#!/bin/bash

# Abort if error.
trap "exit 1" ERR

#======================================
# Build a Vim's RPM file (GUI enabled)
#======================================

# Environments
export SCRIPT_DIR=$VOLUME_SHARE_CONTAINER/scripts
export OUT_DIR=$VOLUME_SHARE_CONTAINER

# Update yum packages
yum -y update

# Install the checkinstall
yum -y install  $(ls $SCRIPT_DIR/checkinstall*.rpm | tail -1)
# Prepare environment to run the rpm-build.
export HOME=/root
mkdir -p $HOME/rpmbuild/SOURCES

# Download the original version
yum -y install git
git clone https://github.com/vim/vim.git
cd $BUILD_TMP/vim

# Build
## Configure
./configure \
  --prefix=/usr/local \
  --with-features=huge \
  --enable-multibyte \
  --enable-xim \
  --enable-fontset \
  --enable-fail-if-missing \
  --disable-darwin \
  --disable-selinux \
  --with-x \
  --enable-gui=gnome2 \
  --enable-luainterp \
  --enable-perlinterp \
  --enable-pythoninterp \
  --enable-rubyinterp \
  --enable-cscope
## Make
make
## Identify the version string. ("x.y.z")
export VERSION=""$(LANG=C ./src/vim --version | grep "^VIM" | sed "s/VIM - Vi IMproved \([0-9]*\.[0-9]*\).*/\1/").$(LANG=C ./src/vim --version | grep "^Included patches:" | sed "s/Included patches:.*-\([0-9]*\)/\1/")""
## Build a rpm.
export REQUIRES=gtk2,libSM,libXt,lua,perl-libs,python-libs,ruby-libs
echo "Vim $VERSION" > description-pak
checkinstall --type=rpm --pkgname=vim --pkgversion=$VERSION --default --requires=$REQUIRES --autoreqprov=no
## Save the full path of the rpm file into a file
export RPM_PATH="$HOME/rpmbuild/RPMS/$(arch)/vim-$VERSION-1.$(arch).rpm"
## Install the generated rpm file to test it
yum -y localinstall $RPM_PATH
cd $BUILD_TMP

# Export
# (Environment "VOLUME_SHARE_CONTAINER" must be specified when 'docker run'.)
cp -p $RPM_PATH $OUT_DIR
rm -f $RPM_PATH

echo "========================="
echo "Created: $(basename $RPM_PATH)"
echo "========================="

# Clean up
cd /
yum clean all
rm -rf $BUILD_TMP
