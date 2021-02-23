#! /bin/bash

set -e
sudo -v

BOLD=$(tput bold)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

SPIN='-\|/'
function wait_while() {
    echo -ne " "
    i=0
    while $1 2>/dev/null; do
        i=$(((i + 1) % 4))
        echo -ne "\b${SPIN:$i:1}"
        sleep .1
    done
    echo -ne "\b"
}

function wait_for_finish() {
    PROGRAM=$1
    function is_running() {
        kill -0 $PROGRAM
    }
    wait_while is_running
}

printf "Stopping Backend Server..."
docker-compose down &>/dev/null &
wait_for_finish $!
echo "Done."

printf "Starting Backend Server..."
docker-compose up --build --remove-orphans --detach &>server-build.log &
wait_for_finish $!
echo "Done."

echo
echo "${BLUE}${BOLD}Server Build Logs:${RESET} ${BOLD}cat server-build.log${RESET}"
echo "${BLUE}${BOLD}Server Run Logs:${RESET} ${BOLD}docker-compose logs -f${RESET}"
echo
