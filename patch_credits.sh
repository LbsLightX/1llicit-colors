#!/usr/bin/env bash

# 1llicit Theme Header Patcher

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

# Directories
THEME_DIR="themes" 
OUTPUT_DIR="patched_themes"

# Header
echo -e "\n╔═══════════════ ${WHITE}${BOLD}${UNDER}THEME PATCHER${RESET} ═══════════════ ◈"
echo "╬"

# Verification
if [ ! -d "$THEME_DIR" ]; then
    echo -e "╬ ${RED}${BOLD}[!] Error:${RESET} Directory '${THEME_DIR}' not found."
    echo -e "╚══════════════════════════════════════════ ◈"
    exit 1
fi

echo -e "╬ ${CYAN}[*]${RESET} Creating output directory..."
mkdir -p "$OUTPUT_DIR"

count=0

# Processing Loop
echo -e "╬ ${CYAN}[*]${RESET} Patching headers..."

for file in "$THEME_DIR"/*.properties; do
    [ -e "$file" ] || continue
    
    filename=$(basename "$file")
    name="${filename%.properties}"
    
    # Extract only valid property lines (color, background, foreground, cursor)
    content=$(grep -E "^(color|background|foreground|cursor)" "$file")
    
    # Write new file with 1llicit Credit Header
    {
        echo "# ==============================================================="
        echo "# Color Scheme: $name"
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
        echo "$content"
        echo ""
    } > "$OUTPUT_DIR/$filename"
    
    ((count++))
    
    # Visual Progress
    printf "╬     ${DIM}Processed:${RESET} %-30s\r" "$name"
done

printf "\r\033[K" # Clear the progress line
echo -e "╬ ${GREEN}${BOLD}[+]${RESET} Patching complete."

echo "╬"
echo -e "╬ ${WHITE}${BOLD}Summary:${RESET}"
echo -e "╬     Total Themes: ${GREEN}$count${RESET}"
echo -e "╬     Output Dir:   ${UNDER}./$OUTPUT_DIR/${RESET}"
echo "╬"
echo -e "╚══════════════════ ${GREEN}${BOLD}FINISHED${RESET} ══════════════════ ◈"
echo ""

# LbsLightX
