<cfcomponent>
 <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="init" output="false" returntype="any" hint="instantiates an object of this class" access="public">
	<cfargument name="queryInterface" required="true">
		
		<cfset variables.queryInterface = arguments.queryInterface />
		<cfset variables.prefix = arguments.queryInterface.getTablePrefix() />
		
		<cfreturn this />
</cffunction>

<cffunction name="editLink" access="package" output="false">
	<cfargument name="id" type="string" required="true" />
	<cfargument name="title" type="string" required="true" />
	<cfargument name="address" type="string" required="true" />
	<cfargument name="description" type="string" required="true" />
	<cfargument name="category" type="string" required="true" />
	<cfargument name="order" type="string" required="false" default="0" />
		
		<cfset var myQueryString = "">

		<cfsavecontent variable="myQueryString"><cfoutput>
			UPDATE #variables.prefix#link
			SET title = '#replacenocase(arguments.title,"'","''",'all')#',
			address = '#replacenocase(arguments.address,"'","''",'all')#',
			description = '#replacenocase(arguments.description,"'","''",'all')#',
			category_id = '#arguments.category#',
			showOrder = #val(arguments.order)#
			WHERE id = '#arguments.id#'
			</cfoutput>
		</cfsavecontent>
			
		<cfset variables.queryInterface.makeQuery(myQueryString,0,false) />
		
	<cfreturn />
</cffunction>


<cffunction name="deleteLink" access="package" output="false">
	<cfargument name="id" type="string" required="true" />
		
		<cfset var myQueryString = "">

		<cfsavecontent variable="myQueryString"><cfoutput>
			DELETE FROM #variables.prefix#link
			WHERE id = '#arguments.id#'
			</cfoutput>
		</cfsavecontent>
			
		<cfset variables.queryInterface.makeQuery(myQueryString,0,false) />
		
	<cfreturn />
</cffunction>

<cffunction name="addLink" access="package" output="false">
	<cfargument name="title" type="string" required="true" />
	<cfargument name="address" type="string" required="true" />
	<cfargument name="description" type="string" required="true" />
	<cfargument name="category" type="string" required="true" />
	<cfargument name="order" type="string" required="false" default="0" />
		
		<cfset var myQueryString = "">

		<cfsavecontent variable="myQueryString"><cfoutput>
			INSERT INTO #variables.prefix#link
			(id, title, address, description, category_id, showOrder) 
			VALUES (
				'#createUUID()#',
				'#replacenocase(arguments.title,"'","''",'all')#',
				'#replacenocase(arguments.address,"'","''",'all')#',
				'#replacenocase(arguments.description,"'","''",'all')#',
				'#arguments.category#',
			 	#val(arguments.order)#
			)
			</cfoutput>
		</cfsavecontent>
			
		<cfset variables.queryInterface.makeQuery(myQueryString,0,false) />
		
	<cfreturn />
</cffunction>


<cffunction name="editCategory" access="package" output="false">
	<cfargument name="id" type="string" required="true" />
	<cfargument name="name" type="string" required="true" />
	<cfargument name="description" type="string" required="true" />
		
		<cfset var myQueryString = "">

		<cfsavecontent variable="myQueryString"><cfoutput>
			UPDATE #variables.prefix#link_category
			SET name = '#replacenocase(arguments.name,"'","''",'all')#',
			description = '#replacenocase(arguments.description,"'","''",'all')#'
			WHERE id = '#arguments.id#'
			</cfoutput>
		</cfsavecontent>
			
		<cfset variables.queryInterface.makeQuery(myQueryString,0,false) />
		
	<cfreturn />
</cffunction>

<cffunction name="addCategory" access="package" output="false">
	<cfargument name="name" type="string" required="true" />
	<cfargument name="description" type="string" required="true" />
	<cfargument name="blog_id" type="string" required="false" default="default" />
		
		<cfset var myQueryString = "">

		<cfsavecontent variable="myQueryString"><cfoutput>
			INSERT INTO #variables.prefix#link_category
			(id, name, description, blog_id) 
			VALUES (
				'#createUUID()#',
				'#replacenocase(arguments.name,"'","''",'all')#',
				'#replacenocase(arguments.description,"'","''",'all')#',
				'#arguments.blog_id#'
			)
			</cfoutput>
		</cfsavecontent>
			
		<cfset variables.queryInterface.makeQuery(myQueryString,0,false) />
		
	<cfreturn />
</cffunction>

<cffunction name="deleteCategory" access="package" output="false">
	<cfargument name="id" type="string" required="true" />
		
		<cfset var myQueryString = "">

		<cfsavecontent variable="myQueryString"><cfoutput>
			DELETE FROM #variables.prefix#link_category
			WHERE id = '#arguments.id#'
			</cfoutput>
		</cfsavecontent>
			
		<cfset variables.queryInterface.makeQuery(myQueryString,0,false) />
		
	<cfreturn />
</cffunction>

</cfcomponent>