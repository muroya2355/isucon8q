#!/bin/sh

set -e

cd /home/isucon/torb/webapp/go
sudo systemctl stop torb.go
rm -f torb
make
sudo systemctl restart mariadb
sudo systemctl start torb.go
cd /home/isucon/torb/bench

