
    
    

with all_values as (

    select
        order_status as value_field,
        count(*) as n_records

    from `latihan-data-505310`.`olist_dataset`.`stg_orders`
    group by order_status

)

select *
from all_values
where value_field not in (
    'delivered','shipped','invoiced','processing','canceled','unavailable','created','approved'
)


