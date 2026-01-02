<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.name" default="">
<cfparam name="attributes.ifHasName" default="">
<cfparam name="attributes.ifNotHasName" default="">
<cfparam name="attributes.defaultValue" default="">
<cfparam name="attributes.format" default="default">
<cfparam name="attributes.ifValueEQ" type="string" default="">

<cfif thisTag.executionmode is 'start'>
	<cfscript>function ParagraphFormat2(str) {
//first make Windows style into Unix style
		str = replace(str,chr(13)&chr(10),chr(10),"ALL");
//now make Macintosh style into Unix style
		str = replace(str,chr(13),chr(10),"ALL");
//now fix tabs
		str = replace(str,chr(9),"&nbsp;&nbsp;&nbsp;","ALL");
//now return the text formatted in HTML
		return replace(str,chr(10),"<br>","ALL");
	}</cfscript>

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

<cfif len(attributes.ifValueEQ) AND (
	( len(attributes.name) AND ( NOT structkeyexists(currentSetting, attributes.name ) OR currentSetting[attributes.name] NEQ attributes.ifValueEQ ))
	OR ( len(attributes.ifHasName) AND currentSetting[attributes.ifHasName] NEQ attributes.ifValueEQ )
	OR ( len(attributes.ifNotHasName) AND currentSetting[attributes.ifNotHasName] NEQ attributes.ifValueEQ )
)
>
	<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
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

	<cfif attributes.format EQ "paragraph">
		<cfset prop = ParagraphFormat2( prop ) />
		<cfelseif attributes.format EQ "escapedHtml">
		<cfset prop = htmleditformat( prop )>
	</cfif>
<cfoutput>#prop#</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">