#!/bin/bash

# Configuration
API_KEY="McUIwQBBMosmiBcDP672F7n7hJJiRUOGU_XjADah"
KUTT_HOST="https://t.sasanka.cloud"
API_ENDPOINT="$KUTT_HOST/api/v2/links"

# Function to shorten URL
shorten_url() {
    local LONG_URL="$1"
    local NOTIFY="$2" # Whether to notify on error/skip

    # Basic validation: Check if empty
    if [[ -z "$LONG_URL" ]]; then
        return 1
    fi

    # Basic validation: Check if it looks like a URL
    if [[ ! "$LONG_URL" =~ ^http ]]; then
        return 1
    fi

    # Check if already shortened (contains the Kutt host)
    if [[ "$LONG_URL" == *"t.sasanka.cloud"* ]]; then
        if [[ "$NOTIFY" == "true" ]]; then
            echo "URL is already shortened."
        fi
        return 0
    fi

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
        if [[ "$NOTIFY" == "true" ]]; then
            osascript -e 'display notification "Connection failed" with title "Kutt Shortener"'
        fi
        return 1
    fi

    # Parse response
    SHORT_URL=$(echo "$RESPONSE" | jq -r '.link')
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error // empty')

    if [[ "$SHORT_URL" != "null" && -n "$SHORT_URL" ]]; then
        # Success
        echo -n "$SHORT_URL" | pbcopy
        echo "Shortened URL copied to clipboard: $SHORT_URL"
        osascript -e "display notification \"$SHORT_URL copied to clipboard\" with title \"Kutt Shortener\""
        return 0
    else
        # API Error
        echo "Error: API returned an error: $RESPONSE"
        if [[ -n "$ERROR_MSG" ]]; then
             if [[ "$NOTIFY" == "true" ]]; then
                osascript -e "display notification \"Error: $ERROR_MSG\" with title \"Kutt Shortener\""
             fi
        fi
        return 1
    fi
}

# Main logic
if [[ "$1" == "--once" ]]; then
    # One-off run
    LONG_URL=$(pbpaste)
    shorten_url "$LONG_URL" "true"
else
    echo "Watching clipboard for new URLs..."
    echo "Press Ctrl+C to stop."
    
    LAST_CLIP=$(pbpaste)
    
    while true; do
        sleep 1
        CURRENT_CLIP=$(pbpaste)
        
        # Check if clipboard content has changed
        if [[ "$CURRENT_CLIP" != "$LAST_CLIP" ]]; then
            
            # Try to shorten
            shorten_url "$CURRENT_CLIP" "false"
            
            # Update LAST_CLIP to reflect current clipboard state
            # We must re-read pbpaste because shorten_url might have updated it
            LAST_CLIP=$(pbpaste)
        fi
    done
fi
