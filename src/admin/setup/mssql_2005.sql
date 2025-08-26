
<cfquery name="setup" datasource="#dsn#"  username="#username#" password="#password#">

CREATE TABLE #prefix#author (
	id varchar (35) NOT NULL ,
	username nvarchar (50) NULL ,
	password nvarchar (50) NULL ,
	name nvarchar (100) NULL ,
	email nvarchar (255) NULL ,
	description nvarchar(max) NULL ,
	shortdescription nvarchar(max) NULL ,
	picture varchar (100) NULL ,
	alias varchar (100) NULL,
	active bit NULL DEFAULT 1
) 

CREATE TABLE #prefix#permission (
	id         	varchar(20) NOT NULL,
    name       	varchar(50) NULL,
    description	varchar(255) NULL,
    is_custom  	bit NULL DEFAULT (1),
    CONSTRAINT PK_#prefix#permission PRIMARY KEY(id)
)

INSERT INTO #prefix#permission(id, name, description, is_custom)
			SELECT 'access_admin', 'Access site admin', 'If not enabled, user will have no access to the admin pages', 0
UNION ALL	SELECT 'manage_all_pages', 'Manage pages', 'Add, edit and remove any page', 0
UNION ALL	SELECT 'manage_all_posts', 'Manage all posts', 'Edit and remove other author''s posts', 0
UNION ALL	SELECT 'manage_categories', 'Manage categories', 'Add, edit and delete categories', 0
UNION ALL	SELECT 'manage_files', 'Manage files', 'Upload, rename and delete files', 0
UNION ALL	SELECT 'manage_links', 'Manage links', 'Add, edit and remove links', 0
UNION ALL	SELECT 'manage_pages', 'Manage own pages', 'Add, edit, and remove pages created by the user', 0
UNION ALL	SELECT 'manage_plugins', 'Manage plugins', 'Install and remove plugins', 0
UNION ALL	SELECT 'manage_plugin_prefs', 'Manage plugin custom settings', 'Change settings specified by plugins', 0
UNION ALL	SELECT 'manage_posts', 'Manage own posts', 'Create and edit own posts', 0
UNION ALL	SELECT 'manage_settings', 'Manage blog settings', 'Change blog main settings', 0
UNION ALL	SELECT 'manage_themes', 'Manage themes', 'Download and remove themes', 0
UNION ALL	SELECT 'manage_users', 'Manage users', 'Add and edit users and permissions', 0
UNION ALL	SELECT 'publish_pages', 'Publish pages', 'If not enabled, user can only create drafts or "to review" pages', 0
UNION ALL	SELECT 'publish_posts', 'Publish posts', 'If not enabled, user can only create drafts or "to review" posts', 0
UNION ALL	SELECT 'set_plugins', 'Manage installed plugins', 'Activate and de-activate plugins', 0
UNION ALL	SELECT 'set_themes', 'Switch themes', 'Change the blog theme', 0
UNION ALL	SELECT 'manage_pods', 'Manage pods', 'Add, remove and re-order pods added to the blog''s sidebars', 0
UNION ALL	SELECT 'manage_system', 'Manage system', 'Update blog and change system settings', 0
UNION ALL	SELECT 'set_profile', 'Update own profile', 'Update own username, password, description and picture', 0
UNION ALL	SELECT 'manage_comments', 'Manage comments', 'Edit and delete comments', 0

CREATE TABLE #prefix#role ( 
	id  	varchar(20) NOT NULL,
	name	varchar(50) NULL,
	description varchar(255) default NULL,
	preferences nvarchar(max) default NULL,
	CONSTRAINT PK_#prefix#role PRIMARY KEY(id)
)

INSERT INTO #prefix#role (id, name, description, preferences)
  VALUES('administrator', 'Administrator', 'Somebody who has access to all the administration features.', '');
INSERT INTO #prefix#role (id, name, description, preferences)
  VALUES('author', 'Author', 'Somebody who can publish and manage their own posts and pages.', '');
INSERT INTO #prefix#role (id, name, description, preferences)
  VALUES('editor', 'Editor', 'Somebody who can publish posts, manage posts as well as manage other people''s posts.', '');

  
