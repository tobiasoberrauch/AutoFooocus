# AutoFooocus - Project Structure

This project maintains a clean separation between custom scripts and the Fooocus installation.

## Directory Layout

```
AutoFooocus/
│
├── 📁 scripts/              # Custom scripts (version controlled)
│   ├── working_batch.py     # Main batch processor
│   ├── download_models.py   # Model downloader  
│   ├── view_results.py      # Results analyzer
│   └── run_batch.sh         # Shell wrapper
│
├── 📁 configs/              # Configuration files (version controlled)
│   ├── batch_config.json           # Main batch config
│   ├── batch_config_minimal.json   # Quick test config
│   ├── batch_config_styles.json    # Style testing config
│   ├── models_essential.json       # Essential models list
│   └── models_recommended.json     # Recommended models list
│
├── 📄 Makefile              # Automation commands
├── 📄 README.md             # User documentation
├── 📄 check_setup.sh        # Setup verification
├── 📄 .gitignore            # Git ignore rules
│
└── 📁 Fooocus/              # Fooocus installation (NOT in repo)
    ├── (cloned from GitHub)
    ├── (scripts copied here during install)
    └── (models downloaded here)
```

## Key Design Principles

1. **Clean Separation**: All custom code stays in `scripts/` and `configs/`
2. **No Modifications**: Fooocus repository remains untouched
3. **Easy Updates**: Scripts can be updated without touching Fooocus
4. **Version Control**: Only our custom files are in Git
5. **Reproducible**: Anyone can clone and `make setup` to get started

## Workflow

1. **Installation**: `make install`
   - Clones Fooocus from GitHub
   - Sets up Python environment
   - Copies our scripts into Fooocus directory

2. **Updates**: `make update-scripts`
   - Copies latest scripts from `scripts/` to `Fooocus/`
   - No need to reinstall Fooocus

3. **Usage**: All commands work from project root
   - `make test-single PROMPT="..."`
   - `make test-batch`
   - Scripts run inside Fooocus directory

## Benefits

- ✅ Clean Git repository (no large model files)
- ✅ Easy to share and collaborate
- ✅ Scripts can be updated independently
- ✅ Fooocus updates don't affect our code
- ✅ Clear separation of concerns

## Files Not in Repository

The following are created locally and excluded from Git:

- `Fooocus/` - Entire Fooocus installation
- `*.safetensors` - Model files
- `*.ckpt` - Checkpoint files
- `batch_outputs/` - Generated images
- `venv/` - Python environments

This structure ensures the repository stays small and focused on our custom functionality.