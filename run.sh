#!/bin/bash

## -- Global variables declaration -- ##
g_program_name=$(basename "$0")
g_config_dir="${HOME}/.config/nvim"
g_container_name="nvim-env"
g_image_name="nvim-env"
g_ssh_port=5000

# Print message
function log() {
    printf '%s\n' "$1" >&2
}

# Print message and exit with error code
function die() {
    printf "%s\n" "$1" >&2
    exit 1
}

# Print help information
function show_help() {
cat <<-EOF
Usage:  ${g_program_name} [OPTIONS] IMAGE

Options:
      --name            Assign a name to the container (default: nvim-env)
  -i, --image string    Name of the target docker image (default: nvim-env)
  -p, --port uint16     Host port where the container's ssh service will be published (default: 5000)
  -d, --config          Host directory to mount as config (default: ${HOME}/.config/nvim)
  -h  --help            Show this help
EOF
}

# Arguments parsing function
function get_args() {
    local valid_args
    if ! valid_args=$(getopt -n "${g_program_name}" \
                    -o i:p:d:h --long name:,image:,port:,config:,help \
                    -- "$@"); then
        exit 1;
    fi

    eval set -- "${valid_args}"
    while true; do
        case $1 in
            -h | --help)
                show_help
                exit
                ;;
            --name)
                g_container_name=$2
                shift 2
                ;;
            -i | --image)
                g_image_name=$2
                shift 2
                ;;
            -p | --port)
                g_ssh_port=$2
                shift 2
                ;;
            -d | --config)
                g_config_dir=$2
                shift 2
                ;;
            --) # End of all options.
                shift; break
                ;;
            *) # Default case: No more options, so break out of the loop.
                break
        esac
    done
}

function check_args() {
    # Check if g_config_dir directory exists.
    if ! [[ -e "${g_config_dir}" ]]; then
        die "[error] ${g_config_dir} directory doesn't exit"
    fi

    # Check if --port value is an unsigned number
    if ! [[ ${g_ssh_port} =~ ^[0-9]+$ ]] ; then
       die "[error] --port value (${g_ssh_port}) must be an unsigned number. See --help"
    fi
}

function main() {
    get_args "$@"
    check_args

    local image_id=""
    local running=""
    local container_id=""

    ## -- Script logic -- ##

    # Check if the image already exist. If not, creates it
    image_id=$(docker images --format "{{if eq .Repository \"${g_image_name}\"}}{{.ID}}{{end}}")
    if [ -z "${image_id}" ]; then
        docker build -t "${g_image_name}" --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" docker/
    fi

    # Check if there is a container running with the same name and get its ID
    running=$(docker ps -q)
    if [[ "${running}" ]]; then
        container_id=$(docker inspect --format="{{if eq (slice .Name 1) \"${g_container_name}\"}}{{slice .ID 0 12}}{{end}}" $running)
    fi

    if [ "${container_id}" ]; then
        log "[info] Container ${g_container_name} already running with id: ${container_id}"
        exit 0
    fi

    container_id=$(docker run --name "${g_container_name}" --rm  -d -p "${g_ssh_port}":22 -v "${g_config_dir}":/root/.config/nvim "${g_image_name}")
    log "[info] Container ${g_container_name} running with id: ${container_id::12}"

}

## -- Script execution --##
main "$@"
