WITH customer_revenue AS (
    SELECT
        customer_id,
        MIN(order_purchase_timestamp) AS first_order_date,
        MAX(order_purchase_timestamp) AS last_order_date,
        SUM(total_revenue) AS total_revenue,
        COUNT(DISTINCT order_id) AS total_orders
    FROM {{ ref('int_revenue_daily') }}
    GROUP BY customer_id
),

customer_clv AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', first_order_date) AS cohort_month,
        total_revenue,
        total_orders,
        total_revenue / NULLIF(total_orders, 0) AS avg_order_value,
        DATEDIFF('day', first_order_date, last_order_date) AS customer_lifespan_days,
        CASE
            WHEN DATEDIFF('day', first_order_date, last_order_date) > 0
            THEN total_revenue * 365.0 / DATEDIFF('day', first_order_date, last_order_date)
            ELSE total_revenue
        END AS annualized_clv
    FROM customer_revenue
)

SELECT
    cohort_month,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(AVG(total_revenue), 2) AS avg_total_revenue,
    ROUND(AVG(total_orders), 2) AS avg_orders,
    ROUND(AVG(annualized_clv), 2) AS avg_annualized_clv,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY annualized_clv), 2) AS median_annualized_clv
FROM customer_clv
GROUP BY cohort_month
ORDER BY cohort_month