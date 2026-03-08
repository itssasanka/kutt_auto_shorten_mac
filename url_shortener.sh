#!/bin/bash

# Configuration
CONFIG_DIR="$HOME/.config/kutt_auto_shorten_mac"
CONFIG_FILE="$CONFIG_DIR/config.json"
EXAMPLE_CONFIG="$(dirname "$0")/config.example.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Creating default configuration at $CONFIG_FILE..."
    mkdir -p "$CONFIG_DIR"
    cp "$EXAMPLE_CONFIG" "$CONFIG_FILE"
    echo "Please update $CONFIG_FILE with your Kutt API details and restart."
    osascript -e "display notification \"Please update $CONFIG_FILE\" with title \"Kutt Shortener Setup\""
    exit 1
fi

# Parse configuration using jq
API_KEY=$(jq -r '.api_key // empty' "$CONFIG_FILE")
KUTT_HOST=$(jq -r '.kutt_host // empty' "$CONFIG_FILE")

# Read ignore list into an array using jq (Bash 3.2 compatible for macOS)
IGNORE_LIST=()
while IFS= read -r line; do
    [[ -n "$line" ]] && IGNORE_LIST+=("$line")
done < <(jq -r '.ignore_list[]? // empty' "$CONFIG_FILE")

if [[ -z "$API_KEY" || "$API_KEY" == "your_kutt_api_key_here" ]]; then
    echo "Error: Please set a valid api_key in config.json"
    exit 1
fi

if [[ -z "$KUTT_HOST" || "$KUTT_HOST" == "https://your-kutt-instance.com" ]]; then
    echo "Error: Please set a valid kutt_host in config.json"
    exit 1
fi

# Extract domain for duplicate checking
KUTT_DOMAIN=$(echo "$KUTT_HOST" | awk -F/ '{print $3}')
API_ENDPOINT="$KUTT_HOST/api/v2/links"

# Function to shorten URL
shorten_url() {
    local LONG_URL="$1"

    # Basic validation: Check if empty
    if [[ -z "$LONG_URL" ]]; then
        return 1
    fi

    # Basic validation: Check if it looks like a URL
    if [[ ! "$LONG_URL" =~ ^http ]]; then
        return 1
    fi

    # Check if already shortened (contains the Kutt host)
    if [[ "$LONG_URL" == *"$KUTT_DOMAIN"* ]]; then
        return 0
    fi

    # Check against ignore list
    for ignore_pattern in "${IGNORE_LIST[@]}"; do
        # Skip empty patterns
        if [[ -z "$ignore_pattern" ]]; then
            continue
        fi
        
        if [[ "$LONG_URL" == *"$ignore_pattern"* ]]; then
            echo "Skipping ignored URL: $LONG_URL"
            return 0
        fi
    done

    echo "Shortening: $LONG_URL"

    # Send request to Kutt API
    RESPONSE=$(curl -s -X POST \
      -H "X-API-KEY: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"target\": \"$LONG_URL\"}" \
      "$API_ENDPOINT")

    # Check for curl errors
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to connect to Kutt API."
        return 1
    fi

    # Parse response
    SHORT_URL=$(echo "$RESPONSE" | jq -r '.link')

    if [[ "$SHORT_URL" != "null" && -n "$SHORT_URL" ]]; then
        # Success
        echo -n "$SHORT_URL" | pbcopy
        echo "Shortened URL copied to clipboard: $SHORT_URL"
        osascript -e "display notification \"$SHORT_URL copied to clipboard\" with title \"Kutt Shortener\""
        return 0
    else
        # API Error
        echo "Error: API returned an error: $RESPONSE"
        return 1
    fi
}

# Main logic
echo "Watching clipboard for new URLs..."
echo "Press Ctrl+C to stop."

LAST_CLIP=$(pbpaste)

while true; do
    sleep 1
    CURRENT_CLIP=$(pbpaste)
    
    # Check if clipboard content has changed
    if [[ "$CURRENT_CLIP" != "$LAST_CLIP" ]]; then
        
        # Try to shorten
        shorten_url "$CURRENT_CLIP"
        
        # Update LAST_CLIP to reflect current clipboard state
        # We must re-read pbpaste because shorten_url might have updated it
        LAST_CLIP=$(pbpaste)
    fi
done
