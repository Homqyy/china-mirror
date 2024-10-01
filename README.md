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

### 工具

| 命令 | 工具 | 版本 | 支持的操作系统 |
| --- | --- | --- | --- |
| bash ./k8s.sh          | kubectl   | -         | Ubuntu |
| bash ./pypi.sh         | pip       | -         | -      |

## 开发

### 测试

```bash
prove ./tests
```
