FROM debian:buster-20200607-slim

LABEL maintainer="thomas.schaffter@gmail.com"

ARG user=builder

# Install Git and the build dependencies
# hadolint ignore=DL3008
RUN apt-get update -qq -y && apt-get install --no-install-recommends -qq -y \
    apt-transport-https \
    bc \
    bison \
    build-essential \
    ca-certificates \
    cpio \
    dpkg-dev \
    fakeroot \
    flex \
    git \
    kmod \
    libssl-dev \
    libc6-dev \
    libncurses5-dev \
    make \
    rsync \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create user and set work directory
RUN useradd -m $user
USER $user
WORKDIR /home/$user

# Copy script that builds the kernel
COPY --chown=$user:$user build-kernel.sh .
RUN chmod +x build-kernel.sh

ENTRYPOINT ["bash", "build-kernel.sh"]
CMD ["--help"]