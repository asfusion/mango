<cfcomponent displayname="AuthorArchive" extends="Archive">

<cfset this.type = "author">

	<cffunction name="init" access="public" returntype="" output="false">
		<cfargument name="type" type="string" required="false" default="" />
		<cfargument name="title" type="string" required="false" default="" />
		<cfargument name="postCount" type="string" required="false" default="" />
		<cfargument name="author" type="Author" required="true" />

		<cfscript>
			setCategory(arguments.category);
			super.init(argumentcollection=arguments);
		</cfscript>

		<cfreturn this />
 	</cffunction>

	<cffunction name="setAuthor" access="public" returntype="void" output="false">
		<cfargument name="author" type="Author" required="true" />
		<cfset this.author = arguments.author />
		<!--- make url --->
		<cfset setUrl(arguments.author.getId()) />
		<cfset setTitle(arguments.author.getName()) />
	</cffunction>
	
	<cffunction name="getAuthor" access="public" returntype="Author" output="false">
		<cfreturn this.author />
	</cffunction>

</cfcomponent>