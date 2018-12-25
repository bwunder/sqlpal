USE [master]
RESTORE DATABASE [WideWorldImporters]
[WWI_InMemory_Data]
FROM DISK = '/var/opt/mssql/backup/WideWorldImporters-FULL.bak'
WITH MOVE 'WWI_Primary' TO '/var/opt/mssql/data/WideWorldImporters.mdf',
  MOVE 'WWI_UserData' TO '/var/opt/mssql/data/WideWorldImporters_UserData.ndf',
  MOVE 'WWI_Log' TO '/var/opt/mssql/data/WideWorldImporters.ldf', 
  MOVE 'WWI_InMemory_Data_1' TO 'var/opt/mssql/data/WideWorldImporters_InMemory_Data_1'