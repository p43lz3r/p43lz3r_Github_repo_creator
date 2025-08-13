#!/bin/bash

# GitHub Repository Creator Script
# Creates a new repository on GitHub with interactive prompts

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            OS="ubuntu"
        elif command -v yum &> /dev/null; then
            OS="centos"
        elif command -v pacman &> /dev/null; then
            OS="arch"
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS="windows"
    else
        OS="unknown"
    fi
}

# Function to check sudo privileges
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        print_warning "This installation requires sudo privileges."
        print_status "You may be prompted for your password."
        
        # Test sudo access
        if ! sudo -v; then
            print_error "Unable to obtain sudo privileges."
            return 1
        fi
    fi
    return 0
}

# Function to install GitHub CLI
install_gh_cli() {
    print_status "Installing GitHub CLI..."
    
    case $OS in
        "ubuntu")
            if ! check_sudo; then
                return 1
            fi
            print_status "Installing via apt..."
            if sudo apt update && sudo apt install -y gh; then
                :
            else
                print_error "Failed to install via apt."
                return 1
            fi
            ;;
        "centos")
            if ! check_sudo; then
                return 1
            fi
            print_status "Installing via yum..."
            if sudo yum install -y gh; then
                :
            else
                print_error "Failed to install via yum."
                return 1
            fi
            ;;
        "arch")
            if ! check_sudo; then
                return 1
            fi
            print_status "Installing via pacman..."
            if sudo pacman -S --noconfirm github-cli; then
                :
            else
                print_error "Failed to install via pacman."
                return 1
            fi
            ;;
        "macos")
            if command -v brew &> /dev/null; then
                print_status "Installing via Homebrew..."
                if brew install gh; then
                    :
                else
                    print_error "Failed to install via Homebrew."
                    return 1
                fi
            else
                print_error "Homebrew not found. Please install Homebrew first or download from https://cli.github.com/"
                return 1
            fi
            ;;
        "windows")
            print_error "Automatic installation not supported on Windows."
            print_status "Please download and install from: https://cli.github.com/"
            print_status "Or use: winget install --id GitHub.cli"
            return 1
            ;;
        *)
            print_error "Automatic installation not supported for your OS."
            print_status "Please install manually from: https://cli.github.com/"
            return 1
            ;;
    esac
    
    # Verify installation
    if command -v gh &> /dev/null; then
        print_success "GitHub CLI installed successfully!"
        return 0
    else
        print_error "Installation failed. Please install manually."
        return 1
    fi
}

# Function to check if GitHub CLI is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed."
        print_status "GitHub CLI is required for this script to work."
        echo
        
        detect_os
        
        if [[ "$OS" == "unknown" ]] || [[ "$OS" == "windows" ]]; then
            print_status "Manual installation required:"
            print_status "Visit: https://cli.github.com/"
            case $OS in
                "windows")
                    print_status "Or use: winget install --id GitHub.cli"
                    ;;
            esac
            exit 1
        fi
        
        echo "Installation options:"
        echo "1) Install GitHub CLI automatically"
        echo "2) Install manually later"
        read -p "Choose option (1-2): " install_choice
        
        case $install_choice in
            1)
                if install_gh_cli; then
                    print_success "Installation complete! Continuing with script..."
                    echo
                else
                    print_error "Installation failed. Please install manually and run the script again."
                    exit 1
                fi
                ;;
            2)
                print_status "Manual installation instructions:"
                print_status "Visit: https://cli.github.com/"
                case $OS in
                    "ubuntu"|"linux")
                        print_status "Or run: sudo apt install gh"
                        ;;
                    "centos")
                        print_status "Or run: sudo yum install gh"
                        ;;
                    "arch")
                        print_status "Or run: sudo pacman -S github-cli"
                        ;;
                    "macos")
                        print_status "Or run: brew install gh"
                        ;;
                esac
                exit 1
                ;;
            *)
                print_error "Invalid choice. Exiting."
                exit 1
                ;;
        esac
    fi
}

# Function to check authentication
check_auth() {
    print_status "Checking GitHub authentication..."
    
    if ! gh auth status &> /dev/null; then
        print_warning "You are not authenticated with GitHub."
        print_status "Starting authentication process..."
        
        echo
        echo "Choose authentication method:"
        echo "1) Login with web browser (recommended)"
        echo "2) Login with token"
        read -p "Enter choice (1-2): " auth_choice
        
        case $auth_choice in
            1)
                gh auth login --web
                ;;
            2)
                gh auth login --with-token
                ;;
            *)
                print_error "Invalid choice. Exiting."
                exit 1
                ;;
        esac
    else
        print_success "Already authenticated with GitHub."
    fi
}

