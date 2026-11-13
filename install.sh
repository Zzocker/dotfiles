#!/usr/bin/env bash
# Symlink every config in this repo into ~/.config (repo layout mirrors ~/.config).
# Existing files are moved to <file>.bak.<timestamp> before linking.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config="${XDG_CONFIG_HOME:-$HOME/.config}"
stamp="$(date +%Y%m%d%H%M%S)"

cd "$repo"
find . -type f -not -path './.git/*' -not -name install.sh -not -name 'README*' -not -name .gitignore -printf '%P\n' |
while read -r rel; do
    src="$repo/$rel"
    dst="$config/$rel"

    if [ "$(readlink -f "$dst" 2>/dev/null)" = "$src" ]; then
        echo "ok      $dst"
        continue
    fi

    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mv "$dst" "$dst.bak.$stamp"
        echo "backup  $dst -> $dst.bak.$stamp"
    fi
    ln -s "$src" "$dst"
    echo "link    $dst -> $src"
done
