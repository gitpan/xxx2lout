package HTML::LoutParser ; # Documented at the __END__.

# $Id: LoutParser.pm,v 1.26 1999/09/04 17:47:40 root Exp root $


require HTML::Parser ;
use Lout ;
use Text::Wrap ;

use vars qw( $VERSION @ISA ) ;
$VERSION = '1.03' ;

@ISA = qw( HTML::Parser ) ;


sub new {
    my $class = shift ;
    my %arg   = (
                    -filename       => '',
                    -comment_attr   => 1, # Include attributes in comments.
                    -comment_tag    => 1, # We always comment unhandled tags.
                    -no_comment     => 0, # Unless we set this.
                    -ignore_comment => 0, # Ignore comments in the HTML.
                    -last_table_col => 'F',
                    -table          => 1,
                    -cnp            => 1, # Add @CNP's to <H1> and <H2>.
                    -verbose        => 0,
                    @_,
                ) ;

    my $self  = $class->SUPER::new ;

    $self->{-last_table_col} = $arg{-last_table_col} ;
    if( $self->{-last_table_col} !~ /^[A-Z]$/o ) {
        $self->{-last_table_col} = uc $self->{-last_table_col} ;
        $self->{-last_table_col} = 'Z' if $self->{-last_table_col} gt 'A' or 
                                          $self->{-last_table_col} lt 'Z' ;
    }
    $self->{-filename}       = $arg{-filename} ;
    $self->{-table}          = $arg{-table} ;
    $self->{-comment_tag}    = $arg{-comment_tag} ;
    $self->{-comment_attr}   = $arg{-comment_attr} ;
    $self->{-ignore_comment} = $arg{-ignore_comment} ;
    $self->{-no_comment}     = $arg{-no_comment} ;
    $self->{-cnp}            = $arg{-cnp} ;
    $self->{-verbose}        = $arg{-verbose} ;

    @{$self->{LIST}}         = () ;
    $self->{CELL}            = 'A' ;
    $self->{TD}              = 0 ;
    $self->{COUNT}           = 0 ;

    print STDERR "Processing tag: " if $self->{-verbose} ;

    bless $self, $class ;
}


sub DESTROY {
    my $self = shift ;

    print STDERR "\n" if $self->{-verbose} ;
}


sub start_lout {
    my $self = shift ;
 
    my( $d, $m, $y ) = (localtime( time ))[3..5] ;
    $y += 1900 ; $m++ ; 
    $m = "0$m" if $m < 10 ; 
    $d = "0$d" if $d < 10 ;

    my $file = $self->{-filename} ? " from " . $self->{-filename} : '' ;

    print <<__EOT__ ;
\@SysInclude { tbl }
\@SysInclude { doc }
# Created by HTML::LoutParser.pm on $y/$m/$d$file.
\@Doc \@Text \@Begin
__EOT__
}


sub end_lout {
    print <<__EOT__ ;
\@End \@Text
__EOT__
}


sub _to_comment {
    my $self = shift ;
    my $text = shift ;

    return '' if $self->{-no_comment} ;

    $text = HTML::Entities::decode( $text ) ;

    $text =~ s/\n/\n#/sog ;
    $text .= "\n" unless substr( $text, length( $text ) - 1, 1 ) eq "\n" ;

    "#$text" ;
}


sub text {
    my( $self, $text ) = @_ ;
   
    my $para ;
    eval {
        $para = wrap( '', '', $text ) ;
    } ;
    $para = $text if $@ ;
    print Lout::htmlentity2lout( $para ) ;
}


sub declaration {
    my( $self, $decl ) = @_ ;

    print $self->_to_comment( $decl ) if $self->{-comment_tag} ;
}


sub comment {
    my( $self, $comment ) = @_ ;

    print $self->_to_comment( $comment ) unless $self->{-ignore_comment} ;
}


