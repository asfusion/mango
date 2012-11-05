<cfcomponent>

	<cfset variables.name = "Favorite Links">
	<cfset variables.id = "org.mangoblog.plugins.Links">
	
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
			<cfset var links = "" />
			<cfset var link = "" />
			<cfset var i = ""/>
			<cfset var j = ""/>
			<cfset var categories = "" />
			<cfset var category = "" />
			<cfset var dao =  ""/>
			<cfset var page = "" />
			
			<cfif eventName EQ "getFavoriteLinks">
				<cfset arguments.event.setOutputData(getLinks(data.orderBy)) />
					
			<cfelseif eventName EQ "getFavoriteLinksByCategory">
				<cfset arguments.event.setOutputData(getLinksByCategory(data.category,data.orderBy)) />
					
			<cfelseif eventName EQ "getFavoriteLinkCategories">
				<cfset arguments.event.setOutputData(getCategories()) />
			
			<cfelseif eventName EQ "getFavoriteLink">
				<cfset arguments.event.setOutputData(getLink(data.id)) />
					
			<!--- admin nav event --->
			<cfelseif eventName EQ "linksNav" AND manager.isCurrentUserLoggedIn()>
				<cfset link = structnew() />
				<cfset link.owner = "Links">
				<cfset link.page = "generic" />
				<cfset link.title = "Edit" />
				<cfset link.eventName = "links-showLinksSettings" />
				
				<cfset arguments.event.addLink(link)>
				
				<cfset link = structnew() />
				<cfset link.owner = "Links">
				<cfset link.page = "generic" />
				<cfset link.title = "Add Category" />
				<cfset link.eventName = "links-editLinkCategorySettings" />
				<cfset arguments.event.addLink(link)>
				
				<cfset link = structnew() />
				<cfset link.owner = "Links">
				<cfset link.page = "generic" />
				<cfset link.eventName = "links-editLinkSettings" />
				<cfset link.title = "Add Link" />
				<cfset arguments.event.addLink(link)>
			
			<!--- admin event --->
			<!---  showLinksSettings ----------------------------------------------- --->
			<cfelseif eventName EQ "links-showLinksSettings" AND manager.isCurrentUserLoggedIn()>
				<cfset data = arguments.event.getData() />
				<cfset categories = getCategories(0) />
				
				<cfsavecontent variable="page">
					<cfloop from="1" to="#arraylen(categories)#" index="j">
						<cfset category = categories[j] />
						<cfset links = getLinksByCategory(categories[j].getId(),"showOrder,title",0) />
						<cfinclude template="admin/linkTable.cfm">
					</cfloop>
					
				</cfsavecontent>
					
					<!--- change message --->
					<cfset data.message.setTitle("All Links") />
					<cfset data.message.setData(page) />
			
			<!---  editLinkSettings ----------------------------------------------- --->
			<cfelseif eventName EQ "links-editLinkSettings" AND manager.isCurrentUserLoggedIn()>
				<cfset data = arguments.event.getData() />
				<cfset categories = getCategories(0) />
				<cfset dao = createObject("component","LinksDAO").init(variables.manager.getQueryInterface()) />
					
				<cfif structkeyexists(data.externaldata,"apply")>
					<cftry>
						<cfif structkeyexists(data.externalData,"linkid")>
							<cfset dao.editLink(data.externaldata.linkid,data.externaldata.title,data.externaldata.address,
							data.externaldata.description, data.externaldata.category, data.externaldata.order) />
							<cfset data.message.settext("Link updated")/>
						<cfelse>
							<!---  new link--->
							<cfset dao.addLink(data.externaldata.title,data.externaldata.address,
							data.externaldata.description, data.externaldata.category, data.externaldata.order) />
							<cfset data.message.settext("Link added")/>
						</cfif>
					
					<!--- update data --->
					<cfset data.message.setstatus("success") />
					<cfset data.message.setType("generic") />
					
					<!--- refresh cache --->
					<cfset getLinksByCategory(data.externaldata.category,"showOrder,title" , 0) />
					
						<cfcatch type="any">
							<cfset data.message.setstatus("error") />
							<cfset data.message.setType("generic") />
							<cfset data.message.settext(cfcatch.message)/>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif structkeyexists(data.externalData,"linkid")>
					<cfset link = getLink(data.externaldata.linkid,0) />
					<cfset data.message.setTitle("Editing link: " & link.getTitle()) />
				
				<!--- new link --->
				<cfelse>
					<cfset link = createObject("component","Link") />
					<cfset data.message.setTitle("Adding new link") />
				</cfif>
				<cfsavecontent variable="page">
					<cfinclude template="admin/editLink.cfm">
				</cfsavecontent>
					
					<!--- change message --->
					<cfset data.message.setData(page) />
			
			<!---  editCategorySettings ----------------------------------------------- --->
			<cfelseif eventName EQ "links-editLinkCategorySettings" AND manager.isCurrentUserLoggedIn()>
				<cfset data = arguments.event.getData() />
				<cfset dao = createObject("component","LinksDAO").init(variables.manager.getQueryInterface()) />
					
				<cfif structkeyexists(data.externaldata,"apply")>
					<cftry>
						<cfif structkeyexists(data.externalData,"categoryid")>
							<cfset dao.editCategory(data.externaldata.categoryid,data.externaldata.name,data.externaldata.description) />
							<cfset data.message.settext("Category updated")/>
						<cfelse>
							<!---  new --->
							<cfset dao.addCategory(data.externaldata.name, data.externaldata.description, variables.manager.getBlog().getId()) />
							<cfset data.message.settext("Category added")/>
						</cfif>
					
					<!--- update queries --->
					<cfset getCategories(cache=0) />
					<cfset data.message.setstatus("success") />
					<cfset data.message.setType("generic") />
					
						<cfcatch type="any">
							<cfset data.message.setstatus("error") />
							<cfset data.message.setType("generic") />
							<cfset data.message.settext(cfcatch.message)/>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif structkeyexists(data.externalData,"categoryid")>
					<cfset category = getCategory(data.externaldata.categoryid,0) />
					<cfset data.message.setTitle("Editing category: " & category.getName()) />
				
				<!--- new link --->
				<cfelse>
					<cfset category = createObject("component","LinkCategory") />
					<cfset data.message.setTitle("Adding new category") />
				</cfif>
				<cfsavecontent variable="page">
					<cfinclude template="admin/editCategory.cfm">
				</cfsavecontent>
					
					<!--- change message --->
					<cfset data.message.setData(page) />
			
			<!---  deleteCategory ----------------------------------------------- --->
			<cfelseif eventName EQ "links-deleteLinkCategory" AND manager.isCurrentUserLoggedIn()>
				<cfset data = arguments.event.getData() />
				<cfset dao = createObject("component","LinksDAO").init(variables.manager.getQueryInterface()) />
					
				<cfset data = arguments.event.getData() />
				
				<cfif structkeyexists(data.externalData,"categoryid")>
					<cftry>
						<!--- @TODO: delte links first --->
						<cfset dao.deleteCategory(data.externalData.categoryid) />
						<cfset data.message.settext("Category deleted")/>
						<cfset data.message.setstatus("success") />
						<cfset data.message.setType("generic") />
					
						<cfcatch type="any">
							<cfset data.message.setstatus("error") />
							<cfset data.message.setType("generic") />
							<cfset data.message.settext(cfcatch.message & " " & cfcatch.detail)/>
						</cfcatch>
					</cftry>
				<cfelse><!--- category missing --->
					<cfset data.message.setstatus("error") />
					<cfset data.message.setType("generic") />
					<cfset data.message.settext("No category selected")/>
				
				</cfif>
				
				<cfset categories = getCategories(0) />
				<cfsavecontent variable="page">
					<cfloop from="1" to="#arraylen(categories)#" index="j">
						<cfset category = categories[j] />
						<cfset links = getLinksByCategory(categories[j].getId(),"showOrder,title",0) />
						<cfinclude template="admin/linkTable.cfm">
					</cfloop>
						
				</cfsavecontent>
				<!--- change message --->
				<cfset data.message.setTitle("All Links") />
				<cfset data.message.setData(page) />
			
			
			<!---  deleteLink ----------------------------------------------- --->
			<cfelseif eventName EQ "links-deleteLink" AND manager.isCurrentUserLoggedIn()>
				<cfset data = arguments.event.getData() />
				<cfset dao = createObject("component","LinksDAO").init(variables.manager.getQueryInterface()) />
				
				<cfif structkeyexists(data.externalData,"linkid")>
					<cftry>
						<cfset dao.deleteLink(data.externalData.linkid) />
						<cfset data.message.settext("Link deleted")/>
						<cfset data.message.setstatus("success") />
						<cfset data.message.setType("generic") />
					
						<cfcatch type="any">
							<cfset data.message.setstatus("error") />
							<cfset data.message.setType("generic") />
							<cfset data.message.settext(cfcatch.message & " " & cfcatch.detail)/>
						</cfcatch>
					</cftry>
				<cfelse><!--- category missing --->
					<cfset data.message.setstatus("error") />
					<cfset data.message.setType("generic") />
					<cfset data.message.settext("All Links")/>
				
				</cfif>
				
				<cfset categories = getCategories(0) />
				<cfsavecontent variable="page">
					<cfloop from="1" to="#arraylen(categories)#" index="j">
						<cfset category = categories[j] />
						<cfset links = getLinksByCategory(categories[j].getId(),"showOrder,title",0) />
						<cfinclude template="admin/linkTable.cfm">
					</cfloop>
						
				</cfsavecontent>
				<!--- change message --->
				<cfset data.message.setTitle("All Links") />
				<cfset data.message.setData(page) />
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>
	
