




# Object Naming Conventions



> [!NOTE]
> Not all SQL platforms are case sensitive. Therefore while PascalCase can be used to highlight objects, underscore `_` is the **required** separator between Prefixes, Table Name and Suffixes.
> <br>
> Expect that TableName and tablename are synonymous until confirmed otherwise




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



## Trigger Object Suffixes

|Action|Suffix|
|:-----|:---|
|Insert only|_tI|
|Update only|_tU|
|Delete only|_tD|
|Insert, Update, Delete|_tIUD|













