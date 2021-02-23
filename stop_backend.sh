#! /bin/bash

set -e
sudo -v

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

printf "Stopping Proxy..."
killall ngrok &>/dev/null || true
echo "Done."

printf "Stopping Backend Server..."
docker-compose down &>/dev/null &
wait_for_finish $!
echo "Done."

printf "Stopping Docker Service..."
sudo systemctl stop docker &>/dev/null &
wait_for_finish $!
echo "Done."
