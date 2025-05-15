
USE master;

-- Create LOGON if it does not exist
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'SQL_MGMT_UTILITIES')
BEGIN
    CREATE LOGIN SQL_MGMT_UTILITIES WITH PASSWORD = 'StrongPassword123!', CHECK_POLICY = OFF;
END;



Use Test_Data;


-- Grant access to the database for the principal
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'SQL_MGMT_UTILITIES')
BEGIN
    CREATE USER SQL_MGMT_UTILITIES FOR LOGIN SQL_MGMT_UTILITIES;
END;

-- Grant necessary permissions
ALTER ROLE db_owner ADD MEMBER SQL_MGMT_UTILITIES;




-- Impersonate SQL_MGMT_UTILITIES
EXECUTE AS LOGIN = 'SQL_MGMT_UTILITIES';

GO

/* Create MGMT Schema */
CREATE SCHEMA Mgmt AUTHORIZATION SQL_MGMT_UTILITIES;


GO



/* Create a table to log script executions */ 
-- Create a sequence for Execution_ID
IF NOT EXISTS (SELECT * FROM sys.sequences WHERE name = 'Execution_ID_Seq' AND schema_id = SCHEMA_ID('mgmt'))
BEGIN
    CREATE SEQUENCE mgmt.Execution_ID_Seq
    AS BIGINT
    START WITH 1
    INCREMENT BY 1;
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SQL_Log_Table' AND schema_id = SCHEMA_ID('mgmt'))
BEGIN
    CREATE TABLE mgmt.SQL_Log_Table (
        Execution_ID BIGINT PRIMARY KEY DEFAULT (NEXT VALUE FOR mgmt.Execution_ID_Seq),
        Script_Name NVARCHAR(255) NOT NULL,
        Script_Version NVARCHAR(50) NOT NULL,
        Script_Description NVARCHAR(MAX),
        Start_Time DATETIME NOT NULL DEFAULT GETDATE(),
        Started_By NVARCHAR(128) NOT NULL DEFAULT SYSTEM_USER,
        End_Time DATETIME NULL,
        Run_Output NVARCHAR(MAX) NULL,
        Run_Successful BIT NOT NULL DEFAULT 0
    );
END;

GO

-- Create a view to display successful script executions
CREATE VIEW mgmt.vw_SQL_Successful AS
SELECT 
    Script_Name,
    Script_Version,
    Start_Time
FROM 
    mgmt.SQL_Log_Table
WHERE 
    Run_Successful = 1;

-- Record Table Creation
INSERT INTO mgmt.SQL_Log_Table (
    Script_Name,
    Script_Version,
    Script_Description,
    Start_Time,
    Started_By,
    End_Time,
    Run_Output,
    Run_Successful
)
VALUES (
    'Create_YourTableName.sql',
    '1.0',
    'Table First Creation',
    GETDATE(),
    SYSTEM_USER,
    GETDATE(),
    NULL,
    1
);

