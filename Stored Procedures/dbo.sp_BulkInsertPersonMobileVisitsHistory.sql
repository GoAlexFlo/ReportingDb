SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_BulkInsertPersonMobileVisitsHistory] 
@profileId Int
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @MakeItFail float;
	--DECLARE @profileId Int;
	DECLARE @dateAdded datetime;
	DECLARE @csvFileName varchar(100);
	DECLARE @sqlString varchar(1000);
	DECLARE @ROWSUPDATED int ; 

	--DROP TABLE #PersonVisitsHistoryTemp
	CREATE TABLE #PersonVisitsHistoryTemp(
				[UserHash] [varchar](50) NULL,
				[UserType] [varchar](50) NULL,
				[GaDate] [varchar](10) NULL,
				[GaHour] [varchar](2) NULL,
				[GaMinute] [varchar](2) NULL,
				[DeviceCategory] [varchar](100) NULL,
				[DeviceInfo] [varchar](100) NULL,
				[SessionCount] [varchar](5) NULL,
				[TotalSessionCount] [varchar](12) NULL,
				[DateAdded] [datetime] NULL,
				[GoogleAnalyticsFileName] [varchar](50) NULL)
				
    IF IsNull((SELECT COUNT(*) FROM dbo.GoogleAnalyticsProcessedCSV WHERE ProcessedDate Is Null And ProfileId=@profileId),0)=0
	   BEGIN
	   --Notify DB Admin that job failed 
	     RaisError ('Error occurred while processing Google Analytics data.  Nothing to insert.  Check this process.', 15, 10)
	     RETURN
	   END
    
    Select Top 1 @csvFileName= '''' + CsvFilePath + CsvFileName +'''', @dateAdded=DateAdded
    From dbo.GoogleAnalyticsProcessedCSV
    Where ProcessedDate Is Null And ProfileId=@profileId
    Order By GoogleAnalyticsProcessedCSVId Desc
    
    Set @sqlString ='BULK
	                 INSERT #PersonVisitsHistoryTemp
	                 FROM ' + @csvFileName + '   
	                 WITH
					 (
					 FIELDTERMINATOR = '','',
					 ROWTERMINATOR = ''\n''
					 )'
	EXEC(@sqlString)
	
	--DROP TABLE #IsDataSampleTemp
	CREATE TABLE #IsDataSampleTemp(
				[SessionDate] date NULL,
				[SessionCount] int NULL,
				[UnSampledSessionCount] int NULL,
				[IsSampleData] [bit] NULL)
				
	 INSERT INTO #IsDataSampleTemp
           ([SessionDate]
           ,[SessionCount]
           ,[UnSampledSessionCount]
           ,[IsSampleData])
	 Select GaDate, 
	        SUM(Convert(Int,SessionCount)),
	        MAX(Convert(Int,TotalSessionCount)),
	        Case When SUM(Convert(Int,SessionCount)) = MAX(Convert(Int,TotalSessionCount)) Then 0 Else 1 End
	 From #PersonVisitsHistoryTemp As pt
	 Group By GaDate
	 
	 IF  IsNull((SELECT COUNT(*) FROM #PersonVisitsHistoryTemp),0)=0 Or IsNull((SELECT COUNT(*) FROM #IsDataSampleTemp),0)=0
	   BEGIN
	   --Notify DB Admin that job failed 
	     RaisError ('Error occurred while inserting Google Analytics data.  There was no data to insert.  This is highly unlikely.', 15, 10)
	     RETURN
	   END
	 
	 INSERT INTO [dbo].[PersonVisitsHistory]
           ([PersonId]
           ,[GaProfileId]
           ,[MarketingPreferenceSharedKey]
           ,[UserType]
           ,[VisitDate]
           ,[DeviceType]
           ,[DeviceInfo]
           ,[NumberOfVisits]
           ,[IsSampleData]
           ,[DateAdded])
     Select
           p.PersonId,
           @ProfileId,
           pt.UserHash,
           Case 
              When pt.UserType='Premium Athlete Paid By Coach' 
              Then 1
              When pt.UserType='Paid Coach'
              Then 2
              When pt.UserType='Premium Athlete'
              Then 4
              When pt.UserType='Demo Coach'
              Then 5
              When pt.UserType='Basic Athlete'
              Then 6
              Else NULL 
           End As UserType, 
           pt.GaDate,
           pt.DeviceCategory,
           pt.DeviceInfo,
           Count(Distinct GaHour) As VisitCount,
           i.IsSampleData,
           pt.DateAdded
     From #PersonVisitsHistoryTemp As pt Inner Join Ultrafit_live..Person As p On pt.UserHash=p.MarketingPreferenceSharedKey
										 Inner Join #IsDataSampleTemp As i On pt.GaDate=i.SessionDate
                                         Left Outer Join dbo.PersonVisitsHistory As ph On pt.UserHash = ph.MarketingPreferenceSharedKey 
                                                                                          And pt.GaDate=ph.VisitDate 
                                                                                          And pt.DeviceInfo=ph.DeviceInfo 
                                                                                          And ph.GaProfileId=@profileId
     Where ph.MarketingPreferenceSharedKey Is Null 
     Group By p.PersonId,
			  pt.UserHash,
			   Case 
				  When pt.UserType='Premium Athlete Paid By Coach' 
				  Then 1
				  When pt.UserType='Paid Coach'
				  Then 2
				  When pt.UserType='Premium Athlete'
				  Then 4
				  When pt.UserType='Demo Coach'
				  Then 5
				  When pt.UserType='Basic Athlete'
				  Then 6
				  Else NULL End,
			   pt.GaDate,
			   pt.DeviceCategory,
			   pt.DeviceInfo,
			   i.IsSampleData,
			   pt.DateAdded
			   
--End of Job -- Stamp GoogleAnalyticsProcessCSV with current date and times stamp.  This will indicate that the Google Analytics for ProfileId and date range has been processes.
BEGIN TRY
		Update dbo.GoogleAnalyticsProcessedCSV 
		Set ProcessedDate= GETDATE() 
		Where ProfileId=@profileId And DateAdded=@dateAdded;
		SET @ROWSUPDATED = @@ROWCOUNT;
	END TRY
			BEGIN CATCH 
			--Notify DB Admin that job failed  
				RaisError ('Error occurred while updating GoogleAnalyticsProcessedCSV with processed date.', 15, 10)
				RETURN
  			END CATCH
  	IF (@ROWSUPDATED = 0)
		BEGIN
			--Notify DB Admin that job failed  
	        RaisError ('GoogleAnalyticsProcessedCSV row was not updated!!!  Check execution for processing error.', 15, 10)
	        RETURN
  		END

END

--select distinct userhash,usertype, DeviceCategory,GaDate,GaHour,DeviceInfo from #PersonVisitsHistoryTemp
--select * from #PersonVisitsHistoryTemp

--select CONVERT(varchar(7), visitDate,111) dte, gaProfileId, SUM(NumberOfVisits) 
--from PersonVisitsHistory 
--where CONVERT(varchar(7), visitDate,111)='2013/12' 
--group by CONVERT(varchar(7), visitDate,111), gaProfileId


GO
