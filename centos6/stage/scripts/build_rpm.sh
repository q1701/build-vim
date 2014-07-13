#!/bin/bash

# Abort if error.
trap "exit 1" ERR

#======================================
# Build a Vim's RPM file (GUI enabled)
#======================================

# Install the checkinstall
yum -y install  $(ls $VOLUME_SHARE_CONTAINER/checkinstall*.rpm | tail -1)
# Prepare environment to run the rpm-build.
export HOME=/root
mkdir -p $HOME/rpmbuild/SOURCES

# Download the original version
yum -y install mercurial
hg clone https://vim.googlecode.com/hg/ vim
cd $BUILD_TMP/vim

# Build
## Install dependencies to build
export BUILD_REQUIRES=gcc,gettext,ncurses-devel,lua,lua-devel,perl-ExtUtils-Embed,ruby,ruby-devel,libX11-devel,libXt-devel,gtk2-devel
yum -y install ${BUILD_REQUIRES//,/ }
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
  --enable-rubyinterp \
  --enable-cscope
## Make and install
make install
## Identify the version string. ("x.y.z")
export VERSION=""$(LANG=C vim --version | grep "^VIM" | sed "s/VIM - Vi IMproved \([0-9]*\.[0-9]*\).*/\1/").$(LANG=C vim --version | grep "^Included patches:" | sed "s/Included patches:.*-\([0-9]*\)/\1/")""
## Build a rpm.
export REQUIRES=gtk2,libSM,libXt,libruby
echo "Vim $VERSION" > description-pak
checkinstall --type=rpm --pkgname=vim --pkgversion=$VERSION --default --requires=$REQUIRES --autoreqprov=no
## Save the full path of the rpm file into a file
export RPM_PATH="$HOME/rpmbuild/RPMS/$(arch)/vim-$VERSION-1.$(arch).rpm"
## Install the generated rpm file to test it
yum -y localinstall $RPM_PATH
cd $BUILD_TMP

# Export
# (Environment "VOLUME_SHARE_CONTAINER" must be specified when 'docker run'.)
cp -p $RPM_PATH $VOLUME_SHARE_CONTAINER
rm -f $RPM_PATH

echo "========================="
echo "Created: $(basename $RPM_PATH)"
echo "========================="

# Clean up
cd /
yum clean all
rm -rf $BUILD_TMP
