# MoonCSV 一页项目申报书

## 项目名称

MoonCSV：MoonBit CSV/表格文本解析、生成与校验库

## 项目方向

运行时与系统能力中的格式处理工具，同时也是可发布的 MoonBit 生态基础库。项目对应比赛推荐方向中的“Format-specific serialization / deserialization tools”和“Application ecosystem”。

## 背景与痛点

CSV 是日志导出、课程数据、标注数据、小型数据集和配置表中最常见的交换格式之一。MoonBit 生态正在成长，需要一批小而可靠的基础库来覆盖真实工程场景。一个可测试的 CSV 库可以帮助 MoonBit 程序快速读取表格文本、输出规范 CSV，并在数据不规则时给出可解释错误。

## 项目目标

首版完成一个纯 MoonBit 核心库和一个命令行演示：

- 支持普通字段、双引号字段、双引号转义、CRLF/LF 换行、尾随空字段。
- 提供 `Document`、`Dialect`、`CsvError`、`Position` 等公开类型。
- 提供解析、生成、表头查询、矩形校验、错误格式化和摘要 API。
- 提供 `moon test` 自动化测试和 `moon run cmd/main` 可运行演示。
- 补齐 README、CI、许可证和验收清单，为后续发布到 mooncakes.io 做准备。

## 技术路线

解析器采用确定性状态机，不依赖外部库。状态机逐字符维护当前字段、当前行、全部行、行列位置、是否处于引号字段，以及引号字段结束后的合法后继字符。生成器使用 `StringBuilder` 拼接输出，并按 CSV 常见规则对需要引用的字段做转义。

## 创新与价值

项目价值不在于把题目做大，而在于做成一个可复用、可验证、可发布的生态组件：

- API 小，适合初学者学习 MoonBit 包结构和错误处理。
- 测试覆盖真实 CSV 边界，便于长期维护。
- CLI 示例和文档完整，适合比赛展示。
- 后续可扩展文件 IO、流式解析、方言配置、类型推断和 benchmark。

## 当前完成度

已完成 MoonBit 项目骨架、核心解析/生成/校验 API、黑盒测试、CLI 演示、README、CI 配置和参赛文档。当前可通过 `moon test` 验证，可通过 `moon run cmd/main` 查看演示输出。

## 后续计划

- 增加文件输入/输出 CLI。
- 增加更完整的方言配置：分隔符、引号字符、是否允许空行、是否 trim。
- 增加 benchmark 和大文件测试样例。
- 发布到 mooncakes.io，并补充中文技术文章。
