# MoonCSV 验收清单

## 比赛基础要求

- [x] MoonBit 是主要实现语言。
- [x] 仓库包含 Apache-2.0 开源许可证。
- [x] README 说明项目目标、安装/运行、API 和示例。
- [x] 提供可运行示例：`moon run cmd/main`。
- [x] 提供自动化测试：`moon test`。
- [x] 提供 CI 配置：`.github/workflows/ci.yml`。
- [x] 提供一页项目申报书：`docs/competition/proposal.md`。
- [ ] 发布公开仓库链接后，更新 `moon.mod` 的 `repository` 字段。
- [ ] 发布 mooncakes.io 后，在 README 中补充安装方式。

## 功能验收

- [x] 普通逗号分隔字段。
- [x] 双引号字段。
- [x] 双引号转义。
- [x] 引号字段内换行。
- [x] CRLF 与 LF 换行。
- [x] 尾随空字段。
- [x] CSV 生成与必要字段引用。
- [x] 行列数一致性校验。
- [x] 按表头查询单元格。
- [x] 带行列位置的错误格式化。

## 后续增强

- [ ] CLI 支持读取文件路径。
- [ ] 支持更多方言配置。
- [ ] 增加 benchmark。
- [ ] 增加 mooncakes.io 发布说明。
