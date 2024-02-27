FROM ubuntu:20.04

# Upgrade system and Buildroot basic dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
        git-core \
        subversion \
	rsync \
	gcc-multilib \
	build-essential \
	debianutils \
	file \
	wget \
	cpio \
	unzip \
	bc   

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install sudo

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*                  

# User management
ARG host_uid=1000
ARG host_gid=1000                                                                
RUN groupadd -g $host_gid buildroot_user && useradd -u $host_uid -g $host_gid -ms /bin/bash buildroot_user && usermod -a -G sudo buildroot_user && usermod -a -G users buildroot_user 

# Install the repo tool to handle git submodules (meta layers) comfortably.
ADD https://storage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
RUN chmod 755 /usr/local/bin/repo

# Run as build user from the installation path                                   
ENV BUILDROOT_INSTALL_PATH "/home/buildroot_user/project"                                              
RUN install -o $host_uid -g $host_gid -d $BUILDROOT_INSTALL_PATH                               
USER buildroot_user                                                                       
WORKDIR ${BUILDROOT_INSTALL_PATH}                                                    

# Install Buildroot                                                                   
RUN git clone https://github.com/buildroot/buildroot.git buildroot
          
                                                                
