# MoonDepSolve v0.3.0 发布前检查清单

## 代码、接口与身份

- [ ] `git config user.name` 为 `python123`。
- [ ] `git config user.email` 为 `python123@users.noreply.gitlink.org.cn`。
- [ ] `python scripts/check_contributor_identity.py`。
- [ ] `moon info` 后人工检查 `pkg.generated.mbti`。
- [ ] `moon fmt --check`。
- [ ] `moon check --warn-list '+73-35'`。
- [ ] `moon test --enable-coverage --warn-list=-35` 与 `moon coverage analyze`。
- [ ] `moon run cmd/main --warn-list=-35`。
- [ ] `moon test --target native --warn-list=-35`。
- [ ] `sh scripts/demo-v0.3.sh`。

## 文档与合规

- [ ] README API、CLI、Roadmap、版本和 Mooncakes 状态一致。
- [ ] CHANGELOG、CONTRIBUTING、SECURITY、Issue/PR 模板齐全。
- [ ] Apache-2.0、AI 辅助声明和第三方依赖记录完整。
- [ ] 一页 PDF 页数断言通过，PDF/DOCX 渲染无裁切、重叠或缺字。
- [ ] `docs/competition/release-notes-v0.3.md` 与标签内容一致。

## Mooncakes

- [ ] `moon login` 由 `python123` 使用 GitHub 授权码完成。
- [ ] `moon publish --dry-run` 通过。
- [ ] `moon.mod` 名称、版本、README、仓库和许可证元数据正确。
- [ ] 发布前确认工作树干净且 `master` 已同步。
- [ ] 执行 `moon publish` 后记录包链接、版本和发布时间。

## 双仓库

- [ ] 所有新增提交的 author/committer 均为 python123。
- [ ] GitHub/GitLink Issue 与 PR/MR 记录可公开访问。
- [ ] 快进合并到 `master`。
- [ ] `git push origin master` 与 `git push github master`。
- [ ] 两个远端 `master` SHA 一致。
- [ ] annotated `v0.3.0` 标签同步两个远端。
- [ ] 两个 fresh clone 的身份检查、测试和 demo 通过。