sub start {
    my( $self, $tag, $attr, $attrseq, $origtext ) = @_ ;

    my $default = 0 ;

    printf STDERR "%08d\b\b\b\b\b\b\b\b", $self->{COUNT} 
    if $self->{-verbose} and $self->{COUNT} % 8 == 0 ;
    $self->{COUNT}++ ;

    CASE : {
        if( $tag eq 'html' or
            $tag eq 'head' or
            $tag eq 'body' 
            ) {
            # No action required.
            last CASE ;
        }
        if( $tag eq 'img' ) {
            my $img = $$attr{'alt'} || $$attr{'src'} ;
            print Lout::htmlentity2lout( "[Image `$img']" ) if defined $img ;
            last CASE ;
        }
        if( $tag eq 'blockquote' ) {
            print "\n\@QuotedDisplay {" ;
            last CASE ;
        }
        if( $tag eq 'dd' ) {
            print "\n\@IndentedDisplay {" ;
            last CASE ;
        }
        if( $tag eq 'hr' ) {
            print "\n\@LLP \@FullWidthRule \@LLP\n" ;
            last CASE ;
        }
        if( $tag eq 'title' ) {
            print "\n\@CentredDisplay { Bold +5p } \@Font {" ;
            last CASE ;
        }
        if( $tag eq 'center' ) {
            print "{ clines } \@Break {\n" ;
            last CASE ;
        }
        if( $tag eq 'pre' ) {
            print "{ lines } \@Break \@F {\n" ;
            last CASE ;
        }
        if( $tag eq 'b' or 
            $tag eq 'strong' ) {
            print "{}\@B {" ;
            last CASE ;
        }
        if( $tag eq 'i' or 
            $tag eq 'cite' or
            $tag =~ /^em(?:phasis)?$/o ) {
            print "{}\@I {" ;
            last CASE ;
        }
        if( $tag =~ /^[au]$/o ) {
            print "{}\@Underline {" ; 
            last CASE ;
        }
        if( $tag eq 'sup' ) {
            print "{}\@Sup {" ;
            last CASE ;
        }
        if( $tag eq 'sub' ) {
            print "{}\@Sub {" ;
            last CASE ;
        }
        if( $tag eq 'kbd' or 
            $tag eq 'tt'  or 
            $tag eq 'code' ) {
            print "{}\@F {" ;
            last CASE ;
        }
        if( $tag =~ /^h([1-6])$/o ) {
            my $level = $1 ;
            my( $sign, $size ) = $level > 4 ? 
                ( "-" , $level - 4 ) : ( "+" , 5 - $level ) ;
            $level = $level < 3 ? "\@LP\n\@CNP\n" : '' ;
            print "\n$level\@CentredDisplay { Bold $sign${size}p } \@Font {" ;
            last CASE ;
        }
        if( $tag eq 'ol' ) {
            my $type  = $$attr{'type'}  || '1' ;

            my $start = $$attr{'start'} || '1' ; 
            $start = ord( uc $1 ) - ord( 'A' ) + 1 
            if( $type =~ /^[Aa]/o and $start =~ /^([A-Za-z])/o ) ;

            CASE : {
                if( $type eq 'a' ) {
                    print "\n\@AlphaList\n" ;
                    last CASE ;
                }
                if( $type eq 'i' ) {
                    print "\n\@RomanList\n" ;
                    last CASE ;
                }
                if( $type eq 'A' ) {
                    print "\n\@UCAlphaList\n" ;
                    last CASE ;
                }
                if( $type eq 'I' ) {
                    print "\n\@UCRomanList\n" ;
                    last CASE ;
                }
                DEFAULT : {
                    print "\n\@NumberedList\n" ;
                    last CASE ;
                }
            }

            print "    start { $start }\n" ;
            push @{$self->{LIST}}, 0 ;
            last CASE ;
        }
        if( $tag eq 'ul' or $tag eq 'menu' ) {
            print "\n\@BulletList\n" ;
            push @{$self->{LIST}}, 0 ;
            last CASE ;
        }
        if( $tag eq 'dl' ) {
            print "\n\@IndentedList\n" ;
            push @{$self->{LIST}}, 0 ;
            last CASE ;
        }
        if( $tag eq 'li' or $tag eq 'dt' ) {
            if( ${$self->{LIST}}[$#{$self->{LIST}}] > 0 ) {
                print "}" ;
                ${$self->{LIST}}[$#{$self->{LIST}}]-- ;
            }
            print "\n\@ListItem {" ;
            ${$self->{LIST}}[$#{$self->{LIST}}]++ ;
            last CASE ;
        }
        if( $tag eq 'p' ) {
            # BUG We fail to take account of paragraph alignments.
            print "\n\@PP\n" ;
            last CASE ;
        }
        if( $tag eq 'br' ) {
            print "\n\@LLP\n" ;
            last CASE ;
        }
        if( $tag eq 'font' ) {
            my $name  = $$attr{'face'} || '' ;
            $name =~ /([^,\s]+)$/o ; # Select last face if several.
            $name = $1 if $1 ;
            $name = 'Times'     if $name =~ /serif/oi ;
            $name = 'Helvetica' if $name =~ /sans/oi ;
            my $size  = $$attr{'size'} || '' ;
            my $sign  = '' ;
            if( $size =~ /^([-+])(\d+)/o ) {
                $sign = $1 ;
                $size = $2 ;
            }
            print "{ $name Base $sign${size}p } \@Font {" ;
            last CASE ;
        }
        if( $self->{-table} and $tag eq 'table' ) {
            # BUG All attributes are ignored.
            print "\n\@LLP\n\@Tbl\n    rule { yes }\n    aformat {" ;
            for my $cell ( A..$self->{-last_table_col} ) {
                print "\@Cell $cell " ;
                print $cell eq $self->{-last_table_col} ? '}' : '| ' ;
            }
            print "\n{\n" ;
            last CASE ;
        }
        if( $self->{-table} and $tag eq 'tr' ) {
            # BUG All attributes are ignored.
            # We have no idea how many columns there will be...
            print '}' while $self->{TD}-- > 0 ; 
            print "\@Rowa\n" ;
            $self->{CELL} = 'A' ;
            $self->{TD}   = 0 ;
            last CASE ;
        }
        if( $self->{-table} and ( $tag eq 'td' or $tag eq 'th' ) ) {
            # BUG All attributes are ignored.
            $self->{TD}--, print '}' if $self->{TD} ; 
            print "    $self->{CELL} {" ;
            $self->{CELL}++ ;
            $self->{TD}++ ;
            last CASE ;
        }
        DEFAULT : {
            print $self->_to_comment( "unhandled start $tag" . 
                  $self->_show_attributes( $attr ) ) ;
            $default = 1 ;
            last CASE ;
        }
    }
    print $self->_to_comment( "start $tag" . $self->_show_attributes( $attr ) ) 
    if $self->{-comment_tag} and not $default ;
}


sub end {
    my( $self, $tag, $origtext ) = @_ ;

    my $default = 0 ;

    CASE : {
        if( $tag eq 'p' ) {
            # We ignore this - we put in a @PP at <P> tags.
            last CASE ;
        }
        if( $tag eq 'head' or
            $tag eq 'body' or
            $tag eq 'html' or
            $tag eq 'li'   or
            $tag eq 'dt'
            ) {
            # No action required.
            last CASE ;
        }
        if( $tag eq 'center'           or 
            $tag eq 'pre'              or
            $tag =~ /^[abiu]$/o        or 
            $tag =~ /^su[bp]$/o        or
            $tag eq 'strong'           or 
            $tag =~ /^em(?:phasis)?$/o or
            $tag eq 'kbd'              or 
            $tag eq 'tt'               or 
            $tag eq 'dd'               or 
            $tag eq 'dl'               or 
            $tag eq 'code'             or
            $tag =~ /^h[1-6]$/o        or 
            $tag eq 'font'             or
            $tag eq 'cite'             or
            $tag eq 'blockquote'       or
            $tag eq 'title'
            ) {
            print "}\n" ;
            last CASE ;
        }
        if( $self->{-table} and $tag eq 'table' ) {
            print '}' while $self->{TD}-- > 0; 
            print "}\@LLP\n" ;
            last CASE ;
        }
        if( $self->{-table} and $tag eq 'tr' ) {
            print '}' while $self->{TD}-- > 0; 
            $self->{TD} = 0 ;
            print "\n" ;
            last CASE ;
        }
        if( $self->{-table} and ( $tag eq 'td' or $tag eq 'th' ) ) {
            print "}\n" ;
            $self->{TD}-- ;
            last CASE ;
        }
        if( $tag =~ /^[ou]l$/o or $tag eq 'menu' ) {
            if( ${$self->{LIST}}[$#{$self->{LIST}}] > 0 ) {
                print "}\n" ;
                ${$self->{LIST}}[$#{$self->{LIST}}]-- ;
            }
            warn "Invalid list\n" if ${$self->{LIST}}[$#{$self->{LIST}}] != 0 ;
            pop @{$self->{LIST}} ;
            print "\n\@EndList\n" ;
            last CASE ;
        }
        DEFAULT : {
            print $self->_to_comment( "unhandled end " . $tag ) ;
            $default = 1 ;
            last CASE ;
        }
    }
    print $self->_to_comment( "end " . $tag ) 
    if $self->{-comment_tag} and not $default ;
}


sub _show_attributes {
    my $self = shift ;
    my $attr = shift ;

    my $attr_str = '' ;
    if( $self->{-comment_attr} ) {
        foreach my $key ( keys %$attr ) {
            next if $key =~ /^[-_]/o ;
            $attr_str .= ", ($key=>$$attr{$key})" ;
        }
        $attr_str =~ s/^, //o ;
        $attr_str = ' attributes= ' . $attr_str if $attr_str ;
    }

    $attr_str ;
}


1 ;


__END__

=head1 NAME

HTML::LoutParser.pm - Module to parse HTML and output Lout

=head1 SYNOPSIS

    require HTML::LoutParser ;

    my $parser = HTML::LoutParser->new() ;

    select( OUTPUT_FILEHANDLE ) ;
    $parser->start_lout ;
    while( <> ) {
        $parser->parse( $_ ) ;
    }
    $parser->eof ;
    $parser->end_lout ;

=head1 DESCRIPTION

Parses the input, outputting the results to the current output filehandle,
STDOUT unless something else is C<select()>ed.

=head2 Options

The parser object can be created with several options, e.g.

    $parser = HTML::LoutParser->new(
                -filename       => 'test.html', 
                -table          => 1,
                -last_table_col => 'D',
                -comment_tag    => 0,
                -comment_attr   => 0,
                -ignore_comment => 0,
                -no_comment     => 0,
                -verbose        => 1,
                ) ;
 
C<-filename> - If given this string will be output as part of the comment at the
top of the lout file.

C<-table> - If set to 1 (the default) will attempt to convert tables. The
outcome will almost certainly require hand correction. If set to 0 all the
table data will be output, with the tags output as comments (unless
C<-no_comment> is 1).

C<-last_table_col> - The letter of the last column to use for tables; all
tables are converted to a fixed number of columns. The default is F (6)
columns.

C<-comment_tag> - If set to 1 (the default) every tag encountered whether
handled or not will be output as a comment. If set to 0 then only unhandled
tags will be output.

C<-comment_attr> - If set to 1 (the default) then every tag output as a
comment will have its attributes listed in the comment too.

C<-ignore_comment> - If set to 1 all HTML comments will be ignored; if set to
0 they will be output as Lout comments.

C<-no_comment> - If set to 1 then no tags are output as comments at all
whether handled or unhandled.

Thus the default is to have every tag converted to a lout comment with its
attributes listed. To have only unhandled tags converted use 
C<-comment_tag =E<gt> 0>. To have no tags output as comments use
C<-no_comment =E<gt> 1>.

C<-verbose> - If set to 1 output a count of start tags processed to STDOUT.

=head2 EXAMPLES

(See DESCRIPTION.)

=head1 BUGS

Not all tags are handled.

Table handling is simplistic. Tables use a fixed number of columns because we
don't know how many we will need. Also we ignore colspan and rowspan, again
because we don't know what we need. Lout needs this info before each row, HTML
gives the info as it goes. Basically you'll need to fix tables (amongst other
things) by hand.

Doesn't always match up all braces - not sure if this is a bug or invalid HTML
in the test files.

If you have something like "E<lt>IE<gt>thisE<lt>/IE<gt>." it may become "{}@I
{this} ." I don't know a solution for this one.


=head1 CHANGES

1999/07/18  First properly documented release. 

1999/07/21  Added @CNP suggested by David Duffy <davidD@qimr.edu.au>. 

1999/07/30  Added -verbose option.

1999/08/08  Changed licence to LGPL.

1999/09/04  Tiny fixes.

=head1 AUTHOR

Mark Summerfield. I can be contacted as <summer@chest.ac.uk> -
please include the word 'loutparser' in the subject line.

=head1 COPYRIGHT

Copyright (c) Mark Summerfield 1999. All Rights Reserved.

This module may be used/distributed/modified under the LGPL. 

=cut

