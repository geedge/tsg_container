#!bin/bash

# work dir
cd /root/tsg_container

# stop sapp tfe vpp
docker-compose down
systemctl stop vpp

# start vpp sapp tfe
systemctl start vpp
sleep 5
docker-compose up >> restart.log &
sleep 3

# start tfe env
sh init_tfe_env.sh

cd -
