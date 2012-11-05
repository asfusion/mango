<cfsilent><?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE preferences SYSTEM "http://java.sun.com/dtd/preferences.dtd">
<preferences EXTERNAL_XML_VERSION="1.0">
	<root type="system">
		<map/>				    
		<node name="generalSettings">
			<map/>
			<node name="dataSource">
				<map>
					<entry key="name" value="your_dsn"/>
					<entry key="username" value="if_your_connection_needs_username"/>
					<entry key="password" value="if_your_connection_needs_password"/>
					<entry key="type" value="mssql_or_mysql"/>
					<entry key="tablePrefix" value="some_prefix"/>
				</map>
			</node>
			<!---<node name="facade">
				<map>
					<entry key="component" value=""/>
				</map>
					
					<node name="settings">
						<map>
							<entry key="someCustomSettingForFacade" value="settingValue"/>
						</map>
					</node>
			</node>--->
		</node>
	</root>
</preferences></cfsilent>

