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


## Privacy
- The logs are all local, they never leave your device.
- Your clipboard/URLs are never sent to any external service.
  - You are free to check the code and verify it yourself.
- The Kutt instance you point it to is the only one that sees your URLs.

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
The `ignore_list` allows you to specify keywords or exact URLs that should NOT be shortened. If any copied URL contains a string from this list (or matches exactly for full URLs), it will be skipped automatically.

- If the pattern is just a word or domain (e.g., `"example"`, `"mydomain.com"`), any URL containing that substring will be ignored.
- If the pattern starts with `http://` or `https://`, it requires an **exact match** to be ignored.

```json
  "ignore_list": [
    "example",                             // Substring: https://site.com/example will be ignored
    "mydomain.com",                        // Substring: https://mydomain.com/path will be ignored
    "https://exact-url.com/exact/path"     // Exact Match: Only this exact URL will be ignored
  ]
```

## Usage
```bash
git clone https://github.com/itssasanka/kutt_auto_shorten_mac
```

To start monitoring your clipboard for URLs to shorten:

```bash
cd kutt_auto_shorten_mac
chmod +x url_shortener.sh
./url_shortener.sh
```
Leave this running in a terminal window. Whenever you copy a valid URL (starting with `http` or `https`), it will automatically shorten it and place the short URL back in your clipboard.

## Run on Startup
1. On Mac, go to Login Items and Extensions in Settings > General.
2. Then, click the "+" button and add the `url_shortener.sh` script.


## License

MIT
