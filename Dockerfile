# Catch-CI docker environmenT

FROM debian:jessie
MAINTAINER Senorsen <senorsen.zhang@gmail.com>

COPY misc/debian-sources.list /etc/apt/sources.list
RUN dpkg --add-architecture i386
RUN apt update && apt upgrade -y

ENV TZ Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

RUN apt -y install locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
COPY misc/locale /etc/default/locale


# Utils
RUN apt -y install curl wget
RUN apt -y install git
RUN apt -y install openssh-server

ENV CATCH_ANDROID_LIBVER 20160728-17191469697558
COPY dev/config.sh config.sh
RUN . ./config.sh; mkdir -p /tmp && wget -O /tmp/latest-android-sdk.tgz http://$WEB_HOST$WEB_PATH/ci-android-sdk-linux-${CATCH_ANDROID_LIBVER}.tar.gz && cd /opt && tar xzf /tmp/latest-android-sdk.tgz && rm /tmp/latest-android-sdk.tgz
ENV ANDROID_HOME /opt/android-sdk-linux

# Android things
RUN apt -y install openjdk-8-jdk
RUN apt -y install libc6:i386 lib32z1

# Node.js 6.x
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt install -y nodejs

RUN mkdir -p /srv/android-build-home/any && chmod 777 /srv/android-build-home/any
RUN mkdir -p /var/run/sshd

RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen
RUN apt install -y build-essential fakeroot

RUN useradd -m -d /home/builder -s /bin/bash builder &&\
    echo "builder:builder" | chpasswd

RUN mkdir -p /root/.ssh && mkdir -p /home/builder/.ssh
COPY ssh-keys/* /root/.ssh/
COPY ssh-keys/* /home/builder/.ssh/
RUN chown -R builder: /home/builder/.ssh

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
