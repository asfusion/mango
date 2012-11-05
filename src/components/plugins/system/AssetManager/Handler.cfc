<cfcomponent extends="org.mangoblog.plugins.BasePlugin">
	
	<cfset variables.maxCacheSize = 250 /><!--- in number of files --->
	<cfset variables.package = "org/mangoblog/plugins/AssetManager"/>
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
						
			<cfset super.init(arguments.mainManager, arguments.preferences) />
			<cfset initSettings(allowedDomains="flickr.com,picasa.com", fileType='jpg', quality=90) />
		<cfreturn this/>
		
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var data = arguments.event.data />
			<cfset var eventName = arguments.event.name />
			<cfset var manager = getManager() />
			<cfset var local = structnew() />

			<cfif eventName EQ "assetManager-getThumb">
				<cfset local.error = '' />
				<cfif NOT structkeyexists(data,"src")>
					<cfset local.error = "No source defined" />
				</cfif>
				<cfif NOT structkeyexists(data,"w") AND NOT structkeyexists(data,"h")>
					<cfset local.error = "Either width or height is required" />
				</cfif>
				
				<cfif NOT len(local.error)>
					<cfif NOT structkeyexists(data,"w")>
						<cfset data.w = 0 />
					</cfif>
					<cfif NOT structkeyexists(data,"h")>
						<cfset data.h = 0 />
					</cfif>
					<!--- d: redirection 0 (no), 1 (yes, default) --->
					<cfif NOT structkeyexists(data,"d")>
						<cfset data.d = 1 />
					</cfif>
					<cfset local.blog = getManager().getBlog()/>
					<cfset local.assets = local.blog.getSetting('assets') />
					<cftry>
						<cfset local.filename = getThumbnail(local.assets.directory, data.src, val(data.w), val(data.h),true) />
						<cfif data.d>
							<cfif NOT structkeyexists(local.assets,'cachePath')>
								<cfset local.redirectUrl = local.assets.path />
							<cfelse>
								<cfset local.redirectUrl = local.assets.cachePath />
							</cfif>
							<cfif NOT findNoCase("http",local.redirectUrl)>
								<cfset local.redirectUrl = local.blog.getUrl() & local.redirectUrl />
							</cfif>
							<cflocation addtoken="false" url="#local.redirectUrl##local.filename#">
						<cfelse>
							<cfcontent type="image/#getSetting('fileType')#" reset="false" />
							<cffile action="readbinary" file="#local.assets.directory##local.filename#" variable="local.filecontent">
							<cfset data.message.setData(local.filecontent) />
						</cfif>
						<cfcatch type="any"><cfset data.message.setData(cfcatch.message) /></cfcatch>
					</cftry>
				<cfelse>
					<cfset data.message.setData(local.error) />
				</cfif>
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getThumbnail" access="private" output="false" returntype="Any">
		<cfargument name="directory" type="string" required="true" />
		<cfargument name="source" type="string" required="true" />
		<cfargument name="width" type="numeric" required="false" default="0" />
		<cfargument name="height" type="numeric" required="false" default="0" />
		<cfargument name="resize" type="boolean" required="false" default="true" />
		
		<cfset var local = structnew() />
		<cfset var imageComponent = createObject("component","Image") />
		<cfset var fileExtension = getSetting('fileType') />
		<cfset var name = "#hash(arguments.source)#_#arguments.width#x#arguments.height#_#arguments.resize#.#fileExtension#" />
		
		<cfset local.cacheFolder = "__thumbnails/_cache/" />
		<cfset local.destination = arguments.directory & local.cacheFolder />
		
		<cfif NOT directoryexists(local.destination)>
			<cfdirectory action="create" directory="#local.destination#">
		</cfif>
		
		<cfif NOT fileexists(local.destination & name)>
			<!--- open the image to resize --->
			<cfif isvalid('url',arguments.source)>
				<!--- check to see if we are allowed to get images from this domain --->
				<cfif domainAllowed(arguments.source)>
					<cfset imageComponent.readImageFromURL(arguments.source) />
				<cfelse>
					<cfthrow type="NOT_ALLOWED" detail="Domain not allowed">
				</cfif>
			<cfelse>
				<cfset imageComponent.readImage(arguments.source) /> 
			</cfif>
			
			<!--- figure whether we should resize and crop, just crop or leave as is --->
			<cfset local.initialHeight = imageComponent.getHeight() />
			<cfset local.initialWidth = imageComponent.getWidth() />
			<cfif arguments.height EQ 0>
				<cfset arguments.height = local.initialHeight />
			</cfif>
			<cfif arguments.width EQ 0>
				<cfset arguments.width = local.initialWidth />
			</cfif>
			<cfif local.initialHeight GT arguments.height OR local.initialWidth GT arguments.width>
				<cfif arguments.resize>
					<cfset local.percentage = min(max(arguments.height/local.initialHeight, arguments.width/local.initialWidth),1) * 100 />
					<cfset imageComponent.scalePercent(local.percentage, local.percentage) />
				</cfif>
				<cfset imageComponent.setImageSize(min(arguments.width, local.initialWidth), min(arguments.height, local.initialHeight), "middleCenter") />
			</cfif>
			
			<!--- before writing the image, check to see if we need to clear the cache --->
			<cfset checkCache(local.destination) />
			<cfset imageComponent.writeImage(local.destination & name, fileExtension, getSetting('quality')) /> 
		</cfif>
		
		<cfreturn local.cacheFolder & name />
		
	</cffunction>
	
	<cffunction name="checkCache" access="private">
		<cfargument name="cacheDir" />
		
		<cfset var local = structnew() />
		<cfdirectory action="list" directory="#arguments.cacheDir#" name="local.dir" sort="datelastmodified asc" filter="*.*">
		<cfif local.dir.recordcount GTE variables.maxCacheSize>
			<!--- delete 20% of max size --->
			<cfset local.numberToDelete = int(variables.maxCacheSize * 0.2) />
			<cfoutput query="local.dir" maxrows="#local.numberToDelete#">
				<cffile action="delete" file="#directory#/#name#" />
			</cfoutput>
		</cfif>
			
	</cffunction>
	
	<cffunction name="domainAllowed" access="private">
		<cfargument name="domain">
		
		<cfset var local = structnew() />
		<cfset arguments.domain = reverse(parseUrl(arguments.domain).domain) />
		<cfset local.host = getManager().getBlog().getHost() />
		<cfset local.hostPartsLength = listlen(local.host,".") />
		<cfif local.hostPartsLength GTE 3>
			<cfset local.host = listgetat(local.host,local.hostPartsLength-1,".") & "." & listgetat(local.host,local.hostPartsLength,".") />
		</cfif>
		<cfset local.allowedDomains = listappend(getSetting("allowedDomains"), local.host) />
		<cfloop list="#local.allowedDomains#" index="local.item">
			<cfif findnocase(reverse(local.item),arguments.domain) EQ 1>
				<cfreturn true />
			</cfif>
		</cfloop>
		<cfreturn false />
	</cffunction>

	
