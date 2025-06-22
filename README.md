# Creating a SQL Server Data Warehouse

## The Project's Aim 

To take raw Customer Relationship Management (CRM) and Enterprise Resource Planning (ERP) data and make a business-ready relational database that can be used for analysis, reporting, machine learning, etc.

## The Data Warehouse Architecture 

A SQL Server database will be created and follow a "medallion" architecture, that is:

![data_architecture](https://github.com/user-attachments/assets/e7502100-bfad-41ca-98ef-632adba3fc90)


**The data sources:**:
* **CRM**: A folder containing three csv files containing data on customers, products, and sales, respectively
* **ERP**: A folder containing three css files containing data on customers, products, and customer locations, respectively

The raw data is loaded into the bronze layer with no changes. It is then cleaned, transformed, normalised, and standardised as it is loaded into the silver layer. Finally, the silver layer tables are aggregated and combined with business logic in the gold layer to provide business-ready analytical data.

SQL is used at all stages of the process to load, clean, aggregate, integrate, standardise, and query the data.

## Repository Structure
```
├── Code                              
│   ├── bronze                        
│   │   ├── ddl_bronze.sql            # Data Definition Language that defines the bronze layer tables
│   │   └── proc_bronze_load.sql      # Stored procedure to load data into the bronze layer tables
│   ├── gold                          
│   │   └── create_gold.sql           # Code that creates the three business-ready views in the gold layer
│   ├── init_database.sql             # Code that creates the database
│   └── silver                        
│       ├── ddl_silver.sql            # Data Definition Language that defines the silver layer tables
│       └── proc_silver_load.sql      # Stored procedure to load data into the bronze layer tables
├── Data
│   ├── CRM                           
│   │   ├── cust_info.csv             # File containing raw CRM customer data
│   │   ├── prd_info.csv              # File containing raw CRM product info
│   │   └── sales_details.csv         # File containing raw sales data
│   └── ERP    
│       ├── CUST_AZ12.csv             # File containing raw ERP customer data
│       ├── LOC_A101.csv              # File containing raw location data for customers
│       ├── PX_CAT_G1V2.csv           # File containing raw category information for products
├── Documentation
│   ├── data_Integration.png          # Graphical representation of how tables and views are related via columns
│   ├── data_architecture.png         # Graphical overview of the data warehouse architecture
│   ├── data_catalogue.md             # Descriptive catalogue of the data in the gold layer
│   ├── data_flow.png                 # Graphical representation of how the data flows through the warehouse
│   └── star_schema_data_model.png    # Graphic showing how dimension and fact views are related in the gold layer
├── LICENSE
├── README.md
└── tests
    └── validate_silver.sql           # Tests to validate the quality of the silver layer tables
```

## Software/Tech Used

|Tech|Purpose  |
|--|--|
| SQL |Building the database, tables and views, cleaning and validating the data, etc.  |
| SQL Server | Hosting the database |
| Azure Data Studio | Interfacing with and managing the database. I wanted to use SQL Server but I use a Mac and so can't download a Windows-based RDMS e.g. SSMS |
| Docker | Again, as I use a Mac I cannot download SQL Server. Instead, I ran the most recent Ubuntu release of SQL Server in a Docker container |
| Command Line | Configuring Docker container, configuring connection between ADS and Docker, moving files, etc. |
| Drawio | Building diagrams e.g. Data Architecture, Data Flow, etc. |

## My Links

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/stewart-robertson-data/) [![Tableau](https://img.shields.io/badge/Tableau-E97627?style=for-the-badge&logo=Tableau&logoColor=white)](https://public.tableau.com/app/profile/stewart5065/vizzes)
