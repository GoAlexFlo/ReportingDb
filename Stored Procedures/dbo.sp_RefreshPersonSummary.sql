SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_RefreshPersonSummary]
AS
BEGIN
	SET NOCOUNT ON;

		Delete PersonSummary;
		
------ Create a Temp table --- stuff many rows into one column
		CREATE TABLE #ManyRowsIntoOneColumn
		  (PersonId int, 
		   CouponCodeUsed varchar(max), 
		   CouponCodePrice varchar(max), 
		   AtpSeasongoals varchar(max), 
		   AtpObjectives varchar(max), 
		   AnnualHours varchar(max),
		   EquipmentBikeBrand varchar(max),
		   EquipmentBikeModel varchar(max),
		   EquipmentBikeDateofPurchase varchar(max),
		   EquipmentShoeBrand varchar(max),
		   EquipmentShoeModel varchar(max),
		   EquipmentShoeDateofPurchase varchar(max),
		   ThresholdHeartRate varchar(max),
		   LimiterEndurance varchar(max), 
		   LimiterForce varchar(max),
		   LimiterSpeedSkill varchar(max),
		   LimiterMuscularEndurance varchar(max),
		   LimiterAnaerobicEndurance varchar(max),   
		   LimiterPower varchar(max),   
		   UserTypePrevious varchar(max),
		   ThresholdPower varchar(max)); 
		
		With StuffManyIntoOne As
		(
			SELECT  t1.Personid, 
			        STUFF((SELECT ', ' + Replace(Convert(varchar,CouponCodeType),',',' ') 
			        FROM CouponCodeUsed t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As CouponCodeUsed, null As CouponCodePrice, null As AtpSeasongoals, null As AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate, null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM CouponCodeUsed t1
			WHERE CouponCodeType Is Not Null or CouponCodeType <>' '
			GROUP BY t1.Personid

			Union All
			SELECT  t1.Personid, null CouponCodeUsed, 
			        STUFF((SELECT ', ' + Replace(Convert(varchar,Price),',',' ') 
			               FROM CouponCodeUsed t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As CouponCodePrice, null As AtpSeasongoals, null As AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate, null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM CouponCodeUsed t1
			WHERE Price Is Not Null or Price <>' '
			GROUP BY t1.Personid
			
			Union All
			SELECT t1.Personid, null As CouponCodeUsed, null As CouponCodePrice,
			  STUFF((SELECT ', ' + 'SeasonGoal for ' + [YEAR] + '    ' + Case When seasongoal1 Is Not Null And seasongoal1 <> ' '  
																		 Then 'SeasonGoal1:(' + Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(seasongoal1,N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),',',' ') + ')     ' Else '' End + 
																	Case When seasongoal2 Is Not Null And seasongoal2 <> ' ' 
																		 Then 'SeasonGoal2:(' + Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(seasongoal2,N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),',',' ') + ')     ' Else '' End + 
																	Case When seasongoal3 Is Not Null And seasongoal3 <> ' ' 
																		 Then 'SeasonGoal3:(' + Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(seasongoal3,N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),',',' ') + ')' Else '' End
									From Ultrafit.dbo.atp  t2
				WHERE t2.Personid = t1.Personid 
				FOR XML PATH (''))
			  ,1,2,'') AS AtpSeasongoals, null As AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate, null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM Ultrafit.dbo.atp t1
			Where (seasongoal1 Is Not Null And seasongoal1 <> ' ' or  seasongoal2 Is Not Null And seasongoal2 <> ' ' or seasongoal3 Is Not Null And seasongoal3 <> ' ')
			GROUP BY t1.Personid
			
			Union All
			  SELECT t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals,
			  STUFF((SELECT ', ' + 'Objective for ' + [YEAR] + '    ' + Case When Objective1 Is Not Null And Objective1 <> ' '  
																		 Then 'Objective1:(' + Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Objective1,N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),',',' ') + ')     ' Else '' End + 
																	Case When Objective2 Is Not Null And Objective2 <> ' ' 
																		 Then 'Objective2:(' + Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Objective2,N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),',',' ') + ')     ' Else '' End + 
																	Case When Objective3 Is Not Null And Objective3 <> ' ' 
																		 Then 'Objective3:(' + Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Objective3,N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),',',' ') + ')     ' Else '' End + 
																	Case When Objective4 Is Not Null And Objective4 <> ' ' 
																		 Then 'Objective4:(' + Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Objective4,N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),',',' ') + ')     ' Else '' End + 
																	Case When Objective5 Is Not Null And Objective5 <> ' ' 
																		 Then 'Objective5:(' + Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Objective5,N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),',',' ') + ')' Else '' End
									From Ultrafit.dbo.atp  t2
				WHERE t2.Personid = t1.Personid 
				FOR XML PATH (''))
			  ,1,2,'') AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate, null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM Ultrafit.dbo.atp t1
			Where (Objective1 Is Not Null And Objective1 <> ' ' or  Objective2 Is Not Null And Objective2 <> ' ' or Objective3 Is Not Null And Objective3 <> ' '  or  Objective4 Is Not Null And Objective4 <> ' ' or Objective5 Is Not Null And Objective5 <> ' ')
			GROUP BY t1.Personid

		Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives,
			STUFF((SELECT ', ' + Replace(Convert(varchar,annual_hours),',',' ') FROM Ultrafit.dbo.atp t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate, null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM Ultrafit.dbo.atp t1
			WHERE annual_hours Is Not Null or annual_hours <>' '
			GROUP BY t1.Personid
			
	    Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours,
	    	STUFF((SELECT ', ' + Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Brand,N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),',',' ')  
			       FROM Ultrafit.dbo.EquipmentBike t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate, null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM Ultrafit.dbo.EquipmentBike t1
			WHERE Brand Is Not Null Or Brand <>' '
			GROUP BY t1.Personid
		
		Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand,
	    	STUFF((SELECT ', ' + Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Model,N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),',',' ')  
			       FROM Ultrafit.dbo.EquipmentBike t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate, null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM Ultrafit.dbo.EquipmentBike t1
			WHERE Model Is Not Null Or Model <>' '
			GROUP BY t1.Personid

		Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null  As EquipmentBikeModel,
	    	STUFF((SELECT ', ' + Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(DateofPurchase,N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),',',' ')  
			       FROM Ultrafit.dbo.EquipmentBike t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate, null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM Ultrafit.dbo.EquipmentBike t1
			WHERE DateofPurchase Is Not Null Or DateofPurchase <>' '
			GROUP BY t1.Personid
			
		Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase,
	    	STUFF((SELECT ', ' + Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Brand,N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),',',' ')  
			       FROM Ultrafit.dbo.EquipmentShoe t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As EquipmentShoeBrand, null As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate, null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM Ultrafit.dbo.EquipmentShoe t1
			WHERE Brand Is Not Null Or Brand <>' '
			GROUP BY t1.Personid
		
		Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand,
	    	STUFF((SELECT ', ' + Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Model,N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),',',' ')  
			       FROM Ultrafit.dbo.EquipmentShoe t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate, null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM Ultrafit.dbo.EquipmentShoe t1
			WHERE Model Is Not Null Or Model <>' '
			GROUP BY t1.Personid

		Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null  As EquipmentShoeModel,
	    	STUFF((SELECT ', ' + Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(DateofPurchase,N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),N'',''),',',' ')  
			       FROM Ultrafit.dbo.EquipmentShoe t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As EquipmentShoeDateofPurchase, null As ThresholdHeartRate, null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM Ultrafit.dbo.EquipmentShoe t1
			WHERE DateofPurchase Is Not Null Or DateofPurchase <>' '
			GROUP BY t1.Personid

			Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null  As EquipmentShoeModel, null As EquipmentShoeDateofPurchase,
			        STUFF((SELECT ', ' + Replace(Convert(varchar,ThresholdHeartRate),',',' ') 
			               FROM Ultrafit.dbo.HeartRateZonesForPerson t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As ThresholdHeartRate, null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM Ultrafit.dbo.HeartRateZonesForPerson t1
			WHERE ThresholdHeartRate Is Not Null or ThresholdHeartRate <>' '
			GROUP BY t1.Personid
			

			Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null  As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate,  
			        STUFF((SELECT ', ' + Replace(Convert(varchar,Endurance),',',' ') 
			               FROM limiter t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM limiter t1
			WHERE Endurance Is Not Null or Endurance <>' '
			GROUP BY t1.Personid
			
			Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null  As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate,  null As LimiterEndurance,
			        STUFF((SELECT ', ' + Replace(Convert(varchar,[Force]),',',' ') 
			               FROM limiter t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM limiter t1
			WHERE [Force] Is Not Null or [Force] <>' '
			GROUP BY t1.Personid
			
			Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null  As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate,  null As LimiterEndurance, null As LimiterForce,
			        STUFF((SELECT ', ' + Replace(Convert(varchar,SpeedSkill),',',' ') 
			               FROM limiter t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM limiter t1
			WHERE SpeedSkill Is Not Null or SpeedSkill <>' '
			GROUP BY t1.Personid
			

			Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null  As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate,  null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill,
			        STUFF((SELECT ', ' + Replace(Convert(varchar,MuscularEndurance),',',' ') 
			               FROM limiter t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM limiter t1
			WHERE MuscularEndurance Is Not Null or MuscularEndurance <>' '
			GROUP BY t1.Personid
			
			Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null  As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate,  null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance,
			        STUFF((SELECT ', ' + Replace(Convert(varchar,AnaerobicEndurance),',',' ') 
			               FROM limiter t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM limiter t1
			WHERE AnaerobicEndurance Is Not Null or AnaerobicEndurance <>' '
			GROUP BY t1.Personid
			
			Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null  As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate,  null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance,
			        STUFF((SELECT ', ' + Replace(Convert(varchar,[Power]),',',' ') 
			               FROM limiter t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As LimiterPower, null As UserTypePrevious, null As ThresholdPower
			FROM limiter t1
			WHERE [Power] Is Not Null or [Power] <>' '
			GROUP BY t1.Personid

			Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null  As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate,  null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower,
			        STUFF((SELECT ', ' + Replace(Convert(varchar,UserTypePrevious),',',' ') 
			               FROM PersonHistory t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As UserTypePrevious, null  As ThresholdPower
			FROM PersonHistory t1
			WHERE UserTypePrevious Is Not Null or UserTypePrevious <>' '
			GROUP BY t1.Personid

			Union All
			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null  As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate,  null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious,
			        STUFF((SELECT ', ' + Replace(Convert(varchar,ThresholdPower),',',' ') 
			               FROM PowerZonesForPerson t2 WHERE t2.Personid = t1.Personid FOR XML PATH ('')),1,2,'') As ThresholdPower
			FROM PowerZonesForPerson t1
			WHERE ThresholdPower Is Not Null or ThresholdPower <>' '
			GROUP BY t1.Personid
			
---------------------
--			Union All
--			SELECT  t1.Personid, null As CouponCodeUsed, null As CouponCodePrice, null AS AtpSeasongoals, null AS AtpObjectives, null As AnnualHours, null As EquipmentBikeBrand, null As EquipmentBikeModel, null As EquipmentBikeDateofPurchase, null As EquipmentShoeBrand, null  As EquipmentShoeModel, null As EquipmentShoeDateofPurchase, null As ThresholdHeartRate,  null As LimiterEndurance, null As LimiterForce, null As LimiterSpeedSkill, null As LimiterMuscularEndurance, null As LimiterAnaerobicEndurance, null As LimiterPower, null As UserTypePrevious,
--			        STUFF((Select N', ' + DeviceMake + ' ' +DeviceModel + '--- (TimesUploaded:' + Convert(varchar, COUNT(*)) + ')'  
--			               FROM uploadedFile t2 WHERE t2.Personid = t1.Personid Group By DeviceMake, DeviceModel 
--			               FOR XML PATH ('')),1,2,'') As UploadedFileDevicemake
--			FROM uploadedFile t1
--			WHERE DeviceMake Is Not Null or DeviceMake <>' '
--			GROUP BY t1.Personid

		)
		INSERT INTO #ManyRowsIntoOneColumn
			  (PersonId, 
			   CouponCodeUsed, 
			   CouponCodePrice, 
			   AtpSeasongoals, 
			   AtpObjectives, 
			   AnnualHours,
			   EquipmentBikeBrand,
			   EquipmentBikeModel,
			   EquipmentBikeDateofPurchase,
			   EquipmentShoeBrand,
			   EquipmentShoeModel,
			   EquipmentShoeDateofPurchase,
			   ThresholdHeartRate,
			   LimiterEndurance, 
			   LimiterForce,
			   LimiterSpeedSkill,
			   LimiterMuscularEndurance,
			   LimiterAnaerobicEndurance,   
			   LimiterPower,   
			   UserTypePrevious,
			   ThresholdPower)   
		Select PersonId, 
		       Max(CouponCodeUsed) CouponCodeUsed, 
		       Max(CouponCodePrice) CouponCodePrice, 
		       Max(AtpSeasongoals) AtpSeasongoals, 
		       Max(AtpObjectives) AtpObjectives, 
		       Max(AnnualHours) AnnualHours,
		       Max(EquipmentBikeBrand) EquipmentBikeBrand,
		       Max(EquipmentBikeModel) EquipmentBikeModel,
  		       Max(EquipmentBikeDateofPurchase) EquipmentBikeDateofPurchase,
  		       Max(EquipmentShoeBrand) EquipmentShoeBrand,
		       Max(EquipmentShoeModel) EquipmentShoeModel,
  		       Max(EquipmentShoeDateofPurchase) EquipmentShoeDateofPurchase,
  		       Max(ThresholdHeartRate) ThresholdHeartRate,
  		       Max(LimiterEndurance) LimiterEndurance, 
  		       Max(LimiterForce) LimiterForce,
  		       Max(LimiterSpeedSkill) LimiterSpeedSkill,
  		       Max(LimiterMuscularEndurance) LimiterMuscularEndurance,
  		       Max(LimiterAnaerobicEndurance) LimiterAnaerobicEndurance,   
  		       Max(LimiterPower) LimiterPower,   
  		       Max(UserTypePrevious) UserTypePrevious,
  		       Max(ThresholdPower) ThresholdPower   
		From StuffManyIntoOne 
		Group By personid;

		With Info As (
			Select  p.PersonID, p.UserType, p.AthleteType, p.City, p.[State], p.Zip, p.Country, p.AccountCreationDate, p.LastLogon,
         			p.NumberOfVisits, p.Age, p.Sex, p.AffiliateID, p.[Language], a.Category,
         			(Select COUNT(*) From dbo.PersonHistory Where PersonId=p.personId And UserTypePrevious In (1, 2, 4) Group By PersonId) As TimesAccountLapsed,
				--Stuff many rows into one column,
				    m.CouponCodeUsed,  m.CouponCodePrice, m.AtpSeasongoals,  m.AtpObjectives,  m.AnnualHours,  m.EquipmentBikeBrand, m.EquipmentBikeModel, 
				    m.EquipmentBikeDateofPurchase, m.EquipmentShoeBrand,  m.EquipmentShoeModel, m.EquipmentShoeDateofPurchase, m.ThresholdHeartRate, m.LimiterEndurance, 
				    m.LimiterForce, m.LimiterSpeedSkill, m.LimiterMuscularEndurance, m.LimiterAnaerobicEndurance, m.LimiterPower, m.UserTypePrevious, m.ThresholdPower,
				--SocialPerson
					s.FacebookId As SocialPerson_FacebookId, s.TwitterId As SocialPerson_TwitterId,
				--UploadedFile
				(SELECT Stuff((Select N', ' + DeviceMake + ' ' + DeviceModel + '--- (TimesUploaded:' + Convert(varchar, COUNT(*)) + ')' 
							   From uploadedFile 
							   Where PersonId = p.PersonId  
							   Group By DeviceMake, DeviceModel FOR XML PATH(''),TYPE) .value('text()[1]','nvarchar(Max)'),1,2,N'')) AS UploadedFile_Devicemake
		From Person As p Inner Join Athlete As a On p.PersonId = a.PersonId 
		                 Left Outer Join #ManyRowsIntoOneColumn as m On p.PersonId = m.PersonId 
						 Left Outer Join SocialPerson As s On p.PersonId = s.PersonId 
		)
		
		INSERT INTO PersonSummary (
				   [PersonId]
				   ,[UserType]
				   ,[AthleteType]
				   ,[City]
				   ,[State]
				   ,[Zip]
				   ,[Country]
				   ,[AccountCreationDate]
				   ,[LastLoginDate]
				   ,[NumberOfVisits]
				   ,[Age]
				   ,[Sex]
				   ,[AffiliateId]
				   ,[Language]
				   ,[Category]
				   ,[TimesAccountLapsed]
				   ,[CouponCodeUsed_CouponCodeType]
				   ,[CouponCodeUsed_Price]
				   ,[ATP_SeasonGoals]
				   ,[ATP_Objectives]
				   ,[ATP_AnnualHours]
				   ,[EquipmentBike_Brand]
				   ,[EquipmentBike_Model]
				   ,[EquipmentBike_DateofPurchase]
				   ,[EquipmentShoe_Brand]
				   ,[EquipmentShoe_Model]
				   ,[EquipmentShoe_DateofPurchase]
				   ,[HeartRateZonesforPerson_ThresholdHeartRate]
				   ,[limiter_Endurance]
				   ,[limiter_Force]
				   ,[limiter_SpeedSkill]
				   ,[limiter_MuscularEndurance]
				   ,[limiter_AnaerobicEndurance]
				   ,[limiter_Power]
				   ,[PersonHistory_UserTypePrevious]
				   ,[PowerZonesForPerson_ThresholdPower]
				   ,[SocialPerson_FacebookId]
				   ,[SocialPerson_TwitterId]
				   ,[UploadedFile_Devicemake])
		Select 
				   [PersonId]
				   ,[UserType]
				   ,[AthleteType]
				   ,[City]
				   ,[State]
				   ,[Zip]
				   ,[Country]
				   ,[AccountCreationDate]
				   ,[LastLogon]
				   ,[NumberOfVisits]
				   ,[Age]
				   ,[Sex]
				   ,[AffiliateId]
				   ,[Language]
				   ,[Category]
				   ,[TimesAccountLapsed]
				   ,[CouponCodeUsed]
				   ,[CouponCodePrice]
				   ,[AtpSeasongoals]
				   ,[AtpObjectives]
				   ,[AnnualHours]
				   ,[EquipmentBikeBrand]
				   ,[EquipmentBikeModel]
				   ,[EquipmentBikeDateofPurchase]
				   ,[EquipmentShoeBrand]
				   ,[EquipmentShoeModel]
				   ,[EquipmentShoeDateofPurchase]
				   ,[ThresholdHeartRate]
				   ,[limiterEndurance]
				   ,[limiterForce]
				   ,[limiterSpeedSkill]
				   ,[limiterMuscularEndurance]
				   ,[limiterAnaerobicEndurance]
				   ,[limiterPower]
				   ,[UserTypePrevious]
				   ,[ThresholdPower]
				   ,[SocialPerson_FacebookId]
				   ,[SocialPerson_TwitterId]
				   ,[UploadedFile_Devicemake]
		From Info 
		
		DROP TABLE #ManyRowsIntoOneColumn;
End

GO
