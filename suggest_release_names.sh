#!/usr/bin/env sh
function require {
  command -v $1 >/dev/null 2>&1 || {
    echo >&2 "Script requires $1 but it's not available."
    exit 1
  }
}
require jq
require pup

if [ -z "$GITHUB_TOKEN" ]
then
  echo >&2 "Script requires a GITHUB_TOKEN environment variable but none exists."
  exit 1
fi

PREVIOUS=`curl 'https://api.github.com/repos/robfletcher/strikt/releases?per_page=1000' -H "Authorization: token $GITHUB_TOKEN" -s | jq '.[] | .name' | tr -d "\"" | sort`

for i in {1..10}
do
  ADJECTIVE=`curl https://randomword.com/adjective -s | pup '#random_word text{}'`
  NOUN=`curl https://randomword.com/noun -s | pup '#random_word text{}'`
  NAME="$ADJECTIVE $NOUN"
  if grep -q "$NAME" <<< "$PREVIOUS"
  then
    echo "~~ $NAME ~~ (ALREADY USED)"
  else
    echo "$NAME"
  fi
done
