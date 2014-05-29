SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CpapPremAthleteInfo] 
	@SourceDbName Varchar(25),
	@WhereConditionYear Varchar(4)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(2000)
DECLARE @Delimiter Varchar(10)
DECLARE @TagsListParm1 Varchar(10)
DECLARE @TagsListParm2 Varchar(10)
DECLARE @TagsListParm3 Varchar(10)
DECLARE @XmlListParm1 Varchar(10)
DECLARE @XmlNodeParm1 Varchar(10)
DECLARE @XmlNodeParm2 Varchar(15)

SET @TagsListParm1 = ''''+ '<x>' + ''''
SET @TagsListParm2 = '''' + '</x><x>' + ''''
SET @TagsListParm3 = '''' + '</x>' + ''''
SET @Delimiter = '''' + ',' + ''''
SET @XmlListParm1 = '''' + 'x' + ''''
SET @XmlNodeParm1 = '''' + '.' + ''''
SET @XmlNodeParm2 = '''' + 'varchar(max)' + ''''

-- Note leave the Distincts in place. Otherwise the counts will be incorect  
Set @Sql = 
	   'BEGIN
			With Info As
			(
				Select Distinct PersonIdList As PersonId, YearMonthCoached, YearMonthDayCoached
					From (
						Select Distinct i.client_ids PersonIds, Convert(VARCHAR(7),thedate,111) As YearMonthCoached, Convert(DateTime,Convert(VARCHAR(7),thedate,111)+''/01'') As YearMonthDayCoached   
						From ' + @SourceDbName + '..client_count As i
						Where YEAR(thedate)>= ' + @WhereConditionYear + ' --And DatePart(DAY,thedate) In (1, 7, 14, 21)  *** Removed as per Bill. This part of the where statement dropped legitimate PersonId that did not fall on 1,7,14,21.
					) theData
					cross apply (select TagsList='+ @TagsListParm1 + '+replace(PersonIds,' + @Delimiter + ',' + @TagsListParm2 + ')+' + @TagsListParm3 + ') EncodeAsXML
					cross apply (select XmlList=cast(TagsList as xml))                                                                                      CastAsXml
					cross apply XmlList.nodes(' + @XmlListParm1 + ')                                                                                        ParseNodes(XmlNode)
					cross apply (select PersonIdList=XmlNode.value(' + @XmlNodeParm1 + ',' + @XmlNodeParm2 + '))                                            ExtractValues
			), PrepInfo As
			(
			   Select i.PersonId, Count(i.YearMonthCoached) As MonthsCoached, MAX(YearMonthDayCoached) As DateLastCoached
			   From Info As i
			   Group by PersonId
			)
			
				Select PersonId, MonthsCoached,
				ISNULL((SELECT COUNT(MonthName) 
							  FROM
						  	  (
								SELECT  DATENAME(MONTH, DATEADD(MONTH, x.number, DateLastCoached)) AS MonthName
								FROM    master.dbo.spt_values x
								WHERE   x.type = ''P'' AND x.number <= DATEDIFF(MONTH, DateLastCoached, GETDATE())
							  ) As d) ,1) As MonthsSinceUserType1
				 
				From PrepInfo  
		END'
	EXEC(@Sql)
END


GO
