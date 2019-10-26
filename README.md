# DQNmeetsElevator
[DQN meets エレベータs](https://qiita.com/774taro/items/20f8a5d6ee826f3ebac6#%E5%85%8D%E8%B2%AC) のサイトのコードを動くようにしたもの. 

## DEMO
[リプレイデータ](https://s3-us-west-2.amazonaws.com/dqn/lifts/viewer.html?https://s3-us-west-2.amazonaws.com/dqn/lifts/replay/300.json.gz)

## Features
### ソースコードの構造
#### ライブラリ
- lifcon.py : 細々とした定義
- lifcon_dqn.py : DQN の定義
#### コマンド
- lifcon_dqn_init.py : DQN の初期化
- lifcon_dqn_fit.py : DQN のフィッティング
- lifcon_sim.py : シミュレーター
#### 起動スクリプト
- run_iteration.sh : コマンドを順番に呼んで上のアルゴリズムを動かす


## Requirement
Dockerfile を参照してください.

## Installation
対象ディレクトリで terminal を起動し, Makefile を使って Docker を起動する.  
Image Name : elevator/dqn
Working Dir : /var/www
```
[(base) user@~~:~~/DQNmeetsElevator$] make build run
```

## Usage
実験を開始する際は, コンテナ内で run_iteration.sh　を起動する.
```
[root@~~:/var/www#] ./run_iteration.sh
```

また, 実験結果を見るときは viewer.html にクエリで投げる. (元記事では .gz で圧縮されたままのデータを投げているが, Ajax 周りで跳ね返されたので解凍してから投げる仕様に変更した.) なお, Chrome では実行できないため, Firefox などを使用してください.
```
file:///home/usr/Documents/DQNmeetsElevator/viewer.html?/home/usr/Documents/DQNmeetsElevator/replay/1.json
```

## Author
作成者 : VoyagerYoshida  
e-mail : yoshida@ss.cs.osakafu-u.ac.jp

## License
[引用元記事作成者](https://qiita.com/774taro)
