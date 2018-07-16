#!/usr/bin/env bash

set -e
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# short circuit if requirements cannot be met
[[ ! -f "$DIR/header.tmplt" ]] && echo 'Header Template missing. Exiting.' && exit 1
[[ ! -f "$DIR/exclude.list" ]] && echo 'Exclude list missing. Exiting.' && exit 1

CONTENT_DIR="$DIR/content"
SRC_DIR="$DIR/build/src"
HEADER_STRING=$(head -n 1 "$DIR/header.tmplt")
HEADER_TMPLT=$(sed -e ':a;N;$!ba;s/\n/\\n/g' "$DIR/header.tmplt")
EXCLUDE_LIST="$DIR/exclude.list"

# ensures directory structure and git repo in place
init() {
  mkdir -p "$CONTENT_DIR"
  if [[ ! -d "$SRC_DIR" ]]; then
    echo "Cloning k/community."
    git clone git@github.com:kubernetes/community.git "$SRC_DIR"
  fi
}

# syncs content from community repo to content dir
sync_content() {
  echo "Syncing k/community to content dir."
  rsync -av --exclude-from "$EXCLUDE_LIST" "$SRC_DIR/" "$CONTENT_DIR/"
}

# gets all markdown files in content directory
find_files() {
  find "$CONTENT_DIR" -type f -name '*.md' -print0
}

# inserts header into file
insert_header() {
  local title
  local filename
  filename="$(basename "$1")"
  # If its README, assume the title should be that of the parent dir. 
  # Otherwise use the name of the file.
  if [[ "${filename,,}" == 'readme.md' || "${filename,,}" == '_index.md' ]]; then
    title="$(basename "$(dirname "$1")")"
  else
    title="${filename%.md}"
  fi
  sed -i "1i${HEADER_TMPLT//__TITLE__/$title}" "$1"
  echo "Header inserted into: $1"
}

# Renames readme.md to _index.md
rename_file() {
  local filename
  filename="$(dirname "$1")/_index.md"
  mv "$1" "$filename"
  echo "Renamed: $1 to $filename"
}

# Cleans up formatting of links found in docs
sub_links() {
  sed -i \
      -e 's|https://github\.com/kubernetes/community/blob/master||Ig' \
      -e 's|README\.md)|)|Ig' \
      -e 's|README\.md#|#|Ig' \
      -e 's|\.md)|)|Ig' \
      -e 's|\.md#|#|Ig' \
      "$1" 
  echo "Links Updated in: $1"
}

main() {
  init
  sync_content
  find_files | while IFS= read -r -d $'\0' file; do
    # short circult early if already 
    [[ $(head -n 1 "$file") == "$HEADER_STRING" ]] && continue
    sub_links "$file"
    insert_header "$file"
    # if its README, we need it to be renamed index.
    [[ $(basename "$file") == 'README.md' ]] && rename_file "$file"
  done
}

main "$@"