
/*
    This is a staging model for the customers table. 
    It is used to clean up the data and make it ready for the customers model and store as a view.
*/


with source_customers as (

    select * from {{ ref('customers') }}

), 

final as (

    select 
        customer_id,
        name,
        date_of_birth,
        joined_date
    from 
        source_customers

)

select * from final
