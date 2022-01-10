#!/usr/bin/perl
# 
# SPDX-FileCopyrightText: 2021 Synacor, Inc.
#
# SPDX-License-Identifier: GPL-2.0-only
# 


use strict;
use Migrate;

my @mailboxIds = Migrate::getMailboxIds();
foreach my $id (@mailboxIds) {
    fixZeroChangeIdItems($id);
}

exit(0);

#####################

sub fixZeroChangeIdItems($) {
    my ($mailboxId) = @_;
    my $sql = <<EOF_FIX_ZERO_SEQUENCE_NUMBERS;

UPDATE mailbox$mailboxId.mail_item
SET mod_content = 1
WHERE mod_content = 0;

UPDATE mailbox$mailboxId.mail_item
SET mod_metadata = 1
WHERE mod_metadata = 0;

EOF_FIX_ZERO_SEQUENCE_NUMBERS

    Migrate::runSql($sql);
}
