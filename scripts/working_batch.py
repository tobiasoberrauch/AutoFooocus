#!/usr/bin/env python3
"""
AutoFooocus Batch Processor - Direct pipeline approach
Automated batch generation with different model combinations
"""

import os
import sys
import json
import time
from datetime import datetime
from pathlib import Path

# Add Fooocus to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Set environment before importing anything
os.environ['PYTORCH_ENABLE_MPS_FALLBACK'] = '1'

# Clear sys.argv to prevent argument conflicts
original_argv = sys.argv.copy()
sys.argv = [sys.argv[0]]

# Import required modules
import modules.default_pipeline as pipeline
import modules.config as config
import modules.patch
import modules.core
from modules.util import generate_temp_filename
import numpy as np


def initialize_fooocus():
    """Initialize Fooocus pipeline"""
    print("Initializing Fooocus...")
    
    # Convert LoRA format and filter enabled ones
    filtered_loras = []
    for lora in config.default_loras:
        if len(lora) == 3 and lora[0]:  # if enabled
            filtered_loras.append((lora[1], lora[2]))  # (filename, weight)
    
    # Initialize with proper parameters
    pipeline.refresh_everything(
        refiner_model_name='None',
        base_model_name=config.default_base_model_name,
        loras=filtered_loras
    )
    
    print("✓ Fooocus initialized")


def generate_image_direct(prompt, negative_prompt="", steps=30, cfg=7.0, width=1024, height=1024, seed=-1):
    """Generate image using direct pipeline calls"""
    
    print(f"Generating: {prompt[:50]}...")
    
    # Generate seed if needed
    if seed == -1:
        seed = int(np.random.randint(0, 2**31))
    
    print(f"Using seed: {seed}")
    
    # Set up patch globals (required for generation)
    modules.patch.positive_prompt = prompt
    modules.patch.negative_prompt = negative_prompt
    modules.patch.clip_skip = 2
    modules.patch.sharpness = 1.5
    
    # Create empty latent
    latent = modules.core.generate_empty_latent(width=width, height=height, batch_size=1)
    
    # Encode prompts
    positive_cond, negative_cond = pipeline.clip_encode_single(
        clip=pipeline.clip,
        positive_prompt=prompt,
        negative_prompt=negative_prompt
    )
    
    # Run sampling
    print("Running diffusion...")
    
    # Set up sampler parameters
    sampler_name = "dpmpp_2m_sde_gpu"
    scheduler_name = "karras"
    
    # Perform sampling
    samples = pipeline.ksampler(
        model=pipeline.model_base,
        seed=seed,
        steps=steps,
        cfg=cfg,
        sampler_name=sampler_name,
        scheduler=scheduler_name,
        positive=positive_cond,
        negative=negative_cond,
        latent=latent,
        denoise=1.0
    )
    
    # Decode VAE
    print("Decoding image...")
    pixels = pipeline.vae_decode(vae=pipeline.vae, samples=samples)
    
    # Convert to numpy and save
    pixels = pixels.cpu().numpy()
    pixels = np.clip(pixels * 255.0, 0, 255).astype(np.uint8)
    
    # Handle batch dimension
    if len(pixels.shape) == 4:
        pixels = pixels[0]  # Take first image
    
    # Convert CHW to HWC if needed
    if pixels.shape[0] == 3:
        pixels = np.transpose(pixels, (1, 2, 0))
    
    # Save image
    from PIL import Image
    image = Image.fromarray(pixels)
    
    # Generate filename
    temp_filename = generate_temp_filename(folder=Path.cwd(), extension='png')
    image.save(temp_filename, 'PNG')
    
    print(f"✓ Image saved to: {temp_filename}")
    return temp_filename


def load_batch_config(config_file):
    """Load batch configuration from JSON file"""
    with open(config_file, 'r') as f:
        return json.load(f)


