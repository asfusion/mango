<cfcomponent name="subscription" hint="Gateway for subscription">

 <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="init" output="false" returntype="any" hint="instantiates an object of this class" access="public">
	<cfargument name="queryInterface" required="true">
		
		<cfset variables.queryInterface = arguments.queryInterface />
		<cfset variables.prefix = arguments.queryInterface.getTablePrefix() />
		
		<cfreturn this />
</cffunction>

	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByEntry" output="false" access="public" returntype="query">
		<cfargument name="entry_id" required="true" type="string" hint="Entry"/>
		<cfargument name="type" required="false" type="string" default="" hint="Type"/>
		<cfargument name="mode" required="false" type="string" default="" hint="Type"/>

	<cfset var q_subscription = "" />
	<cfsavecontent variable="q_subscription">
		<cfoutput>SELECT	*
		FROM	#variables.prefix#entry_subscription
		WHERE entry_id = '#arguments.entry_id#'
		<cfif len(arguments.type)>
			AND type = '#arguments.type#'	
		</cfif>
		<cfif len(arguments.mode)>
			AND mode = '#arguments.mode#'		
		</cfif></cfoutput>
	</cfsavecontent>

	<cfreturn variables.queryInterface.makeQuery(q_subscription) />
</cffunction>

	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByemail" output="false" access="public" returntype="query">
	<cfargument name="email" required="true" type="string" hint="Email"/>
	<cfargument name="mode" required="false" type="string" default="" hint="Type"/>
	
	<cfset var q_subscription = "" />
	
	<cfsavecontent variable="q_subscription">
		<cfoutput>
		SELECT	*
		FROM	#variables.prefix#entry_subscription
		WHERE email = '#arguments.email#'
		<cfif len(arguments.mode)>
			AND mode = '#arguments.mode#'
		</cfif>
	</cfoutput>
	</cfsavecontent>

	<cfreturn variables.queryInterface.makeQuery(q_subscription) />
</cffunction>

	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getBytype" output="false" access="public" returntype="query">
		<cfargument name="type" required="true" type="string" default="" hint="Type"/>

	<cfset var q_subscription = "" />
	
	<cfsavecontent variable="q_subscription">
		<cfoutput>
		SELECT	*
		FROM	#variables.prefix#entry_subscription
		WHERE type = '#arguments.type#'
	</cfoutput>
	</cfsavecontent>

	<cfreturn variables.queryInterface.makeQuery(q_subscription) />
</cffunction>

 
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByMode" output="false" access="public" returntype="query">
	<cfargument name="mode" required="true" type="string" default="" hint="Type"/>

	<cfset var q_subscription = "" />
	
	<cfsavecontent variable="q_subscription">
		<cfoutput>
		SELECT	*
		FROM	#variables.prefix#entry_subscription
		WHERE mode = '#arguments.mode#'
		ORDER BY email, entry_id
	</cfoutput>
	</cfsavecontent>

	<cfreturn variables.queryInterface.makeQuery(q_subscription) />
</cffunction>


 <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

 <cffunction name="search" output="false" hint="Search for subscription matching the criteria" access="public" returntype="query">
	<cfargument name="entry_id" required="false" default="" type="string" hint="Entry"/>
	<cfargument name="email" required="false" default="" type="string" hint="Email"/>
	<cfargument name="type" required="false" type="string" default="" hint="Type"/>
			 
	<cfset var q_subscription = "" />
	
	<cfsavecontent variable="q_subscription">
		<cfoutput>
		SELECT	*
		FROM	#variables.prefix#entry_subscription
		WHERE	0=0
	<cfif len(arguments.type)>
		AND type = '#arguments.type#'
	</cfif>
	<cfif len(arguments.entry_id)>
		AND entry_id =  '#arguments.entry_id#'
	</cfif>
	<cfif len(arguments.email)>
		AND email = '#arguments.email#'
	</cfif>
	ORDER BY entry_id, email, type
	</cfoutput>
	</cfsavecontent>

	<cfreturn variables.queryInterface.makeQuery(q_subscription) />

   </cffunction>

</cfcomponent>