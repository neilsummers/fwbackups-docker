ARG UBUNTU_VERSION=18.04
FROM ubuntu:$UBUNTU_VERSION

LABEL description="Custom Docker Image for fwbackups which uses ubuntu 18.04 Bionic.\
This is the last Ubuntu version that supports python2, which fwbackups require.\
Python2 does not play well with future versions of Ubuntu based on Python3 \
 so need a Docker Image to contain the old OS."

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update
# install dev tools
RUN apt install -y wget intltool build-essential x11-apps
# install dependencies for fwbackups
RUN apt install -y cron gettext python-gtk2 python-paramiko python-glade2 python-crypto python-notify

# INSTALL fwbackups
RUN mkdir -p /src
ADD http://downloads.diffingo.com/fwbackups/fwbackups-1.43.7.tar.bz2 /src
WORKDIR /src
RUN tar jxf fwbackups-1.43.7.tar.bz2
WORKDIR /src/fwbackups-1.43.7
RUN ./configure --prefix=/usr/local
RUN make
RUN make install
# fix bug in file which does not update prefix
RUN sed -i "s/\/usr\/bin\/fwbackups/\/usr\/local\/bin\/fwbackups/" /usr/local/share/fwbackups/fwbackups-autostart.desktop

# set USER and GROUPS to the user building/running the container
ARG USER=username
ARG GROUP=username
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${GROUP}
RUN useradd -l -u ${UID} -g ${GID} ${USER}
RUN install -d -m 0755 -o ${USER} -g ${GROUP} /home/${USER}
USER ${USER}
