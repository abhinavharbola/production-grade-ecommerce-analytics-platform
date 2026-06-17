WITH first_orders AS (
    SELECT
        customer_id,
        MIN(DATE_TRUNC('month', order_purchase_timestamp)) AS cohort_month
    FROM {{ ref('stg_orders') }}
    GROUP BY customer_id
),

orders_with_cohort AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
        f.cohort_month
    FROM {{ ref('stg_orders') }} o
    LEFT JOIN first_orders f
        ON o.customer_id = f.customer_id
)

SELECT * FROM orders_with_cohort