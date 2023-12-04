-- create a cte with rows for each date from current date going back 12 months
-- I have not made this into a macro because in the software engineering principle
-- of YAGNI (you ain't gonna need it) I would need more instances of needing this
-- and other examples of how it would need to be implemented to correctly abstract
-- into a macro. Also using dbt_utils this is already implemented.
with months_current_date as (
    {% for month_num in range(0, 12) %}
        select
            {{ dbt.dateadd(
              datepart="month",
              interval=-month_num,
              from_date_or_timestamp="current_date"
            ) }} as dates
        {% if not loop.last %} union all {% endif %}
    {% endfor %}
),
-- truncate the dates from months_current_date to create a months_trunc_spine
months_trunc_spine as (
    select
        {{ dbt.date_trunc("month", "dates") }} as month_trunc
    from months_current_date
),

months_top_spend_customer as (
    select
        transaction_month_trunc,
        customer_hash as top_customer_hash_by_transaction_total_desc
    from {{ ref('int_transactions_pivoted_to_customers_months') }}
    where customer_transaction_total_desc_rank = 1
),

months_transactions_total_amount as (
    select
        transaction_month_trunc,
        is_full_month,
        sum(transaction_amount_total) as transaction_amount_total
    from {{ ref('int_transactions_pivoted_to_customers_months') }}
    group by 1, 2
),

months_transaction_totals as (
    select
        months_trunc_spine.month_trunc,
        ta.transaction_amount_total,
        ta.transaction_amount_total / lag(ta.transaction_amount_total) over (
          order by months_trunc_spine.month_trunc
        ) as transaction_amount_total_month_change,
        tc.top_customer_hash_by_transaction_total_desc,
        ta.is_full_month
    from months_trunc_spine
    left join months_transactions_total_amount as ta
        on ta.transaction_month_trunc = months_trunc_spine.month_trunc
    left join months_top_spend_customer as tc
        on tc.transaction_month_trunc = months_trunc_spine.month_trunc
),

transactions_month_summary as (
select
    month_trunc,
    is_full_month,
    transaction_amount_total,
    round((cast(transaction_amount_total_month_change as numeric) - 1) * 100, 2) as transaction_total_percentage_change,
    top_customer_hash_by_transaction_total_desc
from months_transaction_totals
)

select * from transactions_month_summary






