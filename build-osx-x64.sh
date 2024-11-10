#!/bin/bash

set -e

APPBASE="build/macos-x64/Stratix.app"

build() {
    pushd native
    cmake -DCMAKE_OSX_ARCHITECTURES=x86_64 -B build-x64 .
    cmake --build build-x64 --config Release
    popd

    source .jdk-versions.sh

    rm -rf build/macos-x64
    mkdir -p build/macos-x64

    if ! [ -f mac64_jre.tar.gz ] ; then
        curl -Lo mac64_jre.tar.gz $MAC_AMD64_LINK
    fi

    echo "$MAC_AMD64_CHKSUM  mac64_jre.tar.gz" | shasum -c

    mkdir -p $APPBASE/Contents/{MacOS,Resources}

    cp native/build-x64/src/Stratix $APPBASE/Contents/MacOS/
    cp target/Stratix.jar $APPBASE/Contents/Resources/
    cp packr/macos-x64-config.json $APPBASE/Contents/Resources/config.json
    cp target/filtered-resources/Info.plist $APPBASE/Contents/
    cp osx/app.icns $APPBASE/Contents/Resources/icons.icns

    tar zxf mac64_jre.tar.gz
    mkdir $APPBASE/Contents/Resources/jre
    mv jdk-$MAC_AMD64_VERSION-jre/Contents/Home/* $APPBASE/Contents/Resources/jre

    echo Setting world execute permissions on Stratix
    pushd $APPBASE
    chmod g+x,o+x Contents/MacOS/Stratix
    popd

    otool -l $APPBASE/Contents/MacOS/Stratix
}

dmg() {
    SIGNING_IDENTITY="Developer ID Application"
    codesign -f -s "${SIGNING_IDENTITY}" --entitlements osx/signing.entitlements --options runtime $APPBASE || true

    # create-dmg exits with an error code due to no code signing, but is still okay
    # note we use Adam-/create-dmg as upstream does not support UDBZ
    create-dmg --format UDBZ $APPBASE . || true
    mv Stratix\ *.dmg Stratix-x64.dmg

    # dump for CI
    hdiutil imageinfo Stratix-x64.dmg

    if ! hdiutil imageinfo Stratix-x64.dmg | grep -q "Format: UDBZ" ; then
        echo "Format of resulting dmg was not UDBZ, make sure your create-dmg has support for --format"
        exit 1
    fi

    if ! hdiutil imageinfo Stratix-x64.dmg | grep -q "Apple_HFS" ; then
        echo Filesystem of dmg is not Apple_HFS
        exit 1
    fi

    # Notarize app
    if xcrun notarytool submit Stratix-x64.dmg --wait --keychain-profile "AC_PASSWORD" ; then
        xcrun stapler staple Stratix-x64.dmg
    fi
}

while test $# -gt 0; do
  case "$1" in
    --build)
      build
      shift
      ;;
    --dmg)
      dmg
      shift
      ;;
    *)
      break
      ;;
  esac
done