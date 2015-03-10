-- --------------------------------------------------------------------------------
-- Name: Levi Harrington
-- Class: SQL Server 2
-- Abstract: Edit Race Conditions
-- --------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------------
USE dbSQL1		
SET NOCOUNT ON	-- Report only errors



-- --------------------------------------------------------------------------------
-- Drops
-- --------------------------------------------------------------------------------
IF OBJECT_ID( 'TScheduledRouteDrivers' )				IS NOT NULL DROP TABLE TScheduledRouteDrivers
IF OBJECT_ID( 'TDriverRoles' )						IS NOT NULL DROP TABLE TDriverRoles
IF OBJECT_ID( 'TScheduledRoutes' )					IS NOT NULL DROP TABLE TScheduledRoutes
IF OBJECT_ID( 'TScheduledTimes' )					IS NOT NULL DROP TABLE TScheduledTimes
IF OBJECT_ID( 'TDrivers' )						IS NOT NULL DROP TABLE TDrivers
IF OBJECT_ID( 'TBuses' )						IS NOT NULL DROP TABLE TBuses
IF OBJECT_ID( 'TRoutes' )						IS NOT NULL DROP TABLE TRoutes

IF OBJECT_ID( 'uspEditRoute' )						IS NOT NULL DROP PROCEDURE uspEditRoute
IF OBJECT_ID( 'uspEditDriver' )						IS NOT NULL DROP PROCEDURE uspEditDriver
IF OBJECT_ID( 'uspEditScheduledRoute' )					IS NOT NULL DROP PROCEDURE uspEditScheduledRoute
IF OBJECT_ID( 'uspMoveScheduledRoute' )					IS NOT NULL DROP PROCEDURE uspMoveScheduledRoute
IF OBJECT_ID( 'uspSuperEditScheduleRoute' )				IS NOT NULL DROP PROCEDURE uspSuperEditScheduleRoute



-- --------------------------------------------------------------------------------
-- Step #1: Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TRoutes
(
	 intRouteID				INTEGER			NOT NULL
	,strRoute				VARCHAR(50)		NOT NULL
	,strRouteDescription			VARCHAR(50)		NOT NULL
	,rvLastUpdated				ROWVERSION		NOT NULL
	,CONSTRAINT TRoutes_PK PRIMARY KEY ( intRouteID )
)

CREATE TABLE TBuses
(
	 intBusID				INTEGER			NOT NULL
	,strBus					VARCHAR(50)		NOT NULL
	,intCapacity				INTEGER			NOT NULL
	,CONSTRAINT TBuses_PK PRIMARY KEY ( intBusID )
)

CREATE TABLE TDrivers
(
	 intDriverID				INTEGER			NOT NULL
	,strFirstName				VARCHAR(50)		NOT NULL
	,strLastName				VARCHAR(50)		NOT NULL
	,strPhoneNumber				VARCHAR(50)		NOT NULL
	,rvLastUpdated				ROWVERSION		NOT NULL
	,CONSTRAINT TDrivers_PK PRIMARY KEY ( intDriverID )					 
)

CREATE TABLE TScheduledTimes
(
	 intScheduledTimeID			INTEGER			NOT NULL
	,strScheduledTime			VARCHAR(50)		NOT NULL
	,CONSTRAINT TScheduledTimes_PK PRIMARY KEY ( intScheduledTimeID )
)

CREATE TABLE TScheduledRoutes
(
	 intScheduledTimeID			INTEGER			NOT NULL
	,intRouteID				INTEGER			NOT NULL
	,intBusID				INTEGER			NOT NULL
	,rvLastUpdated				ROWVERSION		NOT NULL
	,CONSTRAINT TScheduledRoutes_PK PRIMARY KEY ( intScheduledTimeID, intRouteID )
)

CREATE TABLE TDriverRoles
(
	 intDriverRoleID			INTEGER			NOT NULL
	,strDriverRole				VARCHAR(50)		NOT NULL
	,intSortOrder				INTEGER			NOT NULL
	,CONSTRAINT TDriverRoles_PK PRIMARY KEY ( intDriverRoleID )
)

