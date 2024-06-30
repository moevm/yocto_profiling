### Hash server in Docker [INSTRUCTION]
1) Use ./build_docker_image_for_hash.sh to build the Docker image for the hash server.
2) Use ./start_hash.sh <port> to start a container with the hash server on port <port>.
3) Using ./manipulate_hash.sh 
  -  ./manipulate_hash.sh stop - stop all containers from step 1
  -  ./manipulate_hash.sh rm - remove all containers from step 1
  -  ./manipulate_hash.sh start - start containers that were stopped with ./manipulate_hash.sh stop


>[!NOTE]
> I recommend transferring the entire current directory from the target build PC to the hash server PC using the scp utility.
