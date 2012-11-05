<cfcomponent name="EntryDAO" hint="Manages entries">
      
 <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="init" output="false" returntype="any" hint="instantiates an object of this class" access="public">
	<cfargument name="datasource" required="true" type="struct">
		
		<cfset variables.datasource = arguments.datasource />
		<cfset variables.dsn = arguments.datasource.name />
		<cfset variables.prefix = arguments.datasource.tablePrefix />
		<cfset variables.username = arguments.datasource.username />
		<cfset variables.password = arguments.datasource.password />
		<cfreturn this />
		
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="read" output="false" access="public" returntype="any">
		<cfargument name="entry" required="true" type="any" hint="Entry object to populate"/>
		
		<cfset var qRead="">

		<cfquery name="qRead" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			select 	id, name, title, content, excerpt, author_id, 	comments_allowed, status, last_modified
			from #variables.prefix#entry
			where id = <cfqueryparam value="#arguments.entry.getId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>

		<cfscript>
			arguments.entry.setName(qRead.name);
			arguments.entry.setTitle(qRead.title);
			arguments.entry.setContent(qRead.content);
			arguments.entry.setExcerpt(qRead.excerpt);
			arguments.entry.setAuthorId(qRead.author_id);
			arguments.entry.setCommentsAllowed(qRead.comments_allowed);
			arguments.entry.setStatus(qRead.status);
			arguments.entry.setLastModified(qRead.last_modified);
			return arguments.entry;
		</cfscript>
	</cffunction> 


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="store" output="false" hint="Inserts a new record" access="public" returntype="any">
	<cfargument name="entry" required="true" type="any" hint="Entry object"/>

		<cfset var id = arguments.entry.getId() />
		<!--- @TODO validate unique name --->
		<cfif len(id)>
			<!--- update --->
			<cfreturn update(arguments.entry) />
		<cfelse>
			<cfreturn create(arguments.entry) />
		</cfif>	

</cffunction>

	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<!--- Overwrite this method! --->
<cffunction name="create" output="false" hint="Inserts a new record" access="public" returntype="struct">
	<cfargument name="entry" required="true" type="any" hint="entry object"/>
	<cfscript>
		var qinsertentry = "";
		var id = arguments.entry.getId();
		var customfields = arguments.entry.getCustomFieldsAsArray();
		var returnObj = structnew();
		var i = 0;
		returnObj["status"] = false;
		returnObj["message"] = "";
		if (NOT len(id)){
			id = createUUID();
		}
		
		arguments.entry.setId(id);
	</cfscript>

<!---	<cftry> --->
	<cfquery name="qinsertentry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		INSERT INTO #variables.prefix#entry
		(id, name,title,content,excerpt,author_id,comments_allowed,status,last_modified,blog_id)
		VALUES (
		<cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
		<cfqueryparam value="#arguments.entry.getName()#" cfsqltype="CF_SQL_VARCHAR" maxlength="200"/>,
		<cfqueryparam value="#arguments.entry.getTitle()#" cfsqltype="CF_SQL_VARCHAR" maxlength="200"/>,
		<cfqueryparam value="#arguments.entry.getContent()#" cfsqltype="CF_SQL_LONGVARCHAR"/>,
		<cfqueryparam value="#arguments.entry.getExcerpt()#" cfsqltype="CF_SQL_LONGVARCHAR" />,
		<cfqueryparam value="#arguments.entry.getAuthorId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
		<cfqueryparam value="#arguments.entry.getCommentsAllowed()#" cfsqltype="cf_sql_tinyint"/>,
		<cfqueryparam value="#arguments.entry.getStatus()#" cfsqltype="CF_SQL_VARCHAR" maxlength="50"/>,
		<cfqueryparam value="#arguments.entry.getLastModified()#" cfsqltype="cf_sql_timestamp"/>,
		<cfqueryparam value="#arguments.entry.getBlogId()#" cfsqltype="CF_SQL_VARCHAR"/>	
		)
	 </cfquery>
		 
	 <!--- store custom fields --->
	 <cfset setCustomFields(arguments.entry)>
	 
	<cfset returnObj["status"] = true/>

