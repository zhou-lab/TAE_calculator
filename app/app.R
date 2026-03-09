library(shiny)

# ---------------------------------------------------------------------------
# Hardcoded training data (from 20240109_SparseSeqTable_reformated.xlsx)
# Model: loess(z ~ x + y, degree=1, span=0.4)
#   x = Whole Genome Level (%) / 100  (fraction of ALL cytosines modified)
#   y = log2(coverage_raw)  where coverage_raw = num_reads * read_length / region_size
#   z = Total Analytical Error (%) / 100
# ---------------------------------------------------------------------------
tae_x <- c(
  0.03499, 0.03499, 0.03499, 0.03499, 0.03499, 0.03499, 0.03499, 0.03499,
  0.03499, 0.03499, 0.03499, 0.03499, 0.03499, 0.036529, 0.036529, 0.036529,
  0.036529, 0.036529, 0.036529, 0.036529, 0.036529, 0.036529, 0.036529,
  0.036529, 0.036529, 0.036529, 0.035118, 0.035118, 0.035118, 0.035118,
  0.035118, 0.035118, 0.035118, 0.035118, 0.035118, 0.035118, 0.035118,
  0.035118, 0.035118, 0.051926, 0.051926, 0.051926, 0.051926, 0.051926,
  0.051926, 0.051926, 0.051926, 0.051926, 0.051926, 0.051926, 0.051926,
  0.051926, 0.05252, 0.05252, 0.05252, 0.05252, 0.05252, 0.05252, 0.05252,
  0.05252, 0.05252, 0.05252, 0.05252, 0.05252, 0.05252, 0.006071, 0.006071,
  0.006071, 0.006071, 0.006071, 0.006071, 0.006071, 0.006071, 0.006071,
  0.006071, 0.006071, 0.006071, 0.006071, 0.012035, 0.012035, 0.012035,
  0.012035, 0.012035, 0.012035, 0.012035, 0.012035, 0.012035, 0.012035,
  0.012035, 0.012035, 0.012035, 0.006264, 0.006264, 0.006264, 0.006264,
  0.006264, 0.006264, 0.006264, 0.006264, 0.006264, 0.006264, 0.006264,
  0.006264, 0.006264, 0.005887, 0.005887, 0.005887, 0.005887, 0.005887,
  0.005887, 0.005887, 0.005887, 0.005887, 0.005887, 0.005887, 0.005887,
  0.005887, 0.004882, 0.004882, 0.004882, 0.004882, 0.004882, 0.004882,
  0.004882, 0.004882, 0.004882, 0.004882, 0.004882, 0.004882, 0.004882,
  0.002652, 0.002652, 0.002652, 0.002652, 0.002652, 0.002652, 0.002652,
  0.002652, 0.002652, 0.002652, 0.002652, 0.002652, 0.002652, 0.001365,
  0.001365, 0.001365, 0.001365, 0.001365, 0.001365, 0.001365, 0.001365,
  0.001365, 0.001365, 0.001365, 0.001365, 0.001365, 0.012379, 0.012379,
  0.012379, 0.012379, 0.012379, 0.012379, 0.012379, 0.012379, 0.012379,
  0.012379, 0.012379, 0.012379, 0.012379, 0.010514, 0.010514, 0.010514,
  0.010514, 0.010514, 0.010514, 0.010514, 0.010514, 0.010514, 0.010514,
  0.010514, 0.010514, 0.010514, 0.048728, 0.048728, 0.048728, 0.048728,
  0.048728, 0.048728, 0.048728, 0.048728, 0.048728, 0.048728, 0.048728,
  0.048728, 0.048728, 0.048355, 0.048355, 0.048355, 0.048355, 0.048355,
  0.048355, 0.048355, 0.048355, 0.048355, 0.048355, 0.048355, 0.048355,
  0.048355, 0.026145, 0.026145, 0.026145, 0.026145, 0.026145, 0.026145,
  0.026145, 0.026145, 0.026145, 0.026145, 0.026145, 0.026145, 0.026145,
  0.026486, 0.026486, 0.026486, 0.026486, 0.026486, 0.026486, 0.026486,
  0.026486, 0.026486, 0.026486, 0.026486, 0.026486, 0.026486
)
tae_y_raw <- c(
  0.000234358795571099, 0.0004687175911423, 0.0009374351822847, 0.00187487036456949, 0.00374974072913899, 0.00749948145827809,
  0.0149989629165563, 0.0299979258331126, 0.0599958516662254, 0.119991703332451, 0.239983406664902, 0.479966813329804,
  0.959933626659609, 0.000234358795571099, 0.0004687175911423, 0.0009374351822847, 0.00187487036456949, 0.00374974072913899,
  0.00749948145827809, 0.0149989629165563, 0.0299979258331126, 0.0599958516662254, 0.119991703332451, 0.239983406664902,
  0.479966813329804, 0.959933626659609, 0.000234358795571099, 0.0004687175911423, 0.0009374351822847, 0.00187487036456949,
  0.00374974072913899, 0.00749948145827809, 0.0149989629165563, 0.0299979258331126, 0.0599958516662254, 0.119991703332451,
  0.239983406664902, 0.479966813329804, 0.959933626659609, 0.000234358795571099, 0.0004687175911423, 0.0009374351822847,
  0.00187487036456949, 0.00374974072913899, 0.00749948145827809, 0.0149989629165563, 0.0299979258331126, 0.0599958516662254,
  0.119991703332451, 0.239983406664902, 0.479966813329804, 0.959933626659609, 0.000234358795571099, 0.0004687175911423,
  0.0009374351822847, 0.00187487036456949, 0.00374974072913899, 0.00749948145827809, 0.0149989629165563, 0.0299979258331126,
  0.0599958516662254, 0.119991703332451, 0.239983406664902, 0.479966813329804, 0.959933626659609, 0.000234358795571099,
  0.0004687175911423, 0.0009374351822847, 0.00187487036456949, 0.00374974072913899, 0.00749948145827809, 0.0149989629165563,
  0.0299979258331126, 0.0599958516662254, 0.119991703332451, 0.239983406664902, 0.479966813329804, 0.959933626659609,
  0.000234358795571099, 0.0004687175911423, 0.0009374351822847, 0.00187487036456949, 0.00374974072913899, 0.00749948145827809,
  0.0149989629165563, 0.0299979258331126, 0.0599958516662254, 0.119991703332451, 0.239983406664902, 0.479966813329804,
  0.959933626659609, 0.000234358795571099, 0.0004687175911423, 0.0009374351822847, 0.00187487036456949, 0.00374974072913899,
  0.00749948145827809, 0.0149989629165563, 0.0299979258331126, 0.0599958516662254, 0.119991703332451, 0.239983406664902,
  0.479966813329804, 0.959933626659609, 0.000234358795571099, 0.0004687175911423, 0.0009374351822847, 0.00187487036456949,
  0.00374974072913899, 0.00749948145827809, 0.0149989629165563, 0.0299979258331126, 0.0599958516662254, 0.119991703332451,
  0.239983406664902, 0.479966813329804, 0.959933626659609, 0.000234358795571099, 0.0004687175911423, 0.0009374351822847,
  0.00187487036456949, 0.00374974072913899, 0.00749948145827809, 0.0149989629165563, 0.0299979258331126, 0.0599958516662254,
  0.119991703332451, 0.239983406664902, 0.479966813329804, 0.959933626659609, 0.0002252041551191, 0.0004559010945095,
  0.0009282805418327, 0.0018620538679367, 0.00374058608868699, 0.00748666496164529, 0.0149898082761042, 0.0299851093364799,
  0.0599866970257735, 0.119978886835818, 0.23997425202445, 0.479953996833171, 0.959924472019157, 0.0002252041551191,
  0.0004559010945095, 0.0009282805418327, 0.0018620538679367, 0.00374058608868699, 0.00748666496164529, 0.0149898082761042,
  0.0299851093364799, 0.0599866970257735, 0.119978886835818, 0.23997425202445, 0.479953996833171, 0.959924472019157,
  0.0002252041551191, 0.0004559010945095, 0.0009282805418327, 0.0018620538679367, 0.00374058608868699, 0.00748666496164529,
  0.0149898082761042, 0.0299851093364799, 0.0599866970257735, 0.119978886835818, 0.23997425202445, 0.479953996833171,
  0.959924472019157, 0.0002252041551191, 0.0004559010945095, 0.0009282805418327, 0.0018620538679367, 0.00374058608868699,
  0.00748666496164529, 0.0149898082761042, 0.0299851093364799, 0.0599866970257735, 0.119978886835818, 0.23997425202445,
  0.479953996833171, 0.959924472019157, 0.000230696939390299, 0.0004650557349615, 0.0009337733261039, 0.00187120850838869,
  0.00374607887295819, 0.0074958196020973, 0.0149953010603755, 0.0299942639769318, 0.0599921898100447, 0.11998804147627,
  0.239979744808721, 0.479963151473623, 0.959929964803428, 0.000230696939390299, 0.0004650557349615, 0.0009337733261039,
  0.00187120850838869, 0.00374607887295819, 0.0074958196020973, 0.0149953010603755, 0.0299942639769318, 0.0599921898100447,
  0.11998804147627, 0.239979744808721, 0.479963151473623, 0.959929964803428, 0.000196874999999999, 0.000396874999999999,
  0.000796875, 0.00159687499999989, 0.003196875, 0.00639687499999999, 0.012796875, 0.025596875,
  0.051196875, 0.102396874999999, 0.204796875, 0.409596874999999, 0.819196875, 0.000196874999999999,
  0.000396874999999999, 0.000796875, 0.00159687499999989, 0.003196875, 0.00639687499999999, 0.012796875,
  0.025596875, 0.051196875, 0.102396874999999, 0.204796875, 0.409596874999999, 0.819196875
)
tae_z <- c(
  0.488379, 0.283227, 0.213244, 0.146737, 0.121019, 0.099882, 0.0553,
  0.051474, 0.025526, 0.016944, 0.012701, 0.009904, 0.006009, 0.457055,
  0.279415, 0.242197, 0.169812, 0.131057, 0.086213, 0.055271, 0.035831,
  0.024195, 0.018121, 0.012669, 0.010574, 0.006996, 0.557813, 0.254158,
  0.236016, 0.199828, 0.104994, 0.079581, 0.04943, 0.034176, 0.035643,
  0.019995, 0.014393, 0.010385, 0.008785, 0.319309, 0.240513, 0.176016,
  0.142321, 0.098225, 0.074418, 0.046807, 0.038704, 0.028968, 0.016667,
  0.011895, 0.011304, 0.005513, 0.41026, 0.275374, 0.177202, 0.170589,
  0.092197, 0.068101, 0.053321, 0.033037, 0.023891, 0.013561, 0.017297,
  0.007799, 0.005053, 0.799244, 0.710592, 0.558343, 0.360444, 0.206206,
  0.179824, 0.108646, 0.070679, 0.064449, 0.043805, 0.030117, 0.019576,
  0.015691, 0.725288, 0.501421, 0.446418, 0.276057, 0.176679, 0.134059,
  0.094362, 0.066308, 0.052176, 0.030873, 0.023281, 0.015726, 0.010518,
  0.954828, 0.739634, 0.398255, 0.306207, 0.219105, 0.144957, 0.121038,
  0.089338, 0.059595, 0.046034, 0.030783, 0.019485, 0.01415, 0.822807,
  0.841765, 0.466472, 0.37397, 0.229778, 0.181206, 0.123116, 0.099211,
  0.054754, 0.042051, 0.031455, 0.01931, 0.016987, 1.057375, 0.960362,
  0.568829, 0.333157, 0.266119, 0.215208, 0.123849, 0.086811, 0.065311,
  0.044983, 0.028965, 0.022288, 0.015796, 1.800152, 1.345452, 0.845582,
  0.679363, 0.439579, 0.349559, 0.224143, 0.17447, 0.117927, 0.076675,
  0.060306, 0.047003, 0.027739, 1.620099, 1.298967, 0.912374, 0.771528,
  0.457249, 0.299062, 0.23849, 0.159843, 0.118623, 0.08531, 0.055845,
  0.041722, 0.02587, 0.709116, 0.454038, 0.434919, 0.262808, 0.173013,
  0.11869, 0.091379, 0.061915, 0.042161, 0.031014, 0.020913, 0.01407,
  0.011129, 0.697725, 0.453518, 0.318364, 0.246639, 0.184055, 0.142765,
  0.082214, 0.054703, 0.04063, 0.030873, 0.019782, 0.013657, 0.009659,
  0.376627, 0.220596, 0.186761, 0.144544, 0.094403, 0.073763, 0.051012,
  0.034707, 0.02035, 0.018461, 0.011808, 0.009314, 0.00637, 0.351676,
  0.248842, 0.191904, 0.115055, 0.114082, 0.065712, 0.060412, 0.033858,
  0.01947, 0.017577, 0.015886, 0.009623, 0.00639, 0.545752, 0.418836,
  0.274173, 0.216546, 0.171085, 0.103402, 0.070182, 0.043463, 0.035958,
  0.030045, 0.016072, 0.011032, 0.010452, 0.640889, 0.388775, 0.278612,
  0.226033, 0.15929, 0.117527, 0.07902, 0.057447, 0.03354, 0.026679,
  0.017223, 0.013972, 0.009028
)

