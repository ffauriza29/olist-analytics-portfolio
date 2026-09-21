
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select sales_month
from `latihan-data-505310`.`olist_dataset`.`fct_monthly_sales`
where sales_month is null



  
  
      
    ) dbt_internal_test