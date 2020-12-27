# CentOS Slim
A custom slim docker image based on CentOS. Built from the base packages. This includes the base system and file system
support, but minimal tooling. 

Currently as of the latest compiled release (CentOS v`8.3`), the image size is 266MB.

## Notable Differences
This image has a few differences from the base installation from CentOS. These may or may not appeal to you so be sure
to review the following before utilizing this image.

- The following additional packages are included:
  - `nano` - Text editor.
- The `/etc/resolv.conf` has been updated to point to Google's public DNS nameservers `8.8.8.8` and `8.8.4.4`.
- Docker-friendly changes were made to `/etc/sysctl.conf`.
- An `.ssh/` directory is created for the root account. However, the `openssh-clients` package is _**not**_ installed.
- The default working directory is `/srv/`.
- An empty `.started` file is created upon first startup of the container via the docker entrypoint.    
  If you start the container with a command other than the default, the entrypoint script is not run.

# Development
Before building, running, or publishing locally, create a `.env` file locally and define the following environmental variables:

```
BASE_VERSION=1.0.0
DOCKER_REPOSITORY=chriseaton/centos
CENTOS_VERSION=8
CENTOS_RELEASE_PACKAGE=centos-linux-release-8.3-1.2011.el8.noarch.rpm
CENTOS_REPO_PACKAGE=centos-linux-repos-8-2.el8.noarch.rpm
CENTOS_ROOT=image/rootfs
```
You can find repository packages on the http://mirror.centos.org/centos/$CENTOS_VERSION/BaseOS/x86_64/os/Packages/ website (note the CENTOS_VERSION must be changed out).

## Building
Simply run the build script and the image will be created. 
```
sudo ./build.sh
```

## Publishing
To push to a registry, you can run the `publish.sh` script.