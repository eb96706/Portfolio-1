USE [cis31032]
GO
/****** Object:  StoredProcedure [dbo].[A11]    Script Date: 04/21/2011 20:01:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[A11]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--PLACING INFO INTO DIMENSION TABLES
INSERT INTO PILOTDIM
SELECT P.EMP_NUM, E.EMP_TITLE, E.EMP_LNAME, P.PIL_LICENSE, P.PIL_RATINGS
FROM EMPLOYEE E INNER JOIN PILOT P ON E.EMP_NUM = P.EMP_NUM

INSERT INTO CUSTOMERDIM
SELECT CUS_CODE, CUS_LNAME, CUS_FNAME
FROM CUSTOMER

INSERT INTO TIMEDIM (CHARTER_DATE, YEAR_NUM, MONTH_NUM, DAY_NUM, WEEK_NUM, QUARTER_NUM)
SELECT DISTINCT CHAR_DATE, YEAR(CHAR_DATE), MONTH(CHAR_DATE), DAY(CHAR_DATE), DATEPART(WEEK, CHAR_DATE),
				DATEPART(QUARTER, CHAR_DATE)
FROM CHARTER

INSERT INTO MODELDIM
SELECT MOD_CODE, MOD_MANUFACTURER, MOD_NAME, MOD_SEATS, MOD_CHG_MILE
FROM MODEL

-- TURN OFF CONSTRAINTS
ALTER TABLE FACT DROP CONSTRAINT FK_PILOT
ALTER TABLE FACT DROP CONSTRAINT FK_CUSTOMER
ALTER TABLE FACT DROP CONSTRAINT FK_TIME
ALTER TABLE FACT DROP CONSTRAINT FK_MODEL
ALTER TABLE PILOTDIM NOCHECK CONSTRAINT ALL
ALTER TABLE CUSTOMERDIM NOCHECK CONSTRAINT ALL
ALTER TABLE TIMEDIM NOCHECK CONSTRAINT ALL
ALTER TABLE MODELDIM NOCHECK CONSTRAINT ALL

--REMOVE ALL ROWS
TRUNCATE TABLE FACT
TRUNCATE TABLE PILOTDIM
TRUNCATE TABLE CUSTOMERDIM
TRUNCATE TABLE TIMEDIM
TRUNCATE TABLE MODELDIM

--TURN ON CONSTRAINTS AGAIN
ALTER TABLE PILOTDIM CHECK CONSTRAINT ALL
ALTER TABLE CUSTOMERDIM CHECK CONSTRAINT ALL
ALTER TABLE TIMEDIM CHECK CONSTRAINT ALL
ALTER TABLE MODELDIM CHECK CONSTRAINT ALL
ALTER TABLE FACT CHECK CONSTRAINT ALL
ALTER TABLE FACT
ADD CONSTRAINT [FK_PILOT] FOREIGN KEY (PILOTID) REFERENCES PILOTDIM,
CONSTRAINT [FK_CUSTOMER] FOREIGN KEY (CUSTOMERID) REFERENCES CUSTOMERDIM,
CONSTRAINT [FK_TIME] FOREIGN KEY (TIMEID) REFERENCES TIMEDIM,
CONSTRAINT [FK_MODEL] FOREIGN KEY (MODELID) REFERENCES MODELDIM

--INSERTS TRANSACTIONAL DATA INTO STAGETABLE
INSERT INTO STAGETABLE (CHAR_DISTANCE, CHAR_HOURS_FLOWN, CHAR_FUEL_GALLONS, CHAR_OIL_QTS, CUS_CODE, CHARTER_DATE, MOD_CODE, EMP_NUM, MOD_CHG_MILE)
SELECT CH.CHAR_DISTANCE, CH.CHAR_HOURS_FLOWN, CH.CHAR_FUEL_GALLONS, CH.CHAR_OIL_QTS, C.CUS_CODE, CH.CHAR_DATE, M.MOD_CODE, P.EMP_NUM, M.MOD_CHG_MILE
FROM CUSTOMER C INNER JOIN CHARTER CH ON C.CUS_CODE = CH.CUS_CODE
	 INNER JOIN AIRCRAFT A ON CH.AC_NUMBER = A.AC_NUMBER
	 INNER JOIN MODEL M ON A.MOD_CODE = M.MOD_CODE
	 INNER JOIN CREW CR ON CH.CHAR_TRIP = CR.CHAR_TRIP
	 INNER JOIN PILOT P ON CR.EMP_NUM = P.EMP_NUM

--UPDATE STAGETABLE TO ASSIGN DATAWAREHOUSE KEYS
UPDATE STAGETABLE
SET PILOTID = P.PILOTID
FROM STAGETABLE S INNER JOIN PILOTDIM P ON S.EMP_NUM = P.EMP_NUM

UPDATE STAGETABLE
SET CUSTOMERID = C.CUSTOMERID
FROM STAGETABLE S INNER JOIN CUSTOMERDIM C ON S.CUS_CODE = C.CUS_CODE

UPDATE STAGETABLE
SET TIMEID = T.TIMEID
FROM STAGETABLE S INNER JOIN TIMEDIM T ON S.CHARTER_DATE = T.CHARTER_DATE

UPDATE STAGETABLE
SET MODELID = M.MODELID
FROM STAGETABLE S INNER JOIN MODELDIM M ON S.MOD_CODE = M.MOD_CODE

--POPULATE FACT TABLE
INSERT INTO FACT
SELECT PILOTID, MODELID, TIMEID, CUSTOMERID, CHAR_DISTANCE, CHAR_HOURS_FLOWN, CHAR_FUEL_GALLONS, CHAR_OIL_QTS, (CHAR_DISTANCE * MOD_CHG_MILE) AS COST
FROM STAGETABLE



END
