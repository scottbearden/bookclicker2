-- MySQL dump 10.13  Distrib 5.7.33, for Linux (x86_64)
--
-- Host: bc-prod-recovery.cdb858rp5ril.us-east-1.rds.amazonaws.com    Database: bookclicker
-- ------------------------------------------------------
-- Server version	5.7.38-log

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
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED='';

--
-- Table structure for table `api_keys`
--

DROP TABLE IF EXISTS `api_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `platform` varchar(255) NOT NULL,
  `account_id` int(11) DEFAULT NULL,
  `api_dc` varchar(255) DEFAULT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `encrypted_token` varchar(255) DEFAULT NULL,
  `encrypted_token_iv` varchar(255) DEFAULT NULL,
  `encrypted_secret` varchar(255) DEFAULT NULL,
  `encrypted_secret_iv` varchar(255) DEFAULT NULL,
  `encrypted_key` varchar(2048) DEFAULT NULL,
  `encrypted_key_iv` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_api_keys_on_platform` (`platform`),
  KEY `index_api_keys_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_32c28d0dc2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3503 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_requests`
--

DROP TABLE IF EXISTS `api_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `request_url` varchar(255) DEFAULT NULL,
  `response_status` int(11) DEFAULT NULL,
  `response_data` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ar_internal_metadata`
--

DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `assistant_invites`
--

DROP TABLE IF EXISTS `assistant_invites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assistant_invites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_user_id` int(11) NOT NULL,
  `pen_name` varchar(255) DEFAULT NULL,
  `invitee_email` varchar(255) NOT NULL,
  `invite_sent_at` datetime DEFAULT NULL,
  `assistant_created_at` datetime DEFAULT NULL,
  `assistant_user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_assistant_invites_on_member_user_id` (`member_user_id`),
  KEY `index_assistant_invites_on_invitee_email` (`invitee_email`)
) ENGINE=InnoDB AUTO_INCREMENT=225 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `assistant_payment_requests`
--

DROP TABLE IF EXISTS `assistant_payment_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assistant_payment_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `users_assistant_id` int(11) NOT NULL,
  `pay_amount` int(11) NOT NULL,
  `accepted_at` datetime DEFAULT NULL,
  `stripe_subscription_id` varchar(255) DEFAULT NULL,
  `subscription_plan_id` int(11) DEFAULT NULL,
  `declined_at` datetime DEFAULT NULL,
  `agreement_cancelled_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `last_known_subscription_status` varchar(255) DEFAULT NULL,
  `last_known_subscription_status_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_on_whatever` (`users_assistant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `book_links`
--

DROP TABLE IF EXISTS `book_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `book_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `book_id` int(11) DEFAULT NULL,
  `website_name` varchar(255) NOT NULL,
  `link_url` varchar(255) NOT NULL,
  `link_caption` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_book_links_on_book_id` (`book_id`),
  CONSTRAINT `fk_rails_0878f4071d` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20798 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `books`
--

DROP TABLE IF EXISTS `books`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `books` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `pen_name_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `format` varchar(255) DEFAULT NULL,
  `price` decimal(7,2) DEFAULT NULL,
  `launch_date` date DEFAULT NULL,
  `cover_image_url` varchar(255) DEFAULT NULL,
  `blurb` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `amazon_author` varchar(255) DEFAULT NULL,
  `review_count` int(11) DEFAULT NULL,
  `avg_review` decimal(2,1) DEFAULT NULL,
  `pub_date` date DEFAULT NULL,
  `book_rank` int(11) DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_books_on_user_id_and_updated_at` (`user_id`,`updated_at`),
  KEY `index_books_on_user_id_and_pen_name_id` (`user_id`,`pen_name_id`),
  KEY `index_books_on_user_id_and_deleted` (`user_id`,`deleted`),
  CONSTRAINT `fk_rails_bc582ddd02` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19501 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `campaigns`
--

DROP TABLE IF EXISTS `campaigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaigns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `platform_id` varchar(255) NOT NULL,
  `list_id` int(11) NOT NULL,
  `sent_on` date NOT NULL,
  `sent_at` datetime DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `emails_sent` int(11) NOT NULL,
  `open_rate` decimal(5,4) DEFAULT NULL,
  `click_rate` decimal(5,4) DEFAULT NULL,
  `subject` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `preview_url` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_campaigns_on_list_id_and_platform_id` (`list_id`,`platform_id`),
  KEY `index_campaigns_on_list_id_and_sent_on` (`list_id`,`sent_on`)
) ENGINE=InnoDB AUTO_INCREMENT=794942 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `connect_payments`
--

