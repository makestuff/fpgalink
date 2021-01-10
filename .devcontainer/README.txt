# Build the image
docker build --no-cache --progress=plain --tag makestuff:0.1 .

# Run the image
PROJ=makestuff/fpgalink  # or something else...
docker run -p 127.0.0.1:8080:8080/tcp --name makestuff-1 --user vscode -it makestuff:0.1 bash -l -c "cd; if [ ! -e workspace ]; then git clone --recursive https://github.com/${PROJ}.git workspace; fi; cd workspace; ./build.sh Debug -nobuild; code-server ."

# Reconnect
docker start -ai makestuff-1

# Check available containers
docker ps --all

# Connect
http://localhost:8080

# Destroy container
docker rm --force makestuff-1

# Destroy image
docker image rm makestuff:0.1
