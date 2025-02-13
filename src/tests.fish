# Little hand-crafted tests system and test suite with a Fish script to validate the full behavior of binary ./tar
# I couldn't find an easy way to install necessary tools to write tests in Haskell with HUnit or something else, so we wrote something external
# If you want to run them, you can install Fish (https://fishshell.com/ - "brew install fish" for MacOS, not available on Windows but works in WSL2) and run "fish tests.fish". You can also run it in loop with "watch --color fish tests.fish".

# Tests abstractions
function color
    set_color $argv[1] # set color and bold mode
    echo -n $argv[2..-1]
    set_color normal
end

function compress
    echo "$argv[1]" >in # do not -n here, this will break assert_eq reception of params
    if ! ./tar -c in out 2>&1
        return
    end
    cat out
end

function decompress
    echo -n "$argv[1]" >in
    if ! ./tar -d in out 2>&1
        return
    end
    cat out
end

set cnt 0
function assert_eq
    set title $argv[1]
    set initial $argv[2]
    set first $argv[3]
    set second $argv[4]
    set cnt (math $cnt + 1)
    color blue "$cnt. $title: "
    if test "$first" = "$second"
        color green "with '$initial' found '$first'"\n
    else
        color red "with '$initial': expected '$second' found '$first'"\n
    end
end

function assert_fail
    set title $argv[1]
    set initial $argv[2]
    set first $argv[3]
    set cnt (math $cnt + 1)
    color blue "$cnt. $title: "
    if string match -e error "$first" >/dev/null
        color green "with '$initial', got '$first'"\n
    else
        color red "with '$initial': expected to fail but got '$first'"\n
    end
end

function assert_comp
    assert_eq $argv[1] "$argv[2]" (compress "$argv[2]") $argv[3]
end

function assert_decomp
    assert_eq $argv[1] "$argv[2]" (decompress "$argv[2]") $argv[3]
end

function assert_decomp_comp
    assert_eq $argv[1] "$argv[2]" (compress (decompress "$argv[2]")) $argv[2]
end
function assert_comp_decomp
    assert_eq $argv[1] "$argv[2]" (decompress (compress "$argv[2]")) $argv[2]
end

function assert_comp_fail
    assert_fail $argv[1] "$argv[2]" (compress "$argv[2]")
end

function assert_decomp_fail
    assert_fail $argv[1] "$argv[2]" (decompress "$argv[2]")
end

# -------

# Preparations
if ! ghc tar.hs
    color red "Build errors..."\n
    return
end

# Tests suites
color magenta "Compression tests"\n
assert_comp 'Empty string' '' ''
assert_comp 'Single letter' A 1A
assert_comp Basic AAA 3A
assert_comp 'Basic long' aaaaaaaaaaaa 12a
assert_comp Word salut 1s1a1l1u1t
assert_comp '2 digits pattern' uuuuuuuuuuuu 12u
assert_comp '2 digits pattern with zero' uuuuuuuuuuuuuuuuuuuu 20u
assert_comp 'Small string' cbbbba 1c4b1a
assert_comp 'Longer string' AAAABBBCCDAA 4A3B2C1D2A
assert_comp 'Longer string with special chars' 'xxXXP***ççàààààà' '2x2X1P3*2ç6à'
assert_comp 'Longer string with spaces and tabs' "  "\t" " "2 1"\t"1 "
assert_comp_fail 'Digits forbidden - start' 52h
assert_comp_fail 'Digits forbidden - middle' aaaa3bbbbk
assert_comp_fail 'Digits forbidden - end' hhh5
assert_comp_fail 'Digits forbidden - only digits' 5234

color magenta \n"Decompression tests"\n
assert_decomp 'Empty string' '' ''
assert_decomp 'Single letter' 1A A
assert_decomp 'Single pattern' 4u uuuu
assert_decomp '2 digits pattern' 12u uuuuuuuuuuuu
assert_decomp '2 digits pattern with zero' 20u uuuuuuuuuuuuuuuuuuuu
assert_decomp Word 1s1a1l1u1t salut
assert_decomp Basic 3X5F XXXFFFFF
assert_decomp Long 3X5F XXXFFFFF
assert_decomp_fail 'Char without any counter forbidden - start single' A
assert_decomp_fail 'Char without any counter forbidden - start multiple' 4ABD3b
assert_decomp_fail 'Char without any counter forbidden - end' 3AB
assert_decomp_fail 'Counter without any char after forbidden' 4B5
assert_decomp_fail 'Counter without any char after forbidden - multiple digits' 4B532
assert_decomp_fail 'A counter equal to 0 forbidden' 0b5a
assert_decomp_fail 'A counter equal to 0 forbidden - end' 19b5A0k

color magenta \n"Compression+Decompression tests"\n
assert_comp_decomp 'Long pattern' '"salut__éla_*ç%&&&"*ç***$$$$``'

color magenta \n"Decompression+Compression tests"\n
assert_decomp_comp 'Long pattern' '4a10b123w13g3$10_5%'
assert_decomp_comp 'Long single letter' 250w

# Cleanup
rm -f in out
