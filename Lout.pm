package Lout ; # Documented at the __END__.

# $Id: Lout.pm,v 1.15 1999/09/05 12:10:46 root Exp root $


use strict ; 

use vars qw( $VERSION %Entity2char ) ;
$VERSION = '1.12' ;


my %option = (
        -html           => 0,
        -hyphen         => 0,
        -smartquotes    => 1,
        -superscripts   => 1,
        -tex            => 0,
        -verbatim       => 1,
        ) ;

# This hash (and most of its comments) is copied from Gisle Aas
# HTML::Entities.pm module with the plain text characters being replaced by
# their Lout equivalents.
%Entity2char = (
    # Some normal chars that have special meaning in SGML context
    amp     => '&',     # Note we convert & to "&" later. # ampersand 
    'gt'    => '>',     # greater than
    'lt'    => '<',     # less than
    quot    => '"',     # double quote

    # PUBLIC ISO 8879-1986//ENTITIES Added Latin 1//EN//HTML
    AElig	=> '{@Char AE}',          # 'Æ',  # capital AE diphthong (ligature)
    Aacute	=> '{@Char Aacute}',      # 'Á',  # capital A, acute accent
    Acirc	=> '{@Char Acircumflex}', # 'Â',  # capital A, circumflex accent
    Agrave	=> '{@Char Agrave}',      # 'À',  # capital A, grave accent
    Aring	=> '{@Char Aring}',       # 'Å',  # capital A, ring
    Atilde	=> '{@Char Atilde}',      # 'Ã',  # capital A, tilde
    Auml	=> '{@Char Adieresis}',   # 'Ä',  # capital A, dieresis or umlaut mark
    Ccedil	=> '{@Char Ccedilla}',    # 'Ç',  # capital C, cedilla
    ETH	    => '{@Char Eth}',         # 'Ð',  # capital Eth, Icelandic
    Eacute	=> '{@Char Eacute}',      # 'É',  # capital E, acute accent
    Ecirc	=> '{@Char Ecircumflex}', # 'Ê',  # capital E, circumflex accent
    Egrave	=> '{@Char Egrave}',      # 'È',  # capital E, grave accent
    Euml	=> '{@Char Edieresis}',   # 'Ë',  # capital E, dieresis or umlaut mark
    Iacute	=> '{@Char Iacute}',      # 'Í',  # capital I, acute accent
    Icirc	=> '{@Char Icircumflex}', # 'Î',  # capital I, circumflex accent
    Igrave	=> '{@Char Igrave}',      # 'Ì',  # capital I, grave accent
    Iuml	=> '{@Char Idieresis}',   # 'Ï',  # capital I, dieresis or umlaut mark
    Ntilde	=> '{@Char Ntilde}',      # 'Ñ',  # capital N, tilde
    Oacute	=> '{@Char Oacute}',      # 'Ó',  # capital O, acute accent
    Ocirc	=> '{@Char Ocircumflex}', # 'Ô',  # capital O, circumflex accent
    Ograve	=> '{@Char Ograve}',      # 'Ò',  # capital O, grave accent
    Oslash	=> '{@Char Oslash}',      # 'Ø',  # capital O, slash
    Otilde	=> '{@Char Otilde}',      # 'Õ',  # capital O, tilde
    Ouml	=> '{@Char Odieresis}',   # 'Ö',  # capital O, dieresis or umlaut mark
    THORN	=> '{@Char Thorn}',       # 'Þ',  # capital THORN, Icelandic
    Uacute	=> '{@Char Uacute}',      # 'Ú',  # capital U, acute accent
    Ucirc	=> '{@Char Ucircumflex}', # 'Û',  # capital U, circumflex accent
    Ugrave	=> '{@Char Ugrave}',      # 'Ù',  # capital U, grave accent
    Uuml	=> '{@Char Udieresis}',   # 'Ü',  # capital U, dieresis or umlaut mark
    Yacute	=> '{@Char Yacute}',      # 'Ý',  # capital Y, acute accent
    aacute	=> '{@Char aacute}',      # 'á',  # small a, acute accent
    acirc	=> '{@Char acircumflex}', # 'â',  # small a, circumflex accent
    aelig	=> '{@Char ae}',          # 'æ',  # small ae diphthong (ligature)
    agrave	=> '{@Char agrave}',      # 'à',  # small a, grave accent
    aring	=> '{@Char aring}',       # 'å',  # small a, ring
    atilde	=> '{@Char atilde}',      # 'ã',  # small a, tilde
    auml	=> '{@Char adieresis}',   # 'ä',  # small a, dieresis or umlaut mark
    ccedil	=> '{@Char ccedilla}',    # 'ç',  # small c, cedilla
    eacute	=> '{@Char eacute}',      # 'é',  # small e, acute accent
    ecirc	=> '{@Char ecircumflex}', # 'ê',  # small e, circumflex accent
    egrave	=> '{@Char egrave}',      # 'è',  # small e, grave accent
    eth	    => '{@Char eth}',         # 'ð',  # small eth, Icelandic
    euml	=> '{@Char edieresis}',   # 'ë',  # small e, dieresis or umlaut mark
    iacute	=> '{@Char iacute}',      # 'í',  # small i, acute accent
    icirc	=> '{@Char icircumflex}', # 'î',  # small i, circumflex accent
    igrave	=> '{@Char igrave}',      # 'ì',  # small i, grave accent
    iuml	=> '{@Char idieresis}',   # 'ï',  # small i, dieresis or umlaut mark
    ntilde	=> '{@Char ntilde}',      # 'ñ',  # small n, tilde
    oacute	=> '{@Char oacute}',      # 'ó',  # small o, acute accent
    ocirc	=> '{@Char ocircumflex}', # 'ô',  # small o, circumflex accent
    ograve	=> '{@Char ograve}',      # 'ò',  # small o, grave accent
    oslash	=> '{@Char oslash}',      # 'ø',  # small o, slash
    otilde	=> '{@Char otilde}',      # 'õ',  # small o, tilde
    ouml	=> '{@Char odieresis}',   # 'ö',  # small o, dieresis or umlaut mark
    szlig	=> '{@Char germandbls}',  # 'ß',  # small sharp s, German (sz ligature)
    thorn	=> '{@Char thorn}',       # 'þ',  # small thorn, Icelandic
    uacute	=> '{@Char uacute}',      # 'ú',  # small u, acute accent
    ucirc	=> '{@Char ucircumflex}', # 'û',  # small u, circumflex accent
    ugrave	=> '{@Char ugrave}',      # 'ù',  # small u, grave accent
    uuml	=> '{@Char udieresis}',   # 'ü',  # small u, dieresis or umlaut mark
    yacute	=> '{@Char yacute}',      # 'ý',  # small y, acute accent
    yuml	=> '{@Char ydieresis}',   # 'ÿ',  # small y, dieresis or umlaut mark

    # Some extra Latin 1 chars that are listed in the HTML3.2 draft 1996/05/21
    copy    => '{@CopyRight}',        # '©',  # copyright sign
    reg     => '{@Register}',         # '®',  # registered sign
    nbsp    => '~',                   #       # non breaking space

    # Additional ISO-8859/1 entities listed in rfc1866 (section 14)
    iexcl   => '{@Char exclamdown}',       # '¡',
    cent    => '{@Char cent}',             # '¢',
    pound   => '{@Sterling}',              # '£',
    curren  => '{@Char currency}',         # '¤',
    yen     => '{@Yen}',                   # '¥',
    brvbar  => '{@Char bar}',              # '¦',
    sect    => '{@SectSym}',               # '§',
    uml     => '{@Char dieresis}',         # '¨',
    ordf    => '{@Char ordfeminine}',      # 'ª',
    laquo   => '{@Char guillemotleft}',    # '«',
    'not'   => '{@Char logicalnot}',       # '¬',    # not is a keyword in perl
    shy     => '{@Char hyphen}',           # '­',
    macr    => '{@Char macron}',           # '¯',
    deg     => '{@Char degree}',           # '°',
    plusmn  => '{@Char plusminus}',        # '±',
    sup1    => '{@Char onesuperior}',      # '¹',
    sup2    => '{@Char twosuperior}',      # '²',
    sup3    => '{@Char threesuperior}',    # '³',
    acute   => '{@Char acute}',            # '´',
    micro   => '{@Char mu}',               # 'µ',
    para    => '{@ParSym}',                # '¶',
    middot  => '{@Char periodcentered}',   # '·',
    cedil   => '{@Char cedilla}',          # '¸',
    ordm    => '{@Char ordmasculine}',     # 'º',
    raquo   => '{@Char guillemotright}',   # '»',
    frac14  => '{@Char onequarter}',       # '¼',
    frac12  => '{@Char onehalf}',          # '½',
    frac34  => '{@Char threequarters}',    # '¾',
    iquest  => '{@Char questiondown}',     # '¿',
    'times' => '{@Multiply}',              # '×',    # times is a keyword in perl
    divide  => '{@Divide}',                # '÷',
) ;


