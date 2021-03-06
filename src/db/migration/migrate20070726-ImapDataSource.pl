#!/usr/bin/perl
# 
# SPDX-FileCopyrightText: 2021 Synacor, Inc.
#
# SPDX-License-Identifier: GPL-2.0-only
# 


use strict;
use Migrate;

Migrate::verifySchemaVersion(45);
foreach my $group (Migrate::getMailboxGroups()) {
    createImapDataSourceTables($group);
}
Migrate::updateSchemaVersion(45, 46);

exit(0);

#####################

sub createImapDataSourceTables($) {
  my ($group) = @_;

  my $sql = <<CREATE_TABLE_EOF;
CREATE TABLE $group.imap_folder (
   mailbox_id         INTEGER UNSIGNED NOT NULL,
   item_id            INTEGER UNSIGNED NOT NULL,
   data_source_id     CHAR(36) NOT NULL,
   local_path         VARCHAR(1000) NOT NULL,
   remote_path        VARCHAR(1000) NOT NULL,

   PRIMARY KEY (mailbox_id, item_id),
   CONSTRAINT fk_imap_folder_mailbox_id FOREIGN KEY (mailbox_id) REFERENCES zimbra.mailbox(id) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE $group.imap_message (
   mailbox_id     INTEGER UNSIGNED NOT NULL,
   imap_folder_id INTEGER UNSIGNED NOT NULL,
   uid            BIGINT NOT NULL,
   item_id        INTEGER UNSIGNED NOT NULL,

   PRIMARY KEY (mailbox_id, item_id),
   CONSTRAINT fk_imap_message_mailbox_id FOREIGN KEY (mailbox_id)
      REFERENCES zimbra.mailbox(id) ON DELETE CASCADE,
   CONSTRAINT fk_imap_message_imap_folder_id FOREIGN KEY (mailbox_id, imap_folder_id)
      REFERENCES $group.imap_folder(mailbox_id, item_id) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE UNIQUE INDEX i_uid_imap_id ON $group.imap_message (mailbox_id, imap_folder_id, uid);
CREATE_TABLE_EOF

  Migrate::runSql($sql);
}
