# Android SDK in Docker

This is a fork of [thyrlian/AndroidSDK](https://github.com/thyrlian/AndroidSDK).

This README is a supplement to the original, which has been copied to
[README-UPSTREAM.md](README-UPSTREAM.md)

What follows is abbreviated steps to install/start/stop/destroy the
[plenuspyramis/android-sdk](https://hub.docker.com/r/plenuspyramis/android-sdk)
docker container.

## Deviations from upstream

The Dockefile is rebuilt to run as the `android` user instead of `root`. Sudo
priviliges are granted, so you can still do everything you used to do as root.
This fixes file permissions for sharing files between the host and container.

If your user account on the host is different than `1000` (the default first
user account on any system; check by running `echo $UID`) you can rebuild the
container image to use a custom `USER_ID` build argument:

```
sudo docker build -t plenuspyramis/android-sdk --build-arg USER_ID=$UID android-sdk
```

## Setup

This wraps all the docker commands into reusable bash aliases.

Put this in your `$HOME/.bashrc`. Ensure you change ANDROID_DOCKER to a real
path on your host where you would like to store the container files:

```
# Android Docker Config:
# github.com/PlenusPyramis/AndroidSDK
export ANDROID_DOCKER=$HOME/git/vendor/plenuspyramis/AndroidSDK/env
export ANDROID_DOCKER_CONTAINER=android-docker

alias android-docker-create-sdk-cache="sudo docker run --rm -it -v $ANDROID_DOCKER/sdk:/sdk plenuspyramis/android-sdk bash -c 'cp -a /opt/android-sdk/. /sdk'"

alias android-docker-start="sudo docker run -d --name $ANDROID_DOCKER_CONTAINER -v $ANDROID_DOCKER/sdk:/sdk -v $ANDROID_DOCKER/gradle_caches:/root/.gradle/caches plenuspyramis/android-sdk"

alias android-docker-stop="sudo docker stop $ANDROID_DOCKER_CONTAINER"
alias android-docker-destroy="sudo docker rm -f $ANDROID_DOCKER_CONTAINER"
alias android-docker-shell="sudo docker exec -it $ANDROID_DOCKER_CONTAINER /bin/bash"
```

### Command reference:

 * `android-docker-create-sdk-cache` - Create the SDK cache directory and copy the pre-downloaded SDK (inside the container image) to the host path `$ANDROID_DOCKER/sdk`. You need to do this only once.
 * `android-docker-start` - Create/Start container
 * `android-docker-stop` - Stop container
 * `android-docker-shell` - Connect to a shell for the running container
 
