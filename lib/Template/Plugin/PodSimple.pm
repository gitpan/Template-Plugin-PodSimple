=head1 NAME

Template::Plugin::PodSimple - simple Pod::Simple plugin for TT

=head1 SYNOPSIS

    [% USE PodSimple %]
    [% PodSimple.parse('format',string_containing_pod_or_filename) %]

=head1 DESCRIPTION

    [%    SET somepod = "
    
    =head1 NAME
    
    the name
    
    =head1 DESCRIPTION
    
    somepod
    
    =cut
    
    ";
    USE PodSimple;
    %]
    
    [% PodSimple.parse('Text', somepod) %]
    [% PodSimple.parse('xml', somepod) %]
    [% mySimpleTree = PodSimple.parse('tree', somepod ) %]
    [% PodSimple.parse('html', somepod, 'prefix') %]

Text translates to L<Pod::Simple::Text|Pod::Simple::Text>.

xMl translates to L<Pod::Simple::XMLOutStream|Pod::Simple::XMLOutStream>.

tree translates to L<Pod::Simple::SimpleTree|Pod::Simple::SimpleTree>,
and the tree B<root> is what's returned.
This is what you want to use if you want to create your own formatter.

htMl translates to L<Pod::Simple::HTML|Pod::Simple::HTML>.
When dealing with htMl, the 3rd argument (prefix)
is used to prefix all non-local LE<lt>E<gt>inks,
by temporarily overriding C<< *Pod::Simple::HTML::resolve_pod_page_link >>.
Prefix is "B<?>" by default.



=head1 SEE ALSO

L<Template::Plugin|Template::Plugin>,
L<Pod::Simple|Pod::Simple>.

=head1 BUGS

To report bugs, go to
E<lt>http://rt.cpan.org/NoAuth/Bugs.html?Dist=Template-Plugin-PodSimpleE<gt>
or send mail to E<lt>Template-Plugin-PodSimple#rt.cpan.orgE<gt>.

=head1 LICENSE

Copyright (c) 2003 by D.H. (PodMaster). All rights reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. If you don't know what this means,
visit http://perl.org/ or http://cpan.org/.

=cut

package Template::Plugin::PodSimple;
use strict;
use Pod::Simple;
use Carp 'croak';
use base qw[ Template::Plugin ];
use vars '$VERSION';
$VERSION = sprintf "%d.%03d", q$Revision: 1.5 $ =~ /(\d+).(\d+)/g;


my %map = (
    tree => 'SimpleTree',
    html => 'HTML',
    text => 'Text',        
    xml  => 'XMLOutStream',
);

sub parse {
    my $self = shift;
    my $class = lc shift;
    my $prefix = $_[1] || '?';
    my $somestring="";
    my $new;

    unless( exists $INC{"lib/Pod/Simple/$map{$class}.pm"} ){
        eval "require Pod::Simple::$map{$class};";
        croak("Template::Plugin::PodSimple could not load Pod::Simple::$map{$class} : $@ $!")
            if $@;
    }
            
    $new = "Pod::Simple::$map{$class}"->new();

    croak("`$class' not recognized by Template::Plugin::PodSimple $@ $!")
        unless defined $new;

    $new->output_string( \$somestring );

    local *Pod::Simple::HTML::resolve_pod_page_link = sub {
        my($self, $to) = @_;
        return "$prefix$to";
    } if $class =~ /html/i;

    if( $_[0] =~ /\n/ ){
        $new->parse_string_document( $_[0] );
    } else {
        $new->parse_file($_[0]);
    }

    $somestring = $new->root if $class eq 'tree';

    return $somestring;
}


1;
__END__
sub filter {
  my($class, $source) = @_;
  my $new = $class->new;
  my $somestring="";
  $new->output_string( \$somestring );
  
  if(ref($source || '') eq 'SCALAR') {
    $new->parse_string_document( $$source );
  } elsif(ref($source)) {  # it's a file handle
    $new->parse_file($source);
  } else {  # it's a filename
    $new->parse_file($source);
  }
  
  return $somestring;
}
