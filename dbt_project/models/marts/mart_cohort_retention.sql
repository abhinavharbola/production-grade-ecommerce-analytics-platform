WITH cohort_activity AS (
    SELECT
        oc.cohort_month,
        DATE_TRUNC('month', r.order_purchase_timestamp) AS activity_month,
        COUNT(DISTINCT r.customer_id) AS active_customers
    FROM {{ ref('int_order_cohorts') }} oc
    LEFT JOIN {{ ref('int_revenue_daily') }} r
        ON oc.customer_id = r.customer_id
    GROUP BY oc.cohort_month, DATE_TRUNC('month', r.order_purchase_timestamp)
),

cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM {{ ref('int_order_cohorts') }}
    GROUP BY cohort_month
)

SELECT
    ds.cohort_month,
    ds.order_month,
    ds.period,
    cs.cohort_size,
    COALESCE(ca.active_customers, 0) AS active_customers,
    ROUND(COALESCE(ca.active_customers, 0) * 100.0 / cs.cohort_size, 2) AS retention_pct
FROM {{ ref('int_dense_cohort_spine') }} ds
LEFT JOIN cohort_sizes cs
    ON ds.cohort_month = cs.cohort_month
LEFT JOIN cohort_activity ca
    ON ds.cohort_month = ca.cohort_month
    AND ds.order_month = ca.activity_month
ORDER BY ds.cohort_month, ds.period