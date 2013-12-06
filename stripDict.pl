#!/usr/bin/perl -ni

	/(\S+)\s+(.*)$/;
	$word = uc($1); $pron = $2;

# strip numbers from phones
	$pron =~ s/[0-9]//g;
	print "$word\t\t\t$pron\n";


