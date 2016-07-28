# Catch-CI docker environmenT

FROM debian:jessie

RUN dpkg --add-architecture i386
RUN apt update && apt upgrade -y

# Utils
RUN apt -y install curl wget
RUN apt -y install git

ENV CATCH_ANDROID_LIBVER 20160728-17191469697558
RUN . dev/config.sh; mkdir -p tmp && wget -O tmp/latest-android-sdk.tgz http://$WEB_HOST$WEB_PATH/ci-android-sdk-linux-${CATCH_ANDROID_LIBVER}.tar.gz
ADD tmp/latest-android-sdk.tgz /opt
ENV ANDROID_HOME /opt/android-sdk-linux

# Android things
RUN apt -y install openjdk-8-jdk
RUN apt -y install libc6:i386 lib32z1

# Node.js 6.x
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt install -y nodejs


