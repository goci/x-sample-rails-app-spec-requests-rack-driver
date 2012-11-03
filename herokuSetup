#!/bin/bash

CREATE_HEROKU_APP="$1"

if ! git remote | grep -q heroku; then
    heroku create "$CREATE_HEROKU_APP"
else
    HEROKU_APP_NAME=$(grep url .git/config | grep heroku | cut -d":" -f2 | sed s/.git//)
    echo "Heroku app $HEROKU_APP_NAME already created, skipping heroku create..."
fi