DROP TABLE IF EXISTS `connect_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connect_payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reservation_id` int(11) NOT NULL,
  `charge_id` varchar(255) NOT NULL,
  `destination_acct_id` varchar(255) NOT NULL,
  `amount` int(11) DEFAULT NULL,
  `currency` varchar(255) DEFAULT NULL,
  `application_fee` varchar(255) DEFAULT NULL,
  `application` varchar(255) DEFAULT NULL,
  `paid` tinyint(4) DEFAULT NULL,
  `refunded` tinyint(4) NOT NULL DEFAULT '0',
  `card_id` varchar(255) DEFAULT NULL,
  `last4` varchar(255) DEFAULT NULL,
  `funding` varchar(255) DEFAULT NULL,
  `exp_month` smallint(6) DEFAULT NULL,
  `exp_year` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `stripe_payment_intent_id` int(11) DEFAULT NULL,
  `application_fee_amount` int(11) DEFAULT NULL,
  `destination_charge` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_connect_payments_on_charge_id` (`charge_id`),
  KEY `index_connect_payments_on_reservation_id` (`reservation_id`),
  KEY `index_connect_payments_on_stripe_payment_intent_id` (`stripe_payment_intent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=29868 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `connect_refunds`
--

DROP TABLE IF EXISTS `connect_refunds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connect_refunds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `refund_id` varchar(255) NOT NULL,
  `amount` int(11) NOT NULL,
  `balance_transaction` varchar(255) DEFAULT NULL,
  `charge_id` varchar(255) NOT NULL,
  `currency` varchar(255) DEFAULT NULL,
  `metadata` text,
  `status` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_connect_refunds_on_charge_id` (`charge_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1401 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `conversation_user_pen_names`
--

DROP TABLE IF EXISTS `conversation_user_pen_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `conversation_user_pen_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `conversation_id` int(11) NOT NULL,
  `receipt_id` int(11) NOT NULL,
  `receipt_pen_name_id` int(11) NOT NULL,
  `sender_pen_name_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_conversation_user_pen_names_on_conversation_id` (`conversation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=31302 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `emails`
--

DROP TABLE IF EXISTS `emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `email_address` varchar(255) NOT NULL,
  `mailer` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_emails_on_user_id_and_mailer_and_created_at` (`user_id`,`mailer`,`created_at`),
  KEY `index_emails_on_user_id_and_email_address_and_mailer` (`user_id`,`email_address`,`mailer`),
  KEY `index_emails_on_email_address_and_mailer` (`email_address`,`mailer`)
) ENGINE=InnoDB AUTO_INCREMENT=1118003 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `external_reservations`
--

DROP TABLE IF EXISTS `external_reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `external_reservations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `list_id` int(11) NOT NULL,
  `recorded_list_name` varchar(255) DEFAULT NULL,
  `date` date NOT NULL,
  `book_owner_name` varchar(255) DEFAULT NULL,
  `book_owner_email` varchar(255) DEFAULT NULL,
  `book_title` varchar(255) DEFAULT NULL,
  `book_link` varchar(255) DEFAULT NULL,
  `inv_type` varchar(255) NOT NULL DEFAULT 'mention',
  `campaigns_fetched_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_external_reservations_on_list_id_and_date` (`list_id`,`date`)
) ENGINE=InnoDB AUTO_INCREMENT=89355 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `genres`
--

