{% snapshot inventory_snapshot %}

{{
    config(
      target_schema='main',
      unique_key='id',
      strategy='timestamp',
      updated_at='created_at'
    )
}}

SELECT * 
FROM {{ source('ecommerce', 'inventory_items') }}

{% endsnapshot %}