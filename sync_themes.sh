#!/usr/bin/env bash

# 1llicit-colors Sync & Convert Tool
# Heavy Box Edition

# Colors & Styles
B="\033[1m"
DIM="\033[2m"
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
WHITE="\033[1;97m"
RESET="\033[0m"

# CONFIG
GOGH_REPO="https://github.com/Gogh-Co/Gogh.git"
TEMP_DIR="gogh_temp"
TARGET_DIR="themes"

echo
echo -e "╔═════════ ${WHITE}${BOLD}SYNC MANAGER${RESET} ════════════════════════════ ◈"
echo "╬"

# 1. Fetch Source Files
[ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"

printf "╬ ${YELLOW}${B}[*]${RESET} Cloning Gogh installs...\r"
git clone --depth 1 "$GOGH_REPO" "$TEMP_DIR" >/dev/null 2>&1
printf "\r\033[K"
echo -e "╬ ${GREEN}${B}[+]${RESET} Source cloned."

SOURCE_DIR="$TEMP_DIR/installs"
COUNT_NEW=0
COUNT_SKIPPED=0

echo "╬"
printf "╬ ${YELLOW}${B}[*]${RESET} Processing themes..."

# 2. Iterate and Convert
for sh_file in "$SOURCE_DIR"/*.sh; do
    [ -e "$sh_file" ] || continue
    
    BASENAME=$(basename "$sh_file" .sh)
    TARGET_FILE="$TARGET_DIR/$BASENAME.properties"
    
    # Check if we already have it
    if [ -f "$TARGET_FILE" ]; then
        ((COUNT_SKIPPED++))
        continue
    fi
    
    # Needs Conversion!
    PROFILE_NAME=$(grep 'export PROFILE_NAME' "$sh_file" | cut -d'"' -f2)
    [ -z "$PROFILE_NAME" ] && PROFILE_NAME="$BASENAME"
    
    printf "\r\033[K"
echo -e "╬ ${GREEN}${B}[+]${RESET} Converting: $PROFILE_NAME"
    
    # Start writing (Standard Header)
    {
        echo "# ==============================================================="
        echo "# Color Scheme: $PROFILE_NAME"
        echo "# Source: https://github.com/Gogh-Co/Gogh/blob/main/installs/$BASENAME.sh"
        echo "# Credits: https://github.com/Gogh-Co/Gogh/graphs/contributors"
        echo "# ==============================================================="
        echo ""
    } > "$TARGET_FILE"
    
    # SAFE PARSING LOGIC (No execution)
    # Part 1: Indexed Colors (0-15) - Written FIRST
    for i in {01..16}; do
        val=$(grep "export COLOR_$i=" "$sh_file" | cut -d'"' -f2)
        if [ -n "$val" ]; then
            num=$((10#$i))
            idx=$((num - 1))
            echo "color$idx=$val" >> "$TARGET_FILE"
        fi
    done
    
    echo "" >> "$TARGET_FILE"

    # Part 2: Background/Foreground/Cursor - Written LAST
    grep 'export BACKGROUND_COLOR=' "$sh_file" | cut -d'"' -f2 | xargs -I{} echo "background={}" >> "$TARGET_FILE"
grep 'export FOREGROUND_COLOR=' "$sh_file" | cut -d'"' -f2 | xargs -I{} echo "foreground={}" >> "$TARGET_FILE"
grep 'export CURSOR_COLOR='     "$sh_file" | cut -d'"' -f2 | xargs -I{} echo "cursor={}"     >> "$TARGET_FILE"
    
    ((COUNT_NEW++))
done

# 3. Cleanup
rm -rf "$TEMP_DIR"

printf "\r\033[K"
echo "╬"
echo -e "╠═════════ ${WHITE}${B}REPORT${RESET} ══════════════════════════════════ ◈"
echo -e "╬ ${GREEN}${B}[+]${RESET} Added:   ${BOLD}${COUNT_NEW}${RESET}"
echo -e "╬ ${CYAN}${B}[-]${RESET} Skipped: ${BOLD}${COUNT_SKIPPED}${RESET}"
echo -e "╚════════════════════════════════════════════════════ ◈"
echo ""
