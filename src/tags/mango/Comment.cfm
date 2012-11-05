<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.ifCurrentIsOdd" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsEven" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsFirst" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsLast" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsNotFirst" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsNotLast" type="boolean" default="false">

<cfif thisTag.executionmode is 'start'>
	<cfset data = GetBaseTagData("cf_comments")/>
	<cfset currentComment = data.currentComment />
	<cfset currentCommentCount = data.counter />
	<cfset total = data.to />
	
	<cfif attributes.ifCurrentIsOdd AND NOT currentCommentCount mod 2>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsEven AND currentCommentCount mod 2>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsFirst AND currentCommentCount NEQ 1>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsLast AND currentCommentCount NEQ total>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsNotFirst AND currentCommentCount EQ 1>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsNotLast AND currentCommentCount EQ total>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
</cfif>
<cfsetting enablecfoutputonly="false">