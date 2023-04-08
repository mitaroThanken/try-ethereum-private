# Try Ethereum - local

WIP

## 前提

* 大筋は以下のドキュメントに従っている
  * [Private Network](https://geth.ethereum.org/docs/fundamentals/private-network)
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

    [Private Network](https://geth.ethereum.org/docs/fundamentals/private-network) の
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
