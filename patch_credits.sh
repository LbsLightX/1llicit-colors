#!/usr/bin/env bash

# Path to your themes (Adjust if necessary)
THEME_DIR="themes" 
OUTPUT_DIR="patched_themes"

mkdir -p "$OUTPUT_DIR"

echo "╔═══════════════════════════════════════════╗"
echo "║      1LLICIT HEADER PATCHER v1.0          ║"
echo "╚═══════════════════════════════════════════╝"

count=0

for file in "$THEME_DIR"/*.properties; do
    [ -e "$file" ] || continue
    
    filename=$(basename "$file")
    name="${filename%.properties}"
    
    # 1. READ CONTENT (Skip lines starting with # or empty lines at top)
    # We grep for lines starting with 'color', 'background', 'foreground', 'cursor'
    # This ensures we only capture the DATA, not the old comments.
    content=$(grep -E "^(color|background|foreground|cursor)" "$file")
    
    # 2. WRITE NEW FILE
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
    printf "\rProcessing: %-30s" "$name"
done

echo ""
echo "---------------------------------------------"
echo "Done! Patched $count themes."
echo "Location: ./$OUTPUT_DIR/"
echo "---------------------------------------------"
