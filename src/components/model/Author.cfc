<cfcomponent displayname="Author" alias="org.mangoblog.model.Author">

	<cfproperty name="id" type="string" default="">
	<cfproperty name="username" type="string" default="">
	<cfproperty name="password" type="string" default="">
	<cfproperty name="name" type="string" default="">
	<cfproperty name="email" type="string" default="">
	<cfproperty name="description" type="string" default="">
	<cfproperty name="shortdescription" type="string" default="">
	<cfproperty name="picture" type="string" default="">
	<cfproperty name="alias" type="string" default="">
	<cfproperty name="blogs" type="array" default="">
	<cfproperty name="active" type="boolean" default="true">
	<cfproperty name="archivesUrlString" type="string" default="">

	<cfscript>
		this.id = "";
		this.username = "";
		this.password = "";
		this.name = "";
		this.email = "";
		this.description = "";
		this.shortdescription = "";
		this.urlString = "";
		this.archivesUrlString = "";
		this.picture = "";
		this.alias = "";
		this.active = true;
		this.blogs = arraynew(1);
	</cfscript>
	
	<cffunction name="init" access="public" returntype="Author" output="false">
		<cfargument name="id" type="string" required="false" default="" />
		<cfargument name="username" type="string" required="false" default="" />
		<cfargument name="password" type="string" required="false" default="" />
		<cfargument name="name" type="string" required="false" default="" />
		<cfargument name="email" type="string" required="false" default="" />
		<cfargument name="description" type="string" required="false" default="" />
		<cfargument name="shortdescription" type="string" required="false" default="" />
		<cfargument name="picture" type="string" required="false" default="" />
		<cfargument name="alias" type="string" required="false" default="" />
		<cfargument name="active" type="boolean" required="false" default="true" />

		<cfscript>
			this.id = arguments.id;
			setUsername(arguments.username);
			setPassword(arguments.password);
			setName(arguments.name);
			setEmail(arguments.email);
			setDescription(arguments.description);
			setShortdescription(arguments.shortdescription);
			setAlias(arguments.alias);
			setpicture(arguments.picture);
			this.active = arguments.active;
		</cfscript>

		<cfreturn this />
 	</cffunction>


	<cffunction name="setId" access="public" returntype="void" output="false">
		<cfargument name="id" type="string" required="true" />
		<cfset this.id = arguments.id />
	</cffunction>
	
	<cffunction name="getId" access="public" returntype="string" output="false">
		<cfreturn this.id />
	</cffunction>

	<cffunction name="setUsername" access="public" returntype="void" output="false">
		<cfargument name="username" type="string" required="true" />
		<cfset this.username = arguments.username />
	</cffunction>
	
	<cffunction name="getUsername" access="public" returntype="string" output="false">
		<cfreturn this.username />
	</cffunction>

	<cffunction name="setPassword" access="public" returntype="void" output="false">
		<cfargument name="password" type="string" required="true" />
		<cfset this.password = arguments.password />
	</cffunction>
	
	<cffunction name="getPassword" access="public" returntype="string" output="false">
		<cfreturn this.password />
	</cffunction>

	<cffunction name="setName" access="public" returntype="void" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfset this.name = arguments.name />
	</cffunction>
	
	<cffunction name="getName" access="public" returntype="string" output="false">
		<cfreturn this.name />
	</cffunction>

	<cffunction name="setEmail" access="public" returntype="void" output="false">
		<cfargument name="email" type="string" required="true" />
		<cfset this.email = arguments.email />
	</cffunction>
	
	<cffunction name="getEmail" access="public" returntype="string" output="false">
		<cfreturn this.email />
	</cffunction>

	<cffunction name="setDescription" access="public" returntype="void" output="false">
		<cfargument name="description" type="string" required="true" />
		<cfset this.description = arguments.description />
	</cffunction>
	
	<cffunction name="getDescription" access="public" returntype="string" output="false">
		<cfreturn this.description />
	</cffunction>
	
		<cffunction name="getShortdescription" output="false" access="public" returntype="any">
		<cfreturn this.Shortdescription>
	</cffunction>

	<cffunction name="setShortdescription" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.Shortdescription = arguments.val>
	</cffunction>
	
	<cffunction name="setUrl" access="public" returntype="void" output="false">
		<cfargument name="urlString" type="string" required="true" />
		<cfset this.urlString = arguments.urlString />
	</cffunction>
	
	<cffunction name="getUrl" access="public" returntype="string" output="false">
		<cfreturn this.urlString />
	</cffunction>
	
	<cffunction name="setArchivesUrl" access="public" returntype="void" output="false">
		<cfargument name="urlString" type="string" required="true" />
		<cfset this.archivesUrlString = arguments.urlString />
	</cffunction>
	
	<cffunction name="getArchivesUrl" access="public" returntype="string" output="false">
		<cfreturn this.archivesUrlString />
	</cffunction>
	
	<cffunction name="getPicture" output="false" access="public" returntype="any">
		<cfreturn this.Picture>
	</cffunction>

	<cffunction name="setPicture" output="false" access="public" returntype="void">
		<cfargument name="picture" required="true">
		<cfset this.picture = arguments.picture>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCurrentRole" output="false" access="public" returntype="any">
		<cfargument name="blogId" type="string" required="false" default="default" />
		
		<!--- this is only in case they set the blogs without using the setter --->
		<cfif NOT structkeyexists(variables, "blogDictionary")>
			<cfset setBlogs(this.blogs) />
		</cfif>
		<cfif structKeyExists(variables.blogDictionary, arguments.blogId)>
			<cfreturn variables.blogDictionary[arguments.blogId].role />
		<cfelse>
			<cfreturn createObject("component","Role") />
		</cfif>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setCurrentRole" output="false" access="public" returntype="void">
		<cfargument name="role" required="true">
		<cfset this.currentRole = arguments.currentRole />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setBlogs" access="public" returntype="void" output="false">
		<cfargument name="blogs" type="array" required="true" />
		<cfset var i = 0 />
		
		<cfset variables.blogDictionary = structnew() />
		
		<cfloop from="1" to="#arraylen(arguments.blogs)#" index="i">
			<cfset variables.blogDictionary[arguments.blogs[i].id] = arguments.blogs[i] />
		</cfloop>
		<cfset this.blogs = arguments.blogs />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getBlogs" access="public" returntype="array" output="false">
		<cfreturn this.blogs />
	</cffunction>

	<cffunction name="getAlias" output="false" access="public" returntype="any">
		<cfreturn this.alias>
	</cffunction>

	<cffunction name="setAlias" output="false" access="public" returntype="void">
		<cfargument name="alias" required="true">
		<cfset this.alias = arguments.alias>
	</cffunction>

	
	<cffunction name="isValidForSave" access="public" returntype="struct" output="false">
		<cfset var returnObj = structnew() />
		<cfset returnObj.status = true />
		<cfset returnObj.errors = arraynew(1) />
		
		<cfif len(this.email) AND NOT isValid("email",this.email)>
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"Email is not valid")/>			
		</cfif>
		<cfif NOT len(this.username)>
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"Username is required")/>			
		</cfif>

		<cfreturn returnObj />
		
	</cffunction>	

	<cffunction name="getInstanceData" access="public" returntype="struct" output="false">
		
		<cfscript>
			var data = structnew();
			data["id"] = this.id;
			data["username"] = this.username;
			data["password"] = this.password;
			data["name"] = this.name;
			data["email"] = this.email;
			data["description"] = this.description;
			data["url"] = this.urlString;
			data["picture"] = this.picture;
			data["alias"] = this.alias;
			data["blogs"] = this.blogs;
		</cfscript>
	
		<cfreturn data />
	</cffunction>	

</cfcomponent>