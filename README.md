# Try Ethereum - local

WIP

## Geth でプライベートネットワークを構成

### 前提

* 大筋は以下のドキュメントに従っている
  * [Private Networks](https://geth.ethereum.org/docs/fundamentals/private-network)
* `node1` と書かれている箇所については、`node1`・`node2`・`node3`……と、必要なノード数分繰り返す

### Geth Init

#### 各ノードでの署名用にアカウントを1つずつ作る

1. これから作るアカウントのパスワードを用意する

    ```shell
    mkdir geth-node1
    ```

    ```shell
    touch geth-node1/PASSWORD
    ```

1. `geth-node1/PASSWORD` にパスワードを設定する

    改行は不要。

1. これから生成するノードに関する情報を永続化するボリュームを用意する

    ```shell
    docker volume create geth-node1-volume
    ```

1. アカウントを生成するため、client-go のコンテナを一時的に立ち上げ、`sh` にアタッチする

    ```shell
    docker run \
    -v geth-node1-volume:/root/.ethereum \
    --mount type=bind,source="$(pwd)"/geth-node1/PASSWORD,target=/root/PASSWORD,readonly \
    --mount type=bind,source="$(pwd)"/geth-node/genesis.json,target=/root/genesis.json,readonly \
    -it --rm \
    ethereum/client-go:alltools-v1.11.5 \
    /bin/sh
    ```

1. アタッチしたシェルにて、アカウントを生成する

    ```shell
    cd
    ```

    ```shell
    geth account new --password PASSWORD
    ```

    ```shell
    exit
    ```

1. 生成されたアカウントのパブリックアドレスのキー（Public address of the key）を `geth-node1/etherbase` に控えておく

    ```shell
    touch geth-node1/etherbase
    ```

    `0x`を含む文字列。改行は不要。

#### ノードを初期化する

1. `genesis.json` を修正する

    [Private Networks](https://geth.ethereum.org/docs/fundamentals/private-network) の
    "Clique Example" を参照。

1. ノードを初期化するため、client-go のコンテナを一時的に立ち上げ、`sh` にアタッチする

    コマンドは「アカウントを作成するため」のものと同じ。

1. アタッチしたシェルにて、ノードを初期化する

    ```shell
    cd
    ```

    ```shell
    geth init genesis.json
    ```

    ```shell
    exit
    ```

### Bootnode の準備 - Docker Compose の導入

ノード同士の接続を簡便にするため、 `bootnode` を使用する。

1. `boot.key` を生成する

    ```shell
    mkdir bootnode
    ```

    ```shell
    docker run -it --rm ethereum/client-go:alltools-v1.11.5 /bin/sh \
    -c "bootnode -genkey boot.key && cat boot.key" \
    > bootnode/boot.key
    ```

1. `docker-compose.yml` を用意する

    この時点では、IPアドレスを固定した Bootnode だけからなる構成としておく。
    （この項をコミットした時点を参照）

1. Bootnode の enode アドレスを控える

    コンテナを起動する。

    ```shell
    docker compose up
    ```

    以下のようなログが観測できる。

    ```text
    20:38 $ docker compose up
    [+] Running 2/2
     ✔ Network try-ethereum_default       Created                                                                                                                                                     0.2s 
     ✔ Container try-ethereum-bootnode-1  Created                                                                                                                                                     0.2s 
    Attaching to try-ethereum-bootnode-1
    try-ethereum-bootnode-1  | INFO [04-08|11:43:58.950] Mapped network port                      proto=udp extport=30301 intport=30301 interface=ExtIP(172.29.0.100)
    try-ethereum-bootnode-1  | enode://804a97abc3561ea5cba672707b418810262378849967a9b5f38d19c3ba687fcf2f927770a9ade6fa283f92da7d66b77f8dbe00ca704237415d2989ba7fe87a42@172.29.0.100:0?discport=30301
    try-ethereum-bootnode-1  | Note: you're using cmd/bootnode, a developer tool.
    try-ethereum-bootnode-1  | We recommend using a regular node as bootstrap node for production deployments.
    try-ethereum-bootnode-1  | INFO [04-08|11:43:58.956] New local node record                    seq=1,680,954,238,953 id=dbdebe9299065db7 ip=<nil> udp=0 tcp=0
    ```

    上記のログの場合、
    `enode://804a97abc3561ea5cba672707b418810262378849967a9b5f38d19c3ba687fcf2f927770a9ade6fa283f92da7d66b77f8dbe00ca704237415d2989ba7fe87a42@172.29.0.100:0?discport=30301`
    が Bootnode の enode アドレス。

    これを`bootnode/enode.txt`に控える。改行は不要。

    控え終わったら、コンテナを停止させる。

### ノードを追加する

1. 起動用のスクリプトを用意する

    `geth-node/boot.sh`を参照。

    * 起動後の動作を安定させるため、起動開始のタイミングをずらせるようにしている（冒頭の`sleep`）

      `docker-compose.yml` を参照。

    * `--bootnodes` に Bootnode の enode アドレスを指定している
    * 起動後の動作を安定させるため、`--syncmode full` とする
    * この時点ではマイニング（Clique におけるサイニング）を成立させるため、以下の設定としている
      * アカウントをアンロックする（`--unlock`・`--password`）
      * マイニングを開始してする（`--mine`）
      * マイニングを行うアカウントを指定（`--miner.etherbase`）

1. `docker-compose.yml`に 全ノード分のサービスとボリュームを追加する

    ここをコミットしている時点の `docker-compose.yml` を参照。

1. `docker compose up`

    しばらく待っていると `"🔗 block reached canonical chain"` が記録されていることが確認できる。

    確認できなければ、どこかのステップが間違っている。ログをよく確認する。

### ノードにアタッチして疎通確認

[Private Networks](https://geth.ethereum.org/docs/fundamentals/private-network)にのっとって、
疎通確認。

1. いずれかのノードのコンテナのシェルにアタッチ

1. `geth attach`

    ```text
    / # geth attach
    Welcome to the Geth JavaScript console!

    instance: Geth/v1.11.5-stable-a38f4108/linux-amd64/go1.20.2
    coinbase: 0x108e30910a05eb43da87a30575afa53ec983a54d
    at block: 295 (Sat Apr 08 2023 13:33:57 GMT+0000 (UTC))
     datadir: /root/.ethereum
     modules: admin:1.0 clique:1.0 debug:1.0 engine:1.0 eth:1.0 miner:1.0 net:1.0 rpc:1.0 txpool:1.0 web3:1.0

    To exit, press ctrl-d or type exit
    >
    ```

    `coinbase` が意図したノードのものであることを確認する。

1. `net.peerCount`

    ```text
    > net.peerCount
    ```

    ```javascript
    2
    ```

    得られた数が 立ち上げたノードの数 - 1 ならば OK。

1. `admin.peers`

    ```test
    > admin.peers
    ```

    ```javascript
    [{
        caps: ["eth/66", "eth/67", "eth/68", "snap/1"],
        enode: "enode://f76749c83160e350b89b603aa5fe2d682dfd8cb9badddb5e0ddf4e38cc3ca4e5fea7ec05fd61036a963fedca2860b427490e5ea88906e5628dec5a7f108eb548@172.29.0.2:30303",
        enr: "enr:-KO4QJYObTsJy5j7EozFrEM1fldXnhfC0NcPK7AVWcfwh86gEQhrOxBBm3oFmUUvSH-YabjDI6O7G1NchM8T5Ac_JYyGAYdg9e3Mg2V0aMfGhGfPKs2AgmlkgnY0gmlwhKwdAAKJc2VjcDI1NmsxoQL3Z0nIMWDjULibYDql_i1oLf2Mubrd214N3044zDyk5YRzbmFwwIN0Y3CCdl-DdWRwgnZf",
        id: "2a6adf537c46c7a82ad2e0565c1597d311521cf00894ac8a9171ab3ffca60170",
        name: "Geth/v1.11.5-stable-a38f4108/linux-amd64/go1.20.2",
        network: {
          inbound: false,
          localAddress: "172.29.0.1:40532",
          remoteAddress: "172.29.0.2:30303",
          static: false,
          trusted: false
        },
        protocols: {
          eth: {
            version: 68
          },
          snap: {
            version: 1
          }
        }
    }, {
        caps: ["eth/66", "eth/67", "eth/68", "snap/1"],
        enode: "enode://2c179f629d33a98a169fabbaf278219af57b3f78838fb63087023e512dc5390ea070f2842cf20c3673fdf380d9c248f4d8ce6672d7849d0c6e550b6b42594cd0@172.29.0.3:39214",
        id: "71919be026838f6441f52a682fe6f63024c88d2534f81da5ad99c7bdfb08ef5e",
        name: "Geth/v1.11.5-stable-a38f4108/linux-amd64/go1.20.2",
        network: {
          inbound: true,
          localAddress: "172.29.0.1:30303",
          remoteAddress: "172.29.0.3:39214",
          static: false,
          trusted: false
        },
        protocols: {
          eth: {
            version: 68
          },
          snap: {
            version: 1
          }
        }
    }]
    > 
    ```

    残りのノードがピアとして列挙されていれば OK。

1. 他のノードのアカウントに送金

    ```text
    > eth.accounts
    ```

    ```javascript
    ["0x108e30910a05eb43da87a30575afa53ec983a54d"]
    ```

    ```text
    > eth.getBalance(eth.accounts[0])
    ```

    ```javascript
    100000000000000000000
    ```

    ```text
    > eth.sendTransaction({
        to: '0xA206b499ddA19DC1D3b2cb4901a650aACF66b048',
        from: eth.accounts[0],
        value: 25000
    })
    ```

    ```javascript
    "0x100832df75366cb7fd9fd1263b2aa0cd06a594f56bdce0c68fcac28678929a82"
    ```

    ```text
    > eth.getTransaction("0x100832df75366cb7fd9fd1263b2aa0cd06a594f56bdce0c68fcac28678929a82")
    ```

    ```javascript
    {
      accessList: [],
      blockHash: "0x9382eb5aac3ab5faecb06b9dd8c7e3c42dd0ae4f10c99fa45e9aa7bce34fb615",
      blockNumber: 439,
      chainId: "0xc3eb",
      from: "0x108e30910a05eb43da87a30575afa53ec983a54d",
      gas: 21000,
      gasPrice: 1000000007,
      hash: "0x100832df75366cb7fd9fd1263b2aa0cd06a594f56bdce0c68fcac28678929a82",
      input: "0x",
      maxFeePerGas: 1000000014,
      maxPriorityFeePerGas: 1000000000,
      nonce: 0,
      r: "0xd07d715bf222b50e3b302cee8728f29f84943596a188be1a73b67577e71c6292",
      s: "0x35944d9162c69bf1888ffeb18a7e2b6b4e35ce5d206dc55b6606b110b9c6f868",
      to: "0xa206b499dda19dc1d3b2cb4901a650aacf66b048",
      transactionIndex: 0,
      type: "0x2",
      v: "0x0",
      value: 25000
    }
    ```

    ```text
    > eth.getBalance(eth.accounts[0])
    ```

    ```javascript
    99999978999999828000
    ```

    ```text
    > eth.getBalance('0xA206b499ddA19DC1D3b2cb4901a650aACF66b048')
    ```

    ```javascript
    100000000000000025000
    ```

    ```text
    > eth.getBalance('0x25685A527709D66F5EbE024D5Fb5fc0f69a2b877')
    ```

    ```javascript
    100000021000000000000
    ```

    ```text
    > eth.getBlock('0x9382eb5aac3ab5faecb06b9dd8c7e3c42dd0ae4f10c99fa45e9aa7bce34fb615')
    ```

    ```javascript
    {
      baseFeePerGas: 7,
      difficulty: 2,
      extraData: "0xd883010b05846765746888676f312e32302e32856c696e7578000000000000000877eff1384a4037738e24b5706c5bb836fa774004dbc64d0bc907eaf323dde410b0c540903bb80b060fd24b17ef6164c6e701ca3857260e2a29c907495e4c6c01",
      gasLimit: 520969949,
      gasUsed: 21000,
      hash: "0x9382eb5aac3ab5faecb06b9dd8c7e3c42dd0ae4f10c99fa45e9aa7bce34fb615",
      logsBloom: "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      miner: "0x0000000000000000000000000000000000000000",
      mixHash: "0x0000000000000000000000000000000000000000000000000000000000000000",
      nonce: "0x0000000000000000",
      number: 439,
      parentHash: "0x1e1aee8fb078b757ccdbb3d95b75dac562571443fee5f4552df049f6c871ab8a",
      receiptsRoot: "0xf78dfb743fbd92ade140711c8bbc542b5e307f0ab7984eff35d751969fe57efa",
      sha3Uncles: "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
      size: 728,
      stateRoot: "0x29622f7637cae0721558ae3f9b83f0a9c1cbd6ac65ba9b4c65a10b9f5f8644ac",
      timestamp: 1680961557,
      totalDifficulty: 876,
      transactions: ["0x100832df75366cb7fd9fd1263b2aa0cd06a594f56bdce0c68fcac28678929a82"],
      transactionsRoot: "0x241ebd95e583eee0a10322c88beeed9d91cc9bb59e8a8ded2c67c9506cd17cbd",
      uncles: []
    }
    ```

## Clef で Clique のサイニングをおこなう

### 前提

* 大筋は以下のドキュメントに従っている
  * [Clique signing](https://geth.ethereum.org/docs/tools/clef/clique-signing)
* `node1` と書かれている箇所については、`node1`・`node2`・`node3`……と、必要なノード数分繰り返す

### Prepping Clef

1. マスターシードのパスワードを用意する

    ```shell
    mkdir clef-node1
    ```

    ```shell
    touch clef-node1/PASSWORD
    ```

1. `clef-node1/PASSWORD` にパスワードを設定する

    （v1.11.5 時点において、使用できる文字種に制限がある……？）

    改行は不要。

1. Clef 用のボリュームを作る

    ```shell
    docker volume create clef-node1-volume
    ```

1. Clef の初期設定を行うため、client-go のコンテナを一時的に立ち上げ、`sh` にアタッチする

    ```shell
    docker run \
    -v geth-node1-volume:/root/.ethereum \
    -v clef-node1-volume:/root/.clef \
    --mount type=bind,source="$(pwd)"/geth-node1/etherbase,target=/root/etherbase,readonly \
    -it --rm \
    ethereum/client-go:alltools-v1.11.5 \
    /bin/sh
    ```

1. アタッチしたシェルにて、初期設定を行う

    `--chainid` は `geth-node/genesis.json` での設定と合わせる。

    ```shell
    clef --chainid 50155 --suppress-bootwarn init
    ```

    `clef_node1/PASSWORD`に設定したパスワードで初期化する。

    シェルから抜けずに先に進む。

### Storeing passwords in clef

1. 対応する Geth のノードのユーザーのパスワードを保存する

    ```shell
    clef --chainid 50155 --suppress-bootwarn \
    setpw $(cat /root/etherbase)
    ```

    ```shell
    exit
    ```

### Using rules to approve blocks

1. `TLDR quick-version` を参照し、`rules.js` を `clef-node/rules.js` として保存する

    （あとで調整する意図で、 `ApproveTx()`を仕込んでいる。）

1. 再び、client-go のコンテナを一時的に立ち上げ、`sh` にアタッチする

    ```shell
    docker run \
    -v geth-node1-volume:/root/.ethereum \
    -v clef-node1-volume:/root/.clef \
    --mount type=bind,source="$(pwd)"/clef-node/rules.js,target=/root/rules.js,readonly \
    --mount type=bind,source="$(pwd)"/clef-node1/PASSWORD,target=/root/PASSWORD,readonly \
    -it --rm \
    ethereum/client-go:alltools-v1.11.5 \
    /bin/sh
    ```

1. Attest it

    ```shell
    clef --chainid 50155 --suppress-bootwarn \
    attest `sha256sum /root/rules.js | cut -f1` \
    < /root/PASSWORD
    ```

    ```shell
    exit
    ```

### 起動テスト・スクリプトの差し替え

#### 起動テスト

Geth の起動順において、安定しているノード 1が他より先行して起動する必要があるため、まず node3 でテストを行うこととする。
command を一時的に `sleep infinity` にして、clef 用のコンテナ（サービス）を追加。
編集が終わったら、コンテナ群を起動する。

1. `docker-compose.yml` を修正

    ここをコミットした時点の `docker-compose.yml` を参照。

1. コンテナを起動

    ```shell
    docker compose up
    ```

1. 起動テスト

    `sleep infinity` としたコンテナ内のシェルにアタッチし、clef、geth の順にサービスを開始。

    ```shell
    docker compose exec node3-clef /bin/sh
    ```

    ```shell
    clef --chainid 50155 --suppress-bootwarn \
    --rules /root/rules.js \
    --http \
    --http.addr $(hostname -i) \
    < /root/PASSWORD
    ```

    ```shell
    docker compose exec node3 /bin/sh
    ```

    ```shell
    geth -networkid 50155 \
    --nat extip:$(hostname -i) \
    --netrestrict 172.29.0.0/16 \
    --bootnodes $(cat /root/bootnode-enode.txt) \
    --syncmode full \
    --mine \
    --miner.etherbase $(cat /root/etherbase) \
    --signer http://$(hostname -i)0:8550
    ```

    ブロックへのサインが行われていることを確認したら、全サービスを停止する。

#### スクリプトの差し替え

1. clef を起動するスクリプトを用意する

    ```shell
    touch clef-node/boot.sh
    ```

    ```shell
    chmod a+x clef-node/boot.sh
    ```

    `clef-node/boot.sh` での clef 起動時のオプションは起動テストでのものと同一でよい。

1. geth の起動スクリプトを改定する

    順番に移行していくため、既存の `geth-node/boot.sh` は残しておく。
    （`geth-node/boot.sh` はすべてのノードの移行が終わりしだい、削除する。）

    ```shell
    touch geth-node/boot-with-clef.sh
    ```

    ```shell
    chmod a+x geth-node/boot-with-clef.sh
    ```

    `geth-node/boot-with-clef.sh` での geth 起動時のオプションも起動テストのものと同一でよい。
    ただし、`geth-node/boot.sh`で行っているように、任意の時間の待機ができるようにしておく必要がある。

1. `docker-compose.yml`を修正する

    起動テストが終わったコンテナに起動スクリプトをマウントし、
    `sleep infinity` を起動スクリプトに差し替える。

    geth の起動は、clef の起動完了を待つ必要があることに注意。

1. 起動テスト

    ```shell
    docker compose up
    ```

すべてのノードが clef に依存するように変更したら、
`geth-node/boot.sh` を削除する。
