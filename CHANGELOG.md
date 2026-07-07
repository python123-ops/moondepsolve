# Changelog

本项目遵循语义化版本号，所有重要变更记录在此文件。

## [0.3.1] - 2026-07-08

### Changed

- Renamed `ConflictReport.package` to `ConflictReport.package_name` to remove the MoonBit reserved-keyword warning raised by strict OSC2026 quality gates.
- Kept formatted conflict-report text stable: CLI and report output still use the label `package: ...`.
- Updated CI and local verification docs to run `moon check --deny-warn`, `moon test --deny-warn`, and native backend checks without warning 35 suppression.

## [0.3.0] - 2026-06-21

### Added

- 新增 `HighestCompatible` 与精确 `MinimalChange` 升级策略。
- 新增 `UpgradeOptions`、`UpgradePlan`、`UpgradeChange`、`UpgradeError` 及稳定文本格式化 API。
- 新增有界搜索上限；搜索未完成时返回 `SearchLimitExceeded`，不输出伪最优解。
- 新增 `cmd/cli` 原生文件 CLI，支持 `resolve`、`plan`、lock、文本图和 Graphviz DOT。
- 新增 registry/lock 示例、四组 expected 输出和 `scripts/demo-v0.3.sh` 回归脚本。
- 新增升级规划与 CLI 参数测试，默认后端 27 项、native 后端 31 项测试通过。

### Changed

- 模块版本升级为 `0.3.0`，保持 v0.1/v0.2 公共 API 兼容。
- CI 增加 native 构建、CLI 测试、expected 输出比对和完整历史身份门禁。
- `.gitattributes` 固定文本 LF，避免 Windows/WSL 维护产生无意义换行差异。
- pre-commit 同时检查唯一贡献者身份、格式、诊断和默认测试套件。

### Dependencies

- 新增 `moonbitlang/async@0.19.4`，仅用于原生 CLI 的异步文件访问；许可证为 Apache-2.0。

## [0.2.0] - 2026-06-18

### Added

- 新增结构化 `DependencyGraph`、稳定文本输出和 Graphviz DOT 输出。
- 新增 `ConflictReport`，覆盖缺包、无匹配版本和已选版本冲突。
- 新增候选版本降序展示、未解析图节点和 DOT 标签转义。
- 新增贡献者身份检查、完整历史 CI 门禁和 pre-commit 检查。
- 新增贡献指南、安全策略、Issue/PR 模板和 v0.2 验收材料。

### Changed

- CLI 同时演示 lock、依赖图和结构化冲突报告。
- 扩充解析、求解、图和冲突测试；核心 `moondepsolve.mbt` 无未覆盖行。
- 版本元数据升级为 `0.2.0`，保持 v0.1 公共 API 兼容。

## [0.1.0] - 2026-06-12

### Added

- 语义版本解析、比较和五类版本约束。
- 确定性传递依赖求解、错误路径和稳定 lock。
- 轻量文本 registry、lock 读回、CLI、测试、CI 和竞赛材料。