<cffunction name="getLinks" access="private" output="false" returntype="array">
	<cfargument name="orderBy" type="string" required="false" default="showOrder,title" />
	<cfargument name="cache" type="numeric" required="false" default="60" />
		
		<cfset var myQueryString = "">
		<cfset var linksQ = "" />
		<cfset var queryInterface = variables.manager.getQueryInterface()/>
		<cfset var prefix = queryInterface.getTablePrefix() />
			
		<!--- @TODO: make this a little more secure (in the orderby clause)--->
		<cfsavecontent variable="myQueryString"><cfoutput>
			SELECT * FROM #prefix#link
			ORDER BY #listgetat(arguments.orderBy,1," ")#</cfoutput>
		</cfsavecontent>
			
		<!--- cache results for 60 minutes --->
		<cfset linksQ = queryInterface.makeQuery(myQueryString,arguments.cache) />
		
	<cfreturn packageLinkObjects(linksQ) />
</cffunction>


<cffunction name="getLinksByCategory" access="private" output="false" returntype="array">
	<cfargument name="category" type="string" required="false" default="" />
	<cfargument name="orderBy" type="string" required="false" default="showOrder,title" />
	<cfargument name="cache" type="numeric" required="false" default="60" />
		
		<cfset var myQueryString = "">
		<cfset var linksQ = "" />
		<cfset var queryInterface = variables.manager.getQueryInterface()/>
		<cfset var prefix = queryInterface.getTablePrefix() />
		
		<!--- just check that category is a valid id--->
		<cfif isValid("UUID", arguments.category)>
			
			<!--- @TODO: make this a little more secure (in the orderby clause)--->
			<cfsavecontent variable="myQueryString">
				<cfoutput>
					SELECT * FROM #prefix#link
					WHERE category_id = '#arguments.category#'
					ORDER BY #listgetat(arguments.orderBy,1," ")#</cfoutput>
			</cfsavecontent>
			
			<!--- cache results for 60 minutes --->
			<cfset linksQ = queryInterface.makeQuery(myQueryString,arguments.cache) />
			
		<cfelse>
			<cfreturn arraynew(1) />
		</cfif>
		
	<cfreturn packageLinkObjects(linksQ) />
