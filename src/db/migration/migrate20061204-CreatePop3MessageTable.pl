#!/usr/bin/perl
# 
# SPDX-FileCopyrightText: 2021 Synacor, Inc.
#
# SPDX-License-Identifier: GPL-2.0-only
# 


use strict;
use Migrate;

Migrate::verifySchemaVersion(32);
foreach my $group (Migrate::getMailboxGroups()) {
    createPop3MessageTable($group);
}
Migrate::updateSchemaVersion(32, 33);

exit(0);

#####################

sub createPop3MessageTable($) {
  my ($group) = @_;

  my $sql = <<CREATE_TABLE_EOF;
CREATE TABLE IF NOT EXISTS $group.pop3_message (
   mailbox_id     INTEGER UNSIGNED NOT NULL,
   data_source_id CHAR(36) NOT NULL,
   uid            VARCHAR(255) NOT NULL,
   item_id        INTEGER UNSIGNED NOT NULL,
   
   PRIMARY KEY (mailbox_id, item_id),
   CONSTRAINT fk_pop3_message_mailbox_id FOREIGN KEY (mailbox_id) REFERENCES zimbra.mailbox(id)
) ENGINE = InnoDB;

CREATE UNIQUE INDEX i_uid_pop3_id ON $group.pop3_message (uid, data_source_id);
CREATE_TABLE_EOF

  Migrate::runSql($sql);
}
