

/* Create Mgmt schema */

CREATE SCHEMA Mgmt
    AUTHORIZATION myuser;



/* Create Organisation Table */

CREATE TABLE Mgmt.Organisation
(
  Organisation_ID integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Company_Name varchar(200) DEFAULT 'MISSING' NOT NULL,
  Parent_Organisation_ID integer DEFAULT 1 NOT NULL,
  Inherit_Flg boolean DEFAULT FALSE NOT NULL,
  Created_By_User_ID bigint DEFAULT 1 NOT NULL,
  Created_Date timestamp DEFAULT NOW() NOT NULL,
  Is_Current boolean DEFAULT TRUE,
  Updated_by_User_ID bigint DEFAULT 1 NOT NULL,
  Updated_Date timestamp DEFAULT '9999-12-31 23:59:59' NOT NULL,
  DB_Created_Date     	TIMESTAMP  NULL    			DEFAULT  NOW(),
  DB_Created_By        	VARCHAR(255)  NULL			DEFAULT  'MISSING',
  DB_Is_Deleted         	BOOLEAN  NULL 					DEFAULT  FALSE,
  DB_Last_Updated_Date   	TIMESTAMP  NULL 				DEFAULT  NOW(),
  DB_Last_Updated_By   	VARCHAR(255)  NULL 			DEFAULT  'MISSING',
  Constraint "Organisation_ID" PRIMARY KEY (Organisation_ID)
 )
;


ALTER TABLE Mgmt.Organisation ADD CONSTRAINT FK_Organisation__Organisation
  FOREIGN KEY (Parent_Organisation_ID) REFERENCES Mgmt.Organisation (Organisation_ID);


COMMENT ON TABLE Mgmt.Organisation IS E'Client organisational structure. \n\nNeeds 3 default skeleton records: \n\n1 = Missing\n2 = Public\n3 = Ultimate Parent\n\nSelf-referencing to allow for a hierarchy to be defined. \n\nInherit_Flg specifies where permissions should be inheritied - i.e. a user with the permissions in #3 will have the same permission in all lower strata of the org. \n\nTherefore there may be 2 parent-child relations coded - where Inherit = True and Inherit = False\n';
COMMENT ON COLUMN Mgmt.Organisation.Inherit_Flg IS E'Default = False - i.e. do NOT inherit';


INSERT INTO Mgmt.Organisation(company_name, parent_organisation_id, inherit_flg)
	VALUES  ('Ultimate-Parent', 1, False),
	        ('Sub-Co', 1, False);

CREATE UNIQUE INDEX IX_OrgName_Current on Mgmt.Organisation (Company_Name) WHERE Is_Current = TRUE;






/* Create App_User Table */


CREATE TABLE Mgmt.App_User
(
  App_User_ID bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  User_Name varchar(255) DEFAULT 'MISSING' NOT NULL,
  User_Email varchar(255) DEFAULT 'MISSING' NOT NULL,
  User_Created_Date timestamp DEFAULT NOW() NOT NULL,
  User_Modified_Date timestamp DEFAULT NOW() NOT NULL,
  User_Last_Access_Date timestamp DEFAULT '1999-01-01 00:00:01.000' NULL,
  User_Cred_SO varchar(255) DEFAULT 'MISSING',
  User_Password varchar(768),
  Login_Allowed boolean DEFAULT True,
  Last_Modified_By bigint DEFAULT 1 NOT NULL,
  Is_Current boolean DEFAULT True ,
  DB_Created_Date     	TIMESTAMP  NULL    			DEFAULT  NOW(),
	DB_Created_By        	VARCHAR(255)  NULL			DEFAULT  'MISSING',
	DB_Is_Deleted         	BOOLEAN  NULL 					DEFAULT  FALSE,
	DB_Last_Updated_Date   	TIMESTAMP  NULL 				DEFAULT  NOW(),
	DB_Last_Updated_By   	VARCHAR(255)  NULL 			DEFAULT  'MISSING'
  Constraint "App_User_ID" PRIMARY KEY (App_User_ID)
)
;


