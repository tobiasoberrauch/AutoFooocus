#!/usr/bin/env python3
"""
AutoFooocus Device Optimizer
Detects and configures optimal settings for CUDA, MPS, and CPU
"""

import sys
import platform
import subprocess
import json
from pathlib import Path

def detect_device():
    """Detect the best available device and return optimization settings"""
    device_info = {
        "device": "cpu",
        "device_name": "CPU",
        "memory_gb": 0,
        "batch_size": 1,
        "precision": "fp32",
        "optimizations": []
    }
    
    # Try CUDA first
    try:
        import torch
        if torch.cuda.is_available():
            device_info["device"] = "cuda"
            device_info["device_name"] = torch.cuda.get_device_name(0)
            device_info["memory_gb"] = torch.cuda.get_device_properties(0).total_memory / (1024**3)
            
            # CUDA optimizations based on VRAM
            if device_info["memory_gb"] >= 12:
                device_info["batch_size"] = 4
                device_info["precision"] = "fp16"
                device_info["optimizations"] = ["attention_slicing", "vae_slicing"]
            elif device_info["memory_gb"] >= 8:
                device_info["batch_size"] = 2
                device_info["precision"] = "fp16"
                device_info["optimizations"] = ["attention_slicing", "vae_slicing", "cpu_offload"]
            elif device_info["memory_gb"] >= 6:
                device_info["batch_size"] = 1
                device_info["precision"] = "fp16"
                device_info["optimizations"] = ["attention_slicing", "vae_slicing", "cpu_offload", "sequential_cpu_offload"]
            else:
                device_info["batch_size"] = 1
                device_info["precision"] = "fp16"
                device_info["optimizations"] = ["attention_slicing", "vae_slicing", "cpu_offload", "sequential_cpu_offload", "low_vram"]
            
            return device_info
    except ImportError:
        pass
    
    # Try MPS (Apple Silicon)
    try:
        import torch
        if hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
            device_info["device"] = "mps"
            device_info["device_name"] = "Apple Silicon (MPS)"
            
            # Get system memory for MPS estimation
            try:
                result = subprocess.run(['sysctl', 'hw.memsize'], capture_output=True, text=True)
                if result.returncode == 0:
                    memory_bytes = int(result.stdout.split(': ')[1])
                    device_info["memory_gb"] = memory_bytes / (1024**3)
                else:
                    device_info["memory_gb"] = 8  # Default assumption
            except:
                device_info["memory_gb"] = 8
            
            # MPS optimizations
            if device_info["memory_gb"] >= 16:
                device_info["batch_size"] = 2
                device_info["precision"] = "fp16"
                device_info["optimizations"] = ["attention_slicing"]
            else:
                device_info["batch_size"] = 1
                device_info["precision"] = "fp16"
                device_info["optimizations"] = ["attention_slicing", "vae_slicing"]
            
            return device_info
    except ImportError:
        pass
    
    # Fall back to CPU
    try:
        import psutil
        device_info["memory_gb"] = psutil.virtual_memory().total / (1024**3)
    except ImportError:
        device_info["memory_gb"] = 8  # Default assumption
    
    # CPU optimizations
    cpu_count = psutil.cpu_count() if 'psutil' in sys.modules else 4
    device_info["device_name"] = f"CPU ({cpu_count} cores)"
    device_info["batch_size"] = 1
    device_info["precision"] = "fp32"  # Better for CPU
    device_info["optimizations"] = ["cpu_only", "attention_slicing", "vae_slicing"]
    
    return device_info

def get_torch_compile_settings(device_info):
    """Get torch.compile settings for the device"""
    if device_info["device"] == "cuda":
        return {
            "enabled": True,
            "mode": "reduce-overhead",
            "backend": "inductor"
        }
    elif device_info["device"] == "mps":
        return {
            "enabled": False,  # torch.compile not fully stable on MPS yet
            "mode": None,
            "backend": None
        }
    else:  # CPU
        return {
            "enabled": True,
            "mode": "default",
            "backend": "inductor"
        }

def create_device_config(device_info):
    """Create optimized configuration for the detected device"""
    config = {
        "device_settings": device_info,
        "torch_compile": get_torch_compile_settings(device_info),
        "generation_settings": {
            "default_steps": 30 if device_info["device"] != "cpu" else 20,
            "default_guidance_scale": 7.5,
            "scheduler": "dpm_2m_karras" if device_info["device"] != "cpu" else "euler_a",
            "enable_vae_tiling": device_info["memory_gb"] < 8,
            "enable_cpu_offload": "cpu_offload" in device_info["optimizations"]
        },
        "model_settings": {
            "load_in_8bit": device_info["memory_gb"] < 6,
            "use_safetensors": True,
            "cache_models": device_info["memory_gb"] >= 12
        }
    }
    
    return config

def save_device_config(config, output_path="device_config.json"):
    """Save device configuration to file"""
    with open(output_path, 'w') as f:
        json.dump(config, f, indent=2)
    print(f"Device configuration saved to {output_path}")

def print_device_info(device_info):
    """Print device information in a user-friendly format"""
    print(f"\n🔍 Device Detection Results:")
    print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"Device: {device_info['device_name']}")
    print(f"Type: {device_info['device'].upper()}")
    print(f"Memory: {device_info['memory_gb']:.1f} GB")
    print(f"Recommended batch size: {device_info['batch_size']}")
    print(f"Precision: {device_info['precision']}")
    
    if device_info['optimizations']:
        print(f"Optimizations: {', '.join(device_info['optimizations'])}")
    
    # Performance expectations
    if device_info["device"] == "cuda":
        if device_info["memory_gb"] >= 12:
            print("⚡ Expected performance: Excellent (30-60s per image)")
        elif device_info["memory_gb"] >= 8:
            print("⚡ Expected performance: Good (45-90s per image)")
        else:
            print("⚡ Expected performance: Moderate (60-120s per image)")
    elif device_info["device"] == "mps":
        print("⚡ Expected performance: Good (45-90s per image)")
    else:
        print("⚡ Expected performance: Slow (5-15 minutes per image)")

def main():
    """Main function for device detection and optimization"""
    if len(sys.argv) > 1 and sys.argv[1] in ['--help', '-h']:
        print("AutoFooocus Device Optimizer")
        print("Usage: python device_optimizer.py [--config-only] [--output FILE]")
        print("  --config-only    Only create config file, don't print info")
        print("  --output FILE    Output config file path (default: device_config.json)")
        return
    
    config_only = '--config-only' in sys.argv
    output_path = "device_config.json"
    
    if '--output' in sys.argv:
        idx = sys.argv.index('--output')
        if idx + 1 < len(sys.argv):
            output_path = sys.argv[idx + 1]
    
    device_info = detect_device()
    config = create_device_config(device_info)
    
    if not config_only:
        print_device_info(device_info)
    
    save_device_config(config, output_path)
    
    if not config_only:
        print(f"\n✅ Run 'make test-single' to test with optimized settings!")

if __name__ == "__main__":
    main()