#!/usr/local/sh

if [[ $1 == -f ]]; then
    shift
    local fifo
    exec {fifo}<>$1
    backdoor -i $fifo
elif [[ $1 == -i  ]]; then
    shift
    zle -F $1 backdoor
elif [[ $1 == <->  ]]; then
    local line
    # can get DoSed by someone writing data w/o a newline,
    # but obv. that's the least of ur prob's if the other end isn't trusted.
    if ! IFS= read -r line <&$1; then
        zle -F $1
        return 1
    fi
    eval $line
else
    echo >&2 "Usage: backdoor -f fifo"
    echo >&2 "       backdoor -i fd"
    echo >&2
    echo >&2 "Will read lines from given fifo & eval them in zle -F context"
    echo >&2 "You can also attach it to an fd urself w/ backdoor -i fd, &"
    echo >&2 "it'll run all lines read from FD."
fi