CREATE TABLE TScheduledRouteDrivers
(
	 intScheduledTimeID			INTEGER			NOT NULL
	,intRouteID				INTEGER			NOT NULL
	,intDriverID				INTEGER			NOT NULL
	,intDriverRoleID			INTEGER			NOT NULL
	,CONSTRAINT TScheduledRouteDrivers_PK PRIMARY KEY ( intScheduledTimeID, intRouteID, intDriverID )
)



-- --------------------------------------------------------------------------------
-- Step #2: Identify and Create Foreign Keys
-- --------------------------------------------------------------------------------
--#		Child				Parent				Column(s)
--		------				-------				---------
--1		TScheduledRoutes		TScheduledTimes			intScheduledTimeID								
--2		TScheduledRoutes		TRoutes				intRouteID
--3		TScheduledRoutes		TBuses				intBusID
--4		TScheduledRouteDrivers		TScheduledRoutes		intScheduledTimeID, intRouteID
--5		TScheduledRouteDrivers		TDrivers			intDriverID
--6		TScheduledRouteDrivers		TDriverRoles			intDriverRoleID

--1
ALTER TABLE TScheduledRoutes ADD CONSTRAINT TScheduledRoutes_TScheduledTimes_FK
	FOREIGN KEY ( intScheduledTimeID ) REFERENCES TScheduledTimes ( intScheduledTimeID )

--2
ALTER TABLE TScheduledRoutes ADD CONSTRAINT TScheduledRoutes_TRoutes_FK
	FOREIGN KEY ( intRouteID ) REFERENCES TRoutes ( intRouteID )

--3
ALTER TABLE TScheduledRoutes ADD CONSTRAINT TScheduledRoutes_TBuses_FK
	FOREIGN KEY ( intBusID ) REFERENCES TBuses ( intBusID )

--4
ALTER TABLE TScheduledRouteDrivers ADD CONSTRAINT TScheduledRouteDrivers_TScheduledRoutes_FK
	FOREIGN KEY ( intScheduledTimeID, intRouteID ) REFERENCES TScheduledRoutes ( intScheduledTimeID, intRouteID )

--5
ALTER TABLE TScheduledRouteDrivers ADD CONSTRAINT TScheduledRouteDrivers_TDrivers_FK
	FOREIGN KEY ( intDriverID ) REFERENCES TDrivers ( intDriverID )

--6
ALTER TABLE TScheduledRouteDrivers ADD CONSTRAINT TScheduledRouteDrivers_TDriverRoles_FK
	FOREIGN KEY ( intDriverRoleID ) REFERENCES TDriverRoles ( intDriverRoleID )



-- --------------------------------------------------------------------------------
-- Step #2.5: Unique constraints for data integrity 
-- --------------------------------------------------------------------------------
-- Don't allow the same bus to be scheduled more than once at the same time
ALTER TABLE TScheduledRoutes ADD CONSTRAINT TScheduledRoutes_intScheduledTImeID_intBusID
UNIQUE ( intScheduledTimeID, intBusID )

-- Don't allow the same bus to be scheduled more than once at the same time
ALTER TABLE TScheduledRouteDrivers ADD CONSTRAINT TScheduledRouteDrivers_intScheduledTImeID_intDriverID
UNIQUE ( intScheduledTimeID, intDriverID )



-- --------------------------------------------------------------------------------
-- Step #3: Add at least 2 inserts to each table
-- --------------------------------------------------------------------------------
INSERT INTO TRoutes( intRouteID, strRoute, strRouteDescription )
VALUES	 ( 1, 'R50', 'Milford to Downtown' )
	,( 2, 'R00', 'Hyde Park to Mason' )

INSERT INTO TBuses( intBusID, strBus, intCapacity )
VALUES	 ( 1, 'Bus X', 30 )
	,( 2, 'Bus Y', 40 )
	,( 3, 'Bus Z', 25 )

INSERT INTO TDrivers( intDriverID, strFirstName, strLastName, strPhoneNumber )
VALUES	 ( 1, 'Han', 'Solo', '111-1111' )
	,( 2, 'Talon', 'Karrde', '222-2222' )
	,( 3, 'Mara', 'Jade', '333-3333' )

