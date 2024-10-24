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

FROM base as rkbin-downloader
ARG SOURCE_DATE_EPOCH
ARG RKBIN_SOURCE=https://github.com/rockchip-linux/rkbin/archive/refs/heads/master.tar.gz

RUN mkdir -p /src && \
    mkdir -p /rkbin && \
    curl -L ${RKBIN_SOURCE} | tar -xz -C /src --strip-components=1 && \
    cp /src/bin/rk35/$(ls -1 /src/bin/rk35 | grep -E 'rk3588_ddr_lp4_2112MHz_lp5_2400MHz_v[0-9.]+.bin' | tail -n 1) /rkbin/tpl.bin && \
    cp /src/bin/rk35/$(ls -1 /src/bin/rk35 | grep -E 'rk3588_bl31_v[0-9.]+.elf' | tail -n 1) /rkbin/bl31.bin

FROM base as u-boot-builder
ARG SOURCE_DATE_EPOCH

COPY --from=u-boot-downloader /u-boot/src /u-boot/src
COPY --from=rkbin-downloader /rkbin /rkbin

ARG U_BOOT_VERSION=v2024.10
ARG BOARD=cm3588-nas
ARG NAME=u-boot-${U_BOOT_VERSION}-${BOARD}-spi
ARG DEFCONFIG=nanopc-t6-rk3588

ENV ROCKCHIP_TPL=/rkbin/tpl.bin
ENV BL31=/rkbin/bl31.bin
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
ARG BOARD=cm3588-nas
COPY --from=u-boot-builder /u-boot/out/* /

