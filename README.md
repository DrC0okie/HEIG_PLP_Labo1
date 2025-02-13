[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/d3OAr6hE)
# Tape archive

The purpose of this assignment is to practice your understanding of fundamental functional programming constructs in Haskell. This encompasses the definition of functions, the utilization of recursion, the manipulation of data structures, and the application of pattern matching.

## Topic

The topic of the assignment is the Unix command-line utility `tar`, which stands for "tape archive". The `tar` utility is used to create and manage file and directory archives. Initially created for tape backups, `tar` has become a versatile tool for archiving and distributing files.

While `tar` supports various advanced compression techniques like `gzip`, we will focus on a simpler compression method: Run-Length Encoding (RLE). RLE is a straightforward data compression method where sequences of the same data value (runs) are replaced by a single data value and count.

Consider a file with the following content:

```
AAAABBBCCDAA
```

After compression using RLE, the content in the `tar` archive would be:

```
4A3B2C1D2A
```

Here's how we achieve the compressed result:

1. Identify Runs: Look for sequences of the same character.
2. Count the Runs: For each sequence, count the number of consecutive occurrences.
3. Encode the Runs: Replace each sequence with the count followed by the character.

Let's break down the example:

- The first sequence is "AAAA" (four 'A's), which is encoded as "4A".
- The next sequence is "BBB" (three 'B's), which is encoded as "3B".
- The next sequence is "CC" (two 'C's), which is encoded as "2C".
- The next character is "D" (one 'D'), which is encoded as "1D".
- The final sequence is "AA" (two 'A's), which is encoded as "2A".

Upon extracting the `tar` archive, the decompression process would reverse the RLE encoding back to:

```
AAAABBBCCDAA
```

## Task

The assignment requires you to complete a partially implemented Haskell program that emulates the Unix command-line utility `tar`. The provided codebase includes the necessary logic to extract command-line arguments, read input files, and write output files. Your task is to fill in the missing parts of the program:

* Compress an input string using Run-Length Encoding
* Decompress an input string using Run-Length Encoding

You are free to introduce as many helper functions as you see fit, and in fact, you are highly encouraged to do so in order to achieve a readable and modular implementation.

However, refrain from making any changes to the existing codebase provided for the assignment. The codebase is designed to provide a structured framework for your work. Any modifications could potentially disrupt this structure and affect the functionality of your program.

While the standard library can be a useful resource, for this assignment, we ask that you do not use it. We encourage you to implement all functionalities from scratch. The goal is to encourage you to think critically and foster the development of your problem-solving skills.

## How-to

Although the introduction to Haskell programs and the compilation process will be covered later in the course, you can compile and execute your code as follows:

```
% ghc tar.hs
[1 of 1] Compiling Main             ( tar.hs, tar.o )
Linking tar ...
% ./tar
Usage: tar [<option>] <input-file> <output-file>
Options:
  -c  Compress the input file
  -d  Decompress the input file
```

Alternatively, you can test individual functions from your code by loading your source file into the Haskell interpreter and invoking the functions you wish to check:

```
% ghci tar.hs
GHCi, version 9.2.5: https://www.haskell.org/ghc/  :? for help
[1 of 1] Compiling Main             ( tar.hs, interpreted )
Ok, one module loaded.
ghci> usage
Usage: tar [<option>] <input-file> <output-file>
Options:
  -c  Compress the input file
  -d  Decompress the input file
```

To test updated functions without restarting the interpreter, use the `:r` command to reload your source file.

## Grading

The grading of the assignment will be based on the following criteria:

* __Correctness__: The code should compile without errors and perform the task as per the assignment's requirements. It should handle all edge cases and should not crash under any circumstances.
* __Efficiency__: The code should be optimized to run as efficiently as possible. This includes minimizing the time and space complexity of the code. It should not contain unnecessary computation or redundant code.
* __Readability__: The code should be easy to read and understand. This includes proper indentation, the use of meaningful variable and function names, and the inclusion of comments to explain complex parts of the code.
* __Modularity__: The code should be well-structured and divided into functions, each performing a single task. This makes the code easier to read, understand, and maintain.
* __Style__: The code should demonstrate an idiomatic functional programming style, employing suitable programming constructs to ensure the code is concise, modular, and easy to reason about.

Each criterion contributes a maximum of one point to the overall grade. The assignment grade is then computed using the following formula:

<p align="center">
$G = 1 + C_x + E_x + R_x + M_x + S_x$
</p>

where $C_x$, $E_x$, $R_x$, $M_x$, and $S_x$ represent the evaluation of your code based on each respective criterion.

## Deliverable

The deliverable for this assignment is a single Haskell file, named `tar.hs`. This file should include a header that identifies the author(s) of the code. The assignment can be completed individually or in pairs. However, it is crucial to ensure that the work submitted is original and not plagiarized. Copying code from the internet or using solutions from other students is strictly prohibited and will be considered a breach of academic integrity.

## Deadline

The deadline for the assignment is **Wednesday, October 9, 2024, at 23:55**. Once this deadline passes, the repository will be locked for grading purposes, and late submissions will not be accepted under any circumstances.
