FROM debian:trixie-slim

ENV DEBIAN_FRONTEND="noninteractive"

# Install basic dependencies
RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
    wget curl ca-certificates sudo

# Install the correct i386 architecture for WoW64 support and all required Wine dependencies
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    # 64-bit (amd64) libraries for Wine
    libasound2-plugins \
    libasound2t64 \
    libc6 \
    libcups2t64 \
    libdbus-1-3 \
    libfontconfig1 \
    libfreetype6 \
    libglib2.0-0t64 \
    libglu1-mesa \
    libgnutls30t64 \
    libgsm1 \
    libgssapi-krb5-2 \
    libgstreamer-plugins-base1.0-0 \
    libgstreamer1.0-0 \
    libjpeg62-turbo \
    libkrb5-3 \
    libncurses6 \
    libodbc2 \
    libosmesa6 \
    libpcap0.8 \
    libpng16-16t64 \
    libpulse0 \
    libsane1 \
    libsdl2-2.0-0 \
    libtiff6 \
    libudev1 \
    libusb-1.0-0 \
    libx11-6 \
    libxcomposite1 \
    libxcursor1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxinerama1 \
    libxrandr2 \
    libxrender1 \
    libxslt1.1 \
    libxxf86vm1 \
    ocl-icd-libopencl1 \
    # 32-bit (i386) libraries for WoW64
    libasound2-plugins:i386 \
    libasound2t64:i386 \
    libc6:i386 \
    libcups2t64:i386 \
    libdbus-1-3:i386 \
    libfontconfig1:i386 \
    libfreetype6:i386 \
    libglib2.0-0t64:i386 \
    libglu1-mesa:i386 \
    libgnutls30t64:i386 \
    libgsm1:i386 \
    libgssapi-krb5-2:i386 \
    libgstreamer-plugins-base1.0-0:i386 \
    libgstreamer1.0-0:i386 \
    libjpeg62-turbo:i386 \
    libkrb5-3:i386 \
    libncurses6:i386 \
    libodbc2:i386 \
    libosmesa6:i386 \
    libpcap0.8:i386 \
    libpng16-16t64:i386 \
    libpulse0:i386 \
    libsane1:i386 \
    libsdl2-2.0-0:i386 \
    libtiff6:i386 \
    libudev1:i386 \
    libusb-1.0-0:i386 \
    libx11-6:i386 \
    libxcomposite1:i386 \
    libxcursor1:i386 \
    libxext6:i386 \
    libxfixes3:i386 \
    libxi6:i386 \
    libxinerama1:i386 \
    libxrandr2:i386 \
    libxrender1:i386 \
    libxslt1.1:i386 \
    libxxf86vm1:i386 \
    ocl-icd-libopencl1:i386 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install additional packages for gaming and graphics
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    cabextract \
    xvfb \
    unzip \
    tar \
    xz-utils \
    iptables \
    iproute2 \
    socat \
    mesa-vulkan-drivers \
    vulkan-tools \
    libvulkan1 \
    libvulkan-dev \
    mesa-utils \
    mesa-utils-extra \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Create required groups and gamer user early
RUN getent group render >/dev/null 2>&1 || groupadd -r render \
 && getent group input >/dev/null 2>&1 || groupadd -r input \
 && useradd -m -s /bin/bash -u 1000 gamer \
 && usermod -aG audio,video,render,input,sudo gamer \
 && echo 'gamer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Clean up
RUN apt-get -y autoremove \
 && apt-get clean autoclean \
 && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists

# Create mount point for shared directory
RUN mkdir -p /mnt/shared

# Create gfxstream Vulkan ICD configuration
RUN mkdir -p /usr/share/vulkan/icd.d
COPY gfxstream_vk_icd.json /usr/share/vulkan/icd.d/

# Download gfxstream Vulkan library (will be available on Linux target)
RUN mkdir -p /usr/lib/aarch64-linux-gnu/ \
 && echo "Note: libvulkan_gfxstream.so should be available on the Linux target system at /usr/lib/aarch64-linux-gnu/libvulkan_gfxstream.so"

# Create environment setup script
COPY setup-gfxstream.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-gfxstream.sh

# Create game launcher script
COPY launch-game /usr/local/bin/
RUN chmod +x /usr/local/bin/launch-game

# Copy XinputBridge UDP proxy server
COPY services/uhid-server-arm64 /usr/local/bin/
RUN chmod +x /usr/local/bin/uhid-server-arm64

# Create opt directory and set proper permissions for gamer user
RUN mkdir -p /opt \
 && chown -R gamer:gamer /opt

# Install Hangover (native ARM64 Wine implementation)
RUN cd /tmp \
 && wget https://github.com/AndreRH/hangover/releases/download/hangover-10.14/hangover_10.14_debian13_trixie_arm64.tar \
 && tar -xf hangover_10.14_debian13_trixie_arm64.tar \
 && apt-get update \
 && apt install -y ./hangover-wine_10.14~trixie_arm64.deb || true \
 && apt install -y ./hangover-*.deb \
 && rm -rf /tmp/hangover* \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install winetricks
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/local/bin/winetricks \
 && chmod +x /usr/local/bin/winetricks

# Switch to gamer user for Wine prefix initialization
USER gamer
WORKDIR /home/gamer

# Install wine preparation script as gamer user
COPY wine-prep.sh /tmp/
RUN bash /tmp/wine-prep.sh
USER root
RUN rm -f /tmp/wine-prep.sh

# Install DXVK-Sarek after Wine prefix is initialized
USER gamer
ENV WINEPREFIX=/home/gamer/.persist/wine64
RUN cd /tmp && wget -O dxvk-1.10.tar.gz "https://github.com/doitsujin/dxvk/releases/download/v1.10/dxvk-1.10.tar.gz" \
 && tar -xzf dxvk-1.10.tar.gz \
 && cd dxvk-1.10 \
 && chmod +x setup_dxvk.sh \
 && bash setup_dxvk.sh
USER root

# Set up environment variables for gfxstream
ENV MESA_LOADER_DRIVER_OVERRIDE=zink
ENV VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/gfxstream_vk_icd.json
ENV MESA_VK_WSI_DEBUG=sw,linear
ENV XWAYLAND_NO_GLAMOR=1
ENV LIBGL_KOPPER_DRI2=1
ENV DISPLAY=:0
ENV WINEPREFIX=/home/gamer/.persist/wine64

# Set up final permissions and switch to gamer user
RUN chown -R gamer:gamer /home/gamer \
 && chown -R gamer:gamer /mnt/shared

USER gamer
WORKDIR /home/gamer
ENTRYPOINT ["bash", "-c"]
CMD ["bash"]
