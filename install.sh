#!/bin/bash

# Script to install and configure pfSense-Git-Backup

# Function to prompt the user for a value
input_value() {
    prompt_text="$1"
    read -p "$prompt_text: " user_input
    echo "$user_input"
}

# Function to add a cron job
add_cron_job() {
    cron_command="$1"
    (crontab -l 2>/dev/null; echo "$cron_command") | crontab -
}

# Define default values for variables
DEFAULT_GITHUB_USER="your_github_username"
DEFAULT_GITHUB_TOKEN="your_github_token"
DEFAULT_GITHUB_REPO="your_github_repo"
DEFAULT_DISCORD_WEBHOOK_URL="your_discord_webhook_url"
DEFAULT_WEEKLY_BACKUP_DAY="0" # Sunday (0), change as needed
DEFAULT_WEEKLY_BACKUP_HOUR="21" # 21:00 (9 PM), change as needed

# Ask for user-defined values
GITHUB_USER=$(input_value "GitHub Username [$DEFAULT_GITHUB_USER]") || DEFAULT_GITHUB_USER
GITHUB_TOKEN=$(input_value "GitHub Token [$DEFAULT_GITHUB_TOKEN]") || DEFAULT_GITHUB_TOKEN
GITHUB_REPO=$(input_value "GitHub Repository [$DEFAULT_GITHUB_REPO]") || DEFAULT_GITHUB_REPO
DISCORD_WEBHOOK_URL=$(input_value "Discord Webhook URL [$DEFAULT_DISCORD_WEBHOOK_URL]") || DEFAULT_DISCORD_WEBHOOK_URL

# Create the directory for the scripts
INSTALL_DIR="/root/pfsense-config-backup"
mkdir -p $INSTALL_DIR

# Copy the scripts to the installation directory
cp check_config_changes.sh $INSTALL_DIR/
cp weekly_backup.sh $INSTALL_DIR/

# Update the variables in the scripts
sed -i "s/your_github_username/$GITHUB_USER/g" $INSTALL_DIR/check_config_changes.sh
sed -i "s/your_github_token/$GITHUB_TOKEN/g" $INSTALL_DIR/check_config_changes.sh
sed -i "s/your_github_repo/$GITHUB_REPO/g" $INSTALL_DIR/check_config_changes.sh
sed -i "s/your_discord_webhook_url/$DISCORD_WEBHOOK_URL/g" $INSTALL_DIR/check_config_changes.sh

# Ask for weekly backup schedule
echo "Configure Weekly Backup Schedule"
echo "Note: Please enter the day as a number (0 for Sunday, 1 for Monday, ..., 6 for Saturday)"
WEEKLY_BACKUP_DAY=$(input_value "Day of the week (0-6) for Weekly Backup [0]") || DEFAULT_WEEKLY_BACKUP_DAY
WEEKLY_BACKUP_HOUR=$(input_value "Hour (0-23) for Weekly Backup [21]") || DEFAULT_WEEKLY_BACKUP_HOUR

# Update the weekly backup schedule in the script
sed -i "s/your_weekly_backup_day/$WEEKLY_BACKUP_DAY/g" $INSTALL_DIR/weekly_backup.sh
sed -i "s/your_weekly_backup_hour/$WEEKLY_BACKUP_HOUR/g" $INSTALL_DIR/weekly_backup.sh

# Add cron jobs for the scripts
add_cron_job "0 * * * * $INSTALL_DIR/check_config_changes.sh" # Every hour
add_cron_job "$WEEKLY_BACKUP_HOUR * * $WEEKLY_BACKUP_DAY $INSTALL_DIR/weekly_backup.sh"

echo "Installation complete. Scripts are located in $INSTALL_DIR."
echo "Cron jobs have been added to automate backups."
