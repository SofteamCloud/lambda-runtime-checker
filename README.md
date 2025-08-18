# AWS Lambda Runtime Checker

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Script-green.svg)](https://www.gnu.org/software/bash/)

An open source script to identify AWS Lambda functions using obsolete or soon-to-be obsolete runtimes across your AWS accounts.

## 📋 Context

AWS announced the end of support for Python 3.9 on December 15, 2025, following the official end-of-life of Python 3.9 on October 30, 2025. This script helps you identify these Lambda functions across your AWS organization.

## ✨ Features

- 🔍 **Multi-account and multi-region scanning**: Analyzes all your configured AWS profiles
- 📊 **Detailed reports**: Generates reports in text and CSV formats
- 🎯 **Flexible filtering**: Search by runtime type (Python, Node.js, or all)
- ⚙️ **Simple configuration**: Configurable profiles to ignore
- 🚀 **bash 3.x compatible**: Works on macOS and Linux
- 📈 **Statistical summaries**: Overview by account and region

## 🚀 Quick Installation

```bash
# Clone the repository
git clone https://github.com/softeam/lambda-runtime-checker.git
cd lambda-runtime-checker

# Make scripts executable
chmod +x *.sh

# Test installation
./test-setup.sh

# Scan your Python Lambda functions
./check-lambda-runtimes.sh python
```

## 🛠️ Prerequisites

- AWS CLI installed and configured
- `jq` installed (`brew install jq` on macOS)
- AWS profiles configured in `~/.aws/config`
- IAM permissions to list Lambda functions

## 📁 Files

### `check-lambda-runtimes.sh`
Main script to identify Lambda functions with obsolete runtimes.

### `test-setup.sh`
Test script to verify installation and configuration.

### `reports/`
Automatically generated folder containing scan reports.
**Note**: This folder is excluded from Git versioning via `.gitignore`.

### `.gitignore`
Git configuration file to exclude generated reports from versioning.

## 🚀 Usage

### 1. Test installation

```bash
# Make scripts executable
chmod +x *.sh

# Test installation
./test-setup.sh
```

### 2. Identify functions with obsolete runtimes

```bash
# Scan all obsolete runtimes
./check-lambda-runtimes.sh

# Scan Python only
./check-lambda-runtimes.sh python

# Scan Node.js only
./check-lambda-runtimes.sh nodejs

# Show help
./check-lambda-runtimes.sh --help
```

## 📊 Generated Reports

The script generates three types of reports in the `reports/` folder:

1. **Detailed report** (`lambda_obsolete_runtimes_[filter]_[timestamp].txt`)
   - Complete information about each function found
   - Human-readable format

2. **CSV report** (`lambda_obsolete_runtimes_[filter]_[timestamp].csv`)
   - Tabular format for analysis in Excel/Google Sheets
   - Columns: Account, Profile, Region, Function, Runtime, Status, ARN, LastModified

3. **Summary** (`summary_[filter]_[timestamp].txt`)
   - Overview of results
   - Statistics by account and region

## 🎯 Monitored Runtimes

### Python
- `python3.8` - ❌ EOL (End of Life)
- `python3.9` - ⚠️ EOL December 15, 2025

### Node.js
- `nodejs16.x` - ❌ EOL (End of Life)
- `nodejs18.x` - ⚠️ EOL April 30, 2025

### Recommended Runtimes
- **Python**: `python3.12` or `python3.13`
- **Node.js**: `nodejs20.x` or `nodejs22.x`

## 🌍 Scanned Regions

The script scans the following regions (configurable in the script):
- `eu-north-1` (Europe - Stockholm)
- `eu-west-3` (Europe - Paris)
- `us-east-2` (US East - Ohio)
- `eu-west-1` (Europe - Ireland)
- `eu-central-1` (Europe - Frankfurt)
- `us-east-1` (US East - N. Virginia)
- `us-west-2` (US West - Oregon)

## ⚠️ Python 3.9 End of Support Timeline

- **December 15, 2025**: End of security updates, no technical support, removal from AWS Console
- **January 15, 2026**: Cannot create new functions with Python 3.9
- **February 15, 2026**: Cannot update existing functions with Python 3.9

## 🔧 Customization

### Modify scanned regions
Edit the `regions` variable in `check-lambda-runtimes.sh`:

```bash
regions=(
    "eu-west-1"
    "us-east-1"
    # Add your regions
)
```

### Add runtimes to monitor
Modify the runtime status function in `check-lambda-runtimes.sh`:

```bash
get_runtime_status() {
    case "$runtime" in
        "python3.10")
            echo "Soon obsolete - Upgrade recommended"
            ;;
        # Add other runtimes
    esac
}
```

### Configure profiles to ignore
Modify the `IGNORED_PROFILES` variable in `check-lambda-runtimes.sh`:

```bash
IGNORED_PROFILES=(
    "login"
    "sso-profile"
    # Add other profiles to ignore
)
```

## 📝 Output Examples

### Scan summary
```
=== SCAN SUMMARY ===
Date: 2024-01-15 14:30:00
Applied filter: python
Scanned regions: eu-west-1 us-east-1

RESULTS:
- Total functions with obsolete runtimes: 5
- Number of impacted accounts: 2

DETAIL BY ACCOUNT:
- prod-account: 3 function(s)
- dev-account: 2 function(s)
```

### Found function
```
🔍 Found: my-api-function (python3.9) - EOL December 15, 2025 - Upgrade to python3.12 or python3.13
```

## 🆘 Troubleshooting

### "Profile inaccessible" error
- Check that the AWS profile exists: `aws configure list-profiles`
- Check permissions: `aws sts get-caller-identity --profile <profile>`

### "Missing dependencies" error
- Install AWS CLI: [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Install jq: `brew install jq` (macOS) or `apt-get install jq` (Ubuntu)

### Insufficient permissions
Make sure your AWS profiles have the following permissions:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:ListFunctions",
                "lambda:GetFunction"
            ],
            "Resource": "*"
        }
    ]
}
```

## 📞 Support

For any questions or issues:
1. Check error logs
2. Verify AWS permissions
3. Contact AWS Support team if necessary

## 📚 References

- [AWS Lambda Runtime Support Policy](https://docs.aws.amazon.com/lambda/latest/dg/runtime-support-policy.html)
- [Python 3.9 End of Life](https://devguide.python.org/versions/)
- [AWS Lambda Runtimes](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html)

## 🔄 Updating Functions

Once you've identified functions to update, you can:

1. **Via AWS Console**: Modify the runtime in the function configuration
2. **Via AWS CLI**: 
   ```bash
   aws lambda update-function-configuration \
     --function-name <function-name> \
     --runtime python3.12 \
     --profile <profile> \
     --region <region>
   ```
3. **Via Infrastructure as Code**: Update your CloudFormation/SAM/Terraform templates

⚠️ **Important**: Always test your functions after runtime updates to ensure compatibility.

## 🤝 Contributing

Contributions are welcome! Feel free to:

- 🐛 Report bugs via [Issues](../../issues)
- 💡 Propose improvements
- 🔧 Submit Pull Requests
- 📖 Improve documentation

### How to contribute

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Softeam** - *Initial development* - [Softeam](https://github.com/SofteamCloud)

## 🙏 Acknowledgments

- AWS for Lambda runtime documentation
- Open source community for tools and best practices
- All contributors who help improve this project

---

**Developed with ❤️ by [Softeam](https://softeam.com)**
