--create dimensional tables
--create fact table

CREATE TABLE PILOT_DIM
(
PILOTID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
EMP_NUM INT NOT NULL,
PIL_LICENSE NVARCHAR(25),
PIL_RATINGS NVARCHAR(25),
PIL_MED_TYPE NVARCHAR(1),
PIL_MED_DATE DATETIME,
PIL_PT135_DATE DATETIME,
EMP_TITLE NVARCHAR(4),
EMP_LNAME NVARCHAR(15),
EMP_FNAME NVARCHAR(15),
EMP_INITIAL NVARCHAR(1),
EMP_DOB DATETIME,
EMP_HIRE_DATE DATETIME
)

CREATE TABLE MODEL_DIM
(
ModelID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
MOD_CODE NVARCHAR(10) NOT NULL,
MOD_MANUFACTURER NVARCHAR(15),
MOD_NAME NVARCHAR(20),
MOD_SEATS FLOAT,
MOD_CHG_MILE REAL,
MOD_CRUISE FLOAT,
MOD_FUEL FLOAT
)

CREATE TABLE TIME_DIM
(
TIMEID			INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
DATEVALUE		DATETIME,
YEAR_NUM		INT,
MONTH_NUM		INT,
DAY_NUM			INT,
)

CREATE TABLE FACT_TABLE
(
ModelID INT NOT NULL,
TimeID INT NOT NULL,
PilotID INT NOT NULL,
TOT_HOURS_FLOWN FLOAT,
TOT_FUEL_USED FLOAT,
TOT_REVENUE REAL
)


ALTER TABLE FACT_TABLE
ADD CONSTRAINT FK_TIME FOREIGN KEY (TimeID) REFERENCES TIME_DIM
ALTER TABLE FACT_TABLE
ADD CONSTRAINT FK_MODEL FOREIGN KEY (ModelID) REFERENCES MODEL_DIM
ALTER TABLE FACT_TABLE
ADD CONSTRAINT FK_PILOT FOREIGN KEY (PilotID) REFERENCES PILOT_DIM

ALTER TABLE FACT_TABLE
ADD PRIMARY KEY (ModelID, TimeID, PilotID)


--execute stored procedure
EXEC A11 --EXECUTES CORRECTLY


--check tables 
select *
from time_dim

select *
from pilot_dim

select * 
from model_dim

select *
from fact_table


--- for questions
SELECT T.YEAR_NUM, T.MONTH_NUM, T.DAY_NUM, SUM(F.TOT_HOURS_FLOWN) 
FROM FACT_TABLE F INNER JOIN .TIME_DIM T ON F.TIMEID = T.TIMEID
GROUP BY T.YEAR_NUM, T.MONTH_NUM, T.DAY_NUM
ORDER BY T.YEAR_NUM, T.MONTH_NUM, T.DAY_NUM




ALTER VIEW YEARVIEW AS
SELECT T.YEAR_NUM,  MAX(F.TOT_HOURS_FLOWN) AS 'Y TOT HOURS FLOWN', T.TIMEID
FROM FACT_TABLE F INNER JOIN TIME_DIM T ON F.TIMEID = T.TIMEID
GROUP BY T.YEAR_NUM, T.TIMEID


ALTER VIEW MONTHVIEW AS
SELECT T.MONTH_NUM,  MAX(F.TOT_HOURS_FLOWN) AS 'M TOT HOURS FLOWN', T.TIMEID
FROM FACT_TABLE F INNER JOIN TIME_DIM T ON F.TIMEID = T.TIMEID
GROUP BY T.MONTH_NUM, T.TIMEID




---------- WHAT IS THE MAX SUMMED TOTAL HOURS FLOWN PER YEAR, MONTH, AND DAY

CREATE VIEW YVIEW AS
SELECT T.YEAR_NUM, SUM(F.TOT_HOURS_FLOWN) AS 'YEAR SUM'
FROM TIME_DIM T INNER JOIN FACT_TABLE F ON T.TIMEID = F.TIMEID
GROUP BY T.YEAR_NUM

CREATE VIEW MVIEW AS
SELECT T.MONTH_NUM, SUM(F.TOT_HOURS_FLOWN) AS 'MONTH SUM'
FROM TIME_DIM T INNER JOIN FACT_TABLE F ON T.TIMEID = F.TIMEID
GROUP BY T.MONTH_NUM

CREATE VIEW DVIEW AS
SELECT T.DAY_NUM,SUM(F.TOT_HOURS_FLOWN) AS 'DAY SUM'
FROM TIME_DIM T INNER JOIN FACT_TABLE F ON T.TIMEID = F.TIMEID
GROUP BY T.DAY_NUM

CREATE VIEW DMAX AS
SELECT DISTINCT DAY_NUM, MAX([DAY SUM]) AS 'MAX_DAY'
FROM DVIEW
GROUP BY DAY_NUM

CREATE VIEW V1 AS
SELECT  DAY_NUM, MAX([DAY SUM]) AS 'MAX_DAY'
FROM DVIEW
WHERE [DAY SUM] = (SELECT MAX([DAY SUM]) AS 'MDAY' FROM DVIEW) 
GROUP BY DAY_NUM

CREATE VIEW V2 AS
SELECT MONTH_NUM, MAX([MONTH SUM]) AS 'MAX_MONTH'
FROM MVIEW
WHERE [MONTH SUM] = (SELECT MAX([MONTH SUM]) AS 'MMONTH' FROM MVIEW) 
GROUP BY MONTH_NUM

CREATE VIEW V3 AS
SELECT YEAR_NUM, MAX([YEAR SUM]) AS 'MAX_YEAR'
FROM YVIEW
WHERE [YEAR SUM] = (SELECT MAX([YEAR SUM]) AS 'MYEAR' FROM YVIEW) 
GROUP BY YEAR_NUM

SELECT YEAR_NUM, MAX_YEAR, MONTH_NUM, MAX_MONTH, DAY_NUM, MAX_DAY
FROM V1 CROSS JOIN V2 CROSS JOIN V3

--what is the average TOTAL HOURS FLOWN AS PER YEAR, MONTH, DAY

SELECT T.YEAR_NUM, AVG(F.TOT_HOURS_FLOWN)
FROM FACT_TABLE F INNER JOIN TIME_DIM T ON F.TIMEID = T.TIMEIID
GROUP BY Y.YEAR_NUM


-----UPDATING QUESTION












