-- Goal: Transaction detail for granular analysis

with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

order_payments as (
    select * from {{ ref('stg_order_payments') }}
),

order_reviews as (
    select * from {{ ref('stg_order_reviews') }}
)

select
    orders.order_id,
    orders.customer_id,
    orders.order_status,
    orders.purchased_at,
    orders.approved_at,
    orders.delivered_at,
    orders.estimated_delivery_at,
    
    -- Customer info
    customers.city as customer_city,
    customers.state as customer_state,
    
    -- Product info
    order_items.product_id,
    products.product_category_name,
    order_items.price,
    order_items.freight_value,
    
    -- Payment info
    order_payments.payment_type,
    order_payments.installments,
    order_payments.payment_value,
    
    -- Review info
    order_reviews.score as review_score,
    order_reviews.review_comment_message,
    
    -- Calculated metrics
    (order_items.price + order_items.freight_value) as total_item_value,
    date_diff(orders.delivered_at, orders.estimated_delivery_at, day) as delivery_delay_days
from orders
left join customers on orders.customer_id = customers.customer_id
left join order_items on orders.order_id = order_items.order_id
left join products on order_items.product_id = products.product_id
left join order_payments on orders.order_id = order_payments.order_id
left join order_reviews on orders.order_id = order_reviews.order_id
where orders.order_status = 'delivered'