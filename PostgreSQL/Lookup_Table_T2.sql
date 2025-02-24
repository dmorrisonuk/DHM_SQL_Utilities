
/* WIP!! */

CREATE TABLE Mgmt.LookUps
( 
	LookUp_ID              	BIGINT GENERATED ALWAYS AS IDENTITY,
	LookUp_Name            	VARCHAR(50)  NOT NULL ,
	LookUp_Record_ID       	INT  NOT NULL ,
	LookUp_Value         	VARCHAR(255)  NOT NULL 		DEFAULT  'MISSING',
	Is_Current			   	BOOLEAN							DEFAULT  TRUE,
	Version_Key		     	INT NULL						DEFAULT  1,
	Note				   	VARCHAR(768) NULL			DEFAULT  'MISSING', 
	Display_Order       	INT 		NULL, 
	Ref_Entity				VARCHAR(255)	NULL			DEFAULT  'MISSING', 
	Valid_From		   		TIMESTAMP	NOT NULL					DEFAULT NOW(),
	Valid_To		  		TIMESTAMP NOT NULL			DEFAULT  '9999-12-31 23:59:59',
	Is_Skeleton		  		BOOLEAN						DEFAULT 	TRUE,
	DB_Created_Date     	TIMESTAMP  NULL    			DEFAULT  NOW(),
	DB_Created_By        	VARCHAR(255)  NULL			DEFAULT  'MISSING',
	DB_Is_Deleted         	BOOLEAN  NULL 					DEFAULT  FALSE,
	DB_Last_Updated_Date   	TIMESTAMP  NULL 				DEFAULT  NOW(),
	DB_Last_Updated_By   	VARCHAR(255)  NULL 			DEFAULT  'MISSING',
	Constraint "LookUp_ID" PRIMARY KEY (LookUp_ID)
);



INSERT INTO Mgmt.lookups(
	lookup_id, lookup_name, lookup_record_id, lookup_value, is_current, version_key, note, display_order, valid_from, valid_to, is_skeleton, db_created_date, db_created_by, db_is_deleted, db_last_updated_date, db_last_updated_by)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);






/** Create Entity 
| An Entity is the container for any values. 
| An Entity is always created with a sekelton record to capture Entity creation. 
\******************************/ 



INSERT INTO Mgmt.lookups(
	 lookup_name, lookup_record_id, lookup_value, is_current, version_key, note, display_order, valid_from, valid_to, is_skeleton, db_created_date, db_created_by, db_is_deleted, db_last_updated_date, db_last_updated_by)
	VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);


-- PROCEDURE: mgmt.Create_LookUp(character varying[])

-- DROP PROCEDURE IF EXISTS mgmt."Create_LookUp"(character varying[]);

CREATE OR REPLACE PROCEDURE Mgmt.sp_Create_LookUp
LANGUAGE 'sql'
AS $BODY$
SELECT "LookUp_ID"
	FROM mgmt."Test";
$BODY$;
ALTER PROCEDURE mgmt."Select_LookUps"()
    OWNER TO myuser;

COMMENT ON PROCEDURE mgmt."Create_LookUp"(character varying[])
    IS 'Logical LookUp Creation';
