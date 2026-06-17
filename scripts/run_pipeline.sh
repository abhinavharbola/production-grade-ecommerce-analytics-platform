#!/bin/bash
set -euo pipefail

echo "=== Installing dbt dependencies ==="
cd dbt_project
dbt deps

echo "=== Running dbt build (run + test) ==="
dbt build --profiles-dir .

echo "=== Exporting marts to Parquet ==="
cd ..
python scripts/export_marts.py

echo "=== Pipeline complete ==="
