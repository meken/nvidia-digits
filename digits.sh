#!/bin/bash

NVIDIA_DRIVER_VERSION=384.59
NVIDIA_DOCKER_VERSION=1.0.1
DOCKER_VERSION=17.06.0~ce-0~ubuntu

# Admin user
USER=$1

# Getting ready for the NVIDIA driver installation
apt-get update && apt-get install -y build-essential

# Download & install the NVIDIA driver
wget -P /tmp http://us.download.nvidia.com/XFree86/Linux-x86_64/$NVIDIA_DRIVER_VERSION/NVIDIA-Linux-x86_64-$NVIDIA_DRIVER_VERSION.run
chmod u+x /tmp/NVIDIA-Linux*.run
/tmp/NVIDIA-Linux*.run --silent

# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update && apt-get install -y docker-ce="$DOCKER_VERSION"

# Assuming that docker is already installed, install nvidia-docker and nvidia-docker-plugin
wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v$NVIDIA_DOCKER_VERSION/nvidia-docker_$NVIDIA_DOCKER_VERSION-1_amd64.deb
dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb

# Allow the admin user to run docker without sudo
usermod -aG docker $USER

BASE_DIR=/home/$USER
sudo -u $USER mkdir -p $BASE_DIR/data/

# Sometimes it takes a while before the nvidia-docker is running, waiting for it before creating the volume
while [ ! -S /var/lib/nvidia-docker/nvidia-docker.sock ]
do
	echo $(date) "Waiting for nvidia-docker to start..."
	sleep 3
done

echo $(date) "Socket found"

# Create the nvidia volume to prevent issues later, see https://github.com/NVIDIA/nvidia-docker/issues/112
docker volume create -d nvidia-docker --name nvidia_driver_$NVIDIA_DRIVER_VERSION

# Start the DIGITS server
nvidia-docker run --name digits -d -p 80:5000 -v $BASE_DIR/data/:/data/ nvidia/digits:6.0-rc

# Sample MNIST data
nvidia-docker exec -d digits python -m digits.download_data mnist /data/mnist

