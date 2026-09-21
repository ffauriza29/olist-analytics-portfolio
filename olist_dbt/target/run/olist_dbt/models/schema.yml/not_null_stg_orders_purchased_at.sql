
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select purchased_at
from `latihan-data-505310`.`olist_dataset`.`stg_orders`
where purchased_at is null



  
  
      
    ) dbt_internal_test