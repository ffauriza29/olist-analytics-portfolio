

  create or replace view `latihan-data-505310`.`olist_dataset`.`my_second_dbt_model`
  OPTIONS()
  as -- Use the `ref` function to select from other models

select *
from `latihan-data-505310`.`olist_dataset`.`my_first_dbt_model`
where id = 1;