</cffunction>

<cffunction name="getCategories" access="private" output="false" returntype="array">
	<cfargument name="cache" type="numeric" required="false" default="60" />
		<cfset var myQueryString = "">
		<cfset var catsQ = "" />
		<cfset var queryInterface = variables.manager.getQueryInterface()/>
		<cfset var prefix = queryInterface.getTablePrefix() />
		<cfset var blogID = variables.manager.getBlog().getID() />
		
		<cfsavecontent variable="myQueryString">
			<cfoutput>SELECT * FROM #prefix#link_category
			WHERE blog_id = '#blogID#'</cfoutput>
		</cfsavecontent>
			
		<!--- cache results for 60 minutes --->
		<cfset catsQ = queryInterface.makeQuery(myQueryString,arguments.cache) />
		
	<cfreturn packageCategoryObjects(catsQ) />
</cffunction>


<cffunction name="getLink" access="private" output="false" returntype="struct">
	<cfargument name="id" type="string" required="false" default="" />
	<cfargument name="cache" type="numeric" required="false" default="60" />
	
		<cfset var myQueryString = "">
		<cfset var linksQ = "" />
		<cfset var queryInterface = variables.manager.getQueryInterface()/>
		<cfset var prefix = queryInterface.getTablePrefix() />
		<cfset var link = "" />
		
		<!--- just check that category is a valid id--->
		<cfif isValid("UUID", arguments.id)>
			
			<!--- @TODO: make this a little more secure (in the orderby clause)--->
			<cfsavecontent variable="myQueryString">
				<cfoutput>SELECT * FROM #prefix#link
				WHERE id = '#arguments.id#'</cfoutput>
			</cfsavecontent>
			
			<!--- cache results for 60 minutes --->
			<cfset linksQ = queryInterface.makeQuery(myQueryString,arguments.cache) />
			<cfif linksQ.recordcount>
				<cfset link = packageLinkObjects(linksQ)/>
				<cfreturn link[1] />
			<cfelse><!--- @TODO: throw error if not found instead --->
				<cfreturn "">
			</cfif>
			
		<cfelse>
			<cfreturn "" />
		</cfif>
	
