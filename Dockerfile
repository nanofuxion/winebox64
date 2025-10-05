FROM debian:bookworm-slim as build

ENV DEBIAN_FRONTEND="noninteractive"

# Install libraries needed to compile box
RUN dpkg --add-architecture armhf \
 && apt-get update \
 && apt-get install -y --no-install-recommends --no-install-suggests git wget curl cmake python3 build-essential gcc-arm-linux-gnueabihf libc6-dev-armhf-cross libc6:armhf libstdc++6:armhf ca-certificates \
 && apt-get install -y libasound2-plugins:armhf libasound2:armhf libc6:armhf libcapi20-3:armhf libcups2:armhf libdbus-1-3:armhf libfontconfig1:armhf libfreetype6:armhf libglib2.0-0:armhf libglu1-mesa:armhf libgnutls30:armhf libgphoto2-6:armhf libgphoto2-port12:armhf libgsm1:armhf libgssapi-krb5-2:armhf libgstreamer-plugins-base1.0-0:armhf libgstreamer1.0-0:armhf libjpeg62-turbo:armhf libkrb5-3:armhf libncurses6:armhf libodbc1:armhf libosmesa6:armhf libpcap0.8:armhf libpng16-16:armhf libpulse0:armhf libsane1:armhf libsdl2-2.0-0:armhf libtiff6:armhf libudev1:armhf libunwind8:armhf libusb-1.0-0:armhf libv4l-0:armhf libx11-6:armhf libxcomposite1:armhf libxcursor1:armhf libxext6:armhf libxfixes3:armhf libxi6:armhf libxinerama1:armhf libxrandr2:armhf libxrender1:armhf libxslt1.1:armhf libxxf86vm1:armhf ocl-icd-libopencl1:armhf \ 
 && apt-get install -y libasound2-plugins:arm64 libasound2:arm64 libc6:arm64 libcapi20-3:arm64 libcups2:arm64 libdbus-1-3:arm64 libfontconfig1:arm64 libfreetype6:arm64 libglib2.0-0:arm64 libglu1-mesa:arm64 libgnutls30:arm64 libgphoto2-6:arm64 libgphoto2-port12:arm64 libgsm1:arm64 libgssapi-krb5-2:arm64 libgstreamer-plugins-base1.0-0:arm64 libgstreamer1.0-0:arm64 libjpeg62-turbo:arm64 libkrb5-3:arm64 libncurses6:arm64 libodbc1:arm64 libosmesa6:arm64 libpcap0.8:arm64 libpng16-16:arm64 libpulse0:arm64 libsane1:arm64 libsdl2-2.0-0:arm64 libtiff6:arm64 libudev1:arm64 libusb-1.0-0:arm64 libv4l-0:arm64 libx11-6:arm64 libxcomposite1:arm64 libxcursor1:arm64 libxext6:arm64 libxfixes3:arm64 libxi6:arm64 libxinerama1:arm64 libxrandr2:arm64 libxrender1:arm64 libxslt1.1:arm64 libxxf86vm1:arm64 ocl-icd-libopencl1:arm64 

WORKDIR /root

# Build box86
RUN git clone https://github.com/ptitSeb/box86 \
 && mkdir box86/build \
 && cd box86/build \
 && cmake .. -DRPI4ARM64=1 -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 && make -j$(nproc) \
 && make install DESTDIR=/box 

# Build box64
RUN git clone https://github.com/ptitSeb/box64 \
 && mkdir box64/build \
 && cd box64/build \
 && cmake .. -DRPI4ARM64=1 -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 && make -j$(nproc) \
 && make install DESTDIR=/box

FROM debian:bookworm-slim

# Copy compiled box86 and box64 binaries
COPY --from=build /box /

# Install libraries needed to run box
RUN dpkg --add-architecture armhf \
 && apt-get update \
 && apt-get install --yes --no-install-recommends wget curl libc6:armhf libstdc++6:armhf ca-certificates 

# Install additional packages for gaming and graphics
RUN apt-get update && apt-get install -y --no-install-recommends \
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

