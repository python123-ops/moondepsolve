# MoonDepSolve v0.3 终验清单

官方开发期：2026-04-29 至 2026-07-12；验收期：2026-07-13 至 2026-07-17。

## 功能完成度

- [x] v0.1/v0.2 公共 API 保持兼容。
- [x] 语义版本、五类约束、传递求解和最高兼容选择。
- [x] 文本 registry、稳定 lock 与 lock 读回。
- [x] 结构化依赖图、稳定文本、DOT 和冲突解释。
- [x] `HighestCompatible` 与精确 `MinimalChange` 升级规划。
- [x] add/remove/upgrade/downgrade 稳定变更集与目标 Resolution。
- [x] 非法/耗尽搜索上限和依赖失败的结构化错误。
- [x] 原生文件 CLI 的 `resolve`、`plan`、lock/text/dot 输出。
- [x] 四组 registry/lock expected 输出逐字回归。

## 工程质量

- [x] `moon info` 的 `.mbti` 仅增加计划中的 v0.3 API。
- [x] `moon fmt --check` 与 `moon check --warn-list '+73-35'` 通过。
- [x] 默认后端 27 项、native 后端 31 项测试通过。
- [x] `upgrade_plan.mbt` 仅余 5 个防御性/私有未覆盖分支；CLI 使用真实文件命令验证。
- [x] CI 使用完整历史，身份检查先于 MoonBit 检查。
- [x] CI 覆盖接口、格式、诊断、覆盖率、native CLI 和 expected 输出。
- [x] pre-commit 检查身份、格式、诊断和默认测试套件。
- [x] `.gitattributes` 固定 LF，PDF/DOCX/图片按 binary 管理。

## 文档与开源合规

- [x] README、CHANGELOG、CONTRIBUTING、SECURITY 和 Issue/PR 模板齐全。
- [x] Apache-2.0 许可证保留。
- [x] `moonbitlang/async@0.19.4` 来源与 Apache-2.0 许可证已记录。
- [x] AI 辅助边界和维护者审核责任已说明。
- [x] 一页申报书 Markdown、PDF、DOCX 内容同步。
- [x] 三分钟演示讲稿与 v0.3 发布说明齐全。

## 唯一贡献者与双仓库

- [x] 历史、Git 配置、待提交 author/committer 均由脚本检查。
- [x] 当前可达提交仅为 `python123 <python123@users.noreply.gitlink.org.cn>`。
- [ ] GitHub 与 GitLink 均建立 v0.3 Issue/PR 公开审阅记录。
- [ ] v0.3 分支快进合并到 `master`。
- [ ] GitLink/GitHub `master` 指向同一提交。
- [ ] 两个远端 fresh clone 的身份、测试与 demo 复验通过。

## 发布与展示

- [ ] 创建 annotated `v0.3.0` 标签并同步两个远端。
- [ ] 创建 GitHub/GitLink v0.3.0 Release 或等价发布记录。
- [ ] `python123` 通过 GitHub 授权完成 `moon login`。
- [ ] `moon publish --dry-run` 通过。
- [ ] 最终确认后执行 `moon publish` 并回填 Mooncakes 链接。
- [x] 三分钟演示顺序覆盖定位、求解、DOT、最小变更计划和质量证据。
