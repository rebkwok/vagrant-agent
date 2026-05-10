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

# Install Claude Code via apt
install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://downloads.claude.ai/keys/claude-code.asc \
  -o /etc/apt/keyrings/claude-code.asc
echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/stable stable main" \
  | sudo tee /etc/apt/sources.list.d/claude-code.list
apt-get update
apt-get install -y claude-code

# make projects dir
mkdir -p /projects
chown vagrant:vagrant /projects

# add git config for vagrant user
su - vagrant -c "git config --global user.name $GIT_NAME"
su - vagrant -c "git config --global user.email $GIT_EMAIL"

# Install latest lts nodejs and codex
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs
# Install Codex globally
npm install -g @openai/codex

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