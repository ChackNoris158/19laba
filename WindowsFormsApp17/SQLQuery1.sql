CREATE DATABASE Metlov
ON 
(
    NAME = Metlov_dat,
    FILENAME = 'c:\temp\metlov.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5
)
LOG ON 
(
    NAME = Metlov_log,
    FILENAME = 'c:\temp\metlovlog.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB
);

sp_helpdb Metlov

sp_addumpdevice 'disk', 'backupdisk_metlov', 'c:\temp\metlov.bak'
backup database Metlov to backupdisk_metlov


USE master;
GO

CREATE LOGIN Dota WITH PASSWORD = '158';
GO

USE master;
GO

CREATE USER Dota FOR LOGIN Dota;
GO

USE master;
GO

ALTER SERVER ROLE [dbcreator] ADD MEMBER Dota;
GO


CREATE DATABASE ex5
ON 
(
    NAME = ex5_dat,
    FILENAME = 'C:\TEMP\data1\ex5.mdf',
    SIZE = 5,
    MAXSIZE = 10,
    FILEGROWTH = 20%
)
LOG ON 
(
    NAME = ex5_log,
    FILENAME = 'C:\TEMP\data1\ex5log.ldf',
    SIZE = 2MB,
    MAXSIZE = 5MB,
    FILEGROWTH = 1MB
);

sp_helpdb ex5


ALTER DATABASE ex5
ADD FILEGROUP gf;

ALTER DATABASE ex5
ADD FILE
(
    NAME = YourAdditionalFile,
    FILENAME = 'C:\TEMP\DATA1\OrdersDataFile.ndf',
    SIZE = 2MB,
    MAXSIZE = 5MB,
    FILEGROWTH = 1MB
)
TO FILEGROUP gf;

SELECT 
    name AS 'File Logical Name',
    physical_name AS 'File Physical Path',
    size/128 AS 'File Size in MB',
    max_size/128 AS 'Max File Size in MB',
    growth/128 AS 'File Growth in MB',
    type_desc AS 'File Type',
    data_space_id AS 'Filegroup ID'
FROM sys.master_files
WHERE database_id = DB_ID('ex5');

-- Включение автоматического сжатия данных
-- Включение автоматического сжатия данных для всех таблиц в базе данных
USE ex5;
GO

EXEC sp_MSforeachtable 
@command1 = '
    PRINT ''Enabling PAGE compression for ?''
    ALTER TABLE ? REBUILD WITH (DATA_COMPRESSION = PAGE);
';


USE ex5; 
GO

EXEC sp_spaceused;



-- Сжатие базы данных на 25%
USE ex5; -- Замените на имя вашей базы данных
GO

DBCC SHRINKDATABASE (ex5, 25);

-- Получение сведений о дисковом пространстве, занимаемом базой данных
USE ex5; -- Замените на имя вашей базы данных
GO

EXEC sp_spaceused;


-- Создание полной резервной копии базы данных
BACKUP DATABASE ex5 TO DISK = 'C:\temp\ex5_full.bak';

-- Создание резервной копии журнала транзакций
BACKUP LOG ex5 TO DISK = 'C:\temp\ex51_log.trn';


-- Удаление базы данных
USE master;
GO

DROP DATABASE ex5;

-- Восстановление базы данных из резервной копии
USE master;
GO

RESTORE DATABASE ex5
FROM DISK = 'C:\temp\ex5_full.bak'
WITH REPLACE, RECOVERY;





