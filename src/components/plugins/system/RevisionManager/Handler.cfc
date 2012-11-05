<cfcomponent extends="BasePlugin">

	<cfset variables.id 		= "org.mangoblog.plugins.RevisionManager">
	<cfset variables.package 	= "org/mangoblog/plugins/revisionManager"/>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
						
			<cfset setManager(arguments.mainManager) />
			<cfset setPreferencesManager(arguments.preferences) />
			
		<cfreturn this/>
		
	</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />	
		
		<cfset var eventName = arguments.event.getName()  />
		<cfset var local = structnew() />
		
		<cfif eventName EQ "afterPostUpdate">
			<cfset storeRevision(arguments.event.oldItem, arguments.event.changeByUser,"post") />
		<cfelseif eventName EQ "afterPageUpdate">
			<cfset storeRevision(arguments.event.oldItem, arguments.event.changeByUser,"page") />
		<cfelseif eventName EQ "afterPostDelete" OR eventName EQ "afterPageDelete">
			<cfset deleteRevisionsForEntry(arguments.event.oldItem) />
		</cfif>
		
		<cfreturn />

	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var outputData 	= "" />
		<cfset var eventName 	= arguments.event.getName() />
		<cfset var local 		= structnew() />
		<cfset var data 		= arguments.event.data />
		<cfset var manager		= getManager() />

		<cfif (eventName EQ "beforeAdminPostContentEnd" OR eventName EQ "beforeAdminPageContentEnd")  AND manager.isCurrentUserLoggedIn()>
			<!--- get list of revisions --->
			<cfset local.revisions = getRevisions(data.attributes.item.id) />
			<cfif local.revisions.recordcount>
			<cfset local.entry = data.attributes.item />
			<cfset local.revision = structnew() />
			<cfset local.revision.id = 0 />
			<cfsavecontent variable="outputData"><cfoutput>
				<h2>Revisions</h2>
				<cfinclude template="admin/revisions_table.cfm">
			</cfoutput>
			</cfsavecontent>
			</cfif>
			<cfset arguments.event.outputdata = arguments.event.outputdata & outputData />
		
		<cfelseif eventName EQ "afterPostUpdate" AND manager.isCurrentUserLoggedIn()>
			<cfset storeRevision(arguments.event.oldItem, arguments.event.changeByUser,"post") />
		<cfelseif eventName EQ "afterPageUpdate" AND manager.isCurrentUserLoggedIn()>
			<cfset storeRevision(arguments.event.oldItem, arguments.event.changeByUser,"page") />
			
		<!--- ____________________________________________________ --->
		<cfelseif eventName EQ "versioner-showRevision" AND manager.isCurrentUserLoggedIn()>
			<cfset local.revision = getRevision(data.externaldata.revision) />
			<!--- get list of revisions --->
			<cfset local.revisions = getRevisions(local.revision.entry_id) />
			<cfif local.revision.entry_type EQ "post">
				<cfset local.entry = getManager().getAdministrator().getPost(local.revision.entry_id) />
			<cfelse>
				<cfset local.entry = getManager().getAdministrator().getPage(local.revision.entry_id) />
			</cfif>
			
			<cfsavecontent variable="outputData">
				<cfinclude template="admin/revision_compare.cfm">
			</cfsavecontent>
			<cfif local.revision.entry_type EQ "post">
				<cfset local.address = "post.cfm" />
			<cfelse>
				<cfset local.address = "page.cfm" />
			</cfif>
			<cfset data.message.setTitle("Revision for: <a href='#local.address#?id=#local.revision.entry_id#'>#local.revision.currentTitle#</a>") />
			<cfset data.message.setData(outputData) />
		
		<!--- ____________________________________________________ --->
		<cfelseif eventName EQ "versioner-restoreRevision" AND manager.isCurrentUserLoggedIn()>
			<cfset local.revision = getRevision(data.externaldata.revision) />
			<cfset local.manager = getManager() />
			
			<cfif local.revision.entry_type EQ "post">
				<cfset local.manager.getAdministrator().editPost(
											local.revision.entry_id,
											local.revision.title,
											local.revision.content,
											local.revision.excerpt) />
			<cfelseif local.revision.entry_type EQ "page">
				<cfset local.manager.getAdministrator().editPage(
											local.revision.entry_id,
											local.revision.title,
											local.revision.content,
											local.revision.excerpt) />
			</cfif>
		
			<cfset local.revision = getRevision(data.externaldata.revision) />
			<!--- get list of revisions --->
			<cfset local.revisions = getRevisions(local.revision.entry_id) />
			<cfif local.revision.entry_type EQ "post">
				<cfset local.entry = getManager().getAdministrator().getPost(local.revision.entry_id) />
			<cfelse>
				<cfset local.entry = getManager().getAdministrator().getPage(local.revision.entry_id) />
			</cfif>
			
			<cfsavecontent variable="outputData">
				<p class="message">Revision restored</p>
				<cfinclude template="admin/revision_compare.cfm">
			</cfsavecontent>
			<cfif local.revision.entry_type EQ "post">
				<cfset local.address = "post.cfm" />
			<cfelse>
				<cfset local.address = "page.cfm" />
			</cfif>
			<cfset data.message.setTitle("Revision for: <a href='#local.address#?id=#local.revision.entry_id#'>#local.revision.currentTitle#</a>") />
			
			<cfset data.message.setData(outputData) />
		
		</cfif>
		
		<cfreturn arguments.event />
		
	</cffunction>

	<!--- ::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="storeRevision" access="private">
		<cfargument name="entry" required="true" />
		<cfargument name="author" required="true" />
		<cfargument name="entry_type" required="false" default="post" />
		
		<cfset var myQueryString = "">
		<cfset var queryInterface = getManager().getQueryInterface()/>
		<cfset var prefix = queryInterface.getTablePrefix() />

		<cfsavecontent variable="myQueryString"><cfoutput>
			INSERT INTO #prefix#entry_revision
			(id, entry_id, name, title, content, excerpt, author_id, last_modified, entry_type) 
			VALUES (
				'#createUUID()#',
				'#arguments.entry.id#',
				'#arguments.entry.name#',
				'#replacenocase(arguments.entry.title,"'","''",'all')#',
				'#replacenocase(arguments.entry.content,"'","''",'all')#',
				'#replacenocase(arguments.entry.excerpt,"'","''",'all')#',
				'#arguments.author.id#',
				#CreateODBCDateTime(arguments.entry.lastModified)#,
				'#arguments.entry_type#'
			)
			</cfoutput>
		</cfsavecontent>
			
		<cfset queryInterface.makeQuery(myQueryString,0,false) />
		
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getRevisions" access="private">
		<cfargument name="entryId" required="true" />
		
		<cfset var myQueryString = "">
		<cfset var queryInterface = getManager().getQueryInterface()/>
		<cfset var prefix = queryInterface.getTablePrefix() />

		<cfsavecontent variable="myQueryString"><cfoutput>
			SELECT entry_revision.id, entry_revision.last_modified, entry_revision.title, author.name as author
			FROM #prefix#entry_revision as entry_revision 
			INNER JOIN #prefix#author as author
			ON entry_revision.author_id = author.id
			WHERE entry_id = '#arguments.entryId#'
			ORDER BY last_modified desc
			</cfoutput>
		</cfsavecontent>
			
		<cfreturn queryInterface.makeQuery(myQueryString,0,true) />
		
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getRevision" access="private">
		<cfargument name="id" required="true" />
		
		<cfset var myQueryString = "">
		<cfset var queryInterface = getManager().getQueryInterface()/>
		<cfset var prefix = queryInterface.getTablePrefix() />

		<cfsavecontent variable="myQueryString"><cfoutput>
			SELECT entry_revision.*, author.name as author, entry.title as currentTitle
			FROM #prefix#entry_revision as entry_revision 
			INNER JOIN #prefix#author as author
			ON entry_revision.author_id = author.id
			INNER JOIN #prefix#entry as entry
			ON entry_revision.entry_id = entry.id
			WHERE entry_revision.id = '#arguments.id#'
			</cfoutput>
		</cfsavecontent>
			
		<cfreturn queryInterface.makeQuery(myQueryString,0,true) />
		
	</cffunction>


	<!--- ::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deleteRevisionsForEntry" access="private">
		<cfargument name="entry" required="true" />
		
		<cfset var myQueryString = "">
		<cfset var queryInterface = getManager().getQueryInterface()/>
		<cfset var prefix = queryInterface.getTablePrefix() />

		<cfsavecontent variable="myQueryString"><cfoutput>
			DELETE FROM #prefix#entry_revision
			WHERE entry_id = '#arguments.entry.id#'
			</cfoutput>
		</cfsavecontent>
			
		<cfset queryInterface.makeQuery(myQueryString,0,false) />
		
	</cffunction>
</cfcomponent>