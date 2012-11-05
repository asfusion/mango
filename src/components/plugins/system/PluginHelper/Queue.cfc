<cfcomponent name="Queue">

	<cfproperty name="elements" type="any" />
	
	<cfset variables.elements = arraynew(1) />
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getTotalElements" access="public" output="false" returntype="numeric">
		
		<cfreturn arraylen(variables.elements) />
	</cffunction>
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getElements" access="public" output="false" returntype="any">
		
		<cfset var tempArray = arraynew(1) />
		<cfset var i = 0 />
		<cfloop index="i" from="1" to="#arraylen(variables.elements)#">
			<cfset tempArray[i] = variables.elements[i].obj />
		</cfloop>
		<cfreturn tempArray />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="addElement" access="public" output="false" returntype="any">
		<cfargument name="element" type="any" required="false" />
		<cfargument name="priority" type="numeric" required="false" />

			<cfset var i = 0/>
			<cfset var elementObj = structnew() />
			<cfset var lastIndex = arraylen(variables.elements) />
			<cfset elementObj.obj = arguments.element />
			<cfset elementObj.priority = arguments.priority />
			
			<!--- find first element with lower priority --->
			<cfif lastIndex EQ 0 OR variables.elements[lastIndex].priority GTE arguments.priority>
				<!--- add element to end of array --->
				<cfset arrayappend(variables.elements,elementObj) />
			<cfelse>
				<!--- insert element before first element with a lower priority --->
				<cfloop index="i" from="1" to="#lastIndex#">
					<cfif variables.elements[i].priority LT arguments.priority>
						<cfset arrayinsertat(variables.elements,i,elementObj) />
						<!--- get out  --->
						<cfbreak />
					</cfif>
				</cfloop>
			</cfif>
		
		<cfreturn />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="removeElement" access="public" output="false" returntype="any">
		<!--- TODO: Implement Method --->
		<cfreturn />
	</cffunction>
</cfcomponent>