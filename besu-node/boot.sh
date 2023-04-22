#!/bin/sh
sleep $1
besu --genesis-file=genesis.json \
    --data-path=data \
    --bootnodes=$(cat geth-node1-enode),$(cat geth-node2-enode) \
    --network-id=50155 \
    --p2p-interface=$(hostname -i)
