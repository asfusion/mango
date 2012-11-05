<cfcomponent extends="Setup">
<!--- this component imports any number of blogs from blogCFC
It is strange that it outputs html, but I wanted to give the user feedback about what 
goes on because it can take a long time to import all the data
 --->

	<cfset variables.authorKeys = structnew() />			

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="init" access="public" output="true" returntype="any">
		<cfargument name="address" type="String" required="true" />
		<cfargument name="configFile" type="String" required="true" />
		<cfargument name="iniFile" type="String" required="true" />
		<cfargument name="datasourcename" type="String" required="true" />
		<cfargument name="dbType" type="String" required="true" />
		<cfargument name="prefix" type="String" required="false" default="" />
		
		<cfargument name="username" type="String" required="false" default="" />
		<cfargument name="password" type="String" required="false" default="" />
			
			<!--- attempt to get the components path --->
			<cfset variables.componentPath = replacenocase(GetMetaData(this).name,"admin.setup.Importer_BlogCFC_5x","components.") />
			<cftry>
				<cfset createObject("component",variables.componentPath & "utilities.Preferences")>
			<cfcatch type="any">
				<!--- if we catch a problem, it means there was a problem finding the path --->
				<cfset variables.componentPath = replace(GetPathFromURL(arguments.address),"/",".",'all') & "components." />
				<cfset variables.componentPath = right(variables.componentPath,len(variables.componentPath)-1) />
				<cfset createObject("component",variables.componentPath & "utilities.Preferences")>
			</cfcatch>
			</cftry>
					
			<cfif NOT fileexists(arguments.iniFile)>
				<cfthrow type="ImportConfigFileNotFound" message="ini file not found. Please check path and try again">
			</cfif>
			<cfset variables.iniFile = arguments.iniFile />
			<cfset variables.configFile = arguments.configFile />
			<cfset variables.dsn = arguments.datasourcename  />
			<cfset variables.dsnUsername = arguments.username  />
			<cfset variables.dsnPassword = arguments.password  />
			<cfset variables.dbType = arguments.dbType  />
			<cfset variables.prefix = arguments.prefix  />			
			
		<cfreturn this />
	
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="import" access="public" output="true" returntype="struct">
		<cfargument name="blogaddress" type="String" required="false" default="" />
			
			<cfset var profiles = GetProfileSections(variables.iniFile) />
			<cfset var profile = ""/>
			<cfset var mangoprofile = "" />
			<cfset var blogManager = "" />
			<cfset var objectFactory = "" />
			<cfset var blog = "" />
			<cfset var basePath = "" />
			<cfset var result = structnew() />
			<cfset var dsn = structnew() />
			<cfset var address = "" />
			<cfset var profileList = "" />
			<cfset var email = "" />
			<cfset var profileNumber = 0 />
			<cfset var local = structnew() />
			
			<cfset result.status = true />
			<cfset result.message =  "" />
			<cfset variables.defaults["userPlugins"] = variables.defaults["userPlugins"] & ",blogcfcRedirecter" />
			
			<cfloop collection="#profiles#" item="profile">
				<cfset profileList = listappend(profileList,profile) />
			</cfloop>
			
			<cfloop collection="#profiles#" item="profile">
				<cfset profileNumber = profileNumber + 1 />
				<cfif profileNumber EQ 1 AND NOT listfindnocase(profileList, variables.defaults["id"])>
					<!--- there is no  default profile in blogcfc. we need one, so let's use the first one as default --->
					<cfset mangoprofile = variables.defaults["id"] />
				<cfelse>
					<cfset mangoprofile = profile />
				</cfif>
				
				<cfset email = GetProfileString(variables.iniFile, profile, "owneremail") />
				<cfset saveConfig(mangoprofile, email) />
				
				<cfset variables.blog = createobject("component",variables.componentPath & "Mango").init(variables.configFile & "config.cfm", mangoprofile, variables.configFile)>
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
					blog.setId(mangoprofile);
					blog.setTitle(GetProfileString(variables.iniFile, profile, "blogTitle"));
					blog.setDescription(GetProfileString(variables.iniFile, profile, "blogDescription"));
					blog.setUrl(address);
					blog.setSkin(variables.defaults["skin"]);
					blog.setBasePath(basePath);
					blog.setCharset(variables.defaults["charset"]);
					blogManager.addBlog(blog);
				</cfscript>
				<cfloop list="#variables.defaults['systemPlugins']#" index="local.i">
					<cfset blogManager.activatePlugin(mangoprofile,local.i,local.i, "system") />
				</cfloop>
				<cfset variables.blog = createobject("component",variables.componentPath & "Mango").init(variables.configFile & "config.cfm", mangoprofile, variables.configFile)>
				<cfset populate(GetProfileString(variables.iniFile, profile, "dsn"),profile) />
				<!--- once everything is ok, save --->
				<cfset saveConfig(mangoprofile, email) />
				<cfloop list="#variables.defaults['userPlugins']#" index="local.i">
					<cfset blogManager.activatePlugin(mangoprofile,local.i,local.i, "user") />
				</cfloop>
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
			<cfset var key = "" />
			<cfset var thisBlog = ""/>
			<cfset var categorykeys = structnew() />
			<cfset var entrykeys = structnew() />
			<cfset var i = 1/>
			<cfset var tempQuery = "">
			<cfset var newexcerpt = "">
			<cfset var administrator = variables.blog.getAdministrator() />
			<cfset var author = "" />
			<cfset var result = "" />
			<cfset var categories = "" />		
			<cfset var customFields = '' />	
									
			<cfset thisBlog = variables.blog.getBlog() />
			<cfset blogManager = variables.blog.getBlogsManager() />
			<cfset objectFactory = variables.blog.getObjectFactory() />
			
			<cfquery name="originalQuery" datasource="#arguments.datasource#">
				select 	username, password
				from	tblusers
			</cfquery>
			
			<cfoutput>Getting users...<br /><ul></cfoutput>
			
			<cfoutput query="originalQuery">
		<!---		<cftry> ---><li>#username#</li>
					<cfset result = administrator.newAuthor(username,password,username,
									GetProfileString(variables.iniFile, arguments.profile, "owneremail"),'','','administrator') />
		
					<cfscript>
						key = result.newAuthor.getId();
						if (len(key)){
							variables.authorkeys[username] = key;
							author = key;
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
				
			<cfoutput></ul>Getting entries...<br />
			<ul>
			</cfoutput>
			
			<cfquery name="originalQuery" datasource="#arguments.datasource#">
				select 	*
				from	tblblogentries
				WHERE blog = '#profile#'
				ORDER BY posted
			</cfquery>
			
			<cfoutput query="originalQuery"><li>#title#</li>
				<cftry>
					<cfscript>
						
						if (len(morebody)) {
							newexcerpt = body;
						}
						else
							newexcerpt = "";
						
						//store old ids and alias in custom fields
						customFields = structnew();
						customFields['blogcfc_alias'] = structnew();
						customFields['blogcfc_alias'].name = "BlogCFC Alias";
						customFields['blogcfc_alias'].key = 'blogcfc_alias';
						customFields['blogcfc_alias'].value = alias;
						
						customFields['blogcfc_id'] = structnew();
						customFields['blogcfc_id'].name = "BlogCFC Entry ID";
						customFields['blogcfc_id'].key = 'blogcfc_id';
						customFields['blogcfc_id'].value = id;
						
						key = administrator.newPost(title,body & morebody, newexcerpt, 
											released, variables.authorkeys[username],
											allowcomments, posted,'',customFields).newPost.getId();
						entrykeys[id] = key;
					</cfscript>
					
					<cfif len(enclosure)>
						<!--- @TODO: temporary add enclosures this way --->
						<cfquery name="tempQuery"  datasource="#variables.dsn#" username="#variables.dsnUsername#" password="#variables.dsnPassword#">
							INSERT INTO #variables.prefix#media
							(id,entry_id, url, filesize, type )
							VALUES ('#createUUID()#','#key#', '#GetFileFromPath(enclosure)#',#filesize#,'#mimetype#')
			  			</cfquery>
					</cfif>			
					<cfcatch type="any">
					</cfcatch>
				</cftry>
				
			</cfoutput>				
			
			<cfoutput></ul>Getting categories for entries...<br /></cfoutput>
			
			<cfquery name="originalQuery" datasource="#arguments.datasource#">
				select 	tblblogentriescategories.*
				from	tblblogentries INNER JOIN
                      tblblogentriescategories ON tblblogentries.id = tblblogentriescategories.entryidfk
				WHERE tblblogentries.blog = '#profile#'
				ORDER BY entryidfk
			</cfquery>
			
			<cfoutput query="originalQuery" group="entryidfk">
				<cftry>
					<cfset categories = arraynew(1) />
					<cfoutput>
						<cfset arrayappend(categories, categorykeys[categoryidfk]) />		
					</cfoutput>
					<cfset administrator.setPostCategories(entrykeys[entryidfk], categories) />
					<cfcatch type="any">
					</cfcatch>
				</cftry>			
			</cfoutput>
			
			<!---:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
			<!--- Comments --->
			<cfset manager = variables.blog.getCommentsManager() />
			
			<cfoutput>Getting comments...<br /></cfoutput>
			
			<cfquery name="originalQuery" datasource="#arguments.datasource#">
				select 	tblblogcomments.*
				from tblblogcomments INNER JOIN
                  tblblogentries ON tblblogcomments.entryidfk = tblblogentries.id
				WHERE   tblblogentries.blog =  '#profile#'
			</cfquery>
			<ul><li>Total: #originalQuery.recordcount#</li></ul>
			<cfoutput query="originalQuery">
			<!---	<cftry> --->
			<cfset administrator.newComment(entrykeys[entryidfk], comment, 
								name, email, website, 1, true, posted) />
			<!--- 	<cfscript>
					obj = structnew();
					obj["comment_post_id"] = entrykeys[entryidfk];
					obj["comment_content"] = comment;
					obj["comment_name"] = name;
					obj["comment_email"] = email;
					obj["isImport"] = true;
					obj["comment_website"] = website;
					obj["comment_created_on"] = posted;
					obj["subscribe"] = subscribe;
					obj["comment_parent"] = "";
				</cfscript>
					
				<cfset manager.addCommentFromRawData(obj) /> --->
					
				<!---
			<cfcatch type="any">
					</cfcatch>
				</cftry> --->				
			</cfoutput>
			
			<cfoutput>Getting pages...<br /><ul></cfoutput>
			
			<cfquery name="originalQuery" datasource="#arguments.datasource#">
				select 	*
				from	tblblogpages
				WHERE blog = '#profile#'
			</cfquery>
			
			<cfoutput query="originalQuery"><li>#title#</li>
				<cftry>
					<cfscript>
						//store old ids and alias in custom fields
						customFields = structnew();
						customFields['blogcfc_alias'] = structnew();
						customFields['blogcfc_alias'].name = "BlogCFC Alias";
						customFields['blogcfc_alias'].key = 'blogcfc_alias';
						customFields['blogcfc_alias'].value = alias;
						
						customFields['blogcfc_id'] = structnew();
						customFields['blogcfc_id'].name = "BlogCFC Entry ID";
						customFields['blogcfc_id'].key = 'blogcfc_id';
						customFields['blogcfc_id'].value = id;
						
						administrator.newPage(title, body, "", 1 , "", "", currentrow, author, 0, '',customFields).newPage.getId();
					</cfscript>
					
					<cfcatch type="any">
					</cfcatch>
				</cftry>
				
			</cfoutput>
			<cfoutput></ul>Getting trackbacks...</cfoutput>
			<cfquery name="originalQuery" datasource="#arguments.datasource#">
				select 	*
				from	tblblogtrackbacks
				WHERE blog = '#profile#'
			</cfquery>
			
			<cfoutput query="originalQuery">
				<cftry>
					<cfquery name="tempQuery"  datasource="#variables.dsn#" username="#variables.dsnUsername#" password="#variables.dsnPassword#">
						INSERT INTO #variables.prefix#trackback
						(id,entry_id, content, title, creator_url, creator_url_title, created_on, approved )
						VALUES ('#createUUID()#','#entrykeys[entryid]#', '#excerpt#',  '#title#','#posturl#', '#blogname#', '#created#', 1)
			  		</cfquery>		
					
					<cfcatch type="any">
					</cfcatch>
				</cftry>
				
			</cfoutput>
		<cfreturn />
	</cffunction>
	
		
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="saveConfig" access="public" output="false" returntype="struct">
		<cfargument name="id" type="String" required="true" />
		<cfargument name="email" type="String" required="true" />

			<cfset var result = structnew() />

			<cfset super.saveConfig(variables.configFile, arguments.email, arguments.id) />
		
			<cfset result.status = true />
			<cfset result.message =  "" />
			
		<cfreturn result/>
	</cffunction>
	
</cfcomponent>