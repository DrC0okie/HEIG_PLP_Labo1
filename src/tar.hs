-- Tar - simple compression tool
-- Authors: Samuel Roland and Timothée Van Hove
-- Description: Compression is made with basic RLE algorithm, it will compress AAAABBBCCDAA into 4A3B2C1D2A, and is able to decompress 3X5F to XXXFFFFF
-- Features and limits: The compression must support numbers, not only digits, i.e. 345X is a valid compressed string that is a list of 345 times the X letter.
-- there is no support for compressing strings including digits
-- as there is no easy way during decompression to differentiate a counter from a char to repeat.
-- We don't support negative nor null counters
-- When there is any detection of invalid situations, we never want to return a result, we want to fail with an error

-- Goal: compressing a string X and decompressing the result must come back to X,
-- and vice-versa: decompressing a compressed string Y, compressing the result must give Y again,
-- there is a coherence to respect in terms of errors generation on both sides

-- Edge cases on compression
-- 1. Detecting a digit (i.e. in "AAAABBB999") will throw an error because this is not supported and will generate incoherent decompressions
-- 2. An empty string will be compressed to an empty string: "" -> ""

-- Edge cases on decompression
-- 1. Detecting a char without any counter before (i.e. with B in "3AB") will throw an error
-- 2. Detecting a counter without any char after (i.e. with 5 in "4B5") will throw an error, we could interpret it as 5 times nothing but the compression result of "BBBB" will give "4B" not "4B5" so it would be incoherent
-- 3. A counter equal to 0 (i.e. in "0b5a") must throw an error

-- Conventions:
-- 1. n is used for the counter (the number before a char in the compressed version)
-- 2. acc means accumulator, we use to avoid real recursion by having a tail recursion that will be optimized

-- Complexity: we only used ++ where it would not create situations of O(N^2) therefore the rlec and rled are in O(N)
-- to achieve this, we had to push values in front of accumulators and reverse them at the end.
-- These accumulators cannot just be strings, they have to be a list of string because it is harder to reverse it correctly otherwise (for multi digits numbers mostly).
-- All functions are in tail-recursion style for performance and safety

-- Tests: we have a test suite inside file tests.fish where all edge cases documented above have been tested.

import System.Environment

-- Run-Length Encoding Compression
rlec :: String -> String
rlec "" = ""
rlec (x : xs) = concat (rlec' 1 x xs [])
  where
    rlec' :: Int -> Char -> String -> [String] -> [String]
    rlec' _ _ "" acc = reverse acc -- No trailing append, directly reverse the accumulated list
    rlec' n c (x : xs) acc
        | isDigit' c = error ("error: Digits are not allowed, found " ++ [c])
        | x == c = rlec' (n + 1) c xs acc -- Continue accumulating count
        | otherwise = rlec' 1 x xs ((show n ++ [c]) : acc) -- Append part and continue

-- Run-Length Encoding Decompression
rled :: String -> String
rled xs = rled' 0 xs []
  where
    rled' :: Int -> String -> [String] -> String
    rled' n "" acc
        | n /= 0 = error "error: counter without a character"
        | otherwise = concat (reverse acc)
    rled' n (c : cs) acc
        | n == 0 && c == '0' = error ("error: counter cannot be zero in " ++ xs)
        | isDigit' c = rled' (n * 10 + (read [c] :: Int)) cs acc
        | n == 0 = error ("error: character without a counter in " ++ xs)
        | otherwise = rled' 0 cs (repeatChars n c "" : acc)

-- Utils functions
isDigit' :: Char -> Bool
isDigit' x = x <= '9' && x >= '0'

repeatChars :: Int -> Char -> String -> String
repeatChars 0 _ acc = acc
repeatChars n c acc = repeatChars (n - 1) c (c : acc)

-- Compress a file using RLE
compress :: FilePath -> FilePath -> IO ()
compress inputPath outputPath = do
    content <- readFile inputPath
    let compressed = rlec content
    writeFile outputPath compressed

-- Decompress a file using RLE
decompress :: FilePath -> FilePath -> IO ()
decompress inputPath outputPath = do
    content <- readFile inputPath
    let decompressed = rled content
    writeFile outputPath decompressed

-- Usage function to print help message
usage :: IO ()
usage = do
    prog <- getProgName
    putStrLn $ "Usage: " ++ prog ++ " [<option>] <input-file> <output-file>"
    putStrLn "Options:"
    putStrLn "  -c  Compress the input file"
    putStrLn "  -d  Decompress the input file"

-- Main function
main :: IO ()
main = do
    args <- getArgs
    case args of
        ["-c", inputFile, outputFile] -> compress inputFile outputFile
        ["-d", inputFile, outputFile] -> decompress inputFile outputFile
        _ -> usage
