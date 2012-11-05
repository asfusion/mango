<cfcomponent name="Verity">

	<cfproperty name="collectionsPath" type="string" />
	<cfproperty name="language" type="string" />
	<cfset variables.postsCollection = "posts_" />
	<cfset variables.pagesCollection = "pages_" />
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="settings" type="struct" default="#structnew()#" required="false" />
		<cfargument name="language" type="string" default="English" required="false" />
		<cfargument name="blogid" type="string" required="false" default="default" />
		
		<cfset variables.language = arguments.language />
		<cfif NOT structkeyexists(arguments.settings,"collectionsPath") OR NOT len(arguments.settings.collectionsPath)>
			<cfset variables.collectionsPath = getDirectoryFromPath(GetCurrentTemplatePath()) & "collections" />
		<cfelse>
			<cfset variables.collectionsPath = arguments.settings.collectionsPath />
		</cfif>
		
		<cfset variables.postsCollection = variables.postsCollection  & arguments.blogid &  hash(variables.collectionsPath) />		
		<cfset variables.pagesCollection = variables.pagesCollection  & arguments.blogid &  hash(variables.collectionsPath) />
		
		<!--- check directory for collections --->
		<cfset setupCollections() />
		<cfreturn this/>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCollectionsPath" access="public" output="false" returntype="string">
		<cfreturn variables.collectionsPath />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
	<cffunction name="setCollectionsPath" access="public" output="false" returntype="void">
		<cfargument name="collectionsPath" type="string" required="true" />
		<cfset variables.collectionsPath = arguments.collectionsPath />
		<cfreturn />
	</cffunction>
--->
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getLanguage" access="public" output="false" returntype="string">
		<cfreturn variables.language />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setLanguage" access="public" output="false" returntype="void">
		<cfargument name="language" type="string" required="true" />
		<cfset variables.language = arguments.language />
		<cfreturn />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="indexPost" access="public" output="false" returntype="boolean">
		<cfargument name="post" type="Any" required="true" />
		<cfargument name="comments" type="array" default="#arraynew(1)#" required="false" />
		
			<cfset var postData = arguments.post.getInstanceData() />
		<!--- @TODO add comments to data --->
		<cftry>			
				<cfindex collection="#variables.postsCollection#" action="update" 
				type="custom" key="#postData.id#" body="#postData.content##postData.title##postData.excerpt#" 
					title="#postData.title#" category="#postData.categoryList#"> 

		<cfcatch type="Any">
			<cfreturn false />
		</cfcatch> 
	</cftry>

		<cfreturn true/>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="indexPage" access="public" output="false" returntype="boolean">
		<cfargument name="page" type="Any" required="true" />
		<cfargument name="comments" type="array" default="#arraynew(1)#" required="false" />

		<cfset var postData = arguments.page.getInstanceData() />
		<!--- @TODO add comments to data --->
		<cftry>			
				<cfindex collection="#variables.pagesCollection#" action="update" 
				type="custom" key="#postData.id#" body="#postData.content##postData.title##postData.excerpt#" 
					title="#postData.title#" categoryTree="#postData.hierarchy#"> 

		<cfcatch type="Any">
			<cfreturn false />
		</cfcatch> 
	</cftry>

		<cfreturn true/>
		
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deletePost" access="public" output="false" returntype="boolean">
		<cfargument name="post" type="Any" required="true" />
		
		<cfset var postData = arguments.post.getInstanceData() />

		<cftry>			
				<cfindex collection="#variables.postsCollection#" action="delete" 
				type="custom" key="#postData.id#"> 

		<cfcatch type="Any">
			<cfreturn false />
		</cfcatch> 
	</cftry>

		<cfreturn true/>
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deletePage" access="public" output="false" returntype="boolean">
		<cfargument name="page" type="Any" required="true" />
		
		<cfset var postData = arguments.page.getInstanceData() />

		<cftry>			
				<cfindex collection="#variables.pagesCollection#" action="delete" 
				type="custom" key="#postData.id#"> 

		<cfcatch type="Any">
			<cfreturn false />
		</cfcatch> 
	</cftry>

		<cfreturn true/>
	</cffunction>		
	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="optimize" access="public" output="false" returntype="boolean">

		<cftry>			
				<cfindex collection="#variables.postsCollection#" action="optimize"> 
				<cfindex collection="#variables.pagesCollection#" action="optimize"> 
		<cfcatch type="Any">
			<cfreturn false />
		</cfcatch> 
	</cftry>

		<cfreturn true/>
	</cffunction>	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setupCollections" access="public" output="false" returntype="boolean">
		<cfargument name="blogid" type="string" required="false" default="default" />
		
		<cftry> 
			<cfif NOT directoryexists(variables.collectionsPath & variables.postsCollection)>
				<cfcollection action="create" collection="#variables.postsCollection#" path="#variables.collectionsPath#" categories="true">
			</cfif>
			<cfif NOT directoryexists(variables.collectionsPath & variables.pagesCollection)>
				<cfcollection action="create" collection="#variables.pagesCollection#" path="#variables.collectionsPath#" categories="true">
			</cfif>
		<cfcatch type="Any">
			<cfreturn false />
		</cfcatch> 
	</cftry>
		<cfreturn true/>
	</cffunction>	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="searchPosts" access="public" output="false" returntype="Any">
		<cfargument name="criteria" type="String" required="false" />
		<cfargument name="category" type="String" required="false" />
		<cfargument name="categoryTree" type="String" required="false" />
		<cfargument name="blogid" type="string" required="false" default="default" />
				
			<cfset var results = "" />
			<cfsearch name="results" collection="#variables.postsCollection#" 
						criteria="#LCase(arguments.criteria)#" status="extra" suggestions="20" type="internet">
		<cfreturn results />
	</cffunction>
	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="searchPages" access="public" output="false" returntype="Query">
		<cfargument name="criteria" type="String" required="true" />
		<cfargument name="parentTree" type="String" required="false" />
		<cfargument name="blogid" type="string" required="false" default="default" />
		
			<cfset var results = "" />
			<cfsearch name="results" collection="#variables.pagesCollection#" 
						criteria="#LCase(arguments.criteria)#" status="extra" suggestions="20"  type="internet">
		<cfreturn results />
	</cffunction>	
	
</cfcomponent>

