# MoonDepSolve v0.3 三分钟演示稿

## 0:00-0:30 项目定位

打开 README 与仓库首页：MoonDepSolve 面向 MoonBit 包生态，提供语义版本、传递依赖求解、依赖图、冲突解释和精确升级规划。说明 GitLink 为赛事主仓库、GitHub 为镜像，历史提交身份仅为 python123。

## 0:30-1:10 文件求解与依赖图

展示 `examples/registry.txt`，运行：

```bash
moon run cmd/cli --target native -- \
  resolve --registry examples/registry.txt \
  --root 'app:^1.0.0' --format lock
```

结果稳定选择 `app 1.1.0`、`core 1.2.0`、`logging 1.0.0`。将格式改为 `dot`，说明 Root 边、传递边和约束标签均可供 Graphviz 或审计工具消费。

## 1:10-2:00 精确升级规划

打开 `examples/current.lock`，运行 minimal：

```bash
moon run cmd/cli --target native -- \
  plan --registry examples/registry.txt \
  --lock examples/current.lock \
  --root 'app:^1.0.0' --strategy minimal
```

说明该 lock 已满足约束，因此最小变更为 0；再运行 `--strategy highest`，展示 app/core 两项升级。强调 MinimalChange 会枚举有效解，先最小化变更包数量，同成本时偏好更高版本；超过 `--max-states` 会报错，不会伪造最优结果。

## 2:00-2:35 可解释性与边界

展示结构化 `ConflictReport`、候选版本降序和依赖路径；指出 lock 是轻量交换格式，依赖边保留在 registry/graph 中。说明 v0.3 只新增 API，v0.1/v0.2 入口保持兼容。

## 2:35-3:00 工程证据

展示 CI 与终端结果：默认后端 27 项、native 31 项测试通过，四组 CLI 输出逐字比对通过。运行：

```bash
python scripts/check_contributor_identity.py
sh scripts/demo-v0.3.sh
```

最后展示 Apache-2.0、THIRD_PARTY_NOTICES、CHANGELOG、一页申报书和双仓库同 SHA；说明 Mooncakes 发布由 python123 通过 GitHub 授权完成。
