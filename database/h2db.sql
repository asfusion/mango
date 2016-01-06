CREATE TABLE public.author (
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
);

CREATE TABLE public.permission (
	id         	varchar(20) NOT NULL,
    name       	varchar(50) NULL,
    description	varchar(255) NULL,
    is_custom  	bit NULL DEFAULT (1),
    CONSTRAINT public.PK_permission PRIMARY KEY(id)
);

INSERT INTO public.permission(id, name, description, is_custom)
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
UNION ALL	SELECT 'manage_comments', 'Manage comments', 'Edit and delete comments', 0;

CREATE TABLE public.role ( 
	id  	varchar(20) NOT NULL,
	name	varchar(50) NULL,
	description varchar(255) default NULL,
	preferences nvarchar(max) default NULL,
	CONSTRAINT public.PK_role PRIMARY KEY(id)
);

INSERT INTO public.role (id, name, description, preferences)
  VALUES('administrator', 'Administrator', 'Somebody who has access to all the administration features.', '');
INSERT INTO public.role (id, name, description, preferences)
  VALUES('author', 'Author', 'Somebody who can publish and manage their own posts and pages.', '');
INSERT INTO public.role (id, name, description, preferences)
  VALUES('editor', 'Editor', 'Somebody who can publish posts, manage posts as well as manage other people''s posts.', '');

  
CREATE TABLE public.role_permission ( 
    role_id      	varchar(20) NOT NULL,
    permission_id	varchar(20) NOT NULL,
    CONSTRAINT public.PK_role_permission PRIMARY KEY(permission_id,role_id)
);

ALTER TABLE public.role_permission
    ADD CONSTRAINT public.FK_role_permission_role
	FOREIGN KEY(role_id)
	REFERENCES public.role(id)
	ON DELETE CASCADE  ON UPDATE CASCADE;

ALTER TABLE public.role_permission
    ADD CONSTRAINT public.FK_role_permission_permission
	FOREIGN KEY(permission_id)
	REFERENCES public.permission(id)
	ON DELETE CASCADE  ON UPDATE CASCADE;


INSERT INTO public.role_permission(role_id, permission_id)
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
UNION ALL	SELECT 'editor', 'manage_comments';

CREATE TABLE public.blog (
	id varchar (50) NOT NULL ,
	title nvarchar (150) NULL ,
	description nvarchar(max) NULL ,
	tagline nvarchar (150) NULL ,
	skin varchar (100) NULL ,
	url varchar (255) NULL ,
	charset varchar (50) NULL ,
	basePath varchar (255) NULL,
	plugins nvarchar(max),
  	systemplugins nvarchar(max)
);

CREATE TABLE public.author_blog (
	author_id varchar (35) NOT NULL ,
  blog_id varchar (50) NOT NULL,
role varchar(20) NULL
);

CREATE TABLE public.setting (
  path nvarchar(255) NOT NULL default '',
  name nvarchar(100) NOT NULL default '',
  value nvarchar(max),
  blog_id varchar(50) default ''
);

CREATE  INDEX public.IX_setting_path ON public.setting(path);
CREATE  INDEX public.IX_setting_blog ON public.setting(blog_id);

CREATE TABLE public.category (
	id varchar (35) NOT NULL ,
	name nvarchar (150) NULL ,
	title varchar (150) NULL ,
	description nvarchar(max) NULL ,
	created_on datetime NULL ,
	parent_category_id varchar (35) NULL ,
	blog_id varchar (50) NULL 
);

CREATE TABLE public.entry (
	id varchar (35) NOT NULL ,
	name nvarchar (200) NULL ,
	title nvarchar (200) NULL ,
	content nvarchar(max) NULL ,
	excerpt nvarchar(max) NULL ,
	author_id varchar (35) NULL ,
	comments_allowed bit NULL ,
	trackbacks_allowed bit NULL ,
	status varchar (50) NULL ,
	last_modified smalldatetime NULL ,
	blog_id varchar (50) NULL 
);

CREATE TABLE public.comment (
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
);

CREATE TABLE public.entry_custom_field (
	id varchar (255)  NOT NULL ,
	entry_id varchar (35)  NOT NULL ,
	name nvarchar (255)  NULL ,
	field_value nvarchar(max)  NULL 
);

CREATE TABLE public.entry_subscription (
	entry_id varchar (35) NOT NULL ,
	email nvarchar (100) NOT NULL ,
	name nvarchar (50) NULL ,
	type varchar (20) NOT NULL ,
	mode varchar (20) NULL 
);