DROP TABLE IF EXISTS `genres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `genres` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `genre` varchar(255) NOT NULL,
  `category` varchar(255) DEFAULT NULL,
  `search_only` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_genres_on_genre` (`genre`),
  KEY `index_genres_on_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inventories`
--

DROP TABLE IF EXISTS `inventories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `list_id` int(11) DEFAULT NULL,
  `inv_type` varchar(255) NOT NULL,
  `sunday` tinyint(4) NOT NULL DEFAULT '0',
  `monday` tinyint(4) NOT NULL DEFAULT '0',
  `tuesday` tinyint(4) NOT NULL DEFAULT '0',
  `wednesday` tinyint(4) NOT NULL DEFAULT '0',
  `thursday` tinyint(4) NOT NULL DEFAULT '0',
  `friday` tinyint(4) NOT NULL DEFAULT '0',
  `saturday` tinyint(4) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_inventories_on_list_id` (`list_id`),
  CONSTRAINT `fk_rails_c62977819f` FOREIGN KEY (`list_id`) REFERENCES `lists` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8703 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `list_ratings`
--

DROP TABLE IF EXISTS `list_ratings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `list_ratings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `list_id` int(11) NOT NULL,
  `rating` smallint(6) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_list_ratings_on_user_id_and_list_id` (`user_id`,`list_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21660 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `list_subscriptions`
--

DROP TABLE IF EXISTS `list_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `list_subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `list_id` int(11) NOT NULL,
  `reservation_id` int(11) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `opt_in_at` datetime DEFAULT NULL,
  `opt_in_succeeded_at` datetime DEFAULT NULL,
  `opt_in_failed_at` datetime DEFAULT NULL,
  `opt_in_failed_message` varchar(255) DEFAULT NULL,
  `opt_out_at` datetime DEFAULT NULL,
  `opt_out_succeeded_at` datetime DEFAULT NULL,
  `opt_out_failed_at` datetime DEFAULT NULL,
  `opt_out_failed_message` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_list_subscriptions_on_user_id_and_opt_out_at` (`user_id`,`opt_out_at`),
  KEY `index_list_subscriptions_on_user_id_and_list_id` (`user_id`,`list_id`)
) ENGINE=InnoDB AUTO_INCREMENT=49563 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lists`
--

DROP TABLE IF EXISTS `lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `pen_name_id` int(11) DEFAULT NULL,
  `api_key_id` int(11) DEFAULT NULL,
  `platform_id` varchar(255) NOT NULL,
  `platform` varchar(255) NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `adopted_pen_name` varchar(255) DEFAULT NULL,
  `active_member_count` int(11) DEFAULT NULL,
  `open_rate` decimal(5,4) DEFAULT NULL,
  `click_rate` decimal(5,4) DEFAULT NULL,
  `cutoff_date` date DEFAULT NULL,
  `mention_price` int(11) DEFAULT NULL,
  `mention_is_swap_only` tinyint(4) NOT NULL DEFAULT '0',
  `feature_price` int(11) DEFAULT NULL,
  `feature_is_swap_only` tinyint(4) NOT NULL DEFAULT '0',
  `solo_price` int(11) DEFAULT NULL,
  `solo_is_swap_only` tinyint(4) NOT NULL DEFAULT '0',
  `last_refreshed_at` datetime DEFAULT NULL,
  `last_action_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sponsored_tier` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_lists_on_user_id` (`user_id`),
  KEY `index_lists_on_status_and_last_action_at` (`status`,`last_action_at`),
  KEY `index_lists_on_last_refreshed_at` (`last_refreshed_at`),
  KEY `index_lists_on_sponsored_tier_and_last_action_at` (`sponsored_tier`,`last_action_at`),
  CONSTRAINT `fk_rails_d6cf4279f7` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=35473 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lists_genres`
--

DROP TABLE IF EXISTS `lists_genres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lists_genres` (
  `list_id` int(11) NOT NULL,
  `genre_id` int(11) NOT NULL,
  `primary` tinyint(4) NOT NULL DEFAULT '0',
  UNIQUE KEY `index_lists_genres_on_list_id_and_genre_id` (`list_id`,`genre_id`),
  UNIQUE KEY `index_lists_genres_on_genre_id_and_list_id` (`genre_id`,`list_id`),
  KEY `index_lists_genres_on_list_id_and_primary` (`list_id`,`primary`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mailboxer_conversation_opt_outs`
