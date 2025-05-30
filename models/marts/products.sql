WITH product_base AS (
    SELECT 
        id AS product_id,
        name AS product_name,
        category AS product_category,
        department AS product_department
    FROM {{ ref('stg__products') }}
)
, inventory_items AS (
    SELECT 
        product_id,
        SUM(CASE WHEN sold_at IS NOT NULL THEN cost END) AS cost_of_goods_sold
    FROM {{ ref('stg__inventory_items') }}
    GROUP BY 1
)
, order_items AS (
	SELECT 
        product_id,
        SUM(CASE WHEN created_at IS NOT NULL THEN sale_price END) AS sales_amount
    FROM {{ ref('stg__order_items') }}
    GROUP BY 1
)
SELECT 
    pb.product_id,
    pb.product_name,
    pb.product_category,
    oi.sales_amount,
    ii.cost_of_goods_sold,
    oi.sales_amount - ii.cost_of_goods_sold AS profit
FROM product_base pb 
LEFT JOIN inventory_items ii 
    ON pb.product_id = ii.product_id 
LEFT JOIN order_items oi 
    ON pb.product_id = oi.product_id