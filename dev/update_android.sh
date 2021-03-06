#!/bin/sh

set -e
set -x

cd $(dirname $0)
. ./config.sh
cd ../tmp
APP_PATH=$(pwd)
CI_ANDROID_LIBVER=$(date +%Y%m%d-%H%M%S)
FILENAME=ci-android-sdk-linux-${CI_ANDROID_LIBVER}.tar.gz
rm -rf ci-android-*.tar.gz
tar czf $FILENAME android-sdk-linux/
scp $FILENAME root@${WEB_HOST}:${WEB_FSPATH}
DOTFILENAME=dot-android-${CI_ANDROID_LIBVER}.tar.gz
rm -rf dot-android-*.tar.gz
cd ~ && tar czf $APP_PATH/$DOTFILENAME .android
cd $APP_PATH/
scp $DOTFILENAME root@${WEB_HOST}:${WEB_FSPATH}
sed -i "s/ENV CATCH_ANDROID_LIBVER .\+/ENV CATCH_ANDROID_LIBVER ${CI_ANDROID_LIBVER}/" ../Dockerfile

