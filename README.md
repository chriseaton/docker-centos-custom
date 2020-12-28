# CentOS Slim
A custom slim docker image based on CentOS. Built from the base packages. This includes the base system and file system
support, but essentially no tooling, including _no_ package manager. 

Currently as of the latest compiled release (CentOS v`8.3`), the image size is `76MB` (`257MB` uncompressed).

If you need _any_ tooling consider using the [chriseaton/centos](https://hub.docker.com/r/chriseaton/centos):`latest` image. 

## Notable Differences
This image has a few differences from the base installation from CentOS. These may or may not appeal to you so be sure
to review the following before utilizing this image.

- Docker-friendly changes were made to `/etc/sysctl.conf`.
- The `nodocs` flag is set in the `dnf` configuration to reduce download sizes of packages within the container.
- An `.ssh/` directory is created for the root account. However, the `openssh-clients` package is _**not**_ installed.
- The default working directory is `/srv/`.
- An empty `.started` file is created upon first startup of the container via the docker entrypoint.    
  If you start the container with a command other than the default, the entrypoint script is not run.
- The `/etc/resolv.conf` has been updated to point to both CloudFlare and Google's public DNS nameservers: `1.1.1.1`, `1.0.0.1`, `8.8.8.8`, and `8.8.4.4`.
- The following environmental variables are set in the container:
  - `IMAGE_VERSION` The version of the docker image (not the OS).
  - `IMAGE_OS_VERSION` The long-form version of CentOS the image was built with.
  - `IMAGE_OS_DISTRO` This will always be "`CentOS`".

# Development
Before building, running, or publishing locally, create a `.env` file locally and define the following environmental variables:

```
BASE_VERSION=1.0.0
DOCKER_REPOSITORY=chriseaton/centos
CENTOS_BASE_VERSION=8
CENTOS_VERSION=8.3.2011
CENTOS_RELEASE_PACKAGE=centos-linux-release-8.3-1.2011.el8.noarch.rpm
CENTOS_REPO_PACKAGE=centos-linux-repos-8-2.el8.noarch.rpm
CENTOS_ROOT=image/rootfs
```
You can find repository packages on the http://mirror.centos.org/centos/ website. Packages are found under the
`BaseOS/x86_64/os/Packages/` path.

Please note, this build process relies on the presence of `dnf` on your system, so _you must be running_ CentOS, RHEL, or a variant (untested).

## Building
Simply run the build script and the image will be created. 
```
sudo ./build.sh
```

## Publishing
To push to a registry, you can run the `publish.sh` script.