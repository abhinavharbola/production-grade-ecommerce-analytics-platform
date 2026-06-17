WITH source AS (
    SELECT * FROM read_csv_auto('../data/raw/olist_customers_dataset.csv')
)

SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM source