# DHM_SQL_Utilities



<br>

## Structure

While core commands of SQL engines are largely standardised, DDL-type operations and system variables often differ, so there is typically a degree of customisation required by platform. 
All utilities which can be applied across database engine will have a generic guidance document, with the specific code stored in specific platform folder. 

The first part of the code filemane will match the guidance document file name. 


Platform Folders: 

|#|Platform|Folder|Usual Versions|
|:--|:---|:---|:--------|
|1|PostreSQL|x|16|

<br>

_Example:_
LookUp table has a slightly different script between SQL Server and PostgreSQL. 
The guidance document is [here](SQL/LookUp_Table.md ) 

- SQL Server Script: [Lookup_Table_T1](SQL/SQL_Server/Lookup_Table_T1.sql)


# Automation


Automation steps are captured in [.github\workflows](.github\workflows).


Automations in place include: 

1. Consolidation of all [Postgres SQL Scripts](PostgreSQL\SQL_Scripts)  to a single file (002-init.sql)[PostgreSQL\Container\docker\postgres\002-init.sql] in the Docker container folder. 


