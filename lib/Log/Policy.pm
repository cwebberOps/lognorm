package Log::Policy;

use strict;
use warnings;
use Parse::RecDescent;
use Log::Data;

=head1 COPYRIGHT

Copyright 2012 Stephen Hock

This file is part of lognorm.

    lognorm is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    lognorm is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with lognorm.  If not, see <http://www.gnu.org/licenses/>.

=cut

$::RD_HINT = 1;
$::RD_ERRORS = 1;
$::RD_WARN = 1;

my $grammar = q{
policy : policystmt policy
       { $return = Log::Data::cons("policy", $item[1], $item[2]) }
       | policystmt
       { $return = Log::Data::cons("policy", $item[1]) }

policystmt : actions "when" exprs
           { $return = Log::Data::stmt($item[1], $item[3]); }

actions : action ";" actions
        { $return = Log::Data::cons("actions", $item[1], $item[3]) }
        | action
        { $return = Log::Data::cons("actions", $item[1]) }

action : count
       | output
       | save
       | restore
       | forget
       | consume

count : "count" NAME "[" fields "]" 
      { $return = Log::Data::count($item[2], $item[4]) }

save : "save" NAME "{" fields "}" 
      { $return = Log::Data::save($item[2], $item[4]) }

restore : "restore" NAME "{" fields "}" 
      { $return = Log::Data::restore($item[2], $item[4]) }

forget : "forget" NAME "{" fields "}" 
      { $return = Log::Data::forget($item[2], $item[4]) }

consume : "consume" NAME "{" fields "}" 
      { $return = Log::Data::consume($item[2], $item[4]) }

output : "output" fields
       { $return = Log::Data::output($item[2]) }

fields : NAME "," fields
       { $return = Log::Data::cons("fields", $item[1], $item[3]) }
       | NAME
       { $return = Log::Data::cons("fields", $item[1]) }

exprs : expr "," exprs
         { $return = Log::Data::cons("exprs", $item[1], $item[3]) }
         | expr
         { $return = Log::Data::cons("exprs", $item[1]) }

expr : assign
     | regexp
     | comparison

comparison : cmpterm BOOLOP comparison
           { $return = Log::Data::boolop($item[2], $item[1], $item[3]) }
           | cmpterm

cmpterm : cmpfactor CMPOP cmpterm
        { $return = Log::Data::cmpop($item[2], $item[1], $item[3]) }
        | cmpfactorter

cmpfactor : "(" comparison ")"
          { $return = $item[2] }
          | term

BOOLOP : "&&" | "||"

CMPOP : ">=" | "<=" | ">" | "<" | "==" | "!="

assign : names "=" expr
       { $return = Log::Data::assign($item[1], $item[3]) }

names : lvalue "," names
      { $return = Log::Data::cons("names", $item[1], $item[3]) }
      | lvalue
      { $return = Log::Data::cons("names", $item[1]) }

lvalue : NAME
       { $return = Log::Data::lvalue($item[1]) }

regexp : "/" /[^\\/]+/ "/"
       { $return = Log::Data::regexp($item[2]) }

term : NAME "(" args ")"
     { $return = Log::Data::funcall($item[1], $item[3]) }
     | /\d+(\.\d+)?/
     { $return = Log::Data::value($item[1]) }
     | '"' /[^"]+/ '"'
     { $return = Log::Data::value($item[2]) }
     | NAME
     { $return = Log::Data::reference($item[1], $item[3]) }

NAME : /[a-zA-Z][a-zA-Z0-9]*/

args : expr "," args
     { $return = Log::Data::cons("args", $item[1], $item[3]); }
     | expr
     { $return = Log::Data::cons("args", $item[1]) }
};

sub parse {
    my ($file) = @_;
    open(FH, "<$file") or die "Error: can't open $file\n";
    my $contents;
    read(FH, $contents, -s FH);
    close(FH);

    my $parser = Parse::RecDescent->new($grammar);
    return $parser->policy($contents); 
}

1;
