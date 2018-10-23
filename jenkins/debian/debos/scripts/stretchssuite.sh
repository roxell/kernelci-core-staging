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

# Build and install ssuite
########################################################################

TESTDIR=ssuite
mkdir -p /tmp/tests/${TESTDIR} && cd /tmp/tests/${TESTDIR}

TEST_REPO=git://github.com/Algodev-github/S.git

git clone --depth=1 ${TEST_REPO} .

echo '    {"name": "${TESTDIR}", "git_url": "${TEST_REPO}", "git_commit": ' \"`git rev-parse HEAD`\" '}' >> $BUILDFILE


# Copy files in the image
mkdir /opt/ssuite
cp -Rd --preserve=mode,timestamps /tmp/tests/${TESTDIR}/* /opt/ssuite

echo '  ]' >> $BUILDFILE

########################################################################
# Cleanup: remove files and packages we don't want in the images       #
########################################################################
cd /tmp
rm -rf /tmp/tests

apt-get remove --purge -y ${BUILD_DEPS}
apt-get autoremove --purge -y
apt-get clean

# re-add some stuff that is removed by accident
apt-get install -y initramfs-tools

