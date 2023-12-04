{% docs __overview__ %}
# DBT Home Test
## Notes on design
### Cleaning transaction data
**This is the design choice that most affects the final results**.
* Removing the duplicates seems correct
* Removing transactions with no customer ID will affect the monthly summary, but if we do not have the customer ID,
without knowing more about the row we need to remove and assume the whole row is suspect.
* Removing transactions with bad dates was the conservative approach, but it changes the customer level summary.
My decision was that if the date is incorrect then we cannot trust the row and therefore should not attribute to the customer
* Removing transactions with a customer ID we do not have in the customers date was conservative, it changes the monthly summary,
especially chosing the top customer in a month, as 'CUST_011' would have been the top customer in July. My decision was that
without knowing more about the data, it was better to stick with customers we could attribute, rather than a bad row with no
customer data.
* Isolating these transformations into one `int_transactions_cleaned` model makes it easier to change if, after discussions,
some or all of these would be better left in
### Using an intermediate model to clean transactions
The software engineering principle of **fail loudly** was applied. I wanted to be able to set up warnings on staging model for both transactions
and customers so that it is not forgotten we have bad data. Either to fix upstream or discuss. This meant I could not remove this data immediately
because I wanted `warn` level tests on the staging data. I went a bit back and forth on whether to create `base` staging models and then
do the cleaning in the `stg` model or to do as I did with a `stg` model and a cleaned `int` model. The reason I stuck with the `int` model
was it was more obvious with the naming of `int_transactions_cleaned` that there was explicit cleaning going on, but the other pattern could also work.
### Naming of 'Mart' models
Because of the way seeds were created, I could not name my customers level mart `customers` because it clashed with the seeds `customers`.
There is probably a way to reconfigure the seeds correctly but I tried a few and could not get it to work. I would have liked to fix it
and then named my mart `customers` instead of `customers_summary`. As it is this would be a future improvement. It would be easier just to
rename the seeds, but that seemed to be subverting the exercise too much.
To maintain the pattern I also called the other mart `transactions_month_summary`, but again this is not necessarily ideal.
### Using hash style identification instead of given IDs
Following the DBT guiding principle that we are trying to move from **source defined models** to **business defined models**, we should
probably not rely on the source defined IDs all the way through to marts. Instead I adopted the 'Data Vault' style practice of using hash
identifiers rather than source identifiers.
### Using DBT cross platform macros
Whilst I used postgres for development, I tried to use DBT cross platform macros where needed to allow for this code to be run
on any other platform.
I may have missed some, so apologies if the will not run on another platform with a different flavour of SQL. The intent was there but I did not have time to fully
test on another platform.
### PII
I have not explictly dealt with PII issues. I removed the date of birth from the marts for customers as it did not add any useful insight and
is another piece of PII to maintain. There is also the customer name to deal with, but as this was not asked for I have not tackled.
### Testing
I have put in tests where I thought they would work naturally. For most of the summary level data I sense checked the data manually.
I thought about adding specific result level tests for the summary level data, but although it could be done it would be quite contrived
as compared to how an actual project would work where you cannot have as many guarantees on the data as you do with a static seeds source.

As always there is probably more test coverage I could have added, but the tests I added gave me quite a high level of confidence on the code as is.
### Date spine
I added my own date spine to the `transactions_month_summary` because of the stipulation not to use external packages, but in a real project
I would assume I could use something like `dbt_utils` which has more robust implementations out of the box
{% enddocs %}
