#!/usr/bin/bash

readonly basename="$(basename "$0")"

if ! command -v fzf >/dev/null 2>&1; then
    printf "Error: Missing dep: fzf is required to use ${basename}.\n" >&2
    exit 64
fi

#Colors
declare -r esc=$'\033'
declare -r BLUE="${esc}[1m${esc}[34m"
declare -r RED="${esc}[31m"
declare -r GREEN="${esc}[32m"
declare -r YELLOW="${esc}[33m"
declare -r CYAN="${esc}[36m"
# Base commands
readonly QUERY="dnf --cacheonly --quiet repoquery "
readonly PREVIEW="dnf --cacheonly --quiet --color=always info"
readonly QUERY_PREFIX=''
readonly QUERY_SUFIX=' > '
# Install mode
readonly INS_QUERY="${QUERY} --qf '${CYAN}%{name}\n'"
readonly INS_PREVIEW="${PREVIEW}"
readonly INS_PROMPT="${CYAN}${QUERY_PREFIX}Install packages${QUERY_SUFIX}"
# Remove mode
readonly RMV_QUERY="${QUERY} --installed --qf '${RED}%{name}\n'"
readonly RMV_PREVIEW="${PREVIEW} --installed"
readonly RMV_PROMPT="${RED}${QUERY_PREFIX}Remove packages${QUERY_SUFIX}"
# Remove-userinstalled mode
readonly RUI_QUERY="${QUERY} --userinstalled --qf '${YELLOW}%{name}\n'"
readonly RUI_PREVIEW="${PREVIEW} --installed"
readonly RUI_PROMPT="${YELLOW}${QUERY_PREFIX}Remove User-Installed${QUERY_SUFIX}"
# Updates mode
readonly UPD_QUERY="result=${QUERY} --upgrades --qf '${GREEN}%{name}\n'; [ -z "$output" ] && printf '${GREEN}No updates available.\nTry refreshing metadata cache...' || \$result"
readonly UPD_PREVIEW="${PREVIEW}"
readonly UPD_PROMPT="${GREEN}${QUERY_PREFIX}Upgrade packages${QUERY_SUFIX}"

readonly HELP="${basename}
Interactive package manager for Fedora

Alt-i       Install mode (default)
Alt-r       Remove mode
Alt-e       Remove User-Installed mode
Alt-u       Updates mode
Alt-m       Update package metadata cache

Enter       Confirm selection
Tab         Mark package ()
Shift-Tab   Unmark package
Ctrl-a      Select all

Alt-h       Help (this page)
ESC         Quit"

FZF_DEFAULT_COMMAND="${INS_QUERY}" \
fzf \
--ansi \
--multi \
--query=$* \
--header=" ${basename} | Press Alt+h for help or ESC to quit" \
--header-first \
--prompt="${INS_PROMPT}" \
--marker=' ' \
--preview-window='right,67%,wrap' \
--preview="${INS_PREVIEW} {1}" \
--bind="enter:execute(command=\${FZF_PROMPT%% *}; command=\${command#*m}; sudo dnf \${command,,} {+}; \
    read -s -r -n1 -p $'\n${BLUE}Press any key to continue...' && printf '\n')" \
--bind="alt-i:reload(${INS_QUERY})+change-preview(${INS_PREVIEW} {1})+change-prompt(${INS_PROMPT})+first" \
--bind="alt-r:reload(${RMV_QUERY})+change-preview(${RMV_PREVIEW} {1})+change-prompt(${RMV_PROMPT})+first" \
--bind="alt-e:reload(${RUI_QUERY})+change-preview(${RUI_PREVIEW} {1})+change-prompt(${RUI_PROMPT})+first" \
--bind="alt-u:reload(${UPD_QUERY})+change-preview(${UPD_PREVIEW} {1})+change-prompt(${UPD_PROMPT})+first" \
--bind="alt-m:execute(sudo dnf makecache;read -s -r -n1 -p $'\n${BLUE}Press any key to continue...' && printf '\n')" \
--bind="alt-h:preview(printf \"${HELP}\")" \
--bind="ctrl-a:select-all"
