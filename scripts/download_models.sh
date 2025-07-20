#!/bin/bash

# AutoFooocus Model Downloader
# Downloads common SDXL base models and LoRAs from Hugging Face

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Default directories
BASE_DIR="$(pwd)"
MODELS_DIR="$BASE_DIR/models"
CHECKPOINTS_DIR="$MODELS_DIR/checkpoints"
LORAS_DIR="$MODELS_DIR/loras"
VAE_DIR="$MODELS_DIR/vae"

# Create model directories
mkdir -p "$CHECKPOINTS_DIR" "$LORAS_DIR" "$VAE_DIR"

# Function to download file with progress
download_file() {
    local url="$1"
    local output_file="$2"
    local description="$3"
    local size="$4"
    
    echo -e "\n📥 Downloading: $(basename "$output_file")"
    echo "   Description: $description"
    echo "   Expected size: $size"
    
    if [ -f "$output_file" ]; then
        echo "   ✓ Already exists, skipping..."
        return 0
    fi
    
    if curl -L --progress-bar -o "$output_file.tmp" "$url"; then
        mv "$output_file.tmp" "$output_file"
        echo "   ✓ Downloaded successfully!"
        return 0
    else
        echo "   ✗ Download failed"
        rm -f "$output_file.tmp"
        return 1
    fi
}

# Function to download essential models
download_essentials() {
    echo -e "${YELLOW}Downloading essential models...${NC}"
    
    # SDXL Base
    download_file \
        "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors" \
        "$CHECKPOINTS_DIR/sd_xl_base_1.0.safetensors" \
        "Official Stable Diffusion XL base model" \
        "6.94 GB"
    
    # SDXL Refiner
    download_file \
        "https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors" \
        "$CHECKPOINTS_DIR/sd_xl_refiner_1.0.safetensors" \
        "Official SDXL refiner model" \
        "6.08 GB"
    
    # Official LoRA
    download_file \
        "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_offset_example-lora_1.0.safetensors" \
        "$LORAS_DIR/sd_xl_offset_example-lora_1.0.safetensors" \
        "Official offset LoRA example" \
        "49.6 MB"
    
    # SDXL VAE
    download_file \
        "https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors" \
        "$VAE_DIR/sdxl_vae.safetensors" \
        "Official SDXL VAE" \
        "334.6 MB"
    
    echo -e "${GREEN}✓ Essential models downloaded${NC}"
}

# Function to download recommended models
download_recommended() {
    echo -e "${YELLOW}Downloading recommended models...${NC}"
    
    # Call essentials first
    download_essentials
    
    # Additional base models
    download_file \
        "https://huggingface.co/RunDiffusion/Juggernaut-XL-v9/resolve/main/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors" \
        "$CHECKPOINTS_DIR/juggernautXL_v9.safetensors" \
        "Popular photorealistic model" \
        "6.62 GB"
    
    download_file \
        "https://huggingface.co/SG161222/RealVisXL_V4.0/resolve/main/RealVisXL_V4.0.safetensors" \
        "$CHECKPOINTS_DIR/realvisxlV40.safetensors" \
        "Photorealistic model" \
        "6.94 GB"
    
    # Additional LoRAs
    download_file \
        "https://huggingface.co/nerijs/pixel-art-xl/resolve/main/pixel-art-xl.safetensors" \
        "$LORAS_DIR/pixel-art-xl.safetensors" \
        "Pixel art style" \
        "49.6 MB"
    
    download_file \
        "https://huggingface.co/ostris/watercolor_style_lora_sdxl/resolve/main/watercolor_v1_sdxl.safetensors" \
        "$LORAS_DIR/watercolor_v1_sdxl.safetensors" \
        "Watercolor painting style" \
        "49.6 MB"
    
    echo -e "${GREEN}✓ Recommended models downloaded${NC}"
}

# Function to show available disk space
check_space() {
    echo -e "${YELLOW}Checking disk space...${NC}"
    df -h .
    echo ""
    echo "Essential models need ~13GB"
    echo "Recommended models need ~20GB"
    echo "All models need ~40GB"
}

# Function to list downloaded models
list_models() {
    echo -e "${YELLOW}Downloaded Models:${NC}"
    echo ""
    
    echo "Base Models:"
    if ls "$CHECKPOINTS_DIR"/*.safetensors >/dev/null 2>&1; then
        for model in "$CHECKPOINTS_DIR"/*.safetensors; do
            echo "  ✓ $(basename "$model")"
        done
    else
        echo "  (none)"
    fi
    
    echo ""
    echo "LoRA Models:"
    if ls "$LORAS_DIR"/*.safetensors >/dev/null 2>&1; then
        for model in "$LORAS_DIR"/*.safetensors; do
            echo "  ✓ $(basename "$model")"
        done
    else
        echo "  (none)"
    fi
    
    echo ""
    echo "VAE Models:"
    if ls "$VAE_DIR"/*.safetensors >/dev/null 2>&1; then
        for model in "$VAE_DIR"/*.safetensors; do
            echo "  ✓ $(basename "$model")"
        done
    else
        echo "  (none)"
    fi
}

# Function to show help
show_help() {
    echo "AutoFooocus Model Downloader"
    echo "============================"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  essentials     Download essential models (~13GB)"
    echo "  recommended    Download recommended models (~20GB)"
    echo "  check-space    Show available disk space"
    echo "  list           List downloaded models"
    echo "  help           Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 essentials"
    echo "  $0 recommended"
    echo "  $0 list"
}

# Main execution
case "${1:-help}" in
    "essentials")
        download_essentials
        ;;
    "recommended")
        download_recommended
        ;;
    "check-space")
        check_space
        ;;
    "list")
        list_models
        ;;
    "help"|*)
        show_help
        ;;
esac