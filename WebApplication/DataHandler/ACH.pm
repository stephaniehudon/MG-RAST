package DataHandler::ACH;

# DataHandler::ACH - data handler to the ACH database



use strict;
#use warnings;

use base qw( DataHandler );

use DBMaster;
use DBrtns;
use Global_Config;


=pod

=head1 NAME

DataHandler::ACH - data handler to the PPO ACH database

=head1 DESCRIPTION

This module returns the DBMaster object to the ACH database stored in the root
job directory of a ACH server. It requires the Global_Config.pm to specify the  
$rast_jobs directory.

Refer to WebApplication/DataHandler.pm for the full documentation.

=head1 METHODS

=over 4

=item * B<handle> ()

Returns the enclosed data handle. Returns undef if it fails to open the Jobs database

=cut

sub handle {
  
  unless (exists $_[0]->{_handle}) {
    
    my $user    = "";
    my $db      = "";
    my $dbhost  = "";
    my $backend = "";
    my $dbport  = "";
    my $dbsock  = "";
    my $dbpass  = "";
    
    defined($dbhost) ? $dbhost : $Global_Config::dbhost;
    $dbsock = defined($dbsock) ? $dbsock : $Global_Config::dbsock;
    my $type    = "SQL";  # use type to select the access methods
    
    if ($WebConfig::ACHDB){
      $user    = $WebConfig::ACHUSER      || "seed" ; 
      $dbpass  = $WebConfig::ACHDBPASS    || "" ;
      $db      = $WebConfig::ACHDB;
      $dbhost  = $WebConfig::ACHDBHOST;
      $backend = $WebConfig::ACHDBBACKEND || "MySQL";
      $type    = $WebConfig::ACHDBPTYPE   if  ($WebConfig::ACHDBTYPE);
      $dbsock  = $WebConfig::ACHDBSOCK    if ($WebConfig::ACHDBSOCK);
      $dbport  = $WebConfig::ACHDBPORT    if ($WebConfig::ACHDBPORT);
    }
    elsif ($Global_Config::ACHDB) {
      $user    = $Global_Config::ACHUSER      || "seed" ;
      $dbpass  = $Global_Config::ACHDBPASS    || "" ;
      $db      = $Global_Config::ACHDB;
      $dbhost  = $Global_Config::ACHDBHOST;
      $backend = $Global_Config::ACHDBBACKEND || "MySQL";
      $type    = $Global_Config::ACHDBPTYPE   if  ($Global_Config::ACHDBTYPE);
      $dbsock  = $Global_Config::ACHDBSOCK    if ($Global_Config::ACHDBSOCK);
      $dbport  = $Global_Config::ACHDBPORT    if ($Global_Config::ACHDBPORT);

    }
    else{
      	warn "Unable to read DataHandler::ACH database: can't find Global_Config.pm or ACH.pm\n";
	return undef;
    }

    if ($type eq "PPO"){
      
      eval {
	$_[0]->{_handle} = DBMaster->new( -database => $db,
					  -host     => $dbhost,
					  -user     => $user,
					  -backend  => $backend,
					);
      };
      
      
    }
    else{
      # probably a fig db
      $_[0]->{_handle} = new DBrtns( lc($backend),$db,$user,$dbpass,$dbport, $dbhost, $dbsock);
      
    }
    
    
    if ($@) {
      warn "Unable to read DataHandler::ACH : $@\n";
      $_[0]->{_handle} = undef;
    }
  }
  return $_[0]->{_handle};
}

1;