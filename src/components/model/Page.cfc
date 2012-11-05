<cfcomponent extends="Entry" alias="org.mangoblog.model.Page">
	
	<cfproperty name="id" type="string" default="">
	<cfproperty name="name" type="string" default="">
	<cfproperty name="title" type="string" default="">
	<cfproperty name="content" type="string" default="">
	<cfproperty name="excerpt" type="string" default="">
	<cfproperty name="authorId" type="string" default="">
	<cfproperty name="status" type="string" default="">
	<cfproperty name="lastModified" type="date" default="">
	<cfproperty name="customFields" type="struct" default="">
	<cfproperty name="blogId" type="string" default="">
	<cfproperty name="parentPageId" type="string" default="">
	<cfproperty name="template" type="string" default="">
	<cfproperty name="hierarchy" type="string" default="">
	<cfproperty name="sortOrder" type="numeric" default="1">
	<cfproperty name="commentsAllowed" type="boolean" default="false">
	<cfproperty name="permalink" type="string" default="">
	<cfproperty name="url" type="string" default="">

	<cfscript>
		this.parentPageId = "";
		this.template = "";
		this.hierarchy = "";
		this.sortOrder = 1;
		this.commentsAllowed = false;
	</cfscript>

	<cffunction name="init" access="public" output="false">
		<cfargument name="id" required="true" type="string" hint="Primary key"/>
		<cfargument name="name" required="false" type="string" default="" hint="Name"/>
		<cfargument name="title" required="false" type="string" default="" hint="Title"/>
		<cfargument name="content" required="false" type="string" default="" hint="Post body"/>
		<cfargument name="excerpt" required="false" type="string" default="" hint="Excerpt"/>
		<cfargument name="author_id" required="false" type="numeric" default="0" hint="Author ID"/>
		<cfargument name="author" required="false" type="string" default="" hint="Author Name"/>
		<cfargument name="comments_allowed" required="false" type="boolean" default="true" hint="Are comments allowed?"/>
		<cfargument name="status" required="false" type="string" default="" hint="Status"/>
		<cfargument name="last_modified" required="false" default="" hint="Last modified date"/>
		<cfargument name="comment_count" required="false" type="numeric" default="0" hint="Total comments for this post"/>
		<cfargument name="parent_page_id" required="false"  type="string" default="">
		<cfargument name="template" required="false"  type="string" default="">
		<cfargument name="hierarchy" required="false"  type="string" default="">
		<cfargument name="sortOrder" required="false"  type="numeric" default="1">
		
		<cfscript>
			super.init(argumentCollection=arguments);
			setParentPageId(arguments.parent_page_id);
			setTemplate(arguments.template);
			setHierarchy(arguments.hierarchy);
			setSortOrder(arguments.sortOrder);
			return this;
		</cfscript>
 	</cffunction>
	

	<cffunction name="getParentPageId" output="false" access="public" returntype="string">
		<cfreturn this.parentPageId>
	</cffunction>

	<cffunction name="setParentPageId" output="false" access="public" returntype="void">
		<cfargument name="parentPageId" required="true"  type="string">
			<cfset this.parentPageId = arguments.parentPageId>
	</cffunction>

	<cffunction name="getTemplate" output="false" access="public" returntype="any">
		<cfreturn this.template>
	</cffunction>

	<cffunction name="setTemplate" output="false" access="public" returntype="void">
		<cfargument name="template" required="true">
		<cfset this.Template = arguments.template>
	</cffunction>
	
	<cffunction name="getHierarchy" output="false" access="public" returntype="any">
		<cfreturn this.hierarchy>
	</cffunction>

	<cffunction name="setHierarchy" output="false" access="public" returntype="void">
		<cfargument name="hierarchy" required="true" type="string">
		<cfset this.hierarchy = arguments.hierarchy>
	</cffunction>	

	<cffunction name="getSortOrder" output="false" access="public" returntype="numeric">
		<cfreturn this.sortOrder>
	</cffunction>

	<cffunction name="setSortOrder" output="false" access="public" returntype="void">
		<cfargument name="sortOrder" required="true" type="numeric">
		<cfset this.sortOrder = arguments.sortOrder>
	</cffunction>	

	<cffunction name="clone" access="public" returntype="Page" output="false">
		<cfargument name="myClone" required="false" default="#createObject('component','Page')#">
		
		<cfscript>
			arguments.myClone.Id = this.id;
			arguments.myClone.Name = this.name;
			arguments.myClone.Title = this.title;
			arguments.myClone.Content = this.content;
			arguments.myClone.Excerpt = this.excerpt;
			arguments.myClone.AuthorId = this.authorId;
			arguments.myClone.Author = this.author;
			arguments.myClone.CommentsAllowed = this.commentsAllowed;
			arguments.myClone.Status = this.status;
			arguments.myClone.LastModified = this.lastModified;
			arguments.myClone.CommentCount = this.commentCount;
			arguments.myClone.Template = this.template;
			arguments.myClone.ParentPageId = this.parentPageId;
			arguments.myClone.Hierarchy = this.hierarchy;
			arguments.myClone.Url = this.urlString;
			arguments.myClone.SortOrder = this.sortOrder;
			arguments.myClone.customFields = this.customFields;
		</cfscript>
		<cfreturn arguments.myClone />
	</cffunction>

	<cffunction name="getInstanceData" access="public" returntype="struct" output="false">
		
		<cfscript>
			var data = super.getInstanceData();
			var i = 1;			
			data["parentPageId"] = this.parentPageId;
			data["template"] = this.template;
			data["hierarchy"] =  this.hierarchy;
			data["sortOrder"] = this.sortOrder;
		</cfscript>
	
		<cfreturn data />
	</cffunction>

</cfcomponent>