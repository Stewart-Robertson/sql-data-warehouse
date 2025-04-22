# Data Catalogue for the Gold Layer

The Gold layer in the database contains business-ready data that can be used for ad-hoc queries, BI reporting, machine learning, etc.

This layer is uses a **_Star Schema_** with two _dimension_ views and one _fact_ view:

|View Type|Table Name  |
|--|--|
| Dimension |gold.dim_customers  |
| Dimension |gold.dim_products
| Fact | gold.fact_sales

Both dimension views contain surrogate keys which are used to relate them to the fact view in a mandatory-one-to-mandatory-many configuration.

![Star schema data model drawio](https://github.com/user-attachments/assets/5344f0fc-54e2-451c-95cc-4751ed7194ff)


## Customers dimension view

**Purpose**: Stores information on customers.

| Column Name |Data Type | Description|
|--|--|--|
| customer_key | INT | The table's **Primary Key**
| customer_id | INT | Customer identifier
| customer_number | VARCHAR(50) | Customer identifier
| first_name | VARCHAR(50) | Customer's first name
| last_name | VARCHAR(50) | Customer's last name
| marital_status | VARCHAR(50) | Single, Married, Unknown 
| gender | VARCHAR(50) | Male, Female, Unknown
| birth_date | DATE | Customer's D.O.B
| country | VARCHAR(50) | The country from which the order originated
| created_date | DATE | When the order was made

## Products dimension view

**Purpose**: Stores information on products.

| Column Name |Data Type | Description|
|--|--|--|
| product_key | INT | The table's **Primary Key**
| product_number | VARCHAR(50) | Product identifier
| product_name | VARCHAR(50) | Name of the product
| category_id | VARCHAR(50) | Category identifier
| category | VARCHAR(50) | Name of the category of the product e.g. "Accessories", "Bikes", etc.
| subcategory | VARCHAR(50) | Name of the subcategory of the product e.g. "Bike racks", "Bike stands", Jerseys", etc.
| product_line | VARCHAR(50) | The product line of the product e.g. "Mountain", "Road", "Touring", etc.
| product_cost | INT | The cost of the product in USD
| maintenance | VARCHAR(50) | Whether the product requires mechanical maintenance ("Yes", "No")
| product_start_date | DATE | The date at which the product was first available

## Sales fact view

**Purpose**: Stores information on sales transactions, combining information on customers and products.

| Column Name |Data Type | Description|
|--|--|--|
| order_number | VARCHAR(50) | Order identifier
| product_key | INT | **Foreign key 1**
| customer_key | INT | **Foreign key 2**
| quantity | VARCHAR(50) | The amount of the product sold in the order
| price | VARCHAR(50) | The price of one unit of the product
| sales_amount | VARCHAR(50) | The total amount of product sold in the order in USD (quantity * price)
| order_date | VARCHAR(50) | The date the order was placed
| shipped_date | INT | When the order was shipped
| due_date | VARCHAR(50) | When the order is due to be delivered

