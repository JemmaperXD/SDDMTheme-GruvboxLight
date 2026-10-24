#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
theme="gruvbox-ink"
target="/usr/share/sddm/themes"

if [[ ! -f "$here/$theme/Main.qml" ]]; then
    echo "Не найден каталог темы: $here/$theme" >&2
    exit 1
fi

sudo install -d "$target"
sudo rm -rf "$target/$theme"
sudo cp -a "$here/$theme" "$target/$theme"

sudo install -d /etc/sddm.conf.d
printf '[Theme]\nCurrent=%s\n' "$theme" | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null

echo "Тема установлена: $target/$theme"
echo "Активная тема: $theme (перезагрузись или перезапусти sddm)"
