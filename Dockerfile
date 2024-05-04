FROM ubuntu:lunar

RUN DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y wget && \
  mkdir -p /etc/apt/keyrings; \ 
  wget -q -O /etc/apt/keyrings/mopidy-archive-keyring.gpg \ 
    https://apt.mopidy.com/mopidy.gpg \
  && wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/bullseye.list

RUN DEBIAN_FRONTEND=noninteractive && apt-get update && \
  apt-get install -y python3 python3-pip && \
  apt-get install -y libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav \
    gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl \
    gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio

#Let's try this: MAKE sure you're config file is updated
RUN DEBIAN_FRONTEND=noninteractive && pip3 install --break-system-packages yt-dlp

# This works, but youtube-dl fails to load the file:
#RUN pip3 install --break-system-packages --upgrade youtube-dl

# Official youtube-dl installation process is blocked due to legal reasons
#RUN wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl && chmod a+rx /usr/local/bin/youtube-dl

# Change from here?...
RUN DEBIAN_FRONTEND=noninteractive && apt-get -y install mopidy \
  && pip3 install --break-system-packages mopidy-youtube

RUN mkdir -p /var/lib/mopidy/.config \
 && ln -s /config /var/lib/mopidy/.config/mopidy
#                            /root/.config/mopidy/mopidy.conf

# This is insane, there are incredible amount of issues with this mopidy / mopidy-youtube requirments!!
# See: https://github.com/mikf/gallery-dl/issues/4729#issuecomment-1781938030
RUN mkdir -p /opt/homebrew/lib/python3.11/site-packages/yt_dlp; mkdir -p /opt/homebrew/lib/python3.11/site-packages/yt_dlp /opt/homebrew/lib/python3.12/site-packages; ln -s /opt/homebrew/lib/python3.11/site-packages/yt_dlp /opt/homebrew/lib/python3.12/site-packages

# Default configuration.
COPY mopidy.conf /config/mopidy.conf
# Copy the pulse-client configuratrion.
# COPY pulse-client.conf /etc/pulse/client.conf

RUN mopidy --version

#VOLUME ["/var/lib/mopidy/local", "/var/lib/mopidy/media"]

EXPOSE 6600 6680 5555/udp

#ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint.sh"]
ENTRYPOINT ["mopidy"]
#CMD ["--config /config/mopidy.conf"]

HEALTHCHECK --interval=5s --timeout=2s --retries=20 \
    CMD curl --connect-timeout 5 --silent --show-error --fail http://localhost:6680/ || exit 1

RUN apt-get install -y mopidy-mpd mopidy-local
RUN pip3 install --break-system-packages Mopidy-Iris

COPY mopidy.conf /config/mopidy.conf