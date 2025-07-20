# Contributing to AutoFooocus

Thank you for your interest in contributing to AutoFooocus! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Types of Contributions

We welcome several types of contributions:

- **🐛 Bug Reports**: Report issues you encounter
- **✨ Feature Requests**: Suggest new functionality  
- **📝 Documentation**: Improve guides and documentation
- **🔧 Code Improvements**: Bug fixes and optimizations
- **🧪 Testing**: Platform testing and validation
- **🎨 Device Optimization**: CUDA/MPS/CPU improvements

### Getting Started

1. **Fork the Repository**
   ```bash
   git clone https://github.com/your-username/AutoFooocus.git
   cd AutoFooocus
   ```

2. **Set Up Development Environment**
   ```bash
   make setup
   ```

3. **Test Your Setup**
   ```bash
   make test-single PROMPT="test contribution setup"
   ```

## 🏗️ Development Guidelines

### Code Style

- **Shell Scripts**: Follow bash best practices
  - Use `set -e` for error handling
  - Quote variables: `"$variable"`
  - Use meaningful function names
  - Add help text for all scripts

- **Python Scripts**: Follow PEP 8
  - Use type hints where possible
  - Add docstrings for functions
  - Handle errors gracefully
  - Optimize for different devices

- **Makefile**: Keep targets simple and clear
  - One responsibility per target
  - Use shell scripts for complex logic
  - Add help text for all targets

### Architecture Principles

1. **Shell-First**: Primary automation in shell/Makefile
2. **Device Agnostic**: Support CUDA, MPS, and CPU
3. **Self-Contained**: Minimal external dependencies
4. **User-Friendly**: Clear error messages and progress indicators
5. **Modular**: Independent, testable components

## 🔧 Device Optimization

### CUDA Optimization
- Focus on memory efficiency for different VRAM sizes
- Implement batch processing for high-end GPUs
- Use fp16 precision where stable
- Test on various NVIDIA architectures

### MPS (Apple Silicon) Optimization  
- Handle MPS-specific limitations
- Implement proper fallback mechanisms
- Optimize for unified memory architecture
- Test on M1/M2/M3 chips

### CPU Optimization
- Reduce computational complexity
- Implement resolution scaling
- Use efficient schedulers/samplers
- Optimize for multi-core systems

## 🧪 Testing

### Local Testing

```bash
# Test device detection
./scripts/device_optimizer.py

# Test basic functionality
make test-single PROMPT="test prompt"

# Test device-specific configs
make test-config # Uses device-optimized config

# Test model downloads
make download-recommended
```

### Platform Testing

Please test on multiple platforms:
- **Linux**: CUDA support, various distributions
- **macOS**: MPS support, Intel and Apple Silicon
- **Windows**: WSL and native support

### Performance Testing

When contributing optimizations:
- Measure generation time improvements
- Monitor memory usage
- Test with different model sizes
- Document performance gains

## 📝 Submitting Changes

### Pull Request Process

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Follow coding guidelines
   - Add/update documentation
   - Test thoroughly

3. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: descriptive commit message"
   ```

4. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

### Commit Message Format

Use conventional commits:
- `feat:` - New features
- `fix:` - Bug fixes  
- `docs:` - Documentation changes
- `perf:` - Performance improvements
- `refactor:` - Code refactoring
- `test:` - Testing improvements

Examples:
```
feat: add CUDA memory optimization for 6GB GPUs
fix: resolve MPS fallback issue on M1 Macs
docs: update device optimization guide
perf: improve CPU generation speed by 40%
```

## 🐛 Bug Reports

### Before Reporting

1. **Search Existing Issues**: Check if already reported
2. **Test Latest Version**: Ensure you're using current code
3. **Try Device Optimization**: Run `./scripts/device_optimizer.py`

### Bug Report Template

```markdown
## Bug Description
Brief description of the issue

## Environment
- OS: [e.g., macOS 14.0, Ubuntu 22.04]
- Device: [e.g., M2 Pro, RTX 4090, CPU only]
- Python version: [e.g., 3.11.5]
- AutoFooocus version: [commit hash]

## Steps to Reproduce
1. Run command: `make test-single PROMPT="..."`
2. Observe error...

## Expected Behavior
What should happen

## Actual Behavior  
What actually happens

## Logs
```
Paste relevant error messages
```

## Additional Context
Any other relevant information
```

## ✨ Feature Requests

### Feature Request Template

```markdown
## Feature Description
Clear description of the proposed feature

## Use Case
Why is this feature needed? What problem does it solve?

## Proposed Implementation
How could this be implemented?

## Device Considerations
How would this work on CUDA/MPS/CPU?

## Alternatives Considered
Other solutions you've considered
```

## 📚 Documentation

### Documentation Standards

- **Clear and Concise**: Easy to understand
- **Device-Specific**: Include CUDA/MPS/CPU considerations
- **Example-Rich**: Provide working examples
- **Up-to-Date**: Keep synchronized with code changes

### Areas Needing Documentation

- Device optimization guides
- Troubleshooting common issues
- Performance tuning tips
- Custom model integration
- Advanced batch processing

## 💡 Development Tips

### Debugging

```bash
# Enable verbose output
export FOOOCUS_DEBUG=1

# Test device detection
./scripts/device_optimizer.py

# Check installation status
make status

# View recent logs
ls -la Fooocus/batch_outputs/
```

### Performance Profiling

```bash
# Time generation
time make test-single PROMPT="benchmark test"

# Monitor GPU usage (NVIDIA)
nvidia-smi -l 1

# Monitor system resources
htop
```

## 🏅 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- GitHub contributor statistics

## 📞 Getting Help

- **GitHub Issues**: For bugs and feature requests
- **Discussions**: For questions and general discussion
- **Code Review**: We provide thorough, helpful feedback

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to AutoFooocus! Together we can make AI image generation more accessible and efficient across all devices. 🚀