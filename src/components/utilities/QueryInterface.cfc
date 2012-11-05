<cfcomponent>
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" output="false" returntype="any" hint="instantiates an object of this class" access="public">
		<cfargument name="datasource" required="true" type="struct">
	
			<cfset variables.datasource = arguments.datasource />

		<cfreturn this />
	</cffunction>

	<cffunction name="getTablePrefix" access="public" output="false" returntype="string">		
		<cfreturn variables.datasource.tablePrefix />
	</cffunction>
	
	<cffunction name="getDBType" access="public" output="false" returntype="string">		
		<cfreturn variables.datasource.type />
	</cffunction>
	
	<cffunction name="makeQuery" access="public" output="false" returntype="any">		
		<cfargument name="query" required="true" type="string">
		<cfargument name="cacheMinutes" required="false" type="numeric" default="-1">
		<cfargument name="returnResult" required="false" type="boolean" default="true">
		
		<cfset var customQuery = ""/>
		<cfset var queryStatement = trim(arguments.query)>
		
		<cfif arguments.cacheMinutes GT -1 AND arguments.returnResult>
			<cfquery name="customQuery" datasource="#variables.datasource.name#"  username="#variables.datasource.username#" password="#variables.datasource.password#" cachedwithin="#createtimespan(0,0,arguments.cacheMinutes,0)#">
			#preserveSingleQuotes(queryStatement)#
			</cfquery>
		<cfelse>
			<cfquery name="customQuery" datasource="#variables.datasource.name#" username="#variables.datasource.username#" password="#variables.datasource.password#">
			#preserveSingleQuotes(queryStatement)#
			</cfquery>
		</cfif>
		
		<cfif arguments.returnResult>
			<cftry>
				<cfreturn customQuery />
				<cfcatch>
					<cfthrow type="mango.queryInterface.NoResultToReturn" 
					message="Tried to return query result when there was no result" 
					detail="Are you sure you want the result returned? Not available for queries performing an insert,update,delete,drop,create,etc. Are you sure you've included all of the necessary function arguments?" />
				</cfcatch>
			</cftry>
		</cfif>
		
	</cffunction>

</cfcomponent>