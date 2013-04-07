<cfcomponent extends="Setup">
<!--- this component imports a wordpress blog exported from WP admin in XML format
It is strange that it outputs html, but I wanted to give the user feedback about what 
goes on because it can take a long time to import all the data
 --->
	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="init" access="public" output="true" returntype="any">
		<cfargument name="address" type="String" required="true" />
		<cfargument name="configFile" type="String" required="true" />
		<cfargument name="exportedFile" type="String" required="true" />
		<cfargument name="datasourcename" type="String" required="true" />
		<cfargument name="dbType" type="String" required="true" />
		<cfargument name="prefix" type="String" required="false" default="" />
		<cfargument name="pluginsDir" type="String" required="true" />
		<cfargument name="username" type="String" required="false" default="" />
		<cfargument name="password" type="String" required="false" default="" />
			<cfset variables.componentPath = replacenocase(GetMetaData(this).name,"admin.setup.Importer_Wordpress","components.") />
			<cftry>
				<cfset createObject("component",variables.componentPath & "utilities.Preferences")>
			<cfcatch type="any">
				<!--- if we catch a problem, it means there was a problem finding the path --->
				<cfset variables.componentPath = replace(GetPathFromURL(arguments.address),"/",".",'all') & "components." />
				<cfset variables.componentPath = right(variables.componentPath,len(variables.componentPath)-1) />
				<cfset createObject("component",variables.componentPath & "utilities.Preferences")>
			</cfcatch>
			</cftry>
			<cfif NOT fileexists(arguments.exportedFile)>
				<cfthrow type="ImportConfigFileNotFound" message="Imported data file not found. Please upload again">
			</cfif>
			<cfset variables.exportedFile = arguments.exportedFile />
			<cfset variables.configFile = arguments.configFile />
			<cfset variables.dsn = arguments.datasourcename  />
			<cfset variables.dbType = arguments.dbType  />
			<cfset variables.prefix = arguments.prefix  />			
			<cfset variables.dsnUsername = arguments.username  />
			<cfset variables.dsnPassword = arguments.password  />
			
		<cfreturn this />
	
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="import" access="public" output="true" returntype="struct">
		<cfargument name="blogaddress" type="String" required="false" default="" />
		<cfargument name="email" type="String" required="false" default="" />
			
		<cfset var blogManager = "" />
		<cfset var objectFactory = "" />
		<cfset var blog = "" />
		<cfset var basePath = "" />
		<cfset var result = structnew() />
		<cfset var address = "" />
		<cfset var data = "">
		<cfset var local = structnew() />
		<cfset saveConfig(variables.configFile, arguments.email,variables.defaults["id"] , false) />
			
		<cfset variables.blog = createobject("component",variables.componentPath & "Mango").init(variables.configFile & "config.cfm", variables.defaults["id"], variables.configFile)>
		<cfset blogManager = variables.blog.getBlogsManager()  />
		<cfset objectFactory = variables.blog.getObjectFactory() />
			
		<cfset result.status = true />
		<cfset result.message =  "" />
			
			<cffile action="read" file="#variables.exportedFile#" variable="data">
			<cfset data = xmlparse(data) />
		
			<cfscript>
				if (len(arguments.blogaddress)){
							basePath = GetPathFromURL(arguments.blogaddress);
							address = arguments.blogaddress;
				}
				else{
							basePath = GetPathFromURL(data.rss.channel.link.xmlText);
							address = "http://" & GetHostFromURL(data.rss.channel.link.xmlText) 
					& basePath;
				}
				
				blog = objectFactory.createBlog();
				blog.setId(variables.defaults["id"]);
				blog.setTagline(variables.defaults["tagline"]);
				blog.setTitle(data.rss.channel.title.xmlText);
				blog.setDescription(data.rss.channel.description.xmlText);
				blog.setUrl(address);
				blog.setSkin(variables.defaults["skin"]);
				blog.setBasePath(basePath);
				blog.setCharset(variables.defaults["charset"]);
				blogManager.addBlog(blog);
			</cfscript>
			<cfloop list="#variables.defaults['systemPlugins']#" index="local.i">
				<cfset blogManager.activatePlugin(variables.defaults["id"],local.i,local.i, "system") />
			</cfloop>
			<cfset variables.blog = createobject("component",variables.componentPath & "Mango").init(variables.configFile & "config.cfm", variables.defaults["id"],variables.configFile)>
			<cfset populate(data, arguments.email) />
			<cfset saveConfig(variables.configFile, arguments.email) />
			<cfloop list="#variables.defaults['userPlugins']#" index="local.i">
				<cfset blogManager.activatePlugin(variables.defaults["id"],local.i,local.i, "user") />
			</cfloop>
			<!--- delete the file --->
			<cftry>
				<cffile action="delete" file="#variables.exportedFile#">
				<cfcatch type="any"></cfcatch>
			</cftry>

			<cfreturn result>
	
	</cffunction>	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="populate" access="private" output="true" returntype="void">
		<cfargument name="data" type="xml" required="false" />
		<cfargument name="email" type="string" required="false" />
		
			<cfset var manager = ""/>
			<cfset var objectFactory = "" />
			<cfset var thisBlog = ""/>
			<cfset var categorykeys = structnew() />
			<cfset var authorkeys = structnew() />
			<cfset var pagekeys = structnew() />
			<cfset var categories = "" />
			<cfset var obj = "" />
			<cfset var i = 1/>
			<cfset var j = 1 />
			<cfset var key = "">
			<cfset var author = "">
			<cfset var result = "" />
			<cfset var parent = "">
			<cfset var root = arguments.data.rss.channel />
			<cfset var blogId = variables.defaults["id"]>
			<cfset var administrator = variables.blog.getAdministrator() />
									
			<cfset thisBlog = variables.blog.getBlog() />
			
			<cfset objectFactory = variables.blog.getObjectFactory() />
			
			
			<cfset manager = variables.blog.getCategoriesManager() />
			
			<!---:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
			<!--- Categories --->
			<cfoutput>Importing categories...<br /><ul></cfoutput>
			
			<cfloop from="1" to="#arraylen(root.category)#" index="i">
				<li>#root.category[i].cat_name.xmlText#</li>
				
				<cfscript>
					obj = objectFactory.createCategory();
					obj.setname(root.category[i].category_nicename.xmlText);
					obj.setTitle(root.category[i].cat_name.xmlText);
					obj.setCreationDate(now());
					obj.setBlogId(blogId);	
						
					key = manager.addCategory(obj).newCategory.getId();
					categorykeys[root.category[i].cat_name.xmlText] = key;
				</cfscript>
				
			</cfloop>
			<!--- Adds tags also as categories --->
			<cfif structkeyexists(root, "tag")>
				<cfloop from="1" to="#arraylen(root.tag)#" index="i">
					<li>#root.tag[i].tag_name.xmlText#</li>
					
					<cfscript>
						obj = objectFactory.createCategory();
						obj.setname(root.tag[i].tag_slug.xmlText);
						obj.setTitle(root.tag[i].tag_name.xmlText);
						obj.setCreationDate(now());
						obj.setBlogId(blogId);	
							
						key = manager.addCategory(obj).newCategory.getId();
						categorykeys[root.tag[i].tag_name.xmlText] = key;
					</cfscript>
					
				</cfloop>
			</cfif>
			
			<cfset manager = variables.blog.getAuthorsManager() />
			<cfoutput></ul>Importing authors...<br /><ul></cfoutput>
			<cfloop from="1" to="#arraylen(root.item)#" index="i">
				<cfset author = Left(root.item[i].creator.xmltext,50) />
					<cfif NOT structkeyexists(authorkeys,author)>
						<li>Username: #author# - Password: password</li>	
						<cfset result = administrator.newAuthor(author,"password",author,arguments.email
								,'','','','administrator') />				
						<cfscript>
							key = result.newAuthor.getId();
							if (len(key)){
								authorkeys[author] = key;
							}							
						</cfscript>
					</cfif>	
			</cfloop>
			
			
			<!---:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
			<!--- Posts & pages --->
			<cfoutput></ul>Importing posts and pages...<br /><ul></cfoutput>
			
			<cfloop from="1" to="#arraylen(root.item)#" index="i">
			<li>#root.item[i].title.xmlText# 
				
				<cfscript>
					if (root.item[i].post_type.xmltext EQ "post"){
						key = administrator.newPost(root.item[i].title.xmlText, root.item[i].encoded.xmltext, "", 
											root.item[i].status.xmltext EQ "publish", authorkeys[root.item[i].creator.xmltext],
											root.item[i].comment_status.xmltext EQ "open", root.item[i].post_date.xmltext).newPost.getId();
					}
					else {
						//a page
						if (root.item[i].post_parent.xmltext NEQ 0 AND structkeyexists(pagekeys,root.item[i].post_parent.xmltext))
							parent = pagekeys[root.item[i].post_parent.xmltext];
						else
							parent = '';
							
						key = administrator.newPage(root.item[i].title.xmlText, root.item[i].encoded.xmltext, "",
											root.item[i].status.xmltext EQ "publish", parent, "", i, authorkeys[root.item[i].creator.xmltext],
											root.item[i].comment_status.xmltext EQ "open").newPage.getId();
						if (len(key))
							pagekeys[root.item[i].post_id.xmltext] = key;
					}
				</cfscript>
			
			<!--- Post categories --->
			<cfif len(key) AND structkeyexists(root.item[i], "category") AND root.item[i].post_type.xmltext EQ "post">
				<cfset categories = arraynew(1) />
				<cfloop from="1" to="#arraylen(root.item[i].category)#" index="j">					
					<cfset categories = arrayAppendUnique(categories, categorykeys[root.item[i].category[j].xmlText]) />
				</cfloop>
				<cfset administrator.setPostCategories(key, categories) />
			</cfif>
				
				
				
			<!---:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
			<!--- Comments --->
				<cfif len(key) AND structkeyexists(root.item[i], "comment")>
					<!--- loop over comments for this post --->
					<cfloop from="1" to="#arraylen(root.item[i].comment)#" index="j">
						<cfif root.item[i].comment[j].comment_approved.xmlText NEQ "spam">
						<cfset administrator.newComment(key, root.item[i].comment[j].comment_content.xmlText, 
								root.item[i].comment[j].comment_author.xmlText, root.item[i].comment[j].comment_author_email.xmlText, 
								root.item[i].comment[j].comment_author_url.xmlText, root.item[i].comment[j].comment_approved.xmlText, 
								true, root.item[i].comment[j].comment_date.xmlText) />
						</cfif>
					</cfloop>
					(#j-1# comments)
				</cfif>
				</li>
				
			</cfloop>
			
		<cfreturn />
	</cffunction>
	
	<cfscript>
/**
* Appends a value to an array if the value does not already exist within the array.
* 
* @param a1      The array to modify. 
* @param val      The value to append. 
* @return Returns a modified array or an error string. 
* @author Craig Fisher (craig@altainteractive.com) 
* @version 1, October 29, 2001 
*/
function ArrayAppendUnique(a1,val) {
    if ((NOT IsArray(a1))) {
        writeoutput("Error in <Code>ArrayAppendUnique()</code>! Correct usage: ArrayAppendUnique(<I>Array</I>, <I>Value</I>) -- Appends <em>Value</em> to the array if <em>Value</em> does not already exist");
        return 0;
    }
    if (NOT ListFind(Arraytolist(a1), val)) {
        arrayAppend(a1, val);
    }
    return a1;
}
</cfscript>
	
</cfcomponent>