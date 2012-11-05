<cfsetting enablecfoutputonly="true">
<!--- Code based on Steven Erat's code at:  
http://www.talkingtree.com/blog/index.cfm/2005/11/15/TagCloudPod
--->
<cfparam name="attributes.includeStyle" default="true">

<!--- starting tag --->
<cfif thisTag.executionMode EQ "start">	

	<cfset items = request.blogManager.getCategoriesManager().getCategories("count")/>
	<cfif NOT structkeyexists(request, "blog_basepath")>
		<cfset request.blog_basepath = request.blogManager.getBlog().getBasePath() />
	</cfif>
	<cfif arraylen(items)>
	<cfset max = items[arraylen(items)].getPostCount()>
	<cfset min = items[1].getPostCount()>
   
	<cfset diff = max - min>
	<!---
      scaleFactor will affect the degree of difference between the different font sizes.
      if you have one really large category and many smaller categories, then set higher.
      if your category count does not vary too much try a lower number.      
	--->
	<cfset scaleFactor = 25>
	<cfset distribution = diff / scaleFactor>

	<cfif attributes.includeStyle>
	<cfoutput>
	<style type="text/css">
		.smallestTag { font-size: xx-small; }
		.smallTag { font-size: small; }
		.mediumTag { font-size: medium; }
		.largeTag { font-size: large; }
		.largestTag { font-size: xx-large; }
	</style>
  	</cfoutput>
	</cfif>
	<cfloop index="i" from="#arraylen(items)#" to="1" step="-1">
		<cfset count = items[i].getPostCount() />
		<cfif count EQ min>
			<cfset class="smallestTag">
		<cfelseif count EQ max>
			<cfset class="largestTag">
		<cfelseif count GT (min + (distribution*2))>
			<cfset class="largeTag">
		<cfelseif count GT (min + distribution)>
			<cfset class="mediumTag">
		<cfelse>
			<cfset class="smallTag">
		</cfif>
         <cfoutput><a href="#request.blog_basepath##items[i].getUrl()#"><span class="#class#">#lcase(xmlformat(items[i].getTitle()))#</span></a> </cfoutput>
      </cfloop>

	</cfif>

 </cfif>

<cfsetting enablecfoutputonly="false">