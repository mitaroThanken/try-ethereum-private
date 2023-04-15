# try-truffle

## with ganache

ganache --chain.chainId 1337 --chain.networkId 1337
truffle console --network ganache

## generate BIP30 Mnemonic Seed Phrase

```
$ node
Welcome to Node.js v18.15.0.
Type ".help" for more information.
> const { generateMnemonic } = require("ethereum-cryptography/bip39");
undefined
> const { wordlist } = require("ethereum-cryptography/bip39/wordlists/english");
undefined
> console.log(generateMnemonic(wordlist));
labor clay lock brand siren garlic disorder orbit pulse repeat great help
undefined
> 
```
