CREATE TABLE `attendances` (
  `id` int(11) NOT NULL auto_increment,
  `politician_id` int(11) default NULL,
  `sitting_id` int(11) default NULL,
  `present` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_attendances_on_politician_id` (`politician_id`),
  KEY `index_attendances_on_sitting_id` (`sitting_id`)
) ENGINE=InnoDB AUTO_INCREMENT=182994 DEFAULT CHARSET=utf8;

CREATE TABLE `coordinates` (
  `id` int(11) NOT NULL auto_increment,
  `lon` varchar(9) default NULL,
  `lat` varchar(9) default NULL,
  `state_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=233 DEFAULT CHARSET=utf8;

CREATE TABLE `debate_references` (
  `id` int(11) NOT NULL auto_increment,
  `politician_id` int(11) default NULL,
  `name_reference_id` int(11) default NULL,
  `sitting_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40146 DEFAULT CHARSET=utf8;

CREATE TABLE `mp_caches` (
  `id` int(11) NOT NULL auto_increment,
  `politician_id` int(11) default NULL,
  `trip_duration` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3967 DEFAULT CHARSET=utf8;

CREATE TABLE `parliament_votes` (
  `id` int(11) NOT NULL auto_increment,
  `question_id` int(11) default NULL,
  `action_yes` int(11) default NULL,
  `action_no` int(11) default NULL,
  `action_absent` int(11) default NULL,
  `action_abstain` int(11) default NULL,
  `action_novote` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9152 DEFAULT CHARSET=utf8;

CREATE TABLE `political_group_votes` (
  `id` int(11) NOT NULL auto_increment,
  `political_group_id` bigint(11) default NULL,
  `question_id` bigint(11) default NULL,
  `time` varchar(8) default NULL,
  `action_yes` bigint(11) default NULL,
  `action_no` bigint(11) default NULL,
  `action_absent` bigint(11) default NULL,
  `action_abstain` bigint(11) default NULL,
  `action_novote` bigint(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=203670 DEFAULT CHARSET=utf8;

CREATE TABLE `political_groups` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `code` varchar(10) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

CREATE TABLE `politicians` (
  `id` int(11) NOT NULL auto_increment,
  `email` varchar(40) default NULL,
  `constituency` varchar(80) default NULL,
  `party_candidate` varchar(120) default NULL,
  `id_in_lrs` int(11) default NULL,
  `last_name` varchar(255) default NULL,
  `first_name` varchar(255) default NULL,
  `second_name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=990 DEFAULT CHARSET=utf8;

CREATE TABLE `positions` (
  `id` int(11) NOT NULL auto_increment,
  `politician_id` int(11) NOT NULL default '0',
  `description` varchar(200) default NULL,
  `from` date default NULL,
  `to` date default NULL,
  `title` varchar(80) default NULL,
  `department` varchar(80) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=22051 DEFAULT CHARSET=utf8;

CREATE TABLE `questions` (
  `id` int(11) NOT NULL auto_increment,
  `formulation` text,
  `stage` varchar(20) default NULL,
  `sitting_id` int(11) NOT NULL default '0',
  `sid` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `sitting_id_index` (`sitting_id`)
) ENGINE=MyISAM AUTO_INCREMENT=25245 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL default '',
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `from` date default NULL,
  `to` date default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8;

CREATE TABLE `sittings` (
  `id` int(11) NOT NULL auto_increment,
  `sid` int(11) NOT NULL default '0',
  `date` date NOT NULL default '0000-00-00',
  `name` varchar(20) default '',
  `session_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=1345 DEFAULT CHARSET=utf8;

CREATE TABLE `speeches` (
  `id` int(11) NOT NULL auto_increment,
  `time` varchar(8) default NULL,
  `politician_id` int(11) NOT NULL default '0',
  `question_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `index_speeches_on_politician_id` (`politician_id`),
  KEY `index_speeches_on_question_id` (`question_id`)
) ENGINE=MyISAM AUTO_INCREMENT=74640 DEFAULT CHARSET=utf8;

CREATE TABLE `state_groups` (
  `id` int(11) NOT NULL auto_increment,
  `state_id` int(11) NOT NULL default '0',
  `name` varchar(8) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

CREATE TABLE `state_labels` (
  `id` int(11) NOT NULL auto_increment,
  `label` varchar(120) default NULL,
  `state_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=261 DEFAULT CHARSET=utf8;

CREATE TABLE `state_unions` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(10) default NULL,
  `lng` varchar(10) default NULL,
  `lat` varchar(10) default NULL,
  `iso` char(2) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `states` (
  `id` int(11) NOT NULL auto_increment,
  `iso_id` char(2) default NULL,
  `lng` varchar(9) default NULL,
  `lat` varchar(9) default NULL,
  `state_union_id` int(9) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3121 DEFAULT CHARSET=utf8;

CREATE TABLE `trips` (
  `id` int(11) NOT NULL auto_increment,
  `start_date` date default NULL,
  `end_date` date default NULL,
  `kind` varchar(20) default NULL,
  `state_id` int(11) NOT NULL default '0',
  `politician_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=39604 DEFAULT CHARSET=utf8;

CREATE TABLE `vote_patterns` (
  `id` int(11) NOT NULL auto_increment,
  `politician_id` int(11) default NULL,
  `similar_voter_id` int(11) default NULL,
  `score` float default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32538 DEFAULT CHARSET=utf8;

CREATE TABLE `votes` (
  `id` int(11) NOT NULL auto_increment,
  `politician_id` int(11) NOT NULL default '0',
  `political_group_id` int(11) default NULL,
  `question_id` int(11) NOT NULL default '0',
  `action` int(11) default '0',
  `time` varchar(8) default NULL,
  `group_rebellion` tinyint(1) default NULL,
  `parliament_rebellion` tinyint(1) default NULL,
  `sid` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_votes_on_politician_id` (`politician_id`),
  KEY `index_votes_on_question_id` (`question_id`),
  KEY `index_votes_on_sid` (`sid`)
) ENGINE=MyISAM AUTO_INCREMENT=3105540 DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20080904122525');

INSERT INTO schema_migrations (version) VALUES ('20080904125112');

INSERT INTO schema_migrations (version) VALUES ('20080907164138');

INSERT INTO schema_migrations (version) VALUES ('20080916042144');

INSERT INTO schema_migrations (version) VALUES ('20080916050327');

INSERT INTO schema_migrations (version) VALUES ('20080916161324');

INSERT INTO schema_migrations (version) VALUES ('20080918070058');

INSERT INTO schema_migrations (version) VALUES ('20080918104039');

INSERT INTO schema_migrations (version) VALUES ('20080918111430');

INSERT INTO schema_migrations (version) VALUES ('20080919090740');

INSERT INTO schema_migrations (version) VALUES ('20080925105411');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');