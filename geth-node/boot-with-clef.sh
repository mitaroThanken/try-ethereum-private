#!/bin/sh
sleep $1
geth -networkid 50155 \
    --nat extip:$(hostname -i) \
    --netrestrict 172.29.0.0/16 \
    --bootnodes $(cat /root/bootnode-enode.txt) \
    --syncmode full \
    --mine \
    --miner.etherbase $(cat /root/etherbase) \
    --signer http://$(hostname -i)0:8550 \
    --http --http.addr $(hostname -i) --http.vhosts node1,node2,node3 --graphql --ws
