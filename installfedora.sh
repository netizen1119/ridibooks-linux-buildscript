#!/bin/bash
# ./build.sh 성공 후 실행. PKGBUILD의 package() 단계를 Arch 패키지 없이 재현.
# 기본 = 유저 로컬(root 불필요). 시스템 전역(/opt)은 --system.
set -e

pkgname="${pkgname:-ridibooks}"

if [ "$1" = "--system" ]; then
    APP_DIR="/opt/${pkgname}";              BIN_DIR="/usr/local/bin"
    DESKTOP_DIR="/usr/share/applications";  ICON_BASE="/usr/share/icons/hicolor"
    SUDO="sudo"
else
    APP_DIR="${HOME}/.local/opt/${pkgname}";             BIN_DIR="${HOME}/.local/bin"
    DESKTOP_DIR="${HOME}/.local/share/applications";     ICON_BASE="${HOME}/.local/share/icons/hicolor"
    SUDO=""
fi

RELEASE_DIR="$(echo release/Ridibooks-*)"
[ -d "$RELEASE_DIR" ] || { echo "release/Ridibooks-* 없음 — ./build.sh 먼저 실행하세요"; exit 1; }

echo "설치 대상:     $APP_DIR   (기존 내용은 지우고 새로 설치)"
echo "실행 래퍼:     $BIN_DIR/${pkgname}"
echo "데스크톱 항목: $DESKTOP_DIR/${pkgname}.desktop"
read -rp "진행할까요? [y/N] " ok
[ "$ok" = "y" ] || [ "$ok" = "Y" ] || exit 1

$SUDO mkdir -p "$APP_DIR" "$BIN_DIR" "$DESKTOP_DIR"
$SUDO rm -rf "${APP_DIR:?}/"*
$SUDO cp -r "$RELEASE_DIR"/* "$APP_DIR"/

for size in 16x16 32x32 48x48 64x64 128x128; do
    $SUDO mkdir -p "${ICON_BASE}/${size}/apps"
    $SUDO cp "icons/hicolor/${size}/apps/${pkgname}.png" "${ICON_BASE}/${size}/apps/"
done

sed "s#__APP_DIR__#${APP_DIR}#" ridibooks-launch.sh | $SUDO tee "${BIN_DIR}/${pkgname}" >/dev/null
$SUDO chmod +x "${BIN_DIR}/${pkgname}"

sed "s#^Exec=.*#Exec=${BIN_DIR}/${pkgname}#" ridibooks.desktop | $SUDO tee "${DESKTOP_DIR}/${pkgname}.desktop" >/dev/null

echo
echo "설치 완료."
echo "  실행 : ${pkgname}  또는 GNOME 메뉴 아이콘"
echo "  로그 : \${XDG_CACHE_HOME:-\$HOME/.cache}/ridibooks.log"
echo "  종료 : 창 X는 앱이 백그라운드에 남음 — Alt+F4(리디 종료) 사용"
echo "  ※ .desktop 신규·변경 직후 아이콘이 안 뜨면 Wayland라 재로그인 필요"
