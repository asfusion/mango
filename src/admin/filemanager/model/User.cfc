<cfcomponent output="false" alias="com.asfusion.fileexplorer.model.User">
	<cfproperty name="id" type="numeric" default="0">
	<cfproperty name="permissions" type="struct" default="">
	<cfproperty name="allowedDirectories" type="array">
	
	<cfscript>
		this.id = 0;
		this.permissions = structnew();
		this.allowedDirectories = arraynew(1);
		this.allowedDirectories[1] = '/';
	</cfscript>

	<cffunction name="init" output="false" access="public">
	
		<cfscript>
			var permission = createObject("component","Permission");
			
			this.permissions[permission.FILE_UPLOAD] = true;
			this.permissions[permission.FILE_DELETE] = true;
			this.permissions[permission.FILE_RENAME] = true;
			
			this.permissions[permission.DIRECTORY_CREATE] = true;
			this.permissions[permission.DIRECTORY_RENAME] = true;
			this.permissions[permission.DIRECTORY_DELETE] = true;
			
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="clone" output="false" access="public">
		<cfscript>
			var clone = createObject("component","User");
			
			clone.id = this.id;
			clone.permissions = structCopy(this.permissions);
			clone.allowedDirectories = duplicate(this.allowedDirectories);
			
			return clone;
		</cfscript>
	</cffunction>
	
	
	<cffunction name="isAllowed" output="true" access="public" returntype="boolean">
		<cfargument name="action" required="true" type="string" />
		<cfargument name="path" required="true" type="string" />
		<cfscript>
			var permissible = false;	
			var i = 0;
			var index = 0;
			var trail = '';
			
			if (find('/', arguments.path) NEQ 1) {
				arguments.path = '/' & arguments.path;
			}
			
			for (i = 1; i LTE arraylen(this.allowedDirectories); i = i + 1)
			{
				if(this.allowedDirectories[i] EQ "/")
				{
					permissible = true;
					break;
				}
				
				if(len(this.allowedDirectories[i]) LTE len(arguments.path))
				{
					index = findnocase(this.allowedDirectories[i], arguments.path);
					trail = mid(arguments.path, len(this.allowedDirectories[i]) + 1, len(arguments.path) - len(this.allowedDirectories[i]) + 1);
					if(index EQ 1 AND (len(trail) EQ 0 OR find('/', trail) EQ 1))
					{
						permissible = true;
						break;
					}
				}
			}
			
			return permissible AND structkeyexists(this.permissions, arguments.action) AND this.permissions[arguments.action];
			
		</cfscript>
	</cffunction>

</cfcomponent>