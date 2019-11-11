#!/usr/bin/env bash

if [[ ! -d node_modules ]]; then
  echo "Installing dependencies (this might be slow)..."
  npm install
fi

echo "Retrieving Cloudflare token..."
eval "$(node ./cloudflare-token.js)"

host='japscan.co'

title="$1"
dashed_title=$(echo "$title" | tr ' ' '-')
lc_dashed_title=$(echo "$dashed_title" | tr '[:upper:]' '[:lower:]' )
volume= # TODO: compute dynamically from the chapter
chapter="$2"

echo "Retrieving number of pages for chapter $chapter..."
url="https://www.$host/lecture-en-ligne/$lc_dashed_title/$chapter/"
out=$(mktemp)
if ! curl "$url" \
  --header "User-Agent: $ua" \
  --header "Cookie: $cookie" \
  --compressed \
  --fail \
  --silent \
  --show-error \
  --output "$out"; then
  >&2 echo -e "\rFailed to download page $url"
  >&2 echo -e "Maybe the cookie is expired"
  >&2 echo -e "Maybe the user agent is not the same as the one used to generate the cookie"
  exit 1
fi
pages=( $(grep -Po 'data-img="\K.*?(?=")' "$out") )
rm "$out"

BASE_DIR=$(xdg-user-dir PICTURES)/Scans
path="$BASE_DIR/$title"
if [[ ! -z "$volume" ]]; then
  path="$path/Volume $volume"
fi
path="$path/Chapitre $chapter"

mkdir -p "$path"
cd "$path" || exit

for index in "${!pages[@]}"; do
  page="${pages[index]}"
  if [[ -f "./$page" ]]; then
    echo -ne "\r\e[KPage $((index + 1)) already downloaded..."
    sleep 0.05
    continue
  fi

  echo -ne "\r\e[KDownloading page $((index + 1))/${#pages[@]}..."

  # Random sleep between 1 and 3 seconds
  sleep $((RANDOM % 3 + 1))

  url="https://c.$host/lel/$dashed_title/$chapter/$page"

  if ! curl "$url" \
    --header "Host: c.$host" \
    --header "User-Agent: $ua" \
    --header "Cookie: $cookie" \
    --header 'Connection: keep-alive' \
    --compressed \
    --location \
    --remote-name \
    --fail \
    --silent \
    --show-error
  then
    >&2 echo -e "\r\e[KFailed to download page $page from $url"
    >&2 echo -e "Maybe the previous file was a double page"
    >&2 echo -e "Maybe the cookie is expired"
  fi
done
echo
echo "Chapter $chapter downloaded to '$path', enjoy!"