INSERT INTO TDriverRoles( intDriverRoleID, strDriverRole, intSortOrder )
VALUES	 ( 1, 'Primary Driver', 1 )
	,( 2, 'Backup Driver #1', 2 )
	,( 3, 'Backup Driver #2', 3 )
		
INSERT INTO TScheduledTimes( intScheduledTimeID, strScheduledTime )
VALUES	 ( 1, '9AM' )
	,( 2, '11AM' )
	,( 3, '1PM' )
	,( 4, '4PM' )
	,( 5, '6PM' )
		
INSERT INTO TScheduledRoutes( intScheduledTimeID, intRouteID, intBusID )
VALUES	 ( 1, 1, 1 )
	,( 2, 2, 2 )

INSERT INTO TScheduledRouteDrivers( intScheduledTimeID, intRouteID, intDriverID, intDriverRoleID )
VALUES	 ( 1, 1, 1, 1 )
	,( 2, 2, 2, 1 ) 


		
-- --------------------------------------------------------------------------------
-- Step #4: uspEditRoute
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspEditRoute
	 @intRouteID			AS INTEGER
	,@strRoute			AS VARCHAR(50)
	,@strRouteDescription		AS VARCHAR(50)
	,@rvLastUpdated			AS ROWVERSION
AS
SET NOCOUNT ON		-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error

DECLARE @blnRaceConditionExists AS BIT = 1	-- Assume there is a race condition

-- Update the record
UPDATE
	TRoutes
SET
	 strRoute			= @strRoute
	,strRouteDescription		= @strRouteDescription
WHERE
		intRouteID		= @intRouteID
	AND	rvLastUpdated		= @rvLastUpdated 

-- Was the row updated?
IF @@ROWCOUNT = 1

	-- Yes, the row has not been changed so no edit race condition exists
	SET @blnRaceConditionExists = 0

-- Let the caller know if there was a race condition or not
SELECT @blnRaceConditionExists AS blnRaceConditionExists

GO



-- --------------------------------------------------------------------------------
-- Step #5: call uspEditRoute
-- --------------------------------------------------------------------------------
SELECT 'call uspEditRoute' AS 'Step #5'

DECLARE @strRoute			AS VARCHAR( 50 )
DECLARE @strRouteDescription		AS VARCHAR( 50 )
DECLARE @rvLastUpdated			AS ROWVERSION

-- Simulate loading data from database onto form
SELECT
	 @strRoute			= strRoute
	,@strRouteDescription		= strRouteDescription
	,@rvLastUpdated			= rvLastUpdated
FROM
	TRoutes
WHERE
	intRouteID	= 1	-- Hard code for curling/whatever Route

-- Simulate a delay during which the user would change the fields on the form
WAITFOR DELAY '00:00:03'	-- hh:mm:ss  change to whatever you need
SELECT @strRouteDescription = 'Kenwood to Downtown'

-- Simulate clicking OK on the edit form and attempt to save data by calling USP
EXECUTE uspEditRoute 1, @strRoute, @strRouteDescription , @rvLastUpdated

-- It should return 0 for blnRaceConditionExists and you should see that the record was updated
SELECT * FROM TRoutes WHERE intRouteID = 1	-- Verify change.



-- --------------------------------------------------------------------------------
-- Step #6: Call and test uspEditRoute with another copy of SQL Server
-- --------------------------------------------------------------------------------
--DECLARE @strRoute			AS VARCHAR( 50 )
--DECLARE @strRouteDescription		AS VARCHAR( 50 )
--DECLARE @rvLastUpdated		AS ROWVERSION

---- Simulate loading data from database onto form
--SELECT
--	 @strRoute			= strRoute
--	,@strRouteDescription		= strRouteDescription
--	,@rvLastUpdated			= rvLastUpdated
--FROM
--	TRoutes
--WHERE
--	intRouteID	= 1	-- Hard code for curling/whatever Route

