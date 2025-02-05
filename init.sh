#!/bin/bash

sudo apt-get install -y git python3 python3-pip python3-venv

mkdir -p ~/{.ssh/,ansible/deploy,hashi/terraform,python}

touch ~/.ssh/{id_rsa,id_rsa.pub,authorized_keys}
${VISUAL:-${EDITOR:-vi}} ~/.ssh/id_rsa
${VISUAL:-${EDITOR:-vi}} ~/.ssh/id_rsa.pub
echo ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh/
chmod 400 ~/.ssh/id_rsa*

cd
git clone git@github.com:fiercebrake/bash.git

cd ansible/deploy
git clone -b debian git@github.com:fiercebrake/deploy.git
mv deploy/ debian/

git clone -b k8s git@github.com:fiercebrake/deploy.git
mv deploy/ k8s/

cd ~/ansible/
python3 -m venv .latest
source .latest/bin/activate
python -m pip install ansible
python -m pip install ansible-core
python -m pip install ansible-lint
python -m pip install ansible-runner
deactivate

cd
