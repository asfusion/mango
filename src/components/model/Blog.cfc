<cfcomponent name="Blog">
	
	<cfproperty name="id" type="numeric" default="0">
	<cfproperty name="title" displayname="title" type="string" />
	<cfproperty name="url" displayname="url" hint="Address" type="string" />
	<cfproperty name="description" hint="Description" type="string" />
	<cfproperty name="tagline" hint="Tagline" type="string" />
	<cfproperty name="skin" hint="Current skin" type="string" />
	<cfproperty name="basePath" hint="Base path from root" type="string" />
	<cfproperty name="plugins" hint="List of active plugins" type="string" />
	<cfproperty name="systemplugins" hint="List of active system plugins" type="string" />
	
	<cfset this.id =  ""/>
	<cfset this.title = "" />
	<cfset this.url = "" />
	<cfset this.description = "" />
	<cfset this.tagline = "" />
	<cfset this.skin = "" />
	<cfset this.basePath = "" />
	<cfset this.charset = "" />
	<cfset this.plugins = "" />
	<cfset this.systemplugins = "" />
	<cfset this.settings = structnew() />

	<cffunction name="init" hint="Constructor" access="public" output="false" returntype="any">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getId" output="false" access="public" returntype="string">
		<cfreturn this.id>
	</cffunction>

	<cffunction name="setId" output="false" access="public" returntype="void">
		<cfargument name="val" required="true" type="string">
			<cfset this.id = arguments.val>
	</cffunction>


	<cffunction name="getTitle" access="public" output="false" returntype="string">
		<cfreturn this.title />
	</cffunction>

	<cffunction name="setTitle" access="public" output="false" returntype="void">
		<cfargument name="title" type="string" required="true" />
		<cfset this.title = arguments.title />
		<cfreturn />
	</cffunction>

	<cffunction name="getUrl" access="public" output="false" returntype="string">
		<cfreturn this.url />
	</cffunction>

	<cffunction name="setUrl" access="public" output="false" returntype="void">
		<cfargument name="url" type="string" required="true" />
		<cfset this.url = arguments.url />
		<cfreturn />
	</cffunction>

	<cffunction name="getSkin" access="public" output="false" returntype="string">
		<cfreturn this.skin />
	</cffunction>

	<cffunction name="setSkin" access="public" output="false" returntype="void">
		<cfargument name="skin" type="string" required="true" />
		<cfset this.skin = arguments.skin />
		<cfreturn />
	</cffunction>
	
	<cffunction name="getBasePath" access="public" output="false" returntype="string">
		<cfreturn this.basePath />
	</cffunction>

	<cffunction name="setBasePath" access="public" output="false" returntype="void">
		<cfargument name="basePath" type="string" required="true" />
		<cfset this.basePath = arguments.basePath />
		<cfreturn />
	</cffunction>	

	<cffunction name="getDescription" access="public" output="false" returntype="string">
		<cfreturn this.description />
	</cffunction>

	<cffunction name="setDescription" access="public" output="false" returntype="void">
		<cfargument name="description" type="string" required="true" />
		<cfset this.description = arguments.description />
		<cfreturn />
	</cffunction>

	<cffunction name="getTagline" access="public" output="false" returntype="string">
		<cfreturn this.tagline />
	</cffunction>

	<cffunction name="setTagline" access="public" output="false" returntype="void">
		<cfargument name="tagline" type="string" required="true" />
		<cfset this.tagline = arguments.tagline />
		<cfreturn />
	</cffunction>


	<cffunction name="getCharset" access="public" output="false" returntype="string">
		<cfreturn this.charset />
	</cffunction>

	<cffunction name="setCharset" access="public" output="false" returntype="void">
		<cfargument name="charset" type="string" required="true" />
		<cfset this.charset = arguments.charset />
		<cfreturn />
	</cffunction>

	<cffunction name="getPlugins" access="public" output="false" returntype="string">
		<cfreturn this.plugins />
	</cffunction>

	<cffunction name="setPlugins" access="public" output="false" returntype="void">
		<cfargument name="plugins" type="string" required="true" />
		<cfset this.plugins = arguments.plugins />
		<cfreturn />
	</cffunction>
	
	<cffunction name="getSystemPlugins" access="public" output="false" returntype="string">
		<cfreturn this.systemplugins />
	</cffunction>

	<cffunction name="setSystemPlugins" access="public" output="false" returntype="void">
		<cfargument name="plugins" type="string" required="true" />
		<cfset this.systemplugins = arguments.plugins />
		<cfreturn />
	</cffunction>


	<cffunction name="getSetting" access="public" output="false" returntype="any">
		<cfargument name="name" type="string" required="true" />
		
			<cfif structkeyexists(this.settings,arguments.name)>
				<cfreturn this.settings[arguments.name] />
			<cfelse>
				<cfreturn "" />
			</cfif>
		
	</cffunction>

	<cffunction name="setSetting" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="value" type="string" required="true" />
		<cfset this.settings[arguments.name] = arguments.value />
		
		<!--- set some defaults in case they are empty --->
		<cfif arguments.name EQ "skins" AND NOT len(this.settings.skins.path)>
			<cfset this.settings.skins.path = this.basePath & "skins/" />
		</cfif>
		<cfif arguments.name EQ "skins" AND NOT len(this.settings.skins.url)>
			<cfset this.settings.skins.url = this.settings.skins.path />
		</cfif>
		<cfif arguments.name EQ "urls" AND NOT len(this.settings.urls.admin)>
			<cfset this.settings.urls.admin = this.basePath & "admin/" />
		</cfif>
	</cffunction>

	<cffunction name="setSettings" access="public" output="false" returntype="void">
		<cfargument name="settings" type="struct" required="true" />
		
		<cfset var thisSetting = ""/>
		<cfset this.settings = arguments.settings />
		
		<!--- set some defaults in case they are empty --->
		<cfif structkeyexists(this.settings,"skins") AND NOT len(this.settings.skins.path)>
			<cfset this.settings.skins.path = this.basePath & "skins/" />
		</cfif>
		<cfif structkeyexists(this.settings,"skins") AND NOT len(this.settings.skins.url)>
			<cfset this.settings.skins.url = this.settings.skins.path />
		</cfif>
		<cfif structkeyexists(this.settings,"urls") AND NOT len(this.settings.urls.admin)>
			<cfset this.settings.urls.admin = this.basePath & "admin/" />
		</cfif>
	</cffunction>
	

