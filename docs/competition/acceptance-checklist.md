# MoonDepSolve 终验清单

本清单面向 MoonBit OSC2026 终验与优秀项目评选准备。GitLink 仓库是主验收仓库，GitHub 仓库作为同步镜像。

## 功能验收

- [ ] `parse_version` 能解析稳定版本和 prerelease 版本。
- [ ] `compare_version` 能正确比较 major、minor、patch 和 prerelease。
- [ ] `parse_req` 能解析 exact、caret、tilde、comparator set、wildcard。
- [ ] `matches` 能判断版本是否满足约束。
- [ ] `resolve` 能完成根依赖和传递依赖求解。
- [ ] `resolve` 默认选择最高兼容版本。
- [ ] 冲突场景能返回包含依赖路径的错误说明。
- [ ] `format_lock` 输出稳定，便于测试和后续锁文件扩展。
- [ ] `parse_lock` 能把稳定 lock 输出读回 `Resolution`。
- [ ] `parse_registry` 能从轻量文本索引读入包、版本和依赖约束。
- [ ] `moon run cmd/main` 能展示可运行示例。

## 工程验收

- [ ] `moon check` 执行成功。
- [ ] `moon test` 全部通过。
- [ ] `moon run cmd/main` 输出可复现 demo。
- [ ] `moon info && moon fmt` 执行成功，`.mbti` 变化符合预期。
- [ ] CI 保留 `moon info`、`moon fmt --check`、`moon test`、`moon run cmd/main`。
- [ ] `README.md` 是普通文件，包含安装、运行、API、示例、错误诊断、Roadmap、许可证和双仓库说明。
- [ ] `LICENSE` 为 OSI 认可许可证，本项目使用 Apache-2.0。
- [ ] `docs/competition/MoonDepSolve项目申报书.pdf` 和 `.docx` 与 README、当前 API 和仓库链接一致。

## 开源合规

- [ ] 仓库公开可访问，GitLink 链接为 `https://gitlink.org.cn/python123/moondepsolve`。
- [ ] GitHub 镜像链接为 `https://github.com/python123-ops/moondepsolve`。
- [ ] 2026-04-29 之后的有效 commits 能体现功能、测试、文档、发布准备和维护痕迹。
- [ ] 若参考其他生态 semver 或 resolver 实现，在文档中说明参考来源、链接和许可证。
- [ ] 不提交未经授权的私有代码、闭源代码、商业代码或来源不明的生成内容。
- [ ] AI 辅助仅用于代码、测试、文档和分析，提交内容由维护者审阅。

## 发布与展示

- [ ] 版本号、`moon.mod` 元数据、README 和 `.mbti` 保持一致。
- [ ] 准备 Mooncakes 发布说明；发布后补充 Mooncakes 链接。
- [ ] 准备 3 分钟展示材料：问题背景、核心 API、文本索引 demo、冲突诊断、测试与 CI。
- [ ] 验收前运行 `moon coverage analyze > uncovered.log`，根据未覆盖区域补测试或在验收说明中解释。
- [ ] 双远端同步：`origin/master` 和 `github/master` 指向同一验收提交。

## 当前初审风险处理

- [x] 项目方向已从旧项目叙述调整为 MoonBit 包生态基础软件方向。
- [x] 项目名称、README、申报书和 CLI 均使用 MoonDepSolve。
- [x] 仓库保留原有提交历史，并继续以公开提交体现新增工作量。
- [x] README 已明确 GitLink 主仓库与 GitHub 镜像关系。
