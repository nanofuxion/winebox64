FROM debian:trixie-slim as build

ENV DEBIAN_FRONTEND="noninteractive"

# Install libraries needed to compile box
RUN dpkg --add-architecture armhf \
 && apt-get update \
 && apt-get install -y --no-install-recommends --no-install-suggests \
    sudo git wget curl cmake python3 build-essential gcc-arm-linux-gnueabihf libc6-dev-armhf-cross libc6:armhf libstdc++6:armhf ca-certificates \
 && apt-get install -y --no-install-recommends \
    libasound2-plugins:armhf libasound2t64:armhf libc6:armhf libcups2t64:armhf libdbus-1-3:armhf libfontconfig1:armhf libfreetype6:armhf libglib2.0-0t64:armhf libglu1-mesa:armhf libgnutls30t64:armhf libgsm1:armhf libgssapi-krb5-2:armhf libgstreamer-plugins-base1.0-0:armhf libgstreamer1.0-0:armhf libjpeg62-turbo:armhf libkrb5-3:armhf libncurses6:armhf libosmesa6:armhf libpcap0.8:armhf libpng16-16t64:armhf libpulse0:armhf libsane1:armhf libsdl2-2.0-0:armhf libtiff6:armhf libudev1:armhf libunwind8:armhf libusb-1.0-0:armhf libx11-6:armhf libxcomposite1:armhf libxcursor1:armhf libxext6:armhf libxfixes3:armhf libxi6:armhf libxinerama1:armhf libxrandr2:armhf libxrender1:armhf libxslt1.1:armhf libxxf86vm1:armhf ocl-icd-libopencl1:armhf \
 && apt-get install -y --no-install-recommends \
    libasound2-plugins:arm64 libasound2t64:arm64 libc6:arm64 libcups2t64:arm64 libdbus-1-3:arm64 libfontconfig1:arm64 libfreetype6:arm64 libglib2.0-0t64:arm64 libglu1-mesa:arm64 libgnutls30t64:arm64 libgsm1:arm64 libgssapi-krb5-2:arm64 libgstreamer-plugins-base1.0-0:arm64 libgstreamer1.0-0:arm64 libjpeg62-turbo:arm64 libkrb5-3:arm64 libncurses6:arm64 libosmesa6:arm64 libpcap0.8:arm64 libpng16-16t64:arm64 libpulse0:arm64 libsane1:arm64 libsdl2-2.0-0:arm64 libtiff6:arm64 libudev1:arm64 libusb-1.0-0:arm64 libx11-6:arm64 libxcomposite1:arm64 libxcursor1:arm64 libxext6:arm64 libxfixes3:arm64 libxi6:arm64 libxinerama1:arm64 libxrandr2:arm64 libxrender1:arm64 libxslt1.1:arm64 libxxf86vm1:arm64 ocl-icd-libopencl1:arm64 

WORKDIR /root

# Build box64 and box32
RUN git clone https://github.com/ptitSeb/box64 \
 && mkdir box64/build \
 && cd box64/build \
 && cmake .. -DRPI4ARM64=1 -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -D BOX32=ON -D BOX32_BINFMT=ON \
 && make -j$(nproc) \
 && make install DESTDIR=/box

FROM debian:trixie-slim

# Copy compiled box86 and box64 binaries
COPY --from=build /box /

# Install libraries needed to run box
RUN dpkg --add-architecture armhf \
 && apt-get update \
 && apt-get install --yes --no-install-recommends \
    wget curl libc6:armhf libstdc++6:armhf ca-certificates

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
    mesa-vulkan-drivers \
    vulkan-tools \
    libvulkan1 \
    libvulkan-dev \
    mesa-utils \
    mesa-utils-extra \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Create required groups and gamer user early
RUN groupadd -r render \
 && groupadd -r input \
 && useradd -m -s /bin/bash -u 1000 gamer \
 && usermod -aG audio,video,render,input gamer

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

# Switch to gamer user for Wine and game-related installations
USER gamer
WORKDIR /home/gamer

# Install Wine 10.0 with WOW64 support as gamer user
COPY install-wine.sh /tmp/
RUN bash /tmp/install-wine.sh \
 && rm /tmp/install-wine.sh

# Install box wrapper for wine as gamer user
COPY wrap-wine.sh /tmp/
RUN bash /tmp/wrap-wine.sh \
 && rm /tmp/wrap-wine.sh

# Install DXVK-Sarek for Vulkan 1.1.305 compatibility as gamer user
RUN cd /tmp && wget -O dxvk-sarek-v1.11.0.tar.gz "https://github.com/pythonlover02/DXVK-Sarek/releases/download/v1.11.0/dxvk-sarek-async-v1.11.0.tar.gz" \
 && tar -xzf dxvk-sarek-v1.11.0.tar.gz \
 && mkdir -p /home/gamer/.local/share/dxvk-sarek \
 && cp -r dxvk-sarek-async-v1.11.0/* /home/gamer/.local/share/dxvk-sarek/ \
 && rm -rf /tmp/dxvk-sarek-async-v1.11.0 /tmp/dxvk-sarek-v1.11.0.tar.gz

# Install XinputBridge winefiles as gamer user
RUN cd /tmp && wget -O winefiles-1.35.zip "https://github.com/Ilan12346-maya/XinputBridge/releases/download/1.35/winefiles_1.35.zip" \
 && unzip winefiles-1.35.zip \
 && mkdir -p /home/gamer/.local/share/xinput-bridge \
 && cp -r winefiles/* /home/gamer/.local/share/xinput-bridge/ \
 && rm -rf /tmp/winefiles /tmp/winefiles-1.35.zip

# Switch back to root for system-wide UDP proxy installation
USER root

# Install UDP proxy for XinputBridge (system-wide)
RUN cd /tmp && wget -O udp-proxy-1.0.1.zip "https://github.com/nanofuxion/XinputBridge/releases/download/v1.0.1/udp-proxy-package.zip" \
 && unzip udp-proxy-1.0.1.zip \
 && mkdir -p /opt/udp-proxy \
 && cp -r arm64/* /opt/udp-proxy/ \
 && chmod +x /opt/udp-proxy/udp_proxy \
 && chown -R gamer:gamer /opt/udp-proxy \
 && rm -rf /tmp/arm64 /tmp/amd64 /tmp/*.sh /tmp/*.service /tmp/udp-proxy-1.0.1.zip

# Set up environment variables for gfxstream
ENV MESA_LOADER_DRIVER_OVERRIDE=zink
ENV VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/gfxstream_vk_icd.json
ENV MESA_VK_WSI_DEBUG=sw,linear
ENV XWAYLAND_NO_GLAMOR=1
ENV LIBGL_KOPPER_DRI2=1
ENV DISPLAY=:0
ENV WINEPREFIX=/home/gamer/.wine64

# Set up final permissions and switch to gamer user
RUN chown -R gamer:gamer /home/gamer \
 && chown -R gamer:gamer /mnt/shared \
 && mkdir -p /home/gamer/.wine64 \
 && chown -R gamer:gamer /home/gamer/.wine64

USER gamer
WORKDIR /home/gamer
ENTRYPOINT ["bash", "-c"]
CMD ["bash"]