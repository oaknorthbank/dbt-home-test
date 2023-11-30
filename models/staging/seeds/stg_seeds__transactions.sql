with source as (
    select * from {{ ref('transactions') }}
),

reworked as (
    select
        {{ dbt.hash("transaction_id") }} as transaction_hash,
        cast(transaction_id as integer) as transaction_id,
        {{ dbt.hash("customer_id") }} as customer_hash,
        customer_id,
        transaction_date as transaction_date_raw,
        case
            -- Null uncastable dates
            -- Using the software principle of YAGNI, instead of complicating
            -- This check for uncastable dates by bringing in regex checks or
            -- more complicated format checks, this check does what is needed
            -- with the data issues we have 'now' rather than in the future
            when {{ dbt.length("transaction_date") }} > 10 then null
            else cast(transaction_date as date)
        end as transaction_date,
        cast(amount as numeric) as transaction_amount
    from source
)

select * from reworked
