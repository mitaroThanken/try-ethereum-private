#!/bin/sh
sleep $1
geth -networkid 50155 \
    --nat extip:$(hostname -i) \
    --netrestrict 172.29.0.0/16 \
    --bootnodes $(paste /root/*-enode -d ",") \
    --syncmode full \
    --mine \
    --miner.etherbase $(cat /root/etherbase) \
    --signer http://$(hostname -i)0:8550
