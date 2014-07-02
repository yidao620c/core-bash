#!/bin/bash
# 测试输入字符串是否为字母/数字

SUCCESS=0
FAILURE=1

isalpha() { # 是否首字母为alpha
    if [[ -z "$1" ]]; then
        return $FAILURE
    fi

    case "$1" in
        [a-zA-Z]*)
            return $SUCCESS
            ;;
        *)
            return $FAILURE
            ;;
    esac
}

isallalpha() {
    [[ $# == 1 ]] || return $FAILURE
    case $1 in
        *[!a-zA-Z]*|"")
            return $FAILURE
            ;;
        *)
            return $SUCCESS
            ;;
    esac
}

isdigit() {
    [[ $# == 1 ]] || return $FAILURE
    case $1 in
        *[!0-9]* | "") return $FAILURE;;
        *) return $SUCCESS;;
    esac
}

check_var() {
    if isalpha "$@"; then
        echo "\"$*\" begins with an alpha character."
            if isallaplpha "$@"; then
                echo "\"$*\" contains only alpha character."
            else
                echo "\"$*\" contains at least one non-alpha character."
            fi
    else
        echo "\"$*\" begins with a non-alpha character."
    fi
    echo
}

check_var af343
