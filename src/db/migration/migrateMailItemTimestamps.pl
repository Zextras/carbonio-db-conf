#!/usr/bin/perl
# 
# SPDX-FileCopyrightText: 2021 Synacor, Inc.
#
# SPDX-License-Identifier: GPL-2.0-only
# 

use strict;

#############

my $MYSQL = "mysql";
my $ROOT_USER = "root";
my $ROOT_PASSWORD = "liquid";
my $LIQUID_USER = "liquid";
my $LIQUID_PASSWORD = "liquid";
my $PASSWORD = "liquid";
my $DATABASE = "liquid";

#############

my @mailboxIds = runSql($LIQUID_USER,
			$LIQUID_PASSWORD,
			"SELECT id FROM mailbox ORDER BY id");

printLog("Found " . scalar(@mailboxIds) . " mailbox databases.");

my $id;
foreach $id (@mailboxIds) {
    alterTable($id);
    updateTimestamps($id);
}

exit(0);

#############


sub alterTable($)
{
    my ($mailboxId) = @_;
    my $dbName = "mailbox" . $mailboxId;
	
    my $sql = <<ALTER_TABLE_EOF;

ALTER TABLE $dbName.mail_item
CHANGE date date_old DATETIME NULL AFTER metadata,
CHANGE modified modified_old DATETIME NULL AFTER metadata,
ADD COLUMN date BIGINT UNSIGNED NOT NULL AFTER folder_id,
ADD COLUMN modified BIGINT UNSIGNED NOT NULL AFTER metadata;

ALTER_TABLE_EOF

    printLog("Altering date and modified columns in $dbName.mail_item.");
    runSql($ROOT_USER, $ROOT_PASSWORD, $sql);
}

sub updateTimestamps($)
{
    my ($mailboxId) = @_;
    my $dbName = "mailbox" . $mailboxId;
    my $sql = <<UPDATE_TIMESTAMPS_EOF;

UPDATE $dbName.mail_item
SET date = UNIX_TIMESTAMP(date_old) * 1000, modified = UNIX_TIMESTAMP(modified_old) * 1000;

UPDATE_TIMESTAMPS_EOF

    printLog("Updating timestamp data in $dbName.mail_item.");
    runSql($ROOT_USER, $ROOT_PASSWORD, $sql);
}	

sub runSql($$$)
{
    my ($user, $password, $script) = @_;

    # Write the last script to a text file for debugging
    # open(LASTSCRIPT, ">lastScript.sql") || die "Could not open lastScript.sql";
    # print(LASTSCRIPT $script);
    # close(LASTSCRIPT);

    # Run the mysql command and redirect output to a temp file
    my $tempFile = "mysql.out";
    my $command = "$MYSQL --user=$user --password=$password " .
        "--database=$DATABASE --batch --skip-column-names";
    open(MYSQL, "| $command > $tempFile") || die "Unable to run $command";
    print(MYSQL $script);
    close(MYSQL);

    if ($? != 0) {
        die "Error while running '$command'.";
    }

    # Process output
    open(OUTPUT, $tempFile) || die "Could not open $tempFile";
    my @output;
    while (<OUTPUT>) {
        s/\s+$//;
        push(@output, $_);
    }

    return @output;
}

sub printLog
{
    print scalar(localtime()), ": ", @_, "\n";
}
