<cfcomponent extends="org.mangoblog.plugins.BasePlugin">

	<cfset this.events = [ { 'name' = 'dashboardPod', 'type' = 'sync', 'priority' = '1' }] />

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		<cfset super.init(arguments.mainManager, arguments.preferences) />
		<cfset variables.i18n = variables.mainManager.getInternationalizer()/>
		<cfreturn this/>
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
			<cfset var manager = getManager() />
			
			<cfif eventName EQ "dashboardPod" AND manager.isCurrentUserLoggedIn()>
				<cfset postManager = manager.getPostsManager() />
				<cfset pageManager = manager.getPagesManager() />
				<cfset commentManager = manager.getCommentsManager() />
				<cfset postCount = postManager.getPostCount() />
				<cfset firstPost = postManager.getPosts(postCount,1) />
				<cfset draftCount = postManager.getPostCount(true)-postCount />
				
				<cfsavecontent variable="podcontent"><cfoutput>
					<div class="d-block">
						<div class="d-flex align-items-center me-5">
							<div class="icon-shape icon-sm icon-shape-secondary rounded me-3">
								<i class="bi bi-easel-fill fs-3"></i>
							</div>
							<div class="d-block">
								<label class="mb-0">#variables.i18n.getValue( "Posts" )#</label>
								<h4 class="mb-0">#postCount#</h4>
							</div>
						</div>
						<div class="d-flex align-items-center pt-3">
							<div class="icon-shape icon-sm icon-shape-danger rounded me-3">
								<i class="bi bi-sticky-fill fs-3"></i>
							</div>
							<div class="d-block">
								<label class="mb-0">#variables.i18n.getValue( "Pages" )#</label>
								<h4 class="mb-0">#pageManager.getPageCount()#</h4>
							</div>
						</div>
						<div class="d-flex align-items-center pt-3">
							<div class="icon-shape icon-sm icon-shape-purple rounded me-3">
								<i class="bi bi-chat-text-fill fs-3"></i>
							</div>
							<div class="d-block">
								<label class="mb-0">#variables.i18n.getValue( "Comments" )#</label>
								<h4 class="mb-0">#commentManager.getCommentCount()#</h4>
							</div>
						</div>
					</div>
					<cfif arraylen(firstPost)>
						<div class="small d-flex mt-3"><div>#variables.i18n.getValue( "The first post was created" )# #formatAge(firstPost[1].getPostedOn())# ago</div></div>
					</cfif>
					<cfif listfind(variables.mainManager.getCurrentUser().getCurrentRole(variables.mainManager.getBlog().getId()).permissions, "manage_posts")><a href="post.cfm"><button class="btn btn-primary mt-4">Create a new post</button></a></cfif>
				</cfoutput>
				</cfsavecontent>			
				
				<cfset arguments.event.addPod(  { title = #variables.i18n.getValue( "Your Site Statistics" )#,  content = podcontent, size = 'small' }  )>
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
  				age = age & ageYR & " " & variables.i18n.getValue( "years" ) & " ";
  				
  			if (ageMO EQ 1)
  				age = age & "1 month ";
  			if (ageMO GT 1)
  				age = age & ageMO & " " & variables.i18n.getValue( "months" ) & " ";
  			
  			if (ageWK EQ 1)
  				age = age & "1 week";
  			if (ageWK GT 1)
  				age = age & ageWK & " " & variables.i18n.getValue( "weeks" ) & " ";
  				
  			return age;
		</cfscript>
		
	</cffunction>

</cfcomponent>