CREATE TABLE #prefix#role_permission ( 
    role_id      	varchar(20) NOT NULL,
    permission_id	varchar(20) NOT NULL,
    CONSTRAINT PK_#prefix#role_permission PRIMARY KEY(permission_id,role_id)
)

ALTER TABLE #prefix#role_permission
    ADD CONSTRAINT FK_#prefix#role_permission_role
	FOREIGN KEY(role_id)
	REFERENCES #prefix#role(id)
	ON DELETE CASCADE  ON UPDATE CASCADE

ALTER TABLE #prefix#role_permission
    ADD CONSTRAINT FK_#prefix#role_permission_permission
	FOREIGN KEY(permission_id)
	REFERENCES #prefix#permission(id)
	ON DELETE CASCADE  ON UPDATE CASCADE


INSERT INTO #prefix#role_permission(role_id, permission_id)
			SELECT 'administrator', 'access_admin'
UNION ALL	SELECT 'author', 'access_admin'
UNION ALL	SELECT 'editor', 'access_admin'
UNION ALL	SELECT 'administrator', 'manage_all_pages'
UNION ALL	SELECT 'author', 'manage_all_pages'
UNION ALL	SELECT 'editor', 'manage_all_pages'
UNION ALL	SELECT 'administrator', 'manage_all_posts'
UNION ALL	SELECT 'editor', 'manage_all_posts'
UNION ALL	SELECT 'administrator', 'manage_categories'
UNION ALL	SELECT 'author', 'manage_categories'
UNION ALL	SELECT 'editor', 'manage_categories'
UNION ALL	SELECT 'administrator', 'manage_files'
UNION ALL	SELECT 'author', 'manage_files'
UNION ALL	SELECT 'editor', 'manage_files'
UNION ALL	SELECT 'administrator', 'manage_links'
UNION ALL	SELECT 'editor', 'manage_links'
UNION ALL	SELECT 'administrator', 'manage_pages'
UNION ALL	SELECT 'author', 'manage_pages'
UNION ALL	SELECT 'editor', 'manage_pages'
UNION ALL	SELECT 'administrator', 'manage_plugins'
UNION ALL	SELECT 'administrator', 'manage_plugin_prefs'
UNION ALL	SELECT 'editor', 'manage_plugin_prefs'
UNION ALL	SELECT 'administrator', 'manage_posts'
UNION ALL	SELECT 'author', 'manage_posts'
UNION ALL	SELECT 'editor', 'manage_posts'
UNION ALL	SELECT 'administrator', 'manage_settings'
UNION ALL	SELECT 'administrator', 'manage_themes'
UNION ALL	SELECT 'administrator', 'manage_users'
UNION ALL	SELECT 'administrator', 'publish_pages'
UNION ALL	SELECT 'author', 'publish_pages'
UNION ALL	SELECT 'editor', 'publish_pages'
UNION ALL	SELECT 'administrator', 'publish_posts'
UNION ALL	SELECT 'author', 'publish_posts'
UNION ALL	SELECT 'editor', 'publish_posts'
UNION ALL	SELECT 'administrator', 'set_plugins'
UNION ALL	SELECT 'administrator', 'set_themes'
UNION ALL	SELECT 'editor', 'set_themes'
UNION ALL	SELECT 'administrator', 'manage_pods'
UNION ALL	SELECT 'administrator', 'manage_system'
UNION ALL	SELECT 'administrator', 'set_profile'
UNION ALL	SELECT 'author', 'set_profile'
UNION ALL	SELECT 'editor', 'set_profile'
UNION ALL	SELECT 'administrator', 'manage_comments'
UNION ALL	SELECT 'author', 'manage_comments'
UNION ALL	SELECT 'editor', 'manage_comments'

CREATE TABLE #prefix#blog (
	id varchar (50) NOT NULL ,
	title nvarchar (150) NULL ,
	description nvarchar(max) NULL ,
	tagline nvarchar (150) NULL ,
	skin varchar (100) NULL ,
	url varchar (255) NULL ,
	charset varchar (50) NULL ,
    locale varchar (10) NULL ,
	basePath varchar (255) NULL,
	plugins nvarchar(max),
  	systemplugins nvarchar(max)
)

