SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[PW_DeleteErrorLog] @RetentionDays int = 60  
  
AS  
  
set nocount on   
  
/**************************************************************************************************************  
* Author: Craig Bellissimo  
* Date: 2/7/2012  
*  
* Purpose: This procedure will delete the ErrorLog table 10000 rows until no records remain.  
*   
**************************************************************************************************************/  
  
DECLARE @rows INT;  
SET @rows = 1  
WHILE ( @rows > 0 )  
 BEGIN  
  
  DELETE TOP (10000) ErrorLog  
  where datediff(dd,[date] ,getdate()) > @RetentionDays  
  
  SET @rows = @@rowcount  
  WAITFOR DELAY '00:00:00:100';  
  
 END

GO
