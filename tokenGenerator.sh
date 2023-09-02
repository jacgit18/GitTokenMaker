#!/bin/bash

# Function to install a package if it is not already installed
install_if_missing() {
    local package_name="$1"
    if ! command -v "$package_name" >/dev/null 2>&1; then
        echo "Installing $package_name..."
        if [ "$(uname -s)" = "Linux" ]; then
            sudo apt-get update
            sudo apt-get install -y "$package_name"
        elif [ "$(uname -s)" = "Darwin" ]; then
            brew install "$package_name"
        else
            echo "Unsupported operating system. Please install $package_name manually."
            exit 1
        fi
    fi
}

# Install required dependencies
install_if_missing "curl"
install_if_missing "jq"
install_if_missing "git"

TOKEN_FILE="$HOME/.github_token"
GITHUB_USERNAME="your_username"
GITHUB_REPO="your_repository"

# Function to generate a new GitHub token
generate_token() {
    read -sp "Enter your GitHub password: " password
    echo

    response=$(curl -X POST -u "$GITHUB_USERNAME:$password" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/authorizations" -d '{"scopes":["repo"], "note":"Token for script"}')
    new_token=$(echo "$response" | jq -r .token)

    if [ -n "$new_token" ]; then
        echo "$new_token" > "$TOKEN_FILE"
        chmod 600 "$TOKEN_FILE"
        echo "Token generated and stored."
    else
        echo "Token generation failed."
        exit 1
    fi
}

# Function to update the environment with the latest token
update_environment() {
    export GITHUB_TOKEN=$(cat "$TOKEN_FILE")
}

# Check if the token exists and is valid
if [ -f "$TOKEN_FILE" ]; then
    update_environment
else
    echo "GitHub token not found. Generating a new token..."
    generate_token
    update_environment
fi

# Your actual Git-related scripts using the token go here
# For example:
# git clone using $GITHUB_TOKEN
# git pull using $GITHUB_TOKEN
# git push using $GITHUB_TOKEN
