
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select order_id
from `latihan-data-505310`.`olist_raw`.`olist_orders_dataset`
where order_id is null



  
  
      
    ) dbt_internal_test