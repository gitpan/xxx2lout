package Lout ;

# $Id: Lout.pm,v 1.2 1999/07/11 17:07:37 root Exp root $

# Copyright (c) 1999 Mark Summerfield. All Rights Reserved.
# May be used/distributed under the same terms as Perl itself.

use strict ; 

use vars qw( $VERSION ) ;
$VERSION    = '0.02' ;


my %option = (
        -smart_quotes   => 1,
        -superscripts   => 1,
        -tex            => 0,
        ) ;


my $AT          = "\x00" ;
my $LBRACE      = "\x01" ;
my $RBRACE      = "\x02" ;
my $ELLIPSIS    = "\x03" ;
my $QLEFT       = "\x04" ;
my $QRIGHT      = "\x05" ;
my $PARA        = "\x06" ;
# If more are required use pairs, e.g. "\x07\x00" .. "\x07\xFF".


sub set_txt2lout {
    my( $key, $value ) = @_ ;
    
    $option{$key} = $value ;
}


sub txt2lout {
    local $_ = shift ;

    s/[\n\r]{2,}/$PARA/gos ;
    s/\@/$AT/go ;

    # TeX and LaTeX
    if( $option{-tex} ) {
        s/(\W)tex(\W)/$1\@TeX$2/goi ;
        s/(\W)latex(\W)/$1\@LaTeX$2/goi ;
    }

    # Superscripts
    if( $option{-superscripts} ) {
        s/1st/1$LBRACE\@Sup${LBRACE}st$RBRACE$RBRACE/go ;
        s/2nd/2$LBRACE\@Sup${LBRACE}nd$RBRACE$RBRACE/go ;
        s/3rd/3$LBRACE\@Sup${LBRACE}rd$RBRACE$RBRACE/go ;
        s/(\d)th/$1$LBRACE\@Sup${LBRACE}th$RBRACE$RBRACE/go ;
    }

    # `Smart' quotes 
    if( $option{-smart_quotes} ) {
        s/\'(s?\W)/$QRIGHT$1/go ;
        s/(\W)\'/$1$QLEFT/go ;
        s/^\'/$QLEFT/go ;
        s/([\]\)\}>])$QLEFT/$1$QRIGHT/go ;
        s/(\W)"/$1``/go ;
        s/^"/``/go ;
        s/"(\W)/''$1/go ;
        s/"$/''/go ;
        s/([\]\)\}>])``/$1''/go ;
    }

    # Special characters
    s/$ELLIPSIS/$LBRACE\@Char ellipsis$RBRACE/go ;
    s/£/$LBRACE\@Sterling$RBRACE/go ;
    s/([{}|&^~\/#])/"$1"/go ;
    s/\\/$LBRACE\@Char backslash$RBRACE/go ;

    # Fixups
    s/$QLEFT/`/go ;
    s/$QRIGHT/'/go ;
    s/'`/''/go ;
    s/$PARA/\n\@LP\n/go ;
    s/$AT/"@"/go ;
    s/$LBRACE/{/go ;
    s/$RBRACE/}/go ;

    $_ ;
}

1 ;

