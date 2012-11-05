<cfcomponent name="util" description="Various utilities">

 <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="invokeComponent" output="false" hint="Private method to invoke a component dynamically" access="private" returntype="void">
	<cfargument name="component" type="any" required="true" hint="Reference to component object">
	<cfargument name="method" type="string" required="true" hint="">
	<cfargument name="parameters" type="struct" required="false" default="#structnew()#" hint="">
		
	<cfinvoke component="#arguments.component#" method="#arguments.method#"  argumentcollection="#arguments.parameters#">
	
</cffunction>

 <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="makeCleanString" output="false" hint="Creates a nice string to use in URLs" access="public" returntype="string">
	<cfargument name="stringToClean" type="string" required="true">
	<cfargument name="maxLength" type="numeric" required="false" default="150">
	<cfargument name="maxWords" type="numeric" required="false" default="70">	
		
		<!--- Code provided by Seb Duggan, thank you! --->
		<cfset var s = lcase(arguments.stringToClean) />
		<cfset var i = 0 />
		<cfset var c = "" />
		<cfset var cleanedString = "" />
		
		<cfloop from="1" to="#len(s)#" index="i">
			<cfset c = mid(s,i,1) />
			
			<cfswitch expression="#asc(c)#">
				<cfcase delimiters="," value="192,193,194,195,196,197,224,225,226,227,228,229">
					<cfset c = "a" />
				</cfcase>
				
				<cfcase delimiters="," value="198,230">
					<cfset c = "ae" />
				</cfcase>
				
				<cfcase delimiters="," value="199,231">
					<cfset c = "c" />
				</cfcase>
				
				<cfcase delimiters="," value="200,201,202,203,232,233,234,235">
					<cfset c = "e" />
				</cfcase>
				
				<cfcase delimiters="," value="204,205,206,207,236,237,238,239">
					<cfset c = "i" />
				</cfcase>
				
				<cfcase delimiters="," value="208,240">
					<cfset c = "d" />
				</cfcase>

				<cfcase delimiters="," value="209,241">
	               <cfset c = "n" />
	            </cfcase>

	            <cfcase delimiters="," value="210,211,212,213,214,216,242,243,244,245,246,248">
	               <cfset c = "o" />
	            </cfcase>
	
	            <cfcase delimiters="," value="215">
	               <cfset c = "x" />
	            </cfcase>
	
	            <cfcase delimiters="," value="217,218,219,220,249,250,251,252">
	               <cfset c = "u" />
	            </cfcase>
	
	            <cfcase delimiters="," value="221,253,255">
	               <cfset c = "y" />
	            </cfcase>
	
	            <cfcase delimiters="," value="222,254">
	               <cfset c = "p" />
	            </cfcase>
	
	            <cfcase delimiters="," value="223">
	               <cfset c = "b" />
	            </cfcase>
	         </cfswitch>

	         <cfset cleanedString = cleanedString & c />
	      </cfloop>
	
	      <cfset cleanedString = rereplace(cleanedString, "[^a-z0-9]", "-", "all") />
	      <cfset cleanedString = rereplace(cleanedString, "-{2,}", "-", "all") />
	      <cfset cleanedString = rereplace(cleanedString, "(^-|-$)", "", "all") />
	
		<cfreturn cleanedString />
	</cffunction>

</cfcomponent>