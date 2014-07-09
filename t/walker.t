# walker.t --- test the tree walker

use v6;
use Test;

use Pod::Walker;
plan 1;

my $podblock = Pod::Block::Named.new(
    name => "pod",
    config => ().hash,
    content => Array.new(
        Pod::Block::Named.new(
            name => "TITLE",
            config => ().hash,
            content => Array.new(
                Pod::Block::Para.new(
                    config => ().hash,
                    content => Array.new(
                        "The Great Test"
                    )
                )
            )
        ),
        Pod::Heading.new(
            level => 1,
            config => ().hash,
            content => Array.new(
                Pod::Block::Para.new(
                    config => ().hash,
                    content => Array.new(
                        "Begins"
                    )
                )
            )
        ),
        Pod::Block::Para.new(
            config => ().hash,
            content => Array.new(
                "And ",
                Pod::FormattingCode.new(
                    type => "I",
                    meta => Array.new(),
                    config => ().hash,
                    content => Array.new(
                        "now"
                    )
                ),
                " it ",
                Pod::FormattingCode.new(
                    type => "B",
                    meta => Array.new(),
                    config => ().hash,
                    content => Array.new(
                        "ends"
                    )
                ),
               ". Goodbye."
           )
       )
   )
);

my $output = q:to/EOS/.chomp;
BLOCK[pod][
BLOCK[TITLE][
¶[The Great Test]
]H[1][¶[Begins]]
¶[And {I|now} it {B|ends}. Goodbye.]
]
EOS

my class Pod::To::Bracketed does Pod::Walker {
    method pod-named(@text, $name) {
        "BLOCK[$name][\n{[~] @text}\n]";
    }

    method pod-para(@text) {
        "¶[{[~] @text}]";
    }

    method pod-heading(@text, $level) {
        "H[$level][{[~] @text}]\n";
    }

    method pod-plain($text) {
        $text;
    }

    method pod-fcode(@text, $type, @meta) {
        "\{$type|{[~] @text}}"
    }
}

is Pod::To::Bracketed.new.pod-walk($podblock), $output, "Tree walked successfully.";
