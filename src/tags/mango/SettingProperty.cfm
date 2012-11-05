<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.name" default="">
<cfparam name="attributes.ifHasName" default="">
<cfparam name="attributes.ifNotHasName" default="">
<cfparam name="attributes.defaultValue" default="">
<cfparam name="attributes.format" default="default">

<cfif thisTag.executionmode is 'start'>
<cfif attributes.format EQ "default">
	<cfset attributes.format = 'escapedHtml' />
</cfif>

<cfset ancestorlist = getbasetaglist() />

	<cfif listfindnocase(ancestorlist,"cf_setting")>
		<cfset data = GetBaseTagData("cf_setting")/>
	<cfelse>
		<cfset data = structnew() />
	</cfif>

<cfset currentSetting = data.currentSetting />
<cfset prop = "" />

<cfif len(attributes.ifHasName)>
	<cfif NOT structkeyexists(currentSetting, attributes.ifHasName)>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
</cfif>

<cfif len(attributes.ifNotHasName)>
	<cfif structkeyexists(currentSetting, attributes.ifNotHasName)>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
</cfif>

<cfif len(attributes.name)>
	<cfif structkeyexists(currentSetting, attributes.name)>
		<cfif issimplevalue(currentSetting[attributes.name])>
			<cfset prop = tostring(currentSetting[attributes.name]) />
		</cfif>
	<cfelseif len(attributes.defaultValue)>
		<cfset prop = attributes.defaultValue />
	</cfif>
</cfif>

<cfif attributes.format EQ "xml">
	<cfset prop = xmlformat(prop) />
<cfelseif attributes.format EQ "escapedHtml">
	<cfset prop = htmleditformat(prop)>
</cfif>
<cfoutput>#prop#</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">