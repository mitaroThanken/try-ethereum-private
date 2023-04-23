#!/bin/bash
SLEEP=${RANDOM:0:1}0
echo "Wait ${SLEEP} seconds..."
sleep ${SLEEP}
besu --genesis-file=genesis.json \
    --data-path=data \
    --bootnodes=$(cat geth-node1-enode),$(cat geth-node2-enode),$(cat geth-node3-enode) \
    --network-id=50155 \
    --nat-method=NONE \
    --p2p-host=$(hostname -i) \
    --p2p-interface=$(hostname -i)
