# ISUCON8 予選 環境構築手順

## 前提
* Windows 10 Home
* Virtualbox 5.2.8 r121009
* Vagrant 2.1.4

## 手順

### 作業ディレクトリの作成
* 本ディレクトリを作成
	
	C:\Users\user\isucon8q

### 仮想マシンの作成（ホストOS）
* コマンドプロンプトを起動、作業ディレクトリまで移動

* 文字コードをUTF-8 に変更
	```
	> chcp 65001
	```

* プラグインのインストール
	```
	> vagrant plugin install vagrant-vbguest
	```

* Vagrantfile を作成
	```
	> vagrant init
	```
	
* Vagrantfile を編集
	```
	# -*- mode: ruby -*-
	# vi: set ft=ruby :

	Vagrant.configure("2") do |config|
	  config.vm.box = "centos/7"

	  config.vm.network "private_network", ip: "192.168.33.10"

	  config.vm.synced_folder "./share/etc", "/tmp/etc"
	  config.vm.synced_folder "./share/webapp/go", "/home/isucon/torb/webapp/go"

	  config.vm.provider "virtualbox" do |vb|
	    vb.memory = "1024"
	  end

	  config.ssh.insert_key = false
	end
	```

* 仮想マシンの起動
	```
	> vagrant up
	```

* 仮想マシンにSSH接続
	```
	> vagrant ssh
	```

### アプリ構築（ゲストOS）

* `[vagrant@localhost ~]` でログインしていることを確認

* 必要パッケージのインストール
	```
	$ sudo yum install -y ansible git
	```

* isucon8 予選用リポジトリを /tmp にクローン
	```
	cd /tmp
	git clone https://github.com/isucon/isucon8-qualify.git
	```

* 設定ファイル編集（development）
	```
	$ cd isucon8-qualify/provisioning
	$ vi development
	$ cat development
	[portal_web]
	# ポータルをデプロイするサーバ

	[bench]
	localhost ansible_connection=local

	[webapp1]
	localhost ansible_connection=local

	[webapp2]
	# 競技用webappをデプロイするサーバ(2)

	[webapp3]
	# 競技用webappをデプロイするサーバ(3)
	```
	
* Ansible の実行
	```
	$ ansible-playbook -i development site.yml
	```

### ベンチマーカーの準備

* ユーザのスイッチ
	```
	$ sudo -i -u isucon
	```

* 環境変数の設定
	```
	$ export PATH=$HOME/local/go/bin:$HOME/go/bin:$PATH
	$ # export PATH=$HOME/local/perl/bin:$PATH
	```

* ビルド
	```
	$ cd torb/bench
	$ make deps
	$ make
	```

* 初期データ生成
	```
	$ ./bin/gen-initial-dataset   # ../db/isucon8q-initial-dataset.sql.gz ができる
	```

* MariaDB の起動
	```
	$ systemctl status mariadb
	$ sudo systemctl start mariadb
	```

* データベース初期化
	```
	$ mysql -uroot
	> SELECT user,host FROM mysql.user;
	  → すでに isucon@localhost がいることを確認
	> CREATE USER isucon@'%' IDENTIFIED BY 'isucon';
	> GRANT ALL on torb.* TO isucon@'%';
	> GRANT ALL on torb.* TO isucon@'localhost';
	> \q
	$ cd ..
	$ ./db/init.sh
	```

* ポート開放
	```
	$ sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
	$ sudo firewall-cmd --reload
	$ sudo firewall-cmd --list-all
	  →  ports: 8080/tcp を確認
	```

* 参考実装を動かす(golang)
	```
	$ cd ~/torb/webapp/go
	$ export DB_DATABASE=torb
	$ export DB_HOST=localhost
	$ export DB_PORT=3306
	$ export DB_USER=isucon
	$ export DB_PASS=isucon
	$ make
	  → torb バイナリを確認
	$ ./torb
	```

### 動作確認

* ホストOSのブラウザで http://192.168.33.10:8080/ にアクセス

### ベンチマーク

* もう一つコマンドプロンプトを起動し、`vagrant ssh`

* ベンチマークの実行
	```
	$ sudo -i -u isucon
	$ cd ~/torb/bench
	$ ./bin/bench -h # ヘルプ確認
	$ ./bin/bench -remotes=127.0.0.1:8080 -output result.json
	```

* 結果確認
	```
	$ jq . < result.json
	```







