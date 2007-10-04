#!/usr/bin/perl

use strict;
use warnings;

use Treemap::Squarified;
use Treemap::Input::XML;
use Output::HTML;
use Data::Dumper;

my $keywords = Treemap::Input::XML->new();
$keywords->load( "./keywords.xml" );

my $htmler = Output::HTML->new( 
  WIDTH=>1024, 
  HEIGHT=>768,
  TEXT_ALIGN=>'left',
  PADDING=>0,
  SPACING=>0,
  LABEL_PARENTS=>1,
  BORDER => '1px solid white',
  FONT_COLOUR => '#fff',
  FONT_SIZE => '12px',
  FONT => 'VAGRounded, "L VAG Rounded Light", verdana, sans-serif',
);

my $treemap = Treemap::Squarified->new( 
  INPUT => $keywords, 
  OUTPUT => $htmler,
  PADDING => 0,
  SPACING => 0
);

$treemap->map();

print $htmler->page;
