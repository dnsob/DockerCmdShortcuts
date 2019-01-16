#!/bin/bash

##########################
# Author: Dennis Sobczak #
##########################

export option=$1

export image_name=$2
export container_name=$2

export user_name=$3
export host_address=$4

export dockerfile_path=$3


function pullDockerImage()
{
   echo "Pulling latest docker image: $image_name"
   /usr/bin/docker pull $image_name
   echo "Pull DONE."
}

function pullDockerImageWithVersion()
{
   echo "Pulling version of docker image: $image_name"
   /usr/bin/docker pull $image_name:$image_version
   echo "Pull DONE."
}

function removeDockerImageByName()
{
   echo "Removing Docker image: $image_name"
   /usr/bin/docker rmi -f $image_name
   echo "Successfully removed image."
   /usr/bin/docker images
}

function removeDockerContainerByName()
{
   echo "Stopping Docker container: $container_name"
   /usr/bin/docker stop $container_name
   echo "Removing Docker container: $container_name"
   /usr/bin/docker rm $container_name
   echo "Successfully removed container."
   /usr/bin/docker ps -a
}

function exportDockerImageByName()
{
   echo "Exporting image: $image_name"
   /usr/bin/docker save -o /tmp/$image_name.tar $image_name
   #/usr/bin/docker export --output="$image_name.tar" $image_name
   echo "Image export DONE."
}

function importDockerImageByName()
{
   echo "Importing image: $image_name"
   /usr/bin/docker load -i $image_name
   #/usr/bin/docker import $image_name
   echo "Import DONE."
}

function importDockerImageByNameToRemoteHost()
{
   echo "Exporting, compressing and transfering image $image_name to remote host $host_address"
   /usr/bin/docker save $image_name | bzip2 | pv | ssh $user_name@$host_address 'bunzip2 | docker load'
   echo "DONE."
}

function buildDockerImageFromDockerFile()
{
   echo "Building image from Dockerfile in path $dockerfile_path"
   /usr/bin/docker build -t $image_name $dockerfile_path
   echo "DONE."
}

function main(){
   echo "Running Docker Handler"
   case $option in
   "-rc")
       echo "Remove container: $container_name"
       removeDockerContainerByName
       ;;
   "-ri")
       echo "Remove image: $image_name"
       removeDockerImageByName
       ;;
   "-ei")
       echo "Export image: $image_name"
       exportDockerImageByName
       ;;
   "-ii")
       echo "Import image: $image_name"
       importDockerImageByName
       ;;
   "-ti")
       echo "Transfer image $image_name to dest $host_address"
       importDockerImageByNameToRemoteHost
       ;;
   "-bi")
       echo "Build image from $dockerfile_path"
       buildDockerImageFromDockerFile
       ;;
   esac
}

main
