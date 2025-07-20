# AutoFooocus

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/tobiasoberrauch/AutoFooocus/workflows/CI/badge.svg)](https://github.com/tobiasoberrauch/AutoFooocus/actions)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos%20%7C%20windows-lightgrey)](https://github.com/tobiasoberrauch/AutoFooocus)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](https://www.python.org/downloads/)
[![Device Support](https://img.shields.io/badge/devices-CUDA%20%7C%20MPS%20%7C%20CPU-green)](https://github.com/tobiasoberrauch/AutoFooocus/blob/main/DEVICE_OPTIMIZATION.md)

**Automated Batch Processing for Fooocus** - An intelligent shell-first system for testing different AI model combinations with automatic device optimization.

## Quick Start

```bash
# Complete setup (clone + install + download models)
make setup

# Test with a single prompt
make test-single PROMPT="mountain landscape at sunset"

# Test with batch configuration (multiple prompts/models)
make test-batch

# View results in browser
make view-results
```

## Features

- **🚀 Automated Installation**: One-command setup of Fooocus
- **🔧 Device Optimization**: Automatic CUDA/MPS/CPU detection and optimization
- **📦 Model Management**: Download and organize base models, LoRAs, and VAEs
- **⚡ Batch Processing**: Test multiple prompts with different model combinations
- **📊 Result Analysis**: HTML viewer for comparing generated images
- **🎛️ Flexible Configuration**: JSON-based batch configurations with device-specific templates
- **📈 Progress Tracking**: Real-time generation progress with performance metrics

## Installation

### Prerequisites
- Python 3.8+ 
- Git
- ~50GB free disk space (for models)

### Setup
```bash
# Clone this repository
git clone <this-repo>
cd fooocus-batch

# Complete setup
make setup
```

This will:
1. Clone Fooocus from GitHub
2. Create Python virtual environment
3. Install all dependencies
4. Download essential AI models (~13GB)

## Usage

### Device Optimization

AutoFooocus automatically detects and optimizes for your hardware:

```bash
# Detect your device and create optimized configuration
make detect-device

# Test with device-optimized settings
make test-single PROMPT="your prompt here"

# Test with specific device configurations
make test-cuda    # NVIDIA GPU optimized
make test-mps     # Apple Silicon optimized  
make test-cpu     # CPU-only optimized
```

**Performance expectations:**
- **🚀 CUDA (12GB+ VRAM)**: 30-60s per image, batch size 4, fp16
- **⚡ MPS (Apple Silicon)**: 45-90s per image, batch size 2, fp16
- **🐌 CPU**: 5-15 minutes per image, batch size 1, fp32, reduced resolution

### Single Prompt Generation
```bash
# Basic usage (automatically optimized for your device)
make test-single PROMPT="your prompt here"

# With custom settings
make test-single PROMPT="portrait photo" NEGATIVE="cartoon" STEPS=25 COUNT=2
```

### Batch Configuration
Edit `Fooocus/batch_config.json` to define multiple prompts and models:

```json
{
  "prompts": [
    {
      "positive": "professional portrait photography",
      "negative": "cartoon, anime, blurry"
    },
    {
      "positive": "mountain landscape at sunset",
      "negative": "oversaturated, low quality"
    }
  ],
  "models": {
    "base": [
      "sd_xl_base_1.0.safetensors",
      "juggernautXL_v9.safetensors"
    ]
  },
  "settings": {
    "steps": 30,
    "cfg_scale": 7.0,
    "width": 1024,
    "height": 1024
  }
}
```

Then run:
```bash
make test-batch
```

### Shell Script Alternative
```bash
cd Fooocus
./run_batch.sh -p "your prompt" -n "negative prompt" -s 25 -b 2
```

## Model Management

### Download Models
```bash
# Essential models only (~13GB)
make download-models

# All available models (~40GB)
make download-all

# List available models
make list-models

# Check disk space
make check-space
```

### Available Models
- **Base Models**: SDXL base, Juggernaut XL, RealVis XL, DreamShaper XL
- **Refiners**: SDXL refiner for image enhancement
- **LoRAs**: Style modifications (pixel art, watercolor, etc.)
- **VAEs**: Image quality improvements

## Results Analysis

### View Results
```bash
# Create HTML comparison page
make view-results

# Show recent results
make show-results

# Backup results
make backup-results
```

### Result Structure
```
batch_outputs/
├── 20241219_143022/          # Timestamped batch
│   ├── img_01_generated.png  # Generated images
│   ├── img_02_generated.png
│   └── summary.json          # Generation metadata
└── 20241219_151045/
    ├── combo_001_juggernaut_generated.png
    └── summary.json
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make setup` | Complete installation and setup |
| `make install` | Install Fooocus and dependencies |
| `make download-models` | Download essential models |
| `make test-single PROMPT="..."` | Generate with single prompt |
| `make test-batch` | Run batch configuration |
| `make view-results` | Create HTML results viewer |
| `make status` | Show installation status |
| `make clean` | Remove installation |

## Configuration

### Environment Variables
```bash
export PROMPT="default prompt"
export NEGATIVE="blurry, low quality"
export STEPS=30
export COUNT=1
```

### Batch Configuration
The `batch_config.json` file supports:
- Multiple prompts with positive/negative pairs
- Different base models to test
- LoRA combinations
- Custom generation settings
- Output organization

## Advanced Usage

### Direct Python Usage
```bash
cd Fooocus
source venv/bin/activate

# Single generation
python working_batch.py "mountain landscape" "blurry" 25 2

# Batch configuration
python working_batch.py --config batch_config.json

# View results
python view_results.py --html --stats
```

### Model Downloads
```bash
cd Fooocus
source venv/bin/activate

# Download specific category
python download_models.py --category lora

# Download specific models
python download_models.py --category base --models juggernaut dreamshaper
```

## File Structure

```
AutoFooocus/
├── Makefile                  # Main automation
├── README.md                 # This file
├── check_setup.sh           # Setup verification script
├── .gitignore               # Git ignore file
├── scripts/                  # Custom scripts (kept outside Fooocus)
│   ├── working_batch.py      # Main batch processor
│   ├── download_models.py    # Model downloader
│   ├── view_results.py       # Results analyzer
│   └── run_batch.sh          # Shell script wrapper
├── configs/                  # Configuration files
│   └── batch_config.json     # Batch configuration
└── Fooocus/                  # Fooocus installation (created by make install)
    ├── models/               # AI models (downloaded)
    │   ├── checkpoints/      # Base models
    │   ├── loras/           # LoRA models
    │   └── vae/             # VAE models
    └── batch_outputs/        # Generated images

Note: The Fooocus/ directory is created when you run 'make install' and is not part 
of the repository. All custom scripts are kept in scripts/ and copied during installation.
```

## Troubleshooting

### Common Issues

**Installation fails:**
```bash
make clean
make install
```

**Models not downloading:**
```bash
make check-space  # Ensure enough disk space
make download-models
```

**Generation errors:**
```bash
make status  # Check installation
cd Fooocus && source venv/bin/activate && python working_batch.py "test prompt"
```

**Out of memory:**
- Reduce image size in configuration
- Use "Speed" performance mode
- Close other applications

### Getting Help
```bash
make help                    # Show available commands
./run_batch.sh --help       # Script usage
python working_batch.py     # Python script usage
```

## Tips

1. **Start Small**: Test with essential models first
2. **Monitor Progress**: Generation shows real-time progress
3. **Save Results**: Use descriptive prompts for easy identification
4. **Compare Results**: Use HTML viewer to analyze different models
5. **Backup Important**: Save good results before experimenting

## 🤝 Contributing

We welcome contributions! See our [Contributing Guide](CONTRIBUTING.md) for details.

### 🐛 Found a Bug?
- Check [existing issues](https://github.com/tobiasoberrauch/AutoFooocus/issues)
- Use our [bug report template](https://github.com/tobiasoberrauch/AutoFooocus/issues/new?template=bug_report.yml)

### 💡 Have an Idea?
- Use our [feature request template](https://github.com/tobiasoberrauch/AutoFooocus/issues/new?template=feature_request.yml)
- Check the [project roadmap](https://github.com/tobiasoberrauch/AutoFooocus/projects)

### 🔧 Device Optimization
- Help improve performance on your hardware
- Use our [device optimization template](https://github.com/tobiasoberrauch/AutoFooocus/issues/new?template=device_optimization.yml)

## 📊 Project Stats

![GitHub stars](https://img.shields.io/github/stars/tobiasoberrauch/AutoFooocus?style=social)
![GitHub forks](https://img.shields.io/github/forks/tobiasoberrauch/AutoFooocus?style=social)
![GitHub issues](https://img.shields.io/github/issues/tobiasoberrauch/AutoFooocus)
![GitHub pull requests](https://img.shields.io/github/issues-pr/tobiasoberrauch/AutoFooocus)

## 🙏 Acknowledgments

- **[Fooocus](https://github.com/lllyasviel/Fooocus)** - The amazing base framework
- **Contributors** - Everyone who helps improve AutoFooocus
- **Community** - Users providing feedback and device optimization data

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

AutoFooocus builds upon [Fooocus](https://github.com/lllyasviel/Fooocus), which is licensed under the Apache License 2.0.