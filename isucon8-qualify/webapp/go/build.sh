#!/bin/sh

set -e

sudo rm -f /var/log/mariadb/slow.log
export DB_DATABASE=torb
export DB_HOST=localhost
export DB_PORT=3306
export DB_USER=isucon
export DB_PASS=isucon

#cd ~/torb/
#sudo systemctl restart mariadb
#./db/init.sh
sudo systemctl restart mariadb

cd ~/torb/webapp/go/
sudo systemctl stop torb.go
rm -f torb
make
rm -f torb
make
# sudo systemctl restart mariadb
sudo systemctl restart torb.go
sudo systemctl restart torb.go
sudo systemctl restart nginx

