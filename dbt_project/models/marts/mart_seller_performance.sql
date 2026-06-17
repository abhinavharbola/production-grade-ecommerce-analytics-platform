WITH seller_metrics AS (
    SELECT
        oi.seller_id,
        s.seller_city,
        s.seller_state,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.price) AS total_gmv,
        AVG(oi.price) AS avg_price,
        COUNT(DISTINCT oi.product_id) AS unique_products
    FROM {{ ref('stg_order_items') }} oi
    LEFT JOIN {{ ref('stg_sellers') }} s
        ON oi.seller_id = s.seller_id
    GROUP BY oi.seller_id, s.seller_city, s.seller_state
),

seller_concentration AS (
    SELECT
        *,
        SUM(total_gmv) OVER () AS total_marketplace_gmv,
        total_gmv / SUM(total_gmv) OVER () AS gmv_share,
        SUM(total_gmv) OVER (ORDER BY total_gmv DESC) AS cumulative_gmv,
        SUM(total_gmv) OVER (ORDER BY total_gmv DESC) / SUM(total_gmv) OVER () AS cumulative_gmv_share,
        NTILE(10) OVER (ORDER BY total_gmv DESC) AS gmv_decile
    FROM seller_metrics
)

SELECT * FROM seller_concentration
ORDER BY total_gmv DESC