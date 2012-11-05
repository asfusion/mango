<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.ifMessageExists" default="false">
<cfparam name="attributes.type" default="">
<cfparam name="attributes.status" default="">
<cfparam name="attributes.text" default="false">
<cfparam name="attributes.title" default="false">
<cfparam name="attributes.data" default="false">

<cfif thisTag.executionmode is 'start'>
	
	<cfif attributes.ifMessageExists>
		<cfif len(attributes.type) AND request.message.getType() EQ attributes.type
				AND len(attributes.status) AND request.message.getStatus() EQ attributes.status
					><cfelse><cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	<cfif attributes.text>
		<cfoutput>#request.message.getText()#</cfoutput>
	</cfif>
	<cfif attributes.title>
		<cfoutput>#request.message.getTitle()#</cfoutput>
	</cfif>
	<cfif attributes.data>
		<cfoutput>#toString(request.message.getData())#</cfoutput>
	</cfif>


</cfif>

<cfsetting enablecfoutputonly="false">