COMMENT ON COLUMN Mgmt.App_User.User_Cred_SO IS E'Used to hold secondary credential ID (but not password) for a secret manager / SSO provider.';
COMMENT ON COLUMN Mgmt.App_User.User_Password IS E'NOT IN USE\nPlaceholder for user passwords if not managed at DB level. Passwords should be salted and hashed on entry.';
COMMENT ON COLUMN Mgmt.App_User.Login_Allowed IS E'NOT IN USE\nCould be used to prevent user login without removing from system. Never remove user ids';
COMMENT ON COLUMN Mgmt.App_User.Last_Modified_By IS E'Captures Users acting on other User accounts - e.g. administrators';

CREATE UNIQUE INDEX IX_User_Name_Current on Mgmt.App_User (User_Name) WHERE Is_Current = TRUE;

/* Insert Skeleton Admin User */
INSERT INTO Mgmt.App_User	user_name) 
VALUES ('Administrator1');

/* Add Organisation <-> App_User FKs */

ALTER TABLE Mgmt.Organisation ADD CONSTRAINT FK_Organisation__App_User
  FOREIGN KEY (Created_By_User_ID) REFERENCES Mgmt.App_User (App_User_ID);

ALTER TABLE Mgmt.Organisation ADD CONSTRAINT FK_Organisation__App_User2
  FOREIGN KEY (Updated_by_User_ID) REFERENCES Mgmt.App_User (App_User_ID);










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
*//*******************************************************************\
| 	Environment Entity is an example of holding an entity in 		|
|		LookUps Table												|
\*******************************************************************/


INSERT INTO mgmt.lookups(
	organisation_id, lookup_name, lookup_record_id, lookup_value, is_current, version_key, display_order, ref_entity)
	VALUES	
(1,'Environment',1,'Production',TRUE,1,1,'Environment'),
(1,'Environment',2,'Pre_Prod',TRUE,1,2,'Environment'),
(1,'Environment',3,'UAT',TRUE,1,3,'Environment'),
(1,'Environment',4,'SIT',TRUE,1,4,'Environment'),
(1,'Environment',5,'DEV',TRUE,1,5,'Environment');	



CREATE VIEW Mgmt.vw_Environment as
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
AND LookUp_Name = 'Environment'
AND Is_Current is True
);INSERT INTO mgmt.lookups(
	organisation_id, lookup_name, lookup_record_id, lookup_value, is_current, version_key, note, display_order)
	VALUES	
(1,'File_Type',1,'csv',TRUE,1,'',1),
(1,'File_Type',2,'xls',TRUE,1,'Excel to 2003',2),
(1,'File_Type',3,'xlsx',TRUE,1,'Excel 2007 onwards',3),
(1,'File_Type',4,'xlsm',TRUE,1,'',4),
(1,'File_Type',5,'tsv',TRUE,1,'',5),
(1,'File_Type',6,'txt',TRUE,1,'',6);



CREATE VIEW Mgmt.vw_File_Type as
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
AND LookUp_Name = 'File_Type'
AND Is_Current is True
)



/*******************************************************************\
|                                                                   |   
|   Create currency table                                           |              
|   Populate with ISO list                                          |                         
|   Create exchange rate table (with history)                       |
|   Populate with exchange rates at _____________                   |
|                                                                   |                      
\*******************************************************************/



-- Create currency table
CREATE TABLE Mgmt.Currency (
    Currency_ID             integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
    ISO_Currency_Code       VARCHAR(3) NOT NULL,
    Internal_Currency_Code  VARCHAR(20) NOT NULL DEFAULT 'Not Used',
    ISO_Currency_Name       VARCHAR(255) NOT NULL,
    Is_Current              BOOLEAN NOT NULL DEFAULT TRUE,
    Created_By_User_ID		BIGINT NOT NULL 			DEFAULT 1,
    Replaced_By_User_ID		BIGINT NOT NULL 			DEFAULT 1,
	Valid_From		   		TIMESTAMP NOT NULL		    DEFAULT NOW(),
	Valid_To		  		TIMESTAMP NOT NULL			DEFAULT  '9999-12-31 23:59:59',
    Is_Skeleton		  		BOOLEAN						DEFAULT  FALSE, -- defaulted to false to simplify buil insert
    DB_Created_Date     	TIMESTAMP  NULL    			DEFAULT  NOW(),
    DB_Created_By        	VARCHAR(255)  NULL			DEFAULT  'MISSING',
    DB_Is_Deleted         	BOOLEAN  NULL 				DEFAULT  FALSE,
    DB_Last_Updated_Date   	TIMESTAMP  NULL 			DEFAULT  NOW(),
    DB_Last_Updated_By   	VARCHAR(255)  NULL 			DEFAULT  'MISSING',
    Constraint "Currency_ID" PRIMARY KEY (Currency_ID)
);


