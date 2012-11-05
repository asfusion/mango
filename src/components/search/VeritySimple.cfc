<cfcomponent name="VeritySimple" extends="Verity">


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="indexPost" access="public" output="false" returntype="boolean">
		<cfargument name="post" type="Any" required="true" />
		<cfargument name="comments" type="array" default="#arraynew(1)#" required="false" />
		
			<cfset var postData = arguments.post.getInstanceData() />
		<!--- @TODO add comments to data --->
		<cftry>			
				<cfindex collection="#variables.postsCollection#" action="update" 
				type="custom" key="#postData.id#" body="#postData.content##postData.title##postData.excerpt#" 
					title="#postData.title#"> 

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
					title="#postData.title#"> 

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
				<cfcollection action="create" collection="#variables.postsCollection#" path="#variables.collectionsPath#">
			</cfif>
			<cfif NOT directoryexists(variables.collectionsPath & variables.pagesCollection)>
				<cfcollection action="create" collection="#variables.pagesCollection#" path="#variables.collectionsPath#">
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

