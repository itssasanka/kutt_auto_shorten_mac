# Kutt Auto Shortener

A lightweight bash script that monitors your macOS clipboard and automatically shortens any copied URLs. Works with a self-hosted Kutt instance.

## Features

- **Automatic Clipboard Monitoring**: Continuously watches your clipboard and automatically shortens any URLs in the background.
- **macOS Native Notifications**: Get instant native notifications when a URL is successfully shortened or if an error occurs.
- **Smart Detection**: Automatically skips URLs that are already shortened to prevent looping.
- **Clipboard Integration**: Automatically replaces the long URL in your clipboard with the newly shortened URL.

## Prerequisites

This script is designed specifically for macOS as it relies on native clipboard and notification utilities.

You will need the following installed on your Mac:
- `curl` (usually pre-installed on macOS)
- `jq` (command-line JSON processor)

You can install `jq` via Homebrew:
```bash
brew install jq
```

## Configuration

Before using the script, you need to configure it with your Kutt API details. 

The configuration file is expected to be at `~/.config/kutt_auto_shorten_mac/config.json`.

When you run the script for the first time, it will automatically create this directory and copy the `config.example.json` file to that location if it doesn't exist.

Open `~/.config/kutt_auto_shorten_mac/config.json` and update it with your actual details:
```json
{
  "api_key": "your_kutt_api_key_here",
  "kutt_host": "https://your-kutt-instance.com",
  "ignore_list": [
    "example",
    "mydomain.com",
    "https://exact-url.com/exact/path"
  ]
}
```

### Ignore List
The `ignore_list` allows you to specify keywords for URLs that should NOT be shortened. If any copied URL contains a string from this list, it will be skipped automatically.

```
"ignore_list": [
    "example",  <-- https://example.com will be ignored
    "mydomain.com",  <-- https://mydomain.com will be ignored
    "https://exact-url.com/exact/path"  <-- Only https://exact-url.com/exact/path will be ignored
  ]
```

## Usage

To start monitoring your clipboard for URLs to shorten:

```bash
./url_shortener.sh
```
Leave this running in a terminal window. Whenever you copy a valid URL (starting with `http` or `https`), it will automatically shorten it and place the short URL back in your clipboard.

## How it works

1. The script uses `pbpaste` to read the clipboard contents.
2. It validates if the content is a URL and checks if it's already a shortened URL.
3. It sends a request to your Kutt API using `curl`.
4. It parses the response using `jq`.
5. Upon success, it uses `pbcopy` to place the shortened URL into your clipboard and `osascript` to trigger a macOS notification.

## License

MIT
