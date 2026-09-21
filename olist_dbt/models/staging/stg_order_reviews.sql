-- models/staging/stg_order_reviews.sql
with source as (
    select * from {{ source('olist_raw', 'olist_order_reviews_dataset') }}
),

renamed as (
    select
        review_id,
        order_id,
        cast(review_score as integer) as score,
        review_comment_title,
        review_comment_message,
        cast(review_creation_date as timestamp) as created_at,
        cast(review_answer_timestamp as timestamp) as answered_at
    from source
)

select * from renamed