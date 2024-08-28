-- MySQL dump 10.11
--
-- Host: localhost    Database: suse_netsimlin
-- ------------------------------------------------------
-- Server version	5.0.77

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ram`
--

DROP TABLE IF EXISTS `ram`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `ram` (
  `hostname` varchar(20) NOT NULL,
  `ram` varchar(20) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `suse_netsimlin`
--

DROP TABLE IF EXISTS `suse_netsimlin`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `suse_netsimlin` (
  `hostname` varchar(17) default NULL,
  `ip_address` varchar(17) NOT NULL,
  `mac_address` varchar(20) NOT NULL default '',
  `memory` varchar(15) NOT NULL default '',
  `generation` tinyint(4) NOT NULL default '0',
  `disk_type` varchar(20) NOT NULL default '',
  `disk_num` tinyint(4) NOT NULL default '0',
  `arch` varchar(35) NOT NULL,
  `cpu_num` tinyint(4) NOT NULL default '0',
  `ip_address_range_1` varchar(15) NOT NULL default '',
  `ip_address_range_2` varchar(15) NOT NULL default '',
  `ip_address_range_3` varchar(15) NOT NULL default '',
  `ip_address_range_4` varchar(15) NOT NULL default '',
  `ip_address_range_5` varchar(15) NOT NULL,
  `ip_address_range_6` varchar(15) NOT NULL,
  `ip_address_range_7` varchar(15) NOT NULL,
  `ip_address_range_8` varchar(15) NOT NULL,
  `ip_address_range_9` varchar(15) NOT NULL,
  `ip_address_range_10` varchar(15) NOT NULL,
  `ip_address_range_11` varchar(15) NOT NULL,
  `ip_address_range_12` varchar(15) NOT NULL,
  `ip_address_range_13` varchar(20) NOT NULL,
  `ip_address_range_14` varchar(20) NOT NULL,
  `ip_address_range_15` varchar(20) NOT NULL,
  `ip_address_range_16` varchar(20) NOT NULL,
  `ip_address_range_17` varchar(20) NOT NULL,
  `ip_address_range_18` varchar(20) NOT NULL,
  `ip_address_range_19` varchar(20) NOT NULL,
  `ip_address_range_20` varchar(20) NOT NULL,
  `hex_ip_address` varchar(20) NOT NULL default '',
  `suse_cfg_file` varchar(80) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-04-28 11:43:53
