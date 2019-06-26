#!/usr/bin/env zsh

emulate -R zsh
setopt extendedglob typesetsilent warncreateglobal

typeset -ga reply

typeset -g URL="https://api.github.com/repos/\$ORG/\$PRJ/issues?state=open"
typeset -g CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-github-issues"
typeset -g CACHE_SEEN_IDS="$CACHE_DIR/ids_seen.dat"
typeset -g CACHE_NEW_TITLES="$CACHE_DIR/new_titles.log"

command mkdir -p "$CACHE_DIR"
command touch "$CACHE_SEEN_IDS"

download() {
    local url ORG="$1" PRJ="$2"
    eval "url=$URL"
    reply=( "${(@f)"$(curl --silent -i $url)"}" )
}

download zdharma zplugin

local -a ids titles
ids=( "${(M)reply[@]:#    \"id\":[[:space:]]#*,}" )
ids=( "${${(M)ids[@]//(#b)[[:space:]]#\"id\":[[:space:]]#(*),/${match[1]}}[@]}" )
titles=( ${(M)reply[@]:#[[:space:]]#\"title\":[[:space:]]#*,} )
titles=( "${${(M)titles[@]//(#b)[[:space:]]#\"title\":[[:space:]]#\"(*)\",/${match[1]}}[@]}" )

local -A map
integer idx=0
: ${ids[@]//(#b)(*)/${map[${match[1]}]::=${titles[$((++idx))]}}}

local -a seen_ids diff
seen_ids=( "${(@f)"$(<${CACHE_SEEN_IDS})"}" )
if [[ -z "${seen_ids[*]}" ]]; then
    # Initial run – assume that all issues have been seen
    print -rl "${ids[@]}" >! "${CACHE_SEEN_IDS}"
else
    # Detect new issues
    diff=( ${ids[@]:#(${(~j:|:)seen_ids[@]})} )
fi

if [[ ${#diff} -gt 0 ]]; then
    print -rl -- "New issue(s):" "${diff[@]}"
    print -rl "${diff[@]}" >>! "${CACHE_SEEN_IDS}"
    local issue_id
    for issue_id in "${diff[@]}"; do
        print -rl "${map[$issue_id]}" >> "${CACHE_NEW_TITLES}"
    done
fi
