from __future__ import annotations

from pathlib import Path
import re

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    ListFlowable,
    ListItem,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "docs" / "competition"
PDF_PATH = OUT_DIR / "MoonCSV项目申报书.pdf"
DOCX_PATH = OUT_DIR / "MoonCSV项目申报书.docx"

FONT_REGULAR = Path("C:/Windows/Fonts/NotoSansSC-VF.ttf")
FONT_SERIF = Path("C:/Windows/Fonts/NotoSerifSC-VF.ttf")
FONT_FALLBACK = Path("C:/Windows/Fonts/simhei.ttf")


SECTIONS = [
    (
        "项目名称",
        [
            "MoonCSV：MoonBit CSV/表格文本解析、生成与校验库",
        ],
    ),
    (
        "项目简介",
        [
            "MoonCSV 是一个面向 MoonBit 生态的 CSV/表格文本处理基础库，提供 CSV 解析、生成、表头查询、矩形校验、错误诊断和命令行演示。项目目标是补齐 MoonBit 生态中常用数据交换格式处理能力，形成一个可测试、可运行、可复用、可发布到 mooncakes.io 的开源包。",
        ],
    ),
    (
        "项目方向与适用场景",
        [
            "本项目属于格式处理工具和 MoonBit 生态基础库方向，对应大赛推荐方向中的格式特定序列化/反序列化工具和应用生态项目。",
            "CSV 广泛用于日志导出、课程数据、配置表、标注数据、小型数据集和表格交换。MoonCSV 可用于 MoonBit 程序读取表格文本、校验数据形状、按表头访问字段，并重新生成规范 CSV。",
        ],
    ),
    (
        "拟实现的核心功能",
        [
            "支持普通逗号分隔字段解析。",
            "支持双引号字段、双引号转义、字段内换行。",
            "支持 CRLF/LF 换行和尾随空字段。",
            "提供带行列位置的错误诊断，例如未闭合引号、裸引号、引号后非法字符。",
            "提供 CSV 生成能力，自动引用包含逗号、引号或换行的字段。",
            "提供表格辅助功能：读取表头、检测每行列数是否一致、按表头查询单元格。",
            "提供 CLI 示例，可通过 moon run cmd/main 查看解析摘要、表头查询和规范化输出。",
            "提供自动化测试、README、CI、许可证和验收清单。",
        ],
    ),
    (
        "原创性说明",
        [
            "本项目为原创项目，不是移植已有开源项目。项目参考 CSV/RFC 4180 常见工程规则和 MoonBit 官方包开发方式，核心解析器、数据结构、错误诊断、测试和 CLI 示例均围绕 MoonBit 生态重新设计与实现。项目采用 Apache-2.0 开源许可证。",
        ],
    ),
    (
        "技术路线",
        [
            "解析器采用确定性状态机，不依赖外部库。状态机逐字符维护当前字段、当前行、全部行、行列位置、是否处于引号字段，以及引号字段结束后的合法后继字符。生成器使用 StringBuilder 拼接输出，并按 CSV 常见规则对需要引用的字段做转义。",
        ],
    ),
    (
        "当前完成度",
        [
            "已完成 MoonBit 项目骨架、核心解析/生成/校验 API、黑盒测试、CLI 演示、README、CI 配置和参赛文档。当前可通过 moon test 验证，可通过 moon run cmd/main 查看演示输出。",
        ],
    ),
    (
        "后续计划",
        [
            "增加文件输入/输出 CLI。",
            "增加更完整的方言配置：分隔符、引号字符、是否允许空行、是否 trim。",
            "增加 benchmark 和大文件测试样例。",
            "发布到 mooncakes.io，并补充中文技术文章。",
        ],
    ),
]


def _register_fonts() -> str:
    font = FONT_REGULAR if FONT_REGULAR.exists() else FONT_FALLBACK
    pdfmetrics.registerFont(TTFont("MoonCSV-CN", str(font)))
    if FONT_SERIF.exists():
      pdfmetrics.registerFont(TTFont("MoonCSV-Serif", str(FONT_SERIF)))
    return "MoonCSV-CN"


def _esc(text: str) -> str:
    return (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )


