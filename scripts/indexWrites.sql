SELECT OBJECT_NAME(i.[object_id]) AS [ObjectName], i.[name] AS [IndexName], i.index_id,
	   s.user_updates AS [Writes], s.user_seeks + s.user_scans + s.user_lookups AS [Total Reads],
	   i.[type_desc] AS [Index Type], i.fill_factor AS [Fill Factor], i.has_filter, i.filter_definition,
	   s.last_system_update, s.last_user_update
FROM sys.indexes AS i WITH (NOLOCK)
LEFT OUTER JOIN sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
ON i.[object_id] = s.[object_id]
AND i.index_id = s.index_id
AND s.database_id = DB_ID()
WHERE OBJECTPROPERTY(i.[object_id],'IsUserTable') = 1
ORDER BY s.user_updates DESC OPTION (RECOMPILE);
