
/*******************************************************************\
|                                                                   |   
|   Create currency table                                           |              
|   Populate with ISO Currency list                                 |                         
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
    Is_Available          BOOLEAN NOT NULL DEFAULT TRUE,
    Is_Current              BOOLEAN NOT NULL DEFAULT TRUE,
    Created_By_User_ID		BIGINT NOT NULL 			DEFAULT 1,
    Replaced_By_User_ID		BIGINT NOT NULL 			DEFAULT 1,
	  Valid_From		   		  TIMESTAMP NOT NULL		    DEFAULT NOW(),
	  Valid_To		  		    TIMESTAMP NOT NULL			DEFAULT  '9999-12-31 23:59:59',
    Is_Skeleton		  		  BOOLEAN						DEFAULT  FALSE, -- defaulted to false to simplify buil insert
  DB_Created_Date     	TIMESTAMP WITH TIME ZONE  NULL  DEFAULT  NOW(),
  DB_Created_By        	VARCHAR(255)              NULL	DEFAULT  Current_User,
  DB_Is_Deleted         BOOLEAN                   NULL 	DEFAULT  FALSE,
  DB_Last_Updated_Date  TIMESTAMP WITH TIME ZONE  NULL 	DEFAULT  NOW(),
  DB_Last_Updated_By   	VARCHAR(255)              NULL 	DEFAULT  Current_User,
    Constraint "Currency_ID" PRIMARY KEY (Currency_ID)
);


COMMENT ON COLUMN Mgmt.Currency.Internal_Currency_Code IS E'Used where the ISO code has been replaced for internal use.';
COMMENT ON COLUMN Mgmt.Currency.Is_Available            IS E'Is_current shows whether this is the current record for this currency.';
COMMENT ON COLUMN Mgmt.Currency.Is_Available            IS E'Is_available allows pre-seeded lists to be suppressed in the application layer.';

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
AND         Is_Available = TRUE
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
DB_Created_Date     	TIMESTAMP WITH TIME ZONE  NULL  DEFAULT  NOW(),
DB_Created_By        	VARCHAR(255)              NULL	DEFAULT  Current_User,
DB_Is_Deleted         BOOLEAN                   NULL 	DEFAULT  FALSE,
DB_Last_Updated_Date  TIMESTAMP WITH TIME ZONE  NULL 	DEFAULT  NOW(),
DB_Last_Updated_By   	VARCHAR(255)              NULL 	DEFAULT  Current_User,
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

