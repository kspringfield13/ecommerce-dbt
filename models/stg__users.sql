SELECT *
FROM {{ source('ecommerce', 'users') }}