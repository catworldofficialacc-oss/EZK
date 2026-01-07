#!/bin/bash
# Keys v2.0 module for Ez
# Fully supports letters, numbers, symbols, arrows, ENTER, ESC
# Supports multiple variables in one Input() call with :+ operator
# Ready for ed install

# -------------------------------
# Ez interpreter variable reference
# -------------------------------
declare -n ez_vars_ref=ez_vars  # links to Ez interpreter variable array

# -------------------------------
# Map arrow keys and special keys
# -------------------------------
declare -A EZ_KEYMAP
EZ_KEYMAP["$'\e[A'"]="Arrow_up"
EZ_KEYMAP["$'\e[B'"]="Arrow_down"
EZ_KEYMAP["$'\e[C'"]="Arrow_right"
EZ_KEYMAP["$'\e[D'"]="Arrow_left"
EZ_KEYMAP["$'\n'"]="ENTER"
EZ_KEYMAP["$'\e'"]="ESC"

# -------------------------------
# Read a single key from terminal
# -------------------------------
function ez_read_key_full() {
    read -rsn1 key1
    key="$key1"

    # Check escape sequences
    if [[ "$key1" == $'\e' ]]; then
        read -rsn2 -t 0.01 key2
        key="$key1$key2"
    fi

    # Map key names
    if [[ -n "${EZ_KEYMAP[$key]}" ]]; then
        key="${EZ_KEYMAP[$key]}"
    fi

    echo "$key"
}

# -------------------------------
# Main Ez Input function
# Usage example:
# Input(a, d, Arrow_left, Arrow_right (:+ -1, 1, -1, 1 = x, y))
# -------------------------------
function Ez_Input() {
    local keys=("${!1}")       # key names array
    local values=("${!2}")     # values array
    local varnames=("${!3}")   # variable names array

    key=$(ez_read_key_full)

    for i in "${!keys[@]}"; do
        if [[ "${keys[i]}" == "$key" ]]; then
            for var in "${varnames[@]}"; do
                old="${ez_vars_ref[$var]:-0}"
                new=$(( old + values[i] ))
                ez_vars_ref["$var"]="$new"
            done
        fi
    done
}

