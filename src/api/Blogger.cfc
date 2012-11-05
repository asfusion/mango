<cfcomponent extends="API">

	<cffunction name="getUsersBlogs" access="public" output="false" returntype="Any">
		<cfargument name="data" required="true" type="array" />
		
			<cfset var username = data[2] />
			<cfset var password = data[3] />
			<cfset var blogs = super.getUsersBlogs(username,password) />
			<cfset var i = 0 />
			<cfset var result = arraynew(1) />
			<cfset result[1] = arraynew(1) />
			
			<cfloop index="i" from="1" to="#arraylen(blogs)#">
				
				<cfset result[1][i] = structnew()/>
				<cfset result[1][i]["url"] = blogs[i].url />
				<cfset result[1][i]["isAdmin"] = "(boolean)1" />
				<cfset result[1][i]["blogid"] = "(string)" &  blogs[i].id  />
				<cfset result[1][i]["blogName"] =  "(string)" & blogs[i].title />
			</cfloop>

		<cfreturn result />
	</cffunction>
	
	<cffunction name="getRecentPosts" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			<!--- 1: appKey 
			2: blogid
			3: usrename
			4: password
			5: numberOfPosts
			--->
			<cfset var username = arguments.data[3] />
			<cfset var password = arguments.data[4] />
			<cfset var count = 0 />
			<cfset var posts = arraynew(1) />
			<cfset var i = 0 />
			<cfset var result = arraynew(1) />
			
			<cfif arraylen(arguments.data) GTE 5>
				<cfset count = arguments.data[5] />
			</cfif>
			
			<cfset posts = super.getRecentPosts(username,password,count) />
			
			<cfset result[1] = arraynew(1) />
			
			<cfloop index="i" from="1" to="#arraylen(posts)#">
				<cfscript>
				result[1][i] = structnew();
				result[1][i]["title"] = posts[i].title;
				result[1][i]["postid"] = "(string)" & posts[i].id;
				result[1][i]["link"] = posts[i].permalink;
				result[1][i]["permalink"] = posts[i].permalink;
				result[1][i]["description"] = "(string)" & posts[i].content;
				result[1][i]["dateCreated"] ="(dateTime.iso8601)" & posts[i].postedOn;
				result[1][i]["userid"] ="(string)" & posts[i].authorId;
				
				//@todo check this
				//@todo add categories to content
				result[1][i]["content"] = "(string)" & "<title>#posts[i].title#</title>" & posts[i].content;
				
											/* 
												
											result[1][j].userid="(string)" & "#arrayShow[k].author#";
											result[1][j].description="(string)" & "#arrayShow[k].description#";
											result[1][j].mt_excerpt ="(string)" & "#arrayShow[k].excerpt#";
											result[1][j].mt_text_more = ""; 
											result[1][j].mt_allow_comments = "(int) 1";
											result[1][j].mt_allow_pings = "(int) 1"; 
											result[1][j].mt_convert_breaks = "(string)" & "";
											result[1][j].mt_keywords = "(string)" & ""; */
										</cfscript>
			</cfloop>

		<cfreturn result />
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<!--- appkey - (string): Ignored in OpenACS
postId - (string): Post's entry_id
username - (string): email or username for a user who has permission to post to the blog.
password - (string): Password for said username/email --->
	<cffunction name="getPost" access="remote" output="false" returntype="any">
		<cfargument name="data" required="true" type="array" />
					
			<cfset var postId = arguments.data[2] />
			<cfset var username = arguments.data[3] />
			<cfset var password = arguments.data[4] />
			<cfset var result = arraynew(1) />
			<cfset var post = super.getPost(username,password,postId) />
			
			<cfscript>
				result[1] = structnew();
			
				result[1]["title"] = post.title;
				result[1]["postid"] = "(string)" & post.id;
				result[1]["link"] = post.url;
				result[1]["description"] = "(string)" & post.content;
				result[1]["dateCreated"] ="(dateTime.iso8601)" & post.postedOn;
				result[1]["userid"] ="(string)" & post.authorId;

				//@todo add categories to content
	
				</cfscript>
		
		<cfreturn result />
	</cffunction>	
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<!---
	#  appkey (string): Unique identifier/passcode of the application sending the post. 
	# blogid (string): Unique identifier of the blog the post will be added to.
	# username (string): Login for a user who has permission to post to the blog.
	# password (string): Password for said username.
	# content (string): Contents of the post.
	# publish (boolean): If true, the blog will be published immediately after the post is made.  --->
	<cffunction name="newPost" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			
			<cfset var blogId = arguments.data[2] />
			<cfset var username = arguments.data[3] />
			<cfset var password = arguments.data[4] />
			<cfset var content = arguments.data[5]  />
			<cfset var publish = arguments.data[6]  />
			<cfset var result = arraynew(1) />
			<cfset var title = "" />
			<cfset var titleStruct = "" />
			<cfset var postResult = "" />
			
			<!--- find title --->
			<cfset titleStruct = reFindNoCase("<title>([^<]*)</title>",content,1,1)/>
			<cfif titleStruct.len[1]>
				<cfset title = mid(content,titleStruct.pos[2],titleStruct.len[2]) />
				<cfset content = mid(content,titleStruct.len[1]+1,len(content)) />
			</cfif>
				
			<cfset postResult = super.newPost(username,password,title,content,publish,blogId) />
			
			<cfset result[1] = "(string)" & postResult />

		<cfreturn result />
	</cffunction>	


	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<!---
	#  appkey (string): Unique identifier/passcode of the application sending the post. (See access info.)
	# postid (string): Unique identifier of the post to be changed.
	# username (string): Login for a user who has permission to edit the given post (either the user who originally created it or an admin of the blog).
	# password (string): Password for said username.
	# content (string): New content of the post.
	# publish (boolean): If true, the blog will be published immediately after the post is made.   --->
	<cffunction name="editPost" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			
			<cfset var postId = arguments.data[2] />
			<cfset var username = arguments.data[3] />
			<cfset var password = arguments.data[4] />
			<cfset var content = arguments.data[5]  />
			<cfset var publish = arguments.data[6]  />
			<cfset var result = arraynew(1) />
			<cfset var title = "" />
			<cfset var titleStruct = "" />
			<cfset var postResult = "" />
			
			<!--- find title --->
			<cfset titleStruct = reFindNoCase("<title>([^<]*)</title>",content,1,1)/>
			<cfif titleStruct.len[1]>
				<cfset title = mid(content,titleStruct.pos[2],titleStruct.len[2]) />
				<cfset content = mid(content,titleStruct.len[1]+1,len(content)) />
			</cfif>
			<cfset postResult = super.editPost(username,password,postId,title,content,publish) />
			<cfif postResult>
				<cfset result[1] =  "(int) 1" />
			<cfelse>
				<cfset result[1] =  "(int) 0" />
			</cfif>

		<cfreturn result />
	</cffunction>	
	
		<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<!---
	.   --->
	<cffunction name="deletePost" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			
			<cfset var postId = arguments.data[2] />
			<cfset var username = arguments.data[3] />
			<cfset var password = arguments.data[4] />
			<cfset var result = arraynew(1) />
			<cfset var postResult = "" />
			
			<cfset postResult = super.deletePost(username,password,postId) />
			<cfif postResult>
				<cfset result[1] =  "(int) 1" />
			<cfelse>
				<cfset result[1] =  "(int) 0" />
			</cfif>

		<cfreturn result />
	</cffunction>
	
		<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<!---
	   1.  appkey (string): Unique identifier/passcode of the application sending the post. (ignored)
   2. username (string): Login for the user
   3. password (string): Password for said username. 

