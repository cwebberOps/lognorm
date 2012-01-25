package Log::Data;
use strict;
use warnings;

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

sub assign {
  my ($names, $expr) = @_;
  return { type => "assign",
		   lvalues => $names,
		   rvalue => $expr }
}

sub regexp {
  my ($expr) = @_;
  return { type => "regexp",
		   expr => qr{$expr} };
}

sub funcall {
  my ($name, $args) = @_;
  return { type => 'funcall',
		   name => $name,
		   args => $args }
}

sub lvalue {
  my ($name) = @_;
  return { type => 'lvalue',
		   name => $name }
}

sub boolop {
    my ($op, $a, $b) = @_;
    return { type => 'boolop',
        op => $op,
        a => $a,
        b => $b }
}

sub cmpop {
    my ($op, $a, $b) = @_;
    return { type => 'cmpop',
        op => $op,
        a => $a,
        b => $b }
}

sub value {
    my ($value) = @_;
    return { type => 'value',
        value => $value }
}

sub stmt {
  my ($actions, $exprs) = @_;
  return { type => 'stmt',
		   actions => $actions,
		   exprs => $exprs }
}

sub output {
  my ($fields) = @_;
  return { type => 'output',
		   fields => $fields }
}

sub reference {
  my ($name) = @_;
  return { type => 'reference',
		   name => $name }
}

sub count {
  my ($name, $fields) = @_;
  return { type => "count",
		   name => $name,
		   fields => $fields }
}

sub save {
  my ($name, $fields) = @_;
  return { type => "save",
		   name => $name,
		   fields => $fields }
}

sub restore {
  my ($name, $fields) = @_;
  return { type => "restore",
		   name => $name,
		   fields => $fields }
}

sub forget {
  my ($name, $fields) = @_;
  return { type => "forget",
		   name => $name,
		   fields => $fields }
}

sub consume {
  my ($name, $fields) = @_;
  return { type => "consume",
		   name => $name,
		   fields => $fields }
}

sub cons {
  my ($type, $a, $b) = @_;
  
  my @nodes;
  if (defined $b) {
	@nodes = @{$b->{nodes}};	
  }
  
  unshift @nodes, $a;

  return { type => $type,
                   nodes => \@nodes
                 };
}

1;
