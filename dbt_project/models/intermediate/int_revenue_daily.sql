WITH order_items_agg AS (
    SELECT
        order_id,
        SUM(price) AS total_items_price,
        SUM(freight_value) AS total_freight_value,
        COUNT(DISTINCT product_id) AS unique_products,
        COUNT(DISTINCT seller_id) AS unique_sellers
    FROM {{ ref('stg_order_items') }}
    GROUP BY order_id
),

orders_with_revenue AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp,
        COALESCE(oi.total_items_price, 0) AS total_items_price,
        COALESCE(oi.total_freight_value, 0) AS total_freight_value,
        COALESCE(oi.total_items_price, 0) + COALESCE(oi.total_freight_value, 0) AS total_revenue,
        oi.unique_products,
        oi.unique_sellers
    FROM {{ ref('stg_orders') }} o
    LEFT JOIN order_items_agg oi
        ON o.order_id = oi.order_id
    WHERE o.order_status IN ('delivered', 'shipped', 'invoiced', 'approved', 'processing')
)

SELECT * FROM orders_with_revenue