<cfcomponent>
		
	<cfset variables.id = "org.mangoblog.plugins.SubscriptionHandler">
	<cfset variables.package = "org/mangoblog/plugins/SubscriptionHandler"/>
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />	
		
		<cfset variables.manager = arguments.mainManager />
		<cfset variables.preferences = arguments.preferences />
		<cfset variables.scheduled = variables.preferences.get(variables.manager.getBlog().getId() & "/" & variables.package,"digest", 0) />
		
		<cfreturn this/>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getId" access="public" output="false" returntype="any">
		<cfreturn variables.id />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="any" required="true" />
		<cfset variables.id = arguments.id />
		<cfset variables.package = replace(variables.id,".","/","all") />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="boolean">
		<cfset var blogUrl = variables.manager.getBlog().getUrl() />
		<!--- set up scheduled task for digest mode subscriptions --->
		
		<cftry>
		<cfschedule action="update" task="sendDigestSubscriptions_#hash(blogUrl)#" 
					operation="HTTPRequest" startDate="#now()#"
					startTime="12:#randrange(0,60)# PM" url="#blogUrl#generic.cfm?action=event&event=sendDigestSubscriptions" 
					interval="daily" requestTimeOut="1000" />
				<cfset variables.scheduled = true />
				<cfset variables.preferences.put(variables.manager.getBlog().getId() & "/" & variables.package,"digest", 1)>
			<cfcatch type="any">
				<cfset variables.scheduled = false />
				<cfset variables.preferences.put(variables.manager.getBlog().getId() & "/" & variables.package,"digest", 0)>
			</cfcatch>
		</cftry>
		
		<cfreturn true />
	</cffunction>

	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<cfschedule action="delete" task="sendDigestSubscriptions_#hash(blogUrl)#" />
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var comment = "" />
		<cfset var queryInterface = variables.manager.getQueryInterface() />
		<cfset var gateway = createObject("component","SubscriptionGateway").init(queryInterface) />
		<cfset var dao = createObject("component","SubscriptionDAO").init(queryInterface) />
		<cfset var postid = "">
		<cfset var post = "">
		<cfset var addresses = "">
		<cfset var data = "" />
		<cfset var subscribe = "" />
		<cfset var isImport = false/>
		<cfset var emailTemplate= ""/>
		<cfset var subject = "" />
		<cfset var subjectStart = 0 />
		<cfset var bodyStart = 0 />
		<cfset var body = "" />
		<cfset var thisSubject = "" />
		<cfset var thisBody = "" />
		<cfset var lastRun = "" />
		<cfset var link = "" />
		<cfset var mail = structnew() />
		<cfset var mailer = variables.manager.getMailer() />
		<cfset var thisEntry = "" />
		<cfset var found = false />
		<cfset var postlink = "" />
		<cfset var mailFrom = variables.preferences.get(variables.manager.getBlog().getId() & "/" & variables.package,"mailFrom","") />
		<cfset var postAuthorEmail = "">
		<cfset var authorGateway = "">
		<cfset var notes = "" />
		
			<cfswitch expression="#arguments.event.getName()#">
				<!--- @TODO add after comment update to see if approved --->
				<cfcase value="afterCommentAdd">
					<cfset comment = arguments.event.getNewItem() />
					<cfset postid = comment.getEntryId()>
					<cfset addresses = gateway.getByEntry(postid,"comments","instant") />
					<cfset authorGateway = variables.manager.getAuthorsManager() />
					
					
					<cftry>
					<cfset thisEntry = variables.manager.getPostsmanager().getPostById(postid)>
					<cfset found = true />
					<cfcatch type="any"><!--- catching post not found --->						
							<cftry>
								<cfset thisEntry = variables.manager.getPagesmanager().getPageById(postid)>
								<cfset found = true />
							<cfcatch type="any"><!--- catching page not found ---></cfcatch>
							</cftry>
						</cfcatch>
					</cftry>
					
					<cfset postlink = variables.manager.getBlog().getUrl() & thisEntry.getUrl() />
					<cfset postAuthorEmail = authorGateway.getAuthorById(thisEntry.getAuthorId()).getEmail() />
					
					<!--- add subscriptions --->
					<cfset subscribe = comment.getAdditionalField("subscriptionHandler_subscribe") />
					<cfif len(subscribe) AND subscribe>
						<cfset dao.create(postid,comment.getCreatorEmail(),comment.getCreatorName(),"comments","instant") />	
					</cfif>

					<!--- check whether this is an imported comment, in which case, do not send the email --->
					<cfset isImport = comment.getAdditionalField("subscriptionHandler_isimport") />
					
					<cfif (NOT len(isImport) OR NOT isImport)>
						<cfif comment.getApproved()>
							<!--- also check whether this comment has been approved --->
							<cfsavecontent variable="emailTemplate">
								<cfinclude template="templates/emailTemplate.txt">
							</cfsavecontent>
								
							<!--- replace generic variables --->
							<cfset emailTemplate = replacenocase(emailTemplate,"{postTitle}",thisEntry.getTitle(),"all") />
							<cfset emailTemplate = replacenocase(emailTemplate,"{postLink}",postlink ,"all") />
							<cfset emailTemplate = replacenocase(emailTemplate,"{blogTitle}", variables.manager.getBlog().getTitle(),"all") />
							<cfset emailTemplate = replacenocase(emailTemplate,"{commentContent}",comment.getContent(),"all") />
							<cfset emailTemplate = replacenocase(emailTemplate,"{commentCreatorEmail}",comment.getCreatorEmail(),"all") />
							<cfset emailTemplate = replacenocase(emailTemplate,"{commentCreatorName}",comment.getCreatorName(),"all") />
							<cfset emailTemplate = replacenocase(emailTemplate,"{commentCreatorWebsite}",comment.getCreatorUrl(),"all") />
							<cfset emailTemplate = replacenocase(emailTemplate,"{commentId}",comment.getId(),"all") />
							<cfset emailTemplate = replacenocase(emailTemplate,"{blogUrl}", variables.manager.getBlog().getUrl(),"all") />
							<cfset emailTemplate = replacenocase(emailTemplate,"{postId}",thisEntry.getId(),"all") />
							<cfset subjectStart = findnocase("<subject>",emailTemplate) />
							<cfset bodyStart = findnocase("<emailbody>",emailTemplate) />
							
							<cfset subject = mid(emailTemplate,subjectStart+9,findnocase("</subject>",emailTemplate)-subjectStart-9)>
							<cfset body = mid(emailTemplate,bodyStart+11,findnocase("</emailbody>",emailTemplate)-bodyStart-11)>
							
							<cfoutput query="addresses">
								<cfif email NEQ comment.getCreatorEmail()>
									<cfset link = variables.manager.getBlog().getUrl() &  "generic.cfm?action=event&event=subscriptionSettings&entry=" & postid & "&email=" &
											email & "&type=" & type />
									<!--- replace variables --->
									<cfset thisBody = replacenocase(body,"{settingsLink}",link,"all") />
									<cfset thisSubject = replacenocase(subject,"{settingsLink}",link,"all") />								
									
									<cfset mail = structnew() />
									<cfif len(mailFrom)>
										<cfset mail.from = mailFrom />
									</cfif>
									<cfset mail.to = email />
									<cfset mail.subject = thisSubject />
									<cfset mail.body = thisBody />
									
									<!--- send email --->
									<cfset mailer.sendEmail(argumentCollection=mail) />
																					
								</cfif>
							</cfoutput>
							
						</cfif>
							
						<!--- email author, only if not the same as comment creator --->
						<!--- do the same but use different template --->
										
						<cfset subject = getTemplatePart("ownerEmailTemplate.txt","subject") />
						<cfset body = getTemplatePart("ownerEmailTemplate.txt","emailbody") />
						
						<cfif NOT comment.getApproved() AND comment.getRating() EQ -1>
							<cfset notes = "*Possible spam* - Delete: #variables.manager.getBlog().getUrl()#admin/comments.cfm?action=delete&id={commentId}&entry_id={postId}">
						</cfif>
						
						<!--- replace subject variables --->
						<cfset subject = replacenocase(subject,"{postTitle}",thisEntry.getTitle(),"all") />
						<cfset subject = replacenocase(subject,"{postLink}",postlink ,"all") />
						<cfset subject = replacenocase(subject,"{blogTitle}", variables.manager.getBlog().getTitle(),"all") />
						<cfset subject = replacenocase(subject,"{commentContent}",comment.getContent(),"all") />
						<cfset subject = replacenocase(subject,"{commentCreatorEmail}",comment.getCreatorEmail(),"all") />
						<cfset subject = replacenocase(subject,"{commentCreatorName}",comment.getCreatorName(),"all") />
						
						<!--- replace body variables --->
						<cfset body = replacenocase(body,"{notes}", notes,"all") />
						<cfset body = replacenocase(body,"{postTitle}",thisEntry.getTitle(),"all") />
						<cfset body = replacenocase(body,"{postLink}", postlink ,"all") />
						<cfset body = replacenocase(body,"{blogTitle}", variables.manager.getBlog().getTitle(),"all") />
						<cfset body = replacenocase(body,"{commentContent}",comment.getContent(),"all") />
						<cfset body = replacenocase(body,"{commentCreatorEmail}",comment.getCreatorEmail(),"all") />
						<cfset body = replacenocase(body,"{commentCreatorName}",comment.getCreatorName(),"all") />
						<cfset body = replacenocase(body,"{commentCreatorWebsite}",comment.getCreatorUrl(),"all") />
						<cfset body = replacenocase(body,"{commentId}",comment.getId(),"all") />
						<cfset body = replacenocase(body,"{blogUrl}", variables.manager.getBlog().getUrl(),"all") />
						<cfset body = replacenocase(body,"{adminUrl}", variables.manager.getBlog().getUrl() & "admin/","all") />
						<cfset body = replacenocase(body,"{postId}",thisEntry.getId(),"all") />
								
											
						<!--- send notification to author even if not approved --->
						<cfif postAuthorEmail NEQ comment.getCreatorEmail()>
							<cfset mail = structnew() />
							<cfif len(mailFrom)>
								<cfset mail.from = mailFrom />
							</cfif>
							<cfset mail.to = postAuthorEmail />
							<cfset mail.subject = subject />
							<cfset mail.body = body />
								
							<cfset mailer.sendEmail(argumentCollection=mail) />
						</cfif>	
					</cfif>
				</cfcase>
				
				<!--- digest subscriptions --->
				<cfcase value="sendDigestSubscriptions">
					<cfset sendDigest() />
				</cfcase>
				
			</cfswitch>
		
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var comment = "" />
		<cfset var data = "" />
		<cfset var subscribe = "" />
		<cfset var eventName = arguments.event.getName() />
		<cfset var page = "" />
		<cfset var entryId = "" />
		<cfset var entry = structnew() />
		<cfset var thisEntry = "" />
		<cfset var found = false />
		
		<cfset var thisSubsc = "" />
		<cfset var queryInterface = variables.manager.getQueryInterface() />
		<cfset var gateway = createObject("component","SubscriptionGateway").init(queryInterface) />
		<cfset var dao = createObject("component","SubscriptionDAO").init(queryInterface) />
		<cfset var subscription = ""/>
		<cfset var subscriptionsArray = ""/>
		
		<cfset var email = ""/>
		<cfset var i = 0 />
		
		<cfset var link = "" />
		<cfset var result = "" />
		<cfset var templates = "" />
		
		<!--- before adding a comment --->
		<cfif eventName EQ "beforeCommentAdd">
					<!--- add custom field to use later to check for subscription --->
					<cfset data = arguments.event.getData() />					
					<cfset comment = arguments.event.getNewItem() />
					<cfif structkeyexists(data.rawdata,"comment_subscribe")>
						<cfset comment.setAdditionalField("subscriptionHandler_subscribe",data.rawdata.comment_subscribe)>
					<cfelse>
						<cfset comment.setAdditionalField("subscriptionHandler_subscribe",false)>
					</cfif>
					<cfif structkeyexists(data.rawdata,"isImport")>
						<cfset comment.setAdditionalField("subscriptionHandler_isimport",data.rawdata.isImport)>
					<cfelse>
						<cfset comment.setAdditionalField("subscriptionHandler_isimport",false)>
					</cfif>
				
		<!--- settings form --->		
		<cfelseif eventName EQ "subscriptionSettings">	
		
					<!--- show settings template --->
					<cfset data = arguments.event.getData() />	
					<cfset email = data.externaldata.email/>
									
					<cfif structkeyexists(data.externaldata,"entry")>
						<!--- there is a specific entry the user wants to change --->
						<cfset entryId = data.externaldata.entry />
						<cftry>
							<cfset thisEntry = variables.manager.getPostsmanager().getPostById(entryId)>
							<cfset found = true />
							<cfcatch type="any"><!--- catching post not found --->						
									<cftry>
										<cfset thisEntry = variables.manager.getPagesmanager().getPageById(entryId)>
										<cfset found = true />
									<cfcatch type="any"><!--- catching page not found ---></cfcatch>
									</cftry>
								</cfcatch>
							</cftry>
						
						<cfif found>
							<cfset entry.recordcount = 1 />
							<cfset entry.title = thisEntry.getTitle() />
						</cfif>
						<cfset subscription = gateway.search(entryId,email,data.externaldata.type) />
						<cfset subscriptionsArray = getSubscriptions(email, subscription ) />
					<cfelse>
						<!--- since there is no specific entry, just set recordcount as 0 --->
						<cfset entry.recordcount = 0 />
						<cfset subscriptionsArray = getSubscriptions(email) />
					</cfif>
	
					<cfsavecontent variable="page">
							<cfinclude template="settingsForm.cfm">
					</cfsavecontent>
					
					<!--- change message --->
					<cfset data.message.setTitle("Subscription settings") />
					<cfset data.message.setData(page) />


			<!--- apply settings --->	
		<cfelseif eventName EQ "applySubscriptionSettings">
										
					<!--- get request data --->
					<cfset data = arguments.event.getData() />					
					
					<cfset entryId = data.externaldata.entry />
					<cfset email = data.externaldata.email />
					<cfset subscription = data.externaldata.subscriptionOption />
					
					<!--- delete old, add new if necessary --->
					<cfset result = dao.delete(entryId,email,data.externaldata.type) />
					
					<cfif subscription EQ "digest" OR subscription EQ "instant">
						<cfset result = dao.create(entryId,email,"",data.externaldata.type,subscription) />
						<cfif result.status>
							<cfset result.message = "You are now subscribed in " & subscription & " mode">
						</cfif>
					</cfif>
					
					<cfset subscriptionsArray = getSubscriptions(email ) />
					
					<cfsavecontent variable="page">
							<cfinclude template="applySettingsForm.cfm">
					</cfsavecontent>
					
					<!--- change message --->
					<cfset data.message.setTitle("Subscription settings") />
					<cfset data.message.setData(page) />
			
			
			<!--- Admin events --->
			<cfelseif eventName EQ "settingsNav">
				<cfset link = structnew() />
				
				<cfset link.owner = "SubscriptionHandler">
				<cfset link.page = "settings" />
				<cfset link.title = "Subscriptions" />
				<cfset link.eventName = "showSubscriptionsHandlerSettings" />
				<cfset arguments.event.addLink(link)>
			
			<cfelseif eventName EQ "showSubscriptionsHandlerSettings">
										
					<cfset data = arguments.event.getData() />
							
				<cfif structkeyexists(data.externaldata,"apply")>
					<!--- @TODO validate fields --->
					<cfif data.externaldata.mailFrom NEQ "[DEFAULT]">
						<cfset variables.preferences.put(variables.manager.getBlog().getId() & "/" & variables.package,"mailFrom",data.externaldata.mailFrom) />
					<cfelse>
						<cfset variables.preferences.remove(variables.manager.getBlog().getId() & "/" & variables.package,"mailFrom") />
					</cfif>
					
					<!--- update the parts --->
					<cfsavecontent variable="page"><cfoutput><subject>#data.externaldata.normal_subject#</subject>
						<emailbody>#data.externaldata.normal_body#</emailbody></cfoutput>
					</cfsavecontent>
					
					<!--- save the file --->
					<cffile action="write" file="#GetDirectoryFromPath(GetCurrentTemplatePath())#templates/emailTemplate.txt" output="#page#">
					
					<!--- update the parts --->
					<cfsavecontent variable="page"><cfoutput><subject>#data.externaldata.digest_subject#</subject>
						<emailbody><header>#data.externaldata.digest_header#</header>
						<repeat>#data.externaldata.digest_repeat#</repeat>
						<footer>#data.externaldata.digest_footer#</footer></emailbody></cfoutput>
					</cfsavecontent>
					
					<!--- save the file --->
					<cffile action="write" file="#GetDirectoryFromPath(GetCurrentTemplatePath())#templates/digestEmailTemplate.txt" output="#page#">
					
					<!--- update the parts --->
					<cfsavecontent variable="page"><cfoutput><subject>#data.externaldata.owner_subject#</subject>
						<emailbody>#data.externaldata.owner_body#</emailbody></cfoutput>
					</cfsavecontent>
					
					<!--- save the file --->
					<cffile action="write" file="#GetDirectoryFromPath(GetCurrentTemplatePath())#templates/ownerEmailTemplate.txt" output="#page#">
					
					<cfset data.message.setstatus("success") />
					<cfset data.message.setType("settings") />
					<cfset data.message.settext("Settings updated")/>
				</cfif>
				<cfset templates = getAllParts() />
				<cfset email = variables.preferences.get(variables.manager.getBlog().getId() & "/" & variables.package,"mailFrom","[DEFAULT]") />
				
				<cfsavecontent variable="page">
					<cfinclude template="admin/settingsForm.cfm">
				</cfsavecontent>
					
					<!--- change message --->
					<cfset data.message.setTitle("Subscription settings") />
					<cfset data.message.setData(page) />
							
			</cfif>		
		
		<cfreturn arguments.event />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getSubscriptions" access="private" output="false" returntype="array">
		<cfargument name="email" type="string" required="true" />
		<cfargument name="removeEntry" type="any" required="false" default="#structnew()#" />
			
			<cfset var queryInterface = variables.manager.getQueryInterface() />
			<cfset var gateway = createObject("component","SubscriptionGateway").init(queryInterface) />
			<cfset var subscriptions = gateway.getByemail(email) />
			<cfset var found = false />
			<cfset var thisEntry = "" />
			<cfset var subscriptionsArray = arraynew(2) />
			<cfset var counter = 0 />
						
			<cfoutput query="subscriptions">
				<cfset found = false />						
						
				<cftry>
					<cfset thisEntry = variables.manager.getPostsmanager().getPostById(entry_id)>
					<cfset found = true />
					<cfcatch type="any"><!--- catching post not found --->						
							<cftry>
								<cfset thisEntry = variables.manager.getPagesmanager().getPageById(entry_id)>
								<cfset found = true />
							<cfcatch type="any"><!--- catching page not found ---></cfcatch>
							</cftry>
						</cfcatch>
						</cftry>
						
						<cfif found>
							<cfif NOT structkeyexists(arguments.removeEntry,"entry_id") OR thisEntry.getId() NEQ arguments.removeEntry.entry_id>
																
								<cfset counter = counter + 1 />			
								<cfset subscriptionsArray[counter][1] = thisEntry />
								<cfset subscriptionsArray[counter][2] = type />
								<cfset subscriptionsArray[counter][3] = mode />
							</cfif>
						</cfif>
					</cfoutput>
			
		<cfreturn subscriptionsArray />
	</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="sendDigest" access="private" output="false" returntype="void">
		<cfset var queryInterface = variables.manager.getQueryInterface() />
		<cfset var gateway = createObject("component","SubscriptionGateway").init(queryInterface) />
		<cfset var dao = createObject("component","SubscriptionDAO").init(queryInterface) />
		<cfset var commentGateway = variables.manager.getCommentsmanager() />
		<cfset var postsManager = variables.manager.getPostsmanager() />
		<cfset var pagesManager = variables.manager.getPagesmanager() />
		<cfset var subscriptions = gateway.getByMode("digest") />
		<cfset var emailBody = "" />
		<cfset var emailHeader = getTemplatePart("digestEmailTemplate.txt","header") />
		<cfset var emailRepeat = getTemplatePart("digestEmailTemplate.txt","repeat") />
		<cfset var emailFooter = getTemplatePart("digestEmailTemplate.txt","footer") />
		<cfset var emailSubject = getTemplatePart("digestEmailTemplate.txt","subject") />
		<cfset var thisFooter = "" />
		<cfset var comments = structnew() />
		<cfset var emailRepeatBody = "" />
		<cfset var thisSubject = "" />
		<cfset var theseComments = "" />
		<cfset var entries = structnew() />
		<cfset var thisEntry = "" />
		<cfset var found = false />
		<cfset var blogTitle = variables.manager.getBlog().getTitle() />
		<cfset var blogUrl = variables.manager.getBlog().getUrl() />
		<cfset var link = "" />
		<cfset var mailer = variables.manager.getMailer() />
		<cfset var mail = "" />
		<cfset var sendMail = false />
		<cfset var i = 0 />
		<cfset var mailFrom = variables.preferences.get(variables.package,"mailFrom","") />
		
		<!--- get last run time --->
		<cfset var lastRun = variables.preferences.get(variables.package,"lastDigestRun",now()) />
		<!--- set last run time --->
		<cfset variables.preferences.put(variables.package,"lastDigestRun",now()) />
				
		<!--- get all the subscriptions grouped by email --->
		<cfoutput query="subscriptions" group="email">
			<cfset sendMail = false />
			
			<cfset thisSubject = emailSubject />
			<cfset thisSubject = replacenocase(thisSubject,"{blogTitle}",blogTitle,"all") />
			<cfset thisSubject = replacenocase(thisSubject,"{blogUrl}",blogUrl,"all") />
			
			<cfset emailBody = emailHeader />
			<cfset emailBody = replacenocase(emailBody,"{blogTitle}",blogTitle,"all") />
			<cfset emailBody = replacenocase(emailBody,"{blogUrl}",blogUrl,"all") />
			
			<cfset thisFooter = emailFooter />
			<cfset thisFooter = replacenocase(thisFooter,"{blogTitle}",blogTitle,"all") />
			<cfset thisFooter = replacenocase(thisFooter,"{blogUrl}",blogUrl,"all") />
			
			<cfset link = blogUrl &  "generic.cfm?action=event&event=subscriptionSettings" & "&email=" & email />
			
			<!--- replace variables --->
			<cfset emailBody = replacenocase(emailBody,"{settingsLink}",link,"all") />
			<cfset thisFooter = replacenocase(thisFooter,"{settingsLink}",link,"all") />
			
			<!--- for each subscription, loop over the entries and get the new comments --->
			<cfoutput>
				<cfset found = false />				
				
				<cfif NOT structkeyexists(entries,entry_id)>
					<cftry>
						<cfset thisEntry = postsManager.getPostById(entry_id)>
						<cfset found = true />
						<cfcatch type="any"><!--- catching post not found --->						
							<cftry>
								<cfset thisEntry = pagesManager.getPageById(entry_id)>
								<cfset found = true />
							<cfcatch type="any"><!--- catching page not found ---></cfcatch>
							</cftry>
						</cfcatch>
					</cftry>
					<cfif found>
						<cfset entries[entry_id] = thisEntry />
					</cfif>
				<cfelse>
					<cfset found = true />
				</cfif>
				
				<cfif found AND NOT structkeyexists(comments,entry_id)>				
					<!--- we don't have the comments for this entry --->
					<cfset comments[entry_id] = commentGateway.search(entry_id,lastRun,true) />					
				</cfif>
				
				<cfif found><!--- continue only if there is a valid entry --->
					<cfset theseComments = comments[entry_id] />
					<cfif arraylen(theseComments)>
						<cfset sendMail = true />
					</cfif>
					<!--- add the comments for that entry to the email --->
					<cfloop from="1" to="#arraylen(theseComments)#" index="i">
						<cfset emailRepeatBody = emailRepeat />
						<cfset emailRepeatBody = replacenocase(emailRepeatBody,"{postLink}",blogUrl & entries[entry_id].getUrl(),"all") />
						<cfset emailRepeatBody = replacenocase(emailRepeatBody,"{postTitle}",entries[entry_id].getTitle(),"all") />						
						<cfset emailRepeatBody = replacenocase(emailRepeatBody,"{commentCreatorEmail}",theseComments[i].getCreatorEmail(),"all") />
						<cfset emailRepeatBody = replacenocase(emailRepeatBody,"{commentCreatorName}",theseComments[i].getCreatorName(),"all") />
						<cfset emailRepeatBody = replacenocase(emailRepeatBody,"{commentCreatedOn}",dateformat(theseComments[i].getCreatedOn(),"medium") & " " & timeformat(theseComments[i].getCreatedOn(),"short"),"all") />
						<cfset emailRepeatBody = replacenocase(emailRepeatBody,"{commentContent}",theseComments[i].getContent(),"all") />
						
						<cfset emailBody = emailBody & emailRepeatBody />
						
					</cfloop>					
				</cfif>
				
			</cfoutput>	
			
			<!--- only send mail if there was at least one comment --->
			<cfif sendMail>
				<!--- add footer --->			
				<cfset emailBody = emailBody & thisFooter />
				
				<!--- send complete email --->
				<cfset mail = structnew() />
				<cfif len(mailFrom)>
					<cfset mail.from = mailFrom />
				</cfif>
				<cfset mail.to = email />
				<cfset mail.subject = thisSubject />
				<cfset mail.body = emailBody />
	
				<!--- send email --->
				<cfset mailer.sendEmail(argumentCollection=mail) />
			</cfif>
		</cfoutput>	
	
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getTemplatePart" access="private" output="false" returntype="string">
		<cfargument name="template" type="string" required="true" />
		<cfargument name="partName" type="string" required="true" />
		
		<cfset var part = "" />
		<cfset var templateContent = "" />
		<cfset var matches = "" />
		
		<cfsavecontent variable="templateContent">
				<cfinclude template="templates/#arguments.template#">
		</cfsavecontent>
		
		<cftry>
			<cfset matches = REFindNoCase("<#partName#>[^>]*</#partName#>",templateContent,1,true) />
			<cfset part = Mid(templateContent,matches.pos[1],matches.len[1]) />
			<cfset part = replacenocase(replacenocase(part,"<#partName#>",""),"</#partName#>","") />
			<cfcatch type="any"></cfcatch>
		</cftry>
					
		<cfreturn part />
	</cffunction>

	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAllParts" access="private" output="false" returntype="struct">
		
		<cfset var parts = structnew() />
		<!--- normal email --->
		<cfset parts["normal"] = structnew() />
		<cfset parts["normal"]["subject"] = getTemplatePart("emailTemplate.txt","subject") />
		<cfset parts["normal"]["body"] = getTemplatePart("emailTemplate.txt","emailbody") />
		
		<!--- digest email --->
		<cfset parts["digest"] = structnew() />
		<cfset parts["digest"]["subject"] = getTemplatePart("digestEmailTemplate.txt","subject") />
		<cfset parts["digest"]["header"] = getTemplatePart("digestEmailTemplate.txt","header") />
		<cfset parts["digest"]["repeat"] = getTemplatePart("digestEmailTemplate.txt","repeat") />
		<cfset parts["digest"]["footer"] = getTemplatePart("digestEmailTemplate.txt","footer") />
		
		<!--- owner email --->
		<cfset parts["owner"] = structnew() />
		<cfset parts["owner"]["subject"] = getTemplatePart("ownerEmailTemplate.txt","subject") />
		<cfset parts["owner"]["body"] = getTemplatePart("ownerEmailTemplate.txt","emailbody") />
					
		<cfreturn parts />
	</cffunction>

</cfcomponent>