COMMENT ON COLUMN Mgmt.Currency.Internal_Currency_Code IS E'Used where the ISO code has been replaced for internal use.';


ALTER TABLE Mgmt.Currency  ADD CONSTRAINT FK_Currency__Users
  FOREIGN KEY (Created_By_User_ID) REFERENCES Mgmt.App_User (App_User_ID);

ALTER TABLE Mgmt.Currency  ADD CONSTRAINT FK_Currency__Users2
  FOREIGN KEY (Replaced_By_User_ID) REFERENCES Mgmt.App_User (App_User_ID);


CREATE VIEW Mgmt.vw_Currency AS
SELECT 
    Currency_ID,
    ISO_Currency_Code,
    Internal_Currency_Code,
    ISO_Currency_Name
FROM Mgmt.Currency
WHERE       Is_Current = TRUE
AND         DB_Is_Deleted = FALSE;


/* Created by Co-Pilot - not bad. Automatically picked up the Type 2 behaviour ****\

Had to add the DB_Last_Updated_By and DB_Last_Updated_Date fields to the Proc

 */

CREATE OR REPLACE PROCEDURE Mgmt.Add_Currency(
    p_ISO_Currency_Code VARCHAR(3),
    p_ISO_Currency_Name VARCHAR(255),
    p_Internal_Currency_Code VARCHAR(20) DEFAULT 'Not Used',
    p_Update BOOLEAN DEFAULT FALSE
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Mgmt.Currency WHERE ISO_Currency_Code = p_ISO_Currency_Code AND Is_Current = TRUE AND DB_Is_Deleted = FALSE) THEN
        IF p_Update THEN
            UPDATE Mgmt.Currency
            SET Is_Current = FALSE,
                Valid_To = NOW(),
                DB_Is_Deleted = TRUE,
                DB_Last_Updated_Date = NOW(),
                DB_Last_Updated_By = Current_User
            WHERE ISO_Currency_Code = p_ISO_Currency_Code AND Is_Current = TRUE AND DB_Is_Deleted = FALSE;

            INSERT INTO Mgmt.Currency (ISO_Currency_Code, ISO_Currency_Name, Internal_Currency_Code)
            VALUES (p_ISO_Currency_Code, p_ISO_Currency_Name, p_Internal_Currency_Code);
        ELSE
            RAISE NOTICE 'Currency % already exists and update is set to FALSE.', p_ISO_Currency_Code;
        END IF;
    ELSE
        INSERT INTO Mgmt.Currency (ISO_Currency_Code, ISO_Currency_Name, Internal_Currency_Code)
        VALUES (p_ISO_Currency_Code, p_ISO_Currency_Name, p_Internal_Currency_Code);
    END IF;
END;
$$;



/*** Insert Statements ***/


Insert Into Mgmt.Currency (ISO_Currency_Code, ISO_Currency_Name, Is_Skeleton)
Values
('XXX','The codes assigned for transactions where no currency is involved', TRUE);