def _build_pdf() -> None:
    font = _register_fonts()
    styles = getSampleStyleSheet()
    title = ParagraphStyle(
        "TitleCN",
        parent=styles["Title"],
        fontName=font,
        fontSize=22,
        leading=30,
        alignment=TA_CENTER,
        textColor=colors.HexColor("#203864"),
        spaceAfter=10,
    )
    subtitle = ParagraphStyle(
        "SubtitleCN",
        parent=styles["Normal"],
        fontName=font,
        fontSize=10,
        leading=15,
        alignment=TA_CENTER,
        textColor=colors.HexColor("#5f6f89"),
        spaceAfter=14,
    )
    h2 = ParagraphStyle(
        "HeadingCN",
        parent=styles["Heading2"],
        fontName=font,
        fontSize=13,
        leading=18,
        textColor=colors.HexColor("#203864"),
        spaceBefore=9,
        spaceAfter=6,
    )
    body = ParagraphStyle(
        "BodyCN",
        parent=styles["BodyText"],
        fontName=font,
        fontSize=10.5,
        leading=17,
        alignment=TA_LEFT,
        firstLineIndent=18,
        spaceAfter=5,
    )
    bullet = ParagraphStyle(
        "BulletCN",
        parent=body,
        leftIndent=16,
        firstLineIndent=0,
        bulletIndent=4,
        spaceAfter=4,
    )
    meta = ParagraphStyle(
        "MetaCN",
        parent=styles["BodyText"],
        fontName=font,
        fontSize=9.5,
        leading=14,
        textColor=colors.HexColor("#3b4a60"),
    )

    doc = SimpleDocTemplate(
        str(PDF_PATH),
        pagesize=A4,
        rightMargin=22 * mm,
        leftMargin=22 * mm,
        topMargin=18 * mm,
        bottomMargin=18 * mm,
        title="MoonCSV项目申报书",
        author="px830",
    )
    story = [
        Paragraph("MoonCSV 项目申报书", title),
        Paragraph("MoonBit 国产基础软件生态开源大赛参赛材料", subtitle),
    ]
    meta_table = Table(
        [
            [Paragraph("项目名称", meta), Paragraph("MoonCSV：MoonBit CSV/表格文本解析、生成与校验库", meta)],
            [Paragraph("项目类型", meta), Paragraph("MoonBit 生态基础库 / 格式处理工具", meta)],
            [Paragraph("开源协议", meta), Paragraph("Apache-2.0", meta)],
            [Paragraph("当前状态", meta), Paragraph("核心库、测试、CLI、README、CI 与参赛文档已完成初版", meta)],
        ],
        colWidths=[30 * mm, 122 * mm],
        hAlign="LEFT",
    )
    meta_table.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (-1, -1), font),
                ("BACKGROUND", (0, 0), (0, -1), colors.HexColor("#EAF1F8")),
                ("TEXTCOLOR", (0, 0), (0, -1), colors.HexColor("#203864")),
                ("GRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#B8C6D8")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 7),
                ("RIGHTPADDING", (0, 0), (-1, -1), 7),
                ("TOPPADDING", (0, 0), (-1, -1), 5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
            ]
        )
    )
    story.extend([meta_table, Spacer(1, 8)])

    bullet_sections = {"拟实现的核心功能", "后续计划"}
    for heading, paragraphs in SECTIONS:
        story.append(Paragraph(_esc(heading), h2))
        if heading in bullet_sections:
            items = [
                ListItem(Paragraph(_esc(text), bullet), leftIndent=10)
                for text in paragraphs
            ]
            story.append(
                ListFlowable(
                    items,
                    bulletType="bullet",
                    start="circle",
                    leftIndent=18,
                    bulletFontName=font,
                    bulletFontSize=8,
                )
            )
        else:
            for text in paragraphs:
                story.append(Paragraph(_esc(text), body))
    doc.build(story)


def _set_east_asia_font(run, font_name: str) -> None:
    run.font.name = font_name
    run._element.rPr.rFonts.set(qn("w:eastAsia"), font_name)


def _build_docx() -> None:
    doc = Document()
    section = doc.sections[0]
    section.top_margin = Cm(2)
    section.bottom_margin = Cm(2)
    section.left_margin = Cm(2.2)
    section.right_margin = Cm(2.2)

    styles = doc.styles
    styles["Normal"].font.name = "等线"
    styles["Normal"].font.size = Pt(10.5)
    styles["Normal"]._element.rPr.rFonts.set(qn("w:eastAsia"), "等线")

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run("MoonCSV 项目申报书")
    _set_east_asia_font(r, "等线")
    r.font.size = Pt(22)
    r.font.bold = True
    r.font.color.rgb = RGBColor(32, 56, 100)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run("MoonBit 国产基础软件生态开源大赛参赛材料")
    _set_east_asia_font(r, "等线")
    r.font.size = Pt(10.5)
    r.font.color.rgb = RGBColor(95, 111, 137)

    table = doc.add_table(rows=4, cols=2)
    table.style = "Table Grid"
    rows = [
        ("项目名称", "MoonCSV：MoonBit CSV/表格文本解析、生成与校验库"),
        ("项目类型", "MoonBit 生态基础库 / 格式处理工具"),
        ("开源协议", "Apache-2.0"),
        ("当前状态", "核心库、测试、CLI、README、CI 与参赛文档已完成初版"),
    ]
    for row, (k, v) in zip(table.rows, rows):
        row.cells[0].text = k
        row.cells[1].text = v

    for heading, paragraphs in SECTIONS:
        p = doc.add_paragraph()
        p.style = "Heading 2"
        r = p.add_run(heading)
        _set_east_asia_font(r, "等线")
        r.font.color.rgb = RGBColor(32, 56, 100)
        for text in paragraphs:
            if heading in {"拟实现的核心功能", "后续计划"}:
                para = doc.add_paragraph(style="List Bullet")
            else:
                para = doc.add_paragraph()
                para.paragraph_format.first_line_indent = Pt(21)
            run = para.add_run(text)
            _set_east_asia_font(run, "等线")
            run.font.size = Pt(10.5)
    doc.save(DOCX_PATH)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    _build_pdf()
    _build_docx()
    for path in (PDF_PATH, DOCX_PATH):
        if not path.exists() or path.stat().st_size == 0:
            raise SystemExit(f"failed to create {path}")
        print(f"{path} {path.stat().st_size} bytes")


if __name__ == "__main__":
    main()
