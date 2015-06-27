#!/bin/bash

ANSIBLE_PLAYBOOK="provision.yml"
VAGRANT_PATH="/vagrant/provision"
ANSIBLE_HOSTS="hosts"
ANSIBLE_EXTRA_VARS=""
ANSIBLE_INVENTORY="vagrant-inventory"

if [ ! -f ${VAGRANT_PATH}/${ANSIBLE_PLAYBOOK} ]; then
        echo "ERROR: Cannot find the given Ansible playbook."
        exit 1
fi

if [ ! -f $VAGRANT_PATH/$ANSIBLE_HOSTS ]; then
        echo "ERROR: Cannot find the given Ansible hosts file."
        exit 2
fi

# Install ansible and dependencies if not present in box
if ! command -v ansible >/dev/null; then
        echo "Installing Ansible dependencies and Git."
        if command -v yum >/dev/null; then
                sudo yum install -y gcc git python python-devel
        elif command -v apt-get >/dev/null; then
                sudo apt-get update -qq
                #sudo apt-get install -y -qq git python-yaml python-paramiko python-jinja2
                sudo apt-get install -y -qq git python python-dev
        else
                echo "neither yum nor apt-get found!"
                exit 1
        fi
        echo "Installing pip via easy_install."
        wget http://peak.telecommunity.com/dist/ez_setup.py
        sudo python ez_setup.py && rm -f ez_setup.py
        sudo easy_install pip
        # Make sure setuptools are installed crrectly.
        sudo pip install setuptools --no-use-wheel --upgrade
        echo "Installing required python modules."
        sudo pip install paramiko pyyaml jinja2 markupsafe
        sudo pip install ansible
		echo "Ansible installed"
fi

if [ ! -z "$ANSIBLE_EXTRA_VARS" -a "$ANSIBLE_EXTRA_VARS" != " " ]; then
        ANSIBLE_EXTRA_VARS=" --extra-vars $ANSIBLE_EXTRA_VARS"
fi

# stream output
export PYTHONUNBUFFERED=1

# show ANSI-colored output
export ANSIBLE_FORCE_COLOR=true

# copy ansible hosts file to server
cp ${VAGRANT_PATH}/hosts /etc/ansible/hosts

# chmod -x ${VAGRANT_PATH}/${ANSIBLE_INVENTORY}

echo "Running Ansible"
ansible-playbook ${VAGRANT_PATH}/${ANSIBLE_PLAYBOOK} --connection=local # $ANSIBLE_EXTRA_VARS
