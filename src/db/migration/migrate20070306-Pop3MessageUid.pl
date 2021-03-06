#!/usr/bin/perl
# 
# SPDX-FileCopyrightText: 2021 Synacor, Inc.
#
# SPDX-License-Identifier: GPL-2.0-only
# 


use strict;
use Migrate;

Migrate::verifySchemaVersion(36);
foreach my $group (Migrate::getMailboxGroups()) {
    modifyPop3MessageSchema($group);
}
Migrate::updateSchemaVersion(36, 37);

exit(0);

#####################

sub modifyPop3MessageSchema($) {
  my ($group) = @_;

  my $sql = <<MODIFY_POP3_MESSAGE_SCHEMA_EOF;
ALTER TABLE $group.pop3_message
CHANGE uid uid VARCHAR(255) BINARY NOT NULL;
MODIFY_POP3_MESSAGE_SCHEMA_EOF

  Migrate::runSql($sql);
}
