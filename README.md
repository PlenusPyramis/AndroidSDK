# PlenusPyramis Android SDK in Docker

This is a fork of [thyrlian/AndroidSDK](https://github.com/thyrlian/AndroidSDK).

This README is a supplement to the original, which has been copied to
[README-UPSTREAM.md](README-UPSTREAM.md)

What follows is abbreviated steps to install/start/stop/destroy the
[plenuspyramis/android-sdk](https://hub.docker.com/r/plenuspyramis/android-sdk)
docker container.

## Setup

This wraps all the docker commands into reusable bash aliases.

Put this in your `$HOME/.bashrc`. Ensure you change ANDROID_DOCKER to a real
path on your host where you would like to store the container files:

```
# Android Docker Config:
# github.com/PlenusPyramis/AndroidSDK
export ANDROID_DOCKER=$HOME/git/vendor/plenuspyramis/AndroidSDK
export ANDROID_DOCKER_IMAGE=plenuspyramis/android-sdk:latest-vnc
export ANDROID_DOCKER_CONTAINER=android-docker

alias android-docker-create-sdk-cache='sudo docker run --rm -it -v $ANDROID_DOCKER/sdk:/sdk $ANDROID_DOCKER_IMAGE bash -c "sudo cp -a /opt/android-sdk/. /sdk && sudo chown -R android:android /sdk"'

alias android-docker-start="if sudo docker ps -a | grep $ANDROID_DOCKER_CONTAINER > /dev/null; then sudo docker start $ANDROID_DOCKER_CONTAINER; else sudo docker run -d --name $ANDROID_DOCKER_CONTAINER -v $ANDROID_DOCKER/sdk:/sdk -v $ANDROID_DOCKER/gradle_caches:/root/.gradle/caches -p 127.0.0.1:5901:5901 $ANDROID_DOCKER_IMAGE; fi;"

alias android-docker-stop='sudo docker stop $ANDROID_DOCKER_CONTAINER'
alias android-docker-destroy='sudo docker rm $ANDROID_DOCKER_CONTAINER'
alias android-docker-shell='sudo docker exec -it $ANDROID_DOCKER_CONTAINER /bin/bash'
alias android-docker-vnc='if ! which vncviewer > /dev/null; then echo "You must install vncviewer" && exit 1; else vncviewer 127.0.0.1:1; fi'
```

### Command reference:

 * `android-docker-create-sdk-cache` - Create the SDK cache directory and copy
   the pre-downloaded SDK (inside the container image) to the host path
   `$ANDROID_DOCKER/sdk`. You only need to do this once.

 * `android-docker-start` - Start/Create the `android-docker` container. (The
   name is configurable by setting `ANDROID_DOCKER_CONTAINER`, see above.)

 * `android-docker-stop` - Stop the container.

 * `android-docker-shell` - Connect to a shell inside the running container.

 * `android-docker-vnc` - Connect to the vnc server running in the container
   (must have `vncviewer` installed on host.) Default password is `android`.

 * `android-docker-destroy` - destroy the stopped container. (add `-f` to stop
   and destroy the running container.)

## Building images

If you want to use the `plenuspyramis/android-sdk` image from the docker hub,
skip this section. This section will help you build your own images if you need
to make customizations.

There are two `Dockerfiles`: 

 * `android-sdk/Dockerfile` - the main base image. (builds
   `plenuspyramis/android-sdk:latest`)
 * `android-sdk/vnc/Dockerfile` - the VNC server which builds upon the base
   image. (builds `plenuspyramis/android-sdk:latest-vnc`)

This fork of `thyrlian/android-sdk` is reworked to run as the `android` user
instead of `root`. Sudo priviliges are granted to the `android` user, so you can
still do everything that still needs `root`. This fixes file permissions for
sharing files between the host and container.

### Build the base image:

From the same directory as this README, run this to build the base image:

```
sudo docker build -t android-sdk:local --build-arg USER_ID=$UID android-sdk
```

The `USER_ID` argument is necessary to fix permissions for files mounted from
the host to the conatiner. `$UID` (check it by running `echo $UID`) is your
current host user account's user id. Your user id is usually `1000` on a
computer with only one user account. Passing it into the build will ensure the
image is built giving the `android` user inside the container the same user id
that your account on the host uses.

### Build the vnc image:

From the same directory as this README, run this to build the vnc image:

```
sudo docker build -t android-sdk:local-vnc --build-arg BASE_IMAGE=android-sdk:local android-sdk/vnc
```

The new image will be called `android-sdk:local-vnc`. Update the
`ANDROID_DOCKER_IMAGE` variable that you earlier put in your `$HOME/.bashrc`,
change it **from** `plenuspyramis/android-sdk:latest-vnc` **to** `android-sdk:local-vnc`. 

Make sure you reload your terminal session to reload the aliases from
`$HOME/.bashrc`.

Run `android-docker-destroy` to delete the old container.

Finally, run `android-docker-start` to create a new container using your new
image.