---- Simulate a delay during which the user would change the fields on the form
--WAITFOR DELAY '00:00:03'	-- hh:mm:ss  change to whatever you need
--SELECT @strRouteDescription = 'Kenwood to Downtown'

---- Simulate clicking OK on the edit form and attempt to save data by calling USP
--EXECUTE uspEditRoute 1, @strRoute, @strRouteDescription , @rvLastUpdated

---- It should return 0 for blnRaceConditionExists and you should see that the record was updated
--SELECT * FROM TRoutes WHERE intRouteID = 1	-- Verify change.



-- Other SQL Server running 
--UPDATE TRoutes
--SET strRouteDescription = 'I beat you to it.'
--WHERE intRouteID = 1



-- --------------------------------------------------------------------------------
-- Step #7: uspEditDriver
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspEditDriver
	 @intDriverID			AS INTEGER
	,@strFirstName			AS VARCHAR(50)
	,@strLastName			AS VARCHAR(50)
	,@strPhoneNumber		AS VARCHAR(50)
	,@rvLastUpdated			AS ROWVERSION
AS
SET NOCOUNT ON		-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error

DECLARE @blnRaceConditionExists AS BIT = 1	-- Assume there is a race condition

-- Update the record but --
UPDATE
	TDrivers
SET
	 strFirstName			= @strFirstName
	,strLastName			= @strLastName
	,strPhoneNumber			= @strPhoneNumber
WHERE
		intDriverID		= @intDriverID
	AND	rvLastUpdated		= @rvLastUpdated 

-- Was the row updated?
IF @@ROWCOUNT = 1

	-- Yes, the row has not been changed so no edit race condition exists
	SET @blnRaceConditionExists = 0

-- Let the caller know if there was a race condition or not
SELECT @blnRaceConditionExists AS blnRaceConditionExists

GO



-- --------------------------------------------------------------------------------
-- Step #8: call uspEditDriver
-- --------------------------------------------------------------------------------
SELECT 'call uspEditDriver' AS 'Step #8'

DECLARE @strFirstName			AS VARCHAR( 50 )
DECLARE @strLastName			AS VARCHAR( 50 )
DECLARE @strPhoneNumber			AS VARCHAR( 50 )
DECLARE @rvLastUpdated			AS ROWVERSION

-- Simulate loading data from database onto form
SELECT
	 @strFirstName			= strFirstName
	,@strLastName			= strLastName
	,@strPhoneNumber		= strPhoneNumber
	,@rvLastUpdated			= rvLastUpdated
FROM
	TDrivers
WHERE
	intDriverID	= 1	-- Hard code for driver

-- Simulate a delay during which the user would change the fields on the form
WAITFOR DELAY '00:00:03'	-- hh:mm:ss  change to whatever you need
SELECT @strLastName = 'Calrissian'

-- Simulate clicking OK on the edit form and attempt to save data by calling USP
EXECUTE uspEditDriver 1, @strFirstName, @strLastName, @strPhoneNumber, @rvLastUpdated

-- It should return 0 for blnRaceConditionExists and you should see that the record was updated
SELECT * FROM TDrivers WHERE intDriverID = 1	-- Verify change.



-- --------------------------------------------------------------------------------
-- Step #9: Call and test uspEditDriver with another copy of SQL Server
-- --------------------------------------------------------------------------------
--DECLARE @strFirstName			AS VARCHAR( 50 )
--DECLARE @strLastName			AS VARCHAR( 50 )
--DECLARE @strPhoneNumber		AS VARCHAR( 50 )
--DECLARE @rvLastUpdated		AS ROWVERSION

---- Simulate loading data from database onto form
--SELECT
--	 @strFirstName			= strFirstName
--	,@strLastName			= strLastName
--	,@strPhoneNumber		= strPhoneNumber
--	,@rvLastUpdated			= rvLastUpdated
--FROM
--	TDrivers
--WHERE
--	intDriverID	= 1	-- Hard code for driver

---- Simulate a delay during which the user would change the fields on the form
--WAITFOR DELAY '00:00:03'	-- hh:mm:ss  change to whatever you need
--SELECT @strLastName = 'Calrissian'

