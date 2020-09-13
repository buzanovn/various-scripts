#!/bin/sh

DEFAULT_BRANCH_OR_TAG="master"
[ -z "$BRANCH_OR_TAG" ] && BRANCH_OR_TAG="$DEFAULT_BRANCH_OR_TAG"
RAW_URL="https://raw.githubusercontent.com/buzanovn/various-scripts/${BRANCH_OR_TAG}"

FILES_TO_INSTALL=$(cat << EOF
helpers.sh 
docker/dapt.sh 
docker/dpip.sh
EOF
)

DEFAULT_PREFIX_PATH="/usr/local/sbin"
[ -z "$PREFIX_PATH" ] && PREFIX_PATH="$DEFAULT_PREFIX_PATH"

path_to_name () {
  local name_without_ext=$(basename $1 | cut -d. -f1)
  echo "${PREFIX_PATH}/${name_without_ext}"
}

if [ -z "$(command -v wget)" ]; then
  if [ -z "$(command -v curl)" ]; then 
    exit 1
  else
    get_file() { 
      curl -fsSL "$1" "$2"
    }
  fi
else
  get_file() { 
    wget -qO "$2" "$1" 
  }
fi

for f in $FILES_TO_INSTALL; do
  install_path="$(path_to_name $f)"
  get_file "$RAW_URL/$f" "$install_path"
  chmod +x "$install_path"
done