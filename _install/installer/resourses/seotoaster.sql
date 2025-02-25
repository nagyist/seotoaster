SET NAMES utf8;
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP TABLE IF EXISTS `config`;
CREATE TABLE `config` (
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `value` TEXT COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `config` (`name`, `value`) VALUES
('currentTheme',	'default'),
('imgSmall',	'250'),
('imgMedium',	'350'),
('imgLarge',	'500'),
('useSmtp',	'0'),
('smtpHost',	''),
('smtpLogin',	''),
('smtpPassword',	''),
('language',	'us'),
('teaserSize',	'200'),
('smtpPort',	''),
('memPagesInMenu',	'1'),
('mediaServers',	'0'),
('smtpSsl',	'0'),
('codeEnabled',	'0'),
('inlineEditor',	'1'),
('recaptchaPublicKey',	'6LcaJdASAAAAADyAWIdBYytJMmYPEykb3Otz4pp6'),
('recaptchaPrivateKey',	'6LcaJdASAAAAAH-e1dWpk96PACf3BQG1OGGvh5hK'),
('grecaptchaPublicKey', '6LdZLBQUAAAAAGkmICdj_M7bsgYV68HgUAQzUi1o'),
('grecaptchaPrivateKey', '6LdZLBQUAAAAAPrpbakuqApNJlyonUsVN_bm_Pcx'),
('enableMobileTemplates',	'1'),
('userDefaultTimezone', 'America/New_York'),
('userDefaultPhoneMobileCode', 'US'),
('oldMobileFormat', '1'),
('enableMinifyCss', '0'),
('enableMinifyJs', '0'),
('cropNewFormat', '0'),
('optimizedNotifications', ''),
('wraplinks', '0'),
('takeATour', '1'),
('version',	'3.9.2');


DROP TABLE IF EXISTS `container`;
CREATE TABLE `container` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `container_type` int(10) unsigned NOT NULL,
  `page_id` int(11) unsigned DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `published` enum('0','1') COLLATE utf8_unicode_ci DEFAULT '1',
  `publishing_date` date DEFAULT NULL,
  `content` longtext COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `indPublished` (`published`),
  KEY `indContainerType` (`container_type`),
  KEY `indPageId` (`page_id`),
  CONSTRAINT `container_ibfk_1` FOREIGN KEY (`page_id`) REFERENCES `page` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `deeplink`;
CREATE TABLE `deeplink` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_id` int(10) unsigned DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `type` enum('int','ext') COLLATE utf8_unicode_ci DEFAULT 'int',
  `ban` enum('0','1') COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `nofollow` enum('0','1') COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `indName` (`name`),
  KEY `indType` (`type`),
  KEY `indUrl` (`url`),
  KEY `indDplPageId` (`page_id`),
  CONSTRAINT `deeplink_ibfk_1` FOREIGN KEY (`page_id`) REFERENCES `page` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `email_triggers`;
CREATE TABLE `email_triggers` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `enabled` enum('0','1') COLLATE utf8_unicode_ci NOT NULL,
  `trigger_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `observer` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `trigger_name_2` (`trigger_name`,`observer`),
  KEY `trigger_name` (`trigger_name`),
  KEY `observer` (`observer`),
  KEY `enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `email_triggers` (`id`, `enabled`, `trigger_name`, `observer`) VALUES
(1,	'1',	't_feedbackform',	'Tools_Mail_SystemMailWatchdog'),
(2,	'1',	't_passwordreset',	'Tools_Mail_SystemMailWatchdog'),
(3,	'1',	't_passwordchange',	'Tools_Mail_SystemMailWatchdog'),
(4,	'1',	't_membersignup',	'Tools_Mail_SystemMailWatchdog'),
(5,	'1',	't_systemnotification',	'Tools_Mail_SystemMailWatchdog'),
(6,	'1',	't_userinvitation',	'Tools_Mail_SystemMailWatchdog'),
(7,	'1',	't_mfanotification', 'Tools_Mail_SystemMailWatchdog');

DROP TABLE IF EXISTS `email_triggers_actions`;
CREATE TABLE `email_triggers_actions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `service` enum('email','sms') COLLATE utf8_unicode_ci DEFAULT NULL,
  `trigger` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `template` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `recipient` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `from` tinytext COLLATE utf8_unicode_ci NOT NULL COMMENT 'can be used in the From field of e-mail',
  `subject` tinytext COLLATE utf8_unicode_ci NOT NULL COMMENT 'can be used in the "Subject" field of e-mail',
  `preheader` TEXT COLLATE utf8_unicode_ci COMMENT 'Email preheader text is a small line of text that appears after the subject line in an email inbox.',
  PRIMARY KEY (`id`),
  KEY `trigger` (`trigger`),
  KEY `template` (`template`),
  KEY `recipient` (`recipient`),
  CONSTRAINT `email_triggers_actions_ibfk_1` FOREIGN KEY (`trigger`) REFERENCES `email_triggers` (`trigger_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `email_triggers_actions_ibfk_2` FOREIGN KEY (`recipient`) REFERENCES `email_triggers_recipient` (`recipient`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `email_triggers_actions_ibfk_3` FOREIGN KEY (`template`) REFERENCES `template` (`name`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `email_triggers_recipient`;
CREATE TABLE `email_triggers_recipient` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `recipient` varchar(255) COLLATE utf8_unicode_ci NOT NULL COMMENT 'Recipient Name',
  PRIMARY KEY (`id`),
  KEY `recipient` (`recipient`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `email_triggers_recipient` (`id`, `recipient`) VALUES
(4,	'admin'),
(3,	'copywriter'),
(1,	'guest'),
(2,	'member'),
(5,	'superadmin');

DROP TABLE IF EXISTS `featured_area`;
CREATE TABLE `featured_area` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(164) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `indName` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `form`;
CREATE TABLE `form` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `code` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `contact_email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `message_success` text COLLATE utf8_unicode_ci NOT NULL,
  `message_error` text COLLATE utf8_unicode_ci NOT NULL,
  `reply_subject` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reply_mail_template` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `reply_from` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `reply_from_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reply_text` text COLLATE utf8_unicode_ci,
  `captcha` enum('0','1') COLLATE utf8_unicode_ci DEFAULT '0',
  `mobile` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `enable_sms` enum('0','1') COLLATE utf8_unicode_ci DEFAULT '0',
  `admin_subject` VARCHAR(255) DEFAULT NULL,
  `admin_mail_template` VARCHAR(255) DEFAULT NULL,
  `admin_from` VARCHAR(255) DEFAULT NULL,
  `admin_from_name` VARCHAR (255) DEFAULT NULL,
  `admin_text` TEXT DEFAULT NULL,
  `reply_email` enum('0','1') COLLATE utf8_unicode_ci DEFAULT '0',
  `auto_reply_pdf_template` VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `form_page_conversion`;
CREATE TABLE `form_page_conversion` (
  `page_id` int(10) unsigned NOT NULL,
  `form_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `conversion_code` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`page_id`,`form_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `link_container`;
CREATE TABLE `link_container` (
  `id_container` int(10) unsigned NOT NULL,
  `link` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id_container`,`link`),
  KEY `indContainerId` (`id_container`),
  KEY `indLink` (`link`),
  CONSTRAINT `FK_link_container` FOREIGN KEY (`id_container`) REFERENCES `container` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `observers_queue`;
CREATE TABLE `observers_queue` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `observable` text COLLATE utf8_unicode_ci NOT NULL COMMENT 'Observable Class Name',
  `observer` text COLLATE utf8_unicode_ci NOT NULL COMMENT 'Observer Class Name',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `optimized`;
CREATE TABLE `optimized` (
  `page_id` int(10) unsigned NOT NULL COMMENT 'Foreign key to page table',
  `url` tinytext COLLATE utf8_unicode_ci,
  `h1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `header_title` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `nav_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `targeted_key_phrase` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `meta_description` text COLLATE utf8_unicode_ci,
  `meta_keywords` text COLLATE utf8_unicode_ci,
  `teaser_text` text COLLATE utf8_unicode_ci,
  `seo_intro` text COLLATE utf8_unicode_ci,
  `seo_intro_target` text COLLATE utf8_unicode_ci,
  `status` enum('tweaked','on') COLLATE utf8_unicode_ci DEFAULT NULL,
  `seo_rule_id` int(10) DEFAULT NULL,
  `url_rule_id` int(10) DEFAULT NULL,
  UNIQUE KEY `page_id` (`page_id`),
  KEY `h1` (`h1`),
  KEY `status` (`status`),
  KEY `nav_name` (`nav_name`),
  KEY `url` (`url`(30)),
  CONSTRAINT `optimized_ibfk_1` FOREIGN KEY (`page_id`) REFERENCES `page` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `page`;
CREATE TABLE `page` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `template_id` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `parent_id` int(11) NOT NULL DEFAULT '0',
  `nav_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `meta_description` text COLLATE utf8_unicode_ci,
  `meta_keywords` text COLLATE utf8_unicode_ci,
  `header_title` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `h1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `teaser_text` text COLLATE utf8_unicode_ci,
  `last_update` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_404page` enum('0','1') COLLATE utf8_unicode_ci DEFAULT '0',
  `show_in_menu` enum('0','1','2') COLLATE utf8_unicode_ci DEFAULT '0',
  `order` int(10) unsigned DEFAULT NULL,
  `weight` tinyint(3) unsigned DEFAULT '0',
  `silo_id` int(10) unsigned DEFAULT NULL,
  `targeted_key_phrase` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `protected` enum('0','1') CHARACTER SET utf8 DEFAULT '0',
  `system` enum('0','1') COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `draft` enum('0','1') COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `publish_at` date DEFAULT NULL,
  `news` enum('0','1') COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `err_login_landing` enum('0','1') COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `mem_landing` enum('0','1') COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `signup_landing` enum('0','1') COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `checkout` enum('0','1') COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `preview_image` text COLLATE utf8_unicode_ci COMMENT 'Page Preview Image',
  `external_link_status` enum('0','1') COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `external_link` TEXT COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_type` TINYINT(3) unsigned NOT NULL DEFAULT '1',
  `page_folder` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_folder_index` enum('0','1') COLLATE utf8_unicode_ci DEFAULT '0',
  `exclude_category` enum('0','1') COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `page_target_blank` enum('0','1') COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `not_clickable` enum('0','1') COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `indParentId` (`parent_id`),
  KEY `indUrl` (`url`),
  KEY `indMenu` (`show_in_menu`),
  KEY `indOrder` (`order`),
  KEY `indProtected` (`protected`),
  KEY `draft` (`draft`),
  KEY `news` (`news`),
  KEY `nav_name` (`nav_name`),
  KEY `page_folder` (`page_folder`),
  CONSTRAINT `page_ibfk_2` FOREIGN KEY (`page_folder`) REFERENCES `page_folder` (`name`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `page_folder`;
CREATE TABLE `page_folder` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `index_page` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `index_page` (`index_page`),
  CONSTRAINT `page_folder_ibfk_4` FOREIGN KEY (`index_page`) REFERENCES `page` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `page` (`id`, `template_id`, `parent_id`, `nav_name`, `meta_description`, `meta_keywords`, `header_title`, `h1`, `url`, `teaser_text`, `last_update`, `is_404page`, `show_in_menu`, `order`, `weight`, `silo_id`, `targeted_key_phrase`, `protected`, `system`, `draft`, `publish_at`, `news`, `err_login_landing`, `mem_landing`, `signup_landing`, `checkout`, `preview_image`) VALUES
(1,	'index',	0,	'Home',	'',	'',	'Home',	'Home',	'index.html',	'',	'2012-06-20 11:30:39',	'0',	'1',	0,	0,	NULL,	'',	'0',	'0',	'0',	NULL,	'0',	'0',	'0',	'0',	'0',	NULL);

DROP TABLE IF EXISTS `page_fa`;
CREATE TABLE `page_fa` (
  `page_id` int(10) unsigned NOT NULL,
  `fa_id` int(10) unsigned NOT NULL,
  `order` int(10) unsigned NOT NULL,
  PRIMARY KEY (`page_id`,`fa_id`),
  KEY `indPageId` (`page_id`),
  KEY `indFaId` (`fa_id`),
  KEY `indOrder` (`order`),
  CONSTRAINT `FK_page_fa` FOREIGN KEY (`page_id`) REFERENCES `page` (`id`) ON DELETE CASCADE,
  CONSTRAINT `page_fa_ibfk_1` FOREIGN KEY (`fa_id`) REFERENCES `featured_area` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `page_has_option`;
CREATE TABLE `page_has_option` (
  `page_id` int(10) unsigned NOT NULL,
  `option_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`page_id`,`option_id`),
  KEY `option_id` (`option_id`),
  CONSTRAINT `page_has_option_ibfk_1` FOREIGN KEY (`page_id`) REFERENCES `page` (`id`) ON DELETE CASCADE,
  CONSTRAINT `page_has_option_ibfk_2` FOREIGN KEY (`option_id`) REFERENCES `page_option` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `page_option`;
CREATE TABLE `page_option` (
  `id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `title` tinytext COLLATE utf8_unicode_ci NOT NULL,
  `context` varchar(255) COLLATE utf8_unicode_ci NOT NULL COMMENT 'In which context this option is used. E.g. option_newsindex used in News system context',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `option_usage` ENUM('once', 'many') CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT 'many',
  PRIMARY KEY (`id`),
  KEY `active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `page_option` (`id`, `title`, `context`, `active`, `option_usage`) VALUES
('option_404page',	'Our error 404 "Not found" page',	'Seotoaster pages',	1, 'many'),
('option_member_landing',	'Where members land after logging-in',	'Seotoaster membership',	1, 'once'),
('option_member_loginerror',	'Our membership login error page',	'Seotoaster membership',	1, 'once'),
('option_member_signuplanding',	'Where members land after signed-up',	'Seotoaster membership',	1, 'once'),
('option_protected',	'Accessible only to logged-in members',	'Seotoaster pages',	1, 'many'),
('option_search',	'Search landing page',	'Seotoaster pages',	1, 'once'),
('option_adminredirect',	'Page where superadmin will be redirected after login',	'Redirect',	1,	'once');

DROP TABLE IF EXISTS `password_reset_log`;
CREATE TABLE `password_reset_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `token_hash` varchar(100) COLLATE utf8_unicode_ci NOT NULL COMMENT 'Password reset token. Unique hash string.',
  `user_id` int(10) unsigned NOT NULL,
  `status` enum('new','used','expired') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'new' COMMENT 'Recovery link status',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expired_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  KEY `status` (`status`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `plugin`;
CREATE TABLE `plugin` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` enum('enabled','disabled') COLLATE utf8_unicode_ci DEFAULT 'disabled',
  `tags` text COLLATE utf8_unicode_ci COMMENT 'comma separated words',
  `license` blob,
  `version` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `indName` (`name`),
  KEY `indStatus` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `redirect`;
CREATE TABLE `redirect` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `page_id` int(10) unsigned DEFAULT NULL,
  `from_url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `to_url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `domain_to` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `domain_from` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `indPageId` (`page_id`),
  KEY `indFromUrl` (`from_url`),
  KEY `indToUrl` (`to_url`),
  CONSTRAINT `FK_redirect` FOREIGN KEY (`page_id`) REFERENCES `page` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `seo_data`;
CREATE TABLE `seo_data` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `seo_top` longtext COLLATE utf8_unicode_ci,
  `seo_bottom` longtext COLLATE utf8_unicode_ci,
  `seo_head` longtext COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `silo`;
CREATE TABLE `silo` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `indName` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `template`;
CREATE TABLE `template` (
  `name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `content` longtext COLLATE utf8_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`name`),
  KEY `type` (`type`),
  CONSTRAINT `template_ibfk_1` FOREIGN KEY (`type`) REFERENCES `template_type` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `template` (`name`, `content`, `type`) VALUES
('category',	'<!DOCTYPE html>\n<html lang="en">\n<head>\n    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>\n    <title>{$page:title}</title>\n    <meta name="keywords" content="{$meta:keywords}"/>\n    <meta name="description" content="{$meta:description}"/>\n    <meta name="generator" content="seotoaster"/>\n\n    <link href="reset.css" rel="stylesheet" type="text/css" media="screen"/>\n    <link href="style.css" rel="stylesheet" type="text/css" media="screen"/>\n    <link href="content.css" rel="stylesheet" type="text/css" media="screen"/>\n\n    <!--[if IE]>\n    <script src="html5.js" type="text/javascript"></script>\n    <![endif]-->\n\n</head>\n\n<body>\n<div class="container_12">\n    <header>\n        <div class="grid_3">\n            <div class="logo">\n                <a href="{$website:url}" title="{$page:h1}" class="logo">\n                    <img src="images/logo-small.jpg" width="110" alt="seotoaster">\n                </a>\n            </div>\n        </div>\n        <div class="grid_9">\n            <h2 class="mt30px mb20px xlarge"><strong>Welcome to SEOTOASTER V3 !</strong></h2>\n            <nav>{$menu:main}</nav>\n        </div>\n    </header>\n    <hr/>\n    <aside class="grid_3">\n    <h2>Flat menu</h2>\n    {$menu:flat}\n    </aside>\n    <section class="grid_9">\n        <h1>{$page:h1}</h1>\n        <article>\n            <h3>Header widgets</h3>\n            {$header:header}\n            {$header:header1:static}\n        </article>\n        <article>\n            <h3>Content widgets</h3>\n            {$content:header}\n            {$content:header1:static}\n        </article>\n        <article>\n            <h3>Image Only widget</h3>\n            {$imageonly:photo:200}\n        </article>\n        <article>\n            <h3>Gallery Only widget</h3>\n            {$galleryonly:uniq_name}\n        </article>\n        <article>\n            <h3>Text Only widget</h3>\n            {$textonly:uniq_name}\n        </article>\n        <article>\n            <h3>Featured Area Only widget</h3>\n            {$featuredonly:name}\n        </article>\n        <article>\n            <h3>DirectUpload widget</h3>\n            {$directupload:foldername:imagename:100::crop}\n        </article>\n    </section>\n    <hr/>\n    <footer class="mt10px">\n        <p>Powered by Free &amp; Open Source Ecommerce Website Builder <a href="http://www.seotoaster.com" target="_blank">SEOTOASTER</a>, Courtesy of <a href="http://www.seosamba.com" target="_blank">SEO Samba</a>.</p>\n    </footer>\n</div>\n{$content:newContent}\n</body>\n</html>',	'typeregular'),
('default',	'<!DOCTYPE html>\n<html lang="en">\n<head>\n    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>\n    <title>{$page:title}</title>\n    <meta name="keywords" content="{$meta:keywords}"/>\n    <meta name="description" content="{$meta:description}"/>\n    <meta name="generator" content="seotoaster"/>\n\n    <link href="reset.css" rel="stylesheet" type="text/css" media="screen"/>\n    <link href="style.css" rel="stylesheet" type="text/css" media="screen"/>\n    <link href="content.css" rel="stylesheet" type="text/css" media="screen"/>\n\n    <!--[if IE]>\n    <script src="html5.js" type="text/javascript"></script>\n    <![endif]-->\n\n</head>\n\n<body>\n<div class="container_12">\n    <header>\n        <div class="grid_3">\n            <div class="logo">\n                <a href="{$website:url}" title="{$page:h1}" class="logo">\n                    <img src="images/logo-small.jpg" width="110" alt="seotoaster">\n                </a>\n            </div>\n        </div>\n        <div class="grid_9">\n            <h2 class="mt30px mb20px xlarge"><strong>Welcome to SEOTOASTER V3 !</strong></h2>\n            <nav>{$menu:main}</nav>\n        </div>\n    </header>\n    <hr/>\n    <aside class="grid_3">\n    <h2>Flat menu</h2>\n    {$menu:flat}\n    </aside>\n    <section class="grid_9">\n        <h1>{$page:h1}</h1>\n        <article>\n            <h3>Header widgets</h3>\n            {$header:header}\n            {$header:header1:static}\n        </article>\n        <article>\n            <h3>Content widgets</h3>\n            {$content:header}\n            {$content:header1:static}\n        </article>\n        <article>\n            <h3>Image Only widget</h3>\n            {$imageonly:photo:200}\n        </article>\n        <article>\n            <h3>Gallery Only widget</h3>\n            {$galleryonly:uniq_name}\n        </article>\n        <article>\n            <h3>Text Only widget</h3>\n            {$textonly:uniq_name}\n        </article>\n        <article>\n            <h3>FeaturedArea Only widget</h3>\n            {$featuredonly:name}\n        </article>\n        <article>\n            <h3>DirectUpload widget</h3>\n            {$directupload:foldername:imagename:100::crop}\n        </article>\n    </section>\n    <hr/>\n    <footer class="mt10px">\n        <p>Powered by Free &amp; Open Source Ecommerce Website Builder <a href="http://www.seotoaster.com" target="_blank">SEOTOASTER</a>, Courtesy of <a href="http://www.seosamba.com" target="_blank">SEO Samba</a>.</p>\n    </footer>\n</div>\n{$content:newContent}\n</body>\n</html>',	'typeregular'),
('index',	'<!DOCTYPE html>\n<html lang="en">\n<head>\n    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>\n    <title>{$page:title}</title>\n    <meta name="keywords" content="{$meta:keywords}"/>\n    <meta name="description" content="{$meta:description}"/>\n    <meta name="generator" content="seotoaster"/>\n\n    <link href="reset.css" rel="stylesheet" type="text/css" media="screen"/>\n    <link href="style.css" rel="stylesheet" type="text/css" media="screen"/>\n    <link href="content.css" rel="stylesheet" type="text/css" media="screen"/>\n\n    <!--[if IE]>\n    <script src="html5.js" type="text/javascript"></script>\n    <![endif]-->\n\n</head>\n\n<body>\n<div class="container_12">\n\n    <header>\n        <div class="grid_4">\n            <h1 class="logo">\n                <a href="{$website:url}" title="{$page:h1}" class="logo">\n                    <img src="images/logo-small.jpg" width="215" height="275" alt="seotoaster">\n                </a>\n            </h1>\n        </div>\n\n        <div class="grid_8">\n            <h2 class="mt40px mb50px xlarge">Congratulations,<br/>you have successfully installed<br/><strong>SEOTOASTER\n                V2 !</strong></h2>\n\n            <div class="log_in">Now log into your admin console at <a href="{$website:url}go">{$website:url}go</a></div>\n        </div>\n    </header>\n    {adminonly}\n    <script>\n        $(document).ready(function () {\n            $(\'.log_in\').hide();\n        });\n    </script>\n    <section>\n        <h3><span class="number">1</span>Hit the ground running: get your website on the map now</h3>\n\n        <p>Complete the website ID [WID] card below. It\'s a great time saver, and when you use one of our free premium\n            themes your information shows up in <strong>all the right places</strong> throughout your website.</p>\n\n        <p>In addition, SEOTOASTER build a kml file to help <strong>search engines and geolocation services locate your\n            business </strong>while plug-ins work better and provide you with a pre-built <strong>mobile\n            version</strong> of your website for instance.</p>\n        <hr/>\n\n        {$plugin:widcard:landing}\n        <h3 id="step2" class="mt10px"><span class="number">2</span>Look like a million bucks: download a FREE premium\n            theme</h3>\n        <iframe id="themesList" scrolling-y="yes" frameborder="0" style="width: 100%; height: 660px;" runat="server"\n                src="http://www.seotoaster.com/themes-for-mojo.html" allowtransparency="true"></iframe>\n        <h3 class="mt10px"><span class="number">3</span>Use the easy-to-follow assembly instructions</h3>\n        <a class="_lbox" title="1 click themes" href="images/how-to-add-theme/1-click-themes-big.jpg"><img\n                src="images/how-to-add-theme/1-click-themes.jpg" border="0" alt="1 click themes" width="315"\n                height="221"/></a>\n        <a class="_lbox" title="2 upload theme" href="images/how-to-add-theme/2-upload-theme-big.jpg"><img\n                src="images/how-to-add-theme/2-upload-theme.jpg" border="0" alt="2 upload theme" width="315"\n                height="221"/></a>\n        <a class="_lbox" title="3 select theme" href="images/how-to-add-theme/3-select-theme-big.jpg"><img\n                src="images/how-to-add-theme/3-select-theme.jpg" border="0" alt="3 select theme" width="315"\n                height="221"/></a>\n\n        <h3 class="mt40px"><span class="number">4</span>Explore the plug-ins marketplace: buy or lease it\'s up to you !\n        </h3>\n        <iframe id="themesList" scrolling-y="yes" frameborder="0" style="width: 100%; height: 700px;" runat="server"\n                src="http://www.seotoaster.com/plugins-for-mojo.html" allowtransparency="true"></iframe>\n    </section>\n    {/adminonly}\n    <hr/>\n    <footer class="mt10px">\n        <p>Powered by Free &amp; Open Source Ecommerce Website Builder <a href="http://www.seotoaster.com"\n                                                                          target="_blank">SEOTOASTER</a>, Courtesy of <a\n                href="http://www.seosamba.com" target="_blank">SEO Samba</a>.</p></footer>\n</div>\n{$content:newContent}\n</body>\n</html>',	'typeregular');

DROP TABLE IF EXISTS `template_type`;
CREATE TABLE `template_type` (
  `id` varchar(255) COLLATE utf8_unicode_ci NOT NULL COMMENT 'Template type name: For example ''quote'', ''regularpage'', etc...',
  `title` tinytext COLLATE utf8_unicode_ci NOT NULL COMMENT 'Alias for the template "Product listing", etc...',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `template_type` (`id`, `title`) VALUES
('typemail',	'E-mail'),
('typemenu',	'Menu'),
('typemobile',	'Mobile page'),
('typeregular',	'Regular'),
('type_partial_template',	'Nested Templates'),
('type_fa_template',	'Featuredarea Templates'),
('type_form_auto_reply_pdf', 'Form auto reply pdf');

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `role_id` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(35) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'user password',
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `prefix` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `full_name` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_login` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ipaddress` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reg_date` timestamp NULL DEFAULT NULL,
  `referer` tinytext COLLATE utf8_unicode_ci,
  `gplus_profile` tinytext COLLATE utf8_unicode_ci,
  `mobile_phone` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `voip_phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `notes` TEXT COLLATE utf8_unicode_ci DEFAULT NULL,
  `timezone` VARCHAR(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_country_code` CHAR(2) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_country_code_value` VARCHAR(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `desktop_phone` VARCHAR(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `desktop_country_code` CHAR(2) COLLATE utf8_unicode_ci DEFAULT NULL,
  `desktop_country_code_value` VARCHAR(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `signature` TEXT COLLATE utf8_unicode_ci DEFAULT NULL,
  `subscribed` ENUM('0', '1') DEFAULT '0',
  `allow_remote_authorization` ENUM('1', '0') DEFAULT '0' NOT NULL,
  `remote_authorization_info` TEXT COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'additional info',
  `remote_authorization_token` CHAR(40) DEFAULT NULL,
  `personal_calendar_url` TEXT COLLATE utf8_unicode_ci DEFAULT NULL,
  `avatar_link` TEXT COLLATE utf8_unicode_ci DEFAULT NULL,
  `receive_reports` ENUM('0', '1') DEFAULT '0',
  `receive_reports_preferable_time` int(10) unsigned DEFAULT NULL,
  `receive_reports_cc_email` TEXT COLLATE utf8_unicode_ci DEFAULT NULL,
  `receive_reports_types_list` TEXT COLLATE utf8_unicode_ci DEFAULT NULL,
  `enabled_mfa` ENUM('0', '1') DEFAULT '0',
  `mfa_code` CHAR(6) DEFAULT NULL,
  `mfa_code_expiration_time` TIMESTAMP NULL,
  `exclude_weekends` ENUM('0', '1') DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `indEmail` (`email`),
  KEY `indPassword` (`password`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `user_attributes`;
CREATE TABLE `user_attributes` (
  `user_id` int(10) unsigned NOT NULL,
  `attribute` tinytext COLLATE utf8_unicode_ci NOT NULL,
  `value` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`user_id`,`attribute`(20)),
  CONSTRAINT `user_attributes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `page_types`;
CREATE TABLE `page_types` (
  `page_type_id` TINYINT(3) unsigned NOT NULL,
  `page_type_name` VARCHAR(60),
  PRIMARY KEY (`page_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `page_types` (`page_type_id`, `page_type_name`)
VALUES ('1', 'page');

DROP TABLE IF EXISTS `page_types_access`;
CREATE TABLE `page_types_access` (
  `page_type_id` TINYINT(3) unsigned NOT NULL,
  `resource_type` VARCHAR(60),
  PRIMARY KEY (`page_type_id`, `resource_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `page_types_access` (`page_type_id`, `resource_type`) VALUES
('1', 'list_pages'),
('1', 'link_list'),
('1', 'organize_pages'),
('1', 'seo_pages'),
('2', 'seo_pages'),
('3', 'seo_pages'),
('1', 'sitemap_pages'),
('2', 'sitemap_pages'),
('3', 'sitemap_pages');

DROP TABLE IF EXISTS `masks_list`;
CREATE TABLE `masks_list` (
  `country_code` CHAR(2) COLLATE utf8_unicode_ci NOT NULL,
  `mask_type` ENUM('mobile', 'desktop') DEFAULT 'mobile' NOT NULL,
  `mask_value` VARCHAR(20) COLLATE utf8_unicode_ci NOT NULL,
  `full_mask_value` VARCHAR(20) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`country_code`, `mask_type`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `masks_list` (`country_code`, `mask_type`, `mask_value`, `full_mask_value`) VALUES
('AC',	'mobile',	'9999',	'9999'),
('AC',	'desktop',	'9999',	'9999'),
('AD',	'mobile',	'999-999',	'999-999'),
('AD',	'desktop',	'999-999',	'999-999'),
('AE',	'mobile',	'59-999-9999',	'59-999-9999'),
('AE',	'desktop',	'59-999-9999',	'59-999-9999'),
('AF',	'mobile',	'99-999-9999',	'99-999-9999'),
('AF',	'desktop',	'99-999-9999',	'99-999-9999'),
('AG',	'mobile',	'(268)999-9999',	'(268)999-9999'),
('AG',	'desktop',	'(268)999-9999',	'(268)999-9999'),
('AI',	'mobile',	'(264)999-9999',	'(264)999-9999'),
('AI',	'desktop',	'(264)999-9999',	'(264)999-9999'),
('AL',	'mobile',	'(999)999-999',	'(999)999-999'),
('AL',	'desktop',	'(999)999-999',	'(999)999-999'),
('AM',	'mobile',	'99-999-999',	'99-999-999'),
('AM',	'desktop',	'99-999-999',	'99-999-999'),
('AN',	'mobile',	'999-9999',	'999-9999'),
('AN',	'desktop',	'999-9999',	'999-9999'),
('AO',	'mobile',	'(999)999-999',	'(999)999-999'),
('AO',	'desktop',	'(999)999-999',	'(999)999-999'),
('AQ',	'mobile',	'199-999',	'199-999'),
('AQ',	'desktop',	'199-999',	'199-999'),
('AR',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('AR',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('AS',	'mobile',	'(684)999-9999',	'(684)999-9999'),
('AS',	'desktop',	'(684)999-9999',	'(684)999-9999'),
('AT',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('AT',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('AU',	'mobile',	'9-9999-9999',	'9-9999-9999'),
('AU',	'desktop',	'9-9999-9999',	'9-9999-9999'),
('AW',	'mobile',	'999-9999',	'999-9999'),
('AW',	'desktop',	'999-9999',	'999-9999'),
('AZ',	'mobile',	'99-999-99-99',	'99-999-99-99'),
('AZ',	'desktop',	'99-999-99-99',	'99-999-99-99'),
('BA',	'mobile',	'99-99999',	'99-99999'),
('BA',	'desktop',	'99-99999',	'99-99999'),
('BB',	'mobile',	'(246)999-9999',	'(246)999-9999'),
('BB',	'desktop',	'(246)999-9999',	'(246)999-9999'),
('BD',	'mobile',	'99-999-999',	'99-999-999'),
('BD',	'desktop',	'99-999-999',	'99-999-999'),
('BE',	'mobile',	'9 99 99 99 99',	'9 99 99 99 99'),
('BE',	'desktop',	'9 99 99 99 99',	'9 99 99 99 99'),
('BF',	'mobile',	'99-99-9999',	'99-99-9999'),
('BF',	'desktop',	'99-99-9999',	'99-99-9999'),
('BG',	'mobile',	'(999)999-999',	'(999)999-999'),
('BG',	'desktop',	'(999)999-999',	'(999)999-999'),
('BH',	'mobile',	'9999-9999',	'9999-9999'),
('BH',	'desktop',	'9999-9999',	'9999-9999'),
('BI',	'mobile',	'99-99-9999',	'99-99-9999'),
('BI',	'desktop',	'99-99-9999',	'99-99-9999'),
('BJ',	'mobile',	'99-99-9999',	'99-99-9999'),
('BJ',	'desktop',	'99-99-9999',	'99-99-9999'),
('BM',	'mobile',	'(441)999-9999',	'(441)999-9999'),
('BM',	'desktop',	'(441)999-9999',	'(441)999-9999'),
('BN',	'mobile',	'999-9999',	'999-9999'),
('BN',	'desktop',	'999-9999',	'999-9999'),
('BO',	'mobile',	'9-999-9999',	'9-999-9999'),
('BO',	'desktop',	'9-999-9999',	'9-999-9999'),
('BR',	'mobile',	'(99)9999-9999',	'(99)9999-9999'),
('BR',	'desktop',	'(99)9999-9999',	'(99)9999-9999'),
('BS',	'mobile',	'(242)999-9999',	'(242)999-9999'),
('BS',	'desktop',	'(242)999-9999',	'(242)999-9999'),
('BT',	'mobile',	'17-999-999',	'17-999-999'),
('BT',	'desktop',	'17-999-999',	'17-999-999'),
('BW',	'mobile',	'99-999-999',	'99-999-999'),
('BW',	'desktop',	'99-999-999',	'99-999-999'),
('BY',	'mobile',	'(99)999-99-99',	'(99)999-99-99'),
('BY',	'desktop',	'(99)999-99-99',	'(99)999-99-99'),
('BZ',	'mobile',	'999-9999',	'999-9999'),
('BZ',	'desktop',	'999-9999',	'999-9999'),
('CA',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('CA',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('CD',	'mobile',	'(999)999-999',	'(999)999-999'),
('CD',	'desktop',	'(999)999-999',	'(999)999-999'),
('CF',	'mobile',	'99-99-9999',	'99-99-9999'),
('CF',	'desktop',	'99-99-9999',	'99-99-9999'),
('CG',	'mobile',	'99-999-9999',	'99-999-9999'),
('CG',	'desktop',	'99-999-9999',	'99-999-9999'),
('CH',	'mobile',	'99 999 99 99',	'99 999 99 99'),
('CH',	'desktop',	'99 999 99 99',	'99 999 99 99'),
('CI',	'mobile',	'99-999-999',	'99-999-999'),
('CI',	'desktop',	'99-999-999',	'99-999-999'),
('CK',	'mobile',	'99-999',	'99-999'),
('CK',	'desktop',	'99-999',	'99-999'),
('CL',	'mobile',	'9-9999-9999',	'9-9999-9999'),
('CL',	'desktop',	'9-9999-9999',	'9-9999-9999'),
('CM',	'mobile',	'9999-9999',	'9999-9999'),
('CM',	'desktop',	'9999-9999',	'9999-9999'),
('CN',	'mobile',	'(999)9999-9999',	'(999)9999-9999'),
('CN',	'desktop',	'(999)9999-9999',	'(999)9999-9999'),
('CO',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('CO',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('CR',	'mobile',	'9999-9999',	'9999-9999'),
('CR',	'desktop',	'9999-9999',	'9999-9999'),
('CU',	'mobile',	'9-999-9999',	'9-999-9999'),
('CU',	'desktop',	'9-999-9999',	'9-999-9999'),
('CV',	'mobile',	'(999)99-99',	'(999)99-99'),
('CV',	'desktop',	'(999)99-99',	'(999)99-99'),
('CW',	'mobile',	'999-9999',	'999-9999'),
('CW',	'desktop',	'999-9999',	'999-9999'),
('CY',	'mobile',	'99-999-999',	'99-999-999'),
('CY',	'desktop',	'99-999-999',	'99-999-999'),
('CZ',	'mobile',	'(999)999-999',	'(999)999-999'),
('CZ',	'desktop',	'(999)999-999',	'(999)999-999'),
('DE',	'mobile',	'(9999)999-9999',	'(9999)999-9999'),
('DE',	'desktop',	'(9999)999-9999',	'(9999)999-9999'),
('DJ',	'mobile',	'99-99-99-99',	'99-99-99-99'),
('DJ',	'desktop',	'99-99-99-99',	'99-99-99-99'),
('DK',	'mobile',	'99-99-99-99',	'99-99-99-99'),
('DK',	'desktop',	'99-99-99-99',	'99-99-99-99'),
('DM',	'mobile',	'(767)999-9999',	'(767)999-9999'),
('DM',	'desktop',	'(767)999-9999',	'(767)999-9999'),
('DO',	'mobile',	'(809)999-9999',	'(809)999-9999'),
('DO',	'desktop',	'(809)999-9999',	'(809)999-9999'),
('DZ',	'mobile',	'99-999-9999',	'99-999-9999'),
('DZ',	'desktop',	'99-999-9999',	'99-999-9999'),
('EC',	'mobile',	'99-999-9999',	'99-999-9999'),
('EC',	'desktop',	'99-999-9999',	'99-999-9999'),
('EE',	'mobile',	'9999-9999',	'9999-9999'),
('EE',	'desktop',	'9999-9999',	'9999-9999'),
('EG',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('EG',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('ER',	'mobile',	'9-999-999',	'9-999-999'),
('ER',	'desktop',	'9-999-999',	'9-999-999'),
('ES',	'mobile',	'(999)999-999',	'(999)999-999'),
('ES',	'desktop',	'(999)999-999',	'(999)999-999'),
('ET',	'mobile',	'99-999-9999',	'99-999-9999'),
('ET',	'desktop',	'99-999-9999',	'99-999-9999'),
('FI',	'mobile',	'(999)999-99-99',	'(999)999-99-99'),
('FI',	'desktop',	'(999)999-99-99',	'(999)999-99-99'),
('FJ',	'mobile',	'99-99999',	'99-99999'),
('FJ',	'desktop',	'99-99999',	'99-99999'),
('FK',	'mobile',	'99999',	'99999'),
('FK',	'desktop',	'99999',	'99999'),
('FM',	'mobile',	'999-9999',	'999-9999'),
('FM',	'desktop',	'999-9999',	'999-9999'),
('FO',	'mobile',	'999-999',	'999-999'),
('FO',	'desktop',	'999-999',	'999-999'),
('FR',  'mobile', '99 99 99 99 9?9', '99 99 99 99 9?9'),
('FR',  'desktop', '99 99 99 99 9?9', '99 99 99 99 9?9'),
('GA',	'mobile',	'9-99-99-99',	'9-99-99-99'),
('GA',	'desktop',	'9-99-99-99',	'9-99-99-99'),
('GB',	'mobile',	'99-9999-9999?9',	'99-9999-9999?9'),
('GB',	'desktop',	'99-9999-9999?9',	'99-9999-9999?9'),
('GD',	'mobile',	'(473)999-9999',	'(473)999-9999'),
('GD',	'desktop',	'(473)999-9999',	'(473)999-9999'),
('GE',	'mobile',	'(999)999-999',	'(999)999-999'),
('GE',	'desktop',	'(999)999-999',	'(999)999-999'),
('GF',	'mobile',	'99999-9999',	'99999-9999'),
('GF',	'desktop',	'99999-9999',	'99999-9999'),
('GH',	'mobile',	'(999)999-999',	'(999)999-999'),
('GH',	'desktop',	'(999)999-999',	'(999)999-999'),
('GI',	'mobile',	'999-99999',	'999-99999'),
('GI',	'desktop',	'999-99999',	'999-99999'),
('GL',	'mobile',	'99-99-99',	'99-99-99'),
('GL',	'desktop',	'99-99-99',	'99-99-99'),
('GM',	'mobile',	'(999)99-99',	'(999)99-99'),
('GM',	'desktop',	'(999)99-99',	'(999)99-99'),
('GN',	'mobile',	'99-999-999',	'99-999-999'),
('GN',	'desktop',	'99-999-999',	'99-999-999'),
('GQ',	'mobile',	'99-999-9999',	'99-999-9999'),
('GQ',	'desktop',	'99-999-9999',	'99-999-9999'),
('GR',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('GR',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('GT',	'mobile',	'9-999-9999',	'9-999-9999'),
('GT',	'desktop',	'9-999-9999',	'9-999-9999'),
('GU',	'mobile',	'(671)999-9999',	'(671)999-9999'),
('GU',	'desktop',	'(671)999-9999',	'(671)999-9999'),
('GW',	'mobile',	'9-999999',	'9-999999'),
('GW',	'desktop',	'9-999999',	'9-999999'),
('GY',	'mobile',	'999-9999',	'999-9999'),
('GY',	'desktop',	'999-9999',	'999-9999'),
('HK',	'mobile',	'9999-9999',	'9999-9999'),
('HK',	'desktop',	'9999-9999',	'9999-9999'),
('HN',	'mobile',	'9999-9999',	'9999-9999'),
('HN',	'desktop',	'9999-9999',	'9999-9999'),
('HR',	'mobile',	'99-999-999',	'99-999-999'),
('HR',	'desktop',	'99-999-999',	'99-999-999'),
('HT',	'mobile',	'99-99-9999',	'99-99-9999'),
('HT',	'desktop',	'99-99-9999',	'99-99-9999'),
('HU',	'mobile',	'(999)999-999',	'(999)999-999'),
('HU',	'desktop',	'(999)999-999',	'(999)999-999'),
('ID',	'mobile',	'(899)999-9999',	'(899)999-9999'),
('ID',	'desktop',	'(899)999-9999',	'(899)999-9999'),
('IE',	'mobile',	'(999)999-999',	'(999)999-999'),
('IE',	'desktop',	'(999)999-999',	'(999)999-999'),
('IL',	'mobile',	'59-999-9999',	'59-999-9999'),
('IL',	'desktop',	'59-999-9999',	'59-999-9999'),
('IN',	'mobile',	'(9999)999-999',	'(9999)999-999'),
('IN',	'desktop',	'(9999)999-999',	'(9999)999-999'),
('IO',	'mobile',	'999-9999',	'999-9999'),
('IO',	'desktop',	'999-9999',	'999-9999'),
('IQ',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('IQ',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('IR',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('IR',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('IS',	'mobile',	'999-9999',	'999-9999'),
('IS',	'desktop',	'999-9999',	'999-9999'),
('IT',	'mobile',	'(999)9999-999',	'(999)9999-999'),
('IT',	'desktop',	'(999)9999-999',	'(999)9999-999'),
('JM',	'mobile',	'(876)999-9999',	'(876)999-9999'),
('JM',	'desktop',	'(876)999-9999',	'(876)999-9999'),
('JO',	'mobile',	'9-9999-9999',	'9-9999-9999'),
('JO',	'desktop',	'9-9999-9999',	'9-9999-9999'),
('JP',	'mobile',	'99-9999-9999',	'99-9999-9999'),
('JP',	'desktop',	'99-9999-9999',	'99-9999-9999'),
('KE',	'mobile',	'999-999999',	'999-999999'),
('KE',	'desktop',	'999-999999',	'999-999999'),
('KG',	'mobile',	'(999)999-999',	'(999)999-999'),
('KG',	'desktop',	'(999)999-999',	'(999)999-999'),
('KH',	'mobile',	'99-999-999',	'99-999-999'),
('KH',	'desktop',	'99-999-999',	'99-999-999'),
('KI',	'mobile',	'99-999',	'99-999'),
('KI',	'desktop',	'99-999',	'99-999'),
('KM',	'mobile',	'99-99999',	'99-99999'),
('KM',	'desktop',	'99-99999',	'99-99999'),
('KN',	'mobile',	'(869)999-9999',	'(869)999-9999'),
('KN',	'desktop',	'(869)999-9999',	'(869)999-9999'),
('KP',	'mobile',	'191-999-9999',	'191-999-9999'),
('KP',	'desktop',	'191-999-9999',	'191-999-9999'),
('KR',	'mobile',	'99-999-9999',	'99-999-9999'),
('KR',	'desktop',	'99-999-9999',	'99-999-9999'),
('KW',	'mobile',	'9999-9999',	'9999-9999'),
('KW',	'desktop',	'9999-9999',	'9999-9999'),
('KY',	'mobile',	'(345)999-9999',	'(345)999-9999'),
('KY',	'desktop',	'(345)999-9999',	'(345)999-9999'),
('KZ',	'mobile',	'(699)999-99-99',	'(699)999-99-99'),
('KZ',	'desktop',	'(699)999-99-99',	'(699)999-99-99'),
('LA',	'mobile',	'(2099)999-999',	'(2099)999-999'),
('LA',	'desktop',	'(2099)999-999',	'(2099)999-999'),
('LB',	'mobile',	'99-999-999',	'99-999-999'),
('LB',	'desktop',	'99-999-999',	'99-999-999'),
('LC',	'mobile',	'999-9999',	'999-9999'),
('LC',	'desktop',	'999-9999',	'999-9999'),
('LI',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('LI',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('LK',	'mobile',	'99-999-9999',	'99-999-9999'),
('LK',	'desktop',	'99-999-9999',	'99-999-9999'),
('LR',	'mobile',	'99-999-999',	'99-999-999'),
('LR',	'desktop',	'99-999-999',	'99-999-999'),
('LS',	'mobile',	'9-999-9999',	'9-999-9999'),
('LS',	'desktop',	'9-999-9999',	'9-999-9999'),
('LT',	'mobile',	'(999)99-999',	'(999)99-999'),
('LT',	'desktop',	'(999)99-999',	'(999)99-999'),
('LU',	'mobile',	'(999)999-999',	'(999)999-999'),
('LU',	'desktop',	'(999)999-999',	'(999)999-999'),
('LV',	'mobile',	'99-999-999',	'99-999-999'),
('LV',	'desktop',	'99-999-999',	'99-999-999'),
('LY',	'mobile',	'99-999-999',	'99-999-999'),
('LY',	'desktop',	'99-999-999',	'99-999-999'),
('MA',	'mobile',	'99-9999-999',	'99-9999-999'),
('MA',	'desktop',	'99-9999-999',	'99-9999-999'),
('MC',	'mobile',	'99 99 99 99',	'99 99 99 99'),
('MC',	'desktop',	'99 99 99 99',	'99 99 99 99'),
('MD',	'mobile',	'9999-9999',	'9999-9999'),
('MD',	'desktop',	'9999-9999',	'9999-9999'),
('ME',	'mobile',	'99-999-999',	'99-999-999'),
('ME',	'desktop',	'99-999-999',	'99-999-999'),
('MG',	'mobile',	'99-99-99999',	'99-99-99999'),
('MG',	'desktop',	'99-99-99999',	'99-99-99999'),
('MH',	'mobile',	'999-9999',	'999-9999'),
('MH',	'desktop',	'999-9999',	'999-9999'),
('MK',	'mobile',	'99-999-999',	'99-999-999'),
('MK',	'desktop',	'99-999-999',	'99-999-999'),
('ML',	'mobile',	'99-99-9999',	'99-99-9999'),
('ML',	'desktop',	'99-99-9999',	'99-99-9999'),
('MM',	'mobile',	'99-999-999',	'99-999-999'),
('MM',	'desktop',	'99-999-999',	'99-999-999'),
('MN',	'mobile',	'99-99-9999',	'99-99-9999'),
('MN',	'desktop',	'99-99-9999',	'99-99-9999'),
('MO',	'mobile',	'9999-9999',	'9999-9999'),
('MO',	'desktop',	'9999-9999',	'9999-9999'),
('MP',	'mobile',	'999-9999',	'999-9999'),
('MP',	'desktop',	'999-9999',	'999-9999'),
('MQ',	'mobile',	'(999)99-99-99',	'(999)99-99-99'),
('MQ',	'desktop',	'(999)99-99-99',	'(999)99-99-99'),
('MR',	'mobile',	'99-99-9999',	'99-99-9999'),
('MR',	'desktop',	'99-99-9999',	'99-99-9999'),
('MS',	'mobile',	'999-9999',	'999-9999'),
('MS',	'desktop',	'999-9999',	'999-9999'),
('MT',	'mobile',	'9999-9999',	'9999-9999'),
('MT',	'desktop',	'9999-9999',	'9999-9999'),
('MU',	'mobile',	'999-9999',	'999-9999'),
('MU',	'desktop',	'999-9999',	'999-9999'),
('MV',	'mobile',	'999-9999',	'999-9999'),
('MV',	'desktop',	'999-9999',	'999-9999'),
('MW',	'mobile',	'999-999',	'999-999'),
('MW',	'desktop',	'999-999',	'999-999'),
('MX',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('MX',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('MY',	'mobile',	'99-999-9999',	'99-999-9999'),
('MY',	'desktop',	'99-999-9999',	'99-999-9999'),
('MZ',	'mobile',	'99-999-999',	'99-999-999'),
('MZ',	'desktop',	'99-999-999',	'99-999-999'),
('NA',	'mobile',	'99-999-9999',	'99-999-9999'),
('NA',	'desktop',	'99-999-9999',	'99-999-9999'),
('NC',	'mobile',	'99-9999',	'99-9999'),
('NC',	'desktop',	'99-9999',	'99-9999'),
('NE',	'mobile',	'99-99-9999',	'99-99-9999'),
('NE',	'desktop',	'99-99-9999',	'99-99-9999'),
('NF',	'mobile',	'99-999',	'99-999'),
('NF',	'desktop',	'99-999',	'99-999'),
('NG',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('NG',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('NI',	'mobile',	'9999-9999',	'9999-9999'),
('NI',	'desktop',	'9999-9999',	'9999-9999'),
('NL',	'mobile',	'99-999-9999',	'99-999-9999'),
('NL',	'desktop',	'99-999-9999',	'99-999-9999'),
('NO',	'mobile',	'(999)99-999',	'(999)99-999'),
('NO',	'desktop',	'(999)99-999',	'(999)99-999'),
('NP',	'mobile',	'99-999-999',	'99-999-999'),
('NP',	'desktop',	'99-999-999',	'99-999-999'),
('NR',	'mobile',	'999-9999',	'999-9999'),
('NR',	'desktop',	'999-9999',	'999-9999'),
('NU',	'mobile',	'9999',	'9999'),
('NU',	'desktop',	'9999',	'9999'),
('NZ',	'mobile',	'(999)999-999',	'(999)999-999'),
('NZ',	'desktop',	'(999)999-999',	'(999)999-999'),
('OM',	'mobile',	'99-999-999',	'99-999-999'),
('OM',	'desktop',	'99-999-999',	'99-999-999'),
('PA',	'mobile',	'999-9999',	'999-9999'),
('PA',	'desktop',	'999-9999',	'999-9999'),
('PE',	'mobile',	'(999)999-999',	'(999)999-999'),
('PE',	'desktop',	'(999)999-999',	'(999)999-999'),
('PF',	'mobile',	'99-99-99',	'99-99-99'),
('PF',	'desktop',	'99-99-99',	'99-99-99'),
('PG',	'mobile',	'(999)99-999',	'(999)99-999'),
('PG',	'desktop',	'(999)99-999',	'(999)99-999'),
('PH',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('PH',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('PK',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('PK',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('PL',	'mobile',	'(999)999-999',	'(999)999-999'),
('PL',	'desktop',	'(999)999-999',	'(999)999-999'),
('PS',	'mobile',	'99-999-9999',	'99-999-9999'),
('PS',	'desktop',	'99-999-9999',	'99-999-9999'),
('PT',	'mobile',	'99-999-9999',	'99-999-9999'),
('PT',	'desktop',	'99-999-9999',	'99-999-9999'),
('PW',	'mobile',	'999-9999',	'999-9999'),
('PW',	'desktop',	'999-9999',	'999-9999'),
('PY',	'mobile',	'(999)999-999',	'(999)999-999'),
('PY',	'desktop',	'(999)999-999',	'(999)999-999'),
('QA',	'mobile',	'9999-9999',	'9999-9999'),
('QA',	'desktop',	'9999-9999',	'9999-9999'),
('RE',	'mobile',	'99999-9999',	'99999-9999'),
('RE',	'desktop',	'99999-9999',	'99999-9999'),
('RO',	'mobile',	'99-999-9999',	'99-999-9999'),
('RO',	'desktop',	'99-999-9999',	'99-999-9999'),
('RS',	'mobile',	'99-999-9999',	'99-999-9999'),
('RS',	'desktop',	'99-999-9999',	'99-999-9999'),
('RU',	'mobile',	'(999)999-99-99',	'(999)999-99-99'),
('RU',	'desktop',	'(999)999-99-99',	'(999)999-99-99'),
('RW',	'mobile',	'(999)999-999',	'(999)999-999'),
('RW',	'desktop',	'(999)999-999',	'(999)999-999'),
('SA',	'mobile',	'9999-9999',	'9999-9999'),
('SA',	'desktop',	'9999-9999',	'9999-9999'),
('SB',	'mobile',	'999-9999',	'999-9999'),
('SB',	'desktop',	'999-9999',	'999-9999'),
('SC',	'mobile',	'9-999-999',	'9-999-999'),
('SC',	'desktop',	'9-999-999',	'9-999-999'),
('SD',	'mobile',	'99-999-9999',	'99-999-9999'),
('SD',	'desktop',	'99-999-9999',	'99-999-9999'),
('SE',	'mobile',	'99-999-9999',	'99-999-9999'),
('SE',	'desktop',	'99-999-9999',	'99-999-9999'),
('SG',	'mobile',	'9999-9999',	'9999-9999'),
('SG',	'desktop',	'9999-9999',	'9999-9999'),
('SH',	'mobile',	'9999',	'9999'),
('SH',	'desktop',	'9999',	'9999'),
('SI',	'mobile',	'99-999-999',	'99-999-999'),
('SI',	'desktop',	'99-999-999',	'99-999-999'),
('SK',	'mobile',	'(999)999-999',	'(999)999-999'),
('SK',	'desktop',	'(999)999-999',	'(999)999-999'),
('SL',	'mobile',	'99-999999',	'99-999999'),
('SL',	'desktop',	'99-999999',	'99-999999'),
('SM',	'mobile',	'9999-999999',	'9999-999999'),
('SM',	'desktop',	'9999-999999',	'9999-999999'),
('SN',	'mobile',	'99-999-9999',	'99-999-9999'),
('SN',	'desktop',	'99-999-9999',	'99-999-9999'),
('SO',	'mobile',	'99-999-999',	'99-999-999'),
('SO',	'desktop',	'99-999-999',	'99-999-999'),
('SR',	'mobile',	'999-9999',	'999-9999'),
('SR',	'desktop',	'999-9999',	'999-9999'),
('SS',	'mobile',	'99-999-9999',	'99-999-9999'),
('SS',	'desktop',	'99-999-9999',	'99-999-9999'),
('ST',	'mobile',	'99-99999',	'99-99999'),
('ST',	'desktop',	'99-99999',	'99-99999'),
('SV',	'mobile',	'99-99-9999',	'99-99-9999'),
('SV',	'desktop',	'99-99-9999',	'99-99-9999'),
('SX',	'mobile',	'999-9999',	'999-9999'),
('SX',	'desktop',	'999-9999',	'999-9999'),
('SY',	'mobile',	'99-9999-999',	'99-9999-999'),
('SY',	'desktop',	'99-9999-999',	'99-9999-999'),
('SZ',	'mobile',	'99-99-9999',	'99-99-9999'),
('SZ',	'desktop',	'99-99-9999',	'99-99-9999'),
('TC',	'mobile',	'999-9999',	'999-9999'),
('TC',	'desktop',	'999-9999',	'999-9999'),
('TD',	'mobile',	'99-99-99-99',	'99-99-99-99'),
('TD',	'desktop',	'99-99-99-99',	'99-99-99-99'),
('TG',	'mobile',	'99-999-999',	'99-999-999'),
('TG',	'desktop',	'99-999-999',	'99-999-999'),
('TH',	'mobile',	'99-999-9999',	'99-999-9999'),
('TH',	'desktop',	'99-999-9999',	'99-999-9999'),
('TJ',	'mobile',	'99-999-9999',	'99-999-9999'),
('TJ',	'desktop',	'99-999-9999',	'99-999-9999'),
('TK',	'mobile',	'9999',	'9999'),
('TK',	'desktop',	'9999',	'9999'),
('TL',	'mobile',	'999-9999',	'999-9999'),
('TL',	'desktop',	'999-9999',	'999-9999'),
('TM',	'mobile',	'9-999-9999',	'9-999-9999'),
('TM',	'desktop',	'9-999-9999',	'9-999-9999'),
('TN',	'mobile',	'99-999-999',	'99-999-999'),
('TN',	'desktop',	'99-999-999',	'99-999-999'),
('TO',	'mobile',	'99999',	'99999'),
('TO',	'desktop',	'99999',	'99999'),
('TR',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('TR',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('TT',	'mobile',	'999-9999',	'999-9999'),
('TT',	'desktop',	'999-9999',	'999-9999'),
('TV',	'mobile',	'9999',	'9999'),
('TV',	'desktop',	'9999',	'9999'),
('TW',	'mobile',	'9-9999-9999',	'9-9999-9999'),
('TW',	'desktop',	'9-9999-9999',	'9-9999-9999'),
('TZ',	'mobile',	'99-999-9999',	'99-999-9999'),
('TZ',	'desktop',	'99-999-9999',	'99-999-9999'),
('UA',	'mobile',	'(99)999-99-99',	'(99)999-99-99'),
('UA',	'desktop',	'(99)999-99-99',	'(99)999-99-99'),
('UG',	'mobile',	'(999)999-999',	'(999)999-999'),
('UG',	'desktop',	'(999)999-999',	'(999)999-999'),
('US',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('US',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('UY',	'mobile',	'9-999-99-99',	'9-999-99-99'),
('UY',	'desktop',	'9-999-99-99',	'9-999-99-99'),
('UZ',	'mobile',	'99-999-9999',	'99-999-9999'),
('UZ',	'desktop',	'99-999-9999',	'99-999-9999'),
('VA',	'mobile',	'99999',	'99999'),
('VA',	'desktop',	'99999',	'99999'),
('VC',	'mobile',	'999-9999',	'999-9999'),
('VC',	'desktop',	'999-9999',	'999-9999'),
('VE',	'mobile',	'(999)999-9999',	'(999)999-9999'),
('VE',	'desktop',	'(999)999-9999',	'(999)999-9999'),
('VG',	'mobile',	'999-9999',	'999-9999'),
('VG',	'desktop',	'999-9999',	'999-9999'),
('VI',	'mobile',	'999-9999',	'999-9999'),
('VI',	'desktop',	'999-9999',	'999-9999'),
('VN',	'mobile',	'99-9999-999',	'99-9999-999'),
('VN',	'desktop',	'99-9999-999',	'99-9999-999'),
('VU',	'mobile',	'99-99999',	'99-99999'),
('VU',	'desktop',	'99-99999',	'99-99999'),
('WF',	'mobile',	'99-9999',	'99-9999'),
('WF',	'desktop',	'99-9999',	'99-9999'),
('WS',	'mobile',	'99-9999',	'99-9999'),
('WS',	'desktop',	'99-9999',	'99-9999'),
('YE',	'mobile',	'999-999-999',	'999-999-999'),
('YE',	'desktop',	'999-999-999',	'999-999-999'),
('ZA',	'mobile',	'99-999-9999',	'99-999-9999'),
('ZA',	'desktop',	'99-999-9999',	'99-999-9999'),
('ZM',	'mobile',	'99-999-9999',	'99-999-9999'),
('ZM',	'desktop',	'99-999-9999',	'99-999-9999'),
('ZW',	'mobile',	'9-999999',	'9-999999'),
('ZW',	'desktop',	'9-999999',	'9-999999');

DROP TABLE IF EXISTS `form_blacklist_rules`;
CREATE TABLE `form_blacklist_rules` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `type` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`type`,`value`),
  UNIQUE (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
INSERT IGNORE INTO `email_triggers_actions` (`service`, `trigger`, `template`, `recipient`, `message`, `from`, `subject`)
SELECT CONCAT('email'),	CONCAT('t_userinvitation'),	NULL,	CONCAT('guest'),	CONCAT('Hello {user:fullname},<br><br>You have a new account at {$website:url}<br><br>Account details:<br><b>Login: </b>{user:email}<br><br>Start using your new account by <a href={reset:url}>setting up a password</a>'),	CONCAT('admin@{$website:domain}'),	CONCAT('Complete your account setup') FROM email_triggers WHERE NOT EXISTS (SELECT `service`, `trigger`, `template`, `recipient`, `message`, `from`, `subject` FROM `email_triggers_actions` WHERE `service` = 'email' AND `recipient` = 'guest' AND `trigger` = 't_userinvitation') LIMIT 1;

DROP TABLE IF EXISTS `user_whitelist_ips`;
CREATE TABLE `user_whitelist_ips` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `role_id` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `ip_address` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`role_id`,`ip_address`),
  UNIQUE (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;