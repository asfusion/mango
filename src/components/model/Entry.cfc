<cfcomponent alias="org.mangoblog.model.Entry">

	<cfproperty name="id" type="string" default="">
	<cfproperty name="name" type="string" default="">
	<cfproperty name="title" type="string" default="">
	<cfproperty name="content" type="string" default="">
	<cfproperty name="excerpt" type="string" default="">
	<cfproperty name="authorId" type="string" default="">
	<cfproperty name="commentsAllowed" type="boolean" default="false">
	<cfproperty name="status" type="string" default="">
	<cfproperty name="lastModified" type="date" default="">
	<cfproperty name="customFields" type="struct" default="">
	<cfproperty name="blogId" type="string" default="">
	<cfproperty name="permalink" type="string" default="">
	<cfproperty name="url" type="string" default="">

	<cfset this.id = "" />
	<cfset this.name = "" />
	<cfset this.title = "" />
	<cfset this.content = "" />
	<cfset this.excerpt = "" />
	<cfset this.authorId =  ""/>
	<cfset this.author =  "" />
	<cfset this.status = "published" />
	<cfset this.commentsAllowed = true />
	<cfset this.lastModified = now() />
	<cfset this.urlString = "" />
	<cfset this.commentCount = 0 />
	<cfset this.customFields = structnew() />
	<cfset this.blogId = "">
	<cfset this.permalink = "" />

	<cffunction name="init" access="public" output="false">
		<cfargument name="id" required="true" type="string" hint="Primary key"/>
		<cfargument name="name" required="false" type="string" default="" hint="Name"/>
		<cfargument name="title" required="false" type="string" default="" hint="Title"/>
		<cfargument name="content" required="false" type="string" default="" hint="Post body"/>
		<cfargument name="excerpt" required="false" type="string" default="" hint="Excerpt"/>
		<cfargument name="author_id" required="false" type="string" default="" hint="Author ID"/>
		<cfargument name="author" required="false" type="string" default="" hint="Author Name"/>
		<cfargument name="comments_allowed" required="false" type="boolean" default="true" hint="Are comments allowed?"/>
		<cfargument name="status" required="false" type="string" default="" hint="Status"/>
		<cfargument name="last_modified" required="false" default="" hint="Last modified date"/>
		<cfargument name="comment_count" required="false" type="numeric" default="0" hint="Total comments for this post"/>
		
		
		<cfscript>
			setId(arguments.id);
			setName(arguments.name);
			setTitle(arguments.title);
			setContent(arguments.content);
			setExcerpt(arguments.excerpt);
			setAuthorId(arguments.author_id);
			setAuthor(arguments.author);
			setCommentsAllowed(arguments.comments_allowed);
			setStatus(arguments.status);
			setLastModified(arguments.last_modified);
			setCommentCount(arguments.comment_count);
			return this;
		</cfscript>
 	</cffunction>
	
	<cffunction name="setId" access="public" returntype="void" output="false">
		<cfargument name="id" type="string" required="true" />
		<cfset this.id = arguments.id />
	</cffunction>
	
	<cffunction name="getId" access="public" returntype="string" output="false">
		<cfreturn this.id />
	</cffunction>

	<cffunction name="setName" access="public" returntype="void" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfset this.name = arguments.name />
	</cffunction>
	<cffunction name="getName" access="public" returntype="string" output="false">
		<cfreturn this.name />
	</cffunction>

	<cffunction name="setTitle" access="public" returntype="void" output="false">
		<cfargument name="title" type="string" required="true" />
			<cfset this.title = arguments.title />
	</cffunction>
	
	<cffunction name="getTitle" access="public" returntype="string" output="false">
		<cfreturn this.title />
	</cffunction>

	<cffunction name="setContent" access="public" returntype="void" output="false">
		<cfargument name="content" type="string" required="true" />
		<cfset this.content = arguments.content />
	</cffunction>
	<cffunction name="getContent" access="public" returntype="string" output="false">
		<cfreturn this.content />
	</cffunction>

	<cffunction name="setExcerpt" access="public" returntype="void" output="false">
		<cfargument name="excerpt" type="string" required="true" />
		<cfset this.excerpt = arguments.excerpt />
	</cffunction>
	<cffunction name="getExcerpt" access="public" returntype="string" output="false">
		<cfreturn this.excerpt />
	</cffunction>

	<cffunction name="setAuthorId" access="public" returntype="void" output="false">
		<cfargument name="author_id" type="string" required="true" />
		<cfset this.authorId = arguments.author_id />
	</cffunction>
	<cffunction name="getAuthorId" access="public" returntype="string" output="false">
		<cfreturn this.authorId />
	</cffunction>

	<cffunction name="setAuthor" access="public" returntype="void" output="false">
		<cfargument name="author" type="string" required="true" />
		<cfset this.author = arguments.author />
	</cffunction>
	<cffunction name="getAuthor" access="public" returntype="string" output="false">
		<cfreturn this.author />
	</cffunction>

	<cffunction name="setCommentsAllowed" access="public" returntype="void" output="false">
		<cfargument name="comments_allowed" type="string" required="true" />
		<cfset this.commentsAllowed = arguments.comments_allowed />
	</cffunction>
	<cffunction name="getCommentsAllowed" access="public" returntype="string" output="false">
		<cfreturn this.commentsAllowed />
	</cffunction>

	<cffunction name="setStatus" access="public" returntype="void" output="false">
		<cfargument name="status" type="string" required="true" />
		<cfset this.status = arguments.status />
	</cffunction>
	<cffunction name="getStatus" access="public" returntype="string" output="false">
		<cfreturn this.status />
	</cffunction>

	<cffunction name="setLastModified" access="public" returntype="void" output="false">
		<cfargument name="last_modified" type="string" required="true" />
		<cfset this.lastModified = arguments.last_modified />
	</cffunction>
	<cffunction name="getLastModified" access="public" returntype="string" output="false">
		<cfreturn this.lastModified />
	</cffunction>

	<cffunction name="setUrl" access="public" returntype="void" output="false">
		<cfargument name="urlString" type="string" required="true" />
		<cfset this.urlString = arguments.urlString />
	</cffunction>
	<cffunction name="getUrl" access="public" returntype="string" output="false">
		<cfreturn this.urlString />
	</cffunction>
	
	<cffunction name="setPermalink" access="public" returntype="void" output="false">
		<cfargument name="permalink" type="string" required="true" />
		<cfset this.permalink = arguments.permalink />
	</cffunction>
	<cffunction name="getPermalink" access="public" returntype="string" output="false">
		<cfreturn this.permalink />
	</cffunction>

	<cffunction name="setCommentCount" access="public" returntype="void" output="false">
		<cfargument name="commentCount" type="string" required="true" />
		<cfset this.commentCount = arguments.commentCount />
	</cffunction>
	<cffunction name="getCommentCount" access="public" returntype="string" output="false">
		<cfreturn this.commentCount />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setCustomField" access="public" returntype="void" output="false">
		<cfargument name="field_key" type="string" required="true" />
		<cfargument name="field_name" type="string" required="true" />
		<cfargument name="field_value" type="any" required="true" />
		
		<cfset this.customFields[arguments.field_key] = structnew() />
		<cfset this.customFields[arguments.field_key]["key"] = arguments.field_key  />
		<cfset this.customFields[arguments.field_key]["name"] = arguments.field_name  />
		<cfset this.customFields[arguments.field_key]["value"] = arguments.field_value  />
		
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getCustomField" access="public" returntype="struct" output="false">
		<cfargument name="field_key" type="string" required="true" />
		
		<cfreturn  this.customFields[arguments.field_key] />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="removeCustomField" access="public" returntype="void" output="false">
		<cfargument name="field_key" type="string" required="true" />
		
		<cfset structdelete(this.customFields, arguments.field_key,false)>
				
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setCustomFields" access="public" returntype="void" output="false">
		<cfargument name="fields" type="struct" required="true" />
		
		<cfset this.customFields = arguments.fields  />
		
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="customFieldExists" access="public" returntype="boolean" output="false">
		<cfargument name="field_key" type="string" required="true" />
		
		<cfreturn structkeyexists(this.customFields, arguments.field_key) />
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCustomFieldsAsArray" access="public" returntype="array" output="false">
		<cfset var fields = arraynew(1) />
		<cfset var key = ''>
		<cfloop collection="#this.customFields#" item="key">
			<cfset arrayappend(fields, this.customFields[key]) />
		</cfloop>
		
		<cfreturn fields />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getBlogId" output="false" access="public" returntype="any">
		<cfreturn this.blogId>
	</cffunction>

	<cffunction name="setBlogId" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.blogId = arguments.val>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="isValidForSave" access="public" returntype="struct" output="false">
		<cfset var returnObj = structnew() />
		<cfset returnObj.status = true />
		<cfset returnObj.errors = arraynew(1) />

		<cfif NOT len(this.blogId)>
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"Blog is required")/>			
		</cfif>
		<cfif NOT len(this.title) AND this.status EQ "published">
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"Title is required")/>			
		</cfif>
		<!---<cfif NOT len(this.content) AND this.status EQ "published">
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"Content is required")/>			
		</cfif>--->
		<cfif len(this.name) AND not REFind("^[a-z0-9]+(-[a-z0-9]+)*$",this.name)>
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"URL-safe title is in an invalid format. Please enter only a-z, 0-9 or -, not starting or ending with a -")/>			
		</cfif>
				
		<cfreturn returnObj />
		
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getInstanceData" access="public" returntype="struct" output="false">
		
		<cfscript>
			var data = structnew();
			var i = 1;
			data["id"] = this.id;
			data["name"] = this.name;
			data["title"] = this.title;
			data["excerpt"] = this.excerpt;
			data["content"] = this.content;
			data["authorId"] = this.authorId;
			data["author"] = this.author;
			data["commentsAllowed"] = this.commentsAllowed;
			data["status"] = this.status;
			data["lastModified"] = this.lastModified;
			data["url"] = this.urlString;
			data["commentCount"] = this.commentCount;
			data["customFields"] = this.customFields;
			data["blogId"] = this.blogId;
			data["permalink"] = this.permalink;
		</cfscript>
	
		<cfreturn data />
	</cffunction>

</cfcomponent>