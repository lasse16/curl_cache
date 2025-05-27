#!/usr/bin/env bash

url=${args[url]}
verbose=${args[--verbose]}
expire_age=${args[--expiration-time]}
force=${args[--force]}

__log ()
{
	if [[ $verbose ]]; then
	   echo "[DEBUG] $*"
	fi
}

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/curl"
__log "Cache directory = $cache_dir"

cache_name=$(echo -n "$url" | md5sum | awk '{print $1}')
mkdir -p "$cache_dir"

cache_file="$cache_dir/$cache_name"
__log "Cache file = $cache_file"


# Check if cached file exists and is fresh enough
if ! [ $force ] && [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -c %Y "$cache_file"))) -lt $expire_age ]; then
    __log "Cache hit at [$cache_file]"
    cat "$cache_file"
else
    # Download and cache with curl
    __log "Cache miss"
    __log "Running new request for [ $url ]"
    curl -sSfL "$url" > "$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
    cat "$cache_file"
fi
