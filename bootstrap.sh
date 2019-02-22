#!/usr/bin/env bash

# stolen- I mean borrowed from https://github.com/skylightio/skylight-phoenix/blob/master/vagrant-provision.sh
apt-get update -y
apt-get -f install

# tools for installing stuff
apt-get install -y wget git build-essential curl

# Stuff that phoenix likes
apt-get install -y inotify-tools

# Postgres
apt-get install -y postgresql postgresql-contrib
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"

# latest nodejs
cd /tmp
curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
chmod +x nodesource_setup.sh
sudo bash ./nodesource_setup.sh
apt-get install -y nodejs

# Erlang - the runtime that Elixir runs on
mkdir uploads
chown vagrant:vagrant uploads
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
dpkg -i erlang-solutions_1.0_all.deb
apt-get update -y
apt-get install -y esl-erlang

# Elixir - the language that Phoenix is written in
apt-get install -y elixir
