FROM debian:bookworm-slim as build

ENV DEBIAN_FRONTEND="noninteractive"

# Install libraries needed to compile box
RUN dpkg --add-architecture armhf \
 && apt-get update \
 && apt-get install -y --no-install-recommends --no-install-suggests git wget curl cmake python3 build-essential gcc-arm-linux-gnueabihf libc6-dev-armhf-cross libc6:armhf libstdc++6:armhf ca-certificates 

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
    mesa-vulkan-drivers \
    vulkan-tools \
    libvulkan1 \
    libvulkan-dev \
    mesa-utils \
    glxinfo \
    vulkan-utils \
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

# Install DXVK-Sarek for Vulkan 1.1.305 compatibility
COPY dxvk-sarek-v1.11.0.tar.gz /tmp/
RUN cd /tmp && tar -xzf dxvk-sarek-v1.11.0.tar.gz \
 && mkdir -p /opt/dxvk-sarek \
 && cp -r dxvk-sarek-async-v1.11.0/* /opt/dxvk-sarek/ \
 && rm -rf /tmp/dxvk-sarek-async-v1.11.0 /tmp/dxvk-sarek-v1.11.0.tar.gz

# Install XinputBridge winefiles
COPY winefiles-1.35.zip /tmp/
RUN cd /tmp && unzip winefiles-1.35.zip \
 && mkdir -p /opt/xinput-bridge \
 && cp -r winefiles/* /opt/xinput-bridge/ \
 && rm -rf /tmp/winefiles /tmp/winefiles-1.35.zip

# Install UDP proxy for XinputBridge
COPY udp-proxy-1.0.1.zip /tmp/
RUN cd /tmp && unzip udp-proxy-1.0.1.zip \
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

# Create mount point for shared directory
RUN mkdir -p /mnt/shared

# Set up environment variables for gfxstream
ENV MESA_LOADER_DRIVER_OVERRIDE=zink
ENV VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/gfxstream_vk_icd.json
ENV MESA_VK_WSI_DEBUG=sw,linear
ENV XWAYLAND_NO_GLAMOR=1
ENV LIBGL_KOPPER_DRI2=1
ENV DISPLAY=:0

WORKDIR /root
ENTRYPOINT ["bash", "-c"]
CMD ["bash"]