---- Simulate clicking OK on the edit form and attempt to save data by calling USP
--EXECUTE uspEditDriver 1, @strFirstName, @strLastName, @strPhoneNumber, @rvLastUpdated

---- It should return 0 for blnRaceConditionExists and you should see that the record was updated
--SELECT * FROM TDrivers WHERE intDriverID = 1	-- Verify change.


-- Other SQL Server running 
--UPDATE TDrivers
--SET strLastName = 'I beat you to it.'
--WHERE intDriverID = 1



-- --------------------------------------------------------------------------------
-- Step #10: uspEditScheduledRoute
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspEditScheduledRoute
	 @intOldScheduledTimeID		AS INTEGER
	,@intOldRouteID			AS INTEGER
	,@intNewScheduledTimeID		AS INTEGER
	,@intNewRouteID			AS INTEGER
	,@intNewBusID			AS INTEGER
	,@rvLastUpdated			AS ROWVERSION
AS
SET NOCOUNT ON		-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error

DECLARE @blnRaceConditionExists AS BIT = 1	-- Assume there is a race condition

-- Update the record but --
UPDATE
	TScheduledRoutes
SET
	 intBusID			= @intNewBusID
	,intScheduledTimeID 		= @intNewScheduledTimeID
	,intRouteID			= @intNewRouteID
WHERE
	intScheduledTimeID  		= @intOldScheduledTimeID
	AND intRouteID			= @intOldRouteID
	AND rvLastUpdated		= @rvLastUpdated 

-- Was the row updated?
IF @@ROWCOUNT = 1

	-- Yes, the row has not been changed so no edit race condition exists
	SET @blnRaceConditionExists = 0

-- Let the caller know if there was a race condition or not
SELECT @blnRaceConditionExists AS blnRaceConditionExists

GO



-- --------------------------------------------------------------------------------
-- Step #11: call uspEditScheduledRoute
-- --------------------------------------------------------------------------------
-- Make local variable for ROWVERSION so we don't have to type in the value every time we run.
--DECLARE @rvLastUpdated AS ROWVERSION
--SELECT
--	@rvLastUpdated = rvLastUpdated
--FROM
--	TScheduledRoutes
--WHERE
--		intScheduledTimeID = 1
--	AND	intRouteID = 1

--EXECUTE uspEditScheduledRoute 1, 1, 2, 1, 1, @rvLastUpdated	-- Change from 9am to 11am


-- --------------------------------------------------------------------------------
-- Step #12:  Why calling uspEditScheduledRoute fails...
-- --------------------------------------------------------------------------------
-- Because intScheduledTimeID and intRouteID are referenced by a Foreign Key constraint in 
-- TScheduledRouteDrivers.  Sort of like with deleting tables at the top, we have to edit/delete
-- intScheduledTimeID and intRouteID in TScheduledRouteDrivers before doing so in
-- TScheduledRoutes.



-- --------------------------------------------------------------------------------
-- Special Step:  Dispaly original tables to compare with
-- --------------------------------------------------------------------------------
SELECT 'with initial data' AS 'Original tables'

SELECT * FROM TScheduledRoutes
SELECT * FROM TScheduledRouteDrivers



-- --------------------------------------------------------------------------------
-- Step #13:  uspMoveScheduledRoute
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspMoveScheduledRoute
	 @intOldScheduledTimeID		AS INTEGER
	,@intOldRouteID			AS INTEGER
	,@intNewScheduledTimeID		AS INTEGER
	,@intNewRouteID			AS INTEGER
	,@intBusID			AS INTEGER
	,@blnResult			AS BIT OUTPUT
AS
SET NOCOUNT ON		-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error

SET @blnResult = 0 
DECLARE @blnAlreadyExists AS BIT = 0		-- False, does not exist