# Function to validate branch name
validate_branch_name() {
    local branch_name="$1"
    
    # Check for empty name
    if [[ -z "$branch_name" ]]; then
        return 1
    fi
    
    # Git branch name rules:
    # - Cannot start with a dot, hyphen, or slash
    # - Cannot end with a dot or slash
    # - Cannot contain double dots (..)
    # - Cannot contain spaces, tildes, carets, colons, question marks, asterisks, open brackets
    # - Cannot contain ASCII control characters
    # - Cannot be exactly '@'
    
    if [[ "$branch_name" =~ ^[./-] ]] || \
       [[ "$branch_name" =~ [./]$ ]] || \
       [[ "$branch_name" =~ \.\. ]] || \
       [[ "$branch_name" =~ [[:space:]~^:?*\[] ]] || \
       [[ "$branch_name" =~ [[:cntrl:]] ]] || \
       [[ "$branch_name" == "@" ]]; then
        return 1
    fi
    
    return 0
}

# Function to check git configuration
check_git_config() {
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed or not in PATH."
        return 1
    fi
    
    local git_name git_email
    # Use || true to prevent script exit on non-zero return codes
    git_name=$(git config --global user.name 2>/dev/null || true)
    git_email=$(git config --global user.email 2>/dev/null || true)
    
    if [[ -z "$git_name" ]] || [[ -z "$git_email" ]]; then
        print_warning "Git is not configured with user information."
        print_status "This is required for branch operations."
        echo
        
        if [[ -z "$git_name" ]]; then
            read -p "Enter your Git username: " git_name
            if [[ -n "$git_name" ]]; then
                if git config --global user.name "$git_name"; then
                    print_success "Set Git username: $git_name"
                else
                    print_error "Failed to set Git username."
                    return 1
                fi
            else
                print_error "Username cannot be empty."
                return 1
            fi
        fi
        
        if [[ -z "$git_email" ]]; then
            read -p "Enter your Git email: " git_email
            if [[ -n "$git_email" ]]; then
                if git config --global user.email "$git_email"; then
                    print_success "Set Git email: $git_email"
                else
                    print_error "Failed to set Git email."
                    return 1
                fi
            else
                print_error "Email cannot be empty."
                return 1
            fi
        fi
    fi
    
    return 0
}

# Function to get repository name
get_repo_name() {
    while true; do
        read -p "Enter repository name: " repo_name
        
        if [[ -z "$repo_name" ]]; then
            print_error "Repository name cannot be empty."
            continue
        fi
        
        # Check if repository name is valid (GitHub naming rules)
        if [[ ! "$repo_name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
            print_error "Invalid repository name. Use only letters, numbers, dots, hyphens, and underscores."
            continue
        fi
        
        # Get current GitHub username
        local github_user
        github_user=$(gh api user --jq .login 2>/dev/null)
        
        if [[ -z "$github_user" ]]; then
            print_warning "Could not determine GitHub username. Proceeding without collision check."
            break
        fi
        
        # Check if repository already exists (proper format: username/repo)
        if gh repo view "$github_user/$repo_name" &> /dev/null; then
            print_error "Repository '$github_user/$repo_name' already exists."
            print_status "Choose a different name or delete the existing repository first."
            continue
        fi
        
        break
    done
}

# Function to get repository description
get_repo_description() {
    read -p "Enter repository description (optional): " repo_description
}

# Function to ask about repository visibility
get_repo_visibility() {
    echo
    echo "Repository visibility:"
    echo "1) Public (visible to everyone)"
    echo "2) Private (only visible to you and collaborators)"
    read -p "Choose visibility (1-2, default: 1): " visibility_choice
    
    case $visibility_choice in
        2)
            repo_visibility="--private"
            ;;
        *)
            repo_visibility="--public"
            ;;
    esac
}

# Function to ask about README creation
ask_create_readme() {
    read -p "Create README.md file? (y/N): " create_readme
    case $create_readme in
        [Yy]|[Yy][Ee][Ss])
            create_readme=true
            ;;
        *)
            create_readme=false
            ;;
    esac
}

# Function to get main branch name
get_main_branch() {
    while true; do
        read -p "Enter main branch name (default: main): " main_branch
        if [[ -z "$main_branch" ]]; then
            main_branch="main"
        fi
        
        if validate_branch_name "$main_branch"; then
            break
        else
            print_error "Invalid branch name '$main_branch'."
            print_status "Branch names cannot:"
            print_status "  - Start with '.', '-', or '/'"
            print_status "  - End with '.' or '/'"
            print_status "  - Contain spaces, '..', '~', '^', ':', '?', '*', or '['"
            print_status "  - Be exactly '@'"
        fi
    done
}

