with transactions as (
    select * from {{ ref('stg_seeds__transactions') }}
),

cleaned as (
    -- Distinct removes duplicates
    select distinct
        t.transaction_hash,
        t.customer_hash,
        t.transaction_date,
        t.transaction_amount
    from transactions as t
    -- Inner join removes transactions without a corresponding customer
    -- and null customer_hash in transactions
    inner join {{ ref('stg_seeds__customers') }} as c
        on c.customer_hash = t.customer_hash
    -- Removes transactions with a null,
    -- or nulled transaction_date because of validity
    where t.transaction_date is not null
    -- Removes transactions with transaction date in the future
    and t.transaction_date <= current_date
)

select * from cleaned
