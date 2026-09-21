-- Goal: Customer dimension with CLV metric (Customer Lifetime Value)

with customers as (
    select * from `latihan-data-505310`.`olist_dataset`.`stg_customers`
),

orders as (
    select * from `latihan-data-505310`.`olist_dataset`.`stg_orders`
),

order_items as (
    select * from `latihan-data-505310`.`olist_dataset`.`stg_order_items`
),

-- Calculate metric per customer
customer_metrics as (
    select
        orders.customer_id,
        count(distinct orders.order_id) as total_orders,
        sum(order_items.price + order_items.freight_value) as total_spent,
        avg(order_items.price + order_items.freight_value) as avg_order_value,
        min(orders.purchased_at) as first_purchase_date,
        max(orders.purchased_at) as last_purchase_date,
        date_diff(max(orders.purchased_at), min(orders.purchased_at), day) as customer_lifetime_days
    from orders
    left join order_items on orders.order_id = order_items.order_id
    where orders.order_status = 'delivered'
    group by 1
)

select
    customers.customer_id,
    customers.customer_unique_id,
    customers.city,
    customers.state,
    customers.zip_code,
    coalesce(customer_metrics.total_orders, 0) as total_orders,
    coalesce(customer_metrics.total_spent, 0) as total_spent,
    coalesce(customer_metrics.avg_order_value, 0) as avg_order_value,
    customer_metrics.first_purchase_date,
    customer_metrics.last_purchase_date,
    customer_metrics.customer_lifetime_days
from customers
left join customer_metrics on customers.customer_id = customer_metrics.customer_id