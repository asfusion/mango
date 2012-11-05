<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.id" type="string" default="" />
<cfparam name="attributes.title" type="string" default="" />

<cfif thisTag.executionmode is "start">
	
	<!--- find what the context is --->
	<cfset ancestorlist = listdeleteat(getbasetaglist(),1) />

	<!--- this tag should always be inside a pod group, but
	if not, just output it as is --->
	<cfif listfindnocase(ancestorlist,"cf_podgroup")>
		<cfset data = GetBaseTagData("cf_podgroup") />
		<!--- check whether this pod id is allowed, then let the template
		pod be output or exit if not to prevent pod code to be executed --->
		<cfif data.allowedPodIds NEQ "*" AND NOT listfindnocase(data.allowedPodIds, attributes.id)>
			<cfsetting enablecfoutputonly="false"><cfexit>
		</cfif>
	</cfif>
</cfif>

<cfif thisTag.executionmode is "end">
	<!--- save the output as a pod, and remove the actual output.
	if and when the Pods tag is run, this pod will appear there --->
	<cfset pod = structnew() />
	<cfset pod.id = attributes.id />
	<cfset pod.content = thisTag.GeneratedContent />
	<cfset pod.title = attributes.title />
	<cfset arrayappend(data.templatePods, pod) />
	<cfset thisTag.GeneratedContent = '' />
</cfif>

<cfsetting enablecfoutputonly="false">