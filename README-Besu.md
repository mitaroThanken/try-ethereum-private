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

1. 起動スクリプトを作る

    Geth の時と同様、起動タイミングの調整等のため、スクリプトを用意する。
    Geth との相違点は主に以下の通り。

    * `bootnode` が使用できない

        代わりに、実存するノードを指定する必要がある（？）。

    * Geth に対する Clef はこの時点ではない

        最終的に「存在しない」となる可能性あり。

    * `miner` 系オプションが不要

        というよりも、`Clique`・`IBFT 2.0`・`QBFT` を選択した場合、無視されるもよう。

        参照）[Options - miner-coinbase](https://besu.hyperledger.org/en/stable/public-networks/reference/cli/options/#miner-coinbase)

    * `sync-mode` は指定不要
  
        プライベートネットワークの場合 `FULL` がデフォルトであるため。

        参照）[Options - sync-mode](https://besu.hyperledger.org/en/stable/public-networks/reference/cli/options/#sync-mode)

    `besu-node/boot.sh` を参照。
