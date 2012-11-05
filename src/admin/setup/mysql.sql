<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE #prefix#author (
  `id` varchar(35) NOT NULL default '',
  `username` varchar(50) NOT NULL default '',
  `password` varchar(50) NOT NULL default '',
  `name` varchar(100) NOT NULL default '',
  `email` varchar(255) NOT NULL default '',
  `description` text default NULL,
  `shortdescription` text default NULL,
  `picture` varchar(100) NOT NULL default '',
  `alias` varchar(100) NOT NULL default '',
  `active` tinyint(1) default '1',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `IX_#prefix#author` (`username`),
  KEY `IX_#prefix#author_1` (`alias`)
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE `#prefix#permission` (
	`id` varchar(20) NOT NULL,
	`name` varchar(50) default NULL,
	`description` varchar(255) default NULL,
	`is_custom` tinyint(1) default '1',
	PRIMARY KEY(`id`)
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
INSERT INTO #prefix#permission(id, name, description, is_custom)
	VALUES('access_admin', 'Access site admin', 'If not enabled, user will have no access to the admin pages', 0),
	('manage_all_pages', 'Manage pages', 'Add, edit and remove any page', 0),
	('manage_all_posts', 'Manage all posts', 'Edit and remove other author''s posts', 0),
	('manage_categories', 'Manage categories', 'Add, edit and delete categories', 0),
	('manage_files', 'Manage files', 'Upload, rename and delete files', 0),
	('manage_links', 'Manage links', 'Add, edit and remove links', 0),
	('manage_pages', 'Manage own pages', 'Add, edit, and remove pages created by the user', 0),
	('manage_plugins', 'Manage plugins', 'Install and remove plugins', 0),
	('manage_plugin_prefs', 'Manage plugin custom settings', 'Change settings specified by plugins', 0),
	('manage_posts', 'Manage own posts', 'Create and edit own posts', 0),
	('manage_settings', 'Manage blog settings', 'Change blog main settings', 0),
	('manage_themes', 'Manage themes', 'Download and remove themes', 0),
	('manage_users', 'Manage users', 'Add and edit users and permissions', 0),
	('publish_pages', 'Publish pages', 'If not enabled, user can only create drafts or "to review" pages', 0),
	('publish_posts', 'Publish posts', 'If not enabled, user can only create drafts or "to review" posts', 0),
	('set_plugins', 'Manage installed plugins', 'Activate and de-activate plugins', 0),
	('set_themes', 'Switch themes', 'Change the blog theme', 0),
	('manage_pods', 'Manage pods', 'Add, remove and re-order pods added to the blog''s sidebars', 0),
	('manage_system', 'Manage system', 'Update blog and change system settings', 0),
	('set_profile', 'Update own profile', 'Update own username, password, description and picture', 0),
	('manage_comments', 'Manage comments', 'Edit and delete comments', 0)
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE `#prefix#role` (
	`id` varchar(20) NOT NULL,
	`name` varchar(50) default NULL,
	`description` varchar(255) default NULL,
	`preferences` text default NULL,
  PRIMARY KEY  (`id`)
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
INSERT INTO `#prefix#role` (id, name, description, preferences)
  VALUES('administrator', 'Administrator', 'Somebody who has access to all the administration features.', ''),
('author', 'Author', 'Somebody who can publish and manage their own posts and pages.', ''),
('editor', 'Editor', 'Somebody who can publish posts, manage posts as well as manage other people''s posts.', '');
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE  `#prefix#role_permission` (
  `role_id` varchar(20) NOT NULL,
  `permission_id` varchar(20) NOT NULL,
  PRIMARY KEY (`permission_id`, `role_id`),
  CONSTRAINT `FK_#prefix#role_permission_role` FOREIGN KEY `FK_#prefix#role_permission_role` (`role_id`)
    REFERENCES `#prefix#role` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_#prefix#role_permission_permission` FOREIGN KEY `FK_#prefix#role_permission_permission` (`permission_id`)
    REFERENCES `#prefix#permission` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
INSERT INTO #prefix#role_permission(role_id, permission_id)
  VALUES('administrator', 'access_admin'),
		('author', 'access_admin'),
		('editor', 'access_admin'),
		('administrator', 'manage_all_pages'),
		('author', 'manage_all_pages'),
		('editor', 'manage_all_pages'),
		('administrator', 'manage_all_posts'),
		('editor', 'manage_all_posts'),
		('administrator', 'manage_categories'),
		('author', 'manage_categories'),
		('editor', 'manage_categories'),
		('administrator', 'manage_files'),
		('author', 'manage_files'),
		('editor', 'manage_files'),
		('administrator', 'manage_links'),
		('editor', 'manage_links'),
		('administrator', 'manage_pages'),
		('author', 'manage_pages'),
		('editor', 'manage_pages'),
		('administrator', 'manage_plugins'),
		('administrator', 'manage_plugin_prefs'),
		('editor', 'manage_plugin_prefs'),
		('administrator', 'manage_posts'),
		('author', 'manage_posts'),
		('editor', 'manage_posts'),
		('administrator', 'manage_settings'),
		('administrator', 'manage_themes'),
		('administrator', 'manage_users'),
		('administrator', 'publish_pages'),
		('author', 'publish_pages'),
		('editor', 'publish_pages'),
		('administrator', 'publish_posts'),
		('author', 'publish_posts'),
		('editor', 'publish_posts'),
		('administrator', 'set_plugins'),
		('administrator', 'set_themes'),
		('administrator', 'manage_pods'),
		('administrator', 'manage_system'),
		('editor', 'set_themes'),
		('administrator', 'set_profile'),
		('author', 'set_profile'),
		('editor', 'set_profile'),
		('administrator', 'manage_comments'),
		('author', 'manage_comments'),
		('editor', 'manage_comments');
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE `#prefix#blog` (
 `id` varchar(50) NOT NULL default '',
  `title` varchar(150) default NULL,
  `description` text default NULL,
  `tagline` varchar(150) default NULL,
  `skin` varchar(100) default NULL,
  `url` varchar(255) default NULL,
  `charset` varchar(50) default NULL,
  `basepath` varchar(255) default NULL,
  `plugins` text,
  `systemplugins` text,
  PRIMARY KEY  (`id`)
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE  `#prefix#author_blog` (
  `author_id` varchar(35) NOT NULL default '',
  `blog_id` varchar(50) NOT NULL default '',
	`role` varchar(20) NULL,
  PRIMARY KEY  (`author_id`,`blog_id`)
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE `#prefix#setting` (
  `path` varchar(255) NOT NULL default '',
  `name` varchar(100) NOT NULL default '',
  `value` longtext,
  `blog_id` varchar(50) default '',
  KEY `IX_#prefix#setting_path` (`path`),
  KEY `IX_#prefix#setting_blog` (`blog_id`)
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE `#prefix#category` (
  `id` varchar(35) NOT NULL default '',
  `name` varchar(150) default NULL,
  `title` varchar(150) default NULL,
  `description` varchar(150) default NULL,
  `created_on` datetime default NULL,
  `parent_category_id` varchar(35) default NULL,
  `blog_id` varchar(50) default NULL,
  PRIMARY KEY  (`id`),
  KEY `IX_#prefix#category` (`blog_id`),
  CONSTRAINT `FK_#prefix#category_blog` FOREIGN KEY (`blog_id`) REFERENCES `#prefix#blog` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE `#prefix#entry` (
 `id` varchar(35) NOT NULL default '',
  `name` varchar(200) NOT NULL default '',
  `title` varchar(200) NOT NULL default '',
  `content` LONGTEXT default NULL,
  `excerpt` text default NULL,
  `author_id` varchar(35) default NULL,
  `comments_allowed` tinyint(1) NOT NULL default '1',
  `trackbacks_allowed` tinyint(1) default NULL,
  `status` varchar(50) default NULL,
  `last_modified` datetime default NULL,
  `blog_id` varchar(50) default NULL,
  PRIMARY KEY  (`id`),
  KEY `IX_#prefix#entry` (`name`),
  KEY `FK_#prefix#entry_author` (`author_id`),
  KEY `FK_#prefix#entry_blog` (`blog_id`),
  CONSTRAINT `FK_#prefix#entry_author` FOREIGN KEY (`author_id`) REFERENCES `#prefix#author` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_#prefix#entry_blog` FOREIGN KEY (`blog_id`) REFERENCES `#prefix#blog` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE `#prefix#entry_custom_field` (
  `id` varchar(255) NOT NULL default '',
  `entry_id` varchar(35) NOT NULL default '',
  `name` varchar(255) default NULL,
  `field_value` text default NULL,
  PRIMARY KEY  (`id`,`entry_id`),
  KEY `FK_#prefix#entry_custom_field_entry` (`entry_id`),
  CONSTRAINT `FK_#prefix#entry_custom_field_entry` FOREIGN KEY (`entry_id`) REFERENCES `#prefix#entry` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE  `#prefix#entry_subscription` (
  `entry_id` varchar(35) NOT NULL default '',
  `email` varchar(100) NOT NULL default '',
  `name` varchar(50) default NULL,
  `type` varchar(20) NOT NULL default '',
  `mode` varchar(20) NOT NULL default 'instant',
  PRIMARY KEY  (`entry_id`,`email`,`type`),
  CONSTRAINT `FK_#prefix#subscription_entry` FOREIGN KEY (`entry_id`) REFERENCES `#prefix#entry` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE `#prefix#entry_revision` (
  `id` varchar(35) NOT NULL,
  `entry_id` varchar(35) default NULL,
  `name` varchar(200) default NULL,
  `title` varchar(200) default NULL,
  `content` longtext,
  `excerpt` longtext,
  `author_id` varchar(35) default NULL,
  `last_modified` datetime default NULL,
  `entry_type` varchar(10) default NULL,
  PRIMARY KEY  (`id`),
  KEY `IX_#prefix#entry_revision` (`entry_id`)
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE  `#prefix#media` (
  `id` varchar(35) NOT NULL default '',
  `entry_id` varchar(35) default NULL,
  `url` varchar(255) default NULL,
  `fileSize` int(10) unsigned default NULL,
  `type` varchar(50) default NULL,
  `medium` varchar(50) default NULL,
  `isDefault` tinyint(3) unsigned default NULL,
  `duration` int(10) unsigned default NULL,
  `height` int(10) unsigned default NULL,
  `width` int(10) unsigned default NULL,
  `lang` varchar(50) default NULL,
  `rating` varchar(50) default NULL,
  `rating_scheme` varchar(10) default NULL,
  `title` varchar(100) default NULL,
  `description` text default NULL,
  `thumbnail` varchar(255) default NULL,
  `media_group` varchar(35) default NULL,
  `copyright` varchar(50) default NULL,
  PRIMARY KEY  (`id`),
  KEY `IX_#prefix#media` (`entry_id`),
  CONSTRAINT `FK_#prefix#media_entry` FOREIGN KEY (`entry_id`) REFERENCES `#prefix#entry` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE `#prefix#page` (
  `id` varchar(35) NOT NULL default '0',
  `template` varchar(100) default NULL,
  `parent_page_id` varchar(35) default NULL,
  `hierarchy` text default NULL,
  `sort_order` int(10) unsigned NOT NULL default '1',
  PRIMARY KEY  (`id`)
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE `#prefix#post` (
  `id` varchar(35) NOT NULL default '0',
  `posted_on` datetime default NULL,
  PRIMARY KEY  (`id`)
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE `#prefix#comment` (
  `id` varchar(35) NOT NULL default '',
  `entry_id` varchar(35) default NULL,
  `content` text default NULL,
  `creator_name` varchar(50) default NULL,
  `creator_email` varchar(100) default NULL,
  `creator_url` varchar(255) default NULL,
  `created_on` datetime default NULL,
  `approved` tinyint(1) default NULL,
  `author_id` varchar(35) default NULL,
  `parent_comment_id` varchar(35) default NULL,
  `rating` float default NULL,
  PRIMARY KEY  (`id`),
  KEY `IX_#prefix#comment` (`entry_id`),
  KEY `FK_#prefix#comment_author` (`author_id`),
  KEY `FK_#prefix#comment_comment` (`parent_comment_id`),
  CONSTRAINT `FK_#prefix#comment_author` FOREIGN KEY (`author_id`) REFERENCES `#prefix#author` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_#prefix#comment_comment` FOREIGN KEY (`parent_comment_id`) REFERENCES `#prefix#comment` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_#prefix#comment_entry` FOREIGN KEY (`entry_id`) REFERENCES `#prefix#entry` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE `#prefix#post_category` (
  `post_id` char(35) NOT NULL default '0',
  `category_id` char(35) NOT NULL default '0',
  PRIMARY KEY  (`post_id`,`category_id`),
  KEY `FK_#prefix#post_category_category` (`category_id`),
  CONSTRAINT `FK_#prefix#post_category_post` FOREIGN KEY (`post_id`) REFERENCES `#prefix#post` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE  `#prefix#trackback` (
  `id` varchar(35) NOT NULL default '',
  `entry_id` varchar(35) default NULL,
  `content` text default NULL,
  `title` varchar(200) default NULL,
  `creator_url` varchar(255) default NULL,
  `creator_url_title` varchar(50) default NULL,
  `created_on` datetime default NULL,
  `approved` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_#prefix#trackback_entry` (`entry_id`),
  CONSTRAINT `FK_#prefix#trackback_entry` FOREIGN KEY (`entry_id`) REFERENCES `#prefix#entry` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE  `#prefix#link` (
  `id` varchar(35) NOT NULL,
  `title` varchar(100) default NULL,
  `description` varchar(1000) default NULL,
  `address` varchar(255) default NULL,
  `category_id` varchar(35) default NULL,
  `showOrder` int(11) default '0',
  PRIMARY KEY  (`id`)
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE  `#prefix#link_category` (
  `id` varchar(35) NOT NULL,
  `name` varchar(50) default NULL,
  `description` varchar(1000) default NULL,
  `parent_category_id` varchar(35) default NULL,
  `blog_id` varchar(50) default NULL,
   PRIMARY KEY  (`id`)
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>


<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
CREATE TABLE `#prefix#log` (
  `level` varchar(20) default NULL,
  `category` varchar(30) default NULL,
  `message` longtext,
  `logged_on` datetime default NULL,
  `blog_id` varchar(50) default NULL,
  `owner` varchar(255) default NULL
) CHARACTER SET utf8 COLLATE utf8_general_ci;
</cfquery>

<cfquery name="setup" datasource="#dsn#" username="#username#" password="#password#">
INSERT INTO #prefix#setting(path, name, value, blog_id)
  VALUES('system/assets', 'directory', '{baseDirectory}assets/content/', NULL),
		('system/assets', 'path', 'assets/content/', NULL),
		('system/mail', 'server','',NULL),
		('system/mail', 'username','',NULL),
		('system/mail', 'password','',NULL),
		('system/urls', 'searchUrl','archives.cfm/search/',NULL),
		('system/urls', 'postUrl','post.cfm/{postName}',NULL),
		('system/urls', 'authorUrl','author.cfm/{authorAlias}',NULL),
		('system/urls', 'archivesUrl','archives.cfm/',NULL),
		('system/urls', 'categoryUrl','archives.cfm/category/{categoryName}',NULL),
		('system/urls', 'pageUrl','page.cfm/{pageHierarchyNames}{pageName}',NULL),
		('system/urls', 'rssUrl','feeds/rss.cfm',NULL),
		('system/urls', 'atomUrl','feeds/atom.cfm',NULL),
		('system/urls', 'apiUrl','api',NULL),
		('system/urls', 'useFriendlyUrls','1',NULL),
		('system/urls', 'admin','',NULL),
		('system/engine/logging', 'level','warning',NULL),
		('system/engine', 'enableThreads','0',NULL),
		('system/skins', 'directory','{baseDirectory}skins/',NULL),
		('system/skins', 'path','',NULL),
		('system/skins', 'url','',NULL),
		('system/authorization', 'methods','native',NULL),
		('system/search', 'component','search.DatabaseSimple',NULL),
		('system/plugins', 'directory','{componentsDirectory}plugins/',NULL),
		('system/plugins', 'path','plugins.',NULL);
</cfquery>
