package HTML::LoutParser ;

# $Id: LoutParser.pm,v 1.14 1999/07/14 21:36:08 root Exp root $

# Copyright (c) 1999 Mark Summerfield. All Rights Reserved.
# May be used/distributed under the same terms as Perl itself.

# BUG We don't deal with accented characters and non-breaking spaces very
#     well. Should copy HTML::Entities::decode and 'loutify' it.

# TODO Cope better with tables.
# TODO Do &entity; to {@Char entity} translations.


require HTML::Parser ;
use Lout ;
use Text::Wrap ;

use vars qw( $VERSION @ISA ) ;
$VERSION = '0.03' ;

@ISA = qw( HTML::Parser ) ;


my @List ;
my $Cell = 'A' ;
my $Td   = 0 ;


sub new {
    my $class = shift ;
    my $self  = $class->SUPER::new ;
    my %arg   = (
                    -comment_attr   => 1,
                    -comment_tag    => 1, # We always comment unhandled tags.
                    -ignore_comment => 0,
                    -last_table_col => 'H',
                    -table          => 1,
                    @_,
                ) ;

    $self->{-last_table_col} = $arg{-last_table_col} ;
    if( $self->{-last_table_col} !~ /^[A-Z]$/o ) {
        $self->{-last_table_col} = uc $self->{-last_table_col} ;
        $self->{-last_table_col} = 'Z' if $self->{-last_table_col} gt 'A' or 
                                          $self->{-last_table_col} lt 'Z' ;
    }
    $self->{-table}          = $arg{-table} ;
    $self->{-comment_tag}    = $arg{-comment_tag} ;
    $self->{-comment_attr}   = $arg{-comment_attr} ;
    $self->{-ignore_comment} = $arg{-ignore_comment} ;

    $self ;
}


sub start_lout {
 
    my( $d, $m, $y ) = (localtime( time ))[3..5] ;
    $y += 1900 ; $m++ ; 
    $m = "0$m" if $m < 10 ; 
    $d = "0$d" if $d < 10 ;

    print <<__EOT__ ;
\@SysInclude { tbl }
\@SysInclude { doc }
# Created by HTML::LoutParser.pm on $y/$m/$d.
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

    $text = HTML::Entities::decode( $text ) ;

    $text =~ s/\n/\n#/sog ;
    $text .= "\n" unless substr( $text, length( $text ) - 1, 1 ) eq "\n" ;

    "#$text" ;
}


