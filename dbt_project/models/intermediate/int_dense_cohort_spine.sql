WITH cohorts AS (
    SELECT DISTINCT cohort_month
    FROM {{ ref('int_order_cohorts') }}
),

month_spine AS (
    SELECT DISTINCT month_start_date AS order_month
    FROM {{ ref('int_dim_dates') }}
),

dense_spine AS (
    SELECT
        c.cohort_month,
        m.order_month,
        DATEDIFF('month', c.cohort_month, m.order_month) AS period
    FROM cohorts c
    CROSS JOIN month_spine m
    WHERE m.order_month >= c.cohort_month
)

SELECT * FROM dense_spine