Insert Into Mgmt.Currency (ISO_Currency_Code, ISO_Currency_Name)
Values
('AUD', 'Australian Dollar'),
('USD', 'United States Dollar'),
('GBP', 'British Pound'),
('EUR', 'Euro'),
('NZD', 'New Zealand Dollar'),
('JPY', 'Japanese Yen'),
('CAD', 'Canadian Dollar'),
('CHF', 'Swiss Franc'),
('SGD', 'Singapore Dollar'),
('HKD', 'Hong Kong Dollar'),
('SEK', 'Swedish Krona'),
('NOK', 'Norwegian Krone'),
('DKK', 'Danish Krone'),
('ZAR', 'South African Rand'),
('INR', 'Indian Rupee'),
('CNY', 'Chinese Yuan'),
('THB', 'Thai Baht'),
('MYR', 'Malaysian Ringgit'),
('IDR', 'Indonesian Rupiah'),
('PHP', 'Philippine Peso'),
('KRW', 'South Korean Won'),
('VND', 'Vietnamese Dong'),
('TWD', 'Taiwan Dollar'),
('SAR', 'Saudi Riyal'),
('AED', 'United Arab Emirates Dirham'),
('QAR', 'Qatari Riyal'),
('OMR', 'Omani Rial'),
('KWD', 'Kuwaiti Dinar'),
('BHD', 'Bahraini Dinar'),
('JOD', 'Jordanian Dinar'),
('ILS', 'Israeli Shekel'),
('EGP', 'Egyptian Pound'),
('LKR', 'Sri Lankan Rupee'),
('PKR', 'Pakistani Rupee'),
('BDT', 'Bangladeshi Taka'),
('NPR', 'Nepalese Rupee'),
('MVR', 'Maldivian Rufiyaa'),
('MUR', 'Mauritian Rupee'),
('SCR', 'Seychellois Rupee'),
('KES', 'Kenyan Shilling'),
('UGX', 'Ugandan Shilling'),
('TZS', 'Tanzanian Shilling'),
('ZMW', 'Zambian Kwacha'),
('GHS', 'Ghanaian Cedi'),
('NGN', 'Nigerian Naira'),
('ZAR', 'South African Rand'),
('MAD', 'Moroccan Dirham'),
('DZD', 'Algerian Dinar'),
('TND', 'Tunisian Dinar'),
('LYD', 'Libyan Dinar');




/*******************************************************************\
|                                                                   |
|   Create exchange rate table, which holds the Indirect_Quote      |
|   for each currency pair.                                         |
|                                                                   |                                      
|   This means that value in the "Source" or currency can           |
|   be MULTIPLIED by the exchange rate to get the value in the      |
|   "Target" currency                                               |
|
\******************************************************************/



Create Table Mgmt.Exchange_Rates
(Exchange_Rate_ID        INTEGER NOT NULL GENERATED BY DEFAULT AS IDENTITY,
Source_Currency_Code      VARCHAR(3) NOT NULL,  -- no default, should always be specified
Target_Currency_Code      VARCHAR(3) NOT NULL,  -- no default, should always be specified
Indirect_Quote            NUMERIC(20,10) NOT NULL,
Is_Current              BOOLEAN NOT NULL            DEFAULT TRUE,
Created_By_User_ID		BIGINT NOT NULL 			DEFAULT 1,
Replaced_By_User_ID		BIGINT NOT NULL 			DEFAULT 1,
Valid_From		   		TIMESTAMP NOT NULL		    DEFAULT NOW(),
Valid_To		  		TIMESTAMP NOT NULL			DEFAULT  '9999-12-31 23:59:59',
Is_Skeleton		  		BOOLEAN						DEFAULT  FALSE, -- defaulted to false to simplify buil insert
DB_Created_Date     	TIMESTAMP  NULL    			DEFAULT  NOW(),
DB_Created_By        	VARCHAR(255)  NULL			DEFAULT  'MISSING',
DB_Is_Deleted         	BOOLEAN  NULL 				DEFAULT  FALSE,
DB_Last_Updated_Date   	TIMESTAMP  NULL 			DEFAULT  NOW(),
DB_Last_Updated_By   	VARCHAR(255)  NULL 			DEFAULT  'MISSING',
Constraint "Exchange_Rate_ID" PRIMARY KEY (Exchange_Rate_ID)
);  



ALTER TABLE Mgmt.Exchange_Rates ADD CONSTRAINT FK_Exchange_Rate__Users
  FOREIGN KEY (Created_By_User_ID) REFERENCES Mgmt.App_User (App_User_ID);

