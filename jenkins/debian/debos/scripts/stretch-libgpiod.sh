#!/bin/bash

# Important: This script is run under QEMU

set -e

# Build-depends needed to build the test suites, they'll be removed later
BUILD_DEPS="
            autoconf \
            autoconf-archive \
            automake \
            ca-certificates \
            gawk \
            git \
            gcc \
            libtool \
            libc6-dev \
            libkmod-dev \
            libudev-dev \
            make \
            kmod \
            pkg-config \
            python3 \
            udev \
"

apt-get install --no-install-recommends -y  ${BUILD_DEPS}

BUILDFILE=/build_info.txt
echo '  "tests_suites": [' >> $BUILDFILE

# Build and install libgpiod
########################################################################
TMP_TEST_DIR="/tmp/tests/"
mkdir -p ${TMP_TEST_DIR} && cd ${TMP_TEST_DIR}

TESTDIR=libgpiod
#TEST_REPO=https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git
TEST_REPO=https://git.linaro.org/people/anders.roxell/libgpiod.git

#git clone --depth=1 ${TEST_REPO}
git clone ${TEST_REPO}
cd ${TESTDIR}
git checkout testing-v2

echo '    {"name": "${TESTDIR}", "git_url": "${TEST_REPO}", "git_commit": ' \"`git rev-parse HEAD`\" '}' >> $BUILDFILE

pkg-config libkmod
./autogen.sh --enable-install-tests --enable-tests --enable-tools --prefix=/opt/libgpiod
make V=1
make V=1 install-strip

echo '  ]' >> $BUILDFILE

########################################################################
# Cleanup: remove files and packages we don't want in the images       #
########################################################################
rm -rf ${TMP_TEST_DIR}

apt-get remove --purge -y ${BUILD_DEPS}
apt-get autoremove --purge -y
apt-get clean

# re-add some stuff that is removed by accident
apt-get install -y initramfs-tools

