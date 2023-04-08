# Try Ethereum - local

WIP

## 前提

* 大筋は以下のドキュメントに従っている
  * [Private Networks](https://geth.ethereum.org/docs/fundamentals/private-network)
* `node1` と書かれている箇所については、`node1`・`node2`・`node3`……と、必要なノード数分繰り返す。

## Geth Init

### 各ノードでの署名用にアカウントを1つずつ作る

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

### ノードを初期化する

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

## Bootnode の準備

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

## ノードを追加する

1. 起動用のスクリプトを用意する

    `geth-node/boot.sh`を参照。

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
