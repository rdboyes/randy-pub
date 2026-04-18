@def title = "You wouldn't pirate a type (part 2)"
@def date = "02/19/2026"
@def tags = ["julia", "Tidier.jl"]

@def rss_pubdate = Date(2026, 2, 19)

## Lower the flag

[Part 1](/posts/piracy/) looked at some basic half-implementations of tidyverse functions relying on type piracy to make things work. What does it look like to do this without the piracy?

## String Macros