ALTER TABLE Mgmt.Exchange_Rates ADD CONSTRAINT FK_Exchange_Rate__Users2
  FOREIGN KEY (Replaced_By_User_ID	) REFERENCES Mgmt.App_User (App_User_ID);



ALTER TABLE Mgmt.Exchange_Rates ADD CONSTRAINT FK_Exchange_Rate__Currency
  FOREIGN KEY (Source_Currency_Code ) REFERENCES Mgmt.Currency (ISO_Currency_Code);

ALTER TABLE Mgmt.Exchange_Rates ADD CONSTRAINT FK_Exchange_Rate__Currency2
  FOREIGN KEY (Target_Currency_Code) REFERENCES Mgmt.Currency (ISO_Currency_Code);  

-- Create the skeleton record
Insert Into Mgmt.Exchange_Rates (Source_Currency_Code, Target_Currency_Code, Indirect_Quote,    Is_Skeleton)
Values
('XXX','XXX', '1.00', TRUE);


/* Role Model */



CREATE TABLE Mgmt.Roles
(
  Role_ID integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Role_Description varchar(2000) DEFAULT 'MISSING' NOT NULL,
  Role_Permissions varchar(2000) DEFAULT 'None' NOT NULL,
  Created_By_User_ID bigint DEFAULT 1 NOT NULL,
  Created_Date timestamp DEFAULT NOW() NOT NULL,
  Is_Current boolean DEFAULT TRUE NOT NULL,
  Updated_by_User_ID bigint DEFAULT 1 NOT NULL,
  Updated_Date timestamp DEFAULT '9999-12-31 23:59:59' NOT NULL,
  Is_Skeleton boolean DEFAULT FALSE NOT NULL,
  DB_Created_Date     	TIMESTAMP  NULL    			DEFAULT  NOW(),
  DB_Created_By        	VARCHAR(255)  NULL			DEFAULT  'MISSING',
  DB_Is_Deleted         	BOOLEAN  NULL 					DEFAULT  FALSE,
  DB_Last_Updated_Date   	TIMESTAMP  NULL 				DEFAULT  NOW(),
  DB_Last_Updated_By   	VARCHAR(255)  NULL 			DEFAULT  'MISSING',
  Constraint "Role_ID" PRIMARY KEY (Role_ID)
);


Insert into Mgmt.Roles (Role_Description, Role_Permissions, Created_By_User_ID, Is_Skeleton)
Values ('Default Role', 'None', 1, True);



CREATE TABLE Mgmt.User_Permissions
(
  Company_Users_ID bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Organisation_ID integer DEFAULT 1 NOT NULL,
  App_User_ID bigint DEFAULT 1 NOT NULL,
  Role_ID integer DEFAULT 1 NOT NULL
);


COMMENT ON TABLE Mgmt.User_Permissions IS E'A user can have more than one role, in more than one companies';

ALTER TABLE Mgmt.User_Permissions ADD CONSTRAINT Company_Users_ID
  PRIMARY KEY (Company_Users_ID);



ALTER TABLE Mgmt.User_Permissions ADD CONSTRAINT FK_User_Permissions__Roles
  FOREIGN KEY (Role_ID) REFERENCES Mgmt.Roles (Role_ID);

ALTER TABLE Mgmt.User_Permissions ADD CONSTRAINT FK_User_Permissions__Organisation
  FOREIGN KEY (Organisation_ID) REFERENCES Mgmt.Organisation (Organisation_ID);

ALTER TABLE Mgmt.User_Permissions ADD CONSTRAINT FK_User_Permissions__Users
  FOREIGN KEY (App_User_ID) REFERENCES Mgmt.App_User (App_User_ID);



/* Physical S2T Model */

CREATE TABLE Mgmt.Connection_Type
(
  Conn_Type_ID integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Connection_Type varchar(255),
  Driver varchar(255),
  Is_Supported boolean DEFAULT True NOT NULL
)
;

