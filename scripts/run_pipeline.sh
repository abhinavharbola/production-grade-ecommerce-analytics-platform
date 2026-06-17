#!/bin/bash
set -euo pipefail

echo "=== Installing dbt dependencies ==="
cd dbt_project
dbt deps

echo "=== Running dbt build (run + test) ==="
dbt build --profiles-dir .

echo "=== Exporting marts to Parquet ==="
mkdir -p ../data/exports

duckdb ../data/ecommerce.duckdb -c "
  COPY (SELECT * FROM marts.mart_revenue_monthly) TO '../data/exports/mart_revenue_monthly.parquet' (FORMAT PARQUET);
  COPY (SELECT * FROM marts.mart_cohort_retention) TO '../data/exports/mart_cohort_retention.parquet' (FORMAT PARQUET);
  COPY (SELECT * FROM marts.mart_clv) TO '../data/exports/mart_clv.parquet' (FORMAT PARQUET);
  COPY (SELECT * FROM marts.mart_category_performance) TO '../data/exports/mart_category_performance.parquet' (FORMAT PARQUET);
  COPY (SELECT * FROM marts.mart_seller_performance) TO '../data/exports/mart_seller_performance.parquet' (FORMAT PARQUET);
  COPY (SELECT * FROM marts.mart_delivery_reviews) TO '../data/exports/mart_delivery_reviews.parquet' (FORMAT PARQUET);
"

echo "=== Pipeline complete ==="