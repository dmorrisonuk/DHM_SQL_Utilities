
-- Declare the script name and current version in variables: 

DECLARE @ScriptName NVARCHAR(255) = 'logging_test.sql';
DECLARE @ScriptVersion NVARCHAR(50) = '1.0';


--Step 1: Insert a skeleton record into SQL_Log_Table using @NextExecutionID for Execution_ID
INSERT INTO mgmt.SQL_Log_Table (
    Script_Name,
    Script_Version,
    Script_Description,
    
    Start_Time,
    Started_By
)
VALUES (
    @ScriptName,
    @ScriptVersion,
    'Test script for logging functionality',
    GETDATE(),
    SYSTEM_USER
);



-- Retrieve the Execution_ID of the inserted record
DECLARE @CurrentExecutionID BIGINT;
SELECT @CurrentExecutionID = SCOPE_IDENTITY();


-- Step 2: Check if the script has already been executed successfully
IF EXISTS (         SELECT      1 
                    FROM        mgmt.vw_SQL_Successful
                    WHERE       Script_Name = @ScriptName 
                        AND     Script_Version = @ScriptVersion
)
            BEGIN
                -- Update the skeleton record as unsuccessful
                UPDATE mgmt.SQL_Log_Table
                SET 
                    End_Time = GETDATE(),
                    Run_Output = 'Script already executed successfully',
                    Run_Successful = 0
                WHERE Execution_ID = @CurrentExecutionID;
            END
ELSE 
    BEGIN TRY
    -- Proceed with the script logic


    /***********************************************************************************\
    | Step 3 - Add additional script logic here - e.g. check value does not exist,      |
    |     check column being added doesn't exist, etc.                                  |
    \***********************************************************************************/
    IF 1=1
        THROW 50000, 'Forced error: 1 does not equal 2.', 1;

    ELSE 
        PRINT 'Working';

        -- Step 4.i: Update the skeleton record as successful
        UPDATE mgmt.SQL_Log_Table
        SET 
            End_Time = GETDATE(),
            Run_Output = 'Printed Working',
            Run_Successful = 1
        WHERE Execution_ID = @CurrentExecutionID;

    END TRY
    
    BEGIN CATCH
    -- Step 4ii: Handle errors and update the skeleton record as unsuccessful
    UPDATE mgmt.SQL_Log_Table
    SET 
        End_Time = GETDATE(),
        Run_Output = ERROR_MESSAGE(),
        Run_Successful = 0
    WHERE Execution_ID = @CurrentExecutionID;


    PRINT 'Error occurred: ' + ERROR_MESSAGE();

    END CATCH;



