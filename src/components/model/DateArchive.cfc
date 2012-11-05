<cfcomponent displayname="DateArchive" extends="Archive">

	<cfset this.day = 0 />
	<cfset this.month = 0 />
	<cfset this.year = 0 />
	<cfset this.type = "date">

	<cffunction name="init" access="public" returntype="" output="false">
		<cfargument name="title" type="string" required="false" default="" />
		<cfargument name="postCount" type="string" required="false" default="" />
		<cfargument name="year" type="string" required="false" default="" />
		<cfargument name="month" type="string" required="false" default="" />
		<cfargument name="day" type="string" required="false" default="" />

		<cfscript>
			setYear(arguments.year);
			setMonth(arguments.month);
			setDay(arguments.day);
			arguments.type = this.type;
			super.init(argumentcollection=arguments);
		</cfscript>

		<cfreturn this />
 	</cffunction>

	<cffunction name="setYear" access="public" returntype="void" output="false">
		<cfargument name="year" type="string" required="true" />
		<cfset this.year = arguments.year />
		<cfset formatTitle() />
		<cfset formatUrl() />
	</cffunction>
	<cffunction name="getYear" access="public" returntype="string" output="false">
		<cfreturn this.year />
	</cffunction>

	<cffunction name="setMonth" access="public" returntype="void" output="false">
		<cfargument name="month" type="string" required="true" />
		<cfset this.month = arguments.month />
		<cfset formatTitle() />
		<cfset formatUrl() />
	</cffunction>
	<cffunction name="getMonth" access="public" returntype="string" output="false">
		<cfreturn this.month />
	</cffunction>

	<cffunction name="setDay" access="public" returntype="void" output="false">
		<cfargument name="day" type="string" required="true" />
		<cfset this.day = arguments.day />
		<cfset formatTitle() />
		<cfset formatUrl() />
	</cffunction>
	
	<cffunction name="getDay" access="public" returntype="string" output="false">
		<cfreturn this.day />
	</cffunction>
	
	<cffunction name="getFormattedTitle" access="public" returntype="string" output="false">
		<cfargument name="format" type="string" required="true" />
		
		<cfset var m = this.month />
		<cfset var y = this.year />
		<cfset var d =  this.day />
		
		<cfif m EQ 0>
			<cfset m = 1>
		</cfif>
		<cfif d EQ 0>
			<cfset d = 1>
		</cfif>
		<cfif y EQ 0>
			<cfset y = 1>
		</cfif>
		
		<cfreturn lsdateformat(createdate(y,m,d),arguments.format) />
	</cffunction>
	
	<cffunction name="formatTitle" access="public" returntype="void" output="false">
		<cfset this.title = "" />
		<cfif this.year NEQ 0>
			<cfset this.title = this.year>
		</cfif>
		<cfif this.month NEQ 0>
			<cfset this.title = this.month & "-" & this.title>
		</cfif>
		<cfif this.day NEQ 0>
			<cfset this.title = this.day & "-" & this.title>
		</cfif>
	</cffunction>

	<cffunction name="formatUrl" access="public" returntype="void" output="false">
		
		<cfif this.year NEQ 0>
			<cfset setUrl(this.year)>
		</cfif>
		<cfif this.month NEQ 0>
			<cfset setUrl(this.urlString & "/" & this.month) />
		</cfif>
		<cfif this.day NEQ 0>
			<cfset setUrl(this.urlString & "/" & this.day) />
		</cfif>
	</cffunction>

</cfcomponent>