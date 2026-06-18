from pathlib import Path
import hashlib

from docx import Document
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor
from pypdf import PdfReader
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.pdfbase import pdfdoc, pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "docs" / "competition"
PDF_PATH = OUT_DIR / "MoonDepSolve项目申报书.pdf"
DOCX_PATH = OUT_DIR / "MoonDepSolve项目申报书.docx"

TITLE = "MoonDepSolve v0.2 项目申报书"
SUBTITLE = "MoonBit 包生态语义版本与依赖求解基础库"
GITLINK_URL = "https://gitlink.org.cn/python123/moondepsolve"
GITHUB_URL = "https://github.com/python123-ops/moondepsolve"
AUTHOR = "python123"

SECTIONS = [
    (
        "项目定位",
        "MoonDepSolve 面向 MoonBit 包生态，解决版本约束解析、兼容版本选择、传递依赖展开与冲突解释问题，可复用于包管理器、构建工具、依赖审计、自动化发布和教学示例。",
    ),
    (
        "v0.2 核心成果",
        "保持 v0.1 API 兼容；支持 exact、caret、tilde、comparator set、wildcard 与最高兼容求解；支持文本 registry 和 lock 读回；新增稳定 DependencyGraph 文本/DOT 输出、Unresolved 节点，以及覆盖缺包、无匹配版本、已选版本冲突的 ConflictReport。CLI 可同时展示 lock、依赖图和候选版本降序冲突报告。",
    ),
    (
        "技术路线与生态价值",
        "采用“语义版本解析—约束归一化—候选排序—递归求解—图/诊断输出”边界，全部使用 MoonBit 实现，不依赖外部服务。公共接口由 moon info 生成的 .mbti 审核，为 MoonBit 工具链补充可复用、可解释、可测试的依赖求解能力。",
    ),
    (
        "工程质量与公开维护",
        "19 项测试覆盖版本边界、错误索引/lock、求解冲突、图稳定性和 DOT 转义，核心 moondepsolve.mbt 无未覆盖行。CI 拉取完整历史，先检查 author/committer 仅为 python123，再执行接口、格式、覆盖率测试与 CLI。仓库提供 Apache-2.0、README、Changelog、贡献/安全规范和 Issue/PR 模板。",
    ),
    (
        "赛事进度与后续计划",
        "官方开发期为 2026-04-29 至 2026-07-12，验收期为 7 月 13-17 日。4 月 29 日后新增求解/索引/lock、v0.2 图和冲突报告、边界测试、身份门禁、CI 与材料。验收前完成 Mooncakes dry-run 和双远端 fresh clone；v0.3 推进最高兼容升级建议与最小变更升级计划。",
    ),
]


def _compatible_md5(data=b"", **_kwargs):
    return hashlib.md5(data)


pdfdoc.md5 = _compatible_md5


def register_font() -> str:
    for path in [
        Path("C:/Windows/Fonts/msyh.ttc"),
        Path("C:/Windows/Fonts/simhei.ttf"),
        Path("C:/Windows/Fonts/simsun.ttc"),
    ]:
        if path.exists():
            pdfmetrics.registerFont(TTFont("MoonDepSolveCN", str(path)))
            return "MoonDepSolveCN"
    return "Helvetica"


def build_pdf() -> None:
    font = register_font()
    styles = getSampleStyleSheet()
    title_style = ParagraphStyle(
        "TitleCN",
        parent=styles["Title"],
        fontName=font,
        fontSize=22,
        leading=27,
        alignment=TA_CENTER,
        textColor=colors.HexColor("#17365D"),
        spaceAfter=3,
    )
    subtitle_style = ParagraphStyle(
        "SubtitleCN",
        parent=styles["BodyText"],
        fontName=font,
        fontSize=11,
        leading=14,
        alignment=TA_CENTER,
        textColor=colors.HexColor("#4B5563"),
        spaceAfter=11,
    )
    heading_style = ParagraphStyle(
        "HeadingCN",
        parent=styles["Heading2"],
        fontName=font,
        fontSize=13,
        leading=17,
        textColor=colors.HexColor("#1F4D78"),
        spaceBefore=8,
        spaceAfter=3,
    )
    body_style = ParagraphStyle(
        "BodyCN",
        parent=styles["BodyText"],
        fontName=font,
        fontSize=10.2,
        leading=16,
        firstLineIndent=20.4,
        textColor=colors.HexColor("#222222"),
        spaceAfter=2,
    )
    meta_style = ParagraphStyle(
        "MetaCN",
        parent=styles["BodyText"],
        fontName=font,
        fontSize=8.7,
        leading=11.5,
        textColor=colors.HexColor("#263238"),
    )

    document = SimpleDocTemplate(
        str(PDF_PATH),
        pagesize=A4,
        leftMargin=1.25 * cm,
        rightMargin=1.25 * cm,
        topMargin=1.05 * cm,
        bottomMargin=1.05 * cm,
        title=TITLE,
        author=AUTHOR,
        subject=SUBTITLE,
    )
    story = [
        Paragraph(TITLE, title_style),
        Paragraph(SUBTITLE, subtitle_style),
    ]
    metadata = [
        [Paragraph("<b>作者</b>", meta_style), Paragraph(AUTHOR, meta_style),
         Paragraph("<b>许可证</b>", meta_style), Paragraph("Apache-2.0", meta_style)],
        [Paragraph("<b>GitLink</b>", meta_style), Paragraph(GITLINK_URL, meta_style),
         Paragraph("<b>GitHub</b>", meta_style), Paragraph(GITHUB_URL, meta_style)],
    ]
    table = Table(
        metadata,
        colWidths=[1.7 * cm, 6.7 * cm, 1.7 * cm, 8 * cm],
        hAlign="LEFT",
    )
    table.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (-1, -1), font),
                ("BACKGROUND", (0, 0), (0, -1), colors.HexColor("#E8EEF5")),
                ("BACKGROUND", (2, 0), (2, -1), colors.HexColor("#E8EEF5")),
                ("BOX", (0, 0), (-1, -1), 0.45, colors.HexColor("#9AA9B8")),
                ("INNERGRID", (0, 0), (-1, -1), 0.3, colors.HexColor("#C5CDD5")),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5),
                ("TOPPADDING", (0, 0), (-1, -1), 3),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
            ]
        )
    )
    story.extend([table, Spacer(1, 0.15 * cm)])
    for heading, text in SECTIONS:
        story.append(Paragraph(heading, heading_style))
        story.append(Paragraph(text, body_style))
    document.build(story)

    pages = len(PdfReader(str(PDF_PATH)).pages)
    if pages != 1:
        raise RuntimeError(f"Proposal PDF must be exactly one page, got {pages}")


