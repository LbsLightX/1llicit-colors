#!/usr/bin/env bash

# ─────────────────────────────
# UI STYLES
# ─────────────────────────────
BOLD="\033[1m"
DIM="\033[2m"
UNDER="\033[4m"

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
WHITE="\033[1;97m"

RESET="\033[0m"

# ─────────────────────────────
# CONFIG
# ─────────────────────────────
GOGH_REPO="https://github.com/Gogh-Co/Gogh.git"
TEMP_DIR="gogh_temp"
TARGET_DIR="themes"
SOURCE_DIR="$TEMP_DIR/installs"

COUNT_NEW=0
COUNT_SKIPPED=0

# ─────────────────────────────
# HEADER
# ─────────────────────────────
echo
echo -e "╔═════════ ${WHITE}${BOLD}${UNDER}SYNC COLOR THEMES${RESET} ═════════ ◈"
echo "╬"
echo -e "╬ ${GREEN}${BOLD}[+] Source:${RESET} Gogh color schemes"
echo -e "╬     ${DIM}Syncs Gogh themes into Termux .properties format.${RESET}"
echo "╬"

# ─────────────────────────────
# FETCH SOURCE
# ─────────────────────────────
echo -e "╬ ${YELLOW}${BOLD}[*] Fetching:${RESET} Source repository"
echo -e "╬     ${DIM}This may take a moment depending on your network.${RESET}"
echo "╬"

rm -rf "$TEMP_DIR"
git clone --depth 1 "$GOGH_REPO" "$TEMP_DIR" >/dev/null 2>&1

echo -e "╬ ${GREEN}${BOLD}[+] Ready:${RESET} Source repository"
echo "╬"

# ─────────────────────────────
# CONVERT THEMES (LIVE STATUS)
# ─────────────────────────────
printf "╬ ${YELLOW}${BOLD}[*] Converting:${RESET} Themes..."

for sh_file in "$SOURCE_DIR"/*.sh; do
    [ -e "$sh_file" ] || continue

    BASENAME=$(basename "$sh_file" .sh)
    TARGET_FILE="$TARGET_DIR/$BASENAME.properties"

    if [ -f "$TARGET_FILE" ]; then
        ((COUNT_SKIPPED++))
        continue
    fi

    printf "\r╬ ${YELLOW}${BOLD}[*] Converting:${RESET} Themes ${DIM}(new: %d, skipped: %d)${RESET}   " \
           "$COUNT_NEW" "$COUNT_SKIPPED"

    {
        echo "# $BASENAME"
        echo
        bash "$sh_file" | grep -E '^(color|background|foreground|cursor)' | sed 's/export //'
    } > "$TARGET_FILE"

    ((COUNT_NEW++))
done

# clear & replace converting line
printf "\r\033[2K"
echo -e "╬ ${GREEN}${BOLD}[+] Completed:${RESET} Theme conversion"
echo "╬"

# cleanup temp dir
rm -rf "$TEMP_DIR"

# ─────────────────────────────
# REPORT
# ─────────────────────────────
echo -e "╬ ${WHITE}${BOLD}[ SYNC REPORT ]${RESET}"
echo -e "╬     ${GREEN}${BOLD}[+] Added:${RESET}   ${BOLD}${COUNT_NEW}${RESET}"
echo -e "╬     ${RED}${BOLD}[-] Skipped:${RESET} ${BOLD}${COUNT_SKIPPED}${RESET}"
echo "╬"
echo "╚═════════════════════════════════════ ◈"