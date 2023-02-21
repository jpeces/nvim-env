CONFIG_DIR=/home/jpeces/temp/nvim
IMAGE_NAME=nvim-env
CONTAINER_NAME=nvim-env
SSH_PORT=5000

if [[ $# == 0 ]]; then
    echo "[INFO] Using default configuration"
elif [ "$1" ] && [ "$2" ]; then
    CONTAINER_NAME = $1
    IMAGE_NAME = $1
    CONFIG_DIR = $2
fi

IMAGE_ID=`docker images --format "{{if eq .Repository \"${IMAGE_NAME}\"}}{{.ID}}{{end}}"`
if [ -z ${IMAGE_ID} ]; then
    docker build -t ${IMAGE_NAME} --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" .
fi


CONTAINER_ID=`docker inspect --format="{{if eq (slice .Name 1) \"${IMAGE_NAME}\"}}{{slice .ID 0 12}}{{end}}" $(docker ps -q)`
if [ ${CONTAINER_ID} ]; then
    echo "[INFO] Container ${CONTAINER_NAME} already running with id: ${CONTAINER_ID:1}"
    exit 0
fi

CONTAINER_ID=`docker run --name ${CONTAINER_NAME} --rm  -d -p ${SSH_PORT}:22 -v ${CONFIG_DIR}:/root/.config/nvim ${IMAGE_NAME}`
echo "[INFO] Container ${CONTAINER_NAME} running with id: ${CONTAINER_ID:1:11}"