--

DROP TABLE IF EXISTS `mailboxer_conversation_opt_outs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mailboxer_conversation_opt_outs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unsubscriber_type` varchar(255) DEFAULT NULL,
  `unsubscriber_id` int(11) DEFAULT NULL,
  `conversation_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type` (`unsubscriber_id`,`unsubscriber_type`),
  KEY `index_mailboxer_conversation_opt_outs_on_conversation_id` (`conversation_id`),
  CONSTRAINT `mb_opt_outs_on_conversations_id` FOREIGN KEY (`conversation_id`) REFERENCES `mailboxer_conversations` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mailboxer_conversations`
--

DROP TABLE IF EXISTS `mailboxer_conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mailboxer_conversations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) DEFAULT '',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31302 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mailboxer_notifications`
--

DROP TABLE IF EXISTS `mailboxer_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mailboxer_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL,
  `body` text,
  `subject` varchar(255) DEFAULT '',
  `sender_type` varchar(255) DEFAULT NULL,
  `sender_id` int(11) DEFAULT NULL,
  `conversation_id` int(11) DEFAULT NULL,
  `draft` tinyint(1) DEFAULT '0',
  `notification_code` varchar(255) DEFAULT NULL,
  `notified_object_type` varchar(255) DEFAULT NULL,
  `notified_object_id` int(11) DEFAULT NULL,
  `attachment` varchar(255) DEFAULT NULL,
  `updated_at` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `global` tinyint(1) DEFAULT '0',
  `expires` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mailboxer_notifications_notified_object` (`notified_object_type`,`notified_object_id`),
  KEY `index_mailboxer_notifications_on_conversation_id` (`conversation_id`),
  KEY `index_mailboxer_notifications_on_type` (`type`),
  KEY `index_mailboxer_notifications_on_sender_id_and_sender_type` (`sender_id`,`sender_type`),
  KEY `index_mailboxer_notifications_on_notified_object_id_and_type` (`notified_object_id`,`notified_object_type`),
  CONSTRAINT `notifications_on_conversation_id` FOREIGN KEY (`conversation_id`) REFERENCES `mailboxer_conversations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=78772 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mailboxer_receipts`
--

DROP TABLE IF EXISTS `mailboxer_receipts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mailboxer_receipts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `receiver_type` varchar(255) DEFAULT NULL,
  `receiver_id` int(11) DEFAULT NULL,
  `notification_id` int(11) NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `trashed` tinyint(1) DEFAULT '0',
  `deleted` tinyint(1) DEFAULT '0',
  `mailbox_type` varchar(25) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_delivered` tinyint(1) DEFAULT '0',
  `delivery_method` varchar(255) DEFAULT NULL,
  `message_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mailboxer_receipts_on_notification_id` (`notification_id`),
  KEY `index_mailboxer_receipts_on_receiver_id_and_receiver_type` (`receiver_id`,`receiver_type`),
  CONSTRAINT `receipts_on_notification_id` FOREIGN KEY (`notification_id`) REFERENCES `mailboxer_notifications` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=157537 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `one_day_inventories`
--

DROP TABLE IF EXISTS `one_day_inventories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `one_day_inventories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `list_id` int(11) DEFAULT NULL,
  `source` varchar(255) NOT NULL DEFAULT 'automatic',
  `solo` smallint(6) NOT NULL DEFAULT '0',
  `feature` smallint(6) NOT NULL DEFAULT '0',
  `mention` smallint(6) NOT NULL DEFAULT '0',
  `date` date NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_one_day_inventories_on_list_id_and_date` (`list_id`,`date`),
  KEY `index_one_day_inventories_on_list_id` (`list_id`),
  CONSTRAINT `fk_rails_fe401e51b7` FOREIGN KEY (`list_id`) REFERENCES `lists` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=323968 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `password_tokens`
