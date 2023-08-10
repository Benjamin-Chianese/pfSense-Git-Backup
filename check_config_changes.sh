#!/bin/sh

# Configuration
GITHUB_USER="your_github_username"
GITHUB_TOKEN="your_github_token"
GITHUB_REPO="your_github_repo"
CONFIG_DIR="/cf/conf"
GIT_DIR="/root/pfsense-config-git"
DISCORD_WEBHOOK_URL="your_discord_webhook_url"
MAX_WEEKLY_BACKUPS=4   # Keep one week of backups
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

# Check if the Git repository exists, if not, clone it
if [ ! -d "$GIT_DIR" ]; then
    git clone "https://github.com/$GITHUB_USER/$GITHUB_REPO.git" $GIT_DIR
fi

# Check for changes in configuration files
if git -C $GIT_DIR/$PFSENSE_HOSTNAME status --porcelain | grep -q "M"; then
    # Add the changes and commit them to the Git repository
    git -C $GIT_DIR/$PFSENSE_HOSTNAME add .
    git -C $GIT_DIR/$PFSENSE_HOSTNAME commit -m "Automated configuration backup - $(date +%Y%m%d_%H%M%S)"

    # Push the changes to the GitHub repository
    if git -C $GIT_DIR/$PFSENSE_HOSTNAME push origin main; then
        send_discord_message "👍 Automated configuration backup succeeded for pfSense: $PFSENSE_HOSTNAME"
    else
        send_discord_message "❌ Failed to push changes to GitHub for pfSense: $PFSENSE_HOSTNAME"
    fi
else
    send_discord_message "✅ No configuration changes in pfSense for host: $PFSENSE_HOSTNAME"
fi

# Manage old backups (keep the latest MAX_MONTHLY_BACKUPS monthly backups and MAX_WEEKLY_BACKUPS weekly backups)
while [ "$(git -C $GIT_DIR/$PFSENSE_HOSTNAME rev-list --count main)" -gt $MAX_MONTHLY_BACKUPS ]; do
    OLDEST_SHA="$(git -C $GIT_DIR/$PFSENSE_HOSTNAME rev-list --max-parents=0 main)"
    git -C $GIT_DIR/$PFSENSE_HOSTNAME branch -D temp-old-backup
    git -C $GIT_DIR/$PFSENSE_HOSTNAME checkout -b temp-old-backup "$OLDEST_SHA"
    git -C $GIT_DIR/$PFSENSE_HOSTNAME rebase --onto main "$OLDEST_SHA"
    git -C $GIT_DIR/$PFSENSE_HOSTNAME push --force origin temp-old-backup
    git -C $GIT_DIR/$PFSENSE_HOSTNAME push --force origin :refs/heads/temp-old-backup
done

# Manage old weekly backups
while [ "$(git -C $GIT_DIR/$PFSENSE_HOSTNAME rev-list --count temp-old-backup)" -gt $MAX_WEEKLY_BACKUPS ]; do
    OLDEST_WEEKLY_SHA="$(git -C $GIT_DIR/$PFSENSE_HOSTNAME rev-list --max-parents=0 temp-old-backup)"
    git -C $GIT_DIR/$PFSENSE_HOSTNAME branch -D temp-old-weekly-backup
    git -C $GIT_DIR/$PFSENSE_HOSTNAME checkout -b temp-old-weekly-backup "$OLDEST_WEEKLY_SHA"
    git -C $GIT_DIR/$PFSENSE_HOSTNAME rebase --onto temp-old-backup "$OLDEST_WEEKLY_SHA"
    git -C $GIT_DIR/$PFSENSE_HOSTNAME push --force origin temp-old-weekly-backup
    git -C $GIT_DIR/$PFSENSE_HOSTNAME push --force origin :refs/heads/temp-old-weekly-backup
done
