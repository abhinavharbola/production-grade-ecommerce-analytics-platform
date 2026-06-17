{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='delete+insert'
    )
}}

WITH source AS (
    SELECT
        order_id,
        order_status,
        order_purchase_timestamp,
        customer_id
    FROM {{ ref('stg_orders') }}
    {% if is_incremental() %}
    WHERE order_purchase_timestamp > (SELECT MAX(order_purchase_timestamp) FROM {{ this }})
    {% endif %}
)

SELECT * FROM source