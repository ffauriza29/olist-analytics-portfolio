-- models/staging/stg_customers.sql
with source as (
    select * from {{ source('olist_raw', 'olist_customers_dataset') }}
),

renamed as (
    select
        customer_id,
        customer_unique_id,
        lower(customer_city) as city,
        customer_state as state,
        customer_zip_code_prefix as zip_code
    from source
)

select * from renamed