# TAE Calculator

A client-side Sparse-Seq **Total Analytical Error (TAE) calculator** built with R Shiny + [shinylive](https://posit-dev.github.io/r-shinylive/), hosted on GitHub Pages.

All computation runs in the browser via WebAssembly — no server required.

## Live App

👉 **https://zhou-lab.github.io/TAE_calculator/**

## Inputs

| Field | Description |
|---|---|
| Total reads sequenced | Number of reads after alignment/filtering |
| Read length (bp) | Read length in base pairs |
| Beta-value | Per-site modification fraction (0–1) |
| Modification type | CpG / CpH / Total C |
| Genomic region | Whole genome or ChromHMM element (e.g., Tx) |

The app calculates two intermediate values:
- **% total C modification** = Beta × C-type fraction × 100
- **Genome CpG coverage** = Num reads × Read length / bp-per-CpG / Total genome CpG sites

These feed the LOESS model as inputs `x` and `y` to predict TAE.

## Model

- **Algorithm**: 2D LOESS (degree = 1, span = 0.4)
- **Training data**: 234 Sparse-Seq data points across multiple cell types (BS-seq and bACE-seq)
- **x input**: `Whole Genome Level (%) / 100` — training range 0.14%–5.25%
- **y input**: `log2(Downsampled Coverage / 100)` — training range 0.02%–96%
- **Output**: Total Analytical Error (%) — range ~0.5%–180% in training data

## Local Development

```r
# Run locally
shiny::runApp("app")

# Re-export to docs/ after changes
shinylive::export("app", "docs")
```

## GitHub Pages Setup

1. Push to `main` — GitHub Actions will auto-export and deploy to `gh-pages` branch
2. In repo Settings → Pages → set source to `gh-pages` branch, root `/`

Or manually:
1. Run `shinylive::export("app", "docs")` locally
2. Commit and push `docs/`
3. In repo Settings → Pages → set source to `main` branch, `/docs` folder
