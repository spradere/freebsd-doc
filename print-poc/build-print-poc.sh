#!/usr/bin/env bash
set -euo pipefail

POC_DIR="./print-poc"
WORK_DIR="$POC_DIR/.work"
OUTPUT_DIR="$POC_DIR/output"
THEME_FILE="$POC_DIR/theme.yml"
FULL_PDF="$OUTPUT_DIR/arch-handbook-full.pdf"
POC_PDF="$OUTPUT_DIR/arch-handbook-print-poc-first-30-pages.pdf"

mkdir -p "$WORK_DIR" "$OUTPUT_DIR"

command -v git >/dev/null || { echo "git is required"; exit 1; }
command -v ruby >/dev/null || { echo "ruby is required"; exit 1; }

if ! command -v asciidoctor-pdf >/dev/null; then
  echo "Installing asciidoctor-pdf gem (user-local)..."
  gem install --user-install asciidoctor-pdf >/dev/null
  export PATH="$HOME/.local/share/gem/ruby/$(ruby -e 'print RbConfig::CONFIG["ruby_version"]')/bin:$PATH"
fi

BOOK_FILE="./documentation/content/en/books/arch-handbook/book.adoc"

if ! python3 -c "import pypdf" >/dev/null 2>&1; then
  echo "Installing Python dependency pypdf (user-local)..."
  python3 -m pip install --user pypdf >/dev/null
fi
if [ ! -f "$BOOK_FILE" ]; then
  echo "Could not find expected source file: $BOOK_FILE"
  exit 1
fi

asciidoctor-pdf \
  -a reproducible \
  -a pdf-theme="$THEME_FILE" \
  -a source-highlighter=rouge \
  -D "$OUTPUT_DIR" \
  -o "$(basename "$FULL_PDF")" \
  "$BOOK_FILE"

python3 - <<'PY'
from pathlib import Path
from pypdf import PdfReader, PdfWriter

full_pdf = Path("print-poc/output/arch-handbook-full.pdf")
out_pdf = Path("print-poc/output/arch-handbook-print-poc-first-30-pages.pdf")

reader = PdfReader(str(full_pdf))
writer = PdfWriter()
for page in reader.pages[:30]:
    writer.add_page(page)
with out_pdf.open("wb") as f:
    writer.write(f)
PY

echo "Generated: $POC_PDF"
