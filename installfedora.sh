#!/bin/bash
# ./build.sh 성공 후 실행. PKGBUILD의 package() 단계를
# Arch 패키지 없이 재현 — 기본은 유저 로컬 설치(root 불필요).
# 시스템 전역(/opt) 설치가 필요하면 --system 옵션.
set -e

pkgname="${pkgname:-ridibooks}"

if [ "$1" = "--system" ]; then
    APP_DIR="/opt/${pkgname}"
    DESKTOP_DIR="/usr/share/applications"
    ICON_BASE="/usr/share/icons/hicolor"
    SUDO="sudo"
else
    APP_DIR="${HOME}/.local/opt/${pkgname}"
    DESKTOP_DIR="${HOME}/.local/share/applications"
    ICON_BASE="${HOME}/.local/share/icons/hicolor"
    SUDO=""
fi

RELEASE_DIR="$(echo release/Ridibooks-*)"
if [ ! -d "$RELEASE_DIR" ]; then
    echo "release/Ridibooks-* 없음 — ./build.sh 먼저 실행하세요"
    exit 1
fi

echo "설치 대상: $APP_DIR"
echo "데스크톱 항목: $DESKTOP_DIR/${pkgname}.desktop"
read -rp "진행할까요? [y/N] " ok
[ "$ok" = "y" ] || [ "$ok" = "Y" ] || exit 1

$SUDO mkdir -p "$APP_DIR"
$SUDO cp -r "$RELEASE_DIR"/* "$APP_DIR"/
$SUDO mkdir -p "$DESKTOP_DIR"

for size in 16x16 32x32 48x48 64x64 128x128; do
    $SUDO mkdir -p "${ICON_BASE}/${size}/apps"
    $SUDO cp "icons/hicolor/${size}/apps/${pkgname}.png" "${ICON_BASE}/${size}/apps/"
done

sed "s#Exec=/opt/ridibooks/Ridibooks#Exec=${APP_DIR}/Ridibooks --no-sandbox --disable-gpu#" ridibooks.desktop \
    | $SUDO tee "${DESKTOP_DIR}/${pkgname}.desktop" >/dev/null

echo "설치 완료. 메뉴에 안 뜨면: update-desktop-database ${DESKTOP_DIR} (시스템 설치 시에만 보통 필요)"
