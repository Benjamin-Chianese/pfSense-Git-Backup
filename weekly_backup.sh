#!/bin/sh

# Configuration
GITHUB_USER="your_github_username"
GITHUB_TOKEN="your_github_token"
GITHUB_REPO="your_github_repo"
CONFIG_DIR="/cf/conf"
GIT_DIR="/root/pfsense-config-git"
DISCORD_WEBHOOK_URL="your_discord_webhook_url"
MAX_MONTHLY_BACKUPS=4  # Keep one month of weekly backups

# Function to send a Discord message
send_discord_message() {
    MESSAGE="$1"
    curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"$MESSAGE\"}" $DISCORD_WEBHOOK_URL
}

# Get the pfSense hostname
PFSENSE_HOSTNAME=$(cat /etc/rc.conf.local | grep hostname | cut -d '"' -f 2)

# Change to the configuration directory
cd $CONFIG_DIR

# Create a directory for the pfSense hostname if it doesn't exist
if [ ! -d "$GIT_DIR/$PFSENSE_HOSTNAME" ]; then
    mkdir "$GIT_DIR/$PFSENSE_HOSTNAME"
fi

# Archive the current configuration
CONFIG_FILE="$GIT_DIR/$PFSENSE_HOSTNAME/config_backup_$(date +%Y%m%d_%H%M%S).tgz"
tar -czf "$CONFIG_FILE" *

# Add the new configuration backup
git -C $GIT_DIR/$PFSENSE_HOSTNAME add "$CONFIG_FILE"
git -C $GIT_DIR/$PFSENSE_HOSTNAME commit -m "Weekly full configuration backup - $(date +%Y%m%d_%H%M%S)"

# Push the changes to the GitHub repository
if git -C $GIT_DIR/$PFSENSE_HOSTNAME push origin main; then
    send_discord_message "👍 Weekly configuration backup succeeded for pfSense: $PFSENSE_HOSTNAME"
else
    send_discord_message "❌ Failed to push weekly backup changes to GitHub for pfSense: $PFSENSE_HOSTNAME"
fi

# Prune old monthly backups
while [ "$(git -C $GIT_DIR/$PFSENSE_HOSTNAME rev-list --count main)" -gt $MAX_MONTHLY_BACKUPS ]; do
    OLDEST_MONTHLY_SHA="$(git -C $GIT_DIR/$PFSENSE_HOSTNAME rev-list --max-parents=0 main)"
    git -C $GIT_DIR/$PFSENSE_HOSTNAME branch -D temp-old-monthly-backup
    git -C $GIT_DIR/$PFSENSE_HOSTNAME checkout -b temp-old-monthly-backup "$OLDEST_MONTHLY_SHA"
    git -C $GIT_DIR/$PFSENSE_HOSTNAME rebase --onto main "$OLDEST_MONTHLY_SHA"
    git -C $GIT_DIR/$PFSENSE_HOSTNAME push --force origin temp-old-monthly-backup
    git -C $GIT_DIR/$PFSENSE_HOSTNAME push --force origin :refs/heads/temp-old-monthly-backup
done
