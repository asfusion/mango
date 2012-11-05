<cfcomponent displayname="Archive">
		
	<cfset this.urlString = "" />	
	<cfset this.type = "" />
	<cfset this.title = "" />
	<cfset this.postCount = -1 />
	<cfset this.pageSize = 0 />
	

	<cffunction name="init" access="public" returntype="" output="false">
		<cfargument name="type" type="string" required="false" default="" />
		<cfargument name="title" type="string" required="false" default="" />
		<cfargument name="postCount" type="string" required="false" default="" />

		<cfscript>
			setType(arguments.type);
			setTitle(arguments.title);
			setPostCount(arguments.postCount);
		</cfscript>

		<cfreturn this />
 	</cffunction>


	<cffunction name="setType" access="public" returntype="void" output="false">
		<cfargument name="type" type="string" required="true" />
		<cfset this.type = arguments.type />
	</cffunction>
	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfreturn this.type />
	</cffunction>

	<cffunction name="setTitle" access="public" returntype="void" output="false">
		<cfargument name="title" type="string" required="true" />
		<cfset this.title = arguments.title />
	</cffunction>
	<cffunction name="getTitle" access="public" returntype="string" output="false">
		<cfreturn this.title />
	</cffunction>

	<cffunction name="setPageSize" access="public" returntype="void" output="false">
		<cfargument name="pageSize" type="numeric" required="true" />
		<cfset this.pageSize = arguments.pageSize />
	</cffunction>
	<cffunction name="getPageSize" access="public" returntype="numeric" output="false">
		<cfreturn this.pageSize />
	</cffunction>

	<cffunction name="setPostCount" access="public" returntype="void" output="false">
		<cfargument name="postCount" type="string" required="true" />
		<cfset this.postCount = arguments.postCount />
	</cffunction>
	<cffunction name="getPostCount" access="public" returntype="string" output="false">
		<cfreturn this.postCount />
	</cffunction>

<cffunction name="setUrl" access="public" returntype="void" output="false">
		<cfargument name="urlString" type="string" required="true" />
		<cfset this.urlString = arguments.urlString />
	</cffunction>
	<cffunction name="getUrl" access="public" returntype="string" output="false">
		<cfreturn this.urlString />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="clone" access="public" returntype="Archive" output="false">
		<cfargument name="myClone" required="false" default="#createObject('component','Archive')#">
		
		<cfscript>
	
			arguments.myClone.urlString = this.urlString;
			arguments.myClone.type = this.type;
			arguments.myClone.title = this.title;
			arguments.myClone.postCount = this.postCount;
			arguments.myClone.pageSize = this.pageSize;
			
			return  arguments.myClone;
		</cfscript>
	</cffunction>	

</cfcomponent>