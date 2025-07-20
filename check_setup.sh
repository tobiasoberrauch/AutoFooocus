#!/bin/bash

# Fooocus Batch Setup Checker

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}AutoFooocus Setup Check${NC}"
echo "======================================="

# Check if we're in the right directory
if [ ! -f "Makefile" ]; then
    echo -e "${RED}✗ Error: Run this script from the project root directory${NC}"
    exit 1
fi

# Check Python
echo -n "Python 3: "
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    echo -e "${GREEN}✓ $PYTHON_VERSION${NC}"
else
    echo -e "${RED}✗ Python 3 not found${NC}"
fi

# Check Git
echo -n "Git: "
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version 2>&1)
    echo -e "${GREEN}✓ $GIT_VERSION${NC}"
else
    echo -e "${RED}✗ Git not found${NC}"
fi

# Check Make
echo -n "Make: "
if command -v make &> /dev/null; then
    echo -e "${GREEN}✓ Available${NC}"
else
    echo -e "${RED}✗ Make not found${NC}"
fi

# Check disk space
echo -n "Disk space: "
AVAILABLE=$(df -h . | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "${AVAILABLE%.*}" -gt 50 ] 2>/dev/null; then
    echo -e "${GREEN}✓ ${AVAILABLE}G available${NC}"
else
    echo -e "${YELLOW}⚠ Only ${AVAILABLE}G available (50GB+ recommended)${NC}"
fi

echo ""
echo -e "${YELLOW}Fooocus Installation:${NC}"

# Check Fooocus directory
if [ -d "Fooocus" ]; then
    echo -e "${GREEN}✓ Fooocus directory exists${NC}"
    
    # Check virtual environment
    if [ -d "Fooocus/venv" ]; then
        echo -e "${GREEN}✓ Python virtual environment${NC}"
    else
        echo -e "${RED}✗ Virtual environment missing${NC}"
    fi
    
    # Check batch scripts
    if [ -f "Fooocus/working_batch.py" ]; then
        echo -e "${GREEN}✓ Batch processor${NC}"
    else
        echo -e "${RED}✗ Batch processor missing${NC}"
    fi
    
    if [ -f "Fooocus/download_models.py" ]; then
        echo -e "${GREEN}✓ Model downloader${NC}"
    else
        echo -e "${RED}✗ Model downloader missing${NC}"
    fi
    
    # Check models
    echo ""
    echo -e "${YELLOW}Models:${NC}"
    
    BASE_COUNT=$(ls Fooocus/models/checkpoints/*.safetensors 2>/dev/null | wc -l || echo 0)
    LORA_COUNT=$(ls Fooocus/models/loras/*.safetensors 2>/dev/null | wc -l || echo 0)
    VAE_COUNT=$(ls Fooocus/models/vae/*.safetensors 2>/dev/null | wc -l || echo 0)
    
    if [ "$BASE_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✓ Base models: $BASE_COUNT${NC}"
    else
        echo -e "${YELLOW}⚠ No base models found${NC}"
    fi
    
    if [ "$LORA_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✓ LoRA models: $LORA_COUNT${NC}"
    else
        echo -e "${YELLOW}⚠ No LoRA models found${NC}"
    fi
    
    if [ "$VAE_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✓ VAE models: $VAE_COUNT${NC}"
    else
        echo -e "${YELLOW}⚠ No VAE models found${NC}"
    fi
    
else
    echo -e "${RED}✗ Fooocus not installed${NC}"
fi

echo ""
echo -e "${YELLOW}Next Steps:${NC}"

if [ ! -d "Fooocus" ]; then
    echo "1. Run: make setup"
elif [ ! -d "Fooocus/venv" ]; then
    echo "1. Run: make install"
elif [ "$BASE_COUNT" -eq 0 ]; then
    echo "1. Run: make download-models"
else
    echo "1. Ready to use! Try: make test-single PROMPT=\"mountain landscape\""
    echo "2. Or run: make test-batch"
    echo "3. View results: make view-results"
fi

echo ""
echo "For help: make help"