COMMENT ON TABLE Mgmt.Connection_Type IS E'List of Connection types supported - e.g. OCBD, JDBC, FTP, Fileshare\n\nThis is abstracted from Source Type to allow multiple different connection types to the same source platform - e.g. PostgresDB, which may vary depending on whether the target is local, cloud/RDS. \n\nThis will go to LOOKUP table. \n'
;

ALTER TABLE Mgmt.Connection_Type ADD CONSTRAINT Conn_Type_ID
  PRIMARY KEY (Conn_Type_ID);



CREATE TABLE Mgmt.Source_Type
(
  Source_Type_ID bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Source_Type_Short varchar(20) DEFAULT 'MISSING' NOT NULL,
  Source_Type varchar(768) DEFAULT 'MISSING' NOT NULL,
  Source_Version varchar(255) DEFAULT 'MISSING',
  Is_Supported boolean DEFAULT False,
  Conn_Type_ID integer,
  File_Type_ID bigint
)
;


COMMENT ON COLUMN Mgmt.Source_Type.Source_Version IS E'Version of the application - e.g. SQL Server 2016/2019/2022 or Postgres V15, V16 etc. \n\nFor excel files, indicate the file type - e.g. xls, xlsx, xlsm. \n';
COMMENT ON COLUMN Mgmt.Source_Type.Is_Supported IS E'Is this source type currently supported by this application. ';
COMMENT ON COLUMN Mgmt.Source_Type.File_Type_ID IS E'Nullable - only populate for files';

ALTER TABLE Mgmt.Source_Type ADD CONSTRAINT Source_Type_ID
  PRIMARY KEY (Source_Type_ID)
;

CREATE TABLE Mgmt.Compression_Algorithm
(
  Comp_Algo_ID integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Compression_Name varchar(20),
  Compression_Description varchar(200)
)
;

ALTER TABLE Mgmt.Compression_Algorithm ADD CONSTRAINT Comp_Algo_ID
  PRIMARY KEY (Comp_Algo_ID)
;


CREATE TABLE Mgmt.Data_Sources
(
  Data_Source_ID bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Source_Type_ID bigint NOT NULL,
  Source_URI varchar(2000) DEFAULT 'MISSING' NOT NULL,
  Source_Description varchar(2000) DEFAULT 'MISSING' NOT NULL,
  Env_ID integer DEFAULT 1 NOT NULL,
  Source_Is_File boolean DEFAULT True NOT NULL,
  File_Type varchar(20) DEFAULT 'MISSING',
  Line_Ending varchar(10),
  Field_Delimmiter char(10),
  Quote_Character varchar(10),
  Escape_Character varchar(10),
  Comp_Algo_ID integer,
  Rows_Skip integer DEFAULT 0
);





COMMENT ON TABLE Mgmt.Data_Sources IS E'Holds specifics of each source.\n  \nNote that separation of Source_Type and Source allows for multiple instances of the same source type - e.g. multiple databases and/or servers. \n\nDatabase connections should be captured at the DATABASE level, including the server name, rather than server level. \n'
;


COMMENT ON COLUMN Mgmt.Data_Sources.Source_URI IS E'URI for source, e.g. \n\n* HTTPS address\n* Server + Database Name\n';
COMMENT ON COLUMN Mgmt.Data_Sources.Source_Description IS E'Description of source - e.g. Premium data from UAT';
COMMENT ON COLUMN Mgmt.Data_Sources.File_Type IS E'File extension\nShould not be null when Source_Is_File is true. ';
COMMENT ON COLUMN Mgmt.Data_Sources.Line_Ending IS E'How is a line ended? e.g. \nLF\nCR/LF\nThis could have values restricted \n';
COMMENT ON COLUMN Mgmt.Data_Sources.Comp_Algo_ID IS E'Nullable';


ALTER TABLE Mgmt.Data_Sources ADD CONSTRAINT Data_Source_ID
  PRIMARY KEY (Data_Source_ID);





CREATE TABLE Mgmt.Data_Object
(
  Data_Object_ID bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Data_Object_Name varchar(768) DEFAULT 'MISSING',
  Data_Object_Description bigint,
  Source_ID bigint DEFAULT 1 NOT NULL,
  Created_By_ID bigint DEFAULT 1 NOT NULL,
  Object_Created_Date date DEFAULT NOW() NOT NULL
)
;