BEGIN TRANSACTION

	SELECT
		@blnAlreadyExists = 1
	FROM
		TScheduledRoutes (TABLOCKX)			-- Lock table until end of transaction
	WHERE 	intScheduledTimeID	= @intNewScheduledTimeID
		AND	intRouteID	= @intNewRouteID

	IF @blnAlreadyExists = 0 
	BEGIN
 
		INSERT INTO TScheduledRoutes( intScheduledTimeID, intRouteID, intBusID )
		VALUES( @intNewScheduledTimeID, @intNewRouteID, @intBusID  )

	END

	-- Copy drivers from old scheduled route
	INSERT INTO TScheduledRouteDrivers ( intScheduledTimeID, intRouteID, intDriverID, intDriverRoleID )	
	VALUES(		 @intNewScheduledTimeID
				,@intNewRouteID
				,(SELECT 
					intDriverID 
				  FROM 
					TScheduledRouteDrivers	
				  WHERE
						intScheduledTimeID 	= @intOldScheduledTimeID
					AND 	intRouteID		= @intOldRouteID)
				,(SELECT 
					intDriverRoleID 
				  FROM 
					TScheduledRouteDrivers	
				  WHERE
						intScheduledTimeID 	= @intOldScheduledTimeID
					AND 	intRouteID		= @intOldRouteID)
			)

	-- Delete Old Records
	DELETE TScheduledRouteDrivers
	WHERE
			intScheduledTimeID = @intOldScheduledTimeID
		AND intRouteID		   = @intOldRouteID

	DELETE TScheduledRoutes
	WHERE
			intScheduledTimeID = @intOldScheduledTimeID
		AND intRouteID		   = @intOldRouteID
		
	-- if it works...
	SET @blnResult = 1


COMMIT TRANSACTION



-- --------------------------------------------------------------------------------
-- Step #14:  uspSuperEditScheduleRoute
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspSuperEditScheduleRoute
	 @intOldScheduledTimeID		AS INTEGER
	,@intOldRouteID			AS INTEGER
	,@intNewScheduledTimeID		AS INTEGER
	,@intNewRouteID			AS INTEGER
	,@intBusID			AS INTEGER
AS
SET NOCOUNT ON		-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error

DECLARE @blnResult AS BIT = 0

-- If old and new scheduled time or route is different, execute uspMoveScheduledRoute
IF	(@intOldScheduledTimeID <> @intNewScheduledTimeID) 
	OR (@intOldRouteID <> @intNewRouteID)
BEGIN
	EXECUTE uspMoveScheduledRoute @intOldScheduledTimeID, @intOldRouteID, @intNewScheduledTimeID, @intNewRouteID, @intBusID, @blnResult OUTPUT
END
-- Otherwise, just update the bus
ELSE
BEGIN
	UPDATE 
		TScheduledRoutes
	SET
		intBusID 		= @intBusID
	WHERE
		intScheduledTimeID  	= @intOldScheduledTimeID
		AND intRouteID		= @intOldRouteID

	SET @blnResult = 1
END

SELECT @blnResult



-- --------------------------------------------------------------------------------
-- Step #15:  Call uspSuperEditScheduleRoute with new info
-- --------------------------------------------------------------------------------
SELECT 'uspSuperEditScheduleRoute with changed data' AS 'Step #15'

GO

EXECUTE uspSuperEditScheduleRoute 1, 1, 2, 1, 1

GO

SELECT * FROM TScheduledRoutes
SELECT * FROM TScheduledRouteDrivers



-- --------------------------------------------------------------------------------
-- Step #16:  Call uspSuperEditScheduleRoute with just new Bus ID
-- --------------------------------------------------------------------------------
SELECT 'uspSuperEditScheduleRoute with just new Bus ID' AS 'Step #16' 

--GO

--EXECUTE uspSuperEditScheduleRoute 1, 1, 1, 1, 2

--GO

--SELECT * FROM TScheduledRoutes



-- --------------------------------------------------------------------------------
-- Step #17:  Call uspSuperEditScheduleRoute with invalid data
-- --------------------------------------------------------------------------------
SELECT 'uspSuperEditScheduleRoute with invalid data' AS 'Step #17' 

--GO

--sp_Lock

--GO

--EXECUTE uspSuperEditScheduleRoute 1, 1, 100, 1, 1

--GO

--sp_Lock
