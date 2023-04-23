#!/bin/bash
besu --genesis-file=genesis.json \
    --data-path=data \
    --bootnodes $(paste *-enode -d ",") \
    --network-id=50155 \
    --nat-method=NONE \
    --p2p-host=$(hostname -i) \
    --p2p-interface=$(hostname -i)
