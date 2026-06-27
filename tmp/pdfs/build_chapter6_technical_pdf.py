from pathlib import Path
import re

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (
    BaseDocTemplate,
    Frame,
    PageBreak,
    PageTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "output" / "pdf" / "aast_connect_chapter_6_technical_implementation_source.md"
OUTPUT = ROOT / "output" / "pdf" / "aast_connect_chapter_6_technical_implementation.pdf"


def clean_inline(text: str) -> str:
    text = text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    text = re.sub(r"`([^`]+)`", r"<font name='Courier'>\1</font>", text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", text)
    return text


def make_styles():
    base = getSampleStyleSheet()
    return {
        "title": ParagraphStyle(
            "Title",
            parent=base["Title"],
            fontName="Helvetica-Bold",
            fontSize=22,
            leading=28,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#1F3A5F"),
            spaceAfter=12,
        ),
        "subtitle": ParagraphStyle(
            "Subtitle",
            parent=base["BodyText"],
            fontName="Helvetica",
            fontSize=10,
            leading=14,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#5E6B7A"),
            spaceAfter=16,
        ),
        "h2": ParagraphStyle(
            "Heading2",
            parent=base["Heading2"],
            fontName="Helvetica-Bold",
            fontSize=14,
            leading=18,
            textColor=colors.HexColor("#244E7A"),
            spaceBefore=12,
            spaceAfter=6,
            keepWithNext=True,
        ),
        "h3": ParagraphStyle(
            "Heading3",
            parent=base["Heading3"],
            fontName="Helvetica-Bold",
            fontSize=11.5,
            leading=15,
            textColor=colors.HexColor("#2F5D83"),
            spaceBefore=9,
            spaceAfter=4,
            keepWithNext=True,
        ),
        "body": ParagraphStyle(
            "Body",
            parent=base["BodyText"],
            fontName="Helvetica",
            fontSize=9.4,
            leading=13.2,
            alignment=TA_LEFT,
            spaceAfter=6,
        ),
        "bullet": ParagraphStyle(
            "Bullet",
            parent=base["BodyText"],
            fontName="Helvetica",
            fontSize=9.2,
            leading=12.8,
            leftIndent=14,
            firstLineIndent=-7,
            spaceAfter=3.5,
        ),
        "table": ParagraphStyle(
            "TableText",
            parent=base["BodyText"],
            fontName="Helvetica",
            fontSize=8.1,
            leading=10.5,
            spaceAfter=0,
        ),
        "table_header": ParagraphStyle(
            "TableHeader",
            parent=base["BodyText"],
            fontName="Helvetica-Bold",
            fontSize=8.2,
            leading=10.5,
            textColor=colors.white,
            spaceAfter=0,
        ),
    }


class ChapterDoc(BaseDocTemplate):
    def __init__(self, filename: str):
        super().__init__(
            filename,
            pagesize=A4,
            rightMargin=20 * mm,
            leftMargin=20 * mm,
            topMargin=18 * mm,
            bottomMargin=18 * mm,
        )
        frame = Frame(
            self.leftMargin,
            self.bottomMargin,
            self.width,
            self.height,
            id="normal",
        )
        self.addPageTemplates(
            [
                PageTemplate(
                    id="chapter",
                    frames=[frame],
                    onPage=draw_header_footer,
                )
            ]
        )


def draw_header_footer(canvas, doc):
    canvas.saveState()
    width, height = A4
    canvas.setStrokeColor(colors.HexColor("#D8E1EA"))
    canvas.setLineWidth(0.5)
    canvas.line(20 * mm, height - 13 * mm, width - 20 * mm, height - 13 * mm)
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(colors.HexColor("#5E6B7A"))
    canvas.drawString(20 * mm, height - 10 * mm, "AAST Connect - Chapter 6 Technical Implementation")
    canvas.drawRightString(width - 20 * mm, 10 * mm, f"Page {doc.page}")
    canvas.restoreState()


def parse_table(lines, start, styles):
    rows = []
    i = start
    while i < len(lines) and lines[i].strip().startswith("|"):
        row = [cell.strip() for cell in lines[i].strip().strip("|").split("|")]
        rows.append(row)
        i += 1
    if len(rows) >= 2 and all(set(cell) <= {"-", ":", " "} for cell in rows[1]):
        rows.pop(1)

    table_data = []
    for r_index, row in enumerate(rows):
        style_name = "table_header" if r_index == 0 else "table"
        table_data.append([Paragraph(clean_inline(cell), styles[style_name]) for cell in row])

    col_widths = [46 * mm, 104 * mm] if rows and len(rows[0]) == 2 else None
    table = Table(table_data, colWidths=col_widths, hAlign="LEFT", repeatRows=1)
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#244E7A")),
                ("GRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#C9D4DF")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ("TOPPADDING", (0, 0), (-1, -1), 5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F6F9FC")]),
            ]
        )
    )
    return table, i


def build_story(markdown: str):
    styles = make_styles()
    story = []
    lines = markdown.splitlines()
    i = 0
    pending_para = []

    def flush_para():
        if pending_para:
            text = " ".join(part.strip() for part in pending_para).strip()
            if text:
                story.append(Paragraph(clean_inline(text), styles["body"]))
            pending_para.clear()

    while i < len(lines):
        line = lines[i].rstrip()
        stripped = line.strip()

        if not stripped:
            flush_para()
            i += 1
            continue

        if stripped.startswith("|"):
            flush_para()
            table, i = parse_table(lines, i, styles)
            story.append(table)
            story.append(Spacer(1, 7))
            continue

        if stripped.startswith("# "):
            flush_para()
            story.append(Spacer(1, 18))
            story.append(Paragraph(clean_inline(stripped[2:]), styles["title"]))
            story.append(Paragraph("AAST Connect Graduation Project", styles["subtitle"]))
            story.append(Spacer(1, 6))
            i += 1
            continue

        if stripped.startswith("## "):
            flush_para()
            heading = stripped[3:]
            if heading.startswith("6.1 "):
                story.append(PageBreak())
            story.append(Paragraph(clean_inline(heading), styles["h2"]))
            i += 1
            continue

        if stripped.startswith("### "):
            flush_para()
            story.append(Paragraph(clean_inline(stripped[4:]), styles["h3"]))
            i += 1
            continue

        if stripped.startswith("- "):
            flush_para()
            story.append(Paragraph(f"- {clean_inline(stripped[2:])}", styles["bullet"]))
            i += 1
            continue

        if re.match(r"^\d+\. ", stripped):
            flush_para()
            story.append(Paragraph(clean_inline(stripped), styles["bullet"]))
            i += 1
            continue

        pending_para.append(stripped)
        i += 1

    flush_para()
    return story


def main():
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    markdown = SOURCE.read_text(encoding="utf-8")
    doc = ChapterDoc(str(OUTPUT))
    doc.build(build_story(markdown))
    print(OUTPUT)


if __name__ == "__main__":
    main()
