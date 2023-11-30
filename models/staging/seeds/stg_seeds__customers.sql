with source as (
    select * from {{ ref('customers') }}
),

reworked as (
    select
        customer_id,
        {{ dbt.hash("customer_id") }} as customer_hash,
        name as customer_full_name,
        cast(date_of_birth as date) as customer_date_of_birth,
        cast(joined_date as date) as customer_joined_date
    from source
)

select * from reworked
