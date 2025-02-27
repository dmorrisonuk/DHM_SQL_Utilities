INSERT INTO mgmt.lookups(
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