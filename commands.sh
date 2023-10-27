#How to change docker root data directory
#The standard data directory used by docker is /var/lib/docker, and since this directory will store all your images, volumes, etc. it can become quite large in a relative small amount of time.

#1. Stop the docker daemon
sudo service docker stop

#2. Add a configuration file to tell the docker daemon what is the location of the data directory

#Create docker daemon configuration /etc/docker/daemon.json with following content:

{ 
   "data-root": "/path/to/your/new/docker/root"
}

#3. Copy the current data directory to the new one

sudo rsync -aP /var/lib/docker/ "/path/to/your/new/docker/root"

#4. Rename the old docker directory
sudo mv /var/lib/docker /var/lib/docker.old

#5. Restart the docker daemon
sudo service docker start


#download a existent image from docker hub
