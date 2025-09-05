# kmkh — *khaane me kya hain?*

Tiny terminal CLI to fetch today's FC2 menu and show the past/current/next meals

Credits: [Aadit Agarwal](https://github.com/aaditagrawal/fc-menu), the author of the OG Menu website!

## Requirements
- `curl`  
- `jq` (for JSON parsing)

Install `jq`:
```bash
# Debian / Ubuntu
sudo apt install jq

# macOS (Homebrew)
brew install jq
```

## Install / Setup

1. Save the script to `khaana.sh` (or clone the repo and use the provided file)

2. Make it executable:
```bash
chmod +x khaana.sh
```

3. Make it convenient to run 

**Option A - add to path:**
```
mkdir -p ~/bin
mv khaana.sh ~/bin/kmkh
# Ensure ~/bin is in PATH, add to ~/.bashrc or ~/.zshrc:
# export PATH="$HOME/bin:$PATH"
```

**Option B — alias (quick and dirty):**
```bash
# Add to ~/.bashrc or ~/.zshrc:
alias kmkh='/full/path/to/khaana.sh'
# then: source ~/.bashrc
```

After one of the above, you can run `kmkh` anywhere.

## Usage

```bash
# Default: show current meal (if within a meal window), otherwise the next meal
kmkh

# Show the next upcoming meal explicitly
kmkh --next

# Show a specific meal for today (ignores other meals)
kmkh --breakfast
kmkh --lunch
kmkh --snacks
kmkh --dinner

# Help
kmkh -h
```