</cffunction>

<cffunction name="getCategory" access="private" output="false" returntype="struct">
	<cfargument name="id" type="string" required="false" default="" />
	<cfargument name="cache" type="numeric" required="false" default="60" />
	
		<cfset var myQueryString = "">
		<cfset var linksQ = "" />
		<cfset var queryInterface = variables.manager.getQueryInterface()/>
		<cfset var prefix = queryInterface.getTablePrefix() />
		<cfset var link_category = "" />
		
		<!--- just check that category is a valid id--->
		<cfif isValid("UUID", arguments.id)>
			
			<!--- @TODO: make this a little more secure (in the orderby clause)--->
			<cfsavecontent variable="myQueryString">
				<cfoutput>SELECT * FROM #prefix#link_category
				WHERE id = '#arguments.id#'</cfoutput>
			</cfsavecontent>
			
			<!--- cache results for 60 minutes --->
			<cfset linksQ = queryInterface.makeQuery(myQueryString,arguments.cache) />
			<cfif linksQ.recordcount>
				<cfset link_category = packageCategoryObjects(linksQ)/>
				<cfreturn link_category[1] />
			<cfelse><!--- @TODO: throw error if not found instead --->
				<cfreturn "">
			</cfif>
			
		<cfelse>
			<cfreturn "" />
		</cfif>
	
</cffunction>

<cffunction name="packageLinkObjects" access="private" output="false" returntype="array">
	<cfargument name="objectsQuery" type="query" required="true" />
	
	<cfset var links = arraynew(1) />
	<cfset var thisObject = "" />

	<cfoutput query="arguments.objectsQuery">
		<cfset thisObject = createObject("component","Link") />
		<cfscript>
			thisObject.id = id;
			thisObject.Title = title;
			thisObject.Description = description;
			thisObject.Address = address;
			thisObject.CategoryId = category_id;
			thisObject.ShowOrder = showOrder;
			arrayappend(links,thisObject);
		</cfscript>

	</cfoutput>
	
	<cfreturn links />
	
</cffunction>

<cffunction name="packageCategoryObjects" access="private" output="false" returntype="array">
	<cfargument name="objectsQuery" type="query" required="true" />
	
	<cfset var categories = arraynew(1) />
	<cfset var thisObject = "" />

	<cfoutput query="arguments.objectsQuery">
		<cfset thisObject = createObject("component","LinkCategory") />
		<cfscript>
			thisObject.id = id;
			thisObject.name = name;
			thisObject.Description = description;
			thisObject.parentCategoryId = parent_category_id;
			arrayappend(categories,thisObject);
		</cfscript>

	</cfoutput>
	
	<cfreturn categories />
	
</cffunction>



</cfcomponent>