<cfsetting enablecfoutputonly="true">

<cfif thisTag.executionmode is "start">
	<cfparam name="attributes.ifCurrentIsOdd" type="boolean" default="false">
	<cfparam name="attributes.ifCurrentIsEven" type="boolean" default="false">
	<cfparam name="attributes.ifCurrentIsFirst" type="boolean" default="false">
	<cfparam name="attributes.ifCurrentIsLast" type="boolean" default="false">
	<cfparam name="attributes.ifCurrentIsNotFirst" type="boolean" default="false">
	<cfparam name="attributes.ifCurrentIsNotLast" type="boolean" default="false">
	<cfparam name="attributes.ifCurrentCountEQ" type="string" default="">
	<cfparam name="attributes.ifCurrentCountLT" type="string" default="">
	<cfparam name="attributes.ifCurrentCountGT" type="string" default="">
	
	<cfset data = GetBaseTagData("cf_categories")/>
	<cfset currentCategory = data.currentCategory />
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
	
	<cfif len(attributes.ifCurrentCountEQ) AND val(attributes.ifCurrentCountEQ) NEQ currentItemCount>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif len(attributes.ifCurrentCountLT) AND currentItemCount GTE attributes.ifCurrentCountGT>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif len(attributes.ifCurrentCountGT) AND currentItemCount LTE attributes.ifCurrentCountGT>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false">