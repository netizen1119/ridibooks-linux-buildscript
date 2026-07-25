#!/bin/bash

if [ -z "$pkgname" ]; then
	pkgname="ridibooks"
fi

# init builder
mkdir -p builder
(cat << EOF
{
  "name": "ridibooks-desktop-packager",
  "version": "1",
  "private": true,
  "scripts": {
    "package": "electron-packager ../asar-unpack --electron-version=\$ELECTRON_VERSION --platform=linux --arch=x64 --asar --out=../release --overwrite",
    "unpack": "asar extract ../app-unpack/resources/app.asar ../asar-unpack"
  },
  "devDependencies": {
    "electron": "^28.0.0",
    "@electron/packager": "^19.0.1",
    "@electron/asar": "^4.0.1"
  }
}
EOF
)> builder/package.json
npm i --prefix builder
ELECTRON_VERSION="$(cat builder/node_modules/electron/package.json | grep "\"version\": " | sed 's/ *"version": "//g' | sed 's/"//g')"

# unpack setup.exe
[ -e setup-unpack ] && rm -r setup-unpack
[ -e app-unpack ] && rm -r app-unpack
[ -e asar-unpack ] && rm -r asar-unpack
7z x setup.exe -osetup-unpack -bb0
7z x setup-unpack/\$PLUGINSDIR/app-64.7z -oapp-unpack -bb0
npm run unpack --prefix builder

# backup private file
[ -e package-backup ] && rm -r package-backup
mkdir -p package-backup
cp -r asar-unpack/node_modules/@ridi asar-unpack/node_modules/@ridi-app package-backup

# install deps
rm -r asar-unpack/node_modules
cp -r package-backup asar-unpack/node_modules
npm i --prefix asar-unpack

# create icons
sizes=("16x16" "32x32" "48x48" "64x64" "128x128")
mkdir -p icons/hicolor/$size/apps
for size in "${sizes[@]}"; do
	mkdir -p -p icons/hicolor/$size/apps/
	chmod o+xr,g+xr icons icons/hicolor icons/hicolor/$size icons/hicolor/$size/apps/
	gm convert icon.png -resize "$size" "icons/hicolor/$size/apps/${pkgname}.png"
done

# build
ELECTRON_VERSION=$ELECTRON_VERSION npm run package --prefix builder
cp -r app-unpack/resources/assets app-unpack/resources/dist release/Ridibooks-*/resources

