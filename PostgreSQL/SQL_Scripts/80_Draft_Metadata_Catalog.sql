
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

-- Insert Skeleton Role 
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
  Is_Supported boolean DEFAULT True NOT NULL,
  DB_Created_Date TIMESTAMP NULL DEFAULT NOW(),
  DB_Created_By VARCHAR(255) NULL DEFAULT 'MISSING',
  DB_Is_Deleted BOOLEAN NULL DEFAULT FALSE,
  DB_Last_Updated_Date TIMESTAMP NULL DEFAULT NOW(),
  DB_Last_Updated_By VARCHAR(255) NULL DEFAULT 'MISSING',
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
  Is_Supported  boolean DEFAULT False,
  Is_Skeleton   boolean DEFAULT False,
  Conn_Type_ID  integer,
  File_Type_ID  bigint,
  DB_Created_Date TIMESTAMP NULL DEFAULT NOW(),
  DB_Created_By VARCHAR(255) NULL DEFAULT 'MISSING',
  DB_Is_Deleted BOOLEAN NULL DEFAULT FALSE,
  DB_Last_Updated_Date TIMESTAMP NULL DEFAULT NOW(),
  DB_Last_Updated_By VARCHAR(255) NULL DEFAULT 'MISSING',
)
;

-- Insert Skeleton Source_Type
INSERT INTO Mgmt.Source_Type (Source_Type_Short, Source_Type, Is_Skeleton)
VALUES ('Default', 'Default Source Type', True);


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




