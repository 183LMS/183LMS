CREATE TABLE `atable` (
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `inB` bigint(20) unsigned DEFAULT NULL,
  `outB` bigint(20) unsigned DEFAULT NULL,
  `inB_cumulative` bigint(20) unsigned DEFAULT NULL,
  `outB_cumulative` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `btable` (
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `inB` bigint(20) unsigned DEFAULT NULL,
  `outB` bigint(20) unsigned DEFAULT NULL,
  `inB_cumulative` bigint(20) unsigned DEFAULT NULL,
  `outB_cumulative` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `mytable` (
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ping` decimal(7,3) DEFAULT NULL,
  `loss` tinyint(3) unsigned DEFAULT NULL,
  `jitter` decimal(5,3) DEFAULT NULL,
  PRIMARY KEY (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
