#!/usr/bin/env bash
set -e

cd "$(dirname -- "$0")"

# unset THEOS would make the rm -rf below target /lib/RootBridge.framework
: "${THEOS:?THEOS is not set}"

PKG=$(sed -n 's/^Package: //p' control)
VER=$(sed -n 's/^Version: //p' control)

# control is rewritten during the rootless build; always put it back, even on
# a failed build or a Ctrl-C, so it never gets committed modified
CONTROL_BAK=$(mktemp)
cp control "$CONTROL_BAK"
trap 'cp -f "$CONTROL_BAK" control; rm -f "$CONTROL_BAK"' EXIT INT TERM

# create fresh build directory
rm -rf build
mkdir -p build

# $1 = deb suffix, remaining args = env overrides for make
build() {
    local suffix=$1; shift
    rm -rf "$THEOS/lib/RootBridge.framework"
    make clean
    env "$@" make package FINALPACKAGE=1
    cp -p "$(ls -dtr1 packages/* | tail -1)" "build/${PKG}_${VER}_${suffix}.deb"
}

# build main project (rootless ver., iOS 14+)
build_rootless() {
    # redirect truncates control in place, keeping its mode
    sed 's/firmware (>= 8.0)/firmware (>= 14.0)/' "$CONTROL_BAK" > control

    build iphoneos-arm64-rootless \
        THEOS_PACKAGE_SCHEME=rootless \
        ARCHS="arm64 arm64e" \
        TARGET=iphone:clang:latest:14.0

    cp -f "$CONTROL_BAK" control
}

# build main project (rooted ver., iOS 8+)
build_rooted() {
    build iphoneos-arm
}

case ${1:-all} in
    rootless) build_rootless ;;
    rooted) build_rooted ;;
    all) build_rootless; build_rooted ;;
    *) echo "usage: $0 [all|rootless|rooted]" >&2; exit 1 ;;
esac
