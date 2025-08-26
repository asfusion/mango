<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.name" default="">

<cfif thisTag.executionmode EQ "start">
<!--- all these events are type template --->
<!--- we need to get the context to help the plugins know where they are --->
<cfset ancestorlist = getbasetaglist() />
<cfset context = structnew() />
<cfset args = structnew() />
<cfset args.context = context />
<cfset args.request = request />
<cfset args.attributes = attributes />
<cfset pluginQueue = request.blogManager.getpluginQueue() />
<cfset event = pluginQueue.createEvent(attributes.name,args,"Pod") />
<cfset event = pluginQueue.broadcastEvent(event) />
<cfset pods = event.getPods() />

<div class="row container-fluid">
	<cfloop from="1" to="#arraylen(pods)#" index="i">
	<cfset colStyle = "col-4">
	<cfset type = "card">
	<cfset class = '' />
	<cfif structKeyExists( pods[i], 'size' )>
		<cfif pods[ i ].size EQ 'small'><cfset colStyle = 'col-12 col-sm-6 col-md-6 col-lg-4 col-xl-3 small' /></cfif>
		<cfif pods[ i ].size EQ 'medium'><cfset colStyle = 'col-12 col-sm-6 col-xl-4 medium' /></cfif>
		<cfif pods[ i ].size EQ 'large'><cfset colStyle = 'col-12 col-sm-9 col-xl-6 large' /></cfif>
		<cfif pods[ i ].size EQ 'xlarge'><cfset colStyle = 'col-12 col-xl-8 xlarge' /></cfif>
		<cfif pods[ i ].size EQ 'xxlarge'><cfset colStyle = 'col-12' /></cfif>
	</cfif>
	<cfoutput>
		<cfif structKeyExists( pods[i], 'type' )>
			<cfset type = pods[ i ].type>
		</cfif>
		<cfif structKeyExists( pods[i], 'class' )>
			<cfset class = pods[ i ].class>
		</cfif>
		<div class="#colStyle# mb-4">
			<cfif type EQ 'card'>
			<div class="card border-0 shadow #class#">
				<cfif structkeyexists(pods[i],"title") AND len(pods[i].title)>
				<div class="card-header border-bottom d-flex align-items-center justify-content-between">
					<h2 class="fs-5 fw-bold mb-0">#pods[i].title#</h2>
					<!---<a href="#" class="btn btn-sm btn-primary">See all</a>--->
				</div>
				</cfif>
				<div class="card-body">#pods[i].content#</div>
			</div>
			<cfelse>
				#pods[i].content#
			</cfif>
		</div>
	</cfoutput>
	</cfloop>
</div><!--- row ---->
</cfif>
<cfsetting enablecfoutputonly="false">