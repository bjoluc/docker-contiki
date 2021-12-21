
FROM ubuntu:20.04

# Disable interactive prompts during installations with apt-get
ENV DEBIAN_FRONTEND="noninteractive"

USER root

RUN apt-get update

RUN apt-get install -y \
  build-essential \
  gcc-msp430 \
  git \
  openjdk-8-jdk \
  ant \
  sudo \
  openssh-server

# Use Java 8 by default (for Cooja)
RUN update-java-alternatives -s java-1.8.0-openjdk-amd64

RUN mkdir /contiki && chmod 777 /contiki

# Environment variables, based on https://github.com/contiki-ng/contiki-ng/blob/ea66afaa5777193494331d78d2570f954507ba92/tools/docker/Dockerfile
ENV HOME /home/user
ENV CONTIKI /contiki
ENV COOJA ${CONTIKI}/tools/cooja
ENV PATH="${HOME}:${PATH}"
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Append the above environment variables to /etc/environment so they are available in SSH sessions
RUN env | egrep "^(HOME=|CONTIKI=|COOJA=|PATH=|LC_ALL=|LANG=)" >> /etc/environment

# Create an executable script to start cooja
RUN echo '#!/bin/bash\njava -jar /contiki/tools/cooja/dist/cooja.jar -contiki=/contiki' > /usr/bin/cooja && \
  chmod +x /usr/bin/cooja

# Create a user
RUN useradd -md ${HOME} -s /bin/bash -g root -G sudo,dialout -u 1000 user && \
  echo 'user:user' | chpasswd && \
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Enable ssh
RUN echo "X11DisplayOffset 10" >> /etc/ssh/sshd_config
RUN echo "X11UseLocalhost no" >> /etc/ssh/sshd_config
RUN service ssh start

USER user

RUN git clone --recursive --branch 3.0 git://github.com/contiki-os/contiki.git ${CONTIKI}

# Include temperature sensor in sky makefile
RUN sed -i '3s;^;CONTIKI_TARGET_SOURCEFILES += temperature-sensor.c\n;' /contiki/platform/sky/Makefile.sky

# Apply git patch for Cooja fixes
COPY cooja.patch ${CONTIKI}
RUN cd ${CONTIKI} && git apply cooja.patch && rm cooja.patch

# Build Cooja
RUN cd ${COOJA} && ant jar

WORKDIR ${HOME}

EXPOSE 22

CMD ["sudo", "/usr/sbin/sshd", "-D"]