--

DROP TABLE IF EXISTS `password_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `password_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_password_tokens_on_token` (`token`)
) ENGINE=InnoDB AUTO_INCREMENT=901 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pen_name_requests`
--

DROP TABLE IF EXISTS `pen_name_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pen_name_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `requestor_id` int(11) NOT NULL,
  `pen_name_id` int(11) NOT NULL,
  `owner_notified_at` datetime DEFAULT NULL,
  `owner_decision` varchar(255) DEFAULT NULL,
  `owner_decided_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pen_name_requests_on_requestor_id_and_pen_name_id` (`requestor_id`,`pen_name_id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pen_names`
--

DROP TABLE IF EXISTS `pen_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pen_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `group_status` varchar(255) DEFAULT NULL,
  `author_profile_url` varchar(255) DEFAULT NULL,
  `author_name` varchar(255) NOT NULL,
  `author_image` varchar(255) DEFAULT NULL,
  `verified` tinyint(4) NOT NULL DEFAULT '0',
  `promo_service_only` tinyint(4) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_pen_names_on_user_id_and_promo_service_only` (`user_id`,`promo_service_only`),
  KEY `index_pen_names_on_author_name_and_verified` (`author_name`,`verified`)
) ENGINE=InnoDB AUTO_INCREMENT=2887 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `promo_send_confirmations`
--

DROP TABLE IF EXISTS `promo_send_confirmations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promo_send_confirmations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reservation_id` int(11) NOT NULL,
  `reservation_type` varchar(255) NOT NULL DEFAULT 'Reservation',
  `campaign_id` int(11) DEFAULT NULL,
  `campaign_preview_url` varchar(255) DEFAULT NULL,
  `seller_confirmed_at` datetime DEFAULT NULL,
  `buyer_confirmed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_promo_send_confirmations_on_reservation_id` (`reservation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=339065 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `promos`
--

DROP TABLE IF EXISTS `promos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `book_id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `list_size` int(11) NOT NULL,
  `date` date NOT NULL,
  `promo_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_promos_on_uuid` (`uuid`),
  KEY `index_promos_on_book_id` (`book_id`),
  KEY `index_promos_on_book_id_and_date` (`book_id`,`date`),
  CONSTRAINT `fk_rails_a55737134d` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `proxies`
--

DROP TABLE IF EXISTS `proxies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proxies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reservations`
--

