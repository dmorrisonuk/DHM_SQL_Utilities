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
);