<cfparam name="attributes.showFields" default="">
<cfparam name="attributes.title" default="">
<cfparam name="attributes.name" default="">
<cfparam name="attributes.excerpt" default="">
<cfparam name="attributes.content" default="">
<cfset showFields = attributes.showFields />
<cfset title = attributes.title />
<cfset name = attributes.name />
<cfset excerpt = attributes.excerpt />
<cfset content = attributes.content />
<cfif thisTag.executionmode EQ "start"><cfoutput>
    <div class="card card-body border-0 shadow mb-4">
<!--- TITLE --->
    <cfif listfind(showFields,'title')>
        <div class="mb-3">
            <div>
                <label for="title">Title</label>
                <input class="form-control" id="title" type="text" name="title" value="#htmleditformat(title)#" placeholder="Enter post title" required>
            </div>
        </div>
    <cfelse>
        <input type="hidden" name="title" value="#htmleditformat(title)#" />
    </cfif>

<!--- CONTENT --->
    <cfif listfind(showFields,'content')>
        <div class="mb-3">
            <label for="contentField">Content</label>
            <textarea class="form-control htmlEditor required" placeholder="Enter post content" id="contentField" name="content" rows="4">#htmleditformat(content)#</textarea>
        </div>
    <cfelse>
        <input type="hidden" name="content" value="#htmleditformat(content)#" />
    </cfif>

<!--- EXCERPT --->
    <cfif listfind(showFields,'excerpt')>
        <div class="mb-3">
            <label for="excerpt">Excerpt</label>

            <textarea class="form-control htmlEditor" id="excerpt" name="excerpt">#htmleditformat(excerpt)#</textarea>
            <div class="form-text hint">Short summary describing post</div>
        </div>
    <cfelse>
        <input type="hidden" name="excerpt" value="#htmleditformat(excerpt)#" />
    </cfif>

<!--- URL --->
    <cfif listfind(showFields,'name')>
        <cfif not len(name) or not REFind("^[a-z0-9]+(-[a-z0-9]+)*$",name)>
            <div class="mb-3">
                <label for="name">URL-safe title</label>
                <input class="form-control {urlslug:true}" type="text" id="name" name="name" value="#htmleditformat(name)#">
                <div class="form-text hint">Define your own URL. Will be auto-generated when published if left blank.</div>
            </div>
        </cfif>
    <cfelse>
        <input type="hidden" name="name" value="#htmleditformat(name)#" />
    </cfif>
    </div>
</cfoutput>
</cfif>