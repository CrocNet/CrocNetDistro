#!/bin/bash


#Defaults
ROOTFS="rootfs"

# Check if whiptail is installed
if ! command -v whiptail &> /dev/null; then
    echo "whiptail is not installed."

    # Check if apt is available
    if command -v apt &> /dev/null; then
        echo "Attempting to install whiptail using apt..."
        sudo apt update && sudo apt install -y whiptail

        # Verify if whiptail installed successfully
        if command -v whiptail &> /dev/null; then
            echo "whiptail installed successfully."
        else
            echo "Failed to install whiptail."
            exit 1
        fi
    else
        echo "apt is not available on this system. Cannot install whiptail automatically."
        exit 1
    fi
fi

PBDEBUG=false

# Check if any arguments
for arg in "$@"; do
    case "$arg" in
        "bash")   BASHARG="bash" ;;
        "debug")  PBDEBUG=true ;;
        "arm64")  ARCH="arm64" ;;
        "riscv64") ARCH="riscv64" ;;
        *)
            if [ -d "$arg" ]; then
                DISTRO_DIR="$arg"
            fi
            ;;
    esac
done

function start() {

  set -e
  
  docker build . -t distro-${ARCH} --network=host --no-cache --build-arg DISTRO_DIR=${DISTRO_DIR} --build-arg ROOTFS=${ROOTFS}  --target distro-${ARCH}  

  mkdir -p $ROOTFS
  docker run --rm -it --net=host --privileged \
                    -v ./rootfs:/rootfs \
                    -e DISTRO_HOSTNAME="${DISTRO_HOSTNAME}" -e ROOTPW="${ROOTPW}" \
                    -e ROOTFS="${ROOTFS}" \
                    -e PBDEBUG="${PBDEBUG}" \
                     distro-${ARCH} $BASHARG
}


function get_directory()
{
   mapfile -t dirs < <(find . -maxdepth 2 -type f -name "ENV" -exec dirname {} \; | sort -u)
   
   if [ ${#dirs[@]} -eq 0 ]; then
       echo "No directories containing ENV file found."
       exit 1
   fi

   menu_options=()
   for i in "${!dirs[@]}"; do
       dir_name=$(basename "${dirs[$i]}")
       menu_options+=("$((i+1))" "$dir_name")
   done

   DISTRO_DIR=$(whiptail --title "Select Directory" \
       --menu "Choose a directory containing ENV:" \
       15 60 5 \
       "${menu_options[@]}" \
       3>&1 1>&2 2>&3)

   if [ $? -ne 0 ] || [ -z "$DISTRO_DIR" ]; then
      echo "No selection made. Exiting."
      exit 0
   fi

   # Use the selected number to get the basename directly
   DISTRO_DIR=$(basename "${dirs[$((DISTRO_DIR-1))]}")
}

function get_cpu()
{
   CHOICE=$(whiptail --title "Architecture Selection" --menu "Choose an architecture:" 15 60 2 \
   "1" "ARM64" \
   "2" "RISC-V" 3>&1 1>&2 2>&3)

   # Check the exit status of whiptail (0 means OK, 1 means Cancel)
   if [ $? -eq 0 ]; then
       # If-else block based on the user's selection
       if [ "$CHOICE" = "1" ]; then
           ARCH="arm64"
       elif [ "$CHOICE" = "2" ]; then
           ARCH="riscv64"        
       fi
   fi


   [ -z "$ARCH" ] && exit 0
}

[ -z "$DISTRO_DIR" ] && get_directory

source "$DISTRO_DIR/ENV"

[ -z "$ARCH" ] && get_cpu

start

source makeTar.sh