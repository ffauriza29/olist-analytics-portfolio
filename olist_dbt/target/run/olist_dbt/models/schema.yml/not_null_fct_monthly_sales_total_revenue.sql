
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select total_revenue
from `latihan-data-505310`.`olist_dataset`.`fct_monthly_sales`
where total_revenue is null



  
  
      
    ) dbt_internal_test