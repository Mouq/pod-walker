# conv_class.t --- test the class holding conversion functions

use v6;
use Test;
use Pod::Walker;
plan 21;

my $def = Pod::Walker.new;

is $def.pod-para("foo"),       "foo", "Default &para is the identity function.";
is $def.pod-named("foo"),      "foo", "Default &named is the identity function.";
is $def.pod-comment("foo"),    "foo", "Default &comment is the identity function.";
is $def.pod-code("foo"),       "foo", "Default &code is the identity function.";
is $def.pod-declarator("foo"), "foo", "Default &declarator is the identity function.";
is $def.pod-table("foo"),      "foo", "Default &table is the identity function.";
is $def.pod-fcode("foo"),      "foo", "Default &fcode is the identity function.";
is $def.pod-heading("foo"),    "foo", "Default &heading is the identity function.";
is $def.pod-item("foo"),       "foo", "Default &item is the identity function.";
is $def.pod-config("foo"),     "foo", "Default &config is the identity function.";
is $def.pod-plain("foo"),      "foo", "Default &plain is the identity function.";

is $def.pod-para("foo", "bar"), "foo", "Default function eats additional arguments";

{
    class FAKE::ERR {
        has $.text = '';
        method print($thing) {
            $!text ~= $thing;
        }
        method clear() {
            $!text = '';
        }
    }

    temp $*ERR = FAKE::ERR.new;

    is $def.debug, False, "Class not set to debug by default.";

    $def.pod-para("foo");
    is $*ERR.text, '', "Default function does not emit debug info by default.";
    $*ERR.clear;

    my $d2 = Pod::Walker.new(:debug);

    is $d2.debug, True, "New class with :debug successfully set to debug.";

    my $out = "Called para\n";

    $d2.pod-para("foo", "bar", :baz);
    is $*ERR.text, $out, "Default function in debug-based class emits debug info.";
    $*ERR.clear;

    $d2.debug-OFF;
    is $d2.debug, False, "Class' debug can be turned off.";
    $d2.debug-ON;
    is $d2.debug, True, "Class' debug can be turned on.";
}

sub foo($thing, :$debug) { $thing.uc };
sub bar($thing, :$debug) { $thing.lc };

my $d3 = (class :: does Pod::Walker { method pod-para(|a) { foo(|a) } }).new;

is $d3.pod-para("Hello"), "HELLO", "Can assign function to name on initialization.";
is $d3.pod-code("Hello"), "Hello", "Other functions stay at default.";
is $d3.pod-item("Hello"), "Hello", "Other functions stay at default.";

#$d3.set-code(&bar);
#
#is $d3.para("Hello"), "HELLO", "Function assigned at init still there after post-init assignment.";
#is $d3.code("Hello"), "hello", "Function assignment post-init works.";
#is $d3.item("Hello"), "Hello", "Other functions stay at default.";
