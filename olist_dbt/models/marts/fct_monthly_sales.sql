--Tujuan: Metrik penjualan bulanan untuk dashboard 

with orders AS (
    SELECT * FROM {{ ref('stg_orders')}}
),

order_items AS (
    SELECT * FROM {{ref('stg_order_items')}}
),

order_payments AS (
    SELECT * FROM {{ref('stg_order_payments')}}
),

--Calculate total revenue per order
order_revenue AS (
    SELECT 
        order_id,
        sum(price+freight_value) AS total_revenue
    FROM order_items
    GROUP BY 1
),

--Calculate total payment per order
order_payment_total AS (
    SELECT
        order_id,
        sum(payment_value) AS total_payment
    FROM order_payments
    GROUP BY 1
)

-- Final: Monthly Aggregation
SELECT
    date_trunc(orders.purchased_at, month) as sales_month,
    count(distinct orders.order_id) as total_orders,
    count(distinct orders.customer_id) as unique_customers,
    sum(order_revenue.total_revenue) as total_revenue,
    avg(order_revenue.total_revenue) as avg_order_value,
    sum(order_payment_total.total_payment) as total_payments
FROM orders
left join order_revenue on orders.order_id = order_revenue.order_id
left join order_payment_total on orders.order_id = order_payment_total.order_id
where orders.order_status = 'delivered'
group by 1
order by 1