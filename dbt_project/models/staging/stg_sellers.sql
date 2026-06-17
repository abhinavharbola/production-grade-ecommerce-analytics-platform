WITH source AS (
    SELECT * FROM read_csv_auto('../data/raw/olist_sellers_dataset.csv')
)

SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM source