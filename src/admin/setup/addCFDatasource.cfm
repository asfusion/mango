<!--- This is the CF7, CF8 installation of Datasources --->
<cftry>
		<cfscript>
			 // Login to CF Administrator
			createObject("component","cfide.adminapi.administrator").login(arguments.cfadminpassword);
			 // Instantiate the data source object
			dsObj = createObject("component","cfide.adminapi.datasource");
		</cfscript>
		


		<cftry>
			<!--- make sure it does not exist --->
			<cfset dsObj.getDatasources(arguments.datasourcename) />
			<!--- if it doesn't throw error, it already exists' --->
			<cfcatch type="any">
				<!--- everything fine --->
				<cfset dsexists = false />
			</cfcatch>
		</cftry>
		<cfif dsexists>
			<cfthrow type="duplicateDatasource" message="Datasource already exists">
		</cfif>
		
		<cfscript>
			dsn = structNew();
			dsn.name= arguments.datasourcename;
			dsn.host = arguments.host;					
			dsn.database = arguments.dbName;
			dsn.username = arguments.username;
			dsn.password = arguments.password;
			
			if (arguments.dbType EQ "mssql" OR arguments.dbType EQ "mssql_2005"){
				//Create it
  					dsObj.setMSSQL(argumentCollection=dsn);
			}
			else if (arguments.dbType EQ "mysql"){
				//Create it
  					dsObj.setMySQL5(argumentCollection=dsn);
			}
			
			//verify it:
			result.status= dsObj.verifyDsn(arguments.datasourcename);
			if (NOT result.status){// roll back changes
				dsObj.deleteDatasource(arguments.datasourcename);
				result.message = "Datasource could not be verified, please check the settings";
			}
		</cfscript>

<cfcatch type="cfadminapiSecurityError">
	<cfset result.message = "Could not login to CF Administrator" />
</cfcatch>
<cfcatch type="duplicateDatasource">
	<cfset result.message = cfcatch.Message />
</cfcatch>
<cfcatch type="any">
	<cfset result.message =  cfcatch.Message &   " " & cfcatch.Detail />
</cfcatch>
</cftry>
