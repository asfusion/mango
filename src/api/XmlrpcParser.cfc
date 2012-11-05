<cfcomponent>

	<cffunction name="parseRequest" access="public" output="false" returntype="any">
		<cfargument name="xmlRequest" required="true" type="any">
		
			<cfset var xmlParser = createObject("component","xmlrpc") />
			<cfset var data = xmlParser.XMLRPC2CFML(arguments.xmlRequest) />
			
		<cfif data.method NEQ "Error">
			<cfreturn invokeMethod(data) />
		<cfelse>			
			<cfreturn xmlParser.CFML2XMLRPC(data,"response") />
		</cfif>
		
	</cffunction>

	<cffunction name="invokeMethod" access="public" output="false" returntype="any">
		<cfargument name="data" required="true" type="struct">
			
			<cfset var apiHandler = "" />
			<cfset var methodName = "" />
			<cfset var result = "" />
			<cfset var xmlParser = createObject("component","xmlrpc") />
			<cfset var dot = ""/>
			
			<cfif arguments.data.method EQ "mt.supportedMethods">
				<cfset arguments.data.method = "system.listMethods" />
			</cfif>
			
			<cfif findnocase("blogger",arguments.data.method)>
				<cfset apiHandler = CreateObject("component", "Blogger") />
			<cfelseif findnocase("metaWeblog",arguments.data.method)>
				<cfset apiHandler = CreateObject("component", "MetaWeblog") />
			<cfelseif findnocase("mt",arguments.data.method)>
				<cfset apiHandler = CreateObject("component", "MovableType") />
			<cfelseif findnocase("wp",arguments.data.method)>
				<cfset apiHandler = CreateObject("component", "Wordpress") />
			<cfelseif findnocase("system",arguments.data.method)>
				<cfset apiHandler = CreateObject("component", "XmlrpcParser") />
			</cfif>
		
		<cfset dot = find(".",arguments.data.method) />
		<cfif dot NEQ 0>
			<cfset methodName = mid(arguments.data.method,dot+1,len(arguments.data.method)-dot) />
		<cfelse>
			<cfset methodName = arguments.data.method />
		</cfif>

			<!---invoke method --->
			<cfinvoke component="#apiHandler#" method="#methodName#" returnvariable="result">
				<cfinvokeargument name="data" value="#arguments.data.params#">
			</cfinvoke>
			
		<cfreturn xmlParser.CFML2XMLRPC(result,"response") />
	</cffunction>
	
	<cffunction name="listMethods">
		<cfset var methodNames = arraynew(1) />
		<cfset arrayappend(methodNames,"blogger.getUsersBlogs") />
		
		<cfset arrayappend(methodNames,"mt.getRecentPosts") />
		<cfset arrayappend(methodNames,"metaWeblog.getRecentPosts") />
		<cfset arrayappend(methodNames,"blogger.getRecentPosts") />
		
		<cfset arrayappend(methodNames,"mt.getPost") />
		<cfset arrayappend(methodNames,"metaWeblog.getPost") />
		<cfset arrayappend(methodNames,"blogger.getPost") />
		
		<cfset arrayappend(methodNames,"mt.newPost") />
		<cfset arrayappend(methodNames,"metaWeblog.newPost") />
		<cfset arrayappend(methodNames,"blogger.newPost") />
		
		<cfset arrayappend(methodNames,"mt.editPost") />
		<cfset arrayappend(methodNames,"metaWeblog.editPost") />
		<cfset arrayappend(methodNames,"blogger.editPost") />
		
		<cfset arrayappend(methodNames,"mt.deletePost") />
		<cfset arrayappend(methodNames,"metaWeblog.deletePost") />
		<cfset arrayappend(methodNames,"blogger.deletePost") />
		
		<cfset arrayappend(methodNames,"mt.getUserInfo") />
		<cfset arrayappend(methodNames,"metaWeblog.getUserInfo") />
		<cfset arrayappend(methodNames,"blogger.getUserInfo") />
		
		<cfset arrayappend(methodNames,"mt.getCategoryList") />
		<cfset arrayappend(methodNames,"mt.setPostCategories") />
		<cfset arrayappend(methodNames,"mt.getPostCategories") />
		<cfset arrayappend(methodNames,"metaWeblog.getCategories") />
		<cfset arrayappend(methodNames,"metaWeblog.newMediaObject") />
		
		<!--- all wp functions except wp.suggestCategories  --->
		<cfset arrayappend(methodNames,"wp.getPage") />
		<cfset arrayappend(methodNames,"wp.getPages") />
		<cfset arrayappend(methodNames,"wp.getPageList") />
		<cfset arrayappend(methodNames,"wp.newPage") />
		<cfset arrayappend(methodNames,"wp.deletePage") />
		<cfset arrayappend(methodNames,"wp.editPage") />
		<cfset arrayappend(methodNames,"wp.getAuthors") />
		<cfset arrayappend(methodNames,"wp.getCategories") />
		<cfset arrayappend(methodNames,"wp.newCategory") />
		<cfset arrayappend(methodNames,"wp.deleteCategory") />
		<cfset arrayappend(methodNames,"wp.uploadFile") />
		<cfset arrayappend(methodNames,"wp.getComment") />
		<cfset arrayappend(methodNames,"wp.getComments") />
		
		<cfreturn methodNames />
	</cffunction>

</cfcomponent>