# Changelog

All notable changes to AutoFooocus will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive device optimization for CUDA/MPS/CPU
- Automatic device detection and configuration
- Device-specific batch configuration templates
- Performance monitoring and optimization guides
- GitHub issue templates and CI/CD workflows
- Security policy and contribution guidelines

## [1.0.0] - 2024-01-XX

### Added
- Initial release of AutoFooocus
- Shell-first automation architecture
- One-command setup with `make setup`
- Batch processing system for multiple model combinations
- Direct image generation bypassing Gradio UI
- Model download automation for essential and recommended models
- Result organization and HTML viewer
- Comprehensive documentation and user guides

### Features
- **Device Support**: CUDA, MPS (Apple Silicon), and CPU optimization
- **Model Management**: Automatic downloading from Hugging Face
- **Batch Processing**: Test multiple prompts with different models
- **Performance Optimization**: Device-specific settings and optimizations
- **Result Analysis**: HTML viewer for comparing generated images
- **Configuration**: JSON-based configuration system

### Performance
- **CUDA**: Up to 4x batch processing on high-end GPUs
- **MPS**: Optimized for Apple Silicon with proper fallbacks
- **CPU**: Reduced resolution and steps for acceptable performance

### Documentation
- Complete setup and usage guides
- Device optimization documentation
- Contribution guidelines
- Architecture documentation
- Troubleshooting guides

## Version History

### v1.0.0 (Initial Release)
- Complete AutoFooocus implementation
- Shell-first architecture
- Device optimization system
- Comprehensive documentation

---

## Contributing to Changelog

When contributing to AutoFooocus, please update this changelog with your changes:

### Format
- Use [Keep a Changelog](https://keepachangelog.com/) format
- Add entries under `[Unreleased]` section
- Move to versioned section upon release

### Categories
- `Added` for new features
- `Changed` for changes in existing functionality
- `Deprecated` for soon-to-be removed features
- `Removed` for now removed features
- `Fixed` for any bug fixes
- `Security` for vulnerability fixes

### Example Entry
```markdown
### Added
- New device optimization for AMD GPUs (#123)
- Automatic model caching system (#124)

### Fixed
- Memory leak in batch processing (#125)
- MPS fallback issue on M1 Macs (#126)
```