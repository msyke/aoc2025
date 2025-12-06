# Advent of Code: Day 1

## Part 1

Part one here was very easy. Most of my issues were with trying to figure out the Zig standard library.
Aside from that I got it in a a matter of minutes. I just used a modulus operation to check if we
landed on a zero.

## Part 2

Part two was much more challenging. It took me hours. There were way too many edge cases I had to
consider. Right turns were pretty easy but Left turns going negative were tricky. I hand to handle
checking if even though we land on zero, did we go negative so we can properly compute the number
of times we past zero. Also I had to do different operatipons depending on the direction and had
a couple of off by one situations, but after a few days of tinkering I finally got it.
