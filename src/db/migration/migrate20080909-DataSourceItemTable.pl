#!/usr/bin/perl
# 
# SPDX-FileCopyrightText: 2021 Synacor, Inc.
#
# SPDX-License-Identifier: GPL-2.0-only
# 


use strict;
use Migrate;

Migrate::verifySchemaVersion(52);
foreach my $group (Migrate::getMailboxGroups()) {
    createDataSourceItemTable($group);
}
Migrate::updateSchemaVersion(52, 53);

exit(0);

#####################

sub createDataSourceItemTable() {
  my ($group) = @_;
  Migrate::logSql("Creating data_source_item table for ".$group.".");
  
  my $sql = <<CREATE_TABLE_EOF;
CREATE TABLE IF NOT EXISTS $group.data_source_item (
   mailbox_id     INTEGER UNSIGNED NOT NULL,
   data_source_id CHAR(36) NOT NULL,
   item_id        INTEGER UNSIGNED NOT NULL,
   remote_id      VARCHAR(255) BINARY NOT NULL,
   metadata       MEDIUMTEXT,
   
   PRIMARY KEY (mailbox_id, item_id),
   UNIQUE INDEX i_remote_id (mailbox_id, data_source_id, remote_id),   -- for reverse lookup
   CONSTRAINT fk_data_source_item_mailbox_id FOREIGN KEY (mailbox_id) REFERENCES zimbra.mailbox(id) ON DELETE CASCADE
) ENGINE = InnoDB;
CREATE_TABLE_EOF

  Migrate::runSql($sql);
}
