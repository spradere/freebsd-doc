# FreeBSD Arch Handbook print PDF proof of concept

This directory contains an **isolated print experiment** that does not modify upstream Handbook sources in place.

## What this PoC does

- Clones `freebsd/freebsd-doc` into `print-poc/.work/freebsd-doc`.
- Builds `documentation/content/en/books/arch-handbook/book.adoc` to PDF using AsciiDoctor PDF.
- Keeps only the first 30 pages for rapid print-layout validation.

Attribution is preserved in the generated PDF because it is rendered from the original FreeBSD Documentation Project source.

## Required tools

- `git`
- `ruby` + `gem`
- `python3` + `pip`

The build script auto-installs these user-local dependencies when missing:

- Ruby gem: `asciidoctor-pdf`
- Python package: `pypdf`

## Build command

From repository root:

```bash
make print-poc
```

or directly:

```bash
./build-print-poc.sh
```

## Output

Generated files:

- Full intermediate PDF: `print-poc/output/arch-handbook-full.pdf`
- PoC excerpt (first 30 pages): `print-poc/output/arch-handbook-print-poc-first-30-pages.pdf`

## Print design choices

Theme file: `print-poc/theme/arch-handbook-print-theme.yml`

- Page size: **B5** for book-like print testing.
- Margins include extra inner space for binding.
- Serif body text and monospace code blocks.
- Attempts to improve print readability with:
  - heading spacing + minimum trailing space to reduce isolated headings,
  - code block `keep_together` behavior,
  - tighter footer page numbers for recto/verso pages.

## Why AsciiDoctor PDF (vs LaTeX)

AsciiDoctor PDF was chosen for a small first experiment because:

- it directly consumes existing AsciiDoc sources,
- minimizes transformation steps,
- keeps the PoC easy to discard.

LaTeX can offer deeper fine-grained pagination/typographic control, but would require a larger conversion and maintenance surface.

## Current limitations before full-scale rollout

1. First-30-pages selection is done *after* full render (trim step).
2. Widows/orphans control is partial and theme/engine dependent.
3. Font embedding is using default PDF core fonts in this PoC; production should pin specific print fonts.
4. No CI/cache strategy yet for full-book iterative builds.
5. Full handbook may need additional per-block tuning (tables, long code listings, callouts).
