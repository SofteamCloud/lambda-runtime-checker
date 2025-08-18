# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-08-18

### Added
- Main script `check-lambda-runtimes.sh` to identify obsolete runtimes
- Support for Python (3.8, 3.9) and Node.js (16.x, 18.x) runtimes
- Multi-account and multi-region configurable scanning
- Report generation in text, CSV and summary formats
- Runtime type filtering (python, nodejs, all)
- Configurable profile exclusion (e.g., SSO profiles)
- Test script `test-setup.sh` to verify installation
- Complete documentation with README.md
- Contribution guide CONTRIBUTING.md
- MIT open source license
- Git configuration with appropriate .gitignore

### Features
- ✅ Compatible with bash 3.x (macOS and Linux)
- ✅ Error handling and inaccessible profile management
- ✅ Colored messages for better readability
- ✅ Timestamped reports with detailed statistics
- ✅ Configurable AWS regions support
- ✅ Automatic SSO profile exclusion

### Monitored Runtimes
- **Python 3.8**: EOL - Upgrade to python3.12 or python3.13
- **Python 3.9**: EOL December 15, 2025 - Upgrade to python3.12 or python3.13
- **Node.js 16.x**: EOL - Upgrade to nodejs20.x or nodejs22.x
- **Node.js 18.x**: EOL April 30, 2025 - Upgrade to nodejs20.x or nodejs22.x

### Default Regions
- eu-north-1 (Europe - Stockholm)
- eu-west-3 (Europe - Paris)
- us-east-2 (US East - Ohio)
- eu-west-1 (Europe - Ireland)
- eu-central-1 (Europe - Frankfurt)
- us-east-1 (US East - N. Virginia)
- us-west-2 (US West - Oregon)