CREATE TABLE public.media (
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

CREATE TABLE public.page (
	id varchar (35)  NOT NULL ,
	template varchar (100)  NULL ,
	parent_page_id varchar (35)  NULL ,
	hierarchy  nvarchar(max)  NULL ,
	sort_order int NULL 
);


CREATE TABLE public.post (
	id varchar (35)  NOT NULL ,
	posted_on datetime NOT NULL 
);

CREATE TABLE public.trackback (
	id varchar (35) NOT NULL ,
	entry_id varchar (35) NULL ,
	content nvarchar(max) NULL ,
	title nvarchar (200) NULL ,
	creator_url nvarchar (255) NULL ,
  creator_url_title nvarchar (50) NULL ,
	created_on smalldatetime NULL ,
	approved bit NULL 
);

CREATE TABLE public.post_category (
	post_id varchar (35)  NOT NULL ,
	category_id varchar (35) NOT NULL 
);

CREATE TABLE public.entry_revision (
  id varchar(35) NOT NULL,
  entry_id varchar(35) default NULL,
  name nvarchar (200) NULL ,
  title nvarchar (200) NULL ,
  content nvarchar(max),
  excerpt nvarchar(max),
  author_id varchar(35) default NULL,
  last_modified smalldatetime default NULL,
  entry_type varchar(10) default NULL,
  CONSTRAINT public.PK_entry_revision PRIMARY KEY(id)
);

CREATE  INDEX public.IX_entry_revision ON public.entry_revision(entry_id);



CREATE TABLE  public.link (
  id varchar(35) NOT NULL,
  title nvarchar(100) default NULL,
  description nvarchar(1000) default NULL,
  address varchar(255) default NULL,
  category_id varchar(35) default NULL,
  showOrder int default '0'
);

ALTER TABLE public.link ADD CONSTRAINT public.PK_link PRIMARY KEY  ( id );

CREATE TABLE  public.link_category (
  id varchar(35) NOT NULL,
  name nvarchar(50) default NULL,
  description nvarchar(1000) default NULL,
  parent_category_id varchar(35) default NULL,
  blog_id varchar(50) default NULL
);

ALTER TABLE public.link_category ADD CONSTRAINT public.PK_link_category PRIMARY KEY  ( id	);

CREATE TABLE public.log (
  level varchar(20) default NULL,
  category varchar(30) default NULL,
  message nvarchar(max) default NULL,
  logged_on datetime default NULL,
  blog_id varchar(50) default NULL,
  owner nvarchar(255) default NULL
);

ALTER TABLE public.author ADD CONSTRAINT public.PK_author PRIMARY KEY  ( id );


ALTER TABLE public.blog ADD CONSTRAINT public.PK_blog PRIMARY KEY  (	id );
	
ALTER TABLE public.author_blog ADD CONSTRAINT public.PK_author_blog PRIMARY KEY (	
	author_id,
	blog_id
);


ALTER TABLE public.category ADD CONSTRAINT public.PK_category PRIMARY KEY 
	(
		id
	);

ALTER TABLE public.entry ADD CONSTRAINT public.PK_entry PRIMARY KEY 
	(
		id
	);

ALTER TABLE public.comment ADD CONSTRAINT public.PK_comment PRIMARY KEY 
	(
		id
	);

ALTER TABLE public.entry_custom_field ADD CONSTRAINT public.PK_entry_custom_field PRIMARY KEY 
	(
		id,
		entry_id
	);

ALTER TABLE public.entry_subscription ADD CONSTRAINT public.PK_subscription PRIMARY KEY  
	(
		entry_id,
		email,
		type
	);

ALTER TABLE public.media ADD CONSTRAINT public.PK_media PRIMARY KEY  
	(
		id
	);

ALTER TABLE public.page ADD CONSTRAINT public.PK_page PRIMARY KEY  
	(
		id
	);


ALTER TABLE public.post ADD CONSTRAINT public.PK_post PRIMARY KEY  
	(
		id
	);

ALTER TABLE public.trackback ADD CONSTRAINT public.PK_trackback PRIMARY KEY  
	(
		id
	);

ALTER TABLE public.post_category ADD CONSTRAINT public.PK_post_category PRIMARY KEY 
	(
		post_id,
		category_id
	);


ALTER TABLE public.author ADD CONSTRAINT public.IX_author UNIQUE  NONCLUSTERED 
	( username );

ALTER TABLE public.entry 
  ALTER COLUMN comments_allowed 
    SET DEFAULT 1;

ALTER TABLE public.entry 
  ALTER COLUMN last_modified 
    SET DEFAULT now();


ALTER TABLE public.comment 
  ALTER COLUMN created_on
    SET DEFAULT now();


ALTER TABLE public.entry_subscription 
  ALTER COLUMN mode 
    SET DEFAULT 'instant';


ALTER TABLE public.page 
  ALTER COLUMN sort_order
    SET DEFAULT (1);

	
ALTER TABLE public.post 
  ALTER COLUMN posted_on
    SET DEFAULT now();

 CREATE  INDEX public.IX_author_1 ON public.author(alias);

 CREATE  INDEX public.IX_category ON public.category(blog_id);

 CREATE  INDEX public.IX_entry ON public.entry(name);

 CREATE  INDEX public.IX_comment ON public.comment(entry_id);

 CREATE  INDEX public.IX_media ON public.media(entry_id);
  

	
ALTER TABLE public.author_blog 
  ADD FOREIGN KEY( author_id ) 
    REFERENCES public.author( id ) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE public.author_blog 
  ADD FOREIGN KEY( blog_id ) 
    REFERENCES public.blog( id ) ON DELETE CASCADE ON UPDATE CASCADE;


ALTER TABLE public.category 
  ADD CONSTRAINT public.FK_category_blog 
    FOREIGN KEY ( blog_id ) 
	  REFERENCES public.blog ( id );


ALTER TABLE public.entry 
  ADD CONSTRAINT public.FK_entry_author 
    FOREIGN KEY ( author_id ) 
	  REFERENCES public.author ( id ) ON DELETE CASCADE  ON UPDATE CASCADE;

ALTER TABLE public.entry 
  ADD CONSTRAINT public.FK_entry_blog 
    FOREIGN KEY ( blog_id ) 
	  REFERENCES public.blog ( id ) ON DELETE CASCADE  ON UPDATE CASCADE;


ALTER TABLE public.comment 
  ADD CONSTRAINT public.FK_comment_author 
    FOREIGN KEY ( author_id ) 
      REFERENCES public.author ( id ) ON DELETE CASCADE  ON UPDATE CASCADE;

	
ALTER TABLE public.comment 
  ADD CONSTRAINT public.FK_comment_comment 
    FOREIGN KEY ( parent_comment_id ) 
	  REFERENCES public.comment ( id ) ON DELETE CASCADE  ON UPDATE CASCADE;
	  
	
ALTER TABLE public.comment 
  ADD CONSTRAINT public.FK_comment_entry 
    FOREIGN KEY ( entry_id ) REFERENCES public.entry ( id ) ON DELETE CASCADE  ON UPDATE CASCADE;



ALTER TABLE public.entry_custom_field 
  ADD CONSTRAINT public.FK_entry_custom_field_entry 
    FOREIGN KEY ( entry_id ) REFERENCES public.entry ( id ) ON DELETE CASCADE  ON UPDATE CASCADE;

	
ALTER TABLE public.entry_subscription 
  ADD CONSTRAINT public.FK_subscription_entry 
    FOREIGN KEY ( entry_id ) REFERENCES public.entry ( id ) ON DELETE CASCADE  ON UPDATE CASCADE;

	
	
ALTER TABLE public.media 
  ADD CONSTRAINT public.FK_media_entry 
    FOREIGN KEY ( entry_id ) 
	  REFERENCES public.entry ( id ) 
	    ON DELETE CASCADE  ON UPDATE CASCADE;


ALTER TABLE public.page 
  ADD CONSTRAINT public.FK_page_entry 
    FOREIGN KEY ( id ) 
	  REFERENCES public.entry ( id ) 
	    ON DELETE CASCADE  ON UPDATE CASCADE;


ALTER TABLE public.post 
  ADD CONSTRAINT public.FK_post_entry 
    FOREIGN KEY ( id ) 
	  REFERENCES public.entry ( id ) 
	    ON DELETE CASCADE  ON UPDATE CASCADE;

	
ALTER TABLE public.trackback 
  ADD CONSTRAINT public.FK_trackback_entry 
    FOREIGN KEY ( entry_id ) 
      REFERENCES public.entry ( id ) 
        ON DELETE CASCADE  ON UPDATE CASCADE;

	
ALTER TABLE public.post_category 
  ADD CONSTRAINT public.FK_post_category_category 
    FOREIGN KEY ( category_id ) 
	  REFERENCES public.category ( id )
	     ON DELETE CASCADE ON UPDATE CASCADE;
		 
		 
ALTER TABLE public.post_category 
  ADD CONSTRAINT public.FK_post_category_post 
    FOREIGN KEY ( post_id ) 
	  REFERENCES public.post ( id ) 
	    ON DELETE CASCADE ON UPDATE CASCADE;
		
		

INSERT INTO public.setting(path, name, value, blog_id)
			SELECT 'system/assets', 'directory', '{baseDirectory}assets/content/', NULL
UNION ALL	SELECT 'system/assets', 'path', 'assets/content/', NULL
UNION ALL	SELECT 'system/mail', 'server','',NULL
UNION ALL	SELECT 'system/mail', 'username','',NULL
UNION ALL	SELECT 'system/mail', 'password','',NULL
UNION ALL	SELECT 'system/urls', 'searchUrl','archives.cfm/search/',NULL
UNION ALL	SELECT 'system/urls', 'postUrl','post.cfm/{postName}',NULL
UNION ALL	SELECT 'system/urls', 'authorUrl','author.cfm/{authorAlias}',NULL
UNION ALL	SELECT 'system/urls', 'categoryUrl','archives.cfm/category/{categoryName}',NULL
UNION ALL	SELECT 'system/urls', 'archivesUrl','archives.cfm/',NULL
UNION ALL	SELECT 'system/urls', 'pageUrl','page.cfm/{pageHierarchyNames}{pageName}',NULL
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
UNION ALL	SELECT 'system/skins', 'url','',NULL;