<!---		<cfcatch type="Any">
			<cfset returnObj["status"] = false/>
			<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
		</cfcatch>
	</cftry> --->

	<cfif returnObj["status"]>
		<cfset returnObj["message"] = "Insert successful"/>
		<cfset returnObj["data"] = arguments.entry />
	<cfelse>
		<cfset arguments.entry.setId('')>
	</cfif>

	<cfreturn returnObj/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="update" output="false" hint="Updates a record" access="public" returntype="struct">
	<cfargument name="entry" required="true" type="any" hint="entry object"/>

    <cfscript>
		var qupdateentry = "";
		var qDeleteCustomFields = '';
		var returnObj = structnew();		
		returnObj["status"] = false;
		returnObj["message"] = "";
	</cfscript>

	<cftry>
		<cfquery name="qupdateentry"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			UPDATE #variables.prefix#entry
			SET
			name = <cfqueryparam value="#arguments.entry.getName()#" cfsqltype="CF_SQL_VARCHAR" maxlength="200"/>,
			title = <cfqueryparam value="#arguments.entry.getTitle()#" cfsqltype="CF_SQL_VARCHAR" maxlength="200"/>,
			content = <cfqueryparam value="#arguments.entry.getContent()#" cfsqltype="CF_SQL_LONGVARCHAR"/>,
			excerpt = <cfqueryparam value="#arguments.entry.getExcerpt()#" cfsqltype="CF_SQL_LONGVARCHAR" />,
			author_id = <cfqueryparam value="#arguments.entry.getAuthorId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
			comments_allowed = <cfqueryparam value="#arguments.entry.getCommentsAllowed()#" cfsqltype="cf_sql_tinyint"/>,
			status = <cfqueryparam value="#arguments.entry.getStatus()#" cfsqltype="CF_SQL_VARCHAR" maxlength="50"/>,	
			last_modified = <cfqueryparam value="#arguments.entry.getLastModified()#" cfsqltype="cf_sql_timestamp"/>
			
			WHERE id = <cfqueryparam value="#arguments.entry.getId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>
		
		<!--- remove all old custom fields --->
		<cfquery name="qDeleteCustomFields" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			DELETE FROM #variables.prefix#entry_custom_field
			WHERE entry_id = <cfqueryparam value="#arguments.entry.getId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		 </cfquery>
		 
		<cfset setCustomFields(arguments.entry)>
		
		<cfset returnObj["status"] = true/>

		<cfcatch type="Any">
			<cfset returnObj["status"] = false/>
			<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail />
		</cfcatch>
	</cftry>

	<cfif returnObj["status"]>
		<cfset returnObj["message"] = "Insert successful"/>
		<cfset returnObj["data"] = arguments.entry />
	</cfif>

	<cfreturn returnObj/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="delete" output="false" hint="Deletes a record" access="public" returntype="struct">
<cfargument name="id" required="true" type="string" hint="Primary key"/>
    
    <cfscript>
		var qdeleteentry = "";
		var qDeleteCustomFields = '';
		var returnObj = structnew();
		returnObj["status"] = false;
		returnObj["message"] = "";
	</cfscript>

	<cftry>
		<!--- remove all old custom fields --->
		<cfquery name="qDeleteCustomFields" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			DELETE FROM #variables.prefix#entry_custom_field
			WHERE entry_id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		 </cfquery>
		
		<cfquery name="qdeleteentry"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
            DELETE FROM #variables.prefix#entry
			WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>
	
		<cfset returnObj["status"] = true/>
		
    	<cfcatch type="Any">
    		<cfset returnObj["status"] = false/>
     	   <cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail />
		</cfcatch>
	</cftry>
    						
	<cfif returnObj["status"]>
    	<cfset returnObj["message"] = "Delete successful"/>
		<cfset returnObj["data"] = arguments.id />
    </cfif>
    
	<cfreturn returnObj/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setCustomFields" access="package">
		<cfargument name="entry" required="true" type="any" hint="entry object"/>
		
		<cfset var qCreateCustomFields = '' />
		<cfset var customfields = arguments.entry.getCustomFieldsAsArray() />
		<cfset var i = 0 />
		
		<!--- store custom fields --->
		<cfif arraylen(customfields)>
			<cfloop from="1" to="#arraylen(customfields)#" index="i">
				<!--- fields with no value will not be added --->
				<cfif len(customfields[i].value)>
					<cfquery name="qCreateCustomFields" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
						INSERT INTO #variables.prefix#entry_custom_field
						(id, entry_id, name, field_value)
						VALUES (
						<cfqueryparam value="#customfields[i].key#" cfsqltype="CF_SQL_VARCHAR" maxlength="255"/>,
						<cfqueryparam value="#arguments.entry.getId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
						<cfqueryparam value="#customfields[i].name#" cfsqltype="CF_SQL_VARCHAR" maxlength="255"/>,
						<cfqueryparam value="#customfields[i].value#" />
						)
					</cfquery>
				 </cfif>
			 </cfloop>
		 </cfif>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setCustomField" access="public">
		<cfargument name="entryId" required="true" type="any" hint="entry id"/>
		<cfargument name="key" required="true" type="string" hint="custom field key"/>
		<cfargument name="name" required="true" type="string" hint="custom field name"/>
		<cfargument name="value" required="true" type="string" hint="custom field value"/>
		
		<cfscript>
			var qDeleteCustomFields = '';
			var qCreateCustomFields = "";
			var returnObj = structnew();
			returnObj["status"] = true;
			returnObj["message"] = "";
			returnObj["data"] = arguments;
		</cfscript>

		<!--- remove old custom field --->
		<cfquery name="qDeleteCustomFields" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			DELETE FROM #variables.prefix#entry_custom_field
			WHERE entry_id = <cfqueryparam value="#arguments.entryId#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
			AND id = <cfqueryparam value="#arguments.key#" cfsqltype="CF_SQL_VARCHAR"/>
		</cfquery>
		
		<!--- store custom field --->
		<!--- fields with no value will not be added --->
		<cfif len(arguments.value)>
			<cfquery name="qCreateCustomFields" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
				INSERT INTO #variables.prefix#entry_custom_field
					(id, entry_id, name, field_value)
				VALUES (
					<cfqueryparam value="#arguments.key#" cfsqltype="CF_SQL_VARCHAR" maxlength="255"/>,
					<cfqueryparam value="#arguments.entryId#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
					<cfqueryparam value="#arguments.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="255"/>,
					<cfqueryparam value="#arguments.value#" />
				)
			</cfquery>
		</cfif>
		
		<cfif returnObj["status"]>
	    	<cfset returnObj["message"] = "Update successful"/>
	    </cfif>
	    
		<cfreturn returnObj/>
	</cffunction>
</cfcomponent>