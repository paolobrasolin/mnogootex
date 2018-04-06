# Usage: source this in your bash profile as
# [ -s "$(mnogootex mnogoo)" ] && . "$(mnogootex mnogoo)"

mnogoo () {
    if [ "$1" = cd ]; then
        MN_PATH="$(IS_MNOGOO=true mnogootex dir "${@:2}")" || return
        cd "$MN_PATH" || exit
    elif [ "$1" = open ]; then
        MN_PATH="$(IS_MNOGOO=true mnogootex pdf "${@:2}")" || return
        if command -v open >/dev/null 2>&1; then
            open "$MN_PATH"
        elif command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$MN_PATH"
        else
            echo "No known file opener (open, xdg-open) found on your system."
            echo "Please do chime in with suggestions: <paolo.brasolin@gmail.com>"
        fi
    else
        IS_MNOGOO=true mnogootex "$@"
    fi
}
