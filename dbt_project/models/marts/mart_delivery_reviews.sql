WITH delivery_reviews AS (
    SELECT
        da.order_id,
        da.delivery_delay_days,
        da.delivery_status,
        r.review_score
    FROM {{ ref('int_delivery_analysis') }} da
    LEFT JOIN {{ ref('stg_reviews') }} r
        ON da.order_id = r.order_id
    WHERE r.review_score IS NOT NULL
),

delay_buckets AS (
    SELECT
        CASE
            WHEN delivery_delay_days <= -10 THEN '-10 or less'
            WHEN delivery_delay_days <= -5 THEN '-9 to -5'
            WHEN delivery_delay_days <= -1 THEN '-4 to -1'
            WHEN delivery_delay_days = 0 THEN 'On time'
            WHEN delivery_delay_days <= 5 THEN '1 to 5'
            WHEN delivery_delay_days <= 10 THEN '6 to 10'
            WHEN delivery_delay_days <= 20 THEN '11 to 20'
            ELSE '21+'
        END AS delay_bucket,
        review_score
    FROM delivery_reviews
)

SELECT
    delay_bucket,
    COUNT(*) AS total_orders,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_low_score,
    ROUND(SUM(CASE WHEN review_score >= 4 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_high_score
FROM delay_buckets
GROUP BY delay_bucket
ORDER BY
    CASE delay_bucket
        WHEN '-10 or less' THEN 1
        WHEN '-9 to -5' THEN 2
        WHEN '-4 to -1' THEN 3
        WHEN 'On time' THEN 4
        WHEN '1 to 5' THEN 5
        WHEN '6 to 10' THEN 6
        WHEN '11 to 20' THEN 7
        ELSE 8
    END