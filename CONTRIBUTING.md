# Contributing Guide

Thank you for your interest in contributing to the AWS Lambda Runtime Checker project! 🎉

## 🤝 How to Contribute

### Report a Bug

1. Check that the bug hasn't already been reported in [Issues](../../issues)
2. Create a new issue with the "Bug Report" template
3. Include as much detail as possible:
   - Script version
   - Operating system
   - AWS CLI version
   - Complete error messages
   - Steps to reproduce the issue

### Propose an Enhancement

1. Create an issue with the "Feature Request" template
2. Clearly describe the desired functionality
3. Explain why this feature would be useful
4. Propose an implementation if possible

### Submit Code

1. **Fork** the repository
2. **Clone** your fork locally
3. Create a **branch** for your feature:
   ```bash
   git checkout -b feature/my-new-feature
   ```
4. **Develop** your feature
5. **Test** your changes:
   ```bash
   ./test-setup.sh
   ```
6. **Commit** your changes:
   ```bash
   git commit -m "feat: add support for runtime XYZ"
   ```
7. **Push** to your fork:
   ```bash
   git push origin feature/my-new-feature
   ```
8. Create a **Pull Request**

## 📝 Code Standards

### Code Style

- Use **explicit variable names**
- **Comment** complex code
- Follow existing **bash conventions**
- Use **colors** for user messages
- Handle **errors** properly

### Commit Messages

Use the [Conventional Commits](https://www.conventionalcommits.org/) format:

- `feat:` for a new feature
- `fix:` for a bug fix
- `docs:` for documentation
- `style:` for formatting
- `refactor:` for refactoring
- `test:` for tests
- `chore:` for maintenance tasks

Examples:
```
feat: add support for nodejs22.x runtime
fix: correct profile parsing with spaces
docs: update README with new examples
```

### Testing

- Test on **macOS** and **Linux** if possible
- Verify that `./test-setup.sh` passes
- Test with different AWS profiles
- Check that reports are generated correctly

## 🔧 Development Setup

### Prerequisites

- bash 3.x or higher
- AWS CLI configured
- jq installed
- Git

### Installation

```bash
git clone https://github.com/your-username/lambda-runtime-checker.git
cd lambda-runtime-checker
chmod +x *.sh
./test-setup.sh
```

### Project Structure

```
lambda-runtime-checker/
├── check-lambda-runtimes.sh    # Main script
├── test-setup.sh               # Installation tests
├── README.md                   # Documentation
├── CONTRIBUTING.md             # This file
├── LICENSE                     # MIT License
├── .gitignore                  # Files to ignore
└── reports/                    # Generated reports
    └── .gitkeep               # Maintains structure
```

## 🐛 Debugging

### Enable debug mode

```bash
# Add at the top of the script
set -x  # Shows executed commands
```

### Useful logs

- Check file permissions
- Test with a single AWS profile first
- Use `aws sts get-caller-identity` to test access

## 📋 PR Checklist

- [ ] Code follows project standards
- [ ] Tests pass (`./test-setup.sh`)
- [ ] Documentation is updated
- [ ] Commit messages follow conventions
- [ ] No sensitive data in code
- [ ] `.gitignore` is respected

## 🆘 Need Help?

- Check [existing Issues](../../issues)
- Create a new issue with the "question" tag
- Contact maintainers

## 🙏 Thank You!

Every contribution, big or small, is appreciated. Thank you for making this project better! ❤️
