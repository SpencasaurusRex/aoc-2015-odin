# Advent of Code 2015
Advent of Code 2015, solved using Odin.
  
Two goals:
- Improve problem solving skills
- Learn Odin

[Advent of Code](https://adventofcode.com/2015) is a group of programming puzzles to be solved in any language.
They serve as great brain-teasers and tests of problem-solving skills

## Approaches
### Day 01
Pretty straightforward. Just loop through the input characters sequentially. Depending on the character received we can increment or decrement our floor number. The first time we reach floor -1, we print out the current position for part 2 of the puzzle.
### Day 02
For this problem, I looped through the input characters sequentially to parse. I keep track of a start and end index. The start index represents the beginning of a token, and the end index is incremented as we look at each character. 

Example:
> 20x3x11

Once we come across an 'x' or '\n' we know that the start and end index point to the start and end of of a number, so I parse that as a number and store it away in the box_sizes array, then set the start index to our current index + 1 to point at the next number.

Once the file is parsed, it's easy enough to step through the box_sizes array to calculate the surface area or whatever other calculations the problem requires.
