
/* WIP!! */

CREATE TABLE Mgmt.LookUps
( 
	LookUp_ID              	BIGINT GENERATED ALWAYS AS IDENTITY,
	Organisation_ID			INT 		 NOT NULL 		DEFAULT 1, 
	LookUp_Name            	VARCHAR(50)  NOT NULL ,
	LookUp_Record_ID       	INT  NOT NULL ,
	LookUp_Value         	VARCHAR(255)  NOT NULL 		DEFAULT  'MISSING',
	Is_Current			   	BOOLEAN							DEFAULT  TRUE,
	Version_Key		     	INT NULL						DEFAULT  1,
	Note				   	VARCHAR(768) NULL			DEFAULT  'MISSING', 
	Display_Order       	INT 		NULL, 
	Ref_Entity				VARCHAR(255)	NULL			DEFAULT  'MISSING', 
	Created_By_User_ID		BIGINT NOT NULL 			DEFAULT 1,
	Replaced_By_User_ID		BIGINT NOT NULL 			DEFAULT 1,
	Valid_From		   		TIMESTAMP NOT NULL		    DEFAULT NOW(),
	Valid_To		  		TIMESTAMP NOT NULL			DEFAULT  '9999-12-31 23:59:59',
	Is_Skeleton		  		BOOLEAN						DEFAULT 	TRUE,
	DB_Created_Date     	TIMESTAMP  NULL    			DEFAULT  NOW(),
	DB_Created_By        	VARCHAR(255)  NULL			DEFAULT  'MISSING',
	DB_Is_Deleted         	BOOLEAN  NULL 					DEFAULT  FALSE,
	DB_Last_Updated_Date   	TIMESTAMP  NULL 				DEFAULT  NOW(),
	DB_Last_Updated_By   	VARCHAR(255)  NULL 			DEFAULT  'MISSING',
	Constraint "LookUp_ID" PRIMARY KEY (LookUp_ID)
);


/* Constaints - Organisation_ID  and App_User_ID */
ALTER TABLE Mgmt.LookUps ADD CONSTRAINT FK_LookUps__App_User
  FOREIGN KEY (Created_By_User_ID) REFERENCES Mgmt.App_User (App_User_ID);

ALTER TABLE Mgmt.LookUps ADD CONSTRAINT FK_LookUps__App_User2
  FOREIGN KEY (Replaced_By_User_ID) REFERENCES Mgmt.App_User (App_User_ID);


ALTER TABLE Mgmt.LookUps ADD CONSTRAINT FK_LookUps__Organisation
  FOREIGN KEY (Organisation_ID) REFERENCES Mgmt.Organisation (Organisation_ID);


/* Recores Table Creation*/
INSERT INTO Mgmt.LookUps(
	 organisation_id, lookup_name, lookup_record_id, lookup_value,  version_key, note, display_order, is_skeleton)
	VALUES (1, 'Creation_Note', 1,'Creation' , 1, 'Marks Table Creation', 1, TRUE);






/** General Consumption View************************************************************\
|	Allows any entity to be viewed, but excludes: 										|
|		* DB_Is_Deleted = 1																|
|	Generally most useful for a reporting layer											|
\***************************************************************************************/ 


CREATE VIEW Mgmt.vw_LookUps as
(SELECT 		LookUp_ID, 
				Organisation_ID,	
				LookUp_Name,
				LookUp_Record_ID,
				LookUp_Value,
				Is_Current,	
				Version_Key,
				Note,
				Ref_Entity,
				Valid_From,
				Valid_To
				Is_Skeleton	
FROM 		Mgmt.LookUps
WHERE  		DB_Is_Deleted is false
);



/** Create Entity **********************************************************************\
| An Entity is the container for any values. 											|
|																						|
| An Entity is always created with a sekelton record to capture Entity creation. 		|
|																						|
\*************************************************************************************** 




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
*/