def set_cell_shading(cell, fill: str) -> None:
    properties = cell._tc.get_or_add_tcPr()
    shading = OxmlElement("w:shd")
    shading.set(qn("w:fill"), fill)
    properties.append(shading)


def set_cell_width(cell, width_twips: int) -> None:
    properties = cell._tc.get_or_add_tcPr()
    width = properties.find(qn("w:tcW"))
    if width is None:
        width = OxmlElement("w:tcW")
        properties.append(width)
    width.set(qn("w:w"), str(width_twips))
    width.set(qn("w:type"), "dxa")


def set_run_font(run, name: str, size: float, bold: bool = False) -> None:
    run.font.name = name
    run.font.size = Pt(size)
    run.font.bold = bold
    run._element.get_or_add_rPr().get_or_add_rFonts().set(qn("w:eastAsia"), name)


def build_docx() -> None:
    document = Document()
    section = document.sections[0]
    section.page_width = Cm(21)
    section.page_height = Cm(29.7)
    section.left_margin = Cm(1.25)
    section.right_margin = Cm(1.25)
    section.top_margin = Cm(1.05)
    section.bottom_margin = Cm(1.05)
    section.header_distance = Cm(0.4)
    section.footer_distance = Cm(0.4)

    normal = document.styles["Normal"]
    normal.font.name = "Microsoft YaHei"
    normal.font.size = Pt(10.2)
    normal.paragraph_format.space_after = Pt(2)
    normal.paragraph_format.line_spacing = 1.15

    title = document.add_paragraph()
    title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    title.paragraph_format.space_after = Pt(1)
    run = title.add_run(TITLE)
    set_run_font(run, "Microsoft YaHei", 22, True)
    run.font.color.rgb = RGBColor(0x17, 0x36, 0x5D)

    subtitle = document.add_paragraph()
    subtitle.alignment = WD_ALIGN_PARAGRAPH.CENTER
    subtitle.paragraph_format.space_after = Pt(5)
    run = subtitle.add_run(SUBTITLE)
    set_run_font(run, "Microsoft YaHei", 11)
    run.font.color.rgb = RGBColor(0x4B, 0x55, 0x63)

    table = document.add_table(rows=2, cols=4)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    table.style = "Table Grid"
    widths = [1224, 4824, 1224, 5760]
    rows = [
        ("作者", AUTHOR, "许可证", "Apache-2.0"),
        ("GitLink", GITLINK_URL, "GitHub", GITHUB_URL),
    ]
    for row, values in zip(table.rows, rows):
        for index, (cell, value) in enumerate(zip(row.cells, values)):
            set_cell_width(cell, widths[index])
            cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
            paragraph = cell.paragraphs[0]
            paragraph.paragraph_format.space_after = Pt(0)
            run = paragraph.add_run(value)
            set_run_font(run, "Microsoft YaHei", 8.7, index in (0, 2))
            if index in (0, 2):
                set_cell_shading(cell, "E8EEF5")

    for heading, text in SECTIONS:
        paragraph = document.add_paragraph()
        paragraph.paragraph_format.space_before = Pt(7)
        paragraph.paragraph_format.space_after = Pt(2)
        run = paragraph.add_run(heading)
        set_run_font(run, "Microsoft YaHei", 13, True)
        run.font.color.rgb = RGBColor(0x1F, 0x4D, 0x78)

        paragraph = document.add_paragraph()
        paragraph.paragraph_format.first_line_indent = Pt(20.4)
        paragraph.paragraph_format.space_after = Pt(2)
        paragraph.paragraph_format.line_spacing = 1.15
        run = paragraph.add_run(text)
        set_run_font(run, "Microsoft YaHei", 10.2)

    footer = section.footer.paragraphs[0]
    footer.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run = footer.add_run("MoonDepSolve v0.2 · 2026-06-18")
    set_run_font(run, "Microsoft YaHei", 7.5)
    run.font.color.rgb = RGBColor(0x6B, 0x72, 0x80)

    document.core_properties.title = TITLE
    document.core_properties.subject = SUBTITLE
    document.core_properties.author = AUTHOR
    document.core_properties.last_modified_by = AUTHOR
    document.core_properties.keywords = "MoonBit, dependency resolver, OSC2026"
    document.save(DOCX_PATH)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    build_pdf()
    build_docx()
    print(f"Generated one-page PDF: {PDF_PATH}")
    print(f"Generated DOCX: {DOCX_PATH}")


if __name__ == "__main__":
    main()
