# INSTALL DOCKER

Install Docker Engine on Ubuntu

OS requirements
To install Docker Engine, you need the 64-bit version of one of these Ubuntu versions:

Ubuntu Lunar 23.04
Ubuntu Kinetic 22.10
Ubuntu Jammy 22.04 (LTS)
Ubuntu Focal 20.04 (LTS)

1. Uninstall old versions

Before you can install Docker Engine, you need to uninstall any conflicting packages.

Distro maintainers provide unofficial distributions of Docker packages in APT. You must uninstall these packages before you can install the official version of Docker Engine.

The unofficial packages to uninstall are:

docker.io
docker-compose
docker-compose-v2
docker-doc
podman-docker
Moreover, Docker Engine depends on containerd and runc. Docker Engine bundles these dependencies as one bundle: containerd.io. If you have installed the containerd or runc previously, uninstall them to avoid conflicts with the versions bundled with Docker Engine.

Run the following command to uninstall all conflicting packages:

```
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```
2. Set up Docker's apt repository.

```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

3. install latest version 


```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

```

4. Verify that the Docker Engine installation is successful by running the hello-world image.

```
sudo docker run hello-world
```

# CONFIGURE DOCKER

* **A. add sudo privilages**

The docker user group exists but contains no users, which is why you’re required to use sudo to run Docker commands. Continue to Linux postinstall to allow non-privileged users to run Docker commands and for other optional configuration steps.

1. Create the docker group.

```
sudo groupadd docker

```

2. Add your user to the docker group.

```
sudo usermod -aG docker $USER

```

4. activate the changes to groups

```
newgrp docker

```



---

* **B. change docker root data directory (untested)**

ATTENTION: docker folder doesn't work in NTFS or FAT32 partition type

The standard data directory used by docker is /var/lib/docker, and since this directory will store all your images, volumes, etc. it can become quite large in a relative small amount of time.

1. Stop the docker daemon

```
systemctl stop docker.socket
systemctl stop docker.service
sudo service docker stop
```

2. Add a configuration file to tell the docker daemon what is the location of the data directory. Create docker daemon configuration /etc/docker/daemon.json with following content:

```
{ 
   "data-root": "/path/to/your/new/docker/root"
}

```

3. Copy the current data directory to the new one

```
sudo rsync -aP /var/lib/docker/ "/path/to/your/new/docker/root"
```

5. Restart the docker daemon

```
sudo service docker start
```


# DOCKER USAGE

**A. Download a docker image from dockerhub**

```
sudo docker pull rocker/rstudio:4.3.1
```

>4.3.1: Pulling from rocker/rstudio
aece8493d397: Pull complete 
6e4412f9416b: Pull complete 
586b4a75d153: Pull complete 
6595be516dd1: Pull complete 
f56aa2b4fd78: Pull complete 
a6e5da540919: Pull complete 
1c96bb42958e: Pull complete 
73f1bc709c60: Pull complete 
Digest: sha256:735f4afb09d7de93c902ad0a0a6cb7e2be1ddd961576963da63236f8b1e83e1c
Status: Downloaded newer image for rocker/rstudio:4.3.1
docker.io/rocker/rstudio:4.3.1
 
Verify that docker image is downloaded correctly

```
sudo docker images
```

> REPOSITORY       TAG       IMAGE ID       CREATED      SIZE
rocker/rstudio   4.3.1     d9db9fc3ad15   5 days ago   1.98GB

**B. Use the docker iteractively**

```
sudo docker run -it rocker/rstudio:4.3.1 /bin/bash
```

try to install a R package inside the container

start R from bash

```
R
```

install a package

```

if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("edgeR")


```

load tha package

```
library ("edgeR")
```

exit from container

```
quit()
exit
```

When you close a container all changes contained inside the container aren't saved inside the docker image.
However, it is possible to create a new image from the previously closed container.

first of all we need to find in CONTAINER ID of container of interest

```
sudo docker ps -a
```
> CONTAINER ID   IMAGE                  COMMAND       CREATED          STATUS                        PORTS     NAMES
551225187df9   rocker/rstudio:4.3.1   "/bin/bash"   21 minutes ago   Exited (0) 14 minutes ago               exciting_morse

it's possible to explore the log of container

```
sudo docker logs 551225187df9
```

after that we can make new image from container

```
sudo docker commit 551225187df9 edger:0.0.1
```

verify the state of images

```
sudo docker images 
```

> REPOSITORY       TAG       IMAGE ID       CREATED              SIZE
edgeR            0.0.1     6c3a86057552   About a minute ago   2.01GB
rocker/rstudio   4.3.1     d9db9fc3ad15   5 days ago           1.98GB

**C. Use Docker in non iteractive way**

This is the best way to use Docker while maintaining the highest level of reproducibility.

1. make dockerfile

```
mkdir ~/dockertest
cd ~/dockertest
nano 
```

In the Dockerfile, we can specify all the requirements and commands that Docker should execute during the build of a new Docker image.

With the **FROM** statement, we can define a base image from an existing one, such as a specific OS image.

With the **RUN** statement, we can execute command-line instructions during the image build process.

With the **CMD** command, we can specify the command that is executed each time we run a container using that image.

```
FROM rocker/r-ver:4.3.1

#install requirements
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libncurses5-dev

#install edgeR inside R environment
RUN R -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager'); BiocManager::install('edgeR')"

#run R when run the container
CMD ["R"]

```

At this point, we can now build our Dockerfile into an image.

```
sudo docker build --no-cache --progress=plain -t lucidif/edgeR:0.0.1 .
```

**3. operations on images**

When we have the image on this we can do a lot of thinks !

we can copy image

```
sudo docker image tag 6c3a86057552 bck_edgeR:0.0.1
```

we can erase it

```
sudo docker rmi -f fc3f24fce8cf
```

we can save our image as file tarball

```
docker save -o edgeR_0_0_1.tar lucidif/edgeR:0.0.1
```

and load a tarball inmage with

```
docker load -i myimage.tar
```

or we can push on dockerhub our image

```
sudo docker push lucidif/edgeR:0.0.1
```








