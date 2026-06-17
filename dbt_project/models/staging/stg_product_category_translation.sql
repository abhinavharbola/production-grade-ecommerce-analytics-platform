WITH source AS (
    SELECT * FROM read_csv_auto('../data/raw/product_category_name_translation.csv')
)

SELECT
    product_category_name,
    product_category_name_english
FROM source