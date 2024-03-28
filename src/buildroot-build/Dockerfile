FROM ubuntu:20.04


ARG UID
ARG GID
ARG BUILDROOT_INSTALL_PATH
ENV BUILDROOT_INSTALL_PATH=$BUILDROOT_INSTALL_PATH


# Upgrade system and Buildroot basic dependencies, Clean up APT
RUN apt-get update && \ 
	DEBIAN_FRONTEND=noninteractive apt-get -y install \
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
	bc \
	sudo && \   
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*                  


# User management                                              
RUN groupadd -g $GID buildroot_user && \
	useradd -u $UID -g $GID -ms /bin/bash buildroot_user && \
	usermod -a -G sudo buildroot_user && \
	usermod -a -G users buildroot_user && \
	install -o $UID -g $GID -d $BUILDROOT_INSTALL_PATH


# Run as build user from the installation path                                                                                                            
USER buildroot_user                                                                       
WORKDIR $BUILDROOT_INSTALL_PATH                                                    


ENTRYPOINT ["./assembly/building.sh"]                                                       
