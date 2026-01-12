#!/usr/bin/env bash

# 1llicit-colors Sync & Convert Tool
# Syncs new themes from Gogh and converts them to Termux properties format.

GOGH_REPO="https://github.com/Gogh-Co/Gogh.git"
TEMP_DIR="gogh_temp"
TARGET_DIR="themes"

echo -e "\n  ╭── \033[1;35mSYNC MANAGER\033[0m ❂ ──"

# 1. Fetch Source Files
[ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"

printf "│ ◷ Cloning Gogh installs...\r"
git clone --depth 1 "$GOGH_REPO" "$TEMP_DIR" >/dev/null 2>&1
printf "│ ⊕ Source cloned.          \n"

SOURCE_DIR="$TEMP_DIR/installs"
COUNT_NEW=0
COUNT_SKIPPED=0

echo "│"
echo "│ ◷ Processing themes..."

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
    
echo "│ ⊕ Converting: $PROFILE_NAME"

    # Start writing
    {
        echo "# ================================================================"
        echo "# Color Scheme: $PROFILE_NAME"
        echo "# Source: https://github.com/Gogh-Co/Gogh/blob/main/installs/$BASENAME.sh"
        echo "# Credits: https://github.com/Gogh-Co/Gogh/graphs/contributors"
        echo "# ================================================================"
        echo ""
    } > "$TARGET_FILE"
    
    # Parse Variables
    for i in {01..16}; do
        val=$(grep "export COLOR_$i=" "$sh_file" | cut -d'"' -f2)
        if [ -n "$val" ]; then
            num=$((10#$i))
            idx=$((num - 1))
            echo "color$idx=$val" >> "$TARGET_FILE"
        fi
    done
    
    echo "" >> "$TARGET_FILE"

    grep 'export BACKGROUND_COLOR=' "$sh_file" | cut -d'"' -f2 | xargs -I{} echo "background={}" >> "$TARGET_FILE"
    grep 'export FOREGROUND_COLOR=' "$sh_file" | cut -d'"' -f2 | xargs -I{} echo "foreground={}" >> "$TARGET_FILE"
    grep 'export CURSOR_COLOR='     "$sh_file" | cut -d'"' -f2 | xargs -I{} echo "cursor={}"     >> "$TARGET_FILE"
    
    ((COUNT_NEW++))
done

# 3. Cleanup
rm -rf "$TEMP_DIR"

echo "│"
echo "╰── [ REPORT ] ──"
echo "    ⊕ New themes: $COUNT_NEW"
echo "    ⦿ Skipped:    $COUNT_SKIPPED"
echo ""
