
/*
    This is a staging model for the transaction table. 
    It is used to clean up the data and make it ready for the transactions model and store as a view.
*/


with source_transactions as (

    select * from {{ ref('transactions') }}

), 

final as (

    select 
        transaction_id,
        customer_id,
        transaction_date,
        amount
    from 
        source_transactions

)

select * from final