def main():
    # Parse arguments
    if len(original_argv) < 2:
        print("Usage:")
        print("  python working_batch.py \"prompt\" [negative] [steps] [count]")
        print("  python working_batch.py --config batch_config.json")
        print("Examples:")
        print("  python working_batch.py \"mountain landscape\" \"blurry\" 20 2")
        print("  python working_batch.py --config batch_config.json")
        return
    
    # Check if using config file
    if original_argv[1] == "--config" and len(original_argv) > 2:
        config = load_batch_config(original_argv[2])
        process_batch_config(config)
        return
    
    # Single prompt mode
    prompt = original_argv[1]
    negative = original_argv[2] if len(original_argv) > 2 else "blurry, low quality"
    steps = int(original_argv[3]) if len(original_argv) > 3 else 30
    count = int(original_argv[4]) if len(original_argv) > 4 else 1
    
    process_single_prompt(prompt, negative, steps, count)


def process_single_prompt(prompt, negative, steps, count):
    """Process a single prompt with specified parameters"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_dir = Path("batch_outputs") / timestamp
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("AutoFooocus Batch Generator - Single Prompt Mode")
    print(f"Prompt: {prompt}")
    print(f"Negative: {negative}")
    print(f"Steps: {steps}")
    print(f"Count: {count}")
    print(f"Output: {output_dir}")
    
    initialize_fooocus()
    
    results = []
    for i in range(count):
        print(f"\n=== Image {i+1}/{count} ===")
        
        try:
            img_path = generate_image_direct(
                prompt=prompt,
                negative_prompt=negative,
                steps=steps,
                cfg=7.0,
                width=1024,
                height=1024,
                seed=-1
            )
            
            if img_path and os.path.exists(img_path):
                src = Path(img_path)
                dst = output_dir / f"img_{i+1:02d}_{src.name}"
                src.rename(dst)
                results.append(str(dst))
                print(f"Moved to: {dst.name}")
            
        except Exception as e:
            print(f"✗ Generation {i+1} failed: {str(e)}")
    
    save_summary(output_dir, {
        'mode': 'single_prompt',
        'prompt': prompt,
        'negative_prompt': negative,
        'steps': steps,
        'total_images': len(results),
        'images': results
    })


def process_batch_config(config):
    """Process batch configuration with multiple prompts and models"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_dir = Path(config['output_dir']) / timestamp
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("AutoFooocus Batch Generator - Config Mode")
    print(f"Prompts: {len(config['prompts'])}")
    print(f"Models: {len(config['models']['base'])}")
    print(f"Output: {output_dir}")
    
    initialize_fooocus()
    
    all_results = []
    total_combinations = len(config['prompts']) * len(config['models']['base'])
    current = 0
    
    for prompt_config in config['prompts']:
        for base_model in config['models']['base']:
            current += 1
            print(f"\n=== Combination {current}/{total_combinations} ===")
            print(f"Model: {base_model}")
            print(f"Prompt: {prompt_config['positive'][:50]}...")
            
            try:
                img_path = generate_image_direct(
                    prompt=prompt_config['positive'],
                    negative_prompt=prompt_config['negative'],
                    steps=config['settings']['steps'],
                    cfg=config['settings']['cfg_scale'],
                    width=config['settings']['width'],
                    height=config['settings']['height'],
                    seed=-1
                )
                
                if img_path and os.path.exists(img_path):
                    src = Path(img_path)
                    dst = output_dir / f"combo_{current:03d}_{base_model.split('.')[0]}_{src.name}"
                    src.rename(dst)
                    
                    result = {
                        'image': str(dst),
                        'model': base_model,
                        'prompt': prompt_config['positive'],
                        'negative_prompt': prompt_config['negative'],
                        'settings': config['settings']
                    }
                    all_results.append(result)
                    print(f"Saved: {dst.name}")
                
            except Exception as e:
                print(f"✗ Combination {current} failed: {str(e)}")
    
    save_summary(output_dir, {
        'mode': 'batch_config',
        'config': config,
        'total_images': len(all_results),
        'results': all_results
    })


def save_summary(output_dir, data):
    """Save generation summary"""
    data['timestamp'] = datetime.now().isoformat()
    
    with open(output_dir / 'summary.json', 'w') as f:
        json.dump(data, f, indent=2)
    
    print(f"\n✓ Generated {data['total_images']} images in {output_dir}")


if __name__ == '__main__':
    main()