<cfcomponent extends="Setup">
<!--- this component imports a Blogger blog exported from admin in Blogger Atom export format
This component was created based on the Importer_Wordpress.cfc
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
			<cfset variables.componentPath = replacenocase(GetMetaData(this).name,"admin.setup.Importer_Blogger","components.") />
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
			<cfset variables.address = arguments.address  />
			
		<cfreturn this />
	
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="import" access="public" output="true" returntype="struct">
		<cfargument name="blogaddress" type="String" required="false" default="" />
		<cfargument name="email" type="String" required="false" default="" />
			
		<cfset var blogManager = "" />
		<cfset var objectFactory = "" / >
		<cfset var blog = "" />
		<cfset var basePath = "" />
		<cfset var result = structnew() />
		<cfset var address = "" />
		<cfset var data = "">
		<cfset var local = structnew() />
		<cfset saveConfig(variables.configFile, "", "", arguments.email,variables.defaults["id"] ,  "plugins.", false) />
			
		<cfset variables.blog = createobject("component",variables.componentPath & "Mango").init(variables.configFile & "config.cfm", variables.defaults["id"], variables.configFile)>
		<cfset blogManager = variables.blog.getBlogsManager()  />
		<cfset objectFactory = variables.blog.getObjectFactory() />
			
		<cfset result.status = true />
		<cfset result.message =  "" />
			
			<cffile action="read" file="#variables.exportedFile#" variable="data" charset="utf-8">
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
				//pull the blog title node
				blogName						=	XMlSearch(data, "//:entry[:link[@href = 'http://www.blogger.com/feeds/8660463862749146621/settings/BLOG_NAME']]");
				blogDesc						=	XMlSearch(data, "//:entry[:link[@href = 'http://www.blogger.com/feeds/8660463862749146621/settings/BLOG_DESCRIPTION']]");
				
				//set the args
				blog = objectFactory.createBlog();
				blog.setId(variables.defaults["id"]);
				blog.setTagline(variables.defaults["tagline"]);
				blog.setTitle(blogName[1].content.XMLText);
				blog.setDescription(blogDesc[1].content.XMLText);
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
			<cfset saveConfig(variables.configFile, "", "", arguments.email) />
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
			<!--- <cfset var root = arguments.data.rss.channel />XML --->
			<cfset var blogId = variables.defaults["id"]>
			<cfset var administrator = variables.blog.getAdministrator() />
									
			<cfset thisBlog = variables.blog.getBlog() />
			
			<cfset objectFactory = variables.blog.getObjectFactory() />
			
			
			<cfset manager = variables.blog.getCategoriesManager() />
			
			<!---:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
			<!--- Categories --->
			<cfoutput>Importing categories...<br /><ul></cfoutput>
			
			<cfset categories =	XMlSearch(arguments.data, "//:category[@scheme = 'http://www.blogger.com/atom/ns##']")>
			
			
			<cfloop from="1" to="#arraylen(categories)#" index="i">
				<cfset myName	=	categories[i].XmlAttributes.Term>
				<cfset myTitle 	=	Replace(categories[i].XmlAttributes.Term, " ", "_", "all")>
				
				
				<cfscript>
					if(NOT StructKeyExists(categorykeys, myName))
						{
							writeOutput('<li>#myName#</li>');
							obj = objectFactory.createCategory();
							obj.setname(myTitle);
							obj.setTitle(myName);
							obj.setCreationDate(now());
							obj.setBlogId(blogId);	
								
							key = manager.addCategory(obj).newCategory.getId();
							categorykeys[myName] = key;
						}
				</cfscript>
				
			</cfloop>
			
			<!---:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
			<!--- Posts --->
			<cfoutput></ul>Importing posts...<br /><ul></cfoutput>
			<!--- Use XPATH to find all of the Blog Entries --->
			<cfset blogPosts =	XMlSearch(arguments.data, "//:entry[:category[@term = 'http://schemas.google.com/blogger/2008/kind##post']]")>
			<cfloop from="1" to="#arraylen(blogPosts)#" index="i">
				<!--- import this entry's Author - If Needed  --->
				<cfscript>
					author			=	blogPosts[i].Author.name.xmlText;
					authorEmail		=	blogPosts[i].Author.email.xmlText;
					if(NOT structkeyexists(authorkeys,author))
						{
							result = administrator.newAuthor(authorEmail,"password",author,authorEmail,'','','administrator');
							key = result.newAuthor.getId();
							if (len(key))
								{authorkeys[author] = key;}	
						}
				</cfscript>
				<li>#blogPosts[i].title.xmlText#
				
				<!--- go get and store locally any images in this post --->
				<cfset srcValues = reMultiMatch("<img[^>]+>","src\s*=\s*""[^""]+""", "(?<="").+(?="")", blogPosts[i].content.xmltext) />
				<cfset srcBigValues = reMultiMatch("<a[^>]+>","(?=.+?imageanchor\s*=\s*""1"").+","href\s*=\s*""[^""]+""", "(?<="").+(?="")", blogPosts[i].content.xmltext) />
				
				<cfset myFolder  = CreateUUID()>
				<cfset mangoRoot = ReplaceNoCase(ExpandPath(GetPathFromURL(variables.address)), 'admin\setup\', '', 'All')>
				<cfset myStore = "#mangoRoot#\assets\content\import\#myFolder#\">
				
				<cfif ArrayLen(srcValues)>
					<!--- Create a folder for this post --->
					<cfif NOT DirectoryExists(myStore)>
						<cfdirectory action="create" directory="#myStore#">
					</cfif>
					<cfloop from="1" to="#ArrayLen(srcValues)#" step="1" index="b">
						<!--- do an CFHTTP GET on the image and save it locally --->
						<cfhttp method="Get" url="#srcValues[b]#" path="#myStore#" file="#ListLast(srcValues[b], '/')#"></cfhttp>
						<!--- do a replace on the text to update the image path --->
						<cfset blogPosts[i].content.xmltext = ReplaceNoCase(blogPosts[i].content.xmltext, srcValues[b], '#variables.address#assets/content/import/#myFolder#/#ListLast(srcValues[b], "/")#', 'All')>
					</cfloop>
				</cfif>
				
				<cfif ArrayLen(srcBigValues)>
					<!--- Create a folder for this post --->
					<cfif NOT DirectoryExists("#myStore#big\")>
						<cfdirectory action="create" directory="#myStore#big\">
					</cfif>
					<cfloop from="1" to="#ArrayLen(srcBigValues)#" step="1" index="c">
						<!--- do an CFHTTP GET on the image and save it locally --->
						<cfhttp method="Get" url="#srcBigValues[c]#" path="#myStore#big\" file="#ListLast(srcBigValues[c], '/')#"></cfhttp>
						<!--- do a replace on the text to update the image path --->
						<cfset blogPosts[i].content.xmltext = ReplaceNoCase(blogPosts[i].content.xmltext, srcBigValues[c], '#variables.address#assets/content/import/#myFolder#/big/#ListLast(srcBigValues[c], "/")#', 'All')>
					</cfloop>
				</cfif>
				
				<cfscript>
					args					=	StructNew();
					args.title				=	blogPosts[i].title.xmlText;
					args.content			=	blogPosts[i].content.xmlText;
					args.excerpt			=	"";
					args.publish			=	True;		
					args.authorId			=	authorkeys[author];
					args.allowComments		=	True;
					args.postedOn			=	Left(blogPosts[i].published.xmlText, 10);
					key = administrator.newPost(argumentCollection=args).newPost.getId();
				</cfscript>

				
				<!--- Post categories --->
				<cfif (len(key)) AND (ArrayLen(blogPosts[i].xmlchildren))>
					<cfset categories = ArrayNew(1) />
					<cfloop from="1" to="#ArrayLen(blogPosts[i].xmlchildren)#" step="1" index="j">
						<cfif (blogPosts[i].xmlchildren[j].XmlName IS "Category") AND (StructKeyExists(blogPosts[i].xmlchildren[j].XmlAttributes, "scheme")) AND (blogPosts[i].xmlchildren[j].XmlAttributes.scheme IS "http://www.blogger.com/atom/ns##")>
							<cfset categories = arrayAppendUnique(categories, categorykeys[blogPosts[i].xmlchildren[j].XmlAttributes.term]) />
						</cfif>
					</cfloop>
					<cfset administrator.setPostCategories(key, categories) />
				</cfif>
				
					
				<!---:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
				<!--- Comments --->
					<!--- get the comments for this current entry --->
					<cfset myComments = XMlSearch(arguments.data, "//:entry[thr:in-reply-to[@ref = '#blogPosts[i].id.xmltext#']]")>
					
					<cfif (len(key)) AND (ArrayLen(myComments))>
						<!--- loop over comments for this post --->
						<cfloop from="1" to="#ArrayLen(myComments)#" index="k">
							<cfscript>
								args					=	StructNew();
								args.entryId			=	key;
								args.content			=	myComments[k].content.xmltext;
								args.creatorName		=	myComments[k].author.name.xmltext;
								args.creatorEmail		=	myComments[k].author.email.xmltext;	
								args.approved			=	true;
								args.isImport			=	true;
								args.createdOn			=	LEFT(myComments[k].published.xmltext, 10);
								administrator.newComment(argumentCollection=args);
							</cfscript>
						</cfloop>
						(#k-1# comments)
					</cfif>
				</li>
				
			</cfloop>
			
		<cfreturn />
	</cffunction>

<!---
	
	Blog Entry:
	reMultiMatch() - Extracting Iterative Regular Expression Patterns In ColdFusion
	
	Code Snippet:
	2
	
	Author:
	Ben Nadel / Kinky Solutions
	
	Link:
	http://www.bennadel.com/index.cfm?event=blog.view&id=1921
	
	Date Posted:
	May 12, 2010 at 8:14 PM
	
--->
	<cffunction name="reMultiMatch" access="private" returntype="array" output="false" hint="I return array of regular expression matches defined by the first N-1 patterns applied in sequence to the given string.">
	 
		<!--- Define arguments. --->
		<!---
			The first N-1 arguments will be regular expressions. The
			last argument will be the target tring to which the regular
			expressions will be applied.
		--->
	 
		<!--- Define the local scope. --->
		<cfset var local = {} />
	 
		<!---
			Check to make sure at least two arguments were passed into
			the function. If not, we don't have at least one regular
			epxression pattern to apply.
		--->
		<cfif (arrayLen( arguments ) lt 2)>
	 
			<!--- Invalid argument list. --->
			<cfthrow
				type="InvalidArguments"
				message="This function expects at least 2 arguments."
				detail="This function expects (N GT 1) regular expressions followed by the target string to which the regular expressions should be applied."
				/>
	 
		</cfif>
	 
		<!---
			Create a Pattern class instance that we can use to compile
			our regular expression patterns.
	 
			NOTE: We will be using the Java regular expression engine,
			not the POSIX engine; as such, we will have a much more
			robust set of regex capabilities (and speed).
		--->
		<cfset local.patternClass = createObject( "java", "java.util.regex.Pattern" ) />
	 
		<!---
			Let's compile our regular expression pattners down to
			Pattern objects so that we can get matcher objects.
		--->
		<cfset local.patterns = [] />
	 
		<!---
			The first N-1 arguments are the patterns - let's loop
			over each and append them to the array. Then, we can just
			apply the array of patterns in sequence.
		--->
		<cfloop
			index="local.argumentIndex"
			from="1"
			to="#(arrayLen( arguments ) - 1)#"
			step="1">
	 
			<!--- Append the compiled pattern. --->
			<cfset arrayAppend(
				local.patterns,
				local.patternClass.compile(
					javaCast( "string", arguments[ local.argumentIndex ] )
					)
				) />
	 
		</cfloop>
	 
		<!---
			Now that we have compiled our patterns, let's get
			handle on our target string. This should be the last
			argument passed-in.
	 
			NOTE: Because we are coming out of an arguments loop, we konw
			that the current argument index will be pointint to the last
			argument index possible.
		--->
		<cfset local.targetString = arguments[ local.argumentIndex ] />
	 
		<!---
			At this point, we need to start applying the pattern matching
			to the target string. Since this is going to use an iterative
			approach, we need to create an intermediary result set over
			which the patterns will be applied.
	 
			NOTE: To allow the pattern application iteration to be
			applied in a more uniform manner, we are going to start the
			intermediary result set with the target string (as if the
			previous round matched it).
		--->
		<cfset local.currentMatches = [ local.targetString ] />
	 
		<!---
			As we iterate, we need want to override the current results
			set. As such, we need to create an intermediary set for the
			next iteration.
		--->
		<cfset local.nextMatches = [] />
	 
		<!--- Loop over each pattern. --->
		<cfloop
			index="local.pattern"
			array="#local.patterns#">
	 
			<!---
				For each pattern, we want to find matches in the entire
				set of current results. As such, we want to loop over the
				current results and apply a matcher individually.
			--->
			<cfloop
				index="local.match"
				array="#local.currentMatches#">
	 
				<!---
					Apply the current pattern to this match and get a
					matcher which we can use to extract the matches.
				--->
				<cfset local.matcher = local.pattern.matcher(
					javaCast( "string", local.match )
					) />
	 
				<!---
					Loop over each match and add it to the set of next
					matches (used in the next iteration).
				--->
				<cfloop condition="local.matcher.find()">
	 
					<!--- Append to the set of next matches. --->
					<cfset arrayAppend(
						local.nextMatches,
						local.matcher.group()
						) />
	 
				</cfloop>
	 
			</cfloop>
	 
			<!---
				Now that we have applied this pattern to each match in
				the previously available match set, we need to swap the
				matches and allow the next iteration to conitue.
			--->
			<cfset local.currentMatches = local.nextMatches />
	 
			<!---
				Reset the next matches to allow a clean aggregation of
				matched in the next iteration.
			--->
			<cfset local.nextMatches = [] />
	 
		</cfloop>
	 
		<!---
			Return the matches aggregated by the last pattern
			application. This should be all the matches that made it
			through each matching iteration.
		--->
		<cfreturn local.currentMatches />
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