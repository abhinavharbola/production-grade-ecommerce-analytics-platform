import duckdb
import os

db_path = os.path.join(os.path.dirname(__file__), '..', 'data', 'ecommerce.duckdb')
export_dir = os.path.join(os.path.dirname(__file__), '..', 'data', 'exports')
os.makedirs(export_dir, exist_ok=True)

con = duckdb.connect(db_path)

marts = [
    'mart_revenue_monthly',
    'mart_cohort_retention',
    'mart_clv',
    'mart_category_performance',
    'mart_seller_performance',
    'mart_delivery_reviews'
]

for mart in marts:
    export_path = os.path.join(export_dir, f'{mart}.parquet')
    con.execute(f"COPY (SELECT * FROM main_marts.{mart}) TO '{export_path}' (FORMAT PARQUET)")
    print(f"Exported {mart}")

con.close()
print("Export complete")