find_project_root <- function(start = getwd()) {
  path <- normalizePath(start, mustWork = TRUE)
  repeat {
    if (dir.exists(file.path(path, "paper_reproductions"))) return(path)
    parent <- dirname(path)
    if (identical(parent, path)) stop("Could not find project root from: ", start)
    path <- parent
  }
}

root <- find_project_root()
base_dir <- file.path(root, "paper_reproductions", "selected_next_10_core_papers")

paper_meta <- list(
  delnegro_schorfheide_2004_dsge_var = list(
    title = "Del Negro and Schorfheide (2004), Priors from General Equilibrium Models for VARs",
    code = "Formula replication is documented in the shared notes; no standalone paper-specific script is needed yet.",
    raw = "No stable PDF/data payload was available from the checked FRB Atlanta/EconStor endpoints. Use the bibliographic links in `paper_reproductions/selected_next_10_core_papers/notes/source_inventory.md`.",
    processed = "No separate processed data are produced for this theory-first replication. DSGE-VAR moments and formulas are documented in shared notes.",
    figures = "No paper-specific figure is generated in the current theory-first replication.",
    notes = "Use `paper_reproductions/selected_next_10_core_papers/notes/formula_derivation_walkthrough_zh.md` and `paper_reproductions/selected_next_10_core_papers/notes/exact_replication_status_zh.md`.",
    paper = "The checked PDF endpoints returned HTML or bot-check pages, so no invalid PDF was saved here.",
    results = "The local result is formula-level replication, summarized in `paper_reproductions/selected_next_10_core_papers/results/selected_10_method_mapping.csv`."
  ),
  litterman_1986_bvar_forecasting = list(
    title = "Litterman (1986), Forecasting with Bayesian Vector Autoregressions",
    code = "The Minnesota BVAR implementation is centralized in `paper_reproductions/selected_next_10_core_papers/code/run_baseline_replications.R`.",
    raw = "Raw macro data are centralized in `paper_reproductions/selected_next_10_core_papers/data/raw/fred_md/` and `paper_reproductions/selected_next_10_core_papers/data/raw/fred_series/`.",
    processed = "The processed small macro panel is `paper_reproductions/selected_next_10_core_papers/data/processed/small_macro_monthly_1960_2026.csv`.",
    figures = "No paper-specific figure is generated; forecast comparisons are tabular.",
    notes = "Use this paper README plus the shared formula notes.",
    paper = "The accessible JBES PDF mirror is stored in this folder.",
    results = "Relevant output: `paper_reproductions/selected_next_10_core_papers/results/bvar_forecast_comparison.csv`."
  ),
  kadiyala_karlsson_1997_bvar_numerical = list(
    title = "Kadiyala and Karlsson (1997), Numerical Methods for Bayesian VARs",
    code = "Original Fortran/Gauss source code is stored inside `paper_reproductions/selected_next_10_core_papers/kadiyala_karlsson_1997_bvar_numerical/data/raw/var.zip`; no translated local script is generated yet.",
    raw = "The JAE data/code archive is stored in `paper_reproductions/selected_next_10_core_papers/kadiyala_karlsson_1997_bvar_numerical/data/raw/`.",
    processed = "No processed data are generated because the original archive already includes data and output files.",
    figures = "No figures are generated in the current archive-verification pass.",
    notes = "Use the README and `paper_reproductions/selected_next_10_core_papers/notes/exact_replication_status_zh.md` for current exact-replication status.",
    paper = "No local PDF was downloaded; the JAE archive is the primary reproducibility source.",
    results = "Original output files are stored inside `paper_reproductions/selected_next_10_core_papers/kadiyala_karlsson_1997_bvar_numerical/data/raw/data.zip`; local formulas are in shared notes."
  ),
  sims_zha_1998_bayesian_dynamic_multivariate = list(
    title = "Sims and Zha (1998), Bayesian Methods for Dynamic Multivariate Models",
    code = "Dummy-observation prior calculations are documented in shared formula notes; no standalone code is required for this method-level replication.",
    raw = "No stable author data archive was found; shared FRED-MD data support the local BVAR examples.",
    processed = "No paper-specific processed data are produced.",
    figures = "No paper-specific figure is generated.",
    notes = "Use `paper_reproductions/selected_next_10_core_papers/notes/formula_derivations.md` and `paper_reproductions/selected_next_10_core_papers/notes/formula_derivation_walkthrough_zh.md`.",
    paper = "No local PDF was saved in this pass.",
    results = "Method mapping is in `paper_reproductions/selected_next_10_core_papers/results/selected_10_method_mapping.csv`."
  ),
  banbura_giannone_reichlin_2010_large_bvar = list(
    title = "Banbura, Giannone and Reichlin (2010), Large Bayesian VARs",
    code = "Original Matlab code is inside `paper_reproductions/selected_next_10_core_papers/banbura_giannone_reichlin_2010_large_bvar/data/raw/LargeBVARReplicationWeb.zip`; local R extension is `paper_reproductions/selected_next_10_core_papers/code/run_extended_replications.R`.",
    raw = "Author replication archive is stored in `paper_reproductions/selected_next_10_core_papers/banbura_giannone_reichlin_2010_large_bvar/data/raw/`; FRED-MD is centralized in `paper_reproductions/selected_next_10_core_papers/data/raw/fred_md/`.",
    processed = "No separate paper-local processed file is created; the transformed FRED-MD panel is built in memory by the extended script.",
    figures = "No paper-specific figure is generated; system-size results are tabular.",
    notes = "Use the README plus `paper_reproductions/selected_next_10_core_papers/notes/exact_replication_status_zh.md`.",
    paper = "No paper PDF is stored locally; source links are in shared inventory.",
    results = "Relevant output: `paper_reproductions/selected_next_10_core_papers/results/bgr_system_size_bvar_rmse.csv`."
  ),
  giannone_lenza_primiceri_2015_prior_selection = list(
    title = "Giannone, Lenza and Primiceri (2015), Prior Selection for VARs",
    code = "Original Matlab code is inside `paper_reproductions/selected_next_10_core_papers/giannone_lenza_primiceri_2015_prior_selection/data/raw/GLPreplicationWeb.zip`; local R baseline is `paper_reproductions/selected_next_10_core_papers/code/run_baseline_replications.R`.",
    raw = "Harvard Dataverse archive is stored in `paper_reproductions/selected_next_10_core_papers/giannone_lenza_primiceri_2015_prior_selection/data/raw/GLPreplicationWeb.zip`.",
    processed = "No separate paper-local processed file is produced; DataSW is in the author archive and FRED-MD is centralized.",
    figures = "No paper-specific figure is generated in this pass.",
    notes = "Use the README plus shared exact-status and formula notes.",
    paper = "No paper PDF is stored locally; DOI/source links are in shared inventory.",
    results = "Relevant output: `paper_reproductions/selected_next_10_core_papers/results/glp_lambda_grid_small_bvar.csv`."
  ),
  carriero_clark_marcellino_2015_bvar_specification = list(
    title = "Carriero, Clark and Marcellino (2015), Bayesian VAR Specification Choices",
    code = "Original JAE programs are inside `paper_reproductions/selected_next_10_core_papers/carriero_clark_marcellino_2015_bvar_specification/data/raw/ccm-programs.zip`; local R grid is `paper_reproductions/selected_next_10_core_papers/code/run_extended_replications.R`.",
    raw = "JAE archive files are stored in `paper_reproductions/selected_next_10_core_papers/carriero_clark_marcellino_2015_bvar_specification/data/raw/`.",
    processed = "No paper-local processed file is generated; the local grid uses the shared small macro panel.",
    figures = "No paper-specific figure is generated; specification results are tabular.",
    notes = "Use the README plus shared exact-status note.",
    paper = "No local PDF was downloaded; source links are in shared inventory.",
    results = "Relevant output: `paper_reproductions/selected_next_10_core_papers/results/carriero_specification_grid.csv`."
  ),
  primiceri_2005_tvp_svar = list(
    title = "Primiceri (2005), Time Varying Structural VARs and Monetary Policy",
    code = "The rolling-window diagnostic is implemented in `paper_reproductions/selected_next_10_core_papers/code/run_baseline_replications.R` and `paper_reproductions/selected_next_10_core_papers/code/run_extended_replications.R`.",
    raw = "Raw macro data are centralized in `paper_reproductions/selected_next_10_core_papers/data/raw/fred_md/` and `paper_reproductions/selected_next_10_core_papers/data/raw/fred_series/`.",
    processed = "The processed small macro panel is `paper_reproductions/selected_next_10_core_papers/data/processed/small_macro_monthly_1960_2026.csv`.",
    figures = "Relevant figure: `paper_reproductions/selected_next_10_core_papers/figures/rolling_policy_rule_coefficients.png`.",
    notes = "Use the README plus shared TVP-SVAR formula derivations.",
    paper = "The author working-paper PDF is stored in this folder.",
    results = "Relevant outputs: `paper_reproductions/selected_next_10_core_papers/results/rolling_policy_rule_coefficients.csv` and `paper_reproductions/selected_next_10_core_papers/results/primiceri_rolling_window_sensitivity.csv`."
  ),
  bernanke_boivin_eliasz_2005_favar = list(
    title = "Bernanke, Boivin and Eliasz (2005), FAVAR",
    code = "The public R notebook is stored in `paper_reproductions/selected_next_10_core_papers/bernanke_boivin_eliasz_2005_favar/code/`; local R implementation is in shared scripts.",
    raw = "BBE original Excel is stored in `paper_reproductions/selected_next_10_core_papers/bernanke_boivin_eliasz_2005_favar/data/raw/bbe_data.xlsx`; FRED-MD is centralized in `paper_reproductions/selected_next_10_core_papers/data/raw/fred_md/`.",
    processed = "No separate paper-local processed file is produced; the extended script reads the raw Excel directly.",
    figures = "Relevant figure: `paper_reproductions/selected_next_10_core_papers/figures/favar_policy_irf_baseline.png`.",
    notes = "Use the README and shared formula/status notes.",
    paper = "The FEDS paper PDF is stored in `paper/`.",
    results = "Relevant outputs: `paper_reproductions/selected_next_10_core_papers/results/favar_policy_irf_baseline.csv` and `paper_reproductions/selected_next_10_core_papers/results/bbe_table_i_replication.csv`."
  ),
  stock_watson_2002_diffusion_indexes = list(
    title = "Stock and Watson (2002), Macroeconomic Forecasting Using Diffusion Indexes",
    code = "PCA and direct diffusion-forecast exercises are implemented in shared R scripts.",
    raw = "Raw FRED-MD data are centralized in `paper_reproductions/selected_next_10_core_papers/data/raw/fred_md/`.",
    processed = "No paper-local processed file is generated; the FRED-MD transformed panel is built in memory.",
    figures = "Relevant figure: `paper_reproductions/selected_next_10_core_papers/figures/diffusion_factor_variance.png`.",
    notes = "Use the README plus shared diffusion-index formula notes.",
    paper = "The JBES PDF is stored in `paper/`.",
    results = "Relevant outputs: `paper_reproductions/selected_next_10_core_papers/results/diffusion_factor_variance.csv` and `paper_reproductions/selected_next_10_core_papers/results/stock_watson_diffusion_forecast_rmse.csv`."
  )
)

