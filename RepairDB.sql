
/****** BY ADNANE ARHARBI  ******/


Declare @table nvarchar(50)
Declare @cnt int=0
Declare @i int=1
Declare @database_id int=0
Declare @DatabaseName varchar(20)
Declare @sql nvarchar(2000) 
--Vérifier les noms des bases de données 
/*
SELECT
    DatabaseName = [d].[name] ,
    [d].[create_date] ,
    [d].[compatibility_level] ,
    [d].[collation_name],
	d.database_id
FROM master.sys.databases d where d.database_id >4
*/

SELECT @cnt=count(d.database_id) FROM master.sys.databases d where d.database_id >4
--SELECT top 1  @database_id=d.database_id FROM master.sys.databases d where d.database_id >5 order by database_id asc

WHILE (@i<=@cnt)
BEGIN
	SELECT top 1  @DatabaseName=[d].[name] FROM master.sys.databases d where d.database_id >5  and d.database_id = @i+4
	IF (@DatabaseName !='')
	BEGIN
		SET @table=@DatabaseName 
		SET @sql= 'ALTER DATABASE '+  @table +' SET EMERGENCY; ALTER DATABASE '+ @table +' set single_user; DBCC CHECKDB ('+@table+', REPAIR_ALLOW_DATA_LOSS) WITH ALL_ERRORMSGS;  ALTER DATABASE '+ @table +' set multi_user;  ';
		--print @sql
		EXECUTE  sp_executesql @sql
	END
	SET @i=@i+1
END
