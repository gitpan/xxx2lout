package HTML::LoutParser ;

# $Id: LoutParser.pm,v 1.11 1999/07/11 16:24:43 root Exp root $

# Copyright (c) 1999 Mark Summerfield. All Rights Reserved.
# May be used/distributed under the same terms as Perl itself.

# BUG We don't deal with accented characters and non-breaking spaces very
#     well. Should copy HTML::Entities::decode and 'loutify' it.

# TODO Cope with tables, <TABLE>, <TR> and <TD>.
# TODO Do &entity; to {@Char entity} translations.


require HTML::Parser ;
use Lout ;

use vars qw( @ISA ) ;

@ISA = qw( HTML::Parser ) ;

my $TOP = "__TOP__" ;

my @List ;


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
    my $text = shift ;

    $text = HTML::Entities::decode( $text ) ;

    $text =~ s/\n/\n#/sog ;
    $text .= "\n" unless substr( $text, length( $text ) - 1, 1 ) eq "\n" ;

    "#$text" ;
}


sub text {
    my( $self, $text ) = @_ ;
    
    print Lout::txt2lout( HTML::Entities::decode( $text ) ) ;
}


sub declaration {
    my( $self, $decl ) = @_ ;

    print &_to_comment( $decl ) ;
}


sub comment {
    my( $self, $comment ) = @_ ;

    print &_to_comment( $comment ) ;
}


sub start {
    my( $self, $tag, $attr, $attrseq, $origtext ) = @_ ;
    # $attr is reference to a HASH, $attrseq is reference to an ARRAY

    CASE : {
        if( $tag eq 'hr' ) {
            print "\@LLP \@FullWidthRule \@LLP\n" ;
            last CASE ;
        }
        if( $tag eq 'title' ) {
            print "\@CentredDisplay { Bold +5p } \@Font {" ;
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
            print "\@B {" ;
            last CASE ;
        }
        if( $tag eq 'i' or 
            $tag =~ /^em(phasis)?$/o ) {
            print "\@I {" ;
            last CASE ;
        }
        if( $tag =~ /^[au]$/o ) {
            print "\@Underline {" ;
            last CASE ;
        }
        if( $tag eq 'sup' ) {
            print "\@Sup {" ;
            last CASE ;
        }
        if( $tag eq 'sub' ) {
            print "\@Sub {" ;
            last CASE ;
        }
        if( $tag eq 'kbd' or 
            $tag eq 'tt'  or 
            $tag eq 'code' ) {
            print "\@F {" ;
            last CASE ;
        }
        if( $tag =~ /^h([1-6])$/o ) {
            my $level = $1 ;
            my( $sign, $size ) = $level > 4 ? 
                ( "-" , $level - 4 ) : ( "+" , 5 - $level ) ;
            print "\@CentredDisplay { Bold $sign${size}p } \@Font {" ;
            last CASE ;
        }
        if( $tag eq 'ol' ) {
            my $type = $$attr{'type'} || '1' ;
            if( $type eq 'a' ) {
                print "\@AlphaList\n" ;
            }
            elsif( $type eq 'i' ) {
                print "\@RomanList\n" ;
            }
            elsif( $type eq 'A' ) {
                print "\@UCAlphaList\n" ;
            }
            elsif( $type eq 'I' ) {
                print "\@UCRomanList\n" ;
            }
            else {
                print "\@NumberedList\n" ;
            }
            push @List, 0 ;
            last CASE ;
        }
        if( $tag eq 'ul' ) {
            print "\@BulletList\n" ;
            push @List, 0 ;
            last CASE ;
        }
        if( $tag eq 'li' ) {
            if( $List[$#List] > 0 ) {
                print "}\n" ;
                $List[$#List]-- ;
            }
            print "\@ListItem {" ;
            $List[$#List]++ ;
            last CASE ;
        }
        if( $tag eq 'p' ) {
            # BUG We fail to take account of paragraph alignments.
            print "\@LP\n" ;
            last CASE ;
        }
        if( $tag eq 'font' ) {
            my $name  = $$attr{'face'}  || '' ;
            $name = 'Helvetica' if $name eq 'sans-serif' ;
            $name = 'Times'     if $name eq 'serif' ;
            my $size  = $$attr{'size'}  || '' ;
            my $sign  = '' ;
            if( $size =~ /^([-+])(\d+)/o ) {
                $sign = $1 ;
                $size = $2 ;
            }
            print "{ $name $sign${size}p } \@Font {" ;
        }
        DEFAULT : {
            my $attr_str = '' ;
            foreach my $key ( keys %$attr ) {
                $attr_str .= ", ($key=>$$attr{$key})" ;
            }
            $attr_str =~ s/^, //o ;
            print &_to_comment( "start " . $tag . $attr_str ) ;
            last CASE ;
        }
    }
}


sub end {
    my( $self, $tag, $origtext ) = @_ ;

    CASE : {
        if( $tag eq 'p' ) {
            # We ignore this - we put in a @LP at <P> tags.
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
            $tag eq 'code'           or
            $tag =~ /^h[1-6]$/o      or 
            $tag eq 'font'           or
            $tag eq 'title'
            ) {
            print "}\n" ;
            last CASE ;
        }
        if( $tag =~ /^[ou]l$/o ) {
            if( $List[$#List] > 0 ) {
                print "}\n" ;
                $List[$#List]-- ;
            }
            warn "Invalid list\n" if $List[$#List] != 0 ;
            pop @List ;
            print "\@EndList\n" ;
            last CASE ;
        }
        DEFAULT : {
            print &_to_comment( "end " . $tag ) ; 
            last CASE ;
        }
    }
}


1 ;

