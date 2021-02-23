#! /bin/bash

set -e
sudo -v

BOLD=$(tput bold)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
RESET=$(tput sgr0)

NGROK_DASHBOARD=http://127.0.0.1:4040
NGROK_HTTP_TUNNEL_API="${NGROK_DASHBOARD}/api/tunnels/command_line%20%28http%29"

function get_url() {
    curl -s $NGROK_HTTP_TUNNEL_API |
        python -c "import sys, json; print(json.load(sys.stdin)['public_url'])"
}

function proxy_not_ready() {
    get_url &>/dev/null
    RESULT="$?"
    if [ "$RESULT" = "0" ]; then
        false
    else
        true
    fi
}

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

printf "Starting Docker Service..."
sudo systemctl start docker 2>/dev/null &
wait_for_finish $!
echo "Done."

printf "Starting Backend Server..."
docker-compose up --build --remove-orphans --detach &>server-build.log &
wait_for_finish $!
echo "Done."

printf "Starting Proxy Server..."
nohup ngrok http 80 &>/dev/null &
wait_while proxy_not_ready
PROXY_URL=$(get_url)
echo "Done."

echo
echo "${BLUE}${BOLD}Server Build Logs:${RESET} ${BOLD}cat server-build.log${RESET}"
echo "${BLUE}${BOLD}Server Run Logs:${RESET} ${BOLD}docker-compose logs -f${RESET}"
echo
echo "${MAGENTA}${BOLD}NGROK Dashboard:${RESET} ${BOLD}$NGROK_DASHBOARD${RESET}"
echo "${GREEN}${BOLD}Proxy URL:${RESET} ${BOLD}$PROXY_URL${RESET}"
echo

if command -v xclip &>/dev/null; then
    echo -n "$PROXY_URL" | xclip -selection clipboard
    echo "Proxy URL copied!"
fi
