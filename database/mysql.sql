-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.0.45-community-nt


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

--
-- Definition of table `author`
--

DROP TABLE IF EXISTS `author`;
CREATE TABLE `author` (
  `id` varchar(35) NOT NULL default '',
  `username` varchar(50) NOT NULL default '',
  `password` varchar(50) NOT NULL default '',
  `name` varchar(100) NOT NULL default '',
  `email` varchar(255) NOT NULL default '',
  `description` text,
  `shortdescription` text,
  `picture` varchar(100) NOT NULL default '',
  `alias` varchar(100) NOT NULL default '',
  `active` tinyint(1) default '1',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `IX_author` (`username`),
  KEY `IX_author_1` (`alias`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `author`
--

/*!40000 ALTER TABLE `author` DISABLE KEYS */;
/*!40000 ALTER TABLE `author` ENABLE KEYS */;


--
-- Definition of table `author_blog`
--

DROP TABLE IF EXISTS `author_blog`;
CREATE TABLE `author_blog` (
  `author_id` varchar(35) NOT NULL default '',
  `blog_id` varchar(50) NOT NULL default '',
  `role` varchar(20) default NULL,
  PRIMARY KEY  (`author_id`,`blog_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `author_blog`
--

/*!40000 ALTER TABLE `author_blog` DISABLE KEYS */;
/*!40000 ALTER TABLE `author_blog` ENABLE KEYS */;


--
-- Definition of table `blog`
--

DROP TABLE IF EXISTS `blog`;
CREATE TABLE `blog` (
  `id` varchar(50) NOT NULL default '',
  `title` varchar(150) default NULL,
  `description` text,
  `tagline` varchar(150) default NULL,
  `skin` varchar(100) default NULL,
  `url` varchar(255) default NULL,
  `charset` varchar(50) default NULL,
  `basepath` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `blog`
--

/*!40000 ALTER TABLE `blog` DISABLE KEYS */;
/*!40000 ALTER TABLE `blog` ENABLE KEYS */;


--
-- Definition of table `category`
--

DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id` varchar(35) NOT NULL default '',
  `name` varchar(150) default NULL,
  `title` varchar(150) default NULL,
  `description` varchar(150) default NULL,
  `created_on` datetime default NULL,
  `parent_category_id` varchar(35) default NULL,
  `blog_id` varchar(50) default NULL,
  PRIMARY KEY  (`id`),
  KEY `IX_category` (`blog_id`),
  CONSTRAINT `FK_category_blog` FOREIGN KEY (`blog_id`) REFERENCES `blog` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `category`
--

/*!40000 ALTER TABLE `category` DISABLE KEYS */;
/*!40000 ALTER TABLE `category` ENABLE KEYS */;


--
-- Definition of table `comment`
--

DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment` (
  `id` varchar(35) NOT NULL default '',
  `entry_id` varchar(35) default NULL,
  `content` text,
  `creator_name` varchar(50) default NULL,
  `creator_email` varchar(100) default NULL,
  `creator_url` varchar(255) default NULL,
  `created_on` datetime default NULL,
  `approved` tinyint(1) default NULL,
  `author_id` varchar(35) default NULL,
  `parent_comment_id` varchar(35) default NULL,
  `rating` float default NULL,
  PRIMARY KEY  (`id`),
  KEY `IX_comment` (`entry_id`),
  KEY `FK_comment_author` (`author_id`),
  KEY `FK_comment_comment` (`parent_comment_id`),
  CONSTRAINT `FK_comment_author` FOREIGN KEY (`author_id`) REFERENCES `author` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_comment_comment` FOREIGN KEY (`parent_comment_id`) REFERENCES `comment` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_comment_entry` FOREIGN KEY (`entry_id`) REFERENCES `entry` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `comment`
--

/*!40000 ALTER TABLE `comment` DISABLE KEYS */;
/*!40000 ALTER TABLE `comment` ENABLE KEYS */;


--
-- Definition of table `entry`
--

DROP TABLE IF EXISTS `entry`;
CREATE TABLE `entry` (
  `id` varchar(35) NOT NULL default '',
  `name` varchar(200) NOT NULL default '',
  `title` varchar(200) NOT NULL default '',
  `content` longtext,
  `excerpt` text,
  `author_id` varchar(35) default NULL,
  `comments_allowed` tinyint(1) NOT NULL default '1',
  `trackbacks_allowed` tinyint(1) default NULL,
  `status` varchar(50) default NULL,
  `last_modified` datetime default NULL,
  `blog_id` varchar(50) default NULL,
  PRIMARY KEY  (`id`),
  KEY `IX_entry` (`name`),
  KEY `FK_entry_author` (`author_id`),
  KEY `FK_entry_blog` (`blog_id`),
  CONSTRAINT `FK_entry_author` FOREIGN KEY (`author_id`) REFERENCES `author` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_entry_blog` FOREIGN KEY (`blog_id`) REFERENCES `blog` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `entry`
--

/*!40000 ALTER TABLE `entry` DISABLE KEYS */;
/*!40000 ALTER TABLE `entry` ENABLE KEYS */;


--
-- Definition of table `entry_custom_field`
--

DROP TABLE IF EXISTS `entry_custom_field`;
CREATE TABLE `entry_custom_field` (
  `id` varchar(255) NOT NULL default '',
  `entry_id` varchar(35) NOT NULL default '',
  `name` varchar(255) default NULL,
  `field_value` text,
  PRIMARY KEY  (`id`,`entry_id`),
  KEY `FK_entry_custom_field_entry` (`entry_id`),
  CONSTRAINT `FK_entry_custom_field_entry` FOREIGN KEY (`entry_id`) REFERENCES `entry` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `entry_custom_field`
--

/*!40000 ALTER TABLE `entry_custom_field` DISABLE KEYS */;
/*!40000 ALTER TABLE `entry_custom_field` ENABLE KEYS */;


--
-- Definition of table `entry_subscription`
--

DROP TABLE IF EXISTS `entry_subscription`;
CREATE TABLE `entry_subscription` (
  `entry_id` varchar(35) NOT NULL default '',
  `email` varchar(100) NOT NULL default '',
  `name` varchar(50) default NULL,
  `type` varchar(20) NOT NULL default '',
  `mode` varchar(20) NOT NULL default 'instant',
  PRIMARY KEY  (`entry_id`,`email`,`type`),
  CONSTRAINT `FK_subscription_entry` FOREIGN KEY (`entry_id`) REFERENCES `entry` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `entry_subscription`
--

/*!40000 ALTER TABLE `entry_subscription` DISABLE KEYS */;
/*!40000 ALTER TABLE `entry_subscription` ENABLE KEYS */;


--
-- Definition of table `link`
--

DROP TABLE IF EXISTS `link`;
CREATE TABLE `link` (
  `id` varchar(35) NOT NULL,
  `title` varchar(100) default NULL,
  `description` varchar(1000) default NULL,
  `address` varchar(255) default NULL,
  `category_id` varchar(35) default NULL,
  `showOrder` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `link`
--

/*!40000 ALTER TABLE `link` DISABLE KEYS */;
/*!40000 ALTER TABLE `link` ENABLE KEYS */;


--
-- Definition of table `link_category`
--

DROP TABLE IF EXISTS `link_category`;
CREATE TABLE `link_category` (
  `id` varchar(35) NOT NULL,
  `name` varchar(50) default NULL,
  `description` varchar(1000) default NULL,
  `parent_category_id` varchar(35) default NULL,
  `blog_id` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `link_category`
--

/*!40000 ALTER TABLE `link_category` DISABLE KEYS */;
/*!40000 ALTER TABLE `link_category` ENABLE KEYS */;


--
-- Definition of table `media`
--

DROP TABLE IF EXISTS `media`;
CREATE TABLE `media` (
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
  `description` text,
  `thumbnail` varchar(255) default NULL,
  `media_group` varchar(35) default NULL,
  `copyright` varchar(50) default NULL,
  PRIMARY KEY  (`id`),
  KEY `IX_media` (`entry_id`),
  CONSTRAINT `FK_media_entry` FOREIGN KEY (`entry_id`) REFERENCES `entry` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `media`
--

/*!40000 ALTER TABLE `media` DISABLE KEYS */;
/*!40000 ALTER TABLE `media` ENABLE KEYS */;


--
-- Definition of table `page`
--

DROP TABLE IF EXISTS `page`;
CREATE TABLE `page` (
  `id` varchar(35) NOT NULL default '0',
  `template` varchar(100) default NULL,
  `parent_page_id` varchar(35) default NULL,
  `hierarchy` text,
  `sort_order` int(10) unsigned NOT NULL default '1',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `page`
--

/*!40000 ALTER TABLE `page` DISABLE KEYS */;
/*!40000 ALTER TABLE `page` ENABLE KEYS */;


--
-- Definition of table `permission`
--

DROP TABLE IF EXISTS `permission`;
CREATE TABLE `permission` (
  `id` varchar(20) NOT NULL,
  `name` varchar(50) default NULL,
  `description` varchar(255) default NULL,
  `is_custom` tinyint(1) default '1',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `permission`
--

/*!40000 ALTER TABLE `permission` DISABLE KEYS */;
INSERT INTO `permission` (`id`,`name`,`description`,`is_custom`) VALUES 
 ('manage_all_pages','Manage pages','Add, edit and remove any page',0),
 ('manage_all_posts','Manage all posts','Edit and remove other author\'s posts',0),
 ('manage_categories','Manage categories','Add, edit and delete categories',0),
 ('manage_files','Manage files','Upload, rename and delete files',0),
 ('manage_links','Manage links','Add, edit and remove links',0),
 ('manage_pages','Manage own pages','Add, edit, and remove pages created by the user',0),
 ('manage_plugins','Manage plugins','Install and remove plugins',0),
 ('manage_plugin_prefs','Manage plugin custom settings','Change settings specified by plugins',0),
 ('manage_posts','Manage own posts','Create and edit own posts',0),
 ('manage_settings','Manage blog settings','Change blog main settings',0),
 ('manage_themes','Manage themes','Download and remove themes',0),
 ('manage_users','Manage users','Add and edit users and permissions',0),
 ('plublish_pages','Publish pages','If not enabled, user can only create drafts or \"to review\" pages',0),
 ('publish_posts','Publish posts','If not enabled, user can only create drafts or \"to review\" posts',0),
 ('set_plugins','Manage installed plugins','Activate and de-activate plugins',0),
 ('set_themes','Switch themes','Change the blog theme',0);
/*!40000 ALTER TABLE `permission` ENABLE KEYS */;


--
-- Definition of table `post`
--

DROP TABLE IF EXISTS `post`;
CREATE TABLE `post` (
  `id` varchar(35) NOT NULL default '0',
  `posted_on` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `post`
--

/*!40000 ALTER TABLE `post` DISABLE KEYS */;
/*!40000 ALTER TABLE `post` ENABLE KEYS */;


--
-- Definition of table `post_category`
--

DROP TABLE IF EXISTS `post_category`;
CREATE TABLE `post_category` (
  `post_id` char(35) NOT NULL default '0',
  `category_id` char(35) NOT NULL default '0',
  PRIMARY KEY  (`post_id`,`category_id`),
  KEY `FK_post_category_category` (`category_id`),
  CONSTRAINT `FK_post_category_post` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `post_category`
--

/*!40000 ALTER TABLE `post_category` DISABLE KEYS */;
/*!40000 ALTER TABLE `post_category` ENABLE KEYS */;


--
-- Definition of table `role`
--

DROP TABLE IF EXISTS `role`;
CREATE TABLE `role` (
  `id` varchar(20) NOT NULL,
  `name` varchar(50) default NULL,
  `description` varchar(255) default NULL,
  `preferences` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `role`
--

/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` (`id`,`name`,`description`,`preferences`) VALUES 
 ('administrator','Administrator','Somebody who has access to all the administration features.',''),
 ('author','Author','Somebody who can publish and manage their own posts and pages.',''),
 ('editor','Editor','Somebody who can publish posts, manage posts as well as manage other people\'s posts.','');
/*!40000 ALTER TABLE `role` ENABLE KEYS */;


--
-- Definition of table `role_permission`
--

DROP TABLE IF EXISTS `role_permission`;
CREATE TABLE `role_permission` (
  `role_id` varchar(20) NOT NULL,
  `permission_id` varchar(20) NOT NULL,
  PRIMARY KEY  (`permission_id`,`role_id`),
  KEY `FK_role_permission_role` (`role_id`),
  CONSTRAINT `FK_role_permission_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_role_permission_permission` FOREIGN KEY (`permission_id`) REFERENCES `permission` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `role_permission`
--

/*!40000 ALTER TABLE `role_permission` DISABLE KEYS */;
INSERT INTO `role_permission` (`role_id`,`permission_id`) VALUES 
 ('administrator','manage_all_pages'),
 ('administrator','manage_all_posts'),
 ('administrator','manage_categories'),
 ('administrator','manage_files'),
 ('administrator','manage_links'),
 ('administrator','manage_pages'),
 ('administrator','manage_plugins'),
 ('administrator','manage_plugin_prefs'),
 ('administrator','manage_posts'),
 ('administrator','manage_settings'),
 ('administrator','manage_themes'),
 ('administrator','manage_users'),
 ('administrator','plublish_pages'),
 ('administrator','publish_posts'),
 ('administrator','set_plugins'),
 ('administrator','set_themes'),
 ('author','manage_all_pages'),
 ('author','manage_categories'),
 ('author','manage_files'),
 ('author','manage_pages'),
 ('author','manage_posts'),
 ('author','plublish_pages'),
 ('author','publish_posts'),
 ('editor','manage_all_pages'),
 ('editor','manage_all_posts'),
 ('editor','manage_categories'),
 ('editor','manage_files'),
 ('editor','manage_links'),
 ('editor','manage_pages'),
 ('editor','manage_plugin_prefs'),
 ('editor','manage_posts'),
 ('editor','plublish_pages'),
 ('editor','publish_posts'),
 ('editor','set_themes');
/*!40000 ALTER TABLE `role_permission` ENABLE KEYS */;


--
-- Definition of table `trackback`
--

DROP TABLE IF EXISTS `trackback`;
CREATE TABLE `trackback` (
  `id` varchar(35) NOT NULL default '',
  `entry_id` varchar(35) default NULL,
  `content` text,
  `title` varchar(200) default NULL,
  `creator_url` varchar(255) default NULL,
  `creator_url_title` varchar(50) default NULL,
  `created_on` datetime default NULL,
  `approved` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_trackback_entry` (`entry_id`),
  CONSTRAINT `FK_trackback_entry` FOREIGN KEY (`entry_id`) REFERENCES `entry` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `trackback`
--

/*!40000 ALTER TABLE `trackback` DISABLE KEYS */;
/*!40000 ALTER TABLE `trackback` ENABLE KEYS */;




/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
