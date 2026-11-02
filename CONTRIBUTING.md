# Contributing

感谢关注 MoonDepSolve。当前维护在 GitHub 进行，GitLink 保留此前的比赛历史。

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
moon check --deny-warn --warn-list +73
moon test --target all --deny-warn
moon run cmd/main
python scripts/check_cli.py
```

公共 API 变化必须同步检查 `pkg.generated.mbti`、README、测试和 Changelog。提交信息使用 `feat:`、`fix:`、`test:`、`docs:` 或 `chore:` 前缀。

CI 固定使用 MoonBit `0.10.19+97801ee1b`。CLI 回归脚本仅使用 Python 标准库，可在 Windows 与 Linux 上运行。发布前运行 `python scripts/check_package.py` 核对归档内容并检查解压后的所有后端构建；`moon publish --dry-run` 还会验证当前登录账号是否拥有模块命名空间。

## 许可证与来源

提交讨论即表示所提供信息可用于 Apache-2.0 项目。不要粘贴私有、闭源、商业或许可证不明代码；引用实现时必须给出项目链接、许可证和参考范围。
