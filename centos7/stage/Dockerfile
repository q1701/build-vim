FROM centos:centos7

MAINTAINER q1701 <q1701@outlook.com>

# Create a working directory
RUN mkdir /tmp/build
ENV BUILD_TMP /tmp/build
WORKDIR /tmp/build

# Install dependencies to build
ENV BUILD_REQUIRES make,gcc,gettext,ncurses-devel,gtk2-devel,libX11-devel,libXt-devel,lua,lua-devel,perl,perl-ExtUtils-Embed,python,python-devel,ruby,ruby-devel
RUN yum -y install ${BUILD_REQUIRES//,/ }

# Export the generated rpm file
ENTRYPOINT ["/bin/bash", "-c", "$VOLUME_SHARE_CONTAINER/scripts/build_rpm.sh"]
