# Very basic implementation of ls in bash (no flags, no columns)
ls_bash_imp() {
    local dir="${1:-.}"  # Default to current directory if no argument provided

    # Check if the argument is a directory
    if [[ ! -d $dir ]]; then
        echo "Error: '$dir' is not a directory." >&2
        return 1
    fi

    local prev=$(shopt -p nullglob)
    shopt -s nullglob
    local files=(${dir}/*)
    eval $prev
    printf '%s\n' "${files[@]##*/}"
}
