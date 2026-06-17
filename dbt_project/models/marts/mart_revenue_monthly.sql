WITH revenue_monthly AS (
    SELECT
        DATE_TRUNC('month', order_purchase_timestamp) AS order_month,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT customer_id) AS unique_customers,
        SUM(total_revenue) AS total_revenue,
        AVG(total_revenue) AS avg_order_value,
        SUM(total_items_price) AS total_items_price,
        SUM(total_freight_value) AS total_freight_value
    FROM {{ ref('int_revenue_daily') }}
    GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
)

SELECT * FROM revenue_monthly
ORDER BY order_month