CREATE TABLE #prefix#author_blog (
	author_id varchar (35) NOT NULL ,
  blog_id varchar (50) NOT NULL,
role varchar(20) NULL
)

CREATE TABLE #prefix#setting (
  path nvarchar(255) NOT NULL default '',
  name nvarchar(100) NOT NULL default '',
  [value] nvarchar(max),
  blog_id varchar(50) default '',
    [type] varchar( 10 ) default 'string'
)

CREATE  INDEX IX_#prefix#setting_path ON #prefix#setting(path)
CREATE  INDEX IX_#prefix#setting_blog ON #prefix#setting(blog_id)


CREATE TABLE #prefix#login_key (
    id varchar(35) NOT NULL DEFAULT '',
    user_id varchar(35) DEFAULT NULL,
    user_type varchar(10) DEFAULT NULL,
    last_visit_on datetime DEFAULT NULL,
    PRIMARY KEY (id)
    )


CREATE TABLE #prefix#login_password_reset (
    id varchar(40) NOT NULL DEFAULT '',
    user_id varchar(40) DEFAULT NULL,
    valid tinyint DEFAULT NULL,
    created_on datetime DEFAULT NULL,
    PRIMARY KEY (id)


CREATE TABLE #prefix#category (
	id varchar (35) NOT NULL ,
	name nvarchar (150) NULL ,
	title varchar (150) NULL ,
	description nvarchar(max) NULL ,
	created_on datetime NULL ,
	parent_category_id varchar (35) NULL ,
	blog_id varchar (50) NULL 
) 

CREATE TABLE #prefix#entry (
	id varchar (35) NOT NULL ,
	name nvarchar (200) NULL ,
	title nvarchar (200) NULL ,
	content nvarchar(max) NULL ,
	excerpt nvarchar(max) NULL ,
	author_id varchar (35) NULL ,
	comments_allowed bit NULL ,
	status varchar (50) NULL ,
	last_modified smalldatetime NULL ,
	blog_id varchar (50) NULL 
) 

CREATE TABLE #prefix#comment (
  id varchar (35) NOT NULL ,
	entry_id varchar (35) NULL ,
	content nvarchar(max) NULL ,
	creator_name nvarchar (50) NULL ,
	creator_email nvarchar (100) NULL ,
	creator_url nvarchar (255) NULL ,
	created_on smalldatetime NULL ,
	approved bit NULL ,
	author_id varchar (35) NULL ,
	parent_comment_id varchar (35) NULL ,
	rating float NULL 
) 

CREATE TABLE #prefix#entry_custom_field (
	id varchar (255)  NOT NULL ,
	entry_id varchar (35)  NOT NULL ,
	name nvarchar (255)  NULL ,
	field_value nvarchar(max)  NULL 
) 

CREATE TABLE #prefix#entry_subscription (
	entry_id varchar (35) NOT NULL ,
	email nvarchar (100) NOT NULL ,
	name nvarchar (50) NULL ,
	type varchar (20) NOT NULL ,
	mode varchar (20) NULL 
) 

CREATE TABLE #prefix#media (
	id varchar (35) NOT NULL ,
	entry_id varchar (35) NULL ,
	url varchar (255) NULL ,
	fileSize int NULL ,
	type varchar (50) NULL ,
	medium varchar (50) NULL ,
	isDefault bit NULL ,
	duration int NULL ,
	height int NULL ,
	width int NULL ,
	lang varchar (50) NULL ,
	rating varchar (50) NULL ,
	rating_scheme varchar (10) NULL ,
	title nvarchar (100) NULL ,
	description nvarchar (1000) NULL ,
	thumbnail varchar (255) NULL ,
	media_group varchar (35) NULL ,
	copyright varchar (50) NULL 
);

CREATE TABLE #prefix#page (
	id varchar (35)  NOT NULL ,
	template varchar (100)  NULL ,
	parent_page_id varchar (35)  NULL ,
	hierarchy  nvarchar(max)  NULL ,
	sort_order int NULL 
);

