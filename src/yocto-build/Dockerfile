FROM ubuntu:20.04

# Upgrade system and Yocto Project basic dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
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
	libacl1

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
	locales \
	sudo

# Set up locales
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils && dpkg-reconfigure locales && locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Replace dash with bash                                                         
RUN rm /bin/sh && ln -s bash /bin/sh                                        

# User management
ARG host_uid=1000
ARG host_gid=1000                                                                
RUN groupadd -g $host_gid yocto_user && useradd -u $host_uid -g $host_gid -ms /bin/bash yocto_user && usermod -a -G sudo yocto_user && usermod -a -G users yocto_user 

# Install the repo tool to handle git submodules (meta layers) comfortably.
ADD https://storage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
RUN chmod 755 /usr/local/bin/repo

# Run as build user from the installation path                                   
ENV YOCTO_INSTALL_PATH "/home/yocto_user/project"                                              
RUN install -o $host_uid -g $host_gid -d $YOCTO_INSTALL_PATH                               
USER yocto_user                                                                       
WORKDIR ${YOCTO_INSTALL_PATH}                                                    

# Install Poky                                                                   
RUN git clone git://git.yoctoproject.org/poky
  
