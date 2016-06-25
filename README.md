# ReferenDumb

## What is it?

This is a quick hack which retrieves the current number of votes for the
["EU Referendum Rules triggering a 2nd EU Referendum" petition](https://petition.parliament.uk/petitions/131215)
and compares it against the number of votes in the referendum, giving a live
"what-if" answer if the referendum was repeated.

The calculations assume that the people signing the petition are representative
of voters as a whole, whereas in reality they are almost certainly
overwhelmingly people who voted to remain in the EU with a smaller number of
people who already have voter's remorse, or who were unfairly disenfranchised.
So this is very dodgy statistically, but hardly the biggest pack of lies in
this campaign. It's just a bit of fun, really.

What it hopefully *does* highlight is that the referendum result is closer than
the error bars, and that the UK shouldn't immediately blindly leap into leaving
the EU without making sure that it really is the right choice.

## How do I run it?

It is a trivial Perl web site that uses the
[Mojolicious](http://mojolicious.org/) framework. Installing Mojolicious and
then doing `morbo script/referen_dumb` from the checkout root should then run
the development server so you can test it locally.