# ---------------------------------------------------------------------------
# Fit LOESS model once at startup
# ---------------------------------------------------------------------------
train_df <- data.frame(
  x = tae_x,
  y = log2(tae_y_raw / 100),
  z = tae_z
)
loess_mod <- loess(z ~ x + y, data = train_df, degree = 1, span = 0.4)

# Pre-compute heatmap grid
grid_x <- seq(min(train_df$x), max(train_df$x), length.out = 80)
grid_y <- seq(min(train_df$y), max(train_df$y), length.out = 80)
grid_df <- expand.grid(x = grid_x, y = grid_y)
grid_df$z <- pmax(0, predict(loess_mod, newdata = grid_df))

# ---------------------------------------------------------------------------
# Genome constants (mm10/GRCm38)
# ---------------------------------------------------------------------------
MOUSE_GENOME_SIZE <- 2700000000  # mouse genome size in bp

# ChromHMM region scaling factors (fraction of genome in each state).
# coverage_raw = reads * read_length / genome_size * scaling_factor
# Whole Genome = 1.0 (no adjustment)
REGION_SCALE <- c(
  "Whole Genome" = 1.0,
  "Quies"        = 0.483261,
  "QuiesG"       = 0.127215,
  "Quies2"       = 0.0797684,
  "Tx"           = 0.0469154,
  "TxWk"         = 0.0491258,
  "Tss"          = 0.0535334,
  "ReprPCWk"     = 0.0254097,
  "Quies3"       = 0.0265591,
  "TssBiv"       = 0.0173609,
  "EnhPois"      = 0.0172006,
  "ReprPC"       = 0.0131493,
  "Het"          = 0.0110388,
  "TssFlnk"      = 0.0107942,
  "Quies4"       = 0.0158835,
  "Enh"          = 0.00871408,
  "EnhPr"        = 0.00666426,
  "EnhG"         = 0.00487017,
  "EnhLo"        = 0.00253651
)

