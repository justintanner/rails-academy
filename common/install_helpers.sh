if command -v tput &>/dev/null && tput setaf 1 &>/dev/null; then
  export GREEN_CHECK="✅"
  export RED_X="❌"
else
  export GREEN_CHECK="✓"
  export RED_X="✗"
fi

good() {
  echo -e "${GREEN_CHECK} $1"
}

bad() {
  local message="$1"
  local additional_message="$2"
  local exit_code="${3:-0}"

  echo -e "\n${RED_X} ${message}"

  if [[ -n "$additional_message" ]]; then
    echo -e $additional_message
  fi

  if [[ "$exit_code" -eq 1 ]]; then
    exit 1
  fi
}

backup_file() {
  local file=$1
  local backup=$file.bak
  local count=1

  while [ -f $backup ]; do
    backup=$file.bak$count
    count=$((count + 1))
  done

  mv $file $backup
}

install_and_backup_old_file() {
  local source=$1
  local dest=$2

  if [ -f $dest ] && ! cmp -s $dest $source; then
    backup_file $dest
    echo "Backed up old config file to $dest.bak"
  fi

  cp $source $dest
  good "Installed config $dest."
}

install_only_if_missing() {
  local source=$1
  local dest=$2

  if [ ! -f $dest ]; then
    cp $source $dest
    good "Installed config $dest."
  else
    good "Skipped installing config $dest"
  fi
}
