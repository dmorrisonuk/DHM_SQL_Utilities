
DECLARE @SchemaName NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);

SET @SchemaName = 'Mgmt';

SET @SQL = N'IF NOT EXISTS (SELECT schema_name
                            FROM information_schema.schemata
                            WHERE schema_name = ''' + @SchemaName + ''')
            BEGIN
                EXEC sp_executesql N''CREATE SCHEMA ' + @SchemaName + ''';
            END';

EXEC sp_executesql @SQL;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'YourTableName')
BEGIN

CREATE TABLE Mgmt.LookUps
( 
	[LOOKUP_ID]                INT IDENTITY ( 1,1 )  NOT NULL ,
	[LOOKUP_NAME]              VARCHAR(50)  NOT NULL ,
	[LOOKUP_RECORD_ID]         INT  NOT NULL ,
	[LOOKUP_VALUE]             VARCHAR(255)  NOT NULL 		DEFAULT  'MISSING',
	IS_CURRENT				   BIT							DEFAULT  1,
	[VERSION_KEY]		       INT NULL						DEFAULT  1,
	[NOTE]				       VARCHAR(768) NULL			DEFAULT  'MISSING', 
	DISPLAY_ORDER		       INT 		NULL, 
	[DB_CREATED_DATE]          DATETIME  NULL    			DEFAULT  CURRENT_TIMESTAMP,
	[DB_CREATED_BY]            VARCHAR(255)  NULL			DEFAULT  CURRENT_USER,
	[DB_IS_DELETED]            BIT  NULL 					DEFAULT  'FALSE',
	[DB_LAST_UPDATED_DATE]     DATETIME  NULL 				DEFAULT  CURRENT_TIMESTAMP,
	[DB_LAST_UPDATED_BY]       VARCHAR(255)  NULL 			DEFAULT  CURRENT_USER
	PRIMARY KEY  CLUSTERED ([LOOKUP_ID] ASC)
)
;

END;
