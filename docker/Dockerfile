FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm-256color

# Enable universe and multiverse repositories
RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common \
        ca-certificates \
        gnupg \
        curl \
        wget \
    && add-apt-repository universe \
    && add-apt-repository multiverse \
    && apt-get update \
    && rm -rf /var/lib/apt/lists/*

# Install 32-bit compatibility libraries on amd64
RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
        apt-get update && apt-get install -y --no-install-recommends \
            lib32ncurses6 \
            lib32stdc++6 \
            lib32tinfo6 \
            libc6-i386 \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Install build dependencies required by orangepi-build
RUN apt-get update && apt-get install -y --no-install-recommends \
        acl \
        aptly \
        aria2 \
        bc \
        binfmt-support \
        binutils \
        bison \
        btrfs-progs \
        build-essential \
        ccache \
        cpio \
        cryptsetup \
        cryptsetup-bin \
        debian-archive-keyring \
        debian-keyring \
        debootstrap \
        device-tree-compiler \
        dialog \
        distcc \
        dosfstools \
        dwarves \
        f2fs-tools \
        fakeroot \
        fdisk \
        flex \
        gawk \
        gcc-aarch64-linux-gnu \
        gcc-arm-linux-gnueabihf \
        gcc-arm-linux-gnueabi \
        gcc-arm-none-eabi \
        gdisk \
        git \
        imagemagick \
        jq \
        kmod \
        libbison-dev \
        libelf-dev \
        libfdt-dev \
        libfile-fcntllock-perl \
        libfl-dev \
        liblz4-tool \
        libncurses5-dev \
        libncurses-dev \
        libssl-dev \
        libusb-1.0-0-dev \
        linux-base \
        locales \
        lsb-release \
        lzop \
        ncurses-base \
        ncurses-term \
        nfs-kernel-server \
        ntpdate \
        openssh-client \
        p7zip-full \
        parted \
        patchutils \
        pigz \
        pixz \
        pkg-config \
        psmisc \
        pv \
        python3 \
        python3-dev \
        python3-distutils \
        python3-pkg-resources \
        python3-setuptools \
        qemu \
        qemu-utils \
        qemu-user-static \
        rsync \
        sudo \
        swig \
        systemd-container \
        tzdata \
        u-boot-tools \
        udev \
        unzip \
        uuid \
        uuid-dev \
        uuid-runtime \
        whiptail \
        xfsprogs \
        xxd \
        zip \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Generate locale
RUN locale-gen en_US.UTF-8

# Create symlinks for aarch64-none-linux-gnu to match aarch64-linux-gnu
RUN for bin in /usr/bin/aarch64-linux-gnu-*; do \
        suffix="${bin#/usr/bin/aarch64-linux-gnu-}"; \
        ln -s "$bin" "/usr/bin/aarch64-none-linux-gnu-${suffix}"; \
    done

# Configure Git safe directories
RUN git config --system --add safe.directory "*"

# Set loop module config
RUN echo 'loop max_loop=128' >> /etc/modules

WORKDIR /workspace/orangepi-build

CMD [ "/bin/bash" ]
