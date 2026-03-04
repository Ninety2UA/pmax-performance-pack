# CLAUDE.md

## Project Overview

GitHub repo for the **pMax Performance Pack** — a customized deployment of Google's [pMaximizer](https://github.com/google/pmax_best_practices_dashboard) (pMax Best Practices Dashboard).

This repo contains the deployed query files, workflow definitions, and documentation. The actual runtime is on GCP (project `solutions-test-489209`). This repo is the source of truth for all query files.

## What This Repo Contains

- `ads-queries/` — 19 GAQL extraction queries (18 upstream + 1 custom `asset_performance.sql`)
- `bq-queries/` — 16 BigQuery transformation queries (3 patched for API v23+, 1 with custom metrics)
- `workflows/` — Cloud Workflow YAML definitions (exported from GCP)
- `config/` — Account discovery query, credential template, dashboard clone URL
- `docs/images/` — SVG diagrams and PNG screenshots for README

## Custom Additions (vs upstream pMaximizer)

### New Files
- `ads-queries/asset_performance.sql` — Per-asset daily metrics by ad network using `asset_group_asset` resource

### Patched Files (API v23+ compatibility)
- `ads-queries/assetgroupasset.sql` — Removed deprecated `performance_label`
- `ads-queries/campaign_settings.sql` — Removed deprecated `url_expansion_opt_out`
- `bq-queries/06-assetssnapshots.sql` — Default `'LEARNING'` for asset_performance
- `bq-queries/07-campaign_data.sql` — Default `FALSE` for url_expansion_opt_out
- `bq-queries/08-assetsummary.sql` — Added per-asset metrics JOIN + 9 new columns, removed campaign cost subquery

## GCP Deployment

- **Project**: `solutions-test-489209`
- **Region**: `europe-west3` (functions/workflows), `europe` (BigQuery)
- **GCS**: `gs://solutions-test-489209/pmax/` — mirrors this repo structure
- **Pipeline**: Cloud Scheduler (4 AM CET) → Cloud Workflows → GAARF Cloud Functions → BigQuery → Looker Studio
- **Credentials**: `google-ads.yaml` is in GCS only (NOT in this repo — excluded via .gitignore)

## Syncing Repo ↔ GCS

After editing queries in this repo, upload to GCS:
```bash
export BUCKET="solutions-test-489209"
gsutil -m cp ads-queries/*.sql "gs://${BUCKET}/pmax/ads-queries/"
gsutil -m cp bq-queries/*.sql "gs://${BUCKET}/pmax/bq-queries/"
```

## Visual Assets

- `docs/images/banner.svg` — Hero banner (pipeline: G → fn → BQ → LS with Google colors)
- `docs/images/architecture.svg` — Full architecture diagram
- `docs/images/pipeline-flow.svg` — Query execution flow with custom/patched/upstream color coding
- `docs/images/*.png` — Upstream screenshots (dashboard preview, GCP components, bucket structure)
- README uses Mermaid diagrams (rendered natively by GitHub) for pipeline and query flow
