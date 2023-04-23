#!/bin/sh
sleep $1
SLEEP=${RANDOM:0:1}0
echo "Wait ${SLEEP} seconds..."
sleep ${SLEEP}
geth -networkid 50155 \
    --nat extip:$(hostname -i) \
    --netrestrict 172.29.0.0/16 \
    --bootnodes $(cat /root/bootnode-enode) \
    --syncmode full \
    --mine \
    --miner.etherbase $(cat /root/etherbase) \
    --signer http://$(hostname -i)0:8550
