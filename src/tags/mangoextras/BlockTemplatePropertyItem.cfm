<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.ifCurrentIsOdd" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsEven" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsFirst" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsLast" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsNotFirst" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsNotLast" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsMod" type="numeric" default="1">

<cfif thisTag.executionmode is "start">

	<cfset ancestorlist = listdeleteat(getbasetaglist(),1) />
	<cfset counter = 0 />
	<cfset totalItems = 0 />
	
	<cfif listfindnocase( ancestorlist,"cf_blocktemplateproperty" )>
		<cfset data = getBaseTagData("cf_blocktemplateproperty", 1 )/>
		<cfset currentSetting = currentSetting = data.currentSetting>
		<cfset currentSetting.index = counter = data.counter />
		<cfset itemCount = data.count />
	</cfif>
	
	<cfif attributes.ifCurrentIsOdd AND NOT counter mod 2>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">			
	</cfif>
	
	<cfif attributes.ifCurrentIsEven AND counter mod 2>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsFirst AND counter NEQ 1>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsLast AND counter NEQ itemCount>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsNotFirst AND counter EQ 1>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsNotLast AND counter EQ itemCount>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	<cfif attributes.ifCurrentIsMod NEQ 1 AND ( counter mod attributes.ifCurrentIsMod GT 0 )>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false">