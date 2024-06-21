### Hash server in Docker [INSTRUCTION]
1) Use ./build_docker_image_for_hash.sh to build the Docker image for the hash server.
2) Use ./start_hash.sh <port> to start a container with the hash server on port <port>.
3) Use ./stop_hash.sh to stop and remove all containers created from the image built in step 1.

>[!NOTE]
> I recommend transferring the entire current directory from the target build PC to the hash server PC using the scp utility.
