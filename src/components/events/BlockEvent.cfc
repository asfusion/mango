<cfcomponent hint="Represents an event that is broadcasted to add pod items" extends="TemplateEvent" alias="org.mangoblog.event.BlockEvent">
	<cfproperty name="blocks" type="array" />
	<cfproperty name="id" type="string" />
	<cfproperty name="allowedBlocks" type="string" />
	<cfproperty name="orderedBlockIds" type="array" />
	
	<cfset this.type = "BlockEvent" />
	<cfset this.blocks = arraynew(1) />
	<cfset this.id = '' />
	<cfset this.allowedBlocks =  "*"/>
	<cfset this.orderedBlockIds =  [] />

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setData" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		
			<cfset super.setData(arguments.data)/>
			<cfif isstruct(arguments.data)>
				<cfif structkeyexists(arguments.data,"blocks")>
					<cfset setBlocks(arguments.data.blocks) />
				</cfif>
				<cfif structkeyexists(arguments.data,"id")>
					<cfset this.id = arguments.data.id />
				</cfif>
			</cfif>
		<cfset this.data = arguments.data />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getBlocks" access="public" output="false" returntype="any">
		<cfreturn this.blocks />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setBlocks" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset this.blocks = arguments.data />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="addBlock" access="public" output="false" returntype="boolean">
		<cfargument name="data" type="any" required="true" />
		<!--- only add it if it is allowed --->
		<cfif this.allowedBlocks EQ "*" OR listfindnocase(this.allowedBlocks, data.id)>
			<cfset arrayappend(this.blocks, arguments.data) />
			<cfreturn true />
		</cfif>
		<cfreturn false />
	</cffunction>
</cfcomponent>