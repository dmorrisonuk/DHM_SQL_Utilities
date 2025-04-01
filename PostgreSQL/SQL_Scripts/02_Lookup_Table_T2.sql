
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
   	DB_Created_Date     	TIMESTAMP WITH TIME ZONE  NULL  DEFAULT  NOW(),
   	DB_Created_By        	VARCHAR(255)              NULL	DEFAULT  Current_User,
   	DB_Is_Deleted         	BOOLEAN                   NULL 	DEFAULT  FALSE,
   	DB_Last_Updated_Date  	TIMESTAMP WITH TIME ZONE  NULL 	DEFAULT  NOW(),
   	DB_Last_Updated_By   	VARCHAR(255)              NULL 	DEFAULT  Current_User,
	Constraint "LookUp_ID" PRIMARY KEY (LookUp_ID)
);



/* Constaints - Organisation_ID  and App_User_ID */
ALTER TABLE Mgmt.LookUps ADD CONSTRAINT FK_LookUps__App_User
  FOREIGN KEY (Created_By_User_ID) REFERENCES Mgmt.App_User (App_User_ID);

ALTER TABLE Mgmt.LookUps ADD CONSTRAINT FK_LookUps__App_User2
  FOREIGN KEY (Replaced_By_User_ID) REFERENCES Mgmt.App_User (App_User_ID);


ALTER TABLE Mgmt.LookUps ADD CONSTRAINT FK_LookUps__Organisation
  FOREIGN KEY (Organisation_ID) REFERENCES Mgmt.Organisation (Organisation_ID);


/* Records Table Creation against skeleton Org and with Admin user */
INSERT INTO Mgmt.LookUps(
	 organisation_id, lookup_name, lookup_record_id, lookup_value,  version_key, note, display_order, is_skeleton)
	VALUES (1, 'Creation_Note', 1,'Creation' , 1, 'Marks Table Creation', 1, TRUE);






/** General Consumption View************************************************************\
|	Allows any entity to be viewed, but excludes: 										|
|		* DB_Is_Deleted = 1																|
|	Generally most useful for a reporting layer											|
|		History filter (e.g. Is-Current) = True NOT Applied								|
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
AND LookUp_Record_ID > 0 -- skips the Lookup Creation Record
);



/** Create Entity **********************************************************************\
| An Entity is the container for any values. 											|
|																						|
| An Entity is always created with a sekelton record to capture Entity creation and to 	|
|	be its own sekelton 																|
|																						|
\***************************************************************************************/ 


-- PROCEDURE: mgmt.Create_LookUp(character varying[])
CREATE OR REPLACE PROCEDURE Mgmt.sp_Create_LookUp(
	IN p_LookUp_Name VARCHAR(50),
	IN p_App_User_ID BIGINT,
	IN p_Organisation_ID INT DEFAULT 1,
	IN p_Ref_Entity VARCHAR(255) DEFAULT 'MISSING'
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_LookUp_Record_ID INT;
	v_User_Exists BOOLEAN;
	v_Name_Exists BOOLEAN;
BEGIN
	-- Check if the App_User_ID exists in the Mgmt.App_User table
	SELECT EXISTS(SELECT 1 FROM Mgmt.App_User WHERE App_User_ID = p_App_User_ID)
	INTO v_User_Exists;

	IF NOT v_User_Exists THEN
		RAISE EXCEPTION 'App_User_ID % does not exist in Mgmt.App_User table', p_App_User_ID;
	END IF;

	-- Check if the LookUp_Name already exists in the Mgmt.LookUps table
	SELECT EXISTS(SELECT 1 FROM Mgmt.LookUps WHERE LookUp_Name = p_LookUp_Name)
	INTO v_Name_Exists;

	IF v_Name_Exists THEN
		RAISE EXCEPTION 'LookUp_Name % already exists in Mgmt.LookUps table', p_LookUp_Name;
	END IF;


	-- Generate a new LookUp_Record_ID based on the max value for the given LookUp_Name
	SELECT COALESCE(MAX(LookUp_Record_ID), 0) + 1
	INTO v_LookUp_Record_ID
	FROM Mgmt.LookUps
	WHERE LookUp_Name = p_LookUp_Name;


	INSERT INTO Mgmt.LookUps (
					LookUp_Name,
					LookUp_Record_ID ,
					LookUp_Value,
					Ref_Entity,
					Created_By_User_ID,
					Organisation_ID
				)

				VALUES (
					p_LookUp_Name,
					0, -- zero captures lookup creation
					concat(p_LookUp_Name, ' - Creation'),
					p_Ref_Entity,
					p_App_User_ID,
					p_Organisation_ID 
					);

				-- Dynamically create a view using the provided LookUp_Name
				EXECUTE format('
					CREATE OR REPLACE VIEW Mgmt.%I AS
					SELECT 
						LookUp_ID,
						Organisation_ID,
						LookUp_Name,
						LookUp_Record_ID,
						LookUp_Value,
						Is_Current,
						Version_Key,
						Note,
						Ref_Entity,
						Valid_From,
						Valid_To,
						Is_Skeleton
					FROM Mgmt.LookUps
					WHERE LookUp_Name = %L
						AND DB_Is_Deleted = FALSE;',
					concat('vw_LU_',p_LookUp_Name), p_LookUp_Name);

END;
$$;


COMMENT ON PROCEDURE mgmt.sp_Create_LookUp
    IS 'Logical LookUp Creation.';

-- Next - add or update values to an existing lookup, with input arrays