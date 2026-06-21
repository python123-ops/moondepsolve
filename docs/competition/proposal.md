# MoonDepSolve v0.3 项目申报书

**参赛作者：** python123

**方向：** MoonBit 工程基础设施与包生态

**许可证：** Apache-2.0
**仓库：** [GitLink 主仓库](https://gitlink.org.cn/python123/moondepsolve) · [GitHub 镜像](https://github.com/python123-ops/moondepsolve)

## 项目定位

MoonDepSolve 是面向 MoonBit 包生态的语义版本、依赖求解与升级规划基础库。项目覆盖版本约束解析、传递依赖选择、稳定 lock、依赖图、冲突解释和升级方案生成，可复用于包管理器、构建工具、依赖审计与自动化发布流程。

## v0.3 核心成果

- 保持 v0.1/v0.2 的解析、匹配、求解、lock、依赖图和冲突报告 API 兼容。
- 新增 `HighestCompatible` 与精确 `MinimalChange`：先最小化变更包数量，同成本时稳定偏好更高版本；有界搜索超过上限时明确报错。
- 新增结构化 `UpgradePlan`，稳定区分 add、remove、upgrade、downgrade，并返回目标 Resolution。
- 新增原生文件 CLI：从 registry/lock 执行 `resolve` 和 `plan`，输出 lock、文本图或 Graphviz DOT。
- 提供四组 expected 输出与一键演示脚本，真实覆盖文件读取、解析、求解、图导出和升级规划链路。

## 技术路线与 MoonBit 价值

项目采用“版本解析 -> 约束匹配 -> 候选稳定排序 -> 递归求解/有界精确搜索 -> lock/图/诊断输出”的边界。核心算法与公共模型使用 MoonBit 编写，`.mbti` 由 `moon info` 生成审阅；native CLI 使用官方 `moonbitlang/async/fs`。项目为 MoonBit 工具链补充可复用、可解释、可测试的依赖基础能力，也展示了 MoonBit 库 API 与原生文件工具的完整工程路径。

## 工程质量与公开维护

2026-06-21 基线为默认后端 27 项、native 后端 31 项测试通过，另有 4 组 CLI expected 输出回归。CI 使用完整历史，先检查所有 author/committer 均为 `python123 <python123@users.noreply.gitlink.org.cn>`，再检查接口、格式、诊断、覆盖率、native CLI 与演示。仓库提供 Apache-2.0、README、Changelog、贡献/安全规范、Issue/PR 模板、发布清单和第三方许可证记录。

## 赛事进度与交付

官方开发期为 **2026-04-29 至 2026-07-12**，验收期为 **2026-07-13 至 2026-07-17**。4 月 29 日后完成 v0.1 求解基础、v0.2 图与冲突解释、v0.3 精确升级规划和文件 CLI，并持续补充测试、CI、身份门禁和材料。终验交付包括双仓库一致历史、v0.3.0 标签/Release、fresh clone 复验及 Mooncakes dry-run；实际发布由 `python123` 通过 GitHub 授权后执行。