my $AT          = "\x00" ;
my $LBRACE      = "\x01" ;
my $RBRACE      = "\x02" ;
my $ELLIPSIS    = "\x03" ;
my $QLEFT       = "\x04" ;
my $QRIGHT      = "\x05" ;
my $PARA        = "\x06" ;
my $PLACE       = "\x07" ;


sub set_option {
    my( $key, $value ) = @_ ;
    
    $option{$key}      = $value ;
    $option{-verbatim} = 0 if $option{-html} ;
}


sub htmlentity2lout {
    
    my $html           = $option{-html} ;
    $option{-html}     = 1 ;
    my $lout           = &txt2lout( shift ) ;
    $option{-html}     = $html ;

    $lout ;
}


sub txt2lout {
    local $_ = shift ;

    # Verbatim lout in plain text
    my @verbatim ;
    if( $option{-verbatim} ) {
        my $i = 0 ;
        while( s/V<[^>]+>/$PLACE$i/os ) {
            $verbatim[$i++] = $1 ;
        }
    }

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
    if( $option{-smartquotes} ) {
        s/&quot;/"/go if $option{-html} ;
        s/\'(s?\W)/$QRIGHT$1/go ;
        s/(\W)\'/$1$QLEFT/go ;
        s/^\'/$QLEFT/go ;
        s/([\]\)\}>!?.,;:])$QLEFT/$1$QRIGHT/go ;
        s/(\W)"/$1``/go ;
        s/^"/``/go ;
        s/"(\W)/''$1/go ;
        s/"$/''/go ;
        s/([\]\)\}>!?.,;:])``/$1''/go ;
    }

    # Special characters
    s/$ELLIPSIS/$LBRACE\@Char ellipsis$RBRACE/go ;
    s/£/$LBRACE\@Sterling$RBRACE/go ;
    s/([{}|^~\/#])/"$1"/go ;
    s/\\/$LBRACE\@Char backslash$RBRACE/go ;

    # HTML entities
    # This code is copied from Gisle Aas HTML::Entities.pm module
    if( $option{-html} ) {
        s/(&\#(\d+);?)/$2 < 256 ? chr $2 : $1/eg ;
        s/(&\#[xX]([0-9a-fA-F]+);?)/my $c = hex $2 ; $c < 256 ? chr $c : $1/eg ;
        s/(?:&(\w+);?)/$Entity2char{$1} || $1/eg ;
    }

    s/(&)/"$1"/go ;

    s/(\s)-(\s)/$1--$2/go if $option{-hyphen} ;

    # Fixups
    s/$QLEFT/`/go ;
    s/$QRIGHT/'/go ;
    s/'`/''/go if $option{-smartquotes} ;
    if( $option{-html} ) {
        s/$PARA/\n/go ;
    }
    else {
        s/$PARA/\n\@PP\n/go ;
    }
    s/$AT/"@"/go ;
    s/$LBRACE/{/go ;
    s/$RBRACE/}/go ;

    # Verbatim lout in plain text
    if( $option{-verbatim} ) {
        foreach my $verbatim ( 0..$#verbatim ) {
            s/$PLACE$verbatim/$verbatim[$verbatim]/m ;
        }
    }

    $_ ;
}


sub pod2lout {
    local $_ = shift ;

    my $GT = "\x00" ;
    my $LT = "\x01" ;

    $_ = Lout::txt2lout( $_ ) ;
    s/E<gt>/$GT/go ;
    s/E<lt>/$LT/go ;
    s/E<(\[A-Fa-f\d]+)>/chr oct $1/goe ;
    s/B<([^>]*?)>/\@B{$1}/go ;
    s/C<([^>]*?)>/\@F{$1}/go ;
    s/I<([^>]*?)>/\@I{$1}/go ;
    s/F<([^>]*?)>/\@I \@Underline{$1}/go ;
    s/L<([^>]*?)>/\@Underline{$1}/go ;
    s/S<([^>]*?)>/'~' x length( $1 )/goe ;
    s/X<([^>]*?)>/(\@I{$1})/go ;
    s/Z<([^>]*?)>/$1/go ;
    s/$GT/>/go ;
    s/$LT/</go ;

    $_ ;
}


1 ;


__END__

=head1 NAME

Lout.pm - Module providing txt2lout, htmlentity2lout and pod2lout functions

=head1 SYNOPSIS

    use Lout ;

    $lout = Lout::txt2lout( $text ) ;
    $lout = Lout::pod2lout( $pod ) ;
    $lout = Lout::htmlentity2lout( $html ) ;

    # If doing lots of htmlentity2lout this is faster:
    Lout::set_option( -html => 1 ) ;
    foreach $html ( @html ) {
        $lout .= Lout::txt2lout( $html ) ;
    }

=head1 DESCRIPTION

=head2 Lout::txt2lout

This function converts a plain text string into a string of lout. It is
influenced by the following options (all of which are set by calling
C<Lout::set_option> once for each option - defaults are shown):

C<Lout::set_option( -html =E<gt> 0)> - Treat the input as plain text; set to 1
to treat the input as HTML. If on then -verbatim is off.

C<Lout::set_option( -hyphen =E<gt> 0)> - Convert space delimited hyphens to
lout double hyphens.

C<Lout::set_option( -smartquotes =E<gt> 1)> - Convert single and double quotes
to `smart' quotes.

C<Lout::set_option( -superscripts =E<gt> 1)> - Convert the letters after
numbers to superscripts, e.g. for 1st, 2nd, 3rd, 4th, etc. 

C<Lout::set_option( -tex =E<gt> 0)> - Convert TeX and LaTeX to @TeX and
@LaTeX; this assumes that you are using a lout document type which has these
macros defined. 

C<Lout::set_option( -verbatim =E<gt> 1)> - On for text and pod, off for html.
Allows V<@Verbatim Lout> in your text to go through unchanged.

=head2 Lout::htmlentity2lout

This is merely a wrapper around C<Lout::txt2lout> which effectively calls
C<Lout::set_option( -html =E<gt> 1)> first. For processing lots of html entity
strings it is quicker to set the option once and call C<Lout::txt2lout>
direct.

NB This is the equivalent of Gisle Aas HTML::Entities::decode except that it
produces Lout instead of plain text. It does I<not> deal with HTML tags - use
my C<HTML::LoutParser.pm> module for that.

=head2 Lout::pod2lout

This calls C<Lout::txt2lout> (so all the options which are set apply), and
then performs pod-specific translations. 

NB This only translates pod `entities' like EE<gt>gtE<lt>, etc. For full pod
translation use my C<pod2lout> program.

=head2 Lout::set_option

(This sets the options used by C<Lout::txt2lout> and C<Lout::htmlentity2lout>
as described above.)

=head2 EXAMPLES

(See DESCRIPTION.)

=head1 BUGS

None that I know of!

=head1 CHANGES

1999/07/18  First properly documented release. 

1999/07/28  Put %Entity2char in the symbol table so that other perl programs
            can access it, for example lout2html.

1999/08/08  Changed licence to LGPL.

1999/08/15  Added -hyphen and -verbatim options.

1999/09/04  Tiny improvement.


=head1 AUTHOR

Mark Summerfield. I can be contacted as <summer@chest.ac.uk> -
please include the word 'lout' in the subject line.

=head1 COPYRIGHT

Copyright (c) Mark Summerfield 1999. All Rights Reserved.

This module may be used/distributed/modified under the LGPL. 

=cut

