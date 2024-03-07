FROM ubuntu:20.04


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
	apt-utils && \
	dpkg-reconfigure locales && locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8


# Replace dash with bash, User management
ARG UID
ARG GID

ENV YOCTO_INSTALL_PATH "/home/yocto_user/project"
                                                         
RUN rm /bin/sh && ln -s bash /bin/sh && \                                       
	groupadd -g $GID yocto_user && \
	useradd -u $UID -g $GID -ms /bin/bash yocto_user && \
	usermod -a -G sudo yocto_user && \
	usermod -a -G users yocto_user && \
	install -o $UID -g $GID -d $YOCTO_INSTALL_PATH 


# Run as build user from the installation path                                                                                                                
USER yocto_user             
WORKDIR ${YOCTO_INSTALL_PATH}  


# Install Poky
RUN git clone git://git.yoctoproject.org/poky
  

