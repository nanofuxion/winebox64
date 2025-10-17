FROM debian:trixie-slim

ENV DEBIAN_FRONTEND="noninteractive"

# Install basic dependencies
RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
    wget curl ca-certificates sudo procps

# Install required Wine dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
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
    libsdl2-ttf-2.0-0 \
    libsdl2-image-2.0-0 \
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
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install additional packages for gaming and graphics including Wayland support
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
    libwayland-client0 \
    libwayland-server0 \
    libwayland-egl1 \
    libwayland-cursor0 \
    wayland-protocols \
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

# Create opt directory and set proper permissions for gamer user
RUN mkdir -p /opt \
 && chown -R gamer:gamer /opt

# Install Hangover (native ARM64 Wine implementation) and extract DXVK
RUN cd /tmp \
 && wget https://github.com/AndreRH/hangover/releases/download/hangover-10.14/hangover_10.14_debian13_trixie_arm64.tar \
 && tar -xf hangover_10.14_debian13_trixie_arm64.tar \
 && apt-get update \
 && apt install -y ./hangover-wine_10.14~trixie_arm64.deb || true \
 && apt install -y ./hangover-*.deb \
 && tar -xzf dxvk-v*.tar.gz -C /opt/ \
 && DXVK_DIR=$(ls -d /opt/dxvk-v* 2>/dev/null | head -1) \
 && if [ -n "$DXVK_DIR" ]; then chown -R gamer:gamer "$DXVK_DIR"; fi \
 && rm -rf /tmp/hangover* \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Download and install DXVK-Sarek (supports Vulkan 1.1+)
# RUN cd /tmp \
#  && wget -O dxvk-sarek.tar.gz https://github.com/pythonlover02/DXVK-Sarek/releases/download/v1.11.0/dxvk-sarek-async-v1.11.0.tar.gz \
#  && mkdir -p /opt/dxvk-sarek \
#  && tar -xzf dxvk-sarek.tar.gz -C /tmp/ \
#  && mv /tmp/dxvk-sarek-async-v1.11.0/* /opt/dxvk-sarek/ \
#  && chown -R gamer:gamer /opt/dxvk-sarek \
#  && rm -rf /tmp/dxvk-sarek* \
#  && ls -la /opt/dxvk-sarek/

# Download and install XinputBridge for controller support
RUN cd /tmp \
 && wget -O xinput-bridge.zip https://github.com/Ilan12346-maya/XinputBridge/releases/download/1.35/winefiles_1.35.zip \
 && mkdir -p /opt/xinput-bridge \
 && unzip -q xinput-bridge.zip -d /opt/xinput-bridge/ \
 && chown -R gamer:gamer /opt/xinput-bridge \
 && rm -f xinput-bridge.zip \
 && ls -la /opt/xinput-bridge/

# Download UDP proxy for XinputBridge
RUN cd /tmp \
 && wget -O udp-proxy.zip https://github.com/nanofuxion/XinputBridge/releases/download/v1.0.1/udp-proxy-package.zip \
 && mkdir -p /opt/udp-proxy \
 && unzip -q udp-proxy.zip -d /opt/udp-proxy/ \
 && chmod +x /opt/udp-proxy/udp-proxy 2>/dev/null || true \
 && chown -R gamer:gamer /opt/udp-proxy \
 && rm -f udp-proxy.zip \
 && ls -la /opt/udp-proxy/

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

# Set up environment variables for gfxstream with Wayland support
ENV MESA_LOADER_DRIVER_OVERRIDE=zink
ENV VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/gfxstream_vk_icd.json
ENV MESA_VK_WSI_DEBUG=sw,linear
ENV XWAYLAND_NO_GLAMOR=1
ENV LIBGL_KOPPER_DRI2=1
ENV DISPLAY=:0
ENV XDG_SESSION_TYPE=wayland
ENV GDK_BACKEND=wayland
ENV QT_QPA_PLATFORM=wayland
ENV WINEPREFIX=/home/gamer/.persist/wine64

# Write environment variables to system-wide profile and user's bashrc
RUN echo 'export MESA_LOADER_DRIVER_OVERRIDE=zink' >> /etc/profile.d/gfxstream.sh \
 && echo 'export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/gfxstream_vk_icd.json' >> /etc/profile.d/gfxstream.sh \
 && echo 'export MESA_VK_WSI_DEBUG=sw,linear' >> /etc/profile.d/gfxstream.sh \
 && echo 'export XWAYLAND_NO_GLAMOR=1' >> /etc/profile.d/gfxstream.sh \
 && echo 'export LIBGL_KOPPER_DRI2=1' >> /etc/profile.d/gfxstream.sh \
 && echo 'export DISPLAY=${DISPLAY:-:0}' >> /etc/profile.d/gfxstream.sh \
 && echo 'export XDG_SESSION_TYPE=wayland' >> /etc/profile.d/gfxstream.sh \
 && echo 'export GDK_BACKEND=wayland' >> /etc/profile.d/gfxstream.sh \
 && echo 'export QT_QPA_PLATFORM=wayland' >> /etc/profile.d/gfxstream.sh \
 && echo 'export WINEPREFIX=/home/gamer/.persist/wine64' >> /etc/profile.d/gfxstream.sh \
 && chmod +x /etc/profile.d/gfxstream.sh

# Set up final permissions and switch to gamer user
RUN chown -R gamer:gamer /home/gamer \
 && chown -R gamer:gamer /mnt/shared

USER gamer
WORKDIR /home/gamer

# Add environment setup to .bashrc for interactive shells
RUN echo '' >> /home/gamer/.bashrc \
 && echo '# Graphics environment for gfxstream' >> /home/gamer/.bashrc \
 && echo 'export MESA_LOADER_DRIVER_OVERRIDE=zink' >> /home/gamer/.bashrc \
 && echo 'export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/gfxstream_vk_icd.json' >> /home/gamer/.bashrc \
 && echo 'export MESA_VK_WSI_DEBUG=sw,linear' >> /home/gamer/.bashrc \
 && echo 'export XWAYLAND_NO_GLAMOR=1' >> /home/gamer/.bashrc \
 && echo 'export LIBGL_KOPPER_DRI2=1' >> /home/gamer/.bashrc \
 && echo 'export DISPLAY=${DISPLAY:-:0}' >> /home/gamer/.bashrc \
 && echo 'export WINEPREFIX=/home/gamer/.persist/wine64' >> /home/gamer/.bashrc \
 && echo '' >> /home/gamer/.bashrc \
 && echo '# BOX64 performance optimizations' >> /home/gamer/.bashrc \
 && echo 'export BOX64_DYNAREC_BIGBLOCK=1' >> /home/gamer/.bashrc \
 && echo 'export BOX64_DYNAREC_STRONGMEM=1' >> /home/gamer/.bashrc \
 && echo 'export BOX64_DYNAREC_FASTNAN=1' >> /home/gamer/.bashrc \
 && echo 'export BOX64_DYNAREC_FASTROUND=1' >> /home/gamer/.bashrc \
 && echo 'export BOX64_DYNAREC_ALIGNED_ATOMICS=1' >> /home/gamer/.bashrc \
 && echo 'export BOX64_UNITYPLAYER=1' >> /home/gamer/.bashrc \
 && echo 'export BOX64_SYNC_ROUNDING=1' >> /home/gamer/.bashrc \
 && echo 'export BOX64_DYNAREC_DIRTY=1' >> /home/gamer/.bashrc 

ENTRYPOINT ["bash", "-c"]
CMD ["bash"]
