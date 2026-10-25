#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# for rainbow borders animation

set -euo pipefail

colors=()
for _ in {1..10}; do
  colors+=("\"rgba($(openssl rand -hex 3)ff)\"")
done

color_list=$(IFS=,; printf '%s' "${colors[*]}")
hyprctl eval "hl.config({
  general = {
    col = {
      active_border = {
        colors = { $color_list },
        angle = 270
      }
    }
  }
})"
