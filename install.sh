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
    printf "◷ Fetching themes list from 1llicit-colors...\r"
    
    # Updated Logic: Recursive search into 'themes/' folder
    # Added FZF styling to match core.zsh
    theme_data=$(curl -fSsL https://api.github.com/repos/LbsLightX/1llicit-colors/git/trees/main?recursive=1 | jq -r '.tree[] | select(.path | match("^themes/.*\\.properties$")) | (.path | split("/") | last) + " | " + .path')
    
    selection=$(echo "$theme_data" | fzf --prompt="Gogh Sync ▶ " --height=15 --layout=reverse --header="[ Ctrl-c to Cancel ] | [ Enter to Apply ]" --delimiter=" | " --with-nth=1)
    
    if [ $? -eq 0 ] && [ -n "$selection" ]; then
        # Extract the real path (Column 2)
        theme_path=$(echo "$selection" | sed 's/.* | //')
        # Extract the name for display
        theme_name=$(echo "$selection" | sed 's/ | .*//' | sed 's/\.properties//')
        
        printf "✔ Applying color scheme: $theme_name\n"
        mkdir -p ~/.termux
        if curl -fsSL "https://raw.githubusercontent.com/LbsLightX/1llicit-colors/main/$theme_path" -o ~/.termux/colors.properties; then
            termux-reload-settings
            if [ $? -ne 0 ]; then
                echo "✕ Failed to apply color scheme."
            fi
        else
            echo "✕ Failed to download color scheme."
        fi
    else
        echo "⚠ Cancelled."
    fi
else
    echo "Make sure you're connected to the internet and your repo is public!"
    exit 1
fi