sub text {
    my( $self, $text ) = @_ ;
    
    print Lout::txt2lout( HTML::Entities::decode( wrap( '', '', $text ) ) ) ;
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
    # $attr is reference to a HASH, $attrseq is reference to an ARRAY

    my $default = 0 ;

    CASE : {
        if( $tag eq 'html' or
            $tag eq 'head' or
            $tag eq 'body' or
            $tag =~ /d[lt]/o
            ) {
            # No action required.
            last CASE ;
        }
        if( $tag eq 'img' ) {
            my $alt = $$attr{'alt'} ;
            print $self->_to_comment( "Image $alt" ) if defined $alt ;
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
            $tag =~ /^em(phasis)?$/o ) {
            print "{}\@I {" ;
            last CASE ;
        }
        if( $tag =~ /^[au]$/o ) {
            my $name = $$attr{'name'} || '' ;
            print "{}\@Underline {$name" ;
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
            print "\n\@CentredDisplay { Bold $sign${size}p } \@Font {" ;
            last CASE ;
        }
        if( $tag eq 'ol' ) {
            my $type = $$attr{'type'} || '1' ;
            if( $type eq 'a' ) {
                print "\n\@AlphaList\n" ;
            }
            elsif( $type eq 'i' ) {
                print "\n\@RomanList\n" ;
            }
            elsif( $type eq 'A' ) {
                print "\n\@UCAlphaList\n" ;
            }
            elsif( $type eq 'I' ) {
                print "\n\@UCRomanList\n" ;
            }
            else {
                print "\n\@NumberedList\n" ;
            }
            push @List, 0 ;
            last CASE ;
        }
        if( $tag eq 'ul' ) {
            print "\n\@BulletList\n" ;
            push @List, 0 ;
            last CASE ;
        }
        if( $tag eq 'li' ) {
            if( $List[$#List] > 0 ) {
                print "}\n" ;
                $List[$#List]-- ;
            }
            print "\n\@ListItem {" ;
            $List[$#List]++ ;
            last CASE ;
        }
        if( $tag eq 'p' ) {
            # BUG We fail to take account of paragraph alignments.
            print "\n\@LP\n" ;
            last CASE ;
        }
        if( $tag eq 'br' ) {
            print "\n\@LLP\n" ;
            last CASE ;
        }
        if( $tag eq 'font' ) {
            my $name  = $$attr{'face'}  || '' ;
            $name =~ /([^,\s]+)$/o ; # Select last face if several.
            $name = $1 if $1 ;
            $name = 'Helvetica' if $name eq 'sans-serif' ;
            $name = 'Times'     if $name eq 'serif' ;
            my $size  = $$attr{'size'}  || '' ;
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
            print "\n\@Tbl\n  rule { yes }\n{\n" ;
            last CASE ;
        }
        if( $self->{-table} and $tag eq 'tr' ) {
            # BUG All attributes are ignored.
            # BUG We have no idea how many columns there will be...
            print '}' while $Td-- > 0; 
            print "\n\@Row\n  format { " ;
            for my $cell ( A..$self->{-last_table_col} ) {
                print "\@Cell $cell " ;
                print $cell eq $self->{-last_table_col} ? '}' : '| ' ;
            }
            print "\n" ;
            $Cell = 'A' ;
            $Td   = 0 ;
            last CASE ;
        }
        if( $self->{-table} and ( $tag eq 'td' or $tag eq 'th' ) ) {
            # BUG All attributes are ignored.
            $Td--, print '}' if $Td ; 
            print "$Cell {" ;
            $Cell++ ;
            $Td++ ;
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


sub end {
    my( $self, $tag, $origtext ) = @_ ;

    my $default = 0 ;

    CASE : {
        if( $tag eq 'p' ) {
            # We ignore this - we put in a @LP at <P> tags.
            last CASE ;
        }
        if( $tag eq 'head' or
            $tag eq 'body' or
            $tag eq 'html' or
            $tag eq 'li'   or
            $tag =~ /d[lt]/o
            ) {
            # No action required.
            last CASE ;
        }
        if( $tag eq 'center'         or 
            $tag eq 'pre'            or
            $tag =~ /^[abiu]$/o      or 
            $tag =~ /^su[bp]$/o      or
            $tag eq 'strong'         or 
            $tag =~ /^em(phasis)?$/o or
            $tag eq 'kbd'            or 
            $tag eq 'tt'             or 
            $tag eq 'dd'             or 
            $tag eq 'code'           or
            $tag =~ /^h[1-6]$/o      or 
            $tag eq 'font'           or
            $tag eq 'cite'           or
            $tag eq 'blockquote'     or
            $tag eq 'title'
            ) {
            print "}\n" ;
            last CASE ;
        }
        if( $self->{-table} and $tag eq 'table' ) {
            print '}' while $Td-- > 0; 
            print "}\n" ;
            last CASE ;
        }
        if( $self->{-table} and $tag eq 'tr' ) {
            print '}' while $Td-- > 0; 
            $Td = 0 ;
            print "\n" ;
            last CASE ;
        }
        if( $self->{-table} and ( $tag eq 'td' or $tag eq 'th' ) ) {
            print "}\n" ;
            $Td-- ;
            last CASE ;
        }
        if( $tag =~ /^[ou]l$/o ) {
            if( $List[$#List] > 0 ) {
                print "}\n" ;
                $List[$#List]-- ;
            }
            warn "Invalid list\n" if $List[$#List] != 0 ;
            pop @List ;
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


1 ;

