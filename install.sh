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

cd "$repo"
find . -type f -not -path './.git/*' -not -name install.sh -not -name 'README*' -not -name .gitignore -printf '%P\n' |
while read -r rel; do
    case "$rel" in
        home/*) link "$repo/$rel" "$HOME/${rel#home/}" ;;
        *)      link "$repo/$rel" "$config/$rel" ;;
    esac
done
