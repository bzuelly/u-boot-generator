FROM rockylinux:9 AS base
ARG SOURCE_DATE_EPOCH
COPY sigaltarch.repo /etc/yum.repos.d
RUN rpm --import https://dl.rockylinux.org/pub/sig/9/altarch/aarch64/altarch-common/RPM-GPG-KEY-Rocky-SIG-AltArch
RUN dnf install epel-release -y && /usr/bin/crb enable && rm /etc/yum.repos.d/epel-*.repo
RUN dnf install -y \
    bc \
    bison \
    dtc \
    flex \
    gcc \
    gnutls-devel \
    libuuid-devel \
    make \
    ncurses-devel \
    openssl-devel \
    perl-interpreter \
    python3-devel \
    python3-setuptools \
    python3-libfdt \
    SDL2-devel \
    swig \
    arm-trusted-firmware-armv8 \
    python3-pyelftools

FROM base as u-boot-downloader
ARG SOURCE_DATE_EPOCH
ARG U_BOOT_VERSION=v2024.10
ARG U_BOOT_SOURCE=https://source.denx.de/u-boot/u-boot/-/archive/${U_BOOT_VERSION}/u-boot-${U_BOOT_VERSION}.tar.gz
RUN mkdir -p /u-boot/src && \
    curl -L ${U_BOOT_SOURCE} | tar -xz -C /u-boot/src --strip-components=1

FROM base as u-boot-builder
ARG SOURCE_DATE_EPOCH

COPY --from=u-boot-downloader /u-boot/src /u-boot/src
COPY --from=base /usr/share/arm-trusted-firmware/rk3399/bl31.elf /rkbin/bl31.elf

ARG U_BOOT_VERSION=v2024.10
ARG BOARD=rk3399elite
ARG NAME=u-boot-${U_BOOT_VERSION}-${BOARD}-spi
ARG DEFCONFIG=roc-pc-rk3399

ENV ROCKCHIP_TPL=""
ENV BL31=/rkbin/bl31.elf
ENV ARCH=arm64

WORKDIR /u-boot/src
RUN --mount=type=cache,target=/u-boot/build \
    make O=/u-boot/build -j$(nproc) ${DEFCONFIG}_defconfig && \
    make O=/u-boot/build -j$(nproc) HOSTLDLIBS_mkimage="-lssl -lcrypto"

WORKDIR /u-boot
RUN --mount=type=cache,target=/u-boot/build \
    mkdir -p out && \
    cp -r build/u-boot-rockchip-spi.bin out/${NAME}.bin

FROM scratch AS u-boot
ARG SOURCE_DATE_EPOCH

ARG U_BOOT_VERSION=v2024.10
ARG BOARD=rk3399elite
COPY --from=u-boot-builder /u-boot/out/* /

