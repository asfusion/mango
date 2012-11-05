<cfcomponent extends="Entry" alias="org.mangoblog.model.Post">
	
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
	<cfproperty name="postedOn" type="date">
	<cfproperty name="categories" type="array">
	<cfproperty name="permalink" type="string" default="">
	<cfproperty name="url" type="string" default="">

	<cfset this.postedOn = now() />
	<cfset this.categories = arraynew(1) />

	<cffunction name="init" access="public" output="false">
		<cfargument name="id" required="true" type="string" hint="Primary key"/>
		<cfargument name="name" required="false" type="string" default="" hint="Name"/>
		<cfargument name="title" required="false" type="string" default="" hint="Title"/>
		<cfargument name="content" required="false" type="string" default="" hint="Post body"/>
		<cfargument name="excerpt" required="false" type="string" default="" hint="Excerpt"/>
		<cfargument name="posted_on" required="false" hint="Date" default="" />
		<cfargument name="author_id" required="false" type="numeric" default="0" hint="Author ID"/>
		<cfargument name="author" required="false" type="string" default="" hint="Author Name"/>
		<cfargument name="comments_allowed" required="false" type="boolean" default="true" hint="Are comments allowed?"/>
		<cfargument name="status" required="false" type="string" default="" hint="Status"/>
		<cfargument name="last_modified" required="false" default="" hint="Last modified date"/>
		<cfargument name="url" required="false" type="string" default="" hint="Address / permalink"/>
		<cfargument name="comment_count" required="false" type="numeric" default="0" hint="Total comments for this post"/>
		
		
		<cfscript>
			super.init(argumentCollection=arguments);
			setPostedOn(arguments.posted_on);
			return this;
		</cfscript>
 	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setPostedOn" access="public" returntype="void" output="false">
		<cfargument name="posted_on" type="string" required="true" />
		<cfset this.postedOn = arguments.posted_on />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPostedOn" access="public" returntype="string" output="false">
		<cfreturn this.postedOn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->		
	<cffunction name="setCategories" access="public" returntype="void" output="false">
		<cfargument name="categories" type="array" required="true" />
		<cfset this.categories = arguments.categories />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getCategories" access="public" returntype="array" output="false">
		<cfreturn this.categories />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="clone" access="public" returntype="Post" output="false">
		<cfargument name="myClone" required="false" default="#createObject('component','Post')#">
		
		<cfscript>
			arguments.myClone.id = this.id;
			arguments.myClone.name = this.name;
			arguments.myClone.title = this.title;
			arguments.myClone.content = this.content;
			arguments.myClone.excerpt = this.excerpt;
			arguments.myClone.authorId = this.authorId;
			arguments.myClone.Author = this.author;
			arguments.myClone.CommentsAllowed = this.commentsAllowed;
			arguments.myClone.Status = this.status;
			arguments.myClone.LastModified = this.lastModified;
			arguments.myClone.CommentCount = this.commentCount;
			arguments.myClone.PostedOn = this.postedOn;
			arguments.myClone.Categories = this.categories;
			arguments.myClone.urlString = this.urlString;
			arguments.myClone.CustomFields = this.customFields;
			
			return  arguments.myClone;
		</cfscript>
	</cffunction>	

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->		
	<cffunction name="getInstanceData" access="public" returntype="struct" output="false">
		
		<cfscript>
			var data = super.getInstanceData();
			var i = 1;			
			data["postedOn"] = this.postedOn;
			data["categoryList"] = "";
			data["categories"] = arraynew(1);
			for (; i LTE arraylen(this.categories); i= i + 1){
				arrayappend(data["categories"],this.categories[i].getInstanceData());
				data["categoryList"] = listappend(data["categoryList"],this.categories[i].getTitle());
			}
		</cfscript>
	
		<cfreturn data />
	</cffunction>

</cfcomponent>