CREATE TABLE #prefix#post (
	id varchar (35)  NOT NULL ,
	posted_on datetime NOT NULL 
);

CREATE TABLE #prefix#post_category (
	post_id varchar (35)  NOT NULL ,
	category_id varchar (35) NOT NULL 
);

CREATE TABLE #prefix#entry_revision (
  id varchar(35) NOT NULL,
  entry_id varchar(35) default NULL,
  name nvarchar (200) NULL ,
  title nvarchar (200) NULL ,
  content nvarchar(max),
  excerpt nvarchar(max),
  author_id varchar(35) default NULL,
  last_modified smalldatetime default NULL,
  entry_type varchar(10) default NULL,
  CONSTRAINT PK_#prefix#entry_revision PRIMARY KEY(id)
);

CREATE  INDEX IX_#prefix#entry_revision ON #prefix#entry_revision(entry_id);



CREATE TABLE  #prefix#link (
  id varchar(35) NOT NULL,
  title nvarchar(100) default NULL,
  description nvarchar(1000) default NULL,
  address varchar(255) default NULL,
  category_id varchar(35) default NULL,
  showOrder int default '0'
) 

ALTER TABLE #prefix#link WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#link PRIMARY KEY  CLUSTERED 
	( id
	) 

CREATE TABLE  #prefix#link_category (
  id varchar(35) NOT NULL,
  name nvarchar(50) default NULL,
  description nvarchar(1000) default NULL,
  parent_category_id varchar(35) default NULL,
  blog_id varchar(50) default NULL
)

ALTER TABLE #prefix#link_category WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#link_category PRIMARY KEY  CLUSTERED 
	( id
	)
	
CREATE TABLE #prefix#log (
  level varchar(20) default NULL,
  category varchar(30) default NULL,
  message nvarchar(max) default NULL,
  logged_on datetime default NULL,
  blog_id varchar(50) default NULL,
  owner nvarchar(255) default NULL
)

ALTER TABLE #prefix#author WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#author PRIMARY KEY  CLUSTERED 
	( id
	) 


ALTER TABLE #prefix#blog WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#blog PRIMARY KEY  CLUSTERED 
	(
		id
	)   
	
ALTER TABLE #prefix#author_blog WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#author_blog PRIMARY KEY  CLUSTERED 
	(
		author_id,
		blog_id
	)	

ALTER TABLE #prefix#category WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#category PRIMARY KEY  CLUSTERED 
	(
		id
	)   

ALTER TABLE #prefix#entry WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#entry PRIMARY KEY  CLUSTERED 
	(
		id
	) 

ALTER TABLE #prefix#comment WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#comment PRIMARY KEY  CLUSTERED 
	(
		id
	) 

ALTER TABLE #prefix#entry_custom_field WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#entry_custom_field PRIMARY KEY  CLUSTERED 
	(
		id,
		entry_id
	) 

ALTER TABLE #prefix#entry_subscription WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#subscription PRIMARY KEY  CLUSTERED 
	(
		entry_id,
		email,
		type
	) 

ALTER TABLE #prefix#media WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#media PRIMARY KEY  CLUSTERED 
	(
		id
	)

ALTER TABLE #prefix#page WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#page PRIMARY KEY  CLUSTERED 
	(
		id
	) 


ALTER TABLE #prefix#post WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#post PRIMARY KEY  CLUSTERED 
	(
		id
	) 

ALTER TABLE #prefix#trackback WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#trackback PRIMARY KEY  CLUSTERED 
	(
		id
	) 

ALTER TABLE #prefix#post_category WITH NOCHECK ADD 
	CONSTRAINT PK_#prefix#post_category PRIMARY KEY  CLUSTERED 
	(
		post_id,
		category_id
	) WITH  FILLFACTOR = 90   


ALTER TABLE #prefix#author WITH NOCHECK ADD 
	CONSTRAINT IX_#prefix#author UNIQUE  NONCLUSTERED 
	(		username	) 