<cffunction name="isValidForSave" access="public" returntype="struct" output="false">
		<cfset var returnObj = structnew() />
		<cfset returnObj.status = true />
		<cfset returnObj.errors = arraynew(1) />
		
		<cfreturn returnObj />
		
	</cffunction>	
	
	<cffunction name="getHost" access="public" output="false" returntype="string">
		<cfset var host = this.url />
		<cfif findnocase(this.basePath,this.url)>
			<cfset host = left(this.url,len(this.url) - len(this.basePath)) />		
		</cfif>
		<cfset host = replacenocase(host,"http://","")>
		<cfset host = replacenocase(host,"https://","")>
		<cfreturn host />
	</cffunction>

	<cffunction name="clone" access="public" returntype="any" output="false">
		<cfargument name="myClone" required="false" default="#createObject('component','Blog')#">
		
		<cfscript>
			arguments.myClone.Id = this.id;
			arguments.myClone.Title = this.title;
			arguments.myClone.Skin = this.skin;
			arguments.myClone.Url = this.url;
			arguments.myClone.BasePath = this.basePath;
			arguments.myClone.Description = this.description;
			arguments.myClone.Tagline = this.tagline;
			arguments.myClone.Charset = this.charset;
			arguments.myClone.Settings = this.settings;
		</cfscript>
		<cfreturn arguments.myClone />
	</cffunction>

	<cffunction name="getInstanceData" access="public" returntype="struct" output="false">
		
		<cfscript>
			var data = structnew();
			data["id"] = this.id;
			data["title"] = this.title;
			data["url"] = this.url;
			data["skin"] = this.skin;
			data["basePath"] = this.basePath;
			data["description"] = this.description;
			data["tagline"] = this.tagline;
			data["charset"] = this.charset;
			data["settings"] = this.settings;
		</cfscript>
	
		<cfreturn data />
	</cffunction>	

</cfcomponent>