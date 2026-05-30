#!/bin/bash

set -euo pipefail

: "${GIT_NAME:?GIT_NAME environment variable is not set}"
: "${GIT_EMAIL:?GIT_EMAIL environment variable is not set}"

# install system packages
set +u
apt-get update
sed 's/^#.*//' /vagrant/packages.txt | xargs apt-get install --no-install-recommends --no-upgrade -y
apt-get autoremove -y
set -u

# install uv as vagrant user
su - vagrant -c "curl -LsSf https://astral.sh/uv/install.sh | sh"
echo 'export PATH="$HOME/.local/bin:$PATH"' | su vagrant -c "tee -a ~/.bashrc"

# make projects dir
mkdir -p /projects
chown vagrant:vagrant /projects

# add git config for vagrant user
su - vagrant -c "git config --global user.name $GIT_NAME"
su - vagrant -c "git config --global user.email $GIT_EMAIL"

# Install latest lts nodejs
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs
# configure npm
su - vagrant -c "npm config set prefix '~/.local/'"
su - vagrant -c "npm config set min-release-age 7"

# Install claude globally
su - vagrant -c "npm install -g @anthropic-ai/claude-code"
# Install Codex globally
su - vagrant -c "npm install -g @openai/codex"

echo "cd /projects" >> /home/vagrant/.profile
chown vagrant:vagrant /home/vagrant/.profile

# Firewall: restrict access to only what's needed
# Default deny outbound
ufw default deny outgoing
ufw default deny incoming
# Allow vagrant ssh on port 22
ufw allow in 22
ufw allow out 22
# Allow DNS
ufw allow out 53
# Allow HTTPS (npm, pip, APIs)
ufw allow out 443
# Allow HTTP (apt, some package mirrors)
ufw allow out 80
# Allow NTP (clock sync)
ufw allow out 123/udp

ufw --force enable

# add vagrant user to docker group
groupadd -f docker
usermod -aG docker vagrant
