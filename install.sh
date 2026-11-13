#!/usr/bin/env bash
# Symlink configs from this repo into place:
#   home/<path>  -> ~/<path>
#   <path>       -> ~/.config/<path>   (everything else)
# Existing files are moved to <file>.bak.<timestamp> before linking.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config="${XDG_CONFIG_HOME:-$HOME/.config}"
stamp="$(date +%Y%m%d%H%M%S)"

link() {
    local src="$1" dst="$2"
    if [ "$(readlink -f "$dst" 2>/dev/null)" = "$src" ]; then
        echo "ok      $dst"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mv "$dst" "$dst.bak.$stamp"
        echo "backup  $dst -> $dst.bak.$stamp"
    fi
    ln -s "$src" "$dst"
    echo "link    $dst -> $src"
}

clone() {
    local url="$1" dst="$2"
    if [ -d "$dst" ]; then
        echo "ok      $dst"
    else
        git clone -q --depth=1 "$url" "$dst"
        echo "clone   $dst"
    fi
}

# oh-my-zsh theme and plugins used by home/.zshrc (oh-my-zsh itself must already be installed)
zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ -d "$HOME/.oh-my-zsh" ]; then
    clone https://github.com/romkatv/powerlevel10k.git          "$zsh_custom/themes/powerlevel10k"
    clone https://github.com/zsh-users/zsh-autosuggestions      "$zsh_custom/plugins/zsh-autosuggestions"
    clone https://github.com/zsh-users/zsh-syntax-highlighting  "$zsh_custom/plugins/zsh-syntax-highlighting"
else
    echo "skip    oh-my-zsh not installed; install it first for the zsh theme/plugins"
fi

cd "$repo"
find . -type f -not -path './.git/*' -not -name install.sh -not -name 'README*' -not -name .gitignore -printf '%P\n' |
while read -r rel; do
    case "$rel" in
        home/*) link "$repo/$rel" "$HOME/${rel#home/}" ;;
        *)      link "$repo/$rel" "$config/$rel" ;;
    esac
done
