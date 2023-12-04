-- Get the first and last available transaction dates
-- for full month analysis
with available_transaction_dates as (
    select
        max(transaction_date) as last_available_transaction_date,
        min(transaction_date) as first_available_transaction_date
    from {{ ref('int_transactions_cleaned') }} 
),

-- Check if the first transaction date describes a full first month of data
-- (it needs to have the same date as the first date of that month)
-- Check if the last transaction date describes a full last month of data
-- (it needs to have the same date as the last date of that month)
available_transactions_dates_months as (
    select
        first_available_transaction_date,
        {{ dbt.date_trunc("month", "first_available_transaction_date") }}
            as first_available_transaction_date_month_trunc,
        {{ dbt.date_trunc("month", "first_available_transaction_date") }}
            = first_available_transaction_date as is_full_month_first_available_month,
        last_available_transaction_date,
        {{ dbt.date_trunc("month", "last_available_transaction_date") }}
            as last_available_transaction_date_month_trunc,
        {{ dbt.last_day("last_available_transaction_date", "month") }}
            = last_available_transaction_date as is_full_month_last_available_month
    from available_transaction_dates
),

customers_months as (
    select
        customer_hash,
        {{ dbt.date_trunc("month", "transaction_date") }} as transaction_month_trunc,
        sum(transaction_amount) as transaction_amount_total
    from {{ ref('int_transactions_cleaned') }}
    group by 1, 2
),

customers_months_meta as (
    select
        cm.customer_hash,
        cm.transaction_month_trunc,
        cm.transaction_amount_total,
        row_number() over (
            partition by cm.transaction_month_trunc
            order by cm.transaction_amount_total desc
        ) as customer_transaction_total_desc_rank,
        -- Join back to first/last transaction date data
        -- to check if the month level data describes a full
        -- First or last month, otherwise any middle months
        -- should have full data by virtue of not being potentially cut off
        -- (assuming the data given is contiguous)
        coalesce(
            atdm_first.is_full_month_first_available_month,
            atdm_last.is_full_month_last_available_month,
            true
        ) as is_full_month
    from customers_months as cm
    left join available_transactions_dates_months as atdm_first
        on cm.transaction_month_trunc = atdm_first.first_available_transaction_date_month_trunc
    left join available_transactions_dates_months as atdm_last
        on cm.transaction_month_trunc = atdm_last.last_available_transaction_date_month_trunc
)

select * from customers_months_meta