# Function to create README content
create_readme_content() {
    cat > README.md << EOF
# $repo_name

$repo_description

## Description

Add a more detailed description of your project here.

## Installation

Instructions on how to install and set up your project.

## Usage

Examples of how to use your project.

## Contributing

Guidelines for contributing to this project.

## License

This project is licensed under the [MIT License](LICENSE).

---

*Created on $(date)*
EOF
}

# Function to create the repository
create_repository() {
    print_status "Creating repository '$repo_name'..."
    
    # Build the gh repo create command
    cmd="gh repo create $repo_name $repo_visibility"
    
    if [[ -n "$repo_description" ]]; then
        cmd="$cmd --description \"$repo_description\""
    fi
    
    if [[ "$create_readme" == true ]]; then
        cmd="$cmd --add-readme"
    fi
    
    # Execute the command
    if eval $cmd; then
        print_success "Repository '$repo_name' created successfully!"
        
        # Get current GitHub username for proper repo reference
        local github_user
        github_user=$(gh api user --jq .login 2>/dev/null)
        
        if [[ -z "$github_user" ]]; then
            print_warning "Could not determine GitHub username."
            repo_full_name="$repo_name"
        else
            repo_full_name="$github_user/$repo_name"
        fi
        
        # Clone the repository locally if README was created or if user wants to
        read -p "Clone repository locally? (Y/n): " clone_repo
        case $clone_repo in
            [Nn]|[Nn][Oo])
                print_status "Repository created remotely only."
                ;;
            *)
                print_status "Cloning repository locally..."
                
                if gh repo clone "$repo_full_name"; then
                    print_success "Repository cloned successfully."
                    
                    # Handle custom main branch if needed
                    if [[ "$create_readme" == true ]] && [[ "$main_branch" != "main" ]]; then
                        print_status "Setting up custom main branch '$main_branch'..."
                        
                        if cd "$repo_name" 2>/dev/null; then
                            if git branch -M "$main_branch" && git push -u origin "$main_branch"; then
                                print_success "Main branch set to '$main_branch'."
                            else
                                print_error "Failed to set custom main branch."
                                print_status "Repository exists locally with default branch 'main'."
                            fi
                            cd ..
                        else
                            print_error "Could not enter repository directory."
                        fi
                    fi
                    
                    print_success "Repository available at: ./$repo_name"
                else
                    print_error "Failed to clone repository locally."
                    print_status "Repository was created successfully on GitHub."
                    print_status "You can clone it manually later with:"
                    print_status "  gh repo clone $repo_full_name"
                fi
                ;;
        esac
        
        # Show repository URL
        local repo_url
        repo_url=$(gh repo view "$repo_full_name" --json url -q .url 2>/dev/null)
        
        if [[ -n "$repo_url" ]]; then
            print_success "Repository URL: $repo_url"
        else
            print_success "Repository created: $repo_full_name"
        fi
        
    else
        print_error "Failed to create repository."
        print_status "This could be due to:"
        print_status "  - Network connectivity issues"
        print_status "  - Repository name already exists"
        print_status "  - Insufficient GitHub permissions"
        print_status "  - GitHub API rate limits"
        exit 1
    fi
}

# Main function
main() {
    echo "=================================================="
    echo "          GitHub Repository Creator"
    echo "=================================================="
    echo
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    check_gh_cli
    print_status "GitHub CLI check completed."
    
    check_auth
    print_status "Authentication check completed."
    
    check_git_config
    print_status "Git configuration check completed."
    
    echo
    print_status "Repository setup:"
    
    # Get repository details
    get_repo_name
    get_repo_description
    get_repo_visibility
    ask_create_readme
    get_main_branch
    
    echo
    print_status "Repository configuration:"
    echo "  Name: $repo_name"
    echo "  Description: ${repo_description:-"(none)"}"
    echo "  Visibility: $(echo $repo_visibility | sed 's/--//')"
    echo "  Create README: $create_readme"
    echo "  Main branch: $main_branch"
    
    echo
    read -p "Proceed with creation? (Y/n): " confirm
    case $confirm in
        [Nn]|[Nn][Oo])
            print_status "Repository creation cancelled."
            exit 0
            ;;
        *)
            create_repository
            ;;
    esac
    
    echo
    print_success "Done! Happy coding! 🚀"
}

# Run the script
main "$@"
