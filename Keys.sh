#!/bin/bash
# Keys module for Ez
# Handles: letters, numbers, symbols, arrows, ENTER, ESC
# Supports multiple variables and :+ operator

# -------------------------------
# Variables array from Ez
# -------------------------------
declare -n ez_vars_ref=ez_vars  # reference to Ez interpreter variables

# -------------------------------
# Read a single key (full)
# -------------------------------
function ez_read_key_full() {
    # read first char
    read -rsn1 key1
    key="$key1"

    # check for escape sequences (arrows, function keys)
    if [[ "$key1" == $'\e' ]]; then
        read -rsn2 -t 0.01 key2  # read extra chars if arrow
        key="$key1$key2"
    fi

    # Map ENTER
    if [[ "$key" == $'\n' ]]; then
        key="ENTER"
    fi

    # Map ESC
    if [[ "$key" == $'\e' ]]; then
        key="ESC"
    fi

    echo "$key"
}

# -------------------------------
# Input processor for multiple keys
# Example usage in Ez:
# Input(Arrow_left, Arrow_right, a, d (:+ -1, 1, -1, 1 = x))
# -------------------------------
function ez_input_keys() {
    local keys=("${!1}")     # array of key names
    local values=("${!2}")   # array of corresponding values
    local varname="$3"       # variable to update

    key=$(ez_read_key_full)

    for i in "${!keys[@]}"; do
        if [[ "${keys[i]}" == "$key" ]]; then
            old="${ez_vars_ref[$varname]:-0}"
            new=$(( old + values[i] ))
            ez_vars_ref["$varname"]="$new"
        fi
    done
}

# -------------------------------
# Helper: Map arrow escape sequences
# -------------------------------
declare -A EZ_KEYMAP
EZ_KEYMAP["$'\e[A'"]="Arrow_up"
EZ_KEYMAP["$'\e[B'"]="Arrow_down"
EZ_KEYMAP["$'\e[C'"]="Arrow_right"
EZ_KEYMAP["$'\e[D'"]="Arrow_left"
EZ_KEYMAP["$'\n'"]="ENTER"
EZ_KEYMAP["$'\e'"]="ESC"

# Convert read key to standard key name
function ez_key_name() {
    local raw="$1"
    if [[ -n "${EZ_KEYMAP[$raw]}" ]]; then
        echo "${EZ_KEYMAP[$raw]}"
    else
        echo "$raw"  # letters, numbers, symbols
    fi
}

# -------------------------------
# Main Ez Input function
# -------------------------------
function Ez_Input() {
    local keys=("${!1}")     # keys array
    local values=("${!2}")   # values array
    local varname="$3"       # variable to update

    key_raw=$(ez_read_key_full)
    key=$(ez_key_name "$key_raw")

    for i in "${!keys[@]}"; do
        if [[ "${keys[i]}" == "$key" ]]; then
            old="${ez_vars_ref[$varname]:-0}"
            new=$(( old + values[i] ))
            ez_vars_ref["$varname"]="$new"
        fi
    done
}
