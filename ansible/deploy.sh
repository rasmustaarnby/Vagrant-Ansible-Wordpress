#!/bin/bash

VAGRANT_APPS_PATH="/vagrant/www"
ANSIBLE_PATH="/vagrant/ansible"

app="$1"
app_path=$(find $VAGRANT_APPS_PATH -name "${app}.yml")

ANSIBLE_FORCE_COLOR=true ansible-playbook "$ANSIBLE_PATH/deploy.yml" --extra-vars "@$app_path" --connection=local
