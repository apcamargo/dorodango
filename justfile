root := justfile_directory()

# Full pipeline: format, tests, compile documentation, and README assets
all: fmt test compile-manual compile-assets

# Run all formatters
fmt: fmt-typst fmt-toml

# Format all Typst files
fmt-typst:
    typstyle -v -i .

# Format all TOML files
fmt-toml:
    tombi format .

# Run all tests
test:
    tt run --no-export-ephemeral

# Regenerate checked-in smoothing SVGs from pinned reference packages
generate-test-fixtures:
    node tests/_helpers/scripts/generate-smoothing-fixtures.mjs

# Verify that checked-in smoothing SVGs and generated case arguments agree
check-test-fixtures:
    node tests/_helpers/scripts/generate-smoothing-fixtures.mjs --check

# Compile the manual PDF
compile-manual:
    typst compile --root {{root}} docs/manual.typ docs/manual.pdf

# Compile SVG assets embedded in the README
compile-assets: (compile-asset "light") (compile-asset "dark")

# Compile the SVG assets for a single theme
[private]
compile-asset theme:
    typst compile --root {{root}} --input theme={{theme}} assets/rectangle-vs-squircle.typ assets/rectangle-vs-squircle-{{theme}}.svg
    typst compile --root {{root}} --input theme={{theme}} assets/smoothing-comparison.typ assets/smoothing-comparison-{{theme}}.svg
    typst compile --root {{root}} --input theme={{theme}} assets/per-edge-smoothing-comparison.typ assets/per-edge-smoothing-comparison-{{theme}}.svg
