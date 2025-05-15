# Logging Database Changes


The follwing approach can be used for both DDL/DCL updates and data change scripts, which are not covered by database migration frameworks. 

The principle is that each script should 
1. Record an attempted execution before any other logic is applied
2. Check that the current version of script itself has not succesfully run on this environment
3. That the database state is as expected before first execution - e.g. the object, column or data item does not exist. 
4. Record the outcome, whether successful or not. 


## SQL Log Table DDL

See [001_DB_Preparation](../SQL_Scripts/001_DB_Preparation.md) for the table DDL, which will be created in a `mgmt` schema. 

<br>

## SQL Change Template

This is a template implementing the control flow described above: 

[T-SQL_Control_Flow_Template.sql](SQL_Server\T-SQL_Control_Flow_Template.sql)

<br>
This template relies on a log table created in [001_DB_Preparation](SQL_Server\SQL_Scripts\001_DB_Preparation.sql)
It will fail in its current form until appropriate logic is added to Step 3 section. 
<br>


