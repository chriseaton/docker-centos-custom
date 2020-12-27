#!/bin/bash 

if [ "$(whoami)" != "root" ]; then
    echo "Sorry, you are not root."
    exit 99
fi

# load config environment from file
if [ -f .env ]; then
    source .env
fi

###
# DOWNLOAD & INSTALL TO LOCAL DISK
###
# Create a folder for our new root structure
if [ -d "$CENTOS_ROOT" ]; then 
    echo "Root image directory already exists, packages will be upgraded from a previous build..."
    # rm -Rf $CENTOS_ROOT;
fi
mkdir -p $CENTOS_ROOT
CENTOS_ROOT=$(readlink -f $CENTOS_ROOT)

# initialize rpm database
rpm --root $CENTOS_ROOT --initdb

if [[ " $@ " =~ " --skip " ]]; then
    echo "Skipping download and install of release packages."
else
    # download and install the centos-release package, it contains our repository sources
    # grab the centos-release package appropriate to your architecture
    wget http://mirror.centos.org/centos/$CENTOS_VERSION/BaseOS/x86_64/os/Packages/$CENTOS_RELEASE_PACKAGE -O centos-release.rpm
    wget http://mirror.centos.org/centos/$CENTOS_VERSION/BaseOS/x86_64/os/Packages/$CENTOS_REPO_PACKAGE  -O centos-repos.rpm
    if [ ! -f ./centos-release.rpm ]; then
        echo "Failed to download centos-release rpm package."
        exit 97
    fi
    if [ ! -f ./centos-repos.rpm ]; then
        echo "Failed to download centos-repos rpm package."
        exit 96
    fi
    rpm --nodeps --root $CENTOS_ROOT -ivh centos-*.rpm
    rm centos-*.rpm
    dnf -y --installroot=$CENTOS_ROOT --nodocs install basesystem filesystem
fi

# configuration
printf "[main]\ntsflags=nodocs" >> $CENTOS_ROOT/etc/dnf/dnf.conf
tee -a $CENTOS_ROOT/etc/resolv.conf <<EOF
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

# SYSTEM CONFIGURATION
tee $CENTOS_ROOT/etc/sysctl.conf << EOF
# Increase size of file handles and inode cache
fs.file-max = 2097152
# fix nodejs watcher issue
fs.inotify.max_user_watches = 524288
# no swap in docker env
vm.swappiness = 0
vm.overcommit_memory = 1
EOF

# ssh prep
mkdir -p $CENTOS_ROOT/root/.ssh
touch $CENTOS_ROOT/root/.ssh/known_hosts
chmod 700 $CENTOS_ROOT/root/.ssh
chmod 644 $CENTOS_ROOT/root/.ssh/known_hosts
cp ./assets/entrypoint.sh $CENTOS_ROOT/root/
chmod 500 $CENTOS_ROOT/root/entrypoint.sh

# cleanup
dnf -y --installroot=$CENTOS_ROOT clean all

###
# BUILD DOCKER IMAGE
###
echo "Building docker image..."
tar -C $CENTOS_ROOT -c . | docker import - $DOCKER_REPOSITORY:slim \
    -c "WORKDIR /srv/" \
    -c "ENV IMAGE_VERSION=$IMAGE_VERSION" \
    -c "ENV IMAGE_OS_VERSION=$CENTOS_VERSION" \
    -c "ENV IMAGE_OS_DISTRO=CentOS" \
    -c "CMD [\"/bin/sh\", \"/root/entrypoint.sh\"]"
docker tag $(docker images --filter=reference=$DOCKER_REPOSITORY:slim --format "{{.ID}}") $DOCKER_REPOSITORY:$CENTOS_BASE_VERSION-slim
echo "Build complete."