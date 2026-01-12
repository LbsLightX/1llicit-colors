#!/usr/bin/env bash
tmp_IFS=$IFS

_require () {
    for pkg in "$@"
    do
        command -v $pkg >/dev/null 2>&1 || { echo >&2 "I require '$pkg' but it's not installed. Aborting."; exit 1; }
    done
}

_require jq curl fzf

# Get themes from your new 1llicit-colors repository
status_code=$(curl -s -o /dev/null -I -w "%{http_code}" "https://github.com/LbsLightX/1llicit-colors")
if [ "$status_code" -eq "200" ]; then
    echo "Fetching themes list from 1llicit-colors, please wait."
    
    # Updated Logic: Recursive search into 'themes/' folder
    theme=$(curl -fSsL https://api.github.com/repos/LbsLightX/1llicit-colors/git/trees/main?recursive=1 | jq -r '.tree[] | select(.path | match("^themes/.*\\.properties$")) | .path' | fzf --prompt="Gogh Sync > " --height=15 --layout=reverse --header="[ Ctrl-c to Cancel ] | [ Enter to Apply ]")
    
    if [ $? -eq 0 ] && [ -n "$theme" ]; then
        echo "Applying color scheme: $(basename $theme .properties)"
        mkdir -p ~/.termux
        # Download using the full path provided by jq (which includes "themes/...")
        if curl -fsSL "https://raw.githubusercontent.com/LbsLightX/1llicit-colors/main/$theme" -o ~/.termux/colors.properties; then
            termux-reload-settings
            if [ $? -ne 0 ]; then
                echo "Failed to apply color scheme."
            fi
        else
            echo "Failed to download color scheme."
        fi
    else
        echo "⚠️ Cancelled."
    fi
else
    echo "Make sure you're connected to the internet and your repo is public!"
    exit 1
fi
