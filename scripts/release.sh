VERSION=$1
if [ -z "$VERSION" ]
then
  echo $0 version
  exit
fi
NAME=`json -f package.json productName`
NAME_ESCAPED=`echo $NAME | sed 's/\ /\\ /'`
VERSION_ESCAPED=`echo $VERSION | sed 's/\ /\\ /'`
DIR=$NAME_ESCAPED-$VERSION_ESCAPED
ARCH=x64
PLATFORM=darwin

json -I -f package.json -e "this.version='${VERSION}'"
./scripts/build.sh
rm -rf "release-builds/${DIR}/"
mkdir -p "release-builds/${DIR}/${DIR}"

cp -R "release-builds/${NAME_ESCAPED}-${PLATFORM}-${ARCH}/${NAME_ESCAPED}.app" \
  "release-builds/${DIR}/${DIR}/${NAME_ESCAPED}.app"

echo "Drag ${NAME}.app to Applications folder to install" > "release-builds/${DIR}/${DIR}/Notes.txt"
echo "@codeblaan at github" >> "release-builds/${DIR}/${DIR}/Notes.txt"

ln -s /Applications "release-builds/${DIR}/${DIR}/Applications"

hdiutil create \
  -fs HFS+ \
  -srcfolder "release-builds/${DIR}/${DIR}/" \
  "release-builds/${DIR}/${DIR}.dmg"

zip -r "release-builds/${DIR}/${DIR}.dmg.zip" "release-builds/${DIR}/${DIR}.dmg"

cd "release-builds/${DIR}/"
shasum -a 256 "${DIR}.dmg.zip" > "${DIR}.dmg.zip.sha256"
shasum -c "${DIR}.dmg.zip.sha256"

open .
