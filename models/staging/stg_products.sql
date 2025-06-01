SELECT
  id,
  cost,
  category,
  name,
  brand,
  retail_price,
  department,
  sku,
  distribution_center_id
FROM {{ source('ecommerce', 'products') }}