#!/usr/bin/bash
# rofi-dunst-history.sh
# Показывает историю уведомлений dunst в rofi.
#
# Использование:
#   ./rofi-dunst-history.sh                 # читает из dunstctl history
#   ./rofi-dunst-history.sh history.json    # читает из файла
#
# В stdout выбранное уведомление в виде TSV:
#   id<TAB>summary<TAB>body<TAB>appname

set -euo pipefail

# ---------- 1. Получаем JSON ----------
if [[ $# -gt 0 && -f "$1" ]]; then
    json="$(cat "$1")"
else
    command -v dunstctl >/dev/null || { echo "dunstctl не найден" >&2; exit 1; }
    json="$(dunstctl history)"
fi

# Убираем возможный заголовок "dunstctl history"
json="$(printf '%s' "$json" | sed '1{/^[[:space:]]*dunstctl history[[:space:]]*$/d;}')"

command -v jq >/dev/null || { echo "jq не найден" >&2; exit 1; }

# ---------- 2. Парсим в TSV ----------
lines="$(
    printf '%s' "$json" | jq -r '
      def clean:
        tostring
        | gsub("<[^>]*>"; "")
        | gsub("\r"; " ")
        | gsub("\n"; " ")
        | gsub("\t"; " ")
        | gsub("  +"; " ")
        | sub("^ +"; "")
        | sub(" +$"; "");

      .data[0][]
      | [
          (.id.data // "" | tostring),
          ((.summary.data // "") | clean),
          ((.body.data // "")  | clean),
          ((.appname.data // "") | clean)
        ]
      | @tsv
    '
)"

if [[ -z "$lines" ]]; then
    echo "История пуста" >&2
    exit 0
fi

# ---------- 3. Показываем в rofi ----------
display="$(
    printf '%s\n' "$lines" | awk -F'\t' '{ printf "%s  %s — %s\n", $1, $2, $3 }'
)"

chosen="$(
    printf '%s\n' "$display" | rofi -dmenu -i -p "Уведомления" -format i || true
)"

[[ -z "${chosen:-}" ]] && exit 0

# ---------- 4. Печатаем выбранное ----------
printf '%s\n' "$lines" | sed -n "$((chosen + 1))p"
