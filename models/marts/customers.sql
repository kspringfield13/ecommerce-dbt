WITH customer_base AS (
    SELECT 
        id AS user_id,
        first_name AS customer_first_name,
        last_name AS customer_last_name,
        country AS customer_country,
        traffic_source AS customer_acquisition_channel
    FROM {{ ref('stg__users')}}
)
, order_items AS (
    SELECT 
        user_id,
        SUM(sale_price) AS total_amount_spent,
        COUNT(DISTINCT id) AS total_items_purchased,
        MIN(created_at) AS first_order_completed_at,
        MAX(created_at) AS last_order_completed_at,
    FROM {{ ref('stg__order_items') }}
    WHERE status = 'Complete'
    GROUP BY 1
)
, orders AS (
    SELECT 
        user_id,
        COUNT(DISTINCT order_id) AS num_orders,
        COUNT(DISTINCT 
            CASE WHEN status = 'Shipped'
            THEN order_id
            END) AS num_orders_shipped,
        COUNT(DISTINCT 
            CASE WHEN status = 'Complete'
            THEN order_id
            END) AS num_orders_complete,
        COUNT(DISTINCT 
            CASE WHEN status = 'Processing'
            THEN order_id
            END) AS num_orders_processing,
        COUNT(DISTINCT 
            CASE WHEN status = 'Cancelled'
            THEN order_id
            END) AS num_orders_cancelled,
        COUNT(DISTINCT 
            CASE WHEN status = 'Returned'
            THEN order_id
            END) AS num_orders_returned,
    FROM {{ ref('stg__orders') }}
    GROUP BY 1
)
, web_traffic AS (
    SELECT 
        user_id,
        COUNT(DISTINCT session_id) AS num_web_sessions,
    FROM {{ ref('stg__events') }}
    GROUP BY 1
)
SELECT
    cb.user_id,
    cb.customer_first_name,
    cb.customer_last_name,
    cb.customer_country,
    cb.customer_acquisition_channel,
    oi.total_amount_spent,
    oi.total_items_purchased,
    oi.first_order_completed_at,
    oi.last_order_completed_at,
    o.num_orders,
    o.num_orders_shipped,
    o.num_orders_complete,
    o.num_orders_processing,
    o.num_orders_cancelled,
    o.num_orders_returned,
    wt.num_web_sessions,
FROM customer_base cb
LEFT JOIN order_items oi 
    on cb.user_id = oi.user_id
LEFT JOIN orders o
    ON cb.user_id = o.user_id 
LEFT JOIN web_traffic wt 
    ON cb.user_id = wt.user_id