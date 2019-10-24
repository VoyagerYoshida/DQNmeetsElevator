# DQNmeetsElevator
[DQN meets エレベータs](https://qiita.com/774taro/items/20f8a5d6ee826f3ebac6#%E5%85%8D%E8%B2%AC) のサイトのコードを動くようにしたもの. 

# DEMO
[リプレイデータ](https://s3-us-west-2.amazonaws.com/dqn/lifts/viewer.html?https://s3-us-west-2.amazonaws.com/dqn/lifts/replay/300.json.gz)

# Features
W.I.P

# Requirement
Dockerfile を参照してください.

# Installation
image build
```
sudo docker build . -t elevator/dqn
```

run container by root to update poetry
```
sudo docker run -it -u root  -v $(pwd):/var/www  elevator/dqn bash
```

image rebuild
```
sudo docker build . -t elevator/dqn
```

just run!
```
sudo docker run -it -v $(pwd):/var/www   elevator/dqn bash
```

# Usage
W.I.P

# Note
W.I.P

# Author
W.I.P

# License
W.I.P
