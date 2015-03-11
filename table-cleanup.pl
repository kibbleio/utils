#!/usr/bin/perl

use strict;
use warnings;

unless (@ARGV >= 3) {
    print <<EOF;
Search tables defined in DDL for matching fields, and return SQL DELETE statements
Usage:
  $0 value field_list ddl_files
Examples:
  $0 1 'account_record_id|kb_account_id' killbill-0.13.0.ddl stripe.ddl
  $0 2 'tenant_record_id|search_key2|kb_tenant_id' killbill-0.13.0.ddl stripe.ddl
EOF

    exit(-1);
}

my $value = shift;
my $field = shift;

print STDERR "Generating SQL for $field => $value\n";

my $table;
my %seen;
while (<>) {
    if (/CREATE\s+TABLE\s+(\S+)/i) {
        print STDERR "Not found in $table\n" unless !$table or $seen{$table};
        $table = $1;
    }
    if (/($field)/ and not $seen{$table}++) {
        print "DELETE FROM $table WHERE $1 = '$value'\n";
    }
}