dir_labels <- c(
  code = "Code Folder Note",
  raw = "Raw Data Folder Note",
  processed = "Processed Data Folder Note",
  figures = "Figures Folder Note",
  notes = "Notes Folder Note",
  paper = "Paper Folder Note",
  results = "Results Folder Note"
)

write_note <- function(path, title, body) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  lines <- c(
    paste0("# ", title),
    "",
    body,
    "",
    "This file was added by `code/complete_folder_manifests.R` so the project has no unexplained empty research folders."
  )
  writeLines(lines, path, useBytes = TRUE)
}

is_generated_note <- function(path) {
  if (!file.exists(path)) return(FALSE)
  any(grepl("This file was added by `code/complete_folder_manifests.R`", readLines(path, warn = FALSE), fixed = TRUE))
}

is_generated_log <- function(path) {
  if (!file.exists(path)) return(FALSE)
  any(grepl("Folder audited for empty subdirectories.", readLines(path, warn = FALSE), fixed = TRUE))
}

for (folder in names(paper_meta)) {
  meta <- paper_meta[[folder]]
  paper_dir <- file.path(base_dir, folder)
  subdirs <- list(
    code = file.path(paper_dir, "code"),
    raw = file.path(paper_dir, "data", "raw"),
    processed = file.path(paper_dir, "data", "processed"),
    figures = file.path(paper_dir, "figures"),
    notes = file.path(paper_dir, "notes"),
    paper = file.path(paper_dir, "paper"),
    results = file.path(paper_dir, "results")
  )
  for (key in names(subdirs)) {
    readme <- file.path(subdirs[[key]], "README.md")
    if (!file.exists(readme) || is_generated_note(readme)) {
      write_note(readme, dir_labels[[key]], meta[[key]])
    }
  }
  log_path <- file.path(paper_dir, "replication_log.md")
  if (!file.exists(log_path) || is_generated_log(log_path)) {
    lines <- c(
      paste0("# Replication Log: ", meta$title),
      "",
      "## 2026-05-19",
      "",
      "- Folder audited for empty subdirectories.",
      "- Paper-specific README and subfolder notes were added where needed.",
      "- Current code, data and output locations are listed in the subfolder README files.",
      "- Exact-replication caveats are centralized in `../notes/exact_replication_status_zh.md`."
    )
    writeLines(lines, log_path, useBytes = TRUE)
  }
}

