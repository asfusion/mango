<cfcomponent name="Category" >	

	<cfproperty name="id" type="string" default="">
	<cfproperty name="name" type="string" default="">
	<cfproperty name="title" type="string" default="">
	<cfproperty name="description" type="string" default="">
	<cfproperty name="creationDate" type="date" default="">
	<cfproperty name="parentCategoryId" type="numeric" default="0">
	<cfproperty name="blogId" type="string" default="">
	<cfproperty name="postCount" type="numeric" default="0" />
	<cfproperty name="urlString" type="string" default="" />
	
	<cfscript>
		this.id = "";
		this.name = "";
		this.title = "";
		this.description = "";
		this.creationDate = "";
		this.parentCategoryId = "";
		this.blogId = "";
		this.urlString = "";
		this.postCount = 0;
	</cfscript>

	<cffunction name="init" output="false" returntype="Category" access="public">
		<cfargument name="id" type="string" required="false" default="" />
		<cfargument name="name" type="string" required="false" default="" />
		<cfargument name="title" type="string" required="false" default="" />
		<cfargument name="description" type="string" required="false" default="" />
		<cfargument name="created_on" type="string" required="false" default="" />
		<cfargument name="post_count" type="string" required="false" default="" />
		
		<cfscript>
			this.id = arguments.id;
			this.name = arguments.name;
			this.description = arguments.description;
			this.CreationDate = arguments.created_on;
			this.PostCount = arguments.post_count;
			this.Title = arguments.title;			
			return this;
		</cfscript>
 	</cffunction>


	<cffunction name="setId" access="public" returntype="void" output="false">
		<cfargument name="id" type="string" required="true" />
		<cfset this.id = arguments.id />
	</cffunction>
	<cffunction name="getId" access="public" returntype="string" output="false">
		<cfreturn this.id />
	</cffunction>

	<cffunction name="setName" access="public" returntype="void" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfset this.name = arguments.name />
	</cffunction>
	<cffunction name="getName" access="public" returntype="string" output="false">
		<cfreturn this.name />
	</cffunction>

	<cffunction name="setDescription" access="public" returntype="void" output="false">
		<cfargument name="description" type="string" required="true" />
		<cfset this.description = arguments.description />
	</cffunction>
	<cffunction name="getDescription" access="public" returntype="string" output="false">
		<cfreturn this.description />
	</cffunction>

	<cffunction name="setCreationDate" access="public" returntype="void" output="false">
		<cfargument name="created_on" type="string" required="true" />
		<cfset this.creationDate = arguments.created_on />
	</cffunction>
	<cffunction name="getCreationDate" access="public" returntype="string" output="false">
		<cfreturn this.creationDate />
	</cffunction>
	
	<cffunction name="setTitle" access="public" returntype="void" output="false">
		<cfargument name="title" type="string" required="true" />		
		<cfset this.title = arguments.title />		
	</cffunction>
	
	<cffunction name="getTitle" access="public" returntype="string" output="false">
		<cfreturn this.title />
	</cffunction>
	
	<cffunction name="setPostCount" access="public" returntype="void" output="false">
		<cfargument name="postCount" type="string" required="true" />
		<cfset this.postCount = arguments.postCount />
	</cffunction>
	<cffunction name="getPostCount" access="public" returntype="string" output="false">
		<cfreturn this.postCount />
	</cffunction>
	
	<cffunction name="setUrl" access="public" returntype="void" output="false">
		<cfargument name="url" type="string" required="true" />
		<cfset this.urlString = arguments.url />
	</cffunction>
	<cffunction name="getUrl" access="public" returntype="string" output="false">
		<cfreturn this.urlString />
	</cffunction>
	
	<cffunction name="getBlogId" output="false" access="public" returntype="any">
		<cfreturn this.blogId>
	</cffunction>

	<cffunction name="setBlogId" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.blogId = arguments.val>
	</cffunction>
	
	<cffunction name="getParentCategoryId" output="false" access="public" returntype="any">
		<cfreturn this.parentCategoryId>
	</cffunction>

	<cffunction name="setParentCategoryId" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset this.parentCategoryId = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>	
	
	<cffunction name="isValidForSave" access="public" returntype="struct" output="false">
		<cfset var returnObj = structnew() />
		<cfset returnObj.status = true />
		<cfset returnObj.errors = arraynew(1) />
		
		<cfif NOT len(this.title)>
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"Title is required")/>			
		</cfif>
		<cfif NOT len(this.name)>
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"Name is required")/>			
		</cfif>

		<cfreturn returnObj />
		
	</cffunction>		
	
	<cffunction name="getInstanceData" access="public" returntype="struct" output="false">
		
		<cfscript>
			var data = structnew();
			data["id"] = this.id;
			data["name"] = this.name;
			data["url"] = this.urlString;
			data["description"] = this.description;
			data["creationDate"] = this.creationDate;
			data["title"] = this.title;
			data["postCount"] = this.postCount;
			data["blogId"] = this.blogId;
			data["parentCategoryId"] = this.parentCategoryId;
		</cfscript>
	
		<cfreturn data />
	</cffunction>	

</cfcomponent>