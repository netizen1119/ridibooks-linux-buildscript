#!/bin/bash
if [ -z "$pkgver" ]; then pkgver="none"; fi

function getOption() {
	grep "[ -]*$1 *: *" latest.yml | sed "s/[ \\-]*$1 *: *//g"
}
if [ -e latest.yml ]; then
	VERSION_CURR="$(getOption version)"
fi
if [ "$pkgver" != "$VERSION_CURR" ]; then
	curl https://viewer-ota.ridicdn.net/pc_electron/latest.yml -o latest.yml
fi

# download icon
[ ! -e icon.png ] && curl "https://static.ridicdn.net/books-backend/p/39a20f/books/dist/favicon/apple-touch-icon-180x180.png?20220405" -o icon.png

# download latest installer
VERSION_SERVER="$(getOption version)"
FILE="$(getOption url | sed "s/ /%20/g")"
URL="https://viewer-ota.ridicdn.net/pc_electron/${FILE}"
SHA512="$(getOption sha512)"
if [ "$VERSION_CURR" = "$VERSION_SERVER" ] && [ -e setup.exe ]; then
	echo "latest setup.exe downloaded already"
	SKIP=1
fi
[ -n "$SKIP" ] || curl -fL "$URL" -o setup.exe


# --- fork patch: verify installer against latest.yml sha512 (base64) ---
EXPECTED_SHA="$(grep -m1 -oP 'sha512:\s*\K\S+' latest.yml | tr -d '\r')"
ACTUAL_SHA="$(openssl dgst -sha512 -binary setup.exe | base64 -w0)"
if [ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]; then
	echo "ERROR: setup.exe sha512 mismatch - aborting" >&2
	echo "  expected: $EXPECTED_SHA" >&2
	echo "  actual:   $ACTUAL_SHA" >&2
	mv setup.exe setup.exe.badhash
	exit 1
fi
echo "OK: setup.exe sha512 verified"