empty_after <- system(
  paste(
    "find",
    shQuote(base_dir),
    "-type d -empty | sort"
  ),
  intern = TRUE
)

paper_root <- file.path(root, "paper_reproductions")
ignored_local_cache <- "/\\.Rproj\\.user(/|$)"
all_project_dirs <- list.dirs(paper_root, recursive = TRUE, full.names = TRUE)
all_project_dirs <- all_project_dirs[!grepl(ignored_local_cache, all_project_dirs)]
empty_project_dirs <- all_project_dirs[vapply(
  all_project_dirs,
  function(path) length(list.files(path, all.files = TRUE, no.. = TRUE)) == 0,
  logical(1)
)]
all_project_files <- list.files(
  paper_root,
  recursive = TRUE,
  full.names = TRUE,
  all.files = TRUE,
  no.. = TRUE
)
all_project_files <- all_project_files[file.exists(all_project_files) & !dir.exists(all_project_files)]
all_project_files <- all_project_files[!grepl(ignored_local_cache, all_project_files)]
empty_project_files <- all_project_files[file.info(all_project_files)$size == 0]

relative_to_root <- function(paths) {
  project_root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  normalized <- normalizePath(paths, winslash = "/", mustWork = TRUE)
  sub(paste0("^", project_root, "/?"), "", normalized)
}

