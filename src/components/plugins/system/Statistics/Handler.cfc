<cfcomponent>

	<cfset variables.name = "Statistics">
	<cfset variables.id = "org.mangoblog.plugins.Statistics">
	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />

			<cfset variables.manager = arguments.mainManager />
		<cfreturn this/>
	</cffunction>

	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<!--- TODO: Implement Method --->
		<cfreturn />
	</cffunction>

	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<!--- TODO: Implement Method --->
		<cfreturn />
	</cffunction>
	
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>

	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
		<cfreturn />
	</cffunction>

	<cffunction name="getId" access="public" output="false" returntype="any">
		<cfreturn variables.id />
	</cffunction>

	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="any" required="true" />
		<cfset variables.id = arguments.id />
		<cfreturn />
	</cffunction>

	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
		<cfreturn />
	</cffunction>

	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var data = arguments.event.data />
			<cfset var eventName = arguments.event.name />
			<cfset var pod = "" />
			<cfset var postManager = "">
			<cfset var pageManager = "">
			<cfset var commentManager = "">
			<cfset var firstPost = "" />
			<cfset var postCount = "" />
			<cfset var draftCount = "" />
			<cfset var podcontent = "" />
			
			<cfif eventName EQ "dashboardPod" AND manager.isCurrentUserLoggedIn()>
				<cfset postManager = variables.manager.getPostsManager() />
				<cfset pageManager = variables.manager.getPagesManager() />
				<cfset commentManager = variables.manager.getCommentsManager() />
				<cfset postCount = postManager.getPostCount() />
				<cfset firstPost = postManager.getPosts(postCount,1) />
				<cfset draftCount = postManager.getPostCount(true)-postCount />				
				
				<cfsavecontent variable="podcontent">
				<cfoutput><p>This blog has: <ul><li>#postCount# published posts,</li>
					<li>#pageManager.getPageCount()# published pages,</li>
					<cfif draftCount GT 0><li>#draftCount# draft posts and</li></cfif>
					<li>#commentManager.getCommentCount()# comments.</li></ul></p>					
					<cfif arraylen(firstPost)>
						<p>The first post was created #formatAge(firstPost[1].getPostedOn())# ago.</p>
					<cfelse>
						<p><a href="post.cfm">Create a new post</a></p>
					</cfif></cfoutput>
				</cfsavecontent>			
				
				<cfset pod = structnew() />
				<cfset pod.title = "Your Site Statistics" />
				<cfset pod.content = podcontent />
				<cfset arguments.event.addPod(pod)>
				
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>
	
	<cffunction name="formatAge" access="private">
		<cfargument name="date" required="true">
		
		<cfscript>
		 	var ageYR = dateDiff('yyyy', date, now());
  			var ageMO = 0;
  			var ageWK = 0;
  			
  			var age = "";
  			
			if (ageYR GT 0)
				arguments.date = dateadd("yyyy",ageYR,arguments.date);
				
  			ageMO = dateDiff('m', arguments.date, now());
  			
  			if (ageMO GT 0)
				arguments.date = dateadd("m", ageMO, arguments.date);
			
  			ageWK = dateDiff('ww', arguments.date, now());
  			
  			age = "";
  			
  			if (ageYR EQ 1)
  				age = age & " 1 year ";
  			if (ageYR GT 1)
  				age = age & ageYR & " years ";
  				
  			if (ageMO EQ 1)
  				age = age & "1 month ";
  			if (ageMO GT 1)
  				age = age & ageMO & " months ";
  			
  			if (ageWK EQ 1)
  				age = age & "1 week";
  			if (ageWK GT 1)
  				age = age & ageWK & " weeks";
  				
  			return age;
		</cfscript>
		
	</cffunction>

</cfcomponent>