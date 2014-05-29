SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CpapEquipmentInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereCondition Varchar(500),
	@WhereConditionYear Varchar(4)
	
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(2000)

Set @Sql =
	   'BEGIN
			With Info As
			( 
				SELECT Distinct p.PersonId
				FROM ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
				WHERE ' + @WhereCondition + '  
			), PrepInfo As
				(
					Select i.PersonId, 1 As EquipmentBikeCount, 0 AS EquipmentShoeCount 
					From Info AS i Inner Join ' + @SourceDbName + '..EquipmentBike As e On i.PersonId=e.PersonId
				--	Where YEAR(DateOfPurchase)>=' + @WhereConditionYear + ' -- Removed because DateOfPurchase is not a required column 
					
					Union All
					Select i.PersonId, 0 As EquipmentBikeCount, 1 AS EquipmentShoeCount 
					From Info AS i Inner Join ' + @SourceDbName + '..EquipmentShoe As e On i.PersonId=e.PersonId
				--	Where YEAR(DateOfPurchase)>=' + @WhereConditionYear + ' -- Removed because DateOfPurchase is not a required column 
				)
				Select PersonId, Sum(EquipmentBikeCount)As EquipmentBikeCount, Sum(EquipmentShoeCount) As EquipmentShoeCount
				From PrepInfo
				Group by PersonId
		END'
		EXEC(@Sql)
END
GO
