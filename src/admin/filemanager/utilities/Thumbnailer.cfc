<cfcomponent output="false">
	
	<cfset variables.width = 85 />
	<cfset variables.height = 99 />

	<cffunction name="createThumbnail" access="public" output="false" returntype="Any">
		<cfargument name="source" type="string" required="true">
		<cfargument name="destination" type="string" required="true">
		
		<!--- we can use different libraries, pick the one that works best for you --->
		<cfset var imageComponent = createObject("component","Image") />
		
		<!--- open the image to resize ---> 
		<cfset imageComponent.readImage(arguments.source) /> 
 
		<!--- resize the image to a specific width and height ---> 
		<cfset imageComponent.scaleToBox(variables.width,variables.height) /> 
 
		<!--- output the image in png format ---> 
		<cfset imageComponent.writeImage(arguments.destination, "png", 99) /> 
		
		<!--- _______________________ --->
		<!--- if using tmt_img --->
		<!---
		<cfset var imageComponent = createObject("component","tmt_img") />
		<cfset imageComponent.resize(arguments.source, arguments.destination, variables.width,variables.height) />
		 ---->
		
		<!--- _______________________ --->
		<!--- if using built-in cfimage methods --->
		<!---
		<cfset var image = '' />
		<cfimage source="#arguments.source#" name="image">
		<cfset ImageSetAntialiasing(image,"on")>
		<cfset ImageScaleToFit(image,variables.width, variables.height)>
		<cfimage source="#image#" action="write" destination="#arguments.destination#" overwrite="true">
		 ---->
		
		<cfreturn />
	</cffunction>
</cfcomponent>