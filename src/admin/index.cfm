<cfimport prefix="mangoAdmin" taglib="tags">
<cfparam name="message" default="">
<cfparam name="error" default="">

<cfset currentAuthor = request.blogManager.getCurrentUser() />
<cfset currentBlogId = request.blogManager.getBlog().getId() />
<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>

<cfif NOT structkeyexists(url, "update") AND listfind(currentRole.permissions, "manage_system")>
	<!--- check current version --->
	<cfset message = request.blogManager.getUpdater().checkForUpdates() />
</cfif>

<cfif structkeyexists(url, "first")>
	<cfset message ='Welcome to your blog! <br/>You can now edit the <a href="categories.cfm">categories</a>, or <a href="post.cfm">write a new post</a>
	<br />Also, don''t forget to edit your blog''s <a href="settings.cfm">settings</a>.</p>'/>
</cfif>

<cfif len(message)>
	<cfset message = '<p class="infomessage">#message#</p>' />
<cfelseif len(error)>
	<cfset message = '<p class="error">#error#</p>' />
</cfif>

<cf_layout page="Overview" title="Overview">
	<div id="wrapper">
		<div id="content">
		<h2 class="pageTitle">Overview</h2>
			<div id="innercontent">
			<cfoutput>#message#</cfoutput>
			<cfif structkeyexists(url, "update") AND listfind(currentRole.permissions, "manage_system")>
				<cfflush interval="5">
				<cfoutput>
					<div class="message">
						<cfset updateResult = request.blogManager.getUpdater().executeUpdate() />
						<p>#updateResult.message.getText()#</p>
						<br />
					</div>
					<cfif updateResult.message.getStatus() EQ "error">
						<p class="error">#updateResult.message.getText()#</p>
					</cfif>
				</cfoutput>
			</cfif>
			
			<mangoAdmin:PodEvent name="dashboardPod" />
			</div>
		</div>
	</div>
</cf_layout>