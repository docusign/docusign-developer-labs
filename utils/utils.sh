function isCommandAvailable() {
    local cmd=$1
    command -v "$cmd" >/dev/null 2>&1
}

urlencode() {
    local LC_ALL=C
    local string="$1"
    local length=${#string}
    local encoded=""

    for (( i = 0; i < length; i++ )); do
        local c="${string:i:1}"
        case "$c" in
            [a-zA-Z0-9.~_-]) encoded+="$c" ;;
            ' ') encoded+='%20' ;;
            *) printf -v hex '%%%02X' "'$c"
                encoded+="$hex"
                ;;
        esac
    done

    printf '%s' "$encoded"
}

function embedWorkflow() {
    local instance_url=$1
    encoded_instance_url=$(urlencode $instance_url)
    host_url="http://localhost:8080/embed?instance_url=$encoded_instance_url"
    if which xdg-open &> /dev/null  ; then
        xdg-open $host_url
    elif which open &> /dev/null    ; then
        open $host_url
    elif which start &> /dev/null   ; then
        start $host_url
    fi

    case "$LANGUAGE_CHOICE" in
        PHP)
            php ./startServer.php
            ;;
        python3)
            python3 ./startServer.py
            ;;
        python)
            python ./startServer.py
            ;;
        *)
            echo "Unsupported language: $LANGUAGE_CHOICE"
            exit 1
            ;;
    esac
}

export -f isCommandAvailable
export -f embedWorkflow
