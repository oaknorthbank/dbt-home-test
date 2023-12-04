with customers_months as (
    select
        customer_hash,
        sum(transaction_amount_total) / count(*) as transactions_full_month_amount_avg
    from {{ ref('int_transactions_pivoted_to_customers_months') }}
    where is_full_month
    group by 1
),

customers_summary as (
    select
        customers.customer_hash,
        customers.customer_full_name,
        customers.customer_joined_date,
        -- Removed customers birth date as it seems unnecessary and is PII
        ct.transactions_total_count,
        round(cast(ct.transactions_interval_days_avg as numeric), 2) as transactions_interval_days_avg,
        round(cast(cm.transactions_full_month_amount_avg as numeric), 2) as transactions_full_month_amount_avg
    from {{ ref('stg_seeds__customers') }} as customers
    left join {{ ref('int_transactions_pivoted_to_customers') }} as ct
        on ct.customer_hash = customers.customer_hash
    left join customers_months as cm
        on cm.customer_hash = customers.customer_hash
)

select * from customers_summary
