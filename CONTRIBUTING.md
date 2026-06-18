# Contributing

感谢关注 MoonDepSolve。GitLink 是比赛主仓库，GitHub 是同步镜像。

## 比赛期参与方式

OSC2026 验收期间，仓库历史实行单一维护者身份门禁：所有提交的 author 与 committer 必须是 `python123 <python123@users.noreply.gitlink.org.cn>`。

- 欢迎通过 Issue 提交错误复现、API 建议、兼容性案例和文档反馈。
- 请先讨论再提供实现思路；比赛期不直接合并外部实质代码补丁。
- 维护者会独立实现经确认的需求，并在 Changelog/Issue 中保留问题来源，不把他人代码错误署名为维护者作品。

## 本地开发

```bash
git config user.name python123
git config user.email python123@users.noreply.gitlink.org.cn
python scripts/check_contributor_identity.py
moon info
moon fmt
moon check --warn-list +73
moon test
moon run cmd/main
```

公共 API 变化必须同步检查 `pkg.generated.mbti`、README、测试和 Changelog。提交信息使用 `feat:`、`fix:`、`test:`、`docs:` 或 `chore:` 前缀。

## 许可证与来源

提交讨论即表示所提供信息可用于 Apache-2.0 项目。不要粘贴私有、闭源、商业或许可证不明代码；引用实现时必须给出项目链接、许可证和参考范围。
