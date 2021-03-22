Tim's Regular Expression Pattern Matcher

Here's my regular expression pattern matcher. It was written in two hours and
the source is very short. [I've since spent about 3 more hours making it a lot
better] I abhorred having to write a state diagram matching algorithm that
all other regular expression parsers use, so I wrote my own algorithm in short
time. In fact, I think it's an original algorithm. If anyone has seen anything
similar, let me know, otherwise I'd like to claim 'discovery.'

Anyways, You push on the stack the pattern, the text to match, and a flag,
which specificies if it is case sensitive. It will return a value other
than 0 if i matched. It uses the same parameter passing conventions as
Orca/C and Orca/Pascal, so you should be able to directly call it from there.
If you are interested in performing file name matching, then by all means
look at my example program called 'match'. Instructions for running match
are contained in the source code.

The pattern consists of character which are directly matched with the
text, EXCEPT for the following special characters:

   '*' - Matches 0 or more characters
   '+' - Matches 1 or more characters
   '?' - Matches 0 or 1 characters
   '[..]' - Matches with one of the characters contained within the brackets.
            If two characters in the brackets are separated by a '-' then
            matches within the range of the two characters. If the first 
            character encountered in the brackets is a '^' (caret), then
            it will march negatively. ie. it will result in a matched character
            if the character did NOT appear in the brackets.
   '\' - This character quoting. The character immediately following is
         matched directly with the text. For example, '\*' will match a '*',
         NOT 0 or more occurances of characters. '\' is not used inside 
         of brackets.

If you find any bugs or have suggestions, please let me know.

-Tim Meekins
6/13/91

