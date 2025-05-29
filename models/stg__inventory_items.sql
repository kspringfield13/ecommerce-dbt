SELECT *
FROM {{ source('ecommerce', 'inventory_items') }}