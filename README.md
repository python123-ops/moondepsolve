# MoonDepSolve

[![CI](https://github.com/python123-ops/moondepsolve/actions/workflows/ci.yml/badge.svg)](https://github.com/python123-ops/moondepsolve/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/badge/release-v0.3.0-brightgreen.svg)](CHANGELOG.md)

MoonDepSolve 是面向 MoonBit 包生态的语义版本与依赖求解基础库。它提供版本约束、确定性传递依赖求解、稳定 lock、依赖图、冲突解释，以及 v0.3 新增的精确升级规划能力，可作为包管理器、构建工具、依赖审计和自动化发布工具的基础组件。

MoonDepSolve is a compact MoonBit library and native CLI for semantic versions, deterministic dependency resolution, explainable conflicts, and exact upgrade planning.

- GitLink 主仓库：<https://gitlink.org.cn/python123/moondepsolve>
- GitHub 镜像：<https://github.com/python123-ops/moondepsolve>
- Mooncakes：模块 `python123/moondepsolve` 的 v0.3.0 元数据已就绪，待 `python123` 完成 GitHub 授权后 dry-run 与发布
- 唯一提交身份：`python123 <python123@users.noreply.gitlink.org.cn>`

## v0.3 亮点

- `HighestCompatible`：复用稳定求解器，选择所有约束下的最高兼容版本。
- `MinimalChange`：有界穷举所有有效解，先最小化变更包数量，再以更高版本稳定打破平局；默认最多搜索 100000 个状态。
- `UpgradePlan`：稳定列出 add、remove、upgrade、downgrade，并附带目标 `Resolution`。
- 原生文件 CLI：从 registry/lock 文件执行 `resolve` 和 `plan`，支持 lock、文本图和 Graphviz DOT 输出。
- 可复现演示：四组 expected 输出由 `scripts/demo-v0.3.sh` 逐字比对。

v0.3 仅增加 API，v0.1/v0.2 的 `parse_version`、`parse_req`、`matches`、`resolve`、`format_error`、`format_lock`、依赖图和冲突报告入口保持不变。

## 快速验证

库测试可在默认后端运行：

```bash
python scripts/check_contributor_identity.py
moon info
moon fmt --check
moon check --warn-list '+73-35'
moon test --warn-list=-35
moon run cmd/main --warn-list=-35
```

文件 CLI 使用 `moonbitlang/async/fs`，需要 native 后端和系统 C 编译器：

```bash
moon check --target native --warn-list '+73-35'
moon test --target native --warn-list=-35
sh scripts/demo-v0.3.sh
```

Windows 可在配置了 MSVC/clang 的终端运行，或直接使用 WSL2 + gcc。

## 文件 CLI

示例 registry 使用 `name version | dependency:requirement` 行格式：

```text
app 1.1.0 | core:^1.1.0, logging:1.0.x
core 1.2.0
logging 1.0.0
```

最高兼容求解并输出 lock：

```bash
moon run cmd/cli --target native -- \
  resolve \
  --registry examples/registry.txt \
  --root 'app:^1.0.0' \
  --format lock
```

`--format` 可选 `lock`、`text`、`dot`。`--root NAME:REQ` 可重复传入。

从现有 lock 生成精确最小变更计划：

```bash
moon run cmd/cli --target native -- \
  plan \
  --registry examples/registry.txt \
  --lock examples/current.lock \
  --root 'app:^1.0.0' \
  --strategy minimal \
  --max-states 100000
```

```text
strategy: minimal-change
changes: 0
target lock:
# MoonDepSolve lock
app 1.0.0
core 1.0.0
logging 1.0.0
```

使用 `--strategy highest` 可生成最高兼容升级计划。搜索上限必须为正数；超过上限时返回 `SearchLimitExceeded`，不会把未完成搜索误报为最优解。

## 库 API

| 能力 | API |
| --- | --- |
| 版本 | `parse_version`, `format_version`, `compare_version` |
| 约束 | `parse_req`, `matches` |
| 求解 | `resolve` |
| 索引与 lock | `parse_registry`, `format_lock`, `parse_lock` |
| 基础错误 | `format_error` |
| 依赖图 | `build_dependency_graph`, `format_graph_text`, `format_graph_dot` |
| 冲突报告 | `build_conflict_report`, `format_conflict_report` |
| 升级规划 | `default_upgrade_options`, `plan_upgrade`, `format_upgrade_plan`, `format_upgrade_error` |

v0.3 新增公开模型：

- `UpgradeStrategy`、`UpgradeOptions`
- `UpgradeChangeKind`、`UpgradeChange`
- `UpgradePlan`、`UpgradeError`

精确签名见 [`pkg.generated.mbti`](pkg.generated.mbti)。

## 库调用示例

```moonbit
let options = @moondepsolve.default_upgrade_options(MinimalChange)
match @moondepsolve.plan_upgrade(root, current_lock, registry, options) {
  Ok(plan) => {
    println(@moondepsolve.format_upgrade_plan(plan))
    println(@moondepsolve.format_lock(plan.resolution))
  }
  Err(error) => println(@moondepsolve.format_upgrade_error(error))
}
```

完整内存示例见 [`cmd/main/main.mbt`](cmd/main/main.mbt)，文件工作流见 [`cmd/cli`](cmd/cli) 与 [`examples`](examples)。

## 图与冲突解释

`build_dependency_graph` 始终包含 `Root`。根依赖形成 Root 边，传递依赖形成包间边；手工构造的不完整 `Resolution` 会产生 `Unresolved` 节点。文本与 DOT 输出都采用稳定顺序，DOT 标签会转义引号、反斜杠和换行。

`build_conflict_report` 覆盖 `PackageNotFound`、`NoMatchingVersion`、`VersionConflict`，保留依赖路径，并按版本从高到低列出候选。解析错误仍由 `format_error` 处理。

## 测试与质量

2026-06-21 本地终验基线：

- 默认后端：27 项测试通过。
- native 后端：31 项测试通过，包含 4 项 CLI 参数测试。
- 文件 CLI：4 组真实 registry/lock 输出逐字回归通过。
- `upgrade_plan.mbt` 仅余 5 个未覆盖防御性/私有分支；`cmd/main` 与 native CLI 由真实命令单独验证。
- CI 使用完整 Git 历史，先验证唯一 author/committer，再检查 `.mbti`、格式、诊断、覆盖率、native CLI 和 expected 输出。

兼容说明：公开字段 `ConflictReport.package` 是 v0.2 API。当前编译器将 `package` 标记为未来保留字，因此门禁仅豁免 warning 35；其他诊断仍正常启用。

## 维护与发布

- GitLink `origin/master` 是比赛验收主分支，GitHub `github/master` 是公开镜像。
- 贡献、测试与提交规范见 [`CONTRIBUTING.md`](CONTRIBUTING.md)，安全策略见 [`SECURITY.md`](SECURITY.md)。
- 版本变更见 [`CHANGELOG.md`](CHANGELOG.md)，发布步骤见 [`docs/competition/release-checklist.md`](docs/competition/release-checklist.md)。
- 第三方依赖及许可证见 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)。

Roadmap：

- v0.1：语义版本、约束、内存求解、文本索引与 lock。
- v0.2：稳定依赖图、DOT、结构化冲突报告和维护门禁。
- v0.3：精确升级规划、原生文件 CLI 和可复现验收演示。
- 后续：更完整的索引/lock 格式、性能基准和 Mooncakes 工具链集成。

## 许可证与 AI 辅助声明

项目采用 [Apache-2.0](LICENSE)。实现为本项目独立编写，不复制私有、闭源、商业或许可证不明代码。

AI 可辅助接口讨论、实现、测试和文档，但项目方向、技术边界、提交内容、发布授权与开源合规均由维护者 `python123` 审核负责。