audit_path <- file.path(base_dir, "notes", "project_completion_audit_zh.md")
audit <- c(
  "# Project Completion Audit",
  "",
  "日期：2026-05-19",
  "",
  "## 检查范围",
  "",
  "- `paper_reproductions/` 下的论文复现文件夹；",
  "- 空目录、空文件、未解释的占位结构；",
  "- README/notes 中显式写出的未完成项。",
  "",
  "## 处理结果",
  "",
  "- `selected_next_10_core_papers` 中每篇论文的空子目录已补上 `README.md`，说明该目录当前对应的真实代码、数据、结果或限制。",
  "- 每篇后续核心论文已补上 `replication_log.md`。",
  "- 共享脚本和共享结果仍保留在 `selected_next_10_core_papers/code/`、`results/`、`figures/`，避免重复复制同一份输出。",
  "- `.Rproj.user` 下的空目录和空文件是 RStudio 本地缓存，已由 `.gitignore` 忽略，不属于研究交付物。",
  "",
  "## 仍然不是空目录问题的研究边界",
  "",
  "| 项目 | 边界说明 | 当前处理 |",
  "| --- | --- | --- |",
  "| Paccagnini (2010) | 完整 MH posterior integration 未重写 | 已有 reduced DSGE-VAR replication；边界保留在论文笔记中 |",
  "| Koop and Korobilis (2010) | SSVS/TVP-VAR/FAVAR 全量 R 重写未完成 | 已有 Section 2.3 BVAR replication、作者代码和数据；后续模块作为扩展 |",
  "| Chan (2022) | ACP-BVAR posterior sampler 未完全 R 化 | 已复现 Table 2 marginal likelihood；作者 Matlab 代码已收集 |",
  "| Selected next 10 | 部分论文没有稳定公开 exact replication archive | 已用真实数据完成 method-level replication，并在 `exact_replication_status_zh.md` 标明边界 |",
  "",
  "## 当前空目录和空文件复查",
  "",
  if (length(empty_project_dirs) == 0 && length(empty_project_files) == 0) {
    "在 `paper_reproductions/` 内没有剩余空目录或空文件（已排除 `.Rproj.user` 本地缓存）。"
  } else {
    c(
      if (length(empty_project_dirs) > 0) {
        c("以下目录仍为空：", paste0("- `", relative_to_root(empty_project_dirs), "`"))
      },
      if (length(empty_project_files) > 0) {
        c("以下文件仍为空：", paste0("- `", relative_to_root(empty_project_files), "`"))
      }
    )
  }
)
writeLines(audit, audit_path, useBytes = TRUE)

cat("Folder manifests completed.\n")
if (length(empty_after) == 0) {
  cat("No empty directories remain under selected_next_10_core_papers.\n")
} else {
  cat("Remaining empty directories under selected_next_10_core_papers:\n")
  cat(paste(empty_after, collapse = "\n"), "\n")
}