<cfscript>
/**
 * Parses a Url and returns a struct with keys defining the information in the Uri.
 * 
 * @param sURL 	 String to parse. (Required)
 * @return Returns a struct. 
 * @author Dan G. Switzer, II (dswitzer@pengoworks.com) 
 * @version 1, January 10, 2007 
 */
function parseUrl(sUrl){
	// var to hold the final structure
	var stUrlInfo = structNew();
	// vars for use in the loop, so we don't have to evaluate lists and arrays more than once
	var i = 1;
	var sKeyPair = "";
	var sKey = "";
	var sValue = "";
	var aQSPairs = "";
	var sPath = "";
	/*
		from: http://www.ietf.org/rfc/rfc2396.txt

		^((([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*)))?
		 123            4  5          6       7  8        9 A

			scheme    = $3
			authority = $5
			path      = $6
			query     = $8
			fragment  = $10 (A)
	*/
	var sUriRegEx = "^(([^:/?##]+):)?(//([^/?##]*))?([^?##]*)(\?([^##]*))?(##(.*))?";
	/*
		separates the authority into user info, domain and port

		^((([^@:]+)(:([^@]+))?@)?([^:]*)?(:(.*)))?
		 123       4 5           6       7 8

			username  = $3
			password  = $5
			domain    = $6
			port      = $8
	*/
	var sAuthRegEx = "^(([^@:]+)(:([^@]+))?@)?([^:]*)?(:(.*))?";
	/*
		separates the path into segments & parameters

		((/?[^;/]+)(;([^/]+))?)
		12         3 4

			segment     = $1
			path        = $2
			parameters  = $4
	*/
	var sSegRegEx = "(/?[^;/]+)(;([^/]+))?";

	// parse the url looking for info
	var stUriInfo = reFindNoCase(sUriRegEx, sUrl, 1, true);
	// this is for the authority section
	var stAuthInfo = "";
	// this is for the segments in the path
	var stSegInfo = "";

	// create empty keys
	stUrlInfo["scheme"] = "";
	stUrlInfo["authority"] = "";
	stUrlInfo["path"] = "";
	stUrlInfo["directory"] = "";
	stUrlInfo["file"] = "";
	stUrlInfo["query"] = "";
	stUrlInfo["fragment"] = "";
	stUrlInfo["domain"] = "";
	stUrlInfo["port"] = "";
	stUrlInfo["username"] = "";
	stUrlInfo["password"] = "";
	stUrlInfo["params"] = structNew();

	// get the scheme
	if( stUriInfo.len[3] gt 0 ) stUrlInfo["scheme"] = mid(sUrl, stUriInfo.pos[3], stUriInfo.len[3]);
	// get the authority
	if( stUriInfo.len[5] gt 0 ) stUrlInfo["authority"] = mid(sUrl, stUriInfo.pos[5], stUriInfo.len[5]);
	// get the path
	if( stUriInfo.len[6] gt 0 ) stUrlInfo["path"] = mid(sUrl, stUriInfo.pos[6], stUriInfo.len[6]);
	// get the path
	if( stUriInfo.len[8] gt 0 ) stUrlInfo["query"] = mid(sUrl, stUriInfo.pos[8], stUriInfo.len[8]);
	// get the fragment
	if( stUriInfo.len[10] gt 0 ) stUrlInfo["fragment"] = mid(sUrl, stUriInfo.pos[10], stUriInfo.len[10]);

	// break authority into user info, domain and ports
	if( len(stUrlInfo["authority"]) gt 0 ){
		// parse the authority looking for info
		stAuthInfo = reFindNoCase(sAuthRegEx, stUrlInfo["authority"], 1, true);

		// get the domain
		if( stAuthInfo.len[6] gt 0 ) stUrlInfo["domain"] = mid(stUrlInfo["authority"], stAuthInfo.pos[6], stAuthInfo.len[6]);
		// get the port
		if( stAuthInfo.len[8] gt 0 ) stUrlInfo["port"] = mid(stUrlInfo["authority"], stAuthInfo.pos[8], stAuthInfo.len[8]);
		// get the username
		if( stAuthInfo.len[3] gt 0 ) stUrlInfo["username"] = mid(stUrlInfo["authority"], stAuthInfo.pos[3], stAuthInfo.len[3]);
		// get the password
		if( stAuthInfo.len[5] gt 0 ) stUrlInfo["password"] = mid(stUrlInfo["authority"], stAuthInfo.pos[5], stAuthInfo.len[5]);
	}

	// the query string in struct form
	stUrlInfo["params"]["segment"] = structNew();

	// if the path contains any parameters, we need to parse them out
	if( find(";", stUrlInfo["path"]) gt 0 ){
		// this is for the segments in the path
		stSegInfo = reFindNoCase(sSegRegEx, stUrlInfo["path"], 1, true);

		// loop through all the segments and build the strings
		while( stSegInfo.pos[1] gt 0 ){
			// build the path, excluding parameters
			sPath = sPath & mid(stUrlInfo["path"], stSegInfo.pos[2], stSegInfo.len[2]);

			// if there are some parameters in this segment, add them to the struct
			if( stSegInfo.len[4] gt 0 ){

				// put the parameters into an array for easier looping
				aQSPairs = listToArray(mid(stUrlInfo["path"], stSegInfo.pos[4], stSegInfo.len[4]), ";");

				// now, loop over the array and build the struct
				for( i=1; i lte arrayLen(aQSPairs); i=i+1 ){
					sKeyPair = aQSPairs[i]; // current pair
					sKey = listFirst(sKeyPair, "="); // current key
					// make sure there are 2 keys
					if( listLen(sKeyPair, "=") gt 1){
						sValue = urlDecode(listLast(sKeyPair, "=")); // current value
					} else {
						sValue = ""; // set blank value
					}
					// check if key already added to struct
					if( structKeyExists(stUrlInfo["params"]["segment"], sKey) ) stUrlInfo["params"]["segment"][sKey] = listAppend(stUrlInfo["params"]["segment"][sKey], sValue); // add value to list
					else structInsert(stUrlInfo["params"]["segment"], sKey, sValue); // add new key/value pair
				}
			}

			// get the ending position
			i = stSegInfo.pos[1] + stSegInfo.len[1];

			// get the next segment
			stSegInfo = reFindNoCase(sSegRegEx, stUrlInfo["path"], i, true);
		}

	} else {
		// set the current path
		sPath = stUrlInfo["path"];
	}

	// get the file name
	stUrlInfo["file"] = getFileFromPath(sPath);
	// get the directory path by removing the file name
	if( len(stUrlInfo["file"]) gt 0 ){
		stUrlInfo["directory"] = replace(sPath, stUrlInfo["file"], "", "one");
	} else {
		stUrlInfo["directory"] = sPath;
	}

	// the query string in struct form
	stUrlInfo["params"]["url"] = structNew();

	// if query info was supplied, break it into a struct
	if( len(stUrlInfo["query"]) gt 0 ){
		// put the query string into an array for easier looping
		aQSPairs = listToArray(stUrlInfo["query"], "&");

		// now, loop over the array and build the struct
		for( i=1; i lte arrayLen(aQSPairs); i=i+1 ){
			sKeyPair = aQSPairs[i]; // current pair
			sKey = listFirst(sKeyPair, "="); // current key
			// make sure there are 2 keys
			if( listLen(sKeyPair, "=") gt 1){
				sValue = urlDecode(listLast(sKeyPair, "=")); // current value
			} else {
				sValue = ""; // set blank value
			}
			// check if key already added to struct
			if( structKeyExists(stUrlInfo["params"]["url"], sKey) ) stUrlInfo["params"]["url"][sKey] = listAppend(stUrlInfo["params"]["url"][sKey], sValue); // add value to list
			else structInsert(stUrlInfo["params"]["url"], sKey, sValue); // add new key/value pair
		}
	}

	// return the struct
	return stUrlInfo;
}
</cfscript>
</cfcomponent>