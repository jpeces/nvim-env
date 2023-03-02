#!/bin/bash

## -- Global variables declaration -- ##
g_program_name=$(basename "$0")
g_config_dir="${HOME}/.config/nvim"
g_container_name="nvim-env"
g_image_name="nvim-env"
g_username="nvim"
g_force_build=0

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
Usage:  ${g_program_name} [OPTIONS]

Options:
      --name    string      Assign a name to the container (default: nvim-env)
  -i, --image   string      Name of the target docker image (default: nvim-env)
  -u, --user    string      User name used to build and access to the container (default: nvim)
  -d, --config  string      Host directory to mount as config (default: ${HOME}/.config/nvim)
  -b, --build               Force Docker image build stage (default: false)
  -h  --help                Show this help
EOF
}

# Arguments parsing function
function get_args() {
    local valid_args
    if ! valid_args=$(getopt -n "${g_program_name}" \
                    -o i:u:d:bh --long name:,image:,user:,config:,build,help \
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
            -u | --user)
                g_username=$2
                shift 2
                ;;
            -d | --config)
                g_config_dir=$2
                shift 2
                ;;
            -b | --build)
                g_force_build=1
                shift
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
}

function main() {
    get_args "$@"
    check_args

    local image_id=""
    local running=""
    local container_id=""

    ## -- Script logic -- ##

    # Check if there is a container running with the same name and get its ID
    running="$(docker ps -q)"
    if [[ "${running}" ]]; then
        container_id="$(docker inspect \
            --format="{{if eq (slice .Name 1) \"${g_container_name}\"}}{{slice .ID 0 12}}{{end}}" \
            ${running})"

        container_id=${container_id//$'\n'} # remove any \newline from the string variable

        if [[ "${container_id}" ]]; then
            log "[info] Container ${g_container_name} already running with id: ${container_id}"
            ! (( "${g_force_build}" )) && exit 0

            log "[info] Force build set. Stoping container id ${container_id}..."
            docker stop "${container_id}" > /dev/null 2>&1
        fi
    fi

    # Check if the image already exist. If not, creates it and remove all
    # posible dangling images created.
    image_id=$(docker images -q "${g_image_name}")
    if ! [[ "${image_id}" ]] || (( "${g_force_build}" )); then
        docker build -t "${g_image_name}" --build-arg USERNAME="${g_username}" .
        docker rmi "$(docker images -f "dangling=true" -q)" > /dev/null 2>&1
    fi

    container_id=$(docker run -it \
        --name "${g_container_name}" \
        --rm \
        --detach \
        --hostname "${HOSTNAME}" \
        --user "${g_username}" \
        --env DISPLAY="${DISPLAY}" \
        --env XDG_DATA_HOME=/home/"${g_username}"/.config/nvim/data \
        --volume "${g_config_dir}":/home/"${g_username}"/.config/nvim \
        --volume /tmp/.X11-unix:/tmp/.X11-unix \
        --volume "${HOME}"/.Xauthority:/home/"${g_username}"/.Xauthority \
        "${g_image_name}")

    log "[info] Container ${g_container_name} running with id: ${container_id::12}"
}

## -- Script execution --##
main "$@"
