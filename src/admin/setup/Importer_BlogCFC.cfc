<cfcomponent extends="Setup">
<!--- this component imports any number of blogs from blogCFC
It is strange that it outputs html, but I wanted to give the user feedback about what 
goes on because it can take a long time to import all the data
 --->

	<cfset variables.authorKeys = structnew() />			

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="init" access="public" output="true" returntype="any">
		<cfargument name="configFile" type="String" required="true" />
		<cfargument name="iniFile" type="String" required="true" />
		<cfargument name="datasourcename" type="String" required="true" />
		<cfargument name="dbType" type="String" required="true" />
		<cfargument name="prefix" type="String" required="false" default="" />
		<cfargument name="pluginsDir" type="String" required="true" />
		
			<cfset variables.componentPath = replacenocase(GetMetaData(this).name,"admin.setup.Importer_BlogCFC","components.") />
					
			<cfif NOT fileexists(arguments.iniFile)>
				<cfthrow type="ImportConfigFileNotFound" message="ini file not found. Please check path and try again">
			</cfif>
			<cfset variables.iniFile = arguments.iniFile />
			<cfset variables.configFile = arguments.configFile />
			<cfset variables.dsn = arguments.datasourcename  />
			<cfset variables.dbType = arguments.dbType  />
			<cfset variables.prefix = arguments.prefix  />			
			<cfset variables.pluginsDir = arguments.pluginsDir  />		
			
		<cfreturn this />
	
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="import" access="public" output="true" returntype="struct">
		<cfargument name="blogaddress" type="String" required="false" default="" />
			
			<cfset var profiles = GetProfileSections(variables.iniFile) />
			<cfset var profile = ""/>
			<cfset var blogManager = "" />
			<cfset var objectFactory = "" />
			<cfset var blog = "" />
			<cfset var basePath = "" />
			<cfset var result = structnew() />
			<cfset var dsn = structnew() />
			<cfset var address = "" />
			<cfset var profileList = "" />
			<cfset var email = "" />
			
			<cfset result.status = true />
			<cfset result.message =  "" />
			
			<cfloop collection="#profiles#" item="profile">
				<cfset profileList = listappend(profileList,profile) />
			</cfloop>
			
			<cfloop collection="#profiles#" item="profile">
				
				<cfset email = GetProfileString(variables.iniFile, profile, "owneremail") />
				<cfset saveConfig(profile,email) />
				
				<cfset variables.blog = createobject("component",variables.componentPath & "Mango").init(variables.configFile & "config.cfm",profile)>
				<cfset blogManager = variables.blog.getBlogsManager()  />
				<cfset objectFactory = variables.blog.getObjectFactory() />
				<cfoutput><h4>Transferring blog: #profile#</h4></cfoutput>
				<cfscript>
					if (len(arguments.blogaddress)){
							basePath = GetPathFromURL(arguments.blogaddress);
							address = arguments.blogaddress;
					}
					else{
							basePath = GetPathFromURL(GetProfileString(variables.iniFile, profile, "blogURL"));
							address = "http://" & GetHostFromURL(GetProfileString(variables.iniFile, profile, "blogURL")) 
						& basePath;
					}
					blog = objectFactory.createBlog();
					blog.setId(profile);
					blog.setTitle(GetProfileString(variables.iniFile, profile, "blogTitle"));
					blog.setDescription(GetProfileString(variables.iniFile, profile, "blogDescription"));
					blog.setUrl(address);
					blog.setSkin(variables.defaults["skin"]);
					blog.setBasePath(basePath);
					blog.setCharset(variables.defaults["charset"]);
					blogManager.addBlog(blog);
				</cfscript>
				<cfset populate(GetProfileString(variables.iniFile, profile, "dsn"),profile) />
			</cfloop>

			<cfreturn result>
	
	</cffunction>	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="populate" access="private" output="true" returntype="void">
		<cfargument name="datasource" type="String" required="false" />
		<cfargument name="profile" type="String" required="false" />
		
			<cfset var originalQuery =  ""/>
			<cfset var manager = ""/>
			<cfset var objectFactory = "" />
			<cfset var blogManager = "" />
			<cfset var obj = "" />
			<cfset var obj2 = "" />
			<cfset var key = "" />
			<cfset var thisBlog = ""/>
			<cfset var categorykeys = structnew() />
			<cfset var i = 1/>
									
			<cfset thisBlog = variables.blog.getBlog() />
			<cfset manager = variables.blog.getAuthorsManager() />
			<cfset blogManager = variables.blog.getBlogsManager() />
			<cfset objectFactory = variables.blog.getObjectFactory() />
			
			<cfquery name="originalQuery" datasource="#arguments.datasource#">
				select 	username, password
				from	tblusers
			</cfquery>
			
			<cfoutput>Getting users...<br /><ul></cfoutput>
			
			<cfoutput query="originalQuery">
		<!---		<cftry> ---><li>#username#</li>
					<cfscript>
						obj = objectFactory.createAuthor();
						obj.setUsername(username);
						obj.setPassword(password);
						obj.setName(username);
						obj.setEmail(GetProfileString(variables.iniFile, arguments.profile, "owneremail"));
						
						key = manager.addAuthor(obj).newAuthor.getId();
						if (len(key)){
							variables.authorkeys[username] = key;
						}							
					</cfscript>
										
			<!---		<cfcatch type="any">
					</cfcatch>
				</cftry> --->
			</cfoutput>
			
			<cfset manager = variables.blog.getCategoriesManager() />
			
			<cfoutput></ul>Getting categories...<br /><ul></cfoutput>
			
			<cfquery name="originalQuery" datasource="#arguments.datasource#">
				select 	*
				from	tblblogcategories
				WHERE blog = '#profile#'
			</cfquery>
			
			<cfoutput query="originalQuery"><li>#categoryname#</li>
			<!---	<cftry> --->
					<cfscript>
						obj = objectFactory.createCategory();
						//obj.setname(categoryname);
						obj.setTitle(categoryname);
						obj.setCreationDate(now());
						obj.setBlogId(blog);				
						
						key = manager.addCategory(obj).newCategory.getId();
						categorykeys[categoryid] = key;
						//@TODO add duplicates to key
					</cfscript>
										
		<!---			<cfcatch type="any">
					</cfcatch>
				</cftry> --->
			</cfoutput>
			
			<cfset manager = variables.blog.getPostsManager() />
			
			<cfoutput></ul>Getting entries...<br />
			<ul>
			</cfoutput>
			
			<cfquery name="originalQuery" datasource="#arguments.datasource#">
				select 	*
				from	tblblogentries
				WHERE blog = '#profile#'
				ORDER BY posted
			</cfquery>
			
			<cfoutput query="originalQuery"><li>#title#
			<!---	<cftry> --->
					<cfscript>
						obj = objectFactory.createPost();
						obj.setId(id);
						obj.setName(alias);
						obj.setTitle(title);
						obj.setContent(body & morebody);
						if (len(morebody)) {
							obj.setExcerpt(body);
						}
						obj.setAuthorId(variables.authorkeys[username]);
						obj.setCommentsAllowed(allowcomments);
						obj.setStatus('published');
						obj.setLastModified(now());
						obj.setPostedOn(posted);
						obj.setBlogId(blog);					
						
						key = manager.addPost(obj,structnew()).newPost.getId();
					//	categorykeys[categoryid] = key;

					</cfscript>
										
		<!---			<cfcatch type="any">
					</cfcatch>
				</cftry> --->
				</li>
			</cfoutput>				
			
			<cfoutput></ul>Getting categories for entries...<br /></cfoutput>
			
			<cfquery name="originalQuery" datasource="#arguments.datasource#">
				select 	tblblogentriescategories.*
				from	tblBlogEntries INNER JOIN
                      tblBlogEntriesCategories ON tblBlogEntries.id = tblBlogEntriesCategories.entryidfk
				WHERE tblBlogEntries.blog = '#profile#'
				ORDER BY entryidfk
			</cfquery>
			
			<cfoutput query="originalQuery" group="entryidfk">
				<cfset obj2 = entryidfk>
				<cfset i = 0 />
				<cfset obj = arraynew(1)>
				<cftry>
					<cfoutput>
						<cfset i = i + 1 />
						<cfset 	obj[i] = categorykeys[categoryidfk] />
						<cfset manager.setPostCategories(obj2,obj) />					
					</cfoutput>
					<cfcatch type="any">
					</cfcatch>
				</cftry>			
			</cfoutput>
			
			<!---:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
			<!--- Comments --->
			<cfset manager = variables.blog.getCommentsManager() />
			
			<cfoutput>Getting comments...<br /></cfoutput>
			
			<cfquery name="originalQuery" datasource="#arguments.datasource#">
				select 	tblBlogComments.*
				from tblBlogComments INNER JOIN
                  tblBlogEntries ON tblBlogComments.entryidfk = tblBlogEntries.id
				WHERE   tblBlogEntries.blog =  '#profile#'
			</cfquery>
			
			<cfoutput query="originalQuery">
			<!---	<cftry> --->
				<cfscript>
					obj = structnew();
					obj["comment_post_id"] = entryidfk;
					obj["comment_content"] = comment;
					obj["comment_name"] = name;
					obj["comment_email"] = email;
					obj["isImport"] = true;
					obj["comment_website"] = website;
					obj["comment_created_on"] = posted;
					obj["subscribe"] = subscribe;
					obj["comment_parent"] = "";
				</cfscript>
					
				<cfset manager.addCommentFromRawData(obj) />
					
				<!---
			<cfcatch type="any">
					</cfcatch>
				</cftry> --->				
			</cfoutput>
			
		<cfreturn />
	</cffunction>
	
		
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="saveConfig" access="public" output="false" returntype="struct">
		<cfargument name="id" type="String" required="true" />
		<cfargument name="email" type="String" required="true" />

			<cfset var result = structnew() />
			<cfset var assetsDirectory = "" />
			
			<cfset var setupObj = CreateObject("component", "Setup").init(variables.dsn, variables.dbType, variables.prefix)/>
			<cfset setupObj.saveConfig(variables.configFile, arguments.email, arguments.id) />
			
			<cfset result.status = true />
			<cfset result.message =  "" />
			
			

		<cfreturn result/>
	</cffunction>
	
	
	
</cfcomponent>