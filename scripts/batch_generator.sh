#!/bin/bash

# AutoFooocus Batch Generator
# Shell-based batch processing for Fooocus

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Default values
PROMPT=""
NEGATIVE="blurry, low quality"
STEPS=30
COUNT=1
CONFIG_FILE=""
OUTPUT_DIR="batch_outputs"

# Function to show help
show_help() {
    echo "AutoFooocus Batch Generator"
    echo "=========================="
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -p, --prompt TEXT      Positive prompt (required)"
    echo "  -n, --negative TEXT    Negative prompt (default: 'blurry, low quality')"
    echo "  -s, --steps NUM        Number of steps (default: 30)"
    echo "  -c, --count NUM        Number of images (default: 1)"
    echo "  -o, --output DIR       Output directory (default: batch_outputs)"
    echo "  -h, --help             Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 -p \"mountain landscape\" -s 25 -c 2"
    echo "  $0 -p \"cyberpunk city\" -n \"cartoon\" -s 20"
}

# Function to check if Fooocus is properly set up
check_fooocus() {
    if [ ! -f "venv/bin/activate" ]; then
        echo -e "${RED}Error: Fooocus virtual environment not found${NC}"
        echo "Run 'make install' first"
        exit 1
    fi
    
    if [ ! -f "working_batch.py" ]; then
        echo -e "${RED}Error: working_batch.py not found${NC}"
        echo "Run 'make update-scripts' first"
        exit 1
    fi
}

# Function to generate images
generate_images() {
    echo -e "${YELLOW}AutoFooocus Batch Generator${NC}"
    echo "=========================="
    echo "Prompt: $PROMPT"
    echo "Negative: $NEGATIVE"
    echo "Steps: $STEPS"
    echo "Count: $COUNT"
    echo "Output: $OUTPUT_DIR"
    echo ""
    
    # Activate virtual environment and run Python script
    source venv/bin/activate
    python working_batch.py "$PROMPT" "$NEGATIVE" "$STEPS" "$COUNT"
    
    echo -e "${GREEN}✓ Generation complete!${NC}"
    echo "Check results in: $OUTPUT_DIR"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--prompt)
            PROMPT="$2"
            shift 2
            ;;
        -n|--negative)
            NEGATIVE="$2"
            shift 2
            ;;
        -s|--steps)
            STEPS="$2"
            shift 2
            ;;
        -c|--count)
            COUNT="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$PROMPT" ]; then
    echo -e "${RED}Error: Prompt is required${NC}"
    show_help
    exit 1
fi

# Check setup and generate
check_fooocus
generate_images