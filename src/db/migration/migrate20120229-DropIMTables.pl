#!/usr/bin/perl
# 
# SPDX-FileCopyrightText: 2021 Synacor, Inc.
#
# SPDX-License-Identifier: GPL-2.0-only
# 

use strict;
use Migrate;

Migrate::verifySchemaVersion(88);

#
# drop the IM tables if exist
#
my $sql = <<_SQL_;

USE zimbra;

DROP TABLE IF EXISTS jiveUserProp;

DROP TABLE IF EXISTS jiveGroupProp;

DROP TABLE IF EXISTS jiveGroupUser;

DROP TABLE IF EXISTS jivePrivate;

DROP TABLE IF EXISTS jiveOffline;

DROP TABLE IF EXISTS jiveRoster;

DROP TABLE IF EXISTS jiveRosterGroups;

DROP TABLE IF EXISTS jiveVCard;

DROP TABLE IF EXISTS jiveID;

DROP TABLE IF EXISTS jiveProperty;

DROP TABLE IF EXISTS jiveVersion;

DROP TABLE IF EXISTS jiveExtComponentConf;

DROP TABLE IF EXISTS jiveRemoteServerConf;

DROP TABLE IF EXISTS jivePrivacyList;

DROP TABLE IF EXISTS jiveSASLAuthorized;

DROP TABLE IF EXISTS mucRoom;

DROP TABLE IF EXISTS mucRoomProp;

DROP TABLE IF EXISTS mucAffiliation;

DROP TABLE IF EXISTS mucMember;

DROP TABLE IF EXISTS mucConversationLog;

_SQL_

Migrate::runSql($sql);

Migrate::updateSchemaVersion(88, 89);

exit(0);
