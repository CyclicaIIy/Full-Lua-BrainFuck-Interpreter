# optiLBF
*optiLBF* is a fast and simple module that interprets Brainfuck code efficiently in Lua 5.3

Just a fun little side project I started out of boredom, but this is as fast as I could probably make it.
If you have any suggestions to improve this even faster, feel free to make a pull request.

More information
------------------

The module `optiLBF.lua` returns a single function that you just call with the Brainfuck source string in argument in order to run a program.

Example:

    require 'optiLBF' '++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.'

This obviously outputs the usual `Hello World!` message.

Conforming to the Brainfuck language specifications, any character except `+ - < > [ ] . ,` is treated as a comment.
