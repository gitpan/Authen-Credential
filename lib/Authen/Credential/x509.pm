#+##############################################################################
#                                                                              #
# File: Authen/Credential/x509.pm                                              #
#                                                                              #
# Description: abstraction of an X.509 credential                              #
#                                                                              #
#-##############################################################################

#
# module definition
#

package Authen::Credential::x509;
use strict;
use warnings;
our $VERSION  = "0.5";
our $REVISION = sprintf("%d.%02d", q$Revision: 1.3 $ =~ /(\d+)\.(\d+)/);

#
# inheritance
#

our @ISA = qw(Authen::Credential);

#
# used modules
#

use Authen::Credential;
use Params::Validate qw(validate_pos :types);

#
# Params::Validate specification
#

$Authen::Credential::_ValidationSpec{x509} = {
    cert => { type => SCALAR, optional => 1 },
    key  => { type => SCALAR, optional => 1 },
    ca   => { type => SCALAR, optional => 1 },
    pass => { type => SCALAR, optional => 1 },
};

#
# accessors
#

foreach my $name (qw(cert key ca pass)) {
    no strict "refs";
    *$name = sub {
	my($self);
	$self = shift(@_);
	validate_pos(@_) if @_;
	return($self->{$name});
    };
}

#
# preparators
#

$Authen::Credential::_Preparator{x509}{"IO::Socket::SSL"} = sub {
    my($self, %data, $tmp);
    $self = shift(@_);
    validate_pos(@_) if @_;
    foreach $tmp ($self->cert(), $ENV{X509_USER_CERT}) {
	next unless defined($tmp);
	$data{SSL_cert_file} = $tmp;
	last;
    }
    foreach $tmp ($self->key(), $ENV{X509_USER_KEY}) {
	next unless defined($tmp);
	$data{SSL_key_file} = $tmp;
	last;
    }
    foreach $tmp ($self->ca(), $ENV{X509_CERT_DIR}) {
	next unless defined($tmp);
	$data{SSL_ca_path} = $tmp;
	last;
    }
    $data{SSL_passwd_cb} = sub { return($self->pass()) }
        if defined($self->pass());
    return(\%data);
};

1;

__DATA__

=head1 NAME

Authen::Credential::x509 - abstraction of an X.509 credential

=head1 DESCRIPTION

This helper module for Authen::Credential implements an X.509
credential, see L<http://en.wikipedia.org/wiki/X.509>.

It supports the following attributes:

=over

=item cert

the path of the file holding the certificate

=item key

the path of the file holding the private key

=item pass

the pass-phrase protecting the private key (optional)

=item ca

the path of the directory containing trusted certificates (optional)

=back

It supports the following targets for the prepare() method:

=over

=item IO::Socket::SSL

it returns a reference to a hash containing the suitable options for
IO::Socket::SSL

=back

=head1 SEE ALSO

L<Authen::Credential>,
L<IO::Socket::SSL>,
L<http://en.wikipedia.org/wiki/X.509>.

=head1 AUTHOR

Lionel Cons L<http://cern.ch/lionel.cons>

Copyright CERN 2011
