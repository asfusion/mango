<cfcomponent name="Mailer" hint="Sends email">

	<cfset variables.server = "" />
	<cfset variables.username = "" />
	<cfset variables.password = "" />

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="server" required="false" default="">  
		<cfargument name="username" required="false" default="">  
		<cfargument name="password" required="false" default="">
		<cfargument name="defaultFromAddress" required="false" default="">
		
		<cfset variables.server = arguments.server />
		<cfset variables.username = arguments.username />
		<cfset variables.password = arguments.password />
		<cfset variables.defaultFromAddress = arguments.defaultFromAddress />
		<cfreturn this />
		
	</cffunction>

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="sendEmail" output="false" returnType="void" description="sends an email to the specified address"  access="public">
	<cfargument name="to" required="true">  
	<cfargument name="from" required="false" default="#variables.defaultFromAddress#">  
	<cfargument name="subject" required="false" default="">
	<cfargument name="body" required="false" default="">    
	<cfargument name="type" required="false" default="plain text">
	<cfargument name="cc" required="false" default="">  
	<cfargument name="bcc" required="false" default="">    
 
	<cfset var plaintext = "">
	<cfif arguments.type EQ "html">
		<cfset plaintext = ReReplaceNoCase(arguments.body, "<[^>]*>", "", "ALL")>
	</cfif>
	
	<cfif len(variables.server)>
		<cfmail to="#arguments.to#" from="#arguments.from#" subject="#arguments.subject#" server="#variables.server#" 
				username="#variables.username#" password="#variables.password#" cc="#arguments.cc#" bcc="#arguments.bcc#"><cfif arguments.type NEQ "html">#arguments.body#<cfelse><cfmailpart type="text">#plaintext#</cfmailpart>
				   <cfmailpart type="html">
				   	#arguments.body#
				  </cfmailpart>
			</cfif>
		</cfmail>
	<cfelse><!--- no server --->
		<cfmail to="#arguments.to#" from="#arguments.from#" subject="#arguments.subject#" cc="#arguments.cc#" bcc="#arguments.bcc#"><cfif arguments.type NEQ "html">#arguments.body#<cfelse><cfmailpart type="text">#plaintext#</cfmailpart>
				   <cfmailpart type="html">
				   	#arguments.body#
				  </cfmailpart>
			</cfif>
		</cfmail>
	
	</cfif>
	</cffunction> 

</cfcomponent>