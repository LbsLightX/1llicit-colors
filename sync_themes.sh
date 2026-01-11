#!/usr/bin/env bash

# 1llicit-colors Sync & Convert Tool
# Syncs new themes from Gogh and converts them to Termux properties format.

GOGH_REPO="https://github.com/Gogh-Co/Gogh.git"
TEMP_DIR="gogh_temp"
TARGET_DIR="themes" # Updated to point to the new subfolder

echo "🚀 Starting 1llicit-colors Sync..."

# 1. Fetch Source Files
[ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"

echo "   Cloning Gogh installs..."
# Clone only the last commit, no history
git clone --depth 1 "$GOGH_REPO" "$TEMP_DIR" >/dev/null 2>&1

SOURCE_DIR="$TEMP_DIR/installs"
COUNT_NEW=0
COUNT_SKIPPED=0

echo "   Processing themes..."

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
    
    echo "   ➕ Converting: $PROFILE_NAME"

    # Start writing (Header)
    {
        echo "# ==============================================================="
        echo "# Color Scheme: $PROFILE_NAME"
        echo "# Source: https://github.com/Gogh-Co/Gogh/blob/main/installs/$BASENAME.sh"
        echo "# Credits: https://github.com/Gogh-Co/Gogh/graphs/contributors"
        echo "# ==============================================================="
        echo ""
    } > "$TARGET_FILE"
    
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
echo "   Cleaning up..."
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Done!"
echo "   New themes created: $COUNT_NEW"
echo "   Existing skipped:   $COUNT_SKIPPED"