sample response:
<methodResponse>  
	<params>  <param>  <value>  <struct>  
	<member>  <name>nickname</name>  <value>Ev.</value>  </member>  
	<member>  <name>userid</name>  <value>1</value>  </member>  
	<member>  <name>url</name>  <value>http://www.evhead.com</value>  </member>  
	<member>  <name>email</name>  <value>ev@pyra.com</value>  </member>  
	<member>  <name>lastname</name>  <value>Williams</value>  </member>  
	<member>  <name>firstname</name>  <value>Evan</value>  </member>  </struct>  </value>  </param>  </params>  
	</methodResponse>
 --->
	<cffunction name="getUserInfo" access="remote" output="false" returntype="array" hint="returns a struct containing user's userid, firstname, lastname, nickname, email, and url.">
		<cfargument name="data" required="true" type="array" />
			
			<cfset var username = arguments.data[2] />
			<cfset var password = arguments.data[3] />
			<cfset var result = arraynew(1) />
			<cfset var author = "" />
			<cfset var name =  "" />
			<cfset author = super.getUserInfo(username,password) />
			
			<cfset name = author.name />
			<cfset result[1] = structnew() />
			<cfset result[1]["nickname"] = name />
			<cfset result[1]["userid"] = author.id />
			<cfset result[1]["url"] = author.url />
			<cfset result[1]["email"] = author.email />
			<cfset result[1]["firstname"] = listgetat(name,1," ")  />
			<cfif listlen(name," ") GT 1>
				<cfset result[1]["lastname"] = listgetat(name,2," ")  />
			<cfelse>
				<cfset result[1]["lastname"] = "" />
			</cfif>			

		<cfreturn result />
	</cffunction>		
	
	
</cfcomponent>