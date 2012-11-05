<cfcomponent displayname="Application">
	<cfscript>
		this.name = "mango_#right(hash(GetDirectoryFromPath(GetCurrentTemplatePath())),50)#_v1_6";
		this.setclientcookies="yes";
		this.sessionmanagement="yes";
		this.sessiontimeout= CreateTimeSpan(0,0,60,0);

		//do this for CF7
		this.mappings = structnew();
		//do this for CF 8
		this.mappings['/org/mangoblog'] = GetDirectoryFromPath(GetCurrentTemplatePath()) & "components";
		
		if (listFirst(server.coldfusion.productversion) gte 8) {
			//this is a cf8 or compatible engine, so use the mapping
			variables.componentsPath = "org.mangoblog.";
		}
		else {
			variables.componentsPath = "components.";
		}
	</cfscript>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="OnApplicationStart" output="false">
		<cfset var facade = ""/>
		<cftry>
			<cfset createObject("component", variables.componentsPath & "utilities.Preferences") />
			<cfcatch type="any">
				<!--- if we catch a problem, it means there was a problem finding the path --->
				<cfset variables.componentsPath = 
						replace(replacenocase(replacenocase(cgi.script_name,ListLast(cgi.script_name,"/"),''),'admin/',''),"/",".",'all') 
							& "components." />
				<cfset variables.componentsPath = right(variables.componentsPath,len(variables.componentsPath)-1) />
		</cfcatch>
		</cftry>
		
		<cftry>
			<cfset facade = createobject("component",variables.componentsPath & "MangoFacade") />
			<cfset application.blogFacade = facade.init(getDirectoryFromPath(GetCurrentTemplatePath()) & "config.cfm", getDirectoryFromPath(getCurrentTemplatePath())) />
			
			<cfcatch type="MissingConfigFile">
				<cflocation URL="admin/setup/setup.cfm" addtoken="false">
			</cfcatch>
		</cftry>
	</cffunction>
	

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="onRequestStart" returnType="boolean" output="true">
		<cfargument type="String" name="targetPage" required="true" />
			
			<cfset var isAdmin = false />
			<cfset var isAuthor = false />
			<cfset var blog = "" />
			<cfparam name="form" default="#structnew()#">
			
			<cfif structkeyexists(cgi,"CONTENT_TYPE") AND cgi["CONTENT_TYPE"] EQ "application/x-amf">
				<cfset StructDelete(this,"onError") />
			</cfif>
			
			<cftry>
				<cfset request.blogManager = application.blogFacade.getMango()/>
				<cfcatch type="database">
					<cfset StructDelete(this,"onError") />
					<cfset request.message = createObject("component",variables.componentsPath & "Message") />
					<cfset request.message.setTitle("Database error: " & cfcatch.Detail) />
					<cfset request.message.setText(cfcatch.Message) />
					<cfset request.message.setStatus("error") />
				
					<cfheader statuscode="500" statustext="Internal Server Error"/>
					<cfsetting enablecfoutputonly="false">
					<cfinclude template="error.cfm">
					<cfabort>
					</cfcatch>
			</cftry>
			<cfif structkeyexists(url,"logout")>
				<cfset request.blogManager.getAuthorizer().unauthorize() />
			</cfif>
			
			<cfif structkeyexists(form,"login")>
				<cfset isAuthor = request.blogManager.getAuthorizer().authorize(form.username,form.password) />
				<cfif NOT isAuthor>
					<cfset request.errormsg = "Invalid login, please try again." />
					<cfset request.username = form.username />
				</cfif>
			</cfif>
			
			<cfsetting showdebugoutput="false">
			
			<cfset blog = request.blogManager.getBlog() />
			<cfset isAdmin = findNoCase(blog.getSetting('urls').admin,arguments.targetPage)/>
			<cfif isAdmin AND NOT ( request.blogManager.isCurrentUserLoggedIn() AND
					listFind(request.blogManager.getCurrentUser().getCurrentrole(blog.getId()).permissions, "access_admin") )>
				<cfset request.administrator = request.blogManager.getAdministrator() />
				<cfinclude template="admin/login.cfm">
				<cfreturn false>
			<cfelseif isAdmin>
				<!--- until we get error handling in the admin, remove onError method --->
				<cfset StructDelete(this,"onError") />
				<cfset request.administrator = request.blogManager.getAdministrator() />
				<cfset request.formHandler = createObject("component","admin.FormHandler").init(request.administrator, 
					request.blogManager.getCurrentUser()) />
			</cfif>
			
			<cfset structappend(request,request.blogManager.handleRequest(targetPage,url,form),true)/>
			
		<cfreturn true>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="onSessionEnd">
	   <cfargument name = "SessionScope" required="true" />
	   <cfargument name = "AppScope" required="true" />	 
	</cffunction>	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="onApplicationEnd" returnType="void">
   <cfargument name="ApplicationScope" required="true" />
</cffunction>	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="onError" returnType="void">
		<cfargument name="Exception" required="true" />
		<cfargument name="EventName" type="String" required="true"/>

		<cfset request.message = createObject("component",variables.componentsPath & "Message") />
		<cfset request.message.setTitle("Error: " & arguments.EventName) />
		<cfset request.message.setText(arguments.exception.message) />
		<cfset request.message.setStatus("error") />
		<cfset request.message.setData(arguments.exception.detail) />
		
		<!--- Set appropriate HTTP status code --->
		<cfif REFindNoCase("NotFound$",arguments.exception.type)>
			<cfheader statuscode="404" statustext="Not Found"/>
		<cfelse>
			<cfheader statuscode="500" statustext="Internal Server Error"/>
		</cfif>
		
		<cftry>
			<cfsetting enablecfoutputonly="false">
			<cfinclude template="generic.cfm">
		<cfcatch type="any">
			<cfsetting enablecfoutputonly="false">
			<cfinclude template="error.cfm">
		</cfcatch>
		</cftry>
	</cffunction>
	
</cfcomponent>