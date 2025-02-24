# LookUp Table

## Purpose

The purpose of this table is provide a generic way of holding variables in a relational database, with histroty & attribution, without creating a physical table for each logical entity. 

It is designed for holding slowly changing data entites, with a limited number of values, which can be updated in a consistent manner. 

There are 2 versions of the table depdnding on requirements - a Type 1 and Type 2 from the _application_ view. 
Additional columns exist for DB audit purposes. 

**note:** Use only 1 version of the table within a given database. If in doubt, use the Type 2 table as it offers more flexibility in requirements. 

<br> 

## Table Structure

Schema: Mgmt
Table Name: LookUps


<br> 

### Type 1 Dictionary 

<br>

|Table Column|Definition|Example Value|When to Use|
|:---|:---|:---|:---|
|LookUp_ID|	Table Identity column	|1| Never call directly|
|Organisation_ID|Entity ID to allow logial separation between clients/offices etc.|Insert|
|LookUp_Name|Logical name of the reference data entity|'Environment'|Insert and Update|	
|LookUp_Record_ID|Integer key relative to that LOOKUP_NAME. Starts at one for each Reference Data Entity. Can be controlled by a sequence|Insert and Update|1|
|LookUp_Value|Actual value to be held|'Prod'|Insert|
|Is_Current|Allows for application-level logical deletion|1|Insert, Update and Delete|		
|LookUp_Version_Key|A second sequence-controlled key, which can be used to link data uploaded together into a single version|1|Insert|
|Note|Optional Note|||
|Display_Order|Order of values to be shown in lookups etc.|1|Where an ordering is required, which deviates from the insertion sequence (however controlled)|

+ DB Columns, which support a basic level of auditing.

<br>


### Type 2 Dictionary 

This table creates a full, time-stamped history of the reference values, by adding a new row for each change. 
As such there is no `update` semantics - only `insert` and `logical_delete`

<br>

|Table Column|Definition|Example Value|When to Use|
|:---|:---|:---|:---|
|LookUp_ID|	Table Identity column	|1| Never call directly|
|Organisation_ID|Entity ID to allow logial separation between clients/offices etc.|Insert|
|LookUp_Name|Logical name of the reference data entity|'Environment'|Insert|	
|LookUp_Record_ID|Integer key relative to that LOOKUP_NAME. Starts at one for each Reference Data Entity. Can be controlled by a sequence|Insert|1|
|LookUp_Value|Actual value to be held|'Prod'|Insert|
|LookUp_Version_Key|A second sequence-controlled key, which can be used to link data uploaded together into a single version|1|Insert|
|Note|Optional Note||Insert|
|Display_Order|Order of values to be shown in lookups etc.|1|Where an ordering is required, which deviates from the insertion sequence (however controlled)|
|Ref_Entity|Name of any reference data entity from an external data model - e.g. ACORD, Oasys|Customer|Insert, Update|	
|Created_By|Process/user who created this record|'user_1'|Insert|
|Valid_From|Start date of validity of this record|'2025-01-01 00:00:00' |Insert|
|Valid_To|End-Date of validity of this record. Use a default high end date for new records|'9999-31-12 23:59:59'|Insert, Logical_Delete|
|Updated_By|Process/user who deleted this record|'user_1'|Insert, Logical_Delete|
|Is_Skelton|Is this record a skeleton - i.e. a record created to allow a surrogate key to be generated and used before full population|

<br>


## Updating Data

Stored proceedures are provided to allow data to be edited. 
The proceedures provided follow CRUD sequence rather than typical API methods to allow database permissions to be specified by user. 

All data entry should be done via stored proceedures.  
Data should be consumed by views. 



### Inserting Data

[] Sprocs...



### Retreiving Data

[] Views... 















