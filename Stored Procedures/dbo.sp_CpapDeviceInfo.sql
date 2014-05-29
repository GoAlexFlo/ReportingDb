SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[sp_CpapDeviceInfo] 
	@SourceDbName   Varchar(25),
	@WhereCondition Varchar(500),
	@WhereConditionYear Varchar(4)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(3000)

Set @Sql =
	   'BEGIN
			With Info As
		( 
			SELECT Distinct p.PersonId
			FROM ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
			WHERE ' + @WhereCondition + '  
		)
			Select i.PersonId, Popular.MostPopularDevice,  Number.TotalUploads, Number.NumberOfDevices
			From Info As i Inner Join 
				(Select PersonId, DeviceModel As MostPopularDevice 
				 From 
					(
						 Select COUNT(*) as ct, personid, DeviceMake, DeviceModel, ROW_NUMBER() OVER(PARTITION By PersonId ORDER BY COUNT(*) DESC) As "RowNumber"
						 From ' + @SourceDbName + '..UploadedFile
						 Where YEAR(DateUploaded)>=' + @WhereConditionYear + '
						 Group By PersonId, DeviceMake, DeviceModel
					) As b
			Group By ct, personid, DeviceMake, DeviceModel, RowNumber
			Having RowNumber = 1) As Popular On Popular.PersonId = i.PersonId
			left Outer Join 
				(
					Select PersonId, COUNT(*) TotalUploads, COUNT(Distinct DeviceModel) as NumberOfDevices
					From ' + @SourceDbName + '..UploadedFile
					Where YEAR(DateUploaded)>=' + @WhereConditionYear + '
					Group By PersonId
		) As Number On Number.PersonId = i.PersonId
		END'
		
		EXEC(@Sql)
		
END





GO
