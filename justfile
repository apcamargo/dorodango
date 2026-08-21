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

# Compile the manual PDF
[working-directory: root]
compile-manual:
    typst compile --root {{root}} docs/manual.typ docs/manual.pdf

# Compile SVG assets embedded in the README
compile-assets: (compile-asset "light") (compile-asset "dark")

# Compile the SVG assets for a single theme
[private]
[working-directory: root]
compile-asset theme:
    typst compile --root {{root}} --input theme={{theme}} assets/rectangle-vs-squircle.typ assets/rectangle-vs-squircle-{{theme}}.svg
    typst compile --root {{root}} --input theme={{theme}} assets/smoothing-comparison.typ assets/smoothing-comparison-{{theme}}.svg
