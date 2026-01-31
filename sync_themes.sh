#!/usr/bin/env bash

# 1llicit-colors Sync & Convert Tool

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

# Config
GOGH_REPO="https://github.com/Gogh-Co/Gogh.git"
TEMP_DIR="gogh_temp"
TARGET_DIR="themes"

# Header
echo -e "\n╔═══════════════ ${WHITE}${BOLD}${UNDER}SYNC MANAGER${RESET} ═════════════ ☢"
echo "╬"

# Directory Check
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "╬ ${CYAN}[*]${RESET} Creating target directory..."
    mkdir -p "$TARGET_DIR"
fi

# Fetch Source Files
[ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"

printf "╬ ${CYAN}[*]${RESET} Cloning Gogh repository...\r"
git clone --depth 1 "$GOGH_REPO" "$TEMP_DIR" >/dev/null 2>&1
printf "\r\033[K"
echo -e "╬ ${GREEN}${BOLD}[+]${RESET} Source cloned successfully."

SOURCE_DIR="$TEMP_DIR/installs"
COUNT_NEW=0
COUNT_SKIPPED=0

echo "╬"
echo -e "╬ ${CYAN}[*]${RESET} Processing themes..."

# Iterate and Convert
for sh_file in "$SOURCE_DIR"/*.sh; do
    [ -e "$sh_file" ] || continue
    
    BASENAME=$(basename "$sh_file" .sh)
    TARGET_FILE="$TARGET_DIR/$BASENAME.properties"
    
    # Check if we already have it
    if [ -f "$TARGET_FILE" ]; then
        ((COUNT_SKIPPED++))
        continue
    fi
   
    # Needs conversion
    PROFILE_NAME=$(grep 'export PROFILE_NAME' "$sh_file" | cut -d'"' -f2)
    [ -z "$PROFILE_NAME" ] && PROFILE_NAME="$BASENAME"
    
    # Start writing (Standard Header)
    {
        echo "# ==============================================================="
        echo "# Color Scheme: $PROFILE_NAME"
        echo "#"
        echo "# Project: 1llicit-colors (Lbs-Archives)"
        echo "# ------------------------------------"
        echo "# Current Maintainer: LbsLightX (Expansion & Refactor)"
        echo "# Original Logic: AvinashReddy3108 (Legacy 283 Themes)"
        echo "#"
        echo "# Source: https://github.com/Gogh-Co/Gogh"
        echo "# Credits: https://github.com/Gogh-Co/Gogh/graphs/contributors"
        echo "# ==============================================================="
        echo ""
    } > "$TARGET_FILE"
    
    # Safe Parsing Logic (No Execution)
    # Part 1: Indexed Colors (01-16)
    for i in {01..16}; do
        val=$(grep "export COLOR_$i=" "$sh_file" | cut -d'"' -f2)
        if [ -n "$val" ]; then
            num=$((10#$i))
            idx=$((num - 1))
            echo "color$idx=$val" >> "$TARGET_FILE"
        fi
    done
    
    echo "" >> "$TARGET_FILE"

    # Part 2: Background/Foreground/Cursor
    grep 'export BACKGROUND_COLOR=' "$sh_file" | cut -d'"' -f2 | xargs -I{} echo "background={}" >> "$TARGET_FILE"
    grep 'export FOREGROUND_COLOR=' "$sh_file" | cut -d'"' -f2 | xargs -I{} echo "foreground={}" >> "$TARGET_FILE"
    grep 'export CURSOR_COLOR='     "$sh_file" | cut -d'"' -f2 | xargs -I{} echo "cursor={}"     >> "$TARGET_FILE"
    
    ((COUNT_NEW++))

    # Visual Progress (Updates the same line)
    printf "╬     ${DIM}Converting:${RESET} %-30s\r" "$PROFILE_NAME"
done

# Cleanup
rm -rf "$TEMP_DIR"

printf "\r\033[K" # Clear progress line
echo -e "╬ ${GREEN}${BOLD}[+]${RESET} Sync and conversion complete."

# Report
echo "╬"
echo -e "╬ ${WHITE}${BOLD}Report:${RESET}"
echo -e "╬     New Themes: ${GREEN}${COUNT_NEW}${RESET}"
echo -e "╬     Skipped:    ${DIM}${COUNT_SKIPPED}${RESET}"
echo "╬"
echo -e "╚══════════════════ ${GREEN}${BOLD}FINISHED${RESET} ══════════════════ ☢"
echo ""

# LbsLightX
