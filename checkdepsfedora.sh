#!/bin/bash
# Fedora build-dependency checker for ridibooks-linux-buildscript
# PKGBUILD의 makedepends(sed 7zip curl grep nodejs npm graphicsmagick)를
# dnf 패키지명으로 매핑해서 확인만 함 — 설치는 직접 실행 (sudo 자동 실행 안 함)

need=()
command -v node >/dev/null || need+=(nodejs)
command -v npm  >/dev/null || need+=(npm)
command -v curl >/dev/null || need+=(curl)
command -v sed  >/dev/null || need+=(sed)
command -v grep >/dev/null || need+=(grep)
command -v gm   >/dev/null || need+=(GraphicsMagick)
command -v 7z   >/dev/null || need+=(p7zip p7zip-plugins)

if [ ${#need[@]} -eq 0 ]; then
    echo "빌드 의존성 전부 있음 -> ./prepare.sh 진행 가능"
    exit 0
fi

echo "없는 패키지: ${need[*]}"
echo "설치 명령 (직접 실행하세요):"
echo "  sudo dnf install -y ${need[*]}"
echo
echo "p7zip이 7z 커맨드를 못 잡아주면: sudo dnf search 7z 로 실제 패키지명 확인"
