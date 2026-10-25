#!/bin/bash

# Hyprland exports LIBVA_DRIVER_NAME=nvidia session-wide for Firefox/NVDEC.
# libva-nvidia-driver is Firefox-only: it exports each YUV plane as a separate
# dmabuf, which Chromium cannot import into a single texture. Brave then spams
# eglCreateImage EGL_BAD_MATCH (0x3009) and the tab dies. Keep VA-API off here.
unset LIBVA_DRIVER_NAME NVD_BACKEND

exec /usr/bin/brave-browser-stable \
  --ozone-platform=wayland \
  --disable-accelerated-video-decode \
  --enable-features=WebRTCPipeWireCapturer \
  --disable-features=WaylandWpColorManagerV1 \
  "$@"
