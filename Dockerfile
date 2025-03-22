# Use an Ubuntu base image
FROM ubuntu:22.04 AS build 


ENV DEBIAN_FRONTEND=non-interactive


ARG DISTRO_DIR
ENV DISTRO_DIR=${DISTRO_DIR}

RUN if [ -z "$DISTRO_DIR" ]; then echo "Error: DISTRO_DIR is not set" && exit 1; fi

ENV ROOTFS=/rootfs

# Required for ubuntu build
RUN apt update && apt install -y debootstrap qemu qemu-user-static binfmt-support dpkg-cross joe --no-install-recommends

RUN mkdir -p $ROOTFS

COPY $DISTRO_DIR/ distro/
RUN ln -s distro/build.sh /build.sh 

# ------------------------------------------------------------

FROM build AS distro-arm64

ENV ARCH="arm64"
ENV QEMU="qemu-aarch64-static"

RUN apt install -y gcc-aarch64-linux-gnu gcc-aarch64-linux-gnu g++-aarch64-linux-gnu binutils-aarch64-linux-gnu


CMD bash build.sh
# ------------------------------------------------------------------------------

FROM build AS distro-riscv64

ENV ARCH="riscv64"
ENV QEMU="qemu-riscv64-static"

RUN apt install -y gcc-riscv64-linux-gnu g++-riscv64-linux-gnu binutils-riscv64-linux-gnu


CMD bash build.sh