DROP TABLE IF EXISTS `reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reservations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `list_id` int(11) NOT NULL,
  `recorded_list_name` varchar(255) DEFAULT NULL,
  `book_id` int(11) NOT NULL,
  `seller_notified_at` datetime DEFAULT NULL,
  `buyer_invoiced_at` datetime DEFAULT NULL,
  `seller_accepted_at` datetime DEFAULT NULL,
  `seller_declined_at` datetime DEFAULT NULL,
  `buyer_cancelled_at` datetime DEFAULT NULL,
  `seller_cancelled_at` datetime DEFAULT NULL,
  `seller_cancelled_reason` text,
  `system_cancelled_at` datetime DEFAULT NULL,
  `system_cancelled_reason` varchar(255) DEFAULT NULL,
  `campaigns_fetched_at` datetime DEFAULT NULL,
  `confirmation_requested_at` datetime DEFAULT NULL,
  `refund_requested_at` datetime DEFAULT NULL,
  `dismissed_from_buyer_activity_feed_at` datetime DEFAULT NULL,
  `dismissed_from_buyer_sent_feed_at` datetime DEFAULT NULL,
  `inv_type` varchar(255) NOT NULL,
  `date` date NOT NULL,
  `message` text,
  `reply_message` text,
  `price` int(11) DEFAULT NULL,
  `premium` int(11) DEFAULT NULL,
  `payment_offer` tinyint(4) NOT NULL DEFAULT '1',
  `swap_offer` tinyint(4) NOT NULL DEFAULT '0',
  `swap_offer_list_id` int(11) DEFAULT NULL,
  `swap_offer_solo` tinyint(4) DEFAULT '0',
  `swap_offer_feature` tinyint(4) DEFAULT '0',
  `swap_offer_mention` tinyint(4) DEFAULT '0',
  `swap_reservation_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_reservations_on_list_id_and_book_id` (`list_id`,`book_id`),
  KEY `index_reservations_on_book_id_and_list_id` (`book_id`,`list_id`),
  KEY `index_reservations_on_list_id_and_date` (`list_id`,`date`),
  KEY `index_reservations_on_book_id_and_created_at` (`book_id`,`created_at`),
  KEY `index_reservations_on_list_id_and_seller_accepted_at` (`list_id`,`seller_accepted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=781079 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stripe_accounts`
--

DROP TABLE IF EXISTS `stripe_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stripe_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `acct_id` varchar(255) NOT NULL,
  `deferred_acct_email` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `deleted` tinyint(4) NOT NULL DEFAULT '0',
  `publishable_key` varchar(255) DEFAULT NULL,
  `refresh_token` varchar(255) DEFAULT NULL,
  `access_token` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_stripe_accounts_on_acct_id` (`acct_id`),
  KEY `idx_stripe_accounts_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=453 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stripe_card_errors`
--

DROP TABLE IF EXISTS `stripe_card_errors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stripe_card_errors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reservation_id` int(11) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `card` varchar(255) DEFAULT NULL,
  `charge` varchar(255) DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `error_type` varchar(255) DEFAULT NULL,
  `error_code` varchar(255) DEFAULT NULL,
  `decline_code` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2900 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stripe_customers`
--

DROP TABLE IF EXISTS `stripe_customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stripe_customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `destination_stripe_account_id` int(11) DEFAULT NULL,
  `default_source` varchar(255) DEFAULT NULL,
  `cus_id` varchar(255) NOT NULL,
  `currency` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `deleted` tinyint(4) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stripe_payment_intents`
--

DROP TABLE IF EXISTS `stripe_payment_intents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stripe_payment_intents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reservation_id` int(11) NOT NULL,
  `customer_id` varchar(255) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `currency` varchar(255) DEFAULT NULL,
  `intent_id` varchar(255) NOT NULL,
  `payment_method` varchar(255) DEFAULT NULL,
  `application_fee_amount` int(11) DEFAULT NULL,
  `return_url` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_stripe_payment_intents_on_intent_id` (`intent_id`),
  KEY `index_stripe_payment_intents_on_reservation_id` (`reservation_id`),
  CONSTRAINT `fk_rails_537ef0306e` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12380 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stripe_requires_action_events`
--

DROP TABLE IF EXISTS `stripe_requires_action_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stripe_requires_action_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `current_user_id` int(11) DEFAULT NULL,
  `stripe_object_id` varchar(255) DEFAULT NULL,
  `next_action` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stripe_setup_intents`
--

