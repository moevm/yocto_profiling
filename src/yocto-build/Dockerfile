ARG REQS_ARG=perf


FROM ubuntu:20.04 AS requirements

ARG UID
ARG GID
ARG CORE
ARG CODENAME

ARG YOCTO_INSTALL_PATH
ARG LC_ALL
ARG LANG
ENV YOCTO_INSTALL_PATH=$YOCTO_INSTALL_PATH
ENV LC_ALL=$LC_ALL
ENV LANG=$LANG

# Upgrade system and Yocto Project basic dependencies, Set up locales, Clean up APT
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get -y install \
        gawk \
        wget \
        git-core \
        diffstat \
        unzip \
        texinfo \
	gcc-multilib \
        build-essential \
        chrpath \
        socat \
	cpio \
	python3 \
        python3-pip \
        python3-pexpect \
        xz-utils \
	debianutils \
	iputils-ping \
        python3-git \
        python3-jinja2 \
	libegl1-mesa \
        libsdl1.2-dev \
        python3-subunit \ 
	mesa-common-dev \ 
	zstd \ 
	liblz4-tool \ 
	file \ 
	libacl1 \
	locales \
	sudo \
	apt-utils \
	nano \
	software-properties-common \
	\
	lsof \
	\
	sysstat \
	strace && \
	dpkg-reconfigure locales && locale-gen ${LC_ALL} && update-locale LC_ALL=${LC_ALL} LANG=${LANG}


FROM requirements AS perf

# install linux-tools-$CORE for host core
RUN sed -i "s/focal/${CODENAME}/g" /etc/apt/sources.list  && \
	apt-get update && \
	apt-get -y install linux-tools-common linux-tools-${CORE} && \
	sed -i "s/${CODENAME}/focal/g" /etc/apt/sources.list && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


FROM $REQS_ARG AS base

# Python utils
RUN python3 -m pip install -U psutil numpy matplotlib 

# Replace dash with bash, User management              
RUN rm /bin/sh && ln -s bash /bin/sh && \                                       
	groupadd -g $GID yocto_user && \
	useradd -u $UID -g $GID -ms /bin/bash yocto_user && \
	usermod -a -G sudo yocto_user && \
	usermod -a -G users yocto_user && \
	install -o $UID -g $GID -d $YOCTO_INSTALL_PATH && \
	echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Run as build user from the installation path                                                                     
USER yocto_user             
WORKDIR $YOCTO_INSTALL_PATH


ENTRYPOINT ["./assembly/scripts/setup.sh"]
