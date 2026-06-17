SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    DATEDIFF(
        'day',
        order_estimated_delivery_date,
        order_delivered_customer_date
    ) AS delivery_delay_days,
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status
FROM {{ ref('stg_orders') }}
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL