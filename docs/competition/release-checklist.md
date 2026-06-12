# MoonDepSolve 发布前检查清单

用于每次准备 GitLink/GitHub 同步、Mooncakes 发布或比赛验收前的最后检查。

## 代码与接口

- [ ] `moon check`
- [ ] `moon test`
- [ ] `moon run cmd/main`
- [ ] `moon info`
- [ ] `moon fmt`
- [ ] 检查 `pkg.generated.mbti` 和 `cmd/main/pkg.generated.mbti`，确认公开 API 变化符合本次发布目标。

## 文档与材料

- [ ] README 的 API 表、示例、Roadmap 和许可证说明与当前代码一致。
- [ ] `docs/competition/acceptance-checklist.md` 已更新。
- [ ] `docs/competition/proposal.md` 已更新。
- [ ] 重新生成 `docs/competition/MoonDepSolve项目申报书.pdf`。
- [ ] 重新生成 `docs/competition/MoonDepSolve项目申报书.docx`。
- [ ] 如已发布 Mooncakes 包，README 中补充包链接和安装方式。

## 开源合规

- [ ] `LICENSE` 保持 Apache-2.0。
- [ ] 新增代码没有复制未经授权的私有、闭源、商业或来源不明内容。
- [ ] 如参考第三方项目，README 或设计文档中记录项目链接、许可证和参考范围。
- [ ] AI 辅助生成内容已由维护者审阅。

## 双仓库同步

- [ ] 本地工作树干净，只包含本次计划内变更。
- [ ] 提交信息使用 `feat:`、`fix:`、`test:`、`docs:` 或 `chore:` 前缀。
- [ ] 推送到 GitLink：`git push origin master`
- [ ] 推送到 GitHub：`git push github master`
- [ ] 两个远端的目标分支指向同一提交。

## 终验展示

- [ ] 准备 3 分钟 demo：文本包索引、求解结果、lock 输出、冲突诊断。
- [ ] 准备 1 页项目亮点：MoonBit 生态价值、核心 API、测试与 CI、后续维护计划。
- [ ] 验收前运行 `moon coverage analyze > uncovered.log`，根据结果补测试或记录风险。
