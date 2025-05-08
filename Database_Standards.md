


# Object Naming Conventions


> ! Not all SQL platforms are case sensitive ! 



## Golden Rules

1. Avoid using keywords as the only part of an object name - e.g. avoid 'User', use 'App_Users'
2. Do not use case to distinghuish between two separate objects. Expect that TableName and tablename are synonymous until confirmed otherwise. Therefore while PascalCase can be used to highlight objects, underscore `_` is the **required** separator between Prefixes, Table Name and Suffixes.

<br>



## Object Prefixes

Prefixes are used to indicate object type except for: 
- tables including any part of their path (schemas and databases)
- security principals - e.g. Logins, Users
- objets that are clear by their naming requirements, e.g. 
  - simple variables (prefixed with @)
  - temp tables (prefixed with # or ## on SQL Server)

  

|Object Type|Prefix|
|:-----|---|
|Foreign Key Constraint|FK_|
|Function|fn_|
|Index|IX_|
|Primary Key constraint|PK_|
|Stored Proceedure|sp_|
|Sequence|seq_|
|Table Variable|@tv_|
|Trigger|trg_|
|View|vw_|





<br>


## Table Names

Make table names meaningful, separating words with an underscore. 
(PascalCase is not supported by all relational DB engines, so can lose fidelity).  

<br>

## Field Names

There are many views on correct field name conventions. Generally the same guidance as table names applies - Make table names meaningful, separating words with an underscore. 
PascalCase can be used where supported, but if in doubt use lower_case field names. 




<br> 


## Surrogate Keys ("Primary Keys") 

Surrogate Keys field names **should** be meaningful - e.g. User_ID. This simplifies the making and review of code, especially join conditions. 

The surrogate key **values** themselves should not be, e.g. 1,2,3 

<br>

- The exception is, if pursuing unique keys across the database using an alpha-numeric solution, sourec and object identifiers can be included, e.g.
User_1, User_2.
- This approach has 2 downsides:
-- Surrogate keys will need to be text strings, which are typically slightly less performant and require more storage
-- A maximum string length will typically have to be padded to allow meaningful sorting  

<br>


## Foreign Key Naming Conventions

Use a double-underscore between table names as tables may have underscores in name - indeed this is recommended. 
FK__ForeignKeyTable__PrimaryKeyTable


As a general rule, the surrogate key name should be the same on each side of the foreign key relationship - e.g. Object_ID = Object_ID
An accepted deviation is the case of User_IDs where we want to indicate the role of the user on the record- e.g. 
- Created_By_ID
- Updated_By_ID
- Deleted_By_ID


## Stored Procedures - Additional Prefixes

Generally for every table, stored proceedures should be created to: 
1. Add or Update a record
2. Logically delete a record (app side- using Is_Current Flags)

|Prefix 1|Prefix 2|Combined|Description|
|'-----|'-----|'-----|'-----|
|sp_|AddU|sp_AddU|Will Add or Update a record. Requires p_Update = True to update, or will abord|
|sp_|LDel|sp_LDel|Will logically delete a record|






## Trigger Object Suffixes

|Action|Suffix|
|:-----|:---|
|Insert only|_tI|
|Update only|_tU|
|Delete only|_tD|
|Insert, Update, Delete|_tIUD|



# Creating Tables

Avoid using default schema (e.g. .dbo).

It is preferable to populate with default values such as "Missing", True or False, high/low end dates over leaving columns as null values. 



## Default Values


## Skeleton Records


## DB Columns

The following are a recommended set of Database columns to be created in the physical model in additionl to any in the logical model. 

These columns allow preceise transaction ordering and some degree of history capture. They should use server values for users/timestamps rather than any data provided by an application. They also allow for logical deletion at a database level in addition to any logical deletion in the application model. 

The specifics of datatype and default value vary by platform and can be found in their respective sections.  

<br> 

|Column Name|Purpose|Type|Default Value|
|:----|:--------|:-------|:--------|
|DB_Created_By|||CURRENT_USER|
|DB_Created_Date|Immutable record of when this record was first written to the database|Timestamp with Time Zone|NOW()|
|DB_Is_Deleted|Boolean Flag, allowing logical deletion at the Database level|Boolean|False|
|DB_Last_Updated_By|||CURRENT_USER|
|DB_Last_Updated_Date|Immutable record of last change to this record at database layer|Timestamp with Time Zone|NOW()|

<br>

For tables in Postgres, the DDL for these columns is: 

```
  DB_Created_Date     	TIMESTAMP WITH TIME ZONE  NULL  DEFAULT  NOW(),
  DB_Created_By        	VARCHAR(255)              NULL	DEFAULT  Current_User,
  DB_Is_Deleted         BOOLEAN                   NULL 	DEFAULT  FALSE,
  DB_Last_Updated_Date  TIMESTAMP WITH TIME ZONE  NULL 	DEFAULT  NOW(),
  DB_Last_Updated_By   	VARCHAR(255)              NULL 	DEFAULT  Current_User,
  ```

<br> 



# Consuming Data

<br>

Data should be consumed via views or stored procedures. No process or consumer should consume data directly from tables to avoid schema binding.


Ideally consumption objects should be in schemata segmented by consumer groups - this may require ownership chaining to be established. 

<br>



# Constraints

Constaints such as Primary Keys, Foreign Keys or Indexes should be defined where expected, and should generally not be suspended by database operations. 

The use of skeleton records means that dropping / re-creation of constraints is rarely necessary in day-to-day operations





# Alternate Style Guides


| Guide Name         | Link                                   |
|:-------------------|:---------------------------------------|
| Simon Holywell - SQL Style Guide    | [Link](https://www.sqlstyle.guide/)    |
| PostgreSQL Guide   | [Link](https://www.postgresql.org/docs/) |
| Microsoft SQL Guide| [Link](https://learn.microsoft.com/en-us/sql/) |
| Oracle SQL Guide   | [Link](https://docs.oracle.com/en/database/) |
| MySQL Style Guide  | [Link](https://dev.mysql.com/doc/)     |