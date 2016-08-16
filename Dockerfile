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
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen

# Utils
RUN apt -y install curl wget
RUN apt -y install git
RUN apt -y install openssh-server
RUN apt install -y build-essential fakeroot


RUN useradd -m -d /home/builder -s /bin/bash builder && \
    echo "builder:builder" | chpasswd

RUN mkdir -p /root/.ssh && mkdir -p /home/builder/.ssh
COPY ssh-keys/* /root/.ssh/
COPY ssh-keys/* /home/builder/.ssh/
RUN chown -R builder: /home/builder/.ssh && chmod 600 /home/builder/.ssh/id_rsa || true


ENV CATCH_ANDROID_LIBVER 20160729-181506
COPY dev/config.sh config.sh
RUN . ./config.sh; mkdir -p /tmp && wget -O /tmp/latest-android-sdk.tgz http://$WEB_HOST$WEB_PATH/ci-android-sdk-linux-${CATCH_ANDROID_LIBVER}.tar.gz && cd /opt && tar xzf /tmp/latest-android-sdk.tgz && rm /tmp/latest-android-sdk.tgz && wget -O /tmp/dot-android.tgz http://$WEB_HOST$WEB_PATH/dot-android-${CATCH_ANDROID_LIBVER}.tar.gz && cd /home/builder && tar xvf /tmp/dot-android.tgz && chown -R builder: /home/builder/.android && rm -f /tmp/dot-android.tgz
ENV ANDROID_HOME /opt/android-sdk-linux

# Android things
RUN apt -y install openjdk-8-jdk
RUN apt -y install libc6:i386 lib32z1

# Node.js 6.x
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt install -y nodejs

RUN mkdir -p /srv/android-build-home/any && chmod 777 /srv/android-build-home/any
RUN mkdir -p /var/run/sshd

ENV PROXYCHAINS_VERHASH 8870140ff0d730c5c71c2170518c6c7957c4d68c
RUN cd /tmp && git clone https://github.com/rofl0r/proxychains-ng && cd proxychains-ng && git checkout $PROXYCHAINS_VERHASH && ./configure --prefix=/usr --sysconfdir=/etc && make -j 4 && make install && ln -s /usr/bin/proxychains4 /usr/bin/proxychains
COPY misc/proxychains.conf /etc/proxychains.conf
RUN . ./config.sh && echo $PROXY >> /etc/proxychains.conf


# Redis
ENV REDIS_VERSION 3.0.7
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-3.0.7.tar.gz
ENV REDIS_DOWNLOAD_SHA1 e56b4b7e033ae8dbf311f9191cf6fdf3ae974d1c

# for redis-sentinel see: http://redis.io/topics/sentinel
RUN buildDeps='gcc libc6-dev make' \
    && set -x \
    && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O redis.tar.gz "$REDIS_DOWNLOAD_URL" \
    && echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
    && mkdir -p /usr/src/redis \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && rm redis.tar.gz \
    && make -C /usr/src/redis \
    && make -C /usr/src/redis install \
    && rm -r /usr/src/redis \
    && apt-get purge -y --auto-remove $buildDeps

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
