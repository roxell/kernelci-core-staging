#!/bin/bash

# Important: This script is run under QEMU

set -e

# Build-depends needed to build the test suites, they'll be removed later
BUILD_DEPS="
            git \
"

apt-get install --no-install-recommends -y  ${BUILD_DEPS}

BUILDFILE=/build_info.txt
echo '  "tests_suites": [' >> $BUILDFILE

# Build and install IO performance suites
########################################################################
TMP_TEST_DIR="/tmp/tests"
mkdir -p ${TMP_TEST_DIR} && cd ${TMP_TEST_DIR}

TESTDIR=ssuite
TEST_REPO=git://github.com/Algodev-github/S.git

git clone --depth=1 ${TEST_REPO} ${TESTDIR}

echo '    {"name": "${TESTDIR}", "git_url": "${TEST_REPO}", "git_commit": ' \"`git rev-parse HEAD`\" '}' >> $BUILDFILE

# Copy files in the image
cp -Rd --preserve=mode,timestamps ${TMP_TEST_DIR}/${TESTDIR} /opt

# Nothing that we run right now.
# Removing due since the WALL-E trailer are big.
rm -rf /opt/ssuite/video_playing_vs_commands

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