# Clean up
RUN apt-get -y autoremove \
 && apt-get clean autoclean \
 && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists

# Install Wine 10.0 with WOW64 support
COPY install-wine.sh /
RUN bash /install-wine.sh \
 && rm /install-wine.sh

# Install box wrapper for wine
COPY wrap-wine.sh /
RUN bash /wrap-wine.sh \
 && rm /wrap-wine.sh

# Create gfxstream Vulkan ICD configuration
RUN mkdir -p /usr/share/vulkan/icd.d
COPY gfxstream_vk_icd.json /usr/share/vulkan/icd.d/

# Download gfxstream Vulkan library (will be available on Linux target)
RUN mkdir -p /usr/lib/aarch64-linux-gnu/ && \
    echo "Note: libvulkan_gfxstream.so should be available on the Linux target system at /usr/lib/aarch64-linux-gnu/libvulkan_gfxstream.so"

# Install DXVK-Sarek for Vulkan 1.1.305 compatibility
RUN cd /tmp && wget -O dxvk-sarek-v1.11.0.tar.gz "https://github.com/pythonlover02/DXVK-Sarek/releases/download/v1.11.0/dxvk-sarek-async-v1.11.0.tar.gz" \
 && tar -xzf dxvk-sarek-v1.11.0.tar.gz \
 && mkdir -p /opt/dxvk-sarek \
 && cp -r dxvk-sarek-async-v1.11.0/* /opt/dxvk-sarek/ \
 && rm -rf /tmp/dxvk-sarek-async-v1.11.0 /tmp/dxvk-sarek-v1.11.0.tar.gz

# Install XinputBridge winefiles
RUN cd /tmp && wget -O winefiles-1.35.zip "https://github.com/Ilan12346-maya/XinputBridge/releases/download/1.35/winefiles_1.35.zip" \
 && unzip winefiles-1.35.zip \
 && mkdir -p /opt/xinput-bridge \
 && cp -r winefiles/* /opt/xinput-bridge/ \
 && rm -rf /tmp/winefiles /tmp/winefiles-1.35.zip

# Install UDP proxy for XinputBridge
RUN cd /tmp && wget -O udp-proxy-1.0.1.zip "https://github.com/nanofuxion/XinputBridge/releases/download/v1.0.1/udp-proxy-package.zip" \
 && unzip udp-proxy-1.0.1.zip \
 && mkdir -p /opt/udp-proxy \
 && cp -r arm64/* /opt/udp-proxy/ \
 && chmod +x /opt/udp-proxy/udp_proxy \
 && rm -rf /tmp/arm64 /tmp/amd64 /tmp/*.sh /tmp/*.service /tmp/udp-proxy-1.0.1.zip

# Create environment setup script
COPY setup-gfxstream.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-gfxstream.sh

# Create game launcher script
COPY launch-game.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/launch-game.sh

# Create required groups and gamer user
RUN groupadd -r render && \
    groupadd -r input && \
    useradd -m -s /bin/bash -u 1000 gamer && \
    usermod -aG audio,video,render,input gamer

# Create mount point for shared directory
RUN mkdir -p /mnt/shared

# Set up environment variables for gfxstream
ENV MESA_LOADER_DRIVER_OVERRIDE=zink
ENV VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/gfxstream_vk_icd.json
ENV MESA_VK_WSI_DEBUG=sw,linear
ENV XWAYLAND_NO_GLAMOR=1
ENV LIBGL_KOPPER_DRI2=1
ENV DISPLAY=:0
ENV WINEPREFIX=/home/gamer/.wine64

# Set up gamer user home directory and permissions
RUN chown -R gamer:gamer /home/gamer && \
    chown -R gamer:gamer /mnt/shared && \
    mkdir -p /home/gamer/.wine64 && \
    chown -R gamer:gamer /home/gamer/.wine64

WORKDIR /home/gamer
USER gamer
ENTRYPOINT ["bash", "-c"]
CMD ["bash"]