COMMENT ON TABLE Mgmt.Data_Object IS E'Details of the specific object being referenced - e.g. a Table Name in a database, tab name in Excel';
COMMENT ON COLUMN Mgmt.Data_Object.Created_By_ID IS E'User who created this Object Version';


ALTER TABLE Mgmt.Data_Object ADD CONSTRAINT Object_ID
  PRIMARY KEY (Data_Object_ID);



CREATE TABLE Mgmt.Source_Fields
(
  Field_ID bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Field_Name varchar(256) NOT NULL,
  Field_Description varchar(2000) DEFAULT 'MISSING' NOT NULL,
  Attribute_ID bigint DEFAULT 1 NOT NULL,
  Data_Object_ID bigint DEFAULT 1 NOT NULL,
  Created_By_ID bigint DEFAULT 1 NOT NULL,
  Addtl_Att_IDs bigint
)
;

COMMENT ON TABLE Mgmt.Source_Fields IS E'Individual PHYSICAL fields/columns related to object versions. \nBridge Table\n\nAlso allows referencing to Logical Attributes. \nShould be expanded to capture history of description & attribute tags in the physical model. \n';
COMMENT ON COLUMN Mgmt.Source_Fields.Field_Name IS E'256 character limit as default - exceeds most paltforms: \n\nPostgresql: 63 \nSQL Server 2022: 128';
COMMENT ON COLUMN Mgmt.Source_Fields.Addtl_Att_IDs IS E'Holds second or additional glossary attributes as needed. ';


ALTER TABLE Mgmt.Source_Fields ADD CONSTRAINT Field_ID
  PRIMARY KEY (Field_ID);

ALTER TABLE Mgmt.Source_Fields ADD CONSTRAINT FK_Source_Fields__Data_Object
  FOREIGN KEY (Data_Object_ID) REFERENCES Mgmt.Data_Object (Data_Object_ID);



CREATE TABLE Mgmt.Object_Version
(
  Object_Version_ID bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Object_ID bigint DEFAULT 1 NOT NULL,
  Version_Description varchar(2000) DEFAULT 'MISSING' NOT NULL,
  Version_ID bigint DEFAULT 1 NOT NULL,
  Version_Created_By_ID bigint DEFAULT 1 NOT NULL,
  Version_Created_Date date DEFAULT NOW() NOT NULL,
  Is_Current_Version boolean  DEFAULT True NOT NULL
)
;


COMMENT ON COLUMN Mgmt.Object_Version.Version_ID IS E'Increments by 1 for each new object version.';

ALTER TABLE Mgmt.Object_Version ADD CONSTRAINT Object_Ver_ID
  PRIMARY KEY (Object_Version_ID);







CREATE TABLE Mgmt.Object_Schema
(
  Obj_Schema_ID bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Object_Version_ID bigint DEFAULT 1 NOT NULL,
  Field_ID bigint DEFAULT 1 NOT NULL
);

COMMENT ON TABLE Mgmt.Object_Schema IS E'Object Schema is the bridge between Object and fields, creating a new set of rows for each version of the object with 1 row per field per object version per field.\n\n  This bridge table only uses surrogate keys, and all fields sit on the Primary Index\n\n\n'
;

ALTER TABLE Mgmt.Object_Schema ADD CONSTRAINT Obj_Schema_ID
  PRIMARY KEY (Obj_Schema_ID);


ALTER TABLE Mgmt.Object_Schema ADD CONSTRAINT FK_Object_Schema__Object_Version
  FOREIGN KEY (Object_Version_ID) REFERENCES Mgmt.Object_Version (Object_Version_ID);





CREATE TABLE Mgmt.Dataset
(
  Dataset_ID bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Source_Object_Version_ID bigint DEFAULT 1 NOT NULL,
  Target_Object_Version_ID bigint DEFAULT 1 NOT NULL,
  Dataset_Created_Date timestamp DEFAULT NOW() NOT NULL,
  Dataset_Created_By_ID bigint DEFAULT 1 NOT NULL,
   Is_Deleted boolean DEFAULT False NOT NULL,
  Dataset_Deleted_Date timestamp  NULL,
  Dataset_Deleted_By_ID bigint NULL 
)
;

