#!/bin/bash

# Script to install pfSense-Git-Backup with user-defined variables

# Function to prompt the user for a value
input_value() {
    prompt_text="$1"
    read -p "$prompt_text: " user_input
    echo "$user_input"
}

# Define default values for variables
DEFAULT_GITHUB_USER="your_github_username"
DEFAULT_GITHUB_TOKEN="your_github_token"
DEFAULT_GITHUB_REPO="your_github_repo"
DEFAULT_DISCORD_WEBHOOK_URL="your_discord_webhook_url"

# Ask for user-defined values
GITHUB_USER=$(input_value "GitHub Username [$DEFAULT_GITHUB_USER]") || DEFAULT_GITHUB_USER
GITHUB_TOKEN=$(input_value "GitHub Token [$DEFAULT_GITHUB_TOKEN]") || DEFAULT_GITHUB_TOKEN
GITHUB_REPO=$(input_value "GitHub Repository [$DEFAULT_GITHUB_REPO]") || DEFAULT_GITHUB_REPO
DISCORD_WEBHOOK_URL=$(input_value "Discord Webhook URL [$DEFAULT_DISCORD_WEBHOOK_URL]") || DEFAULT_DISCORD_WEBHOOK_URL

# Update the variables in the scripts
sed -i "s/your_github_username/$GITHUB_USER/g" check_config_changes.sh
sed -i "s/your_github_token/$GITHUB_TOKEN/g" check_config_changes.sh
sed -i "s/your_github_repo/$GITHUB_REPO/g" check_config_changes.sh
sed -i "s/your_discord_webhook_url/$DISCORD_WEBHOOK_URL/g" check_config_changes.sh

# Ask for weekly backup schedule
echo "Configure Weekly Backup Schedule"
echo "Note: Please enter the day as a number (0 for Sunday, 1 for Monday, ..., 6 for Saturday)"
WEEKLY_BACKUP_DAY=$(input_value "Day of the week (0-6) for Weekly Backup [0]") || "0"
WEEKLY_BACKUP_HOUR=$(input_value "Hour (0-23) for Weekly Backup [21]") || "21"

# Update the weekly backup schedule in the script
sed -i "s/your_weekly_backup_day/$WEEKLY_BACKUP_DAY/g" weekly_backup.sh
sed -i "s/your_weekly_backup_hour/$WEEKLY_BACKUP_HOUR/g" weekly_backup.sh

echo "Installation complete. Variables updated in check_config_changes.sh and weekly_backup.sh."
