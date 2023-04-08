#!/bin/sh
cd
geth -networkid 50155 \
--nat extip:$(hostname -i) \
--netrestrict 172.29.0.0/16 \
--bootnodes $(cat bootnode-enode.txt) \
--syncmode full \
--unlock $(cat etherbase) \
--password PASSWORD \
--mine \
--miner.etherbase $(cat etherbase)
