# Device Optimization Guide

AutoFooocus automatically optimizes performance for CUDA, MPS, and CPU devices. This guide explains the optimizations and how to get the best performance.

## 🔍 Automatic Device Detection

```bash
# Detect your device and see recommended settings
make detect-device
```

This will:
- Detect your hardware (CUDA/MPS/CPU)
- Show available memory
- Recommend optimal settings
- Create device-specific configuration

## 🚀 CUDA Optimization (NVIDIA GPUs)

### High-End GPUs (12GB+ VRAM)
- **Batch size**: 4 images
- **Precision**: fp16
- **Resolution**: Full 1024x1024
- **Optimizations**: attention_slicing, vae_slicing
- **Expected speed**: 30-60 seconds per image

### Mid-Range GPUs (8-12GB VRAM)
- **Batch size**: 2 images  
- **Precision**: fp16
- **Resolution**: Full 1024x1024
- **Optimizations**: attention_slicing, vae_slicing, cpu_offload
- **Expected speed**: 45-90 seconds per image

### Entry-Level GPUs (6-8GB VRAM)
- **Batch size**: 1 image
- **Precision**: fp16
- **Resolution**: Full 1024x1024
- **Optimizations**: attention_slicing, vae_slicing, cpu_offload, sequential_cpu_offload
- **Expected speed**: 60-120 seconds per image

### Low VRAM GPUs (<6GB VRAM)
- **Batch size**: 1 image
- **Precision**: fp16
- **Resolution**: 768x768 or 512x512
- **Optimizations**: All optimizations + low_vram mode
- **Expected speed**: 90-180 seconds per image

### CUDA Configuration
```bash
# Test with CUDA optimizations
make test-cuda
```

Uses `configs/batch_config_cuda.json` with CUDA-specific settings.

## ⚡ MPS Optimization (Apple Silicon)

### M3 Max/Ultra (32GB+ Unified Memory)
- **Batch size**: 2 images
- **Precision**: fp16
- **Resolution**: Full 1024x1024
- **Optimizations**: attention_slicing
- **Expected speed**: 45-90 seconds per image

### M2 Pro/Max (16-32GB Unified Memory)
- **Batch size**: 2 images
- **Precision**: fp16
- **Resolution**: Full 1024x1024
- **Optimizations**: attention_slicing, vae_slicing
- **Expected speed**: 60-120 seconds per image

### M1/M2 (8-16GB Unified Memory)
- **Batch size**: 1 image
- **Precision**: fp16
- **Resolution**: Full 1024x1024
- **Optimizations**: attention_slicing, vae_slicing, memory_efficient_attention
- **Expected speed**: 90-150 seconds per image

### MPS Configuration
```bash
# Test with MPS optimizations
make test-mps
```

Uses `configs/batch_config_mps.json` with MPS-specific settings.

## 🐌 CPU Optimization

### High-End CPUs (16+ cores, 32GB+ RAM)
- **Batch size**: 1 image
- **Precision**: fp32 (better for CPU)
- **Resolution**: 512x512 (for speed)
- **Steps**: Reduced to 15-20
- **Scheduler**: euler_a (faster)
- **Expected speed**: 5-10 minutes per image

### Standard CPUs (8-16 cores, 16-32GB RAM)
- **Batch size**: 1 image
- **Precision**: fp32
- **Resolution**: 512x512
- **Steps**: 15
- **Optimizations**: All CPU optimizations
- **Expected speed**: 10-15 minutes per image

### Entry-Level CPUs (<8 cores, <16GB RAM)
- **Batch size**: 1 image
- **Precision**: fp32
- **Resolution**: 384x384
- **Steps**: 10-15
- **Simplified prompts**: Less complex descriptions
- **Expected speed**: 15-30 minutes per image

### CPU Configuration
```bash
# Test with CPU optimizations
make test-cpu
```

Uses `configs/batch_config_cpu.json` with CPU-specific settings.

## ⚙️ Manual Optimization

### Environment Variables

You can manually set optimization flags:

```bash
# Memory optimizations
export FOOOCUS_ATTENTION_SLICING=1
export FOOOCUS_VAE_SLICING=1

# CPU offloading (for low VRAM)
export FOOOCUS_CPU_OFFLOAD=1
export FOOOCUS_SEQUENTIAL_CPU_OFFLOAD=1

# Low VRAM mode
export FOOOCUS_LOW_VRAM=1

# Precision
export FOOOCUS_USE_FP16=1

# Device selection
export FOOOCUS_DEVICE=cuda  # or mps, cpu
```

### Custom Configuration

Create your own optimized config by copying and modifying:

```bash
# Copy device-specific template
cp configs/batch_config_cuda.json configs/my_config.json

# Edit settings
nano configs/my_config.json

# Test your configuration
cd Fooocus
python working_batch.py --config ../configs/my_config.json
```

## 📊 Performance Monitoring

### NVIDIA GPUs
```bash
# Monitor GPU usage
nvidia-smi -l 1

# Monitor memory usage
watch -n 1 "nvidia-smi --query-gpu=memory.used,memory.total --format=csv"
```

### Apple Silicon
```bash
# Monitor system resources
activity monitor  # GUI tool

# Command line monitoring
top -o cpu
```

### CPU
```bash
# Monitor CPU and memory
htop

# Monitor specific process
top -p $(pgrep -f working_batch)
```

## 🔧 Troubleshooting

### CUDA Out of Memory
```bash
# Enable all memory optimizations
export FOOOCUS_ATTENTION_SLICING=1
export FOOOCUS_VAE_SLICING=1
export FOOOCUS_CPU_OFFLOAD=1
export FOOOCUS_LOW_VRAM=1

# Reduce batch size and resolution
make test-single PROMPT="test" STEPS=20
```

### MPS Fallback Issues
```bash
# Enable MPS fallback
export PYTORCH_ENABLE_MPS_FALLBACK=1

# Test with reduced settings
make test-mps
```

### CPU Too Slow
```bash
# Use CPU-optimized config
make test-cpu

# Or reduce settings manually
make test-single PROMPT="simple landscape" STEPS=10
```

## 📈 Performance Tips

1. **Use appropriate resolution**: Higher resolution = slower generation
2. **Optimize step count**: 15-30 steps usually sufficient
3. **Choose efficient schedulers**: euler_a for CPU, dpm_2m_karras for GPU
4. **Manage LoRAs**: Fewer LoRAs = faster generation
5. **Monitor resources**: Don't max out VRAM/RAM
6. **Use batch processing**: More efficient than individual generations

## 🎯 Quick Performance Test

```bash
# Quick performance benchmark
time make test-single PROMPT="performance test landscape"

# Compare device configurations
time make test-cuda
time make test-mps  
time make test-cpu
```

This will help you understand your system's performance characteristics and choose optimal settings.