#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

run() {
    j=1
    while eval "\${pipestatus_$j+:} false"; do
        unset pipestatus_$j
        j=$(($j+1))
    done
    j=1 com= k=1 l=
    for a; do
        if [ "x$a" = 'x|' ]; then
            com="$com { $l "'3>&-
                        echo "pipestatus_'$j'=$?" >&3
                      } 4>&- |'
            j=$(($j+1)) l=
        else
            l="$l \"\$$k\""
        fi
        k=$(($k+1))
    done
    com="$com $l"' 3>&- >&4 4>&-
               echo "pipestatus_'$j'=$?"'
    exec 4>&1
    eval "$(exec 3>&1; eval "$com")"
    exec 4>&-
    j=1
    while eval "\${pipestatus_$j+:} false"; do
        eval "[ \$pipestatus_$j -eq 0 ]" || return 1
        j=$(($j+1))
    done
    return 0
}

log() {
    if [ -n "${1-}" ]; then
        echo "[cont-init.d] $(basename $0): $*"
    else
        while read OUTPUT; do
            echo "[cont-init.d] $(basename $0): $OUTPUT"
        done
    fi
}

# Generate machine id.
if [ ! -f /etc/machine-id ]; then
    log "generating machine-id..."
    cat /proc/sys/kernel/random/uuid | tr -d '-' > /etc/machine-id
fi

# Clear the fstab file to make sure its content is not displayed in BitTyrant
echo > /etc/fstab

# Print the core dump info.
log "core dump file location: $(cat /proc/sys/kernel/core_pattern)"
log "core dump file size: $(ulimit -a | grep "core file size" | awk '{print $NF}') (blocks)"

# Take ownership of the config directory content.
#find /config -mindepth 1 -exec chown $USER_ID:$GROUP_ID {} \;
find /config -exec chown $USER_ID:$GROUP_ID {} \;

# Take ownership of the storage directory content.
#find /storage -mindepth 1 -exec chown $USER_ID:$GROUP_ID {} \;
find /storage -exec chown $USER_ID:$GROUP_ID {} \;

# vim: set ft=sh :
