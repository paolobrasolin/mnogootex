# Usage: source this in your bash profile as
# [ -s "$(mnogootex mnogoo)" ] && . "$(mnogootex mnogoo)"

mnogoo () {
    if [ "$1" = cd ]; then
        MN_PATH="$(IS_MNOGOO=true mnogootex dir "${@:2}")" || return
        cd "$MN_PATH" || exit
    elif [ "$1" = open ]; then
        MN_PATH="$(IS_MNOGOO=true mnogootex pdf "${@:2}")" || return
        if command -v open >/dev/null 2>&1; then
            printf '%s\n' "$MN_PATH" | while read -r line; do open "$line"; done
        elif command -v xdg-open >/dev/null 2>&1; then
            printf '%s\n' "$MN_PATH" | while read -r line; do xdg-open "$line"; done
        else
            echo "No known file opener (open, xdg-open) found on your system."
            echo "Please do chime in with suggestions: <paolo.brasolin@gmail.com>"
        fi
    else
        IS_MNOGOO=true mnogootex "$@"
    fi
}
