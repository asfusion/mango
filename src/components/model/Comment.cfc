<cfcomponent name="Comment">

	<cfproperty name="id" type="string" default="">
	<cfproperty name="entryId" type="string" default="">
	<cfproperty name="content" type="string" default="">
	<cfproperty name="creatorName" type="string" default="">
	<cfproperty name="creatorEmail" type="string" default="">
	<cfproperty name="creatorUrl" type="string" default="">
	<cfproperty name="createdOn" type="date" default="">
	<cfproperty name="approved" type="numeric" default="0">
	<cfproperty name="authorId" type="string" default="">
	<cfproperty name="parentCommentId" type="string" default="">
	<cfproperty name="rating" type="numeric" default="0">

	<cfscript>
		this.id = "";
		this.entryId = "";
		this.content = "";
		this.creatorName = "";
		this.creatorEmail = "";
		this.creatorUrl = "";
		this.createdOn = "";
		this.approved = 0;
		this.authorId = "";
		this.parentCommentId = "";
		this.rating = 0;
		this.additionalFields = structnew();
		this.entry = '';
	</cfscript>
	
	<cffunction name="init" output="false" returntype="Comment" access="public">
		<cfargument name="id" type="string" required="false" default="" />
		<cfargument name="entryId" type="string" required="false" default="" />
		<cfargument name="content" type="string" required="false" default="" />
		<cfargument name="creatorName" type="string" required="false" default="" />
		<cfargument name="creatorEmail" type="string" required="false" default="" />
		<cfargument name="creatorUrl" type="string" required="false" default="" />
		<cfargument name="createdOn" type="string" required="false" default="" />
		<cfargument name="approved" type="string" required="false" default="" />
		<cfargument name="authorId" type="string" required="false" default="" />
		<cfargument name="parentCommentId" type="string" required="false" default="" />
		<cfargument name="rating" type="numeric" required="false" default="0" />
		<cfargument name="entry" type="any" required="false" default="" />
		
		<cfscript>
			this.id = arguments.id;
			this.entryId = arguments.entryId;
			this.content = arguments.content;
			this.creatorName = arguments.creatorName;
			this.creatorEmail = arguments.creatorEmail;
			this.creatorUrl = arguments.creatorUrl;
			this.createdOn = arguments.createdOn;
			this.approved = arguments.approved;
			this.authorId = arguments.authorId;
			this.parentCommentId = arguments.parentCommentId;
			this.rating = arguments.rating;
			this.entry = arguments.entry;
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

	<cffunction name="setEntryId" access="public" returntype="void" output="false">
		<cfargument name="entryId" type="string" required="true" />
		<cfset this.entryId = arguments.entryId />
	</cffunction>
	<cffunction name="getEntryId" access="public" returntype="string" output="false">
		<cfreturn this.entryId />
	</cffunction>

	<cffunction name="setContent" access="public" returntype="void" output="false">
		<cfargument name="content" type="string" required="true" />
		<cfset this.content = arguments.content />

	</cffunction>
	<cffunction name="getContent" access="public" returntype="string" output="false">
		<cfreturn this.content />
	</cffunction>

	<cffunction name="setCreatorName" access="public" returntype="void" output="false">
		<cfargument name="creatorName" type="string" required="true" />
		<cfset this.creatorName = arguments.creatorName />
	</cffunction>
	<cffunction name="getCreatorName" access="public" returntype="string" output="false">
		<cfreturn this.creatorName />
	</cffunction>

	<cffunction name="setCreatorEmail" access="public" returntype="void" output="false">
		<cfargument name="creatorEmail" type="string" required="true" />
		<cfset this.creatorEmail = arguments.creatorEmail />
	</cffunction>
	<cffunction name="getCreatorEmail" access="public" returntype="string" output="false">
		<cfreturn this.creatorEmail />
	</cffunction>

	<cffunction name="setCreatorUrl" access="public" returntype="void" output="false">
		<cfargument name="creatorUrl" type="string" required="true" />
		<cfset this.creatorUrl = arguments.creatorUrl />
	</cffunction>
	<cffunction name="getCreatorUrl" access="public" returntype="string" output="false">
		<cfreturn this.creatorUrl />
	</cffunction>

	<cffunction name="setCreatedOn" access="public" returntype="void" output="false">
		<cfargument name="createdOn" type="string" required="true" />
		<cfset this.createdOn = arguments.createdOn />
	</cffunction>
	<cffunction name="getCreatedOn" access="public" returntype="string" output="false">
		<cfreturn this.createdOn />
	</cffunction>

	<cffunction name="setApproved" access="public" returntype="void" output="false">
		<cfargument name="approved" type="string" required="true" />
		<cfset this.approved = arguments.approved />
	</cffunction>
	<cffunction name="getApproved" access="public" returntype="string" output="false">
		<cfreturn this.approved />
	</cffunction>

	<cffunction name="setAuthorId" access="public" returntype="void" output="false">
		<cfargument name="authorId" type="string" required="true" />
		<cfset this.authorId = arguments.authorId />
	</cffunction>
	<cffunction name="getAuthorId" access="public" returntype="string" output="false">
		<cfreturn this.authorId />
	</cffunction>

	<cffunction name="setRating" access="public" returntype="void" output="false">
		<cfargument name="rating" type="numeric" required="true" />
		<cfset this.rating = arguments.rating />
	</cffunction>
	<cffunction name="getRating" access="public" returntype="numeric" output="false">
		<cfreturn this.rating />
	</cffunction>

	<cffunction name="setParentCommentId" access="public" returntype="void" output="false">
		<cfargument name="parentCommentId" type="string" required="true" />
		<cfset this.parentCommentId = arguments.parentCommentId />
	</cffunction>
	<cffunction name="getParentCommentId" access="public" returntype="string" output="false">
		<cfreturn this.parentCommentId />
	</cffunction>
	
	<cffunction name="setEntry" access="public" returntype="void" output="false">
		<cfargument name="approved" type="any" required="true" />
		<cfset this.entry = arguments.entry />
	</cffunction>
	<cffunction name="getEntry" access="public" returntype="entry" output="false">
		<cfreturn this.entry />
	</cffunction>
	
	<cffunction name="setAdditionalField" access="public" returntype="void" output="false">
		<cfargument name="field" type="string" required="true" />
		<cfargument name="value" type="string" required="true" />
		<cfset this.additionalFields[arguments.field] = arguments.value />
	</cffunction>
	
	<cffunction name="getAdditionalField" access="public" returntype="string" output="false">
		<cfargument name="field" type="string" required="true" />
		
		<cfif structkeyexists(this.additionalFields,arguments.field)>
			<cfreturn this.additionalFields[arguments.field] />
		<cfelse>
			<cfreturn "" />
		</cfif>
		
	</cffunction>
		
	
	<cffunction name="clone" access="public" returntype="Comment" output="false">
		<cfargument name="myClone" required="false" default="#createObject('component','Comment')#">
		
		<cfscript>
			arguments.myClone.init(this.id, this.entryId,
			this.content,
			this.creatorName,
			this.creatorEmail,
			this.creatorUrl,
			this.createdOn,
			this.approved,
			this.authorId,
			this.parentCommentId,
			this.rating);
		</cfscript>
		<cfreturn arguments.myClone />
	</cffunction>
	
	<cffunction name="isValidForSave" access="public" returntype="struct" output="false">
		<cfset var returnObj = structnew() />
		<cfset returnObj.status = true />
		<cfset returnObj.errors = arraynew(1) />
		
		<cfif len(this.creatorEmail) AND NOT isValid("email",this.creatorEmail)>
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"Email is not valid")/>			
		<cfelseif NOT len(this.creatorEmail)>
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"Email is required")/>		
		</cfif>
		<cfif NOT len(this.entryId)>
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"Post is required")/>			
		</cfif>
		<cfif NOT len(this.creatorName)>
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"Author name is required")/>			
		</cfif>

		<cfif NOT len(this.content)>
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"Content is required")/>			
		</cfif>
		<cfreturn returnObj />
		
	</cffunction>


	<cffunction name="getInstanceData" access="public" returntype="struct" output="false">
		
		<cfscript>
			var data = structnew();
			data["id"] = this.id;
			data["content"] = this.content;
			data["creatorName"] = this.creatorName;
			data["creatorEmail"] = this.creatorEmail;
			data["creatorUrl"] = this.creatorUrl;
			data["createdOn"] = this.createdOn;
			data["approved"] = this.approved;
			data["rating"] = this.rating;
			data["authorId"] = this.authorId;
			data["entryId"] = this.entryId;
			data["parentCommentId"] = this.parentCommentId;
			data["entry"] = "";
			
			if (NOT isvalid("string", this.entry)) {
				data["entry"] = this.entry.getInstanceData();
			}
		</cfscript>
	
		<cfreturn data />
	</cffunction>
</cfcomponent>