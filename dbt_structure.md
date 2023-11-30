# dbt Repository Structure explained

A clear dbt repository structure is needed to handle multiple datasets across teams and help troubleshoot data issues.

A dbt repository can be split into 3 key layers of transformation: staging, transformation, and marts.

## Staging

Staging models should be structured as follows:
- Prefixed with "stg_"
- Only include 1 data source - no joins or unions to other sources in this layer
- Type casting (numeric, date, timestamp, string etc)
- Snake case
- Deduplication using qualify statement or models for type 1/type 2 dimensions to account for slowly changing dimensions
- Aliasing to fully qualified names (ie. MID > merchant_id, countryCode > country_iso_code)
- Boolean fields should be prefixed with is_ (eg. is_churned)
- Avoid SELECT * on sources/explicitly name all fields for lineage tracking
- Sub-folders based on source (eg. seed, fivetran, google_analytics)
- tag sensitive data using contains_pii in schema.yml file

## Transformation

Transformation models should be structured as follows:
- Combine staging models 
- Prefixed with "trf_"
- Apply Business logic and calculations (eg. Currency conversions to USD etc)
- Includes logic that can be used in multiple mart models 

## Marts (Reporting layer)

Marts models should be structured as follows:
- Sub-folders based on team or domain
- Focus on business areas or key reports
- Organised into Fact (fct_) and Dimenison (dim_)  or Report (rep_) models
    - Fact models for event based data such as transactions
    - Dimension models for dimenional models such as customers
    - Report models for consolidated reporting purposes
- Include Calculations for metrics
- Partitioning and Clusering should added on relevant fields for larger datasets (eg. event_dates)
- Include tests on Foreign keys that are used to join tables in reporting layer

## Other Considerations across all 3 layers

- Models should include natural primary keys or keys generated by surrogate_key function with unique key tests
- Incremental models used on larger datasets of immutable data (in general 10M rows +) and ingestion_timestamps to handle late arriving events
- pii data should be hashed or only available to certain users 
- Avoid SELECT * on sources/explicitly name all fields for lineage tracking
- Reporting from BI Tools (eg. Tableau, Looker) should only refer to Mart layer models, not staging or transformation
- schema.yml files should contain fields and descriptions and tests
- Freshness testing for datasets to ensure data is up to date or within SLA source.yml file

## SQL Style Guide

SQL can be written in a variety of differnt ways (camel case, snake case, Pascal case etc). Ideally a repository should have an easy to read and uniform syntax throughout. 

This can be done using a linting tool such as sqlfluff. 

Suggestions for sql syntax:
- leading commas
- snake_case
- ctes indented by 1 tab/4 spaces
- ctes with long descriptive names of the data/calculation applied
- capital letters for statements (SELECT, FROM, GROUP BY etc)
- indented case when statement for example:
    , CASE
        WHEN x=1
            THEN 'Y'
        ELSE 0
    END AS my_new_column
- Explicit join types (not simply "join") with ON statement indented on following row for example:
FROM my_first_table f
LEFT JOIN my_second_table s 
    ON f.column_id = s.column_id
- table alias in the column select statement when joining tables with multiple fields 