# Display labels for ChromHMM states (name = label shown in UI, value = key in REGION_SCALE)
REGION_CHOICES <- c(
  "Whole Genome"                           = "Whole Genome",
  "Quies — Quiescent (large)"              = "Quies",
  "QuiesG — Quiescent (gene-rich)"         = "QuiesG",
  "Quies2 — Quiescent 2"                   = "Quies2",
  "Quies3 — Quiescent 3"                   = "Quies3",
  "Quies4 — Quiescent 4"                   = "Quies4",
  "Tx — Active transcription"              = "Tx",
  "TxWk — Weak transcription"              = "TxWk",
  "Tss — Active TSS"                       = "Tss",
  "TssFlnk — Flanking TSS"                 = "TssFlnk",
  "TssBiv — Bivalent TSS"                  = "TssBiv",
  "Enh — Active enhancer"                  = "Enh",
  "EnhG — Genic enhancer"                  = "EnhG",
  "EnhPr — Primed enhancer"                = "EnhPr",
  "EnhLo — Low-activity enhancer"          = "EnhLo",
  "EnhPois — Poised enhancer"              = "EnhPois",
  "ReprPC — Repressed polycomb"            = "ReprPC",
  "ReprPCWk — Weak repressed polycomb"     = "ReprPCWk",
  "Het — Heterochromatin"                  = "Het"
)

