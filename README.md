# PlenusPyramis Android SDK in Docker

This is a fork of [thyrlian/AndroidSDK](https://github.com/thyrlian/AndroidSDK).
This sets up an environment to develop and build android apps inside of a
preconfigured docker container.

This README is a supplement to the original, which has been copied to
[README-UPSTREAM.md](README-UPSTREAM.md)

What follows is abbreviated steps to install/start/stop/destroy the
[plenuspyramis/android-sdk](https://hub.docker.com/r/plenuspyramis/android-sdk)
docker container.

## Setup

This wraps all the docker commands into reusable bash aliases.

Ensure your user account has `sudo` priviliges.

Put this in your `$HOME/.bashrc`. Ensure you change `ANDROID_DOCKER` to a real
path on your host where you have this repository cloned:

```
# Android Docker Config:
# https://www.github.com/PlenusPyramis/AndroidSDK
export ANDROID_DOCKER=$HOME/git/vendor/plenuspyramis/AndroidSDK
export ANDROID_DOCKER_IMAGE=plenuspyramis/android-sdk
export ANDROID_DOCKER_CONTAINER=android-docker
alias android-docker-create-sdk-cache='sudo docker run --rm -it -v $ANDROID_DOCKER/sdk:/sdk $ANDROID_DOCKER_IMAGE bash -c "sudo cp -a /opt/android-sdk/. /sdk && sudo chown -R android:android /sdk"'
alias android-docker-start="if sudo docker ps -a | grep $ANDROID_DOCKER_CONTAINER > /dev/null; then sudo docker start $ANDROID_DOCKER_CONTAINER; else sudo docker run -d --name $ANDROID_DOCKER_CONTAINER -v $ANDROID_DOCKER/sdk:/sdk -v $ANDROID_DOCKER/gradle_caches:/home/android/.gradle/caches -p 127.0.0.1:5901:5901 $ANDROID_DOCKER_IMAGE; fi;"
alias android-docker-stop='sudo docker stop $ANDROID_DOCKER_CONTAINER'
alias android-docker-destroy='sudo docker rm $ANDROID_DOCKER_CONTAINER'
alias android-docker-shell='sudo docker exec -it $ANDROID_DOCKER_CONTAINER /bin/bash'
alias android-docker-vnc='if ! which vncviewer > /dev/null; then echo "You must install vncviewer" && exit 1; else vncviewer 127.0.0.1:1; fi'
```

Once you have saved `$HOME/.bashrc`, restart your terminal to reload it.

### Command reference:

 * `android-docker-create-sdk-cache` - Create the SDK cache directory and copy
   the pre-downloaded SDK (inside the container image) to the host path
   `$ANDROID_DOCKER/sdk`. You only need to do this once.

 * `android-docker-start` - Start/Create the `android-docker` container. (The
   name is configurable by setting `ANDROID_DOCKER_CONTAINER`, see above.)

 * `android-docker-stop` - Stop the container.

 * `android-docker-shell` - Connect to a shell inside the running container.

 * `android-docker-vnc` - Connect to the vnc server running in the container
   (must have `vncviewer` installed on host.) Default password is `android`. You
   can change the vnc password by creating your own image and using the
   `VNC_PASSWORD` and `VNC_PASSWORD_VIEW_ONLY` build arguments.

 * `android-docker-destroy` - destroy the stopped container. (add `-f` to stop
   and destroy the running container.)

## Android development mini-tutorial



## Building images

If you want to use the `plenuspyramis/android-sdk` image from the docker hub,
skip this section. This section will help you build your own images if you need
to make customizations.

This fork of `thyrlian/android-sdk` is reworked to run as the `android` user
instead of `root`. Sudo priviliges are granted to the `android` user, so you can
still do everything that still needs `root`. This fixes file permissions for
sharing files between the host and container.

There is a [single multi-stage Dockerfile](android-sdk/Dockerfile) to build the
base image and the vnc server image.

### Build the image:

```
sudo docker build -t android-sdk:local \
  --build-arg USER_ID=$UID \
  --build-arg VNC_PASSWORD=android \
  --build-arg VNC_PASSWORD_VIEW_ONLY=docker \
  $ANDROID_DOCKER/android-sdk
```

The `USER_ID` argument is necessary to fix permissions for files mounted from
the host to the container. `$UID` is your current host user account's user id
(check it by running `echo $UID`). Your user id is usually `1000` on a computer
with only one user account. Passing `--build-arg USER_ID=$UID` into the build
command will ensure the image is built giving the `android` user inside the
container the same user id as that of your user account on the host.

`VNC_PASSWORD` and `VNC_PASSWORD_VIEW_ONLY` are used to set the passwords for
the vnc server.

Your new customized image will be called `android-sdk:local`. Update the
`ANDROID_DOCKER_IMAGE` variable that you earlier put in your `$HOME/.bashrc`,
change it **from** `plenuspyramis/android-sdk` **to** `android-sdk:local`.

Make sure you reload your terminal session to reload the aliases from
`$HOME/.bashrc`.

Run `android-docker-destroy` to delete the old container.

Finally, run `android-docker-start` to create a new container using your new
image.
