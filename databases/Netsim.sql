-- MySQL dump 10.11
--
-- Host: localhost    Database: Netsim
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
-- Table structure for table `ArrayInfo`
--

DROP TABLE IF EXISTS `ArrayInfo`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `ArrayInfo` (
  `key` varchar(100) NOT NULL default '',
  `server` varchar(100) NOT NULL default ''
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `BackupInfo`
--

DROP TABLE IF EXISTS `BackupInfo`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `BackupInfo` (
  `email` varchar(50) NOT NULL,
  `Reason` text NOT NULL,
  `Server` varchar(45) NOT NULL,
  `dir` varchar(50) NOT NULL,
  `RequestID` int(11) NOT NULL auto_increment,
  `DateRequested` int(10) unsigned NOT NULL,
  `Performed` tinyint(1) NOT NULL,
  `Approval` enum('PE','NA','AP') NOT NULL,
  KEY `RequestID` (`RequestID`)
) ENGINE=MyISAM AUTO_INCREMENT=88 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `JumpInfo`
--

DROP TABLE IF EXISTS `JumpInfo`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `JumpInfo` (
  `servername` varchar(50) NOT NULL default '',
  `userid` varchar(15) NOT NULL default '',
  `emailaddress` varchar(50) NOT NULL default '',
  `managerid` varchar(15) NOT NULL default '',
  `testtype` varchar(10) NOT NULL default '',
  `netsimversion` varchar(10) NOT NULL default '',
  `date` datetime NOT NULL default '0000-00-00 00:00:00'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `R_version`
--

DROP TABLE IF EXISTS `R_version`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `R_version` (
  `R_version` varchar(6) NOT NULL default ''
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `ServerInfo`
--

DROP TABLE IF EXISTS `ServerInfo`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `ServerInfo` (
  `servername` varchar(50) NOT NULL default '',
  `hostid` varchar(20) NOT NULL default '',
  `ipaddress` varchar(20) NOT NULL default '',
  `macaddress` varchar(20) NOT NULL default '',
  `OSversion` varchar(20) NOT NULL default '',
  `HWtype` varchar(20) NOT NULL default ''
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

-- Dump completed on 2014-04-28 11:42:14
