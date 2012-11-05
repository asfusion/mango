<cfcomponent extends="API">

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getRecentPosts" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			<!--- 
			 blogid
			usrename
			password
			numberOfPosts
			--->
			<cfset var username = arguments.data[2] />
			<cfset var password = arguments.data[3] />
			<cfset var count = 0 />
			<cfset var posts = arraynew(1) />
			<cfset var i = 1 />
			<cfset var j = 1 />
			<cfset var result = arraynew(1) />
			
			<cfif arraylen(arguments.data) GTE 4>
				<cfset count = arguments.data[4] />
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
				if (posts[i].commentsAllowed) 
					result[1][i]["mt_allow_comments"] = "(int) 1";
				else
					result[1][i]["mt_allow_comments"] = "(int) 0";
				result[1][i]["categories"] = arraynew(1);
				for (j = 1; j LTE arraylen(posts[i].categories); j = j +1){
					result[1][i]["categories"][j] = posts[i].categories[j].title;
				}
				//@todo check this
											/* 											
											result[1][j].userid="(string)" & "#arrayShow[k].author#";
											result[1][j].mt_excerpt ="(string)" & "#arrayShow[k].excerpt#";
											result[1][j].mt_text_more = ""; 											
											result[1][j].mt_allow_pings = "(int) 1"; 
											result[1][j].mt_convert_breaks = "(string)" & "";
											result[1][j].mt_keywords = "(string)" & ""; */
				</cfscript>
			</cfloop>

		<cfreturn result />
	</cffunction>
	

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<!--- 
postId - (string): ID
username - (string): email or username for a user who has permission to post to the blog.
password - (string): Password for said username/email --->
	<cffunction name="getPost" access="remote" output="false" returntype="any">
		<cfargument name="data" required="true" type="array" />
					
			<cfset var postId = arguments.data[1] />
			<cfset var username = arguments.data[2] />
			<cfset var password = arguments.data[3] />
			<cfset var result = arraynew(1) />
			<cfset var i = 1 />
			<cfset var post = super.getPost(username,password,postId) />
			
			<cfscript>
				result[1] = structnew();
			
				result[1]["title"] = post.title;
				result[1]["postid"] = "(string)" & post.id;
				result[1]["url"] = post.url;
				result[1]["link"] = post.permalink;
				result[1]["permalink"] = post.permalink;
				result[1]["description"] = "(string)" & post.content;
				result[1]["dateCreated"] ="(dateTime.iso8601)" & post.postedOn;
				result[1]["userid"] ="(string)" & post.authorId;
				if (post.commentsAllowed) 
					result[1]["mt_allow_comments"] = "(int) 1";
				else
					result[1]["mt_allow_comments"] = "(int) 0";
				
				for (i = 1; i LTE arraylen(post.categories); i = i +1){
					result[1]["categories"][i] = post.categories[i].title;
				}
	
				</cfscript>
		
		<cfreturn result />
	</cffunction>	
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<!---
	# blogid (string): Unique identifier of the blog the post will be added to.
	# username (string): Login for a user who has permission to post to the blog.
	# password (string): Password for said username.
	# post (struct): Contents of the post.
	# publish (boolean): If true, the blog will be published immediately after the post is made.  --->
	<cffunction name="newPost" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />

			<cfset var blogId = arguments.data[1] />
			<cfset var username = arguments.data[2] />
			<cfset var password = arguments.data[3] />
			<cfset var content = arguments.data[4]  />
			<cfset var publish = arguments.data[5]  />
			<cfset var result = arraynew(1) />
			<cfset var i = 0 />
			<cfset var postResult = "" />

			<cfset postResult = super.newPost(username,password,content.title,content.description,publish,blogId) />
			<cfif len(postResult) AND structkeyexists(content,"categories")>
				<!--- insert categories --->
				<cfset super.setPostCategories(username,password, postResult, content.categories) />
			</cfif>
			<cfset result[1] = "(string)" & postResult />

		<cfreturn result />
	</cffunction>	

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<!---
	# postid (string): Unique identifier of the post to be changed.
	# username (string): Login for a user who has permission to edit the given post (either the user who originally created it or an admin of the blog).
	# password (string): Password for said username.
	# struct 
	# publish (boolean): If true, the blog will be published immediately after the post is made.   --->
	<cffunction name="editPost" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			
			<cfset var postId = arguments.data[1] />
			<cfset var username = arguments.data[2] />
			<cfset var password = arguments.data[3] />
			<cfset var content = arguments.data[4]  />
			<cfset var publish = 0 />
			<cfset var result = arraynew(1) />
			<cfset var title = content.title />
			<cfset var titleStruct = "" />
			<cfset var postResult = "" />
			
			<!--- some clients will not pass the fifth argument, and set the publish status in 
			the inner post_status --->
			<cfif arraylen(arguments.data) GTE 5>
				<cfset publish = arguments.data[5] />
			<cfelse>
				<cfif structkeyexists(content, "post_status")>
					<cfset publish = (content.post_status EQ "publish" OR content.post_status EQ "published")>
				</cfif>
			</cfif>
			<cfset postResult = super.editPost(username,password,postId,title,content.description,publish) />
			<cfif postResult>
				<cfset result[1] =  "(int) 1" />
			<cfelse>
				<cfset result[1] =  "(int) 0" />
			</cfif>

		<cfreturn result />
	</cffunction>	
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
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
			
			<cfset name = author.getName() />
			<cfset result[1] = structnew() />
			<cfset result[1]["nickname"] = name />
			<cfset result[1]["userid"] = author.getId() />
			<cfset result[1]["url"] = author.getUrl() />
			<cfset result[1]["email"] = author.getEmail()/>
			<cfset result[1]["firstname"] = listgetat(name,1," ")  />
			<cfif listlen(name," ") GT 1>
				<cfset result[1]["lastname"] = listgetat(name,2," ")  />
			<cfelse>
				<cfset result[1]["lastname"] = "" />
			</cfif>			

		<cfreturn result />
	</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCategories" access="remote" output="false" returntype="any">
		<cfargument name="data" required="true" type="array" />

			<cfset var username = arguments.data[2] />
			<cfset var password = arguments.data[3] />
			<cfset var count = 0 />
			<cfset var categories = super.getCategories(username,password) />
			<cfset var i = 0 />
			<cfset var result = arraynew(1) />
			<cfset result[1] = arraynew(1) />
						
			<cfloop index="i" from="1" to="#arraylen(categories)#">
				<cfscript>
				result[1][i] = structnew();
				result[1][i]["categoryid"] = "(string)" & categories[i].id;
				result[1][i]["title"] = "(string)" & categories[i].title;
				result[1][i]["description"] = categories[i].description;
				result[1][i]["htmlUrl"] = "(string)" & categories[i].url;
				result[1][i]["rssUrl"] = "(string)" & categories[i].url;
						
			</cfscript>	
			</cfloop>	
			<cfreturn result />
	</cffunction>		
	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!--- blogid, username, password, struct) returns struct
The struct must contain at least three elements, name, type and bits. --->
	<cffunction name="newMediaObject" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />

			<cfset var username = arguments.data[2] />
			<cfset var password = arguments.data[3] />
			<cfset var object = arguments.data[4]  />
			<cfset var result = arraynew(1) />
			<cfset result[1] = structnew() />
			
			<cfset result[1]["url"] = super.newMediaObject(username, password, object) />

         <cfreturn result />
   </cffunction>
	
</cfcomponent>