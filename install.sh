#!/usr/bin/env bash

# 1llicit Interactive Theme Installer

# Colors & Styles
BOLD="\033[1m"
DIM="\033[2m"
UNDER="\033[4m"
CYAN="\033[1;36m"
GREEN="\033[1;32m"
RED="\033[1;31m"
WHITE="\033[1;97m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# Header
echo -e "\n╔══════════════ ${WHITE}${BOLD}${UNDER}THEME INSTALLER${RESET} ═══════════════ ◈"
echo "╬"
echo -e "╬ ${GREEN}${BOLD}[+]${RESET} Source: 1llicit-colors repository"
echo -e "╬     ${DIM}Browse and apply themes interactively.${RESET}"
echo "╬"

# Dependency Check
for pkg in jq curl fzf; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        echo -e "╬ ${RED}${BOLD}[!] Error:${RESET} Missing required dependency: '$pkg'"
        echo -e "╚══════════════════════════════════════════ ◈"
        exit 1
    fi
done

# Check Repository Availability
printf "╬ ${CYAN}[*]${RESET} Connecting to repository...\r"

status_code=$(curl -s -o /dev/null -I -w "%{http_code}" \
    "https://github.com/LbsLightX/1llicit-colors")

if [ "$status_code" -ne 200 ]; then
    printf "\r\033[K"
    echo -e "╬ ${RED}${BOLD}[!] Error:${RESET} Unable to reach repository."
    echo -e "╬     ${DIM}Please check your internet connection.${RESET}"
    echo -e "╚══════════════════════════════════════════ ◈"
    echo
    exit 1
fi

# Fetch Theme List
printf "╬ ${CYAN}[*]${RESET} Loading theme list...\r"

theme_data=$(curl -fSsL \
    https://api.github.com/repos/LbsLightX/1llicit-colors/git/trees/main?recursive=1 |
    jq -r '.tree[] | select(.path | match("^themes/.*\\.properties$")) |
           (.path | split("/") | last) + " | " + .path')

printf "\r\033[K"

# Theme Selection
selection=$(echo "$theme_data" | fzf \
    --prompt="╬ Select Theme ⫸ " \
    --height=15 \
    --layout=reverse \
    --header="[ Ctrl-c to Cancel ] | [ Enter to Apply ]" \
    --delimiter=" | " \
    --with-nth=1)

if [ -z "$selection" ]; then
    echo -e "╬ ${RED}${BOLD}[-]${RESET} Cancelled."
    echo "╬"
    echo -e "╚══════════════════════════════════════════ ◈"
    exit 0
fi

theme_path=$(echo "$selection" | sed 's/.* | //')
theme_name=$(echo "$selection" | sed 's/ | .*//' | sed 's/\.properties//')

# Apply Theme
printf "╬ ${CYAN}[*]${RESET} Applying: $theme_name...\r"

mkdir -p ~/.termux

if curl -fsSL \
    "https://raw.githubusercontent.com/LbsLightX/1llicit-colors/main/$theme_path" \
    -o ~/.termux/colors.properties >/dev/null 2>&1; then

    termux-reload-settings
    printf "\r\033[K"
    echo -e "╬ ${GREEN}${BOLD}[+]${RESET} Applied: $theme_name"
else
    printf "\r\033[K"
    echo -e "╬ ${RED}${BOLD}[!]${RESET} Failed to apply theme."
fi

echo "╬"
echo -e "╚═══════════════ ${GREEN}${BOLD}COMPLETE${RESET} ════════════════ ◈"

# LbsLightX
