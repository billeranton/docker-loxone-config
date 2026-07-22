FROM jlesage/baseimage-gui:ubuntu-22.04-v4

# Baseimage-gui ships without /etc/passwd, /var/log is a mount point.
# Create minimal passwd/group so package installs work during build.
RUN rm -rf /var/log && mkdir /var/log && \
    echo "root:x:0:0:root:/root:/bin/sh" > /etc/passwd && \
    echo "root:x:0:root" > /etc/group && \
    echo "staff:x:50:root" >> /etc/group && \
    echo "root::::::::" > /etc/shadow

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        wget gnupg ca-certificates cabextract x11-xkb-utils unzip && \
    wget -nc -q https://dl.winehq.org/wine-builds/winehq.key && \
    gpg -o /etc/apt/keyrings/winehq-archive.key --dearmor winehq.key && \
    rm winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        winehq-stable && \
    rm -rf /var/lib/apt/lists/* && \
    wget -O /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x /usr/bin/winetricks

COPY init-install.sh /init-install.sh
COPY startapp.sh /startapp.sh

RUN chmod a+rx /startapp.sh /init-install.sh

RUN set-cont-env APP_NAME "Loxone Config"