ALTER TABLE #prefix#entry WITH NOCHECK ADD 
	CONSTRAINT DF_#prefix#entry_comments_allowed DEFAULT (1) FOR comments_allowed,
	CONSTRAINT DF_#prefix#entry_last_modified DEFAULT (getdate()) FOR last_modified

ALTER TABLE #prefix#comment WITH NOCHECK ADD 
	CONSTRAINT DF_#prefix#comment_created_on DEFAULT (getdate()) FOR created_on

ALTER TABLE #prefix#entry_subscription WITH NOCHECK ADD 
	CONSTRAINT DF_#prefix#subscription_mode DEFAULT ('instant') FOR mode

ALTER TABLE #prefix#page WITH NOCHECK ADD 
	CONSTRAINT DF_#prefix#page_sort_order DEFAULT (1) FOR sort_order

ALTER TABLE #prefix#post WITH NOCHECK ADD 
	CONSTRAINT DF_#prefix#post_posted_on DEFAULT (getdate()) FOR posted_on

 CREATE  INDEX IX_#prefix#author_1 ON #prefix#author(alias)

 CREATE  INDEX IX_#prefix#category ON #prefix#category(blog_id) 

 CREATE  INDEX IX_#prefix#entry ON #prefix#entry(name)

 CREATE  INDEX IX_#prefix#comment ON #prefix#comment(entry_id) 

 CREATE  INDEX IX_#prefix#media ON #prefix#media(entry_id)
  

ALTER TABLE #prefix#author_blog ADD 
	CONSTRAINT FK_#prefix#author_blog_author FOREIGN KEY 
  	(
		author_id
	) REFERENCES #prefix#author (
		id
	) ON DELETE CASCADE  ON UPDATE CASCADE ,
	CONSTRAINT FK_#prefix#author_blog_blog FOREIGN KEY 
	(
		blog_id
	) REFERENCES #prefix#blog (
		id
	) ON DELETE CASCADE  ON UPDATE CASCADE 

ALTER TABLE #prefix#category ADD 
	CONSTRAINT FK_#prefix#category_blog FOREIGN KEY 
	(
		blog_id
	) REFERENCES #prefix#blog (
		id
	)

ALTER TABLE #prefix#entry ADD 
	CONSTRAINT FK_#prefix#entry_author FOREIGN KEY 
	(
		author_id
	) REFERENCES #prefix#author (
		id
	) ON DELETE CASCADE  ON UPDATE CASCADE ,
	CONSTRAINT FK_#prefix#entry_blog FOREIGN KEY 
	(
		blog_id
	) REFERENCES #prefix#blog (
		id
	) ON DELETE CASCADE  ON UPDATE CASCADE 

ALTER TABLE #prefix#comment ADD 
	CONSTRAINT FK_#prefix#comment_author FOREIGN KEY 
	(
		author_id
	) REFERENCES #prefix#author (
		id
	),
	CONSTRAINT FK_#prefix#comment_comment FOREIGN KEY 
	(
		parent_comment_id
	) REFERENCES #prefix#comment (
		id
	),
	CONSTRAINT FK_#prefix#comment_entry FOREIGN KEY 
	(
		entry_id
	) REFERENCES #prefix#entry (
		id
	) ON DELETE CASCADE  ON UPDATE CASCADE 


alter table #prefix#comment nocheck constraint FK_#prefix#comment_author

alter table #prefix#comment nocheck constraint FK_#prefix#comment_comment

ALTER TABLE #prefix#entry_custom_field ADD 
	CONSTRAINT FK_#prefix#entry_custom_field_entry FOREIGN KEY 
	(
		entry_id
	) REFERENCES #prefix#entry (
		id
	) ON DELETE CASCADE  ON UPDATE CASCADE 

ALTER TABLE #prefix#entry_subscription ADD 
	CONSTRAINT FK_#prefix#subscription_entry FOREIGN KEY 
	(
		entry_id
	) REFERENCES #prefix#entry (
		id
	) ON DELETE CASCADE  ON UPDATE CASCADE 

ALTER TABLE #prefix#media ADD 
	CONSTRAINT FK_#prefix#media_entry FOREIGN KEY 
	(
		entry_id
	) REFERENCES #prefix#entry (
		id
	) ON DELETE CASCADE  ON UPDATE CASCADE 

