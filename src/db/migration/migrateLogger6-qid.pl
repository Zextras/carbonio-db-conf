#!/usr/bin/perl
# 
# SPDX-FileCopyrightText: 2021 Synacor, Inc.
#
# SPDX-License-Identifier: GPL-2.0-only
# 


use strict;
use Migrate;


Migrate::verifyLoggerSchemaVersion(5);

modifyQID();

Migrate::updateLoggerSchemaVersion(5,6);

exit(0);

#####################

sub modifyQID() {
    Migrate::log("Modifying postfix_qid size");

	my $sql = <<EOF;
alter table raw_logs modify postfix_qid VARCHAR(25);
alter table mta modify qid VARCHAR(25);
EOF

    Migrate::runLoggerSql($sql);
}
