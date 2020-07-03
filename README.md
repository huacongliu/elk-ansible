ELK-Ansible 是基于 [Ansible 2.6+](https://docs.ansible.com/ansible/latest/index.html) [Playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html) 研发的 [ELK](https://www.elastic.co) 快速部署工具


## 一、组件简介：

| **组件** | **功能** |
| --- | --- |
| Filebeat | 监视日志源，采集日志 |
| Logstash | 解析、清洗、转化日志 |
| Elasticsearch | 存储数据并提供分析查询能力 |
| Kibana | 绘制并展示图表 |
| Kafka （可选） | 消息发布订阅系统，用来暂存从Filebeat到Logstash之间的数据 |


## 二、ELK部署准备

#### 1. 中控服务器一台，参考配置：

  - CPU-1核，内存-2GB，硬盘16GB 可以运行
  - 与所有目标服务器网络互通
  - 系统版本 CentOS 7
  - 准备好ELK-Ansible程序包（可以从互联网下载，地址参考以下详细文档）

#### 2. 目标服务器若干台（至少一台，可以是中控服务器），参考配置：

  - CPU-1核，内存-2GB，硬盘16GB 可以运行
  - 服务器之间网络互通
  - 系统版本 CentOS 7


## 三、中控服务器安装配置

#### 1. 安装依赖包

```bash
yum -y install epel-release git curl sshpass vim wget
yum install ansible  # version >= 2.6
```

#### 2. 下载并解压 elk-ansible 程序包


```bash
cd /opt
wget https://github.com/chinaboy007/elk-ansible/archive/master.zip
tar -zxvf master.tar.gz
```


## 四、目标服务器安装配置

#### 1. 登录中控服务器，创建ssh密钥对

```bash
ssh-keygen -t rsa
#
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
4e:f8:b6:c4:1f:c3:1d:2a:b1:10:ba:65:39:74:2f:08 root@localhost
The key's randomart image is:
+--[ RSA 2048]----+
|                 |
|                 |
|    E o .        |
|     + * .       |
|    . O S . .    |
|     + B = o .   |
|    .   O = .    |
|       o + o     |
|        . .      |
+-----------------+
```

#### 2. 在中控服务器上，将所有目标服务器 ip 地址添加到 elk-ansible 程序的 hosts 文件中并执行初始化命令

- 修改文件 elk-ansible/hosts
- 将所有目标服务器 ip 地址添加到 [all_nodes] 下面

```ini
[all_nodes]
192.168.10.72
192.168.10.73
```

- 执行以下命令进行初始化

```bash
cd elk-ansible
ansible-playbook -k playbooks/init_node.yml
```

#### 3. 参考 elk-ansible/hosts 参数简介

| 参数 | 含义 |
| --- | --- |
| [all_nodes]  | 所有目标服务器列表，可以同时配置登录方式（默认通过sshkey免密登录）及登录用户 |
| [all_nodes:vars]  | 全局变量，所有目标服务器有效 |
| install_root_path | 组件默认安装目录 |
| [elasticsearch] | 安装ES的服务器列表，这些服务器节点将组成ES集群 |
| [elasticsearch:vars]  | ES局部变量 |
| data_path | ES数据存放目录 |
| cluster_name | ES集群名称 |
| [logstash] | 安装logstash的服务器列表 |
| [kibana]  | 安装kibana的服务器列表 |
| [filebeat] | 安装filebeat的服务器列表 |
| [filebeat:vars] | filebeat局部变量 |
| filebeat_log_path | 监视并采集日志的路径 |
| kafka_topic | 输出到的kafka队列名称，可选 |
| [kafka] | 安装kafka的服务器列表，可选 |
| [kafka_zookeeper] | 安装kafka内置zookeeper的服务器列表，可选 |


## 五、按两种部署场景进行配置

#### 1. 包含 Kafka 的场景示例

| 服务器 | 角色 |
| --- | --- |
| 192.168.10.72 | ansible 中控 |
| 192.168.10.73  | elasticsearch、logstash、filebeat |
| 192.168.10.74 | elasticsearch、logstash、filebeat |
| 192.168.10.75 | elasticsearch、logstash、filebeat、kibana、kafka |

hosts 配置修改示例：

```ini
[all_nodes]
192.168.10.73
192.168.10.74
192.168.10.75

############################### Elasticsearch
[elasticsearch]
192.168.10.73
192.168.10.74
192.168.10.75

############################### Logstash
[logstash]
192.168.10.73
192.168.10.74
192.168.10.75

############################### Kafka
[kafka]
192.168.10.75

[kafka_zookeeper]
192.168.10.75

############################### Filebeat
[filebeat]
192.168.10.73
192.168.10.74
192.168.10.75

############################### Kibana
[kibana]
192.168.10.75
```

#### 2. 不包含 Kafka 的场景示例

| 服务器 | 角色 |
| --- | --- |
| 192.168.10.72 | ansible 中控 |
| 192.168.10.73  | elasticsearch、logstash、filebeat |
| 192.168.10.74 | elasticsearch、logstash、filebeat |
| 192.168.10.75 | elasticsearch、logstash、filebeat、kibana |

hosts 配置修改示例：

```ini
[all_nodes]
192.168.10.73
192.168.10.74
192.168.10.75

############################### Elasticsearch
[elasticsearch]
192.168.10.73
192.168.10.74
192.168.10.75

############################### Logstash
[logstash]
192.168.10.73
192.168.10.74
192.168.10.75

############################### Kafka
[kafka]

[kafka_zookeeper]

############################### Filebeat
[filebeat]
192.168.10.73
192.168.10.74
192.168.10.75

############################### Kibana
[kibana]
192.168.10.75
```


## 六、执行部署脚本

```bash
bash ./deploy.sh
```