ALTER TABLE #prefix#page ADD 
	CONSTRAINT FK_#prefix#page_entry FOREIGN KEY 
	(
		id
	) REFERENCES #prefix#entry (
		id
	) ON DELETE CASCADE  ON UPDATE CASCADE


ALTER TABLE #prefix#post ADD 
	CONSTRAINT FK_#prefix#post_entry FOREIGN KEY 
	(
		id
	) REFERENCES #prefix#entry (
		id
	) ON DELETE CASCADE  ON UPDATE CASCADE

ALTER TABLE #prefix#trackback ADD 
	CONSTRAINT FK_#prefix#trackback_entry FOREIGN KEY 
	(
		entry_id
	) REFERENCES #prefix#entry (
		id
	) ON DELETE CASCADE  ON UPDATE CASCADE

ALTER TABLE #prefix#post_category ADD 
	CONSTRAINT FK_#prefix#post_category_category FOREIGN KEY 
	(
		category_id
	) REFERENCES #prefix#category 
	(
		id
	) ,
	CONSTRAINT FK_#prefix#post_category_post FOREIGN KEY 
	(
		post_id
	) REFERENCES #prefix#post 
	(
		id
	) ON DELETE CASCADE ON UPDATE CASCADE 

INSERT INTO #prefix#setting(path, name, value, blog_id)
			SELECT 'system/assets', 'directory', '{baseDirectory}assets/content/', NULL
UNION ALL	SELECT 'system/assets', 'path', 'assets/content/', NULL
UNION ALL	SELECT 'system/mail', 'server','',NULL
UNION ALL	SELECT 'system/mail', 'username','',NULL
UNION ALL	SELECT 'system/mail', 'password','',NULL
UNION ALL	SELECT 'system/urls', 'searchUrl','archives.cfm',NULL
UNION ALL	SELECT 'system/urls', 'postUrl','post.cfm?entry={postName}',NULL
UNION ALL	SELECT 'system/urls', 'authorUrl','author.cfm/{authorAlias}',NULL
UNION ALL	SELECT 'system/urls', 'categoryUrl','archives.cfm/category/{categoryName}',NULL
UNION ALL	SELECT 'system/urls', 'archivesUrl','archives.cfm/',NULL
UNION ALL	SELECT 'system/urls', 'pageUrl','page.cfm?entry={pageHierarchyNames}{pageName}',NULL
UNION ALL	SELECT 'system/urls', 'atomUrl','feeds/atom.cfm',NULL
UNION ALL	SELECT 'system/urls', 'rssUrl','feeds/rss.cfm',NULL
UNION ALL	SELECT 'system/urls', 'apiUrl','api',NULL
UNION ALL	SELECT 'system/urls', 'useFriendlyUrls','1',NULL
UNION ALL 	SELECT 'system/urls', 'admin','',NULL
UNION ALL	SELECT 'system/engine/logging', 'level','warning',NULL
UNION ALL	SELECT 'system/engine', 'enableThreads','0',NULL
UNION ALL	SELECT 'system/skins', 'directory','{baseDirectory}skins/',NULL
UNION ALL	SELECT 'system/authorization', 'methods','native',NULL
UNION ALL	SELECT 'system/search', 'component','search.DatabaseSimple',NULL
UNION ALL	SELECT 'system/plugins', 'directory','{componentsDirectory}plugins/',NULL
UNION ALL	SELECT 'system/plugins', 'path','plugins.',NULL
UNION ALL	SELECT 'system/skins', 'path','',NULL
UNION ALL	SELECT 'system/skins', 'url','',NULL
UNION ALL 	SELECT 'system/admin/htmleditor', 'editor','tinymce','default'
UNION ALL 	SELECT 'system/admin/pages/fields', 'customfields','0','default'
UNION ALL 	SELECT 'system/admin/pages/fields', 'name','0','default'
UNION ALL 	SELECT 'system/admin/posts/fields', 'customfields','0','default'
UNION ALL 	SELECT 'system/admin/posts/fields', 'name','0','default'
</cfquery>