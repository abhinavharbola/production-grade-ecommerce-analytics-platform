WITH category_metrics AS (
    SELECT
        p.product_category_name,
        pt.product_category_name_english,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.price) AS total_revenue,
        AVG(oi.price) AS avg_price,
        COUNT(DISTINCT oi.product_id) AS unique_products,
        COUNT(DISTINCT oi.seller_id) AS unique_sellers
    FROM {{ ref('stg_order_items') }} oi
    LEFT JOIN {{ ref('stg_products') }} p
        ON oi.product_id = p.product_id
    LEFT JOIN {{ ref('stg_product_category_translation') }} pt
        ON p.product_category_name = pt.product_category_name
    GROUP BY p.product_category_name, pt.product_category_name_english
),

category_reviews AS (
    SELECT
        p.product_category_name,
        AVG(r.review_score) AS avg_review_score,
        COUNT(DISTINCT r.review_id) AS total_reviews
    FROM {{ ref('stg_reviews') }} r
    LEFT JOIN {{ ref('stg_order_items') }} oi
        ON r.order_id = oi.order_id
    LEFT JOIN {{ ref('stg_products') }} p
        ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
)

SELECT
    COALESCE(cm.product_category_name, cr.product_category_name) AS product_category_name,
    COALESCE(cm.product_category_name_english, 'Unknown') AS product_category_name_english,
    COALESCE(cm.total_revenue, 0) AS total_revenue,
    cm.total_orders,
    cm.avg_price,
    cm.unique_products,
    cm.unique_sellers,
    cr.avg_review_score,
    cr.total_reviews,
    RANK() OVER (ORDER BY cm.total_revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY cr.avg_review_score ASC) AS review_rank
FROM category_metrics cm
FULL OUTER JOIN category_reviews cr
    ON cm.product_category_name = cr.product_category_name
WHERE cm.total_revenue IS NOT NULL
ORDER BY total_revenue DESC