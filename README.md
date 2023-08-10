# pfSense-Git-Backup

**Automated Configuration Backup for pfSense with GitHub Integration**

[![License](https://img.shields.io/github/license/your_github_username/your_github_repo)](https://github.com/your_github_username/your_github_repo/blob/main/LICENSE)

The "pfSense-Git-Backup" project provides a set of scripts to automate the backup of pfSense configuration files to a GitHub repository, including version management and customizable retention policies. It aims to ensure the protection of critical pfSense configurations.

## Features

- **Automatic Change Monitoring**: The `check_config_changes.sh` script monitors configuration files and automatically backs up changes, ensuring every modification is captured.

- **Weekly Full Configuration Backup**: The `weekly_backup.sh` script performs a full configuration backup every week on the specified day and hour, making it easy to restore to a previous state when needed.

- **Version Control**: Backups are stored in a GitHub repository, facilitating version management and configuration comparison over time.

- **Discord Notifications**: Notifications are sent via a Discord webhook to inform you about the success or failure of backups, keeping you updated on the status.

- **Customizable Retention**: The project supports customizable retention policies, allowing you to retain a specific number of backups to meet your requirements.

## Getting Started

1. Clone this repository to your pfSense server (or copy the scripts manually).

2. Run the `install.sh` script to configure the necessary variables (GitHub credentials, Discord webhook URL, weekly backup schedule).

3. Add the scripts to CRON tasks to automate backups based on your needs.

Make sure to test the scripts in a controlled environment before deploying them in production. Always prioritize security and the protection of sensitive information.

## License

This project is licensed under the [MIT License](https://github.com/your_github_username/your_github_repo/blob/main/LICENSE).
