# Getting Started with AutoFooocus

## What is AutoFooocus?

AutoFooocus is an automated batch processing system for Fooocus that helps you:
- Test different AI model combinations automatically
- Find the best settings for your prompts
- Compare results from multiple models side-by-side
- Organize and analyze generated images

## Quick 5-Minute Setup

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd AutoFooocus
```

2. **Check your system**
```bash
./check_setup.sh
```

3. **Complete setup** (downloads ~13GB of AI models)
```bash
make setup
```

4. **Test it out**
```bash
make test-single PROMPT="beautiful mountain landscape"
```

## What Happens During Setup

- ✅ Clones Fooocus from GitHub
- ✅ Creates Python virtual environment  
- ✅ Installs all dependencies
- ✅ Copies AutoFooocus scripts
- ✅ Downloads essential AI models
- ✅ Ready to generate images!

## Your First Generation

```bash
# Single image with custom settings
make test-single PROMPT="cyberpunk cityscape" STEPS=25 COUNT=2

# Batch test with multiple prompts and models
make test-batch

# View results in browser
make view-results
```

## What You Get

After running `make setup`, your directory looks like:

```
AutoFooocus/
├── Makefile              # Automation commands
├── README.md             # Full documentation
├── scripts/              # Custom processing scripts
├── configs/              # Configuration templates
└── Fooocus/              # Complete Fooocus installation
    ├── models/           # Downloaded AI models
    └── batch_outputs/    # Your generated images
```

## Next Steps

1. **Experiment with prompts**: Try different artistic styles and subjects
2. **Test model combinations**: See which models work best for your use case
3. **Analyze results**: Use the HTML viewer to compare outputs
4. **Create custom configs**: Design your own batch processing workflows

## Need Help?

```bash
make help                 # Show all available commands
./check_setup.sh         # Verify installation
make status              # Check current state
```

Welcome to automated AI art generation! 🎨✨