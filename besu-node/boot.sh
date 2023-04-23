#!/bin/bash
SLEEP=${RANDOM:0:1}0
echo "Wait ${SLEEP} seconds..."
sleep ${SLEEP}
besu --genesis-file=genesis.json \
    --data-path=data \
    --bootnodes $(paste *-enode -d ",") \
    --network-id=50155 \
    --nat-method=NONE \
    --p2p-host=$(hostname -i) \
    --p2p-interface=$(hostname -i)
