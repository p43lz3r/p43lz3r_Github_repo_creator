# GitHub Repository Creator 🚀

A comprehensive bash script for creating GitHub repositories with interactive prompts, automatic GitHub CLI installation, and robust error handling.

## Features ✨

- **🔧 Automatic GitHub CLI Installation** - Detects and installs GitHub CLI on Ubuntu, CentOS, Arch Linux, and macOS
- **🔐 Smart Authentication** - Handles GitHub authentication with multiple methods (web browser, token)
- **✅ Input Validation** - Validates repository names, branch names, and checks for existing repositories
- **📝 README Generation** - Optional README.md creation with customizable template
- **🌿 Custom Branch Support** - Set custom main branch names (develop, feature/main, etc.)
- **🔍 Git Configuration Check** - Automatically configures Git user settings if missing
- **💾 Local Cloning** - Optional repository cloning with proper branch setup
- **🛡️ Error Recovery** - Comprehensive error handling with helpful recovery instructions
- **🎨 Colored Output** - Color-coded terminal output for better readability

## Quick Start 🏃‍♂️

```bash
# Download the script
curl -o create-github-repo.sh https://raw.githubusercontent.com/yourusername/github-repo-creator/main/create-github-repo.sh

# Make it executable
chmod +x create-github-repo.sh

# Run it
./create-github-repo.sh
```

## Requirements 📋

- **Bash** 4.0+ (works on Linux, macOS, Windows WSL)
- **Internet connection** for GitHub API access
- **Sudo privileges** (for automatic GitHub CLI installation)

**Optional:**
- GitHub CLI (`gh`) - automatically installed if missing
- Git - for local repository operations

## Usage Examples 💡

### Create a Public Arduino Project
```
Repository name: arduino-temperature-sensor
Description: DS18B20 temperature monitoring with LCD display
Visibility: Public
Create README: Yes
Main branch: develop
```

### Create a Private Python Project
```
Repository name: micropython-weather-station
Description: MicroPython weather monitoring system
Visibility: Private
Create README: Yes
Main branch: main
```

## Supported Platforms 🖥️

| Platform | Auto-Install | Package Manager |Tested?             |
|----------|--------------|-----------------|--------------------|
| Ubuntu/Debian | ✅ | `apt` | not fully tested
| CentOS/RHEL | ✅ | `yum` | not tested |
| Arch Linux | ✅ | `pacman` | not tested |
| macOS | ✅ | `brew` | not tested |
| Windows | 📖 Manual | `winget` | not tested |

## Script Workflow 🔄

1. **Prerequisites Check** - Verifies GitHub CLI, authentication, Git configuration
2. **Repository Setup** - Interactive prompts for name, description, visibility
3. **Input Validation** - Validates all input according to GitHub/Git rules
4. **Repository Creation** - Creates repository using GitHub API
5. **Local Setup** - Optional cloning and branch configuration
6. **Completion** - Provides repository URL and success confirmation

## Input Validation 🔍

The script validates:
- **Repository names** - GitHub naming conventions (alphanumeric, dots, hyphens, underscores)
- **Branch names** - Git branch naming rules (no spaces, special characters, etc.)
- **Repository collision** - Checks if repository already exists in your account
- **Git configuration** - Ensures user.name and user.email are set

## Error Handling 🛡️

Comprehensive error handling for:
- Missing GitHub CLI (automatic installation)
- Authentication issues (guided setup)
- Network connectivity problems
- Repository creation failures
- Clone operation failures
- Invalid input (with helpful suggestions)

## Configuration Options ⚙️

- **Repository visibility** - Public or Private
- **README creation** - Optional with template
- **Branch naming** - Custom main branch names
- **Local cloning** - Choose to clone or create remote-only
- **Description** - Optional repository description

## Example Output 📺

```bash
==================================================
          GitHub Repository Creator
==================================================

[INFO] Checking GitHub authentication...
[SUCCESS] Already authenticated with GitHub.

[INFO] Repository setup:

Enter repository name: my-awesome-project
Enter repository description (optional): My awesome Arduino project
Repository visibility:
1) Public (visible to everyone)
2) Private (only visible to you and collaborators)
Choose visibility (1-2, default: 1): 1
Create README.md file? (y/N): y
Enter main branch name (default: main): develop

[INFO] Repository configuration:
  Name: my-awesome-project
  Description: My awesome Arduino project
  Visibility: public
  Create README: true
  Main branch: develop

Proceed with creation? (Y/n): Y

[INFO] Creating repository 'my-awesome-project'...
[SUCCESS] Repository 'my-awesome-project' created successfully!
[SUCCESS] Repository URL: https://github.com/username/my-awesome-project

[SUCCESS] Done! Happy coding! 🚀
```


## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Why This Script? 🤔

Creating repositories manually through GitHub's web interface or remembering `gh` CLI syntax is tedious for me. This script provides:

- **Consistency** - Same setup process every time
- **Validation** - Prevents common mistakes
- **Automation** - Handles installation and configuration
- **Flexibility** - Supports various project types and preferences
- **Reliability** - Robust error handling and recovery

---

**Made with ❤️ for me**
