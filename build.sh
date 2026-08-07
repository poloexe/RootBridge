#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(dirname -- "$0")
cd "$SCRIPT_DIR"

PKG=$(sed -n 's/^Package: //p' control)
VER=$(sed -n 's/^Version: //p' control)

# create fresh build directory
rm -rf "$SCRIPT_DIR/build"
mkdir -p "$SCRIPT_DIR/build"

# build main project (rootless ver., iOS 14+)
build_rootless() {
    rm -rf "$THEOS/lib/RootBridge.framework"
    cp control /tmp/rootbridge-control.bak
    sed 's/firmware (>= 8.0)/firmware (>= 14.0)/' control > control.tmp && mv control.tmp control

    make clean &&
    THEOS_PACKAGE_SCHEME=rootless ARCHS="arm64 arm64e" TARGET=iphone:clang:latest:14.0 make package FINALPACKAGE=1 &&
    cp -p "`ls -dtr1 packages/* | tail -1`" "$SCRIPT_DIR/build/${PKG}_${VER}_iphoneos-arm-rootless.deb"

    mv /tmp/rootbridge-control.bak control
}

# build main project (rooted ver., iOS 8+)
build_rooted() {
    rm -rf "$THEOS/lib/RootBridge.framework"
    make clean &&
    make package FINALPACKAGE=1 &&
    cp -p "`ls -dtr1 packages/* | tail -1`" "$SCRIPT_DIR/build/${PKG}_${VER}_iphoneos-arm.deb"
}

case ${1:-all} in
    rootless) build_rootless ;;
    rooted) build_rooted ;;
    all) build_rootless; build_rooted ;;
    *) echo "usage: $0 [all|rootless|rooted]" >&2; exit 1 ;;
esac