DROP TABLE IF EXISTS `stripe_setup_intents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stripe_setup_intents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `customer_id` varchar(255) DEFAULT NULL,
  `intent_id` varchar(255) NOT NULL,
  `payment_method` varchar(255) DEFAULT NULL,
  `return_url` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL,
  `usage` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_stripe_setup_intents_on_intent_id` (`intent_id`),
  KEY `index_stripe_setup_intents_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_f6dbcf85b7` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3816 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stripe_shared_customer_sources`
--

DROP TABLE IF EXISTS `stripe_shared_customer_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stripe_shared_customer_sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stripe_shared_customer_id` int(11) NOT NULL,
  `deleted` tinyint(4) NOT NULL DEFAULT '0',
  `default` tinyint(4) DEFAULT NULL,
  `card_id` varchar(255) NOT NULL,
  `last4` varchar(255) DEFAULT NULL,
  `cvc_check` varchar(255) DEFAULT NULL,
  `exp_month` smallint(6) DEFAULT NULL,
  `exp_year` int(11) DEFAULT NULL,
  `brand` varchar(255) DEFAULT NULL,
  `funding` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `address_line1` varchar(255) DEFAULT NULL,
  `address_line2` varchar(255) DEFAULT NULL,
  `address_city` varchar(255) DEFAULT NULL,
  `address_state` varchar(255) DEFAULT NULL,
  `address_zip` varchar(255) DEFAULT NULL,
  `address_zip_check` varchar(255) DEFAULT NULL,
  `address_country` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_193` (`stripe_shared_customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1158 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stripe_shared_customers`
--

DROP TABLE IF EXISTS `stripe_shared_customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stripe_shared_customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `customer_id` varchar(255) NOT NULL,
  `deleted` tinyint(4) NOT NULL DEFAULT '0',
  `email_address` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_shared_stripe` (`user_id`,`deleted`),
  KEY `index_stripe_shared_customers_on_customer_id` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=819 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stripe_webhook_events`
--

DROP TABLE IF EXISTS `stripe_webhook_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stripe_webhook_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data` text,
  `event_type` varchar(255) DEFAULT NULL,
  `account` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27440 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscription_plans`
--

DROP TABLE IF EXISTS `subscription_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription_plans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `stripe_acct_id` varchar(255) DEFAULT NULL,
  `stripe_plan_id` varchar(255) DEFAULT NULL,
  `interval` varchar(255) DEFAULT NULL,
  `currency` varchar(255) NOT NULL,
  `amount` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_subscription_plans_on_amount` (`amount`),
  KEY `index_subscription_plans_on_stripe_plan_id` (`stripe_plan_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_events`
--

DROP TABLE IF EXISTS `user_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `event` varchar(255) NOT NULL,
  `event_detail` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_events_on_user_id_and_event_and_event_detail` (`user_id`,`event`,`event_detail`)
) ENGINE=InnoDB AUTO_INCREMENT=4326 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role` tinyint(4) NOT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` datetime DEFAULT NULL,
  `bookings_subscribed` tinyint(4) NOT NULL DEFAULT '1',
  `messages_subscribed` tinyint(4) DEFAULT '1',
  `confirmations_subscribed` tinyint(4) NOT NULL DEFAULT '1',
  `auto_subscribe_on_booking` tinyint(4) NOT NULL DEFAULT '0',
  `auto_subscribe_email` varchar(255) DEFAULT NULL,
  `password_digest` varchar(255) NOT NULL,
  `session_token` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `closed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_session_token` (`session_token`),
  KEY `index_users_on_role` (`role`),
  KEY `index_users_on_last_name_and_first_name` (`last_name`,`first_name`)
) ENGINE=InnoDB AUTO_INCREMENT=3438 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users_assistants`
--

DROP TABLE IF EXISTS `users_assistants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_assistants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `assistant_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_assistants_on_user_id_and_assistant_id` (`user_id`,`assistant_id`),
  UNIQUE KEY `index_users_assistants_on_assistant_id_and_user_id` (`assistant_id`,`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=553 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users_pen_names`
--

DROP TABLE IF EXISTS `users_pen_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_pen_names` (
  `user_id` int(11) NOT NULL,
  `pen_name_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  UNIQUE KEY `index_users_pen_names_on_user_id_and_pen_name_id` (`user_id`,`pen_name_id`),
  UNIQUE KEY `index_users_pen_names_on_pen_name_id_and_user_id` (`pen_name_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `versions`
--

DROP TABLE IF EXISTS `versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_type` varchar(255) NOT NULL,
  `item_id` int(11) NOT NULL,
  `event` varchar(255) NOT NULL,
  `whodunnit` varchar(255) DEFAULT NULL,
  `object` longtext,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_versions_on_item_type_and_item_id` (`item_type`,`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=843 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'bookclicker'
--
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-01-28 20:10:37
INSERT INTO `schema_migrations` (version) VALUES
('20170425052513'),
('20170426181803'),
('20170427025252'),
('20170427201549'),
('20170428160514'),
('20170501181612'),
('20170501184507'),
('20170504150957'),
('20170504155325'),
('20170510022412'),
('20170516014027'),
('20170516065357'),
('20170516201833'),
('20170517222337'),
('20170517235330'),
('20170519155851'),
('20170519160017'),
('20170521030618'),
('20170522041041'),
('20170523205127'),
('20170523205433'),
('20170525180001'),
('20170529150227'),
('20170529230150'),
('20170530184111'),
('20170601141455'),
('20170602015647'),
('20170602021219'),
('20170602161459'),
('20170603040742'),
('20170604163509'),
('20170605034533'),
('20170613152441'),
('20170614012523'),
('20170614020451'),
('20170614162333'),
('20170616214738'),
('20170616220327'),
('20170616231724'),
('20170617145013'),
('20170618060728'),
('20170618203943'),
('20170619221436'),
('20170621230624'),
('20170622170130'),
('20170622174235'),
('20170627215816'),
('20170628051824'),
('20170629214248'),
('20170703191728'),
('20170705181231'),
('20170706204628'),
('20170710043125'),
('20170710055246'),
('20170711223202'),
('20170712055833'),
('20170713224820'),
('20170714004326'),
('20170718004737'),
('20170718065247'),
('20170718231135'),
('20170719044327'),
('20170719215255'),
('20170719221847'),
('20170719223846'),
('20170720041518'),
('20170720064234'),
('20170720205447'),
('20170720215906'),
('20170720224514'),
('20170721033245'),
('20170721040459'),
('20170721145155'),
('20170721194606'),
('20170724165707'),
('20170724191856'),
('20170724195830'),
('20170725173607'),
('20170726031933'),
('20170726210924'),
('20170728000525'),
('20170728181405'),
('20170728190020'),
('20170729012332'),
('20170730172151'),
('20170731101453'),
('20170801181227'),
('20170802001200'),
('20170802003704'),
('20170802112058'),
('20170803192224'),
('20170804150514'),
('20170804192119'),
('20170805210536'),
('20170805215010'),
('20170807110949'),
('20170808203629'),
('20170809152023'),
('20170809162757'),
('20170809224424'),
('20170811102240'),
('20170811200046'),
('20170812133006'),
('20170813172104'),
('20170814082547'),
('20170814091952'),
('20170814092350'),
('20170815065136'),
('20170815111551'),
('20170815120636'),
('20170815125544'),
('20170815131529'),
('20170815153930'),
('20170815161647'),
('20170815211514'),
('20170816121325'),
('20170817141618'),
('20170817204156'),
('20170820162256'),
('20170821154630'),
('20170821160605'),
('20170822090307'),
('20170823120932'),
('20170824075002'),
('20170824103243'),
('20170825170737'),
('20170827092631'),
('20170830135708'),
('20170901112710'),
('20171106224616'),
('20171209222841'),
('20171225154040'),
('20171229223934'),
('20171231202924'),
('20171231213720'),
('20180101230502'),
('20180308144240'),
('20180323171343'),
('20180506185747'),
('20180506185748'),
('20180506185749'),
('20180506185750'),
('20180508214837'),
('20180510044222'),
('20180511173920'),
('20180603022726'),
('20180603023816'),
('20180603034716'),
('20191228233832'),
('20191230034255'),
('20200504012649'),
('20200509145342'),
('20200509145733'),
('20200509194903'),
('20200511003513'),
('20200611162343'),
('20200614183924'),
('20200614235220');


