# Walker.pm6 --- class and functions for walking a Pod tree.

use v6;

role Pod::Walker;

has %!funcs;

has $.debug = False;

method debug-ON { $!debug = True; }
method debug-OFF { $!debug = False; }

method pod-default($text, *@a, *%b) {
    $text;
}
method pod-para(|a)       { note "Called para"       if $!debug; self.pod-default(|a) }
method pod-named(|a)      { note "Called named"      if $!debug; self.pod-default(|a) }
method pod-comment(|a)    { note "Called comment"    if $!debug; self.pod-default(|a) }
method pod-code(|a)       { note "Called code"       if $!debug; self.pod-default(|a) }
method pod-declarator(|a) { note "Called declarator" if $!debug; self.pod-default(|a) }
method pod-table(|a)      { note "Called table"      if $!debug; self.pod-default(|a) }
method pod-fcode(|a)      { note "Called fcode"      if $!debug; self.pod-default(|a) }
method pod-heading(|a)    { note "Called heading"    if $!debug; self.pod-default(|a) }
method pod-item(|a)       { note "Called item"       if $!debug; self.pod-default(|a) }
method pod-config(|a)     { note "Called config"     if $!debug; self.pod-default(|a) }
method pod-plain(|a)      { note "Called plain"      if $!debug; self.pod-default(|a) }

method pod-walk(|a) {
    return pod-walk(self, |a)
}

# I know Pod::Config !~~ Pod::Block, but hopefully you're not using one as a
# top-level node anyway :) .
sub pod-walk(Pod::Walker $wc, Pod::Block $START) is export {
    return pw-recurse($wc, $START, 0);
}

proto sub pw-recurse($wc, $node, $level) {
    note "LEVEL $level".indent($level * 2) if $wc.debug;

    my @*TEXT;
    if $node ~~ Pod::Block {
            
        for $node.content {
            @*TEXT.push(pw-recurse($wc, $_, $level+1));
        }
    }

    {*}
}

multi sub pw-recurse($wc, Pod::Block::Para $node, $level) {
    $wc.pod-para(@*TEXT);
}

multi sub pw-recurse($wc, Pod::Block::Named $node, $level) {
    $wc.pod-named(@*TEXT, $node.name);
}

multi sub pw-recurse($wc, Pod::Block::Comment $node, $level) {
    $wc.pod-comment(@*TEXT);
}

multi sub pw-recurse($wc, Pod::Block::Code $node, $level) {
    $wc.pod-code(@*TEXT);
}

multi sub pw-recurse($wc, Pod::Block::Declarator $node, $level) {
    $wc.pod-declarator(@*TEXT, $node.WHEREFORE);
}

multi sub pw-recurse($wc, Pod::Block::Table $node, $level) {
    $wc.pod-table(@*TEXT, $node.headers, $node.caption);
}

multi sub pw-recurse($wc, Pod::FormattingCode $node, $level) {
    $wc.pod-fcode(@*TEXT, $node.type, $node.meta);
}

multi sub pw-recurse($wc, Pod::Heading $node, $level) {
    $wc.pod-heading(@*TEXT, $node.level // Any);
}

multi sub pw-recurse($wc, Pod::Item $node, $level) {
    $wc.pod-item(@*TEXT, $node.level // Any);
}

multi sub pw-recurse($wc, Pod::Config $node, $level) {
    $wc.pod-item($node.type, $node.config);
}

multi sub pw-recurse($wc, @olditems, $level) {
    my @newitems;
    @newitems.push(pw-recurse($wc, $_, $level+1)) for @olditems;
    @newitems;
}

# XXX replace with "Stringy $node" when appropriate
multi sub pw-recurse($wc, Str $node, $level) {
    $wc.pod-plain($node);
}
