# MoonDepSolve v0.2 终验清单

官方当前开发期：2026-04-29 至 2026-07-12；验收期：2026-07-13 至 2026-07-17。

## 功能

- [x] v0.1 公共 API 保持兼容。
- [x] 语义版本、五类约束、传递求解、最高兼容选择。
- [x] 文本 registry、稳定 lock 与 lock 读回。
- [x] 结构化依赖图、稳定文本与 DOT 输出。
- [x] 未解析节点、DOT 引号/反斜杠/换行转义。
- [x] 缺包、无匹配版本、已选版本冲突报告与候选降序。
- [x] CLI 同时演示 lock、依赖图和冲突报告。

## 工程质量

- [x] `moon info` 的 `.mbti` 仅增加计划中的 v0.2 API。
- [x] `moon fmt --check`、`moon check --warn-list +73`、`moon test` 可执行。
- [x] `moondepsolve.mbt` 无未覆盖行；CLI 使用真实 demo 验证。
- [x] CI 使用完整历史，身份检查先于 MoonBit 检查。
- [x] pre-commit 检查身份与 `moon check --warn-list +73`。
- [x] README、Changelog、贡献指南、安全策略和模板齐全。
- [x] 申报 PDF 恰好一页，DOCX 与 Markdown 内容一致。
- [ ] Mooncakes 登录后 `moon publish --dry-run` 通过（当前非交互终端无法执行 `moon login`）。

## 开源与身份

- [x] Apache-2.0 许可证保留。
- [x] AI 辅助、第三方来源与许可证边界已说明。
- [x] 历史、有效 Git 配置、待提交 author/committer 均由脚本检查。
- [x] 当前提交身份仅为 `python123 <python123@users.noreply.gitlink.org.cn>`。
- [x] 推送后 GitLink/GitHub `master` 指向同一提交。
- [x] 从两个远端 fresh clone 后身份检查、测试和 demo 均通过。

## 验收展示

- [x] 一页申报书突出项目定位、v0.2 成果、MoonBit 价值和公开维护。
- [x] 4 月 29 日后新增功能、测试、文档与门禁可由三次独立提交审阅。
- [ ] 准备 3 分钟演示录屏或讲稿。
- [ ] 实际 Mooncakes 发布后补充 README 包链接。