# C-type fractions: fraction of ALL cytosines in that context (mouse genome)
#   CpG C's ≈ 4% of all C's
#   CpH C's ≈ 96% of all C's (the rest)
C_TYPE_FRACTION <- list(
  "CpG"     = 0.04,
  "CpH"     = 0.96,
  "Total C" = 1.00
)

# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { font-family: 'Segoe UI', Arial, sans-serif; background: #f5f6fa; }
      .card {
        background: white; border-radius: 10px; padding: 24px 28px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.07); margin-bottom: 18px;
      }
      h2 { color: #1a1a2e; margin-bottom: 2px; font-size: 1.7em; }
      h4 { color: #2c3e50; margin-bottom: 12px; }
      .subtitle { color: #888; font-size: 0.9em; margin-bottom: 20px; }
      .hint { font-size: 0.78em; color: #aaa; margin-top: -8px; margin-bottom: 12px; }
      .intermediate-box {
        background: #f8f9ff; border: 1px solid #dde; border-radius: 6px;
        padding: 12px 16px; margin: 14px 0; font-size: 0.9em;
      }
      .int-label { color: #555; margin-bottom: 4px; }
      .int-value { font-size: 1.2em; font-weight: 600; color: #2c3e50; }
      .int-formula { font-size: 0.78em; color: #aaa; margin-top: 2px; }
      .result-box {
        background: #eef6ff; border-left: 5px solid #2c7be5;
        border-radius: 6px; padding: 16px 20px; margin-top: 14px;
      }
      .result-value { font-size: 2.6em; font-weight: 700; color: #2c7be5; }
      .result-label { color: #555; font-size: 0.9em; margin-top: 4px; }
      .warn-box {
        background: #fff8e1; border-left: 4px solid #f9a825;
        border-radius: 4px; padding: 8px 14px; margin-top: 10px;
        font-size: 0.85em; color: #666;
      }
      hr { border-color: #eee; margin: 16px 0; }
      .section-title { font-weight: 600; font-size: 1em; color: #555;
                       margin-bottom: 10px; text-transform: uppercase;
                       letter-spacing: 0.04em; }
    "))
  ),

  div(class = "card",
    h2("Sparse-Seq TAE Calculator"),
    div(class = "subtitle",
        "Total Analytical Error estimator — enter sequencing parameters below"),
    hr(),

    fluidRow(
      # ---- LEFT PANEL: inputs ----
      column(5,
        div(class = "section-title", "Sequencing Parameters"),

        numericInput("num_reads", "Total reads sequenced",
                     value = 30000, min = 100, step = 1000),
        div(class = "hint", "Number of reads after alignment/filtering"),

        numericInput("read_length", "Read length (bp)",
                     value = 150, min = 25, max = 1000, step = 25),

        numericInput("beta_val",
                     "Calculated beta-value (0 – 1)",
                     value = 0.05, min = 0, max = 1, step = 0.001),
        div(class = "hint", "Per-site modification fraction"),

        selectInput("c_type", "Modification type",
                    choices = c("CpG", "CpH", "Total C"),
                    selected = "CpG"),

        selectInput("region", "Genomic region",
                    choices = REGION_CHOICES,
                    selected = "Whole Genome"),

        br(),
        actionButton("calc", "Calculate TAE",
                     class  = "btn-primary",
                     style  = "width:100%; font-size:1.05em; padding:10px;"),

        # ---- Intermediate calculations ----
        uiOutput("intermediates_ui"),

        # ---- Result ----
        uiOutput("result_ui")
      ),

      # ---- RIGHT PANEL: heatmap ----
      column(7,
        div(class = "section-title", "Model Surface — TAE (%)"),
        div(class = "hint",
            "LOESS model trained on 234 Sparse-Seq data points. Red dot = your input."),
        plotOutput("heatmap_plot", height = "440px"),
        div(style = "font-size:0.8em; color:#bbb; margin-top:6px;",
            "X-axis: % total C modification (model input x). ",
            "Y-axis: log\u2082(genome CpG coverage fraction / 100) (model input y).")
      )
    )
  ),

  div(class = "card",
    h4("Calculation Details"),
    tags$table(
      style = "width:100%; border-collapse:collapse; font-size:0.88em;",
      tags$thead(
        tags$tr(
          tags$th(style="text-align:left; padding:6px 10px; border-bottom:2px solid #eee;", "Step"),
          tags$th(style="text-align:left; padding:6px 10px; border-bottom:2px solid #eee;", "Formula"),
          tags$th(style="text-align:left; padding:6px 10px; border-bottom:2px solid #eee;", "Notes")
        )
      ),
      tags$tbody(
        tags$tr(style="border-bottom:1px solid #f0f0f0;",
          tags$td(style="padding:6px 10px;", "Genomic coverage"),
          tags$td(style="padding:6px 10px; font-family:monospace;",
                  "num_reads × read_length / 2,700,000,000 × scale_factor"),
          tags$td(style="padding:6px 10px; color:#888;",
                  "scale_factor = ChromHMM region fraction of mm10 genome")
        ),
        tags$tr(style="border-bottom:1px solid #f0f0f0;",
          tags$td(style="padding:6px 10px;", "Model input y"),
          tags$td(style="padding:6px 10px; font-family:monospace;",
                  "log\u2082(genomic_coverage)"),
          tags$td(style="padding:6px 10px; color:#888;",
                  "Training range: y \u2248 \u221219 to \u22127")
        ),
        tags$tr(style="border-bottom:1px solid #f0f0f0;",
          tags$td(style="padding:6px 10px;", "% total C modification"),
          tags$td(style="padding:6px 10px; font-family:monospace;",
                  "beta × C_type_fraction × 100"),
          tags$td(style="padding:6px 10px; color:#888;",
                  "CpG fraction ≈ 4%, CpH fraction ≈ 96% of all C's")
        ),
        tags$tr(
          tags$td(style="padding:6px 10px;", "Model input x"),
          tags$td(style="padding:6px 10px; font-family:monospace;",
                  "% total C modification / 100"),
          tags$td(style="padding:6px 10px; color:#888;",
                  "Training range: 0.14% – 5.25%")
        )
      )
    ),
    br(),
    div(style = "font-size:0.82em; color:#aaa;",
        "The LOESS model (degree=1, span=0.4) was trained on downsampled Sparse-Seq data ",
        "from multiple cell types and sequencing methods (BS-seq and bACE-seq). ",
        "Genomic coverage uses mouse genome size (mm10, 2.7 Gb).")
  )
)

# ---------------------------------------------------------------------------
# Server
# ---------------------------------------------------------------------------
server <- function(input, output, session) {

  calc_result <- eventReactive(input$calc, {
    # -- Inputs
    num_reads   <- input$num_reads
    read_length <- input$read_length
    beta        <- input$beta_val
    c_type     <- input$c_type
    region_key <- input$region

    # -- Intermediate 1: % total C modification
    c_frac    <- C_TYPE_FRACTION[[c_type]]
    pct_C_mod <- beta * c_frac * 100          # as percentage

    # -- Intermediate 2: genomic coverage (fraction of region sequenced)
    # scale_factor = fraction of reads mapping to this region (smaller region → smaller effective count).
    # Whole Genome = 1.0 (no adjustment).
    scale_factor <- REGION_SCALE[[region_key]]
    coverage_raw <- num_reads * read_length / MOUSE_GENOME_SIZE * scale_factor

    # -- Model inputs
    x_model <- pct_C_mod / 100
    y_model <- log2(coverage_raw)

    # -- Predict TAE
    tae_raw <- predict(loess_mod,
                       newdata = data.frame(x = x_model, y = y_model),
                       se = FALSE)
    tae_pct <- max(0, tae_raw) * 100

    # -- Out-of-range check
    in_range <- x_model >= min(train_df$x) && x_model <= max(train_df$x) &&
                y_model >= min(train_df$y) && y_model <= max(train_df$y)

    list(
      num_reads        = num_reads,
      read_length      = read_length,
      beta             = beta,
      c_type       = c_type,
      region_key   = region_key,
      scale_factor = scale_factor,
      c_frac       = c_frac,
      pct_C_mod    = pct_C_mod,
      coverage_raw = coverage_raw,
      x_model          = x_model,
      y_model          = y_model,
      tae_pct          = tae_pct,
      in_range         = in_range
    )
  })

  output$intermediates_ui <- renderUI({
    req(calc_result())
    r <- calc_result()
    div(
      hr(),
      div(class = "section-title", "Intermediate Values"),
      fluidRow(
        column(6,
          div(class = "intermediate-box",
              div(class = "int-label", "% total C modification"),
              div(class = "int-value", sprintf("%.4f%%", r$pct_C_mod)),
              div(class = "int-formula",
                  sprintf("beta (%.3f) \u00d7 C_frac (%.0f%%) \u00d7 100",
                          r$beta, r$c_frac * 100))
          )
        ),
        column(6,
          div(class = "intermediate-box",
              div(class = "int-label", "Genomic coverage"),
              div(class = "int-value", sprintf("%.4f%%", r$coverage_raw * 100)),
              div(class = "int-formula",
                  sprintf("%.0f reads \u00d7 %d bp / 2.7 Gb \u00d7 %.4f [%s]",
                          r$num_reads, r$read_length,
                          r$scale_factor, r$region_key))
          )
        )
      )
    )
  })

  output$result_ui <- renderUI({
    req(calc_result())
    r <- calc_result()
    warn <- if (!r$in_range) {
      div(class = "warn-box",
          "\u26a0 Input is outside the training data range. Prediction may be unreliable. ",
          sprintf("Model x range: %.4f\u2013%.4f, your x = %.4f. ",
                  min(train_df$x), max(train_df$x), r$x_model),
          sprintf("Model y range: %.1f\u2013%.1f, your y = %.1f.",
                  min(train_df$y), max(train_df$y), r$y_model))
    }
    div(
      hr(),
      div(class = "section-title", "Result"),
      div(class = "result-box",
          div(class = "result-value", sprintf("%.3f%%", r$tae_pct)),
          div(class = "result-label", "Estimated Total Analytical Error (TAE)")
      ),
      div(class = "result-box", style = "margin-top:10px;",
          div(class = "result-value",
              sprintf("%.4f \u00b1 %.4f", r$beta, r$tae_pct / 100 * r$beta)),
          div(class = "result-label", "Beta value \u00b1 error (TAE \u00d7 beta)")
      ),
      warn,
      div(style = "font-size:0.78em; color:#ccc; margin-top:8px;",
          sprintf("Model inputs: x = %.5f, y = %.3f", r$x_model, r$y_model))
    )
  })

  # Heatmap
  output$heatmap_plot <- renderPlot({
    nx <- length(unique(grid_df$x))
    ny <- length(unique(grid_df$y))
    gx <- sort(unique(grid_df$x)) * 100   # convert to %
    gy <- sort(unique(grid_df$y))
    zm <- matrix(pmin(grid_df$z * 100, 100),
                 nrow = nx, ncol = ny)

    pal <- colorRampPalette(c("#053061","#2166ac","#4393c3","#92c5de",
                               "#f7f7f7","#fdbf6f","#e31a1c","#67000d"))(100)

    par(mar = c(5, 5, 2, 5))
    image(gx, gy, zm, col = pal, zlim = c(0, 100),
          xlab = "% Total C modification \u00d7 100",
          ylab = expression(log[2](Genome~coverage~fraction)),
          useRaster = TRUE)

    contour(gx, gy, zm, levels = c(5, 10, 20, 30, 50, 80),
            col = "white", lwd = 1, add = TRUE, labcex = 0.7)

    # Colour legend
    legend_x <- par("usr")[2] + diff(par("usr")[1:2]) * 0.02
    legend_y_bot <- par("usr")[3]
    legend_y_top <- par("usr")[4]
    legend_vals  <- seq(0, 100, length.out = 100)
    legend_ys    <- seq(legend_y_bot, legend_y_top, length.out = 101)
    for (i in seq_along(legend_vals)) {
      rect(legend_x, legend_ys[i], legend_x + diff(par("usr")[1:2]) * 0.04,
           legend_ys[i + 1], col = pal[i], border = NA, xpd = TRUE)
    }
    text(legend_x + diff(par("usr")[1:2]) * 0.05,
         seq(legend_y_bot, legend_y_top, length.out = 6),
         labels = seq(0, 100, by = 20), xpd = TRUE, cex = 0.8)
    text(legend_x + diff(par("usr")[1:2]) * 0.05,
         legend_y_top + diff(par("usr")[3:4]) * 0.03,
         "TAE (%)", xpd = TRUE, cex = 0.9)

    # Add user's point if calculation done
    r <- calc_result()
    if (!is.null(r)) {
      points(r$x_model * 100, r$y_model,
             pch = 21, col = "red", bg = "white", cex = 2.5, lwd = 2.5)
    }
  })
}

shinyApp(ui, server)
