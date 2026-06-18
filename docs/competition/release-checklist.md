# MoonDepSolve v0.2 发布前检查清单

## 代码、接口与身份

- [ ] `git config user.name` 为 `python123`。
- [ ] `git config user.email` 为 `python123@users.noreply.gitlink.org.cn`。
- [ ] `python scripts/check_contributor_identity.py`。
- [ ] `moon info`，人工检查 `pkg.generated.mbti`。
- [ ] `moon fmt --check`。
- [ ] `moon check --warn-list +73`。
- [ ] `moon test --enable-coverage` 与 `moon coverage analyze`。
- [ ] `moon run cmd/main`。

## 文档与合规

- [ ] README API、示例、Roadmap、版本和 Mooncakes 状态一致。
- [ ] CHANGELOG、CONTRIBUTING、SECURITY、Issue/PR 模板齐全。
- [ ] Apache-2.0、AI 辅助声明和第三方来源记录完整。
- [ ] 一页 PDF 页数断言通过，DOCX 渲染无裁切、重叠或缺字。

## Mooncakes

- [ ] `moon login` 完成。
- [ ] `moon publish --dry-run` 通过。
- [ ] 本轮不执行实际 `moon publish`。
- [ ] 实际发布后记录包链接、版本和发布时间。

## 双仓库

- [ ] 三个计划提交的 author/committer 均为 python123。
- [ ] 快进合并到 `master`。
- [ ] `git push origin master` 与 `git push github master`。
- [ ] 两个远端 `master` SHA 一致。
- [ ] 两个 fresh clone 的身份检查、测试和 demo 通过。
