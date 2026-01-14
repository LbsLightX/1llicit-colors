#!/usr/bin/env bash

# ─────────────────────────────
# UI STYLES (shared vibe)
# ─────────────────────────────
B="\033[1m"
DIM="\033[2m"
UNDER="\033[4m"

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
WHITE="\033[1;97m"

RESET="\033[0m"

# ─────────────────────────────
# DEPENDENCY CHECK
# ─────────────────────────────
_require () {
    for pkg in "$@"; do
        command -v "$pkg" >/dev/null 2>&1 || {
            echo -e "${RED}${B}[!] Missing:${RESET} Required dependency '$pkg'"
            exit 1
        }
    done
}

_require jq curl fzf

# ─────────────────────────────
# HEADER
# ─────────────────────────────
echo
echo -e "\n╔══════════ ${WHITE}${B}${UNDER}COLOR THEME INSTALLER${RESET} ═════════ ◈"
echo "╬"
echo -e "╬ ${GREEN}${B}[+] Source:${RESET} 1llicit-colors repository"
echo -e "╬     ${DIM}Browse and apply themes interactively.${RESET}"
echo "╬"

# ─────────────────────────────
# CHECK REPOSITORY AVAILABILITY
# ─────────────────────────────
printf "╬ ${YELLOW}${B}[*] Connecting:${RESET} To repository...\r"

status_code=$(curl -s -o /dev/null -I -w "%{http_code}" \
    "https://github.com/LbsLightX/1llicit-colors")

if [ "$status_code" -ne 200 ]; then
    printf "\r\033[K"
    echo -e "╬ ${RED}${B}[!] Error:${RESET} Unable to reach repository"
    echo -e "╬     ${DIM}Please check your internet connection.${RESET}"
    echo "╚══════════════════════════════════════════ ◈"
    echo
    exit 1
    
fi

# ─────────────────────────────
# FETCH THEME LIST
# ─────────────────────────────
printf "╬ ${YELLOW}${B}[*] Loading:${RESET} Theme list from source...\r"

theme_data=$(curl -fSsL \
    https://api.github.com/repos/LbsLightX/1llicit-colors/git/trees/main?recursive=1 |
    jq -r '.tree[] | select(.path | match("^themes/.*\\.properties$")) |
           (.path | split("/") | last) + " | " + .path')

# clear loading line
printf "\r\033[K"

# ─────────────────────────────
# THEME SELECTION (fzf)
# ─────────────────────────────
selection=$(echo "$theme_data" | fzf \
    --prompt="╬ Selection ⫸ " \
    --height=15 \
    --layout=reverse \
    --header="[ Enter: Apply ] | [ Ctrl+C: Cancel ]" \
    --delimiter=" | " \
    --with-nth=1)

if [ -z "$selection" ]; then
    echo -e "╬ ${RED}${B}[-] Cancelled:${RESET} No theme selected"
    echo "╬"
    echo "╚══════════════════════════════════════════ ◈"
    echo
    exit 0
    
fi

theme_path=$(echo "$selection" | sed 's/.* | //')
theme_name=$(echo "$selection" | sed 's/ | .*//' | sed 's/\.properties//')

# ─────────────────────────────
# APPLY THEME
# ─────────────────────────────
printf "╬ ${YELLOW}${B}[*] Applying:${RESET} $theme_name...\r"

mkdir -p ~/.termux

if curl -fsSL \
    "https://raw.githubusercontent.com/LbsLightX/1llicit-colors/main/$theme_path" \
    -o ~/.termux/colors.properties >/dev/null 2>&1; then

    termux-reload-settings
    printf "\r\033[K"
    echo -e "╬ ${GREEN}${B}[+] Applied:${RESET} $theme_name"
else
    printf "\r\033[K"
    echo -e "╬ ${RED}${B}[!] Failed:${RESET} Unable to apply theme"
fi

echo "╬"
echo "╚══════════════════════════════════════════ ◈"
echo