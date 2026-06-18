# MoonDepSolve v0.2 项目申报书

**参赛作者：** python123

**方向：** MoonBit 工程基础设施与包生态

**许可证：** Apache-2.0
**仓库：** [GitLink 主仓库](https://gitlink.org.cn/python123/moondepsolve) · [GitHub 镜像](https://github.com/python123-ops/moondepsolve)

## 项目定位

MoonDepSolve 是面向 MoonBit 包生态的语义版本与确定性依赖求解基础库。项目解决版本约束解析、兼容版本选择、传递依赖展开和冲突解释问题，可复用于包管理器、构建工具、依赖审计、自动化发布与教学示例。

## v0.2 核心成果

- 保持 v0.1 的 `parse_version`、`parse_req`、`matches`、`resolve`、`format_lock` 等 API 兼容。
- 支持 exact、caret、tilde、comparator set、wildcard，稳定选择最高兼容版本。
- 支持文本 registry 与 lock 读回，便于离线样例和集成测试。
- 新增结构化 `DependencyGraph`，稳定输出文本与 Graphviz DOT；不完整 Resolution 显式生成 `Unresolved` 节点。
- 新增 `ConflictReport`，覆盖缺包、无匹配版本与已选版本冲突，保留依赖路径并按降序列出候选版本。
- CLI 可一次展示 lock、依赖图和冲突报告；核心 `moondepsolve.mbt` 无未覆盖行。

## 技术路线与 MoonBit 价值

项目采用“语义版本解析 -> 约束归一化 -> 候选排序 -> 递归求解 -> 图/诊断输出”的边界。实现全部使用 MoonBit，公共接口由 `moon info` 生成的 `.mbti` 审核，不依赖外部服务。它为 MoonBit 包生态补充可复用的版本约束、依赖求解和可解释诊断能力，也提供一套可直接克隆、测试和扩展的基础软件示例。

## 工程质量与公开维护

项目使用 Apache-2.0；CI 拉取完整历史，先强制检查所有 author/committer 均为 `python123 <python123@users.noreply.gitlink.org.cn>`，再执行 `moon info`、`moon fmt --check`、覆盖率测试和 CLI。仓库包含 README、Changelog、贡献指南、安全策略、Issue/PR 模板、发布清单和一页申报书。AI 仅作为辅助，方向、代码审查与开源合规由维护者负责。

## 赛事计划

官方当前开发期为 **2026-04-29 至 2026-07-12**，验收期为 **7 月 13-17 日**。4 月 29 日后新增工作包括求解/索引/lock、v0.2 图与冲突报告、边界测试、身份门禁、CI、文档与发布材料。验收前完成 Mooncakes dry-run、双远端 fresh clone 复验；后续 v0.3 推进最高兼容升级建议和最小变更升级计划。
