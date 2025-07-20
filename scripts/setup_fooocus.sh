#!/bin/bash

# AutoFooocus Setup Script
# Handles Fooocus installation and configuration

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO_URL="https://github.com/lllyasviel/Fooocus.git"
WORK_DIR="Fooocus"

# Function to check system requirements
check_requirements() {
    echo -e "${YELLOW}Checking system requirements...${NC}"
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}Error: Python 3 not found${NC}"
        exit 1
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Error: Git not found${NC}"
        exit 1
    fi
    
    # Check disk space (need at least 15GB)
    available=$(df . | tail -1 | awk '{print $4}')
    if [ "$available" -lt 15728640 ]; then  # 15GB in KB
        echo -e "${YELLOW}Warning: Low disk space. Need at least 15GB for models${NC}"
    fi
    
    echo -e "${GREEN}✓ System requirements OK${NC}"
}

# Function to clone Fooocus
clone_fooocus() {
    if [ -d "$WORK_DIR" ]; then
        echo "Fooocus directory already exists"
        return 0
    fi
    
    echo -e "${YELLOW}Cloning Fooocus repository...${NC}"
    git clone "$REPO_URL" "$WORK_DIR"
    echo -e "${GREEN}✓ Fooocus cloned${NC}"
}

# Function to setup Python environment
setup_python() {
    echo -e "${YELLOW}Setting up Python environment...${NC}"
    
    cd "$WORK_DIR"
    
    # Create virtual environment
    python3 -m venv venv
    
    # Activate and install dependencies
    source venv/bin/activate
    pip install -r requirements_versions.txt
    
    cd ..
    echo -e "${GREEN}✓ Python environment ready${NC}"
}

# Function to copy scripts
copy_scripts() {
    echo -e "${YELLOW}Copying AutoFooocus scripts...${NC}"
    
    # Copy Python scripts
    cp scripts/working_batch.py "$WORK_DIR/"
    cp scripts/view_results.py "$WORK_DIR/"
    cp scripts/device_optimizer.py "$WORK_DIR/"
    
    # Copy shell scripts
    cp scripts/run_batch.sh "$WORK_DIR/"
    chmod +x "$WORK_DIR/run_batch.sh"
    
    # Copy configs
    cp configs/batch_config.json "$WORK_DIR/"
    cp configs/batch_config_cuda.json "$WORK_DIR/"
    cp configs/batch_config_mps.json "$WORK_DIR/"
    cp configs/batch_config_cpu.json "$WORK_DIR/"
    
    echo -e "${GREEN}✓ Scripts copied${NC}"
}

# Function to download essential models
download_models() {
    echo -e "${YELLOW}Downloading essential models...${NC}"
    
    cd "$WORK_DIR"
    ../scripts/download_models.sh essentials
    cd ..
    
    echo -e "${GREEN}✓ Essential models downloaded${NC}"
}

# Main installation function
install_fooocus() {
    echo -e "${GREEN}AutoFooocus Installation${NC}"
    echo "======================="
    echo ""
    
    check_requirements
    clone_fooocus
    setup_python
    copy_scripts
    
    echo ""
    echo -e "${GREEN}✓ Fooocus installation complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Download models: make download-models"
    echo "  2. Test generation: make test-single PROMPT=\"your prompt\""
}

# Function to update scripts only
update_scripts() {
    if [ ! -d "$WORK_DIR" ]; then
        echo -e "${RED}Error: Fooocus not installed. Run 'make install' first.${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Updating AutoFooocus scripts...${NC}"
    copy_scripts
    echo -e "${GREEN}✓ Scripts updated${NC}"
}

# Function to show status
show_status() {
    echo -e "${YELLOW}AutoFooocus Installation Status${NC}"
    echo "=============================="
    
    if [ -d "$WORK_DIR" ]; then
        echo -e "${GREEN}✓${NC} Fooocus directory: $WORK_DIR"
        
        if [ -d "$WORK_DIR/venv" ]; then
            echo -e "${GREEN}✓${NC} Python virtual environment"
        else
            echo -e "${RED}✗${NC} Python virtual environment missing"
        fi
        
        if [ -f "$WORK_DIR/working_batch.py" ]; then
            echo -e "${GREEN}✓${NC} Batch processor"
        else
            echo -e "${RED}✗${NC} Batch processor missing"
        fi
        
        echo ""
        echo "Models:"
        base_count=$(ls "$WORK_DIR/models/checkpoints/"*.safetensors 2>/dev/null | wc -l || echo 0)
        lora_count=$(ls "$WORK_DIR/models/loras/"*.safetensors 2>/dev/null | wc -l || echo 0)
        vae_count=$(ls "$WORK_DIR/models/vae/"*.safetensors 2>/dev/null | wc -l || echo 0)
        
        echo "  Base models: $base_count"
        echo "  LoRA models: $lora_count"
        echo "  VAE models: $vae_count"
        
    else
        echo -e "${RED}✗${NC} Fooocus not installed"
        echo "Run 'make install' to set up Fooocus"
    fi
}

# Function to clean installation
clean_install() {
    echo -e "${RED}Removing Fooocus installation...${NC}"
    read -p "Are you sure? This will delete everything. (y/N): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        rm -rf "$WORK_DIR"
        echo -e "${GREEN}✓ Cleaned${NC}"
    else
        echo "Cancelled"
    fi
}

# Parse command
case "${1:-help}" in
    "install")
        install_fooocus
        ;;
    "update-scripts")
        update_scripts
        ;;
    "status")
        show_status
        ;;
    "clean")
        clean_install
        ;;
    "download-models")
        if [ -d "$WORK_DIR" ]; then
            cd "$WORK_DIR"
            ../scripts/download_models.sh "${2:-essentials}"
            cd ..
        else
            echo -e "${RED}Error: Fooocus not installed${NC}"
            exit 1
        fi
        ;;
    "help"|*)
        echo "AutoFooocus Setup Script"
        echo "======================="
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  install           Full Fooocus installation"
        echo "  update-scripts    Update AutoFooocus scripts only"
        echo "  download-models   Download models (essentials|recommended)"
        echo "  status            Show installation status"
        echo "  clean             Remove installation"
        echo "  help              Show this help"
        ;;
esac