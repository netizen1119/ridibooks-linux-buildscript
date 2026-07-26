#!/bin/bash
# Ridibooks 실행 래퍼 (Fedora fork)
#
# Electron 버전 = build.sh에서 ^24.0.0 고정. 근거(2026-07-26 실측):
#   - 원본 앱은 Electron 12.2.3로 빌드됐으나, 12는 현대 Mesa/커널에서
#     chrome-sandbox 헬퍼 오류로 창이 안 뜨고 2차 창 합성이 실패한다.
#   - 28 이상은 리디 서버가 요청을 거부한다(user-devices 403 +
#     로그인 응답이 JSON 아닌 HTML). 기기 등록 여부와 무관. 상한 = 24.
#   - 24에서는 무력화 플래그가 불필요하다 — 앱이 요구하는 sandbox:true가
#     커널 네임스페이스 샌드박스 폴백으로 실제 적용됨(Seccomp:2 실측).
#
# mullvad-exclude: 리디는 한국 서비스 — Mullvad 연결 중이면 터널 밖으로
#                  내보낸다(헌법 §3.11 한국 IP 계층).
APP="__APP_DIR__/Ridibooks"
LOG="${XDG_CACHE_HOME:-$HOME/.cache}/ridibooks.log"
mkdir -p "$(dirname "$LOG")"

if command -v mullvad-exclude >/dev/null 2>&1 && mullvad status 2>/dev/null | grep -qi connected; then
    exec mullvad-exclude "$APP" >> "$LOG" 2>&1
fi
exec "$APP" >> "$LOG" 2>&1
