SELECT *
FROM {{ source('ecommerce', 'events') }}