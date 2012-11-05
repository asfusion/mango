<!--- This is the CF7, CF8 installation of Datasources --->
	<cfset var sClassName = "" />
	<cfset var sPort      = "" />
	
<cftry>
	<cfadmin 
		action="getDatasources"
		type="web"
		password="#arguments.cfadminpassword#"
		returnVariable="datasources">

	<cfset dsExists = ListFindNoCase(ValueList(datasources.name), arguments.datasourcename)>
	<cfif dsexists>
		<cfthrow type="duplicateDatasource" message="Datasource already exists">
	</cfif>

	<cfif arguments.dbType EQ "mssql" OR arguments.dbType EQ "mssql_2005">
		<cfset var sClassName="com.microsoft.jdbc.sqlserver.SQLServerDriver">
		<cfset var sPort = "1433">
		<cfset var sDSN  = "jdbc:sqlserver://{host}:{port}">

	<cfelseif arguments.dbType EQ "mysql">
		<cfset var sClassName="org.gjt.mm.mysql.Driver">
		<cfset var sPort = "3306">
		<cfset var sDSN  = "jdbc:mysql://{host}:{port}/{database}">
	</cfif>

	<cfadmin 
		action="updateDatasource"
		type="web"
		password="#arguments.cfadminpassword#"
		name = "#arguments.datasourcename#"
		dsn = "#sDSN#"
		host = "#arguments.host#"
		database = "#arguments.dbName#"
		dbusername = "#arguments.username#"
		dbpassword = "#arguments.password#"
		classname = "#sClassName#"
		port = "#sPort#"
		connectionLimit = -1
		connectionTimeout = 1
		blob = "true"
		clob = "true"
		allowed_select = "true"
		allowed_insert = "true"
		allowed_update = "true"
		allowed_delete = "true"
		allowed_alter = "true"
		allowed_drop = "true"
		allowed_revoke = "true"
		allowed_create = "true"
		allowed_grant = "true"
		custom="#structNew()#">
	
	<cftry>
		<cfadmin 
			action="verifyDatasource"
			type="web"
			password="#arguments.cfadminpassword#"
			name="#arguments.datasourcename#"
			dbusername = "#arguments.username#"
			dbpassword = "#arguments.password#">
		<cfset result.status=true>
		<cfcatch>
			<!--- Roll back --->
			<cfadmin 
				action="removeDatasource"
				type="web"
				password="#arguments.cfadminpassword#"
				name="#arguments.datasourcename#">
		</cfcatch>
	</cftry>
<cfcatch type="any">
	<cfset result.message =  cfcatch.Message &   " " & cfcatch.Detail />
</cfcatch>
</cftry>
