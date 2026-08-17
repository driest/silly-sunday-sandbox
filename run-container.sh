#!/bin/bash

name=""
share_dirs=()

while [ $# -gt 0 ]; do
    case "$1" in
        -n|--name)
            name="$2"
            shift 2
            ;;
        -s|--share)
            share_dirs+=("$2")
            shift 2
            ;;
        *)
            echo "Unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

if [ -n "$name" ] && podman container exists "$name"; then
    exec podman start -ai "$name"
fi

jq --arg dir "$PWD" '.hook.path = $dir + "/firewall.sh"' "$PWD/hooks/firewall_hook.json.skel" > "$PWD/hooks/firewall_hook.json"

kitty_args=()
if [ "$TERM" = "xterm-kitty" ]; then
    kitty_args=(
        --volume "${TERMINFO}/x/xterm-kitty:/home/ubuntu/.terminfo/x/xterm-kitty:ro"
        --env TERM=xterm-kitty
    )
fi

share_args=()
if [ ${#share_dirs[@]} -eq 0 ]; then
    share_args=(--volume ./shared:/shared)
else
    for dir in "${share_dirs[@]}"; do
        share_args+=(--volume "$dir:/shared/$(basename "$dir")")
    done
fi

run_args=(--rm)
if [ -n "$name" ]; then
    run_args=(--name "$name")
fi

podman \
    --hooks-dir "$PWD/hooks" \
    run "${run_args[@]}" -it \
    --annotation firewall=yes \
    --network "pasta:--address,10.0.2.100,--netmask,255.255.255.0,--gateway,10.0.2.2,--map-host-loopback,10.0.2.2,--no-udp,--no-icmp,--no-ndp,--no-dhcpv6,--no-ra,--ipv4-only" \
    "${share_args[@]}" \
    "${kitty_args[@]}" \
    --hostname sandbox \
    sandbox:latest
