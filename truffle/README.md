# try-truffle

## with ganache

ganache --chain.chainId 1337 --chain.networkId 1337
truffle console --network ganache

## with geth

### Clef initialize

clef init
mkdir ~/.ethereum/keystore

### Create account

clef newaccount

### Geth initialize

geth init ~/genesis.json

### Launch geth node

clef --chainid 50155 --suppress-bootwarn
geth -networkid 50155 \
    --signer ~/.clef/clef.ipc \
    --nat extip:$(hostname -i) \
    --netrestrict 172.29.0.0/16 \
    --bootnodes $(cat ~/bootnode-enode.txt) \
    --http

### Attach truffle console

truffle console --network geth
