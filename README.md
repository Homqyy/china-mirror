# china-mirror

一键替换各种中国镜像源

## 支持替换列表

### 操作系统

| 命令 | 操作系统 | 版本 |
| --- | --- | --- |
| bash ./os.sh           | Alpine    | latest    |
| ^                      | ^         | 3.20      |
| ^                      | ^         | 3.14      |
| ^                      | Ubuntu    | 22.04     |
| ^                      | ^         | 20.04     |

#### os.sh

要求： 它需要 root 权限;

会替换操作系统的软件源为国内镜像源。

示例：

```bash
sudo bash ./os.sh
```

### 工具

| 命令 | 工具 | 版本 | 支持的操作系统 |
| --- | --- | --- | --- |
| bash ./docker-ce.sh    | docker    | -         | Ubuntu 20.04,22.04,23.04,24.04 |
| bash ./k8s.sh          | kubectl   | -         | Ubuntu |
| bash ./pypi.sh         | pip       | -         | -      |

#### docker-ce.sh

要求： 它需要 root 权限;

会添加 docker-ce 国内镜像源，并自动安装 docker-ce 和 docker-compose。

示例：

```bash
sudo bash ./docker-ce.sh
```

#### k8s.sh

要求： 它需要 root 权限;

会添加 k8s 国内镜像源。并且支持用`--package`参数来安装特定的包，比如：`kubectl`、`kubeadm`等。

示例：

```bash
sudo bash ./k8s.sh --package kubectl
```

#### pypi.sh

会添加 pypi 国内镜像源。

示例：

```bash
bash ./pypi.sh
```

## 开发

### 测试

```bash
prove ./tests
```
