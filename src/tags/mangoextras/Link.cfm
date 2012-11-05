<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.ifCurrentIsOdd" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsEven" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsFirst" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsLast" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsNotFirst" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsNotLast" type="boolean" default="false">

<cfif thisTag.executionmode is "start">

	<cfset data = GetBaseTagData("cf_links")/> 
	<cfset currentFavoriteLink = data.currentFavoriteLink />
	<cfset currentItemCount = data.counter />
	<cfset total = data.to />
	
	<cfif attributes.ifCurrentIsOdd AND NOT currentItemCount mod 2>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">			
	</cfif>
	
	<cfif attributes.ifCurrentIsEven AND currentItemCount mod 2>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsFirst AND currentItemCount NEQ 1>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsLast AND currentItemCount NEQ total>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsNotFirst AND currentItemCount EQ 1>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsNotLast AND currentItemCount EQ total>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>

</cfif>

<cfsetting enablecfoutputonly="false">