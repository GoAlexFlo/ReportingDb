SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_split] (@sText varchar(8000), @sDelim varchar(20) = ' ')
RETURNS TABLE
AS
RETURN
SELECT ListItem
        FROM (
            SELECT    @sText TheCSV
        ) theData
        cross apply (select TagsList='<x>'+replace(TheCSV,@sDelim,'</x><x>')+'</x>')    EncodeAsXML
        cross apply (select XmlList=cast(TagsList as xml))                                CastAsXml
        cross apply XmlList.nodes('x')                                                    ParseNodes(XmlNode)
        cross apply (select ListItem=XmlNode.value('.','varchar(max)'))                    ExtractValues
GO
