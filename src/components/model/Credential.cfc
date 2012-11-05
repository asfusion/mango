<cfcomponent alias="org.mangoblog.model.Credential" 
			hint="This class is used to handle external authentication. The 
				external authentication mechanism should provide a user of this class">

	<cfproperty name="username" type="string" default="">
	<cfproperty name="password" type="string" default="">
	<cfproperty name="name" type="string" default="">
	<cfproperty name="email" type="string" default="">
	<cfproperty name="permissions" type="string" default="">
	<cfproperty name="roleId" type="string" default="">
	<cfproperty name="preferences" type="struct">
	<cfproperty name="isAuthorized" type="boolean" default="false">

	<cfscript>
		//this must be unique and it is required
		this.username = "";
		//if you wish to set the password in this install's database, set it to other than ''
		// (passwords stored in the database are always hashed)
		this.password = "";
		//full name of the user, not required. If not passed, then username will be used as full name
		this.name = "";
		//user email, it is not completely required, but if not passed, 
		// user will not be able to receive email notifications, and comments
		// will not show as author comments. Strongly recommended
		this.email = "";
		//list of permissions this user has. Either this or roleId is required
		// if both sent empty, the user will be able to login,
		// but he/she won't be able to do anything
		this.permissions = "";
		//roleId as defined in this install's db. Use only if you know the ids and you
		// are sure the ids won't change (roles cannot be deleted from admin, 
		//but their id can change if name changes)
		// you can also use the roleManager to get the role id by a list of
		// permissions
		//roleId will take precedence over the list of permissions if role is found
		this.roleId = "";
		// preferences if any. If structure is empty, then the
		// default preferences for the current role will be assigned
		this.preferences = structnew();
		//you must set this to true if you wish the user to let into the admin
		this.isAuthorized = false;
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="username" type="string" required="true" hint="this must be unique and it is required" />
		<cfargument name="password" type="string" required="false" default="" 
					hint="if you wish to set the password in this install's database, set it to other than ''" />
		<cfargument name="name" type="string" required="false" default="" 
					hint="full name of the user, not required. If not passed, then username will be used as full name" />
		<cfargument name="email" type="string" required="false" default="" 
					hint="user email, it is not completely required, but if not passed, 
						user will not be able to receive email notifications, and comments
						will not show as author comments. Strongly recommended" />
		<cfargument name="permissions" type="string" required="false" default="" 
					hint="list of permissions this user has. Either this or roleId is required
						if both sent empty, the user will be able to login,
							but he/she won't be able to do anything" />
		<cfargument name="roleId" type="string" required="false" default=""
					hint="roleId as defined in this install's db. Use only if you know the ids and you 
						are sure the ids won't change (roles cannot be delete from admin, so 
							there is not a lot of risk of them changing)" />
		<cfargument name="preferences" type="struct" required="false" default="#structnew()#" 
					hint="preferences if any. If structure is empty, then the 
						default preferences for the current role will be assigned" />

		<cfscript>
			setUsername(arguments.username);
			setPassword(arguments.password);
			setName(arguments.name);
			setEmail(arguments.email);
			setPermissions(arguments.permissions);
			setRoleId(arguments.roleId);
			setPreferences(arguments.preferences);
		</cfscript>

		<cfreturn this />
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

	<cffunction name="setPermissions" access="public" returntype="void" output="false">
		<cfargument name="permissions" type="string" required="true" />
		<cfset this.permissions = arguments.permissions />
	</cffunction>
	
	<cffunction name="getPermissions" access="public" returntype="string" output="false">
		<cfreturn this.permissions />
	</cffunction>

	
	<cffunction name="setRoleId" access="public" returntype="void" output="false">
		<cfargument name="roleId" type="string" required="true" />
		<cfset this.roleId = arguments.roleId />
	</cffunction>
	
	<cffunction name="getRoleId" access="public" returntype="string" output="false">
		<cfreturn this.roleId />
	</cffunction>


	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setPreferences" access="public" returntype="void" output="false">
		<cfargument name="preferences" type="struct" required="true" />
		<cfset this.preferences = arguments.preferences />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPreferences" access="public" returntype="struct" output="false">
		<cfreturn this.preferences />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setIsAuthorizer" access="public" returntype="void" output="false">
		<cfargument name="isAuthorized" type="boolean" required="true" />
		<cfset this.isAuthorized = arguments.isAuthorized />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getIsAuthorizer" access="public" returntype="boolean" output="false">
		<cfreturn this.isAuthorized />
	</cffunction>
</cfcomponent>