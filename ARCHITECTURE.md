# AutoFooocus Architecture

## Design Philosophy

AutoFooocus follows a **shell-first** approach where all core automation is done in shell scripts and Makefile, with Python only used for AI-specific tasks.

## Architecture Layers

```
┌─────────────────────────────────────┐
│           User Interface            │
│     Makefile + Shell Scripts       │
├─────────────────────────────────────┤
│         Automation Layer           │
│    Pure Shell Implementation       │
├─────────────────────────────────────┤
│        AI Processing Layer         │
│      Python (Fooocus Core)        │
├─────────────────────────────────────┤
│        System Resources           │
│    Models + GPU + Storage         │
└─────────────────────────────────────┘
```

## Component Breakdown

### 1. Shell Scripts (scripts/)

**Primary automation - no Python dependencies:**

- `setup_fooocus.sh` - Complete installation management
- `download_models.sh` - Model downloads with curl
- `batch_generator.sh` - Simple batch processing wrapper
- `run_batch.sh` - Legacy wrapper (kept for compatibility)

**These scripts handle:**
- ✅ System requirements checking
- ✅ Git repository cloning
- ✅ Python environment setup
- ✅ Model downloading with progress
- ✅ Script copying and updates
- ✅ Status checking and cleanup

### 2. Makefile

**High-level orchestration:**
- Calls shell scripts for all operations
- Provides consistent interface
- Handles parameter passing
- No direct Python/complex logic

### 3. Python Scripts (when needed)

**AI-specific tasks only:**
- `working_batch.py` - Complex batch processing with model switching
- `view_results.py` - HTML generation and result analysis

## Benefits of Shell-First Design

### ✅ Advantages

1. **No External Dependencies**: Works with just bash, curl, git
2. **Fast Execution**: Shell scripts start instantly
3. **Easy Debugging**: Standard shell tools (set -x, etc.)
4. **Universal Compatibility**: Works on any Unix-like system
5. **Self-Contained**: Each script is independent
6. **Easy Testing**: Can test each component separately

### 🐍 When Python is Used

Python is only invoked when absolutely necessary:
- Complex AI pipeline management
- Multi-model batch processing 
- Result analysis and HTML generation
- JSON configuration parsing

## Workflow Examples

### Shell-Only Workflow (Recommended)
```bash
# Complete setup
make setup                              # → setup_fooocus.sh

# Download models  
make download-recommended               # → download_models.sh

# Simple generation
make test-single PROMPT="landscape"    # → batch_generator.sh

# Check status
make status                            # → setup_fooocus.sh status
```

### Python Workflow (Advanced)
```bash
# Complex batch processing
make test-config                       # → working_batch.py

# Result analysis
make view-results                      # → view_results.py
```

## Directory Structure

```
AutoFooocus/
├── Makefile                    # Pure shell orchestration
├── scripts/                    # Shell-first automation
│   ├── setup_fooocus.sh       # 🐚 Installation management
│   ├── download_models.sh     # 🐚 Model downloads
│   ├── batch_generator.sh     # 🐚 Simple generation
│   ├── run_batch.sh           # 🐚 Legacy wrapper
│   ├── working_batch.py       # 🐍 Complex AI processing  
│   └── view_results.py        # 🐍 Result analysis
├── configs/                    # JSON configurations
└── Fooocus/                    # Created by installation
```

Legend: 🐚 = Shell script, 🐍 = Python script

## Implementation Principles

1. **Shell First**: Try shell solution before Python
2. **Single Responsibility**: Each script has one clear purpose
3. **Fail Fast**: Immediate error checking with `set -e`
4. **User Feedback**: Progress indicators and colored output
5. **Self-Documenting**: Built-in help for all scripts
6. **Modular Design**: Scripts can be used independently

## Testing Strategy

```bash
# Test individual components
./scripts/setup_fooocus.sh help
./scripts/download_models.sh check-space
./scripts/batch_generator.sh --help

# Test Makefile integration
make help
make status

# Test end-to-end
make setup PROMPT="test"
```

This architecture ensures AutoFooocus is lightweight, fast, and easy to maintain while providing powerful AI automation capabilities.