COMMENT ON TABLE Mgmt.Dataset IS E'A dataset is created for each instance of reading a datasource. \n\nEach datasset supports a Source_Object_Version and a Target-Object_Version to identify the schemata used. A target does not need to be specified - it will inherit MISSING record if not specified to allow previewing and then choosing a target. \n\nDataset records can be logically deleted at application and database level, separately. Either delete will suppress the data from View \n';

ALTER TABLE Mgmt.Dataset ADD CONSTRAINT FK_Object_Version__Created_By
  FOREIGN KEY (Dataset_Created_By_ID) REFERENCES Mgmt.App_User (App_User_ID);

ALTER TABLE Mgmt.Dataset ADD CONSTRAINT Dataset_ID
  PRIMARY KEY (Dataset_ID);

ALTER TABLE Mgmt.Dataset ADD CONSTRAINT FK_Dataset__Tgt_Object_Version
  FOREIGN KEY (Target_Object_Version_ID) REFERENCES Mgmt.Object_Version (Object_Version_ID);

ALTER TABLE Mgmt.Dataset ADD CONSTRAINT FK_Dataset__Src_Object_Version
  FOREIGN KEY (Target_Object_Version_ID) REFERENCES Mgmt.Object_Version (Object_Version_ID);





/* Business Data Catalog */
CREATE TABLE Mgmt.Domain
(
  Domain_ID integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Domain_Name varchar(200) DEFAULT 'MISSING' NOT NULL,
  Domain_Description varchar(2000) DEFAULT 'MISSING' NOT NULL,
  Created_By_ID bigint DEFAULT 1 NOT NULL,
  Owned_By_ID bigint DEFAULT 1 NOT NULL,
  Created_Date date DEFAULT NOW() NOT NULL
);

ALTER TABLE Mgmt.Domain ADD CONSTRAINT Domain_ID
  PRIMARY KEY (Domain_ID);


CREATE TABLE Mgmt.Entities
(
  Entity_ID bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Entity_Name varchar(255) NOT NULL,
  Entity_Description varchar(2000),
  Created_By_ID bigint DEFAULT 1 NOT NULL,
  Created_Date date DEFAULT NOW(),
  Domain_ID integer NOT NULL
);


COMMENT ON TABLE Mgmt.Entities IS E'Entities holds LOGICAL data entities - i.e. tied to business glossaries, not systems. ';

ALTER TABLE Mgmt.Entities ADD CONSTRAINT Entity_Id
  PRIMARY KEY (Entity_ID);

CREATE TABLE Mgmt.Attributes
(
  Attribute_ID bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY,
  Attribute_Name varchar(256) DEFAULT 'MISSING',
  Attribute_Description varchar(2000),
  Created_By_ID bigint DEFAULT 1 NOT NULL,
  Created_Date date DEFAULT NOW(),
  URI varchar(2000) DEFAULT 'MISSING',
  Entity_ID bigint DEFAULT 1 NOT NULL
)
;


COMMENT ON TABLE Mgmt.Attributes IS E'Captures LOGICAL attributes under logical entities.\nAttributes should be aligned to business glossary rather than source system field/column names. \n'
;
COMMENT ON COLUMN Mgmt.Attributes.URI IS E'External URI for futher information / source of definition';


ALTER TABLE Mgmt.Attributes ADD CONSTRAINT Att_ID
  PRIMARY KEY (Attribute_ID);


ALTER TABLE Mgmt.Attributes ADD CONSTRAINT FK_Attributes__Entities
  FOREIGN KEY (Entity_ID) REFERENCES Mgmt.Entities (Entity_ID);

ALTER TABLE Mgmt.Attributes ADD CONSTRAINT FK_Attributes__Users
  FOREIGN KEY (Created_By_ID) REFERENCES Mgmt.App_User (App_User_ID);




