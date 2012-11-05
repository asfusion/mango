<cfsetting enablecfoutputonly="true">

<cfif thisTag.executionmode is "start">
	<cfparam name="attributes.ifCurrentIsOdd" type="boolean" default="false">
	<cfparam name="attributes.ifCurrentIsEven" type="boolean" default="false">
	
	<cfset data = GetBaseTagData("cf_linkcategories")/>
	<cfset currentLinkCategory = data.currentLinkCategory />
	<cfset currentItemCount = data.counter />
	
	<cfif attributes.ifCurrentIsOdd AND NOT currentItemCount mod 2>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsEven AND currentItemCount mod 2>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
</cfif>

<cfsetting enablecfoutputonly="false">