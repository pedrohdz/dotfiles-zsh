#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail 

GIT_USER_NAME='Pedro H.'
GIT_USER_EMAIL='5179251+pedrohdz@users.noreply.github.com'
GIT_USER_SIGNING_KEY='0xADB0821E62CC1EDD'

GIT_TOP_LEVEL=$(git rev-parse --show-toplevel)
GIT_PROJECT_NAME=$(basename "$GIT_TOP_LEVEL")

echo "New user settings for '$GIT_PROJECT_NAME': $GIT_USER_NAME <$GIT_USER_EMAIL> ($GIT_USER_SIGNING_KEY)"

git config --local user.name "$GIT_USER_NAME"
git config --local user.email "$GIT_USER_EMAIL"
git config --local user.signingKey "$GIT_USER_SIGNING_KEY"
git config --local commit.gpgSign 'true'
git config --local tag.gpgSign 'true'
