WITH order_dates AS (
    SELECT
        MIN(DATE_TRUNC('day', order_purchase_timestamp)) AS min_date,
        MAX(DATE_TRUNC('day', order_purchase_timestamp)) AS max_date
    FROM {{ ref('stg_orders') }}
),

date_range AS (
    SELECT UNNEST(
        GENERATE_SERIES(
            (SELECT min_date FROM order_dates),
            (SELECT max_date FROM order_dates),
            INTERVAL 1 DAY
        )
    ) AS date_key
)

SELECT
    date_key,
    EXTRACT(YEAR FROM date_key) AS year,
    EXTRACT(MONTH FROM date_key) AS month,
    EXTRACT(QUARTER FROM date_key) AS quarter,
    EXTRACT(DAYOFWEEK FROM date_key) AS day_of_week,
    EXTRACT(DAY FROM date_key) AS day_of_month,
    DATE_TRUNC('month', date_key) AS month_start_date,
    DATE_TRUNC('quarter', date_key) AS quarter_start_date
FROM date_range