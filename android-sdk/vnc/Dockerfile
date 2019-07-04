# ====================================================================== #
# Android SDK Docker Image (VNC enabled)
# ====================================================================== #

# Base image
# ---------------------------------------------------------------------- #
FROM plenuspyramis/android-sdk:latest

# Author
# ---------------------------------------------------------------------- #
LABEL maintainer "ryan@enigmacurry.com"

# install and configure VNC server
ARG VNC_PASSWORD="android"
ARG VNC_PASSWORD_VIEW_ONLY="docker"
ENV USER android
ENV DISPLAY :1
EXPOSE 5901
ADD vncpass.sh /tmp/
ADD watchdog.sh /usr/local/bin/
ADD supervisord_vncserver.conf /etc/supervisor/conf.d/
RUN sudo apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive sudo -E apt-get install -y --no-install-recommends xfce4 xfce4-goodies xfonts-base dbus-x11 tightvncserver expect && \
    sudo chmod +x /tmp/vncpass.sh; sudo sync && \
    VNC_PASSWORD=${VNC_PASSWORD} VNC_PASSWORD_VIEW_ONLY=${VNC_PASSWORD_VIEW_ONLY} /tmp/vncpass.sh && \
    sudo rm /tmp/vncpass.sh && \
    sudo apt-get remove -y expect && sudo apt-get autoremove -y && \
    mkdir -p /home/android/.ssh && \
    FILE_SSH_ENV="/home/android/.ssh/environment" && \
    echo "DISPLAY=:1" >> $FILE_SSH_ENV

CMD ["sudo", "/usr/bin/supervisord"]
