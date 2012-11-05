<cfcomponent displayname="SearchArchive" extends="Archive">

<cfset this.type = "search">

	<cffunction name="init" access="public" returntype="" output="false">
		<cfargument name="type" type="string" required="false" default="" />
		<cfargument name="title" type="string" required="false" default="" />
		<cfargument name="postCount" type="string" required="false" default="" />
		<cfargument name="keyword" type="string" required="true" />

		<cfscript>
			super.init(argumentcollection=arguments);
		</cfscript>

		<cfreturn this />
 	</cffunction>


	<cffunction name="setKeyword" access="public" returntype="void" output="false">
		<cfargument name="keyword" type="string" required="true" />
		<cfset this.keyword = arguments.keyword />
	</cffunction>
	
	<cffunction name="getKeyword" access="public" returntype="string" output="false">
		<cfreturn this.keyword />
	</cffunction>

</cfcomponent>