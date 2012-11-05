<cfcomponent displayname="resourceBundle" hint="reads and parses UTF-8 resource bundle per locale">
<!--- 
author:		paul hastings <paul@sustainableGIS.com>
date:		18-june-2003
revisions:	
			08-dec-2003 fixed some bugs with fallback locales arguments rbLocale)
notes:		the purpose of this CFC is to extract text messages from a UTF-8 encoded resource bundle.

methods in this CFC:
			- getResourceBundle required argument is rbFile containing absolute path to resource bundle 
			file. optional argument is rbLocale to indicate which locale's resource bundle to use, defaults
			to us_EN (american english). PUBLIC
 --->	

<cffunction access="public" name="getResourceBundle" output="No" returntype="struct"
	hint="reads and parses UTF-8 resource bundle per locale">
<cfargument name="rbFile" required="Yes" type="string">
<cfargument name="rbLocale" required="No" type="string" default="en_US">
	<cfset var resourceBundle="">
	<cfset var resourceBundleFile="">
	<cfset var thisLocale="">
	<cfset var thisRBfile="">
	<cfset var rbIndx="">
	<cfif NOT len(trim(arguments.rbLocale))>
		<cfset thisLocale="en_US"> <!--- extra fall back locale --->
	<cfelse>
		<cfset thisLocale=arguments.rbLocale>	
	</cfif>
	<cfif NOT fileExists(arguments.rbFile)> <!--- file exists "as is"? --->
		<cfset thisRBFile=getFileFromPath(arguments.rbFile)>
		<cfset thisRBfile=GetDirectoryFromPath(arguments.rbFile) & listFirst(thisRBfile,".") & "_"& thisLocale & "." & listLast(thisRBfile,".")>
	<cfelse> <!--- it exists --->
		<cfset thisRBFile=arguments.rbFile>
	</cfif> <!--- file exists "as is"? --->
	<cftry>
		<cffile action="read" file="#thisRBfile#" variable="resourceBundleFile" charset="utf-8">
		<cfcatch type="Any"> <!--- resource file completely missing --->
			<!--- this should be localized --->
			<cfthrow message="Fatal error: resource bundle #thisRBfile# not found.">
		</cfcatch>	
	</cftry>
	<cfset resourceBundle = structNew()>
	<cfloop index="rbIndx" list="#resourceBundleFile#" delimiters="#chr(10)#">
		<cfif len(trim(rbIndx)) AND left(rbIndx,1) NEQ "##"> <!--- skip comments --->
			<cfset resourceBundle[trim(listFirst(rbIndx,"="))] = trim(listRest(rbIndx,"="))>
		</cfif>
	</cfloop>
	<cfreturn resourceBundle>
</cffunction> 

<!--- code taken from rbJava.cfc from Paul Hastings --->
<cffunction name="getResource" access="public" output="false" returnType="string" 
	hint="Returns bundle.X, if it exists, and optionally performs messageFormat like operation on compound rb string.">
	<cfargument name="resource" type="string" required="true">
	<cfargument name="substituteValues" default="" required="yes" type="any">
	
	<cfset var val = "">
	<cfset var i = "">
	<cfif not isDefined("variables.resourceBundle")>
		<cfthrow message="Fatal error: resource bundle not loaded.">
	</cfif>
	<cfif not structKeyExists(variables.resourceBundle, arguments.resource)>
		<cfset val = "">
	<cfelse>
		<cfset val = variables.resourceBundle[arguments.resource]>
	</cfif>
	
	<cfif isArray(arguments.substituteValues)>
		<cfloop index="i" from="1" to="#arrayLen(arguments.substituteValues)#">
			<cfset val =replace(val,"{#i#}",arguments.substituteValues[i],"ALL")>
		</cfloop>
	<cfelseif len(arguments.substituteValues)>
		<cfset val=replace(val,"{1}",arguments.substituteValues,"ALL")>
	</cfif>
	
	<!--- <cfif isDebugMode()>
		<cfset val = "*** #val# ***">
	</cfif> --->
	<cfreturn val>
</cffunction>

</cfcomponent>