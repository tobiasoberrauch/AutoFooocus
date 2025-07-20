# Pull Request

## 📋 Description
<!-- Provide a clear description of what this PR does -->

## 🔗 Related Issues
<!-- Link to related issues using "Fixes #123" or "Closes #123" -->
- Fixes #

## 🧪 Type of Change
<!-- Mark the relevant option with an "x" -->
- [ ] 🐛 Bug fix (non-breaking change that fixes an issue)
- [ ] ✨ New feature (non-breaking change that adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🔧 Device optimization (CUDA/MPS/CPU improvements)
- [ ] 🎨 Code style/formatting
- [ ] ♻️ Refactoring (no functional changes)
- [ ] ⚡ Performance improvement

## 🔧 Device Testing
<!-- Mark which devices you've tested on -->
- [ ] NVIDIA GPU (CUDA)
- [ ] Apple Silicon (MPS)
- [ ] CPU only
- [ ] Multiple device types

## ✅ Testing Checklist
<!-- Mark completed items with an "x" -->
- [ ] I have tested my changes locally
- [ ] I have run `make detect-device` to verify device optimization
- [ ] I have tested with `make test-single PROMPT="test"`
- [ ] All existing tests pass
- [ ] I have added tests for new functionality (if applicable)
- [ ] Shell scripts pass syntax check (`bash -n script.sh`)
- [ ] JSON configs are valid (`python -m json.tool config.json`)

## 📖 Documentation
<!-- Mark completed items with an "x" -->
- [ ] I have updated relevant documentation
- [ ] I have added inline code comments where necessary
- [ ] I have updated the CHANGELOG.md (if applicable)
- [ ] I have added/updated configuration examples

## 🚀 Performance Impact
<!-- Describe any performance changes -->
- **Generation speed**: [e.g., 20% faster on CUDA]
- **Memory usage**: [e.g., 15% less VRAM usage]
- **Compatibility**: [e.g., works with older GPUs]

## 📸 Screenshots/Examples
<!-- Add screenshots or example outputs if relevant -->

## 🎯 Validation Commands
<!-- Commands to test this PR -->
```bash
# Add specific commands to validate your changes
make setup
make test-single PROMPT="your test prompt"
```

## 📝 Additional Notes
<!-- Any additional information, warnings, or considerations -->

---

## Reviewer Checklist
<!-- For reviewers -->
- [ ] Code follows project conventions
- [ ] Changes are well documented
- [ ] No security issues introduced
- [ ] Performance implications considered
- [ ] Device compatibility maintained
- [ ] Tests are adequate and passing