-- models/staging/stg_order_payments.sql
with source as (
    select * from `latihan-data-505310`.`olist_raw`.`olist_order_payments_dataset`
),

renamed as (
    select
        order_id,
        payment_sequential,
        payment_type,
        cast(payment_installments as integer) as installments,
        cast(payment_value as numeric) as payment_value
    from source
)

select * from renamed