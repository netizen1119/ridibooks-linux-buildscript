#!/bin/bash
# Ridibooks 실행 래퍼 (Fedora fork)
#   --no-sandbox   : 유저 로컬 설치라 chrome-sandbox 헬퍼가 setuid root가 아님.
#                    없으면 Chromium이 치명적 오류로 종료하고 창이 안 뜬다.
#   --disable-gpu  : Electron 12(Chromium 89)의 GPU 합성이 현대 Mesa와 불일치.
#                    없으면 2차인증 창(새 WebContents)만 렌더에 실패한다.
#   mullvad-exclude: 리디는 한국 서비스 — Mullvad 연결 중이면 터널 밖으로 보낸다.
#                    (Chromium 한국 IP 계층과 동일 취급)
APP="__APP_DIR__/Ridibooks"
FLAGS=(--no-sandbox --disable-gpu)
LOG="${XDG_CACHE_HOME:-$HOME/.cache}/ridibooks.log"
mkdir -p "$(dirname "$LOG")"

if command -v mullvad-exclude >/dev/null 2>&1 && mullvad status 2>/dev/null | grep -qi connected; then
    exec mullvad-exclude "$APP" "${FLAGS[@]}" >> "$LOG" 2>&1
fi
exec "$APP" "${FLAGS[@]}" >> "$LOG" 2>&1
