<cfcomponent name="subscription" hint="Manages subscription">
      
 <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="init" output="false" returntype="any" hint="instantiates an object of this class" access="public">
	<cfargument name="queryInterface" required="true">
		
		<cfset variables.queryInterface = arguments.queryInterface />
		<cfset variables.prefix = arguments.queryInterface.getTablePrefix() />
		
		<cfreturn this />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="create" output="false" hint="Inserts a new record" access="public" returntype="struct">
	<cfargument name="entry_id" required="true" type="UUID" hint="Entry"/>
	<cfargument name="email" required="true" type="string" hint="Email"/>
	<cfargument name="name" required="false" type="string" default="" hint="Name"/>
	<cfargument name="type" required="false" type="string" default="" hint="Type"/>
	<cfargument name="mode" required="false" type="string" default="" hint="Type"/>

	<cfscript>
		var qinsertsubscription = "";
		var returnObj = structnew();
		returnObj["status"] = false;
		returnObj["message"] = "";
	</cfscript>
<!--- @TODO: look for possible sql injection --->
	<cftry>
		<cfsavecontent variable="qinsertsubscription">
			<cfoutput>INSERT INTO #variables.prefix#entry_subscription
					(entry_id,email,name,type,mode)
					VALUES ('#arguments.entry_id#',<!--- length: 35 --->
					 '#arguments.email#', <!--- length:100 --->
					 NULL,
					 '#arguments.type#', <!--- length: 20 --->
					 '#arguments.mode#')<!--- length: 20 --->
			</cfoutput>
		</cfsavecontent>
		
		<cfset variables.queryInterface.makeQuery(qinsertsubscription,0,false) />

		<cfset returnObj["status"] = true/>

		<cfcatch type="Any">
				<cfset returnObj["status"] = false/>
				<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
			</cfcatch>
		</cftry>
	
		<cfif returnObj["status"]>
			<cfset returnObj["message"] = "Insert successful"/>
			<cfset returnObj["data"] = arguments />
		</cfif>

	<cfreturn returnObj/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="delete" output="false" hint="Deletes a record" access="public" returntype="struct">
	<cfargument name="entry_id" required="true" type="string" hint="Entry"/>
	<cfargument name="email" required="true" type="string" hint="Email"/>
	<cfargument name="type" required="false" type="string" default="" hint="Type"/>
    
    <cfscript>
		var qdeletesubscription = "";
		var returnObj = structnew();
		returnObj["status"] = false;
		returnObj["message"] = "";
	</cfscript>

	<cftry>
		<cfsavecontent variable="qdeletesubscription"><cfoutput>
            DELETE FROM #variables.prefix#entry_subscription
			WHERE entry_id = '#arguments.entry_id#' AND
			email = '#arguments.email#' AND
			type = '#arguments.type#'</cfoutput>
		</cfsavecontent>
    	
		<cfset variables.queryInterface.makeQuery(qdeletesubscription,0,false) />
	
		<cfset returnObj["status"] = true/>
		
    	<cfcatch type="Any">
    		<cfset returnObj["status"] = false/>
     	   <cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail />
		</cfcatch>
	</cftry>
    						
	<cfif returnObj["status"]>
    	<cfset returnObj["message"] = "Unsubscribed!"/>
    </cfif>
    
	<cfreturn returnObj/>
</cffunction>

</cfcomponent>