FROM ubuntu:20.04 AS requirements

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
	strace 


WORKDIR ./building
COPY ./building ./
COPY ./get_ip.py ./get_ip.py


ENV PORT=8888

EXPOSE ${PORT}

CMD ["sh", "-c", "./building.sh $PORT"]	
