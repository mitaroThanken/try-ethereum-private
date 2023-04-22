# Hyperledger Besu を参加させる

参照）[Create a private network using Clique](https://besu.hyperledger.org/en/stable/private-networks/tutorials/clique/)

## カスタムイメージの作成・ボリュームの作成・Compose への一時的な追加

以下の理由より、Geth の場合と異なり、Besu のコンテナを「何もしない状態」で
登録し、作業する。

* Hyperledger Besu の Docker イメージでは、デフォルトのデータディレクトリへのボリュームのマウントが推奨されていない

    cf. [Run Besu from Docker image - Start Besu](https://besu.hyperledger.org/en/stable/private-networks/get-started/install/run-docker-image/#start-besu)

* イメージにてユーザー besu が指定されている
* イメージにて ENTRYPOINT が指定されている

以降、Geth の場合と同様、`node1` は適切に読み替えること。

1. データディレクトリ用のボリュームを作る

    ```sh
    docker volume create beth-node1-volume
    ```

1. Dockerfile を作る

    `besu-node/Dockerfile` を参照。

1. `docker-compose.yml` に Besu のサービスを追加する

    この時点では、`entrypoint` で ENTRYPOINT を上書きし、何もしないようにしておく。

    `docker-compose.yml` を参照。

1. `docker compose up`

1. ログから、既存のノードの enode を確保する

    Besu は bootnode を利用したネットワークへの参加ができない（？）。
    したがって、各ノードの enode を bootnodes として指定する必要があり、
    この時点で控えておく。

    `geth-node1/enode` 等を参照。

## アカウントの作成

1. Besu のコンテナにアタッチ

1. Clique にてサインを行うアカウントを作成

    ```sh
    besu --data-path=data public-key export-address
    ```

    ```log
    2023-04-22 13:46:04.915+00:00 | main | INFO  | KeyPairUtil | Generated new secp256k1 public key 0x467cc27d6b759f14e6023be6208cd72088ba72eefa89cbb07285c55387c4f501f1765ec9619f23810c80b3cbd07fc90c16e16819b4695403a88491ba20c6dbf1 and stored it to /opt/besu/data/key
    0xd6c3117c5c3f1e867e2a59cd079827ac70b8691d
    2023-04-22 13:46:04.937+00:00 | main | INFO  | Besu | Using jemalloc
    ```

    上記の場合、 `0xd6c3117c5c3f1e867e2a59cd079827ac70b8691d` がアカウントのアドレス。

1. コンテナを停止する

1. `genesis.json` を更新

    Geth の `genesis.json` と Besu の `genesis.json` は仕様が似ているが異なるところもある。
    Besu には、構成要素についてのドキュメント
    （[Genesis file items](https://besu.hyperledger.org/en/stable/public-networks/reference/genesis-items/)）
    がある。

    * Clique
      * 設定のキーが異なる
        * [Clique - genesis file](https://besu.hyperledger.org/en/stable/private-networks/how-to/configure/consensus/clique/#genesis-file)
        * [Concepts - Genesis file](https://besu.hyperledger.org/en/stable/public-networks/concepts/genesis-file/)
        * [Configure Clique consensus](https://besu.hyperledger.org/en/stable/private-networks/how-to/configure/consensus/clique/)

    `extradata` の仕様は Clique の仕様であるため、Geth・Clique 共通。

    `alloc` も、たまたま同じ（Besu では秘密鍵とコメントを含む形で例示されている箇所が多いが、読む人のためのものであり、システム的には無視される。結果として Geth と同じとなる。）

1. 既存の Geth の全ノードのチェーンを破棄・初期化しなおす

    Geth のデータボリュームを操作するための一時的なコンテナ起動・シェルへのアタッチについては、`README.md` を参照。

    1. データベースを破棄

        `geth removedb`

        cf. [Backup & Restore - Cleanup](https://geth.ethereum.org/docs/fundamentals/backup-restore)

    1. データベースを初期化

        `geth init genesis.json`

-----

besu --genesis-file=genesis.json --data-path=./data --bootnodes=enode://4dd46b11efa7e159cc0eab4175bc7879f8a7b10b70d26047337a08b819d6f27c5cd8a7f5f29e1274da5e854914ad894f75f01d1b7c7666769c0525d9d33e1ab0@172.29.0.1:30303,enode://2bed7c590328862d1a83ddaa7554500a17fecd629545746b1d36d762025b659057ed0ff22b65f5b7a99497a2ba4ffa96eb6656ba710a97bc33b675cd2111a06b@172.29.0.2:30303,enode://3c693d98bf6917327dba9045999c940ea354445e7e9512399fbf86a47b711c8890b209a6e77edfd0a9f00fe2bfb82bb45314e08072d383db0d2d32c3a5e5ff1d@172.29.0.3:30303 --network-id=50155 --p2p-interface=$(hostname -i)
