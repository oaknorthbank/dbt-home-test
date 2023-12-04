with transactions_previous_dates as (
    select
        transaction_hash,
        customer_hash,
        transaction_date,
        transaction_amount,
        lag(transaction_date) over (
            partition by customer_hash
            order by transaction_date
        ) as previous_transaction_date
    from {{ ref('int_transactions_cleaned') }}
),

transactions_intervals as (
    select
        *,
        {{ dbt.datediff("previous_transaction_date", "transaction_date", 'day') }} as transactions_interval_days
    from transactions_previous_dates
)

customer_grain as (
    select
        customer_hash,
        count(*) as transactions_total_count,
        avg(transactions_interval_days) as transactions_interval_days_avg
    from
        transactions_intervals
    group by 1
)

select * from customer_grain
