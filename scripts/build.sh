ARCH=x64
PLATFORM=darwin
OUT=release-builds
ICON=assets/icon.icns

electron-packager . \
  --overwrite \
  --platform=$PLATFORM \
  --icon=$ICON \
  --arch=$ARCH \
  --prune=true \
  --out=$OUT
