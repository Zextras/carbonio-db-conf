#!/usr/bin/perl
#
# SPDX-FileCopyrightText: 2021 Synacor, Inc.
#
# SPDX-License-Identifier: GPL-2.0-only
#


use strict;
use Migrate;

Migrate::verifySchemaVersion(33);
foreach my $dbName (Migrate::getMailboxGroups()) {

    my $sql = <<CHECK_VALUES;
SELECT mailbox_id, item_id
FROM $dbName.appointment
GROUP BY mailbox_id, item_id
HAVING COUNT(*) > 1;
CHECK_VALUES

    my @results = Migrate::runSql($sql);
    if (scalar(@results) == 0) {
        Migrate::log("Creating unique index on $dbName.appointment");
	createUniqueIndex($dbName);
    } else {
        Migrate::log("Warning: found duplicate item_id values in $dbName.appointment.\n" .
	      "Unable to create unique index.");
    }
}
Migrate::updateSchemaVersion(33, 34);

exit(0);

#####################

#
# Updates the index on appointment(mailbox_id, item_id) to be
# unique.  Also drops/recreates the foreign key, since the
# index drop will fail if it exists.  Disables foreign key
# constraint checking in case there are dangling references
# in the appointment table.
#
sub createUniqueIndex($) {
  my ($dbName) = @_;

  my $sql = <<CREATE_INDEX_EOF;

ALTER TABLE $dbName.appointment DROP FOREIGN KEY fk_appointment_item_id;
DROP INDEX i_item_id ON $dbName.appointment;

CREATE UNIQUE INDEX i_item_id ON $dbName.appointment (mailbox_id, item_id);

SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE $dbName.appointment
ADD CONSTRAINT fk_appointment_item_id FOREIGN KEY (mailbox_id, item_id)
  REFERENCES $dbName.mail_item(mailbox_id, id) ON DELETE CASCADE;

SET FOREIGN_KEY_CHECKS = 1;
CREATE_INDEX_EOF

  Migrate::runSql($sql);
}
