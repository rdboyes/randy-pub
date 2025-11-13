@def title = "Beginner to Intermediate: What changes?"
@def date = "11/13/2025"
@def tags = ["julia", "cryptography"]

@def rss_pubdate = Date(2025, 11, 13)

When I was first learning how to write code in julia, I solved a series of puzzles called the cryptopals crypto challenges (which are excellent, if you're into programming puzzles). It's been long enough since then that I thought I would take another run at them to see how the code I write has evolved over the last 5 years. I solved the first set without reviewing my past solutions

# Challenge 1: Convert a hex string to a base64 string

```julia
# Beginner Randy

using Base64

str = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
goal = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
out = base64encode(hex2bytes(str))
@assert out == goal
```

```julia
# Intermediate Randy

str = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
expected = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"

function bytes(char1::Char, char2::Char)::UInt8
    temp1 = UInt8(char1)
    temp2 = UInt8(char2)

    temp1 > 0x40 ? temp1 -= 0x57 : temp1 -= 0x30
    temp2 > 0x40 ? temp2 -= 0x57 : temp2 -= 0x30

    return temp1 * 16 + temp2
end

function bytes(input::String)::Vector{UInt8}
    return [bytes(input[c], input[c+1]) for c in 1:2:length(input)]
end

# bytes 1111 1111  2222 2222  3333 3333
# b64   1111 1122  2222 3333  3344 4444

function base64(int1::UInt8, int2::UInt8, int3::UInt8)
    base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    char1 = base64_chars[int1÷0x04+1]
    char2 = base64_chars[0x10*rem(int1, 0x04)+int2÷0x10+1]
    char3 = base64_chars[0x04*rem(int2, 0x10)+(int3÷0x40)+1]
    char4 = base64_chars[rem(int3, 0x40)+1]
    return char1 * char2 * char3 * char4
end

function base64(input::Vector{UInt8})::String
    return *([base64(input[c], input[c+1], input[c+2]) for c in 1:3:length(input)]...)
end

println("Challenge 1: $(base64(bytes(str)) == expected ? "pass" : "fail")")
```

Honestly a massive difference in approach. My beginner solution immediately reaches for a dependency to solve the puzzle, which is effective in its own way, but feels like cheating here. This time around, I didn't really consider looking for a package to solve this, since it felt against the spirit of the challenges.

# Challenge 2: XOR two hex strings

```julia
# Beginner Randy

str1 = hex2bytes("1c0111001f010100061a024b53535009181c")
str2 = hex2bytes("686974207468652062756c6c277320657965")

goal = "746865206b696420646f6e277420706c6179"

out = str1 .⊻ str2

@assert bytes2hex(out) == goal
```

```julia
# Intermediate Randy
p2in = "1c0111001f010100061a024b53535009181c"
p2in2 = "686974207468652062756c6c277320657965"
p2exp = "746865206b696420646f6e277420706c6179"

println("Challenge 2: $(xor.(bytes(p2in), bytes(p2in2)) == bytes(p2exp) ? "pass" : "fail")")
```

Essentially the same approach here.

# Challenge 3: Single Byte XOR Cipher

```julia
# Beginner
str = hex2bytes("1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736")
keys = UInt8[]
for i in 1:255
    append!(keys, i)
end
function single_char_xor(hex_string, char)
    out = UInt8[]
    for i in 1:length(hex_string)
        append!(out, xor(char, hex_string[i]))
    end
    return out
end
out = Array{UInt8, 2}(undef, 255, 34)
function score_text(bytes)
    score = 0
    for i in 1:length(bytes)
        if bytes[i] == 0x61; score += 1; end # a
        if bytes[i] == 0x65; score += 1; end # e
        if bytes[i] == 0x69; score += 1; end # i
        if bytes[i] == 0x6f; score += 1; end # o
        if bytes[i] == 0x75; score += 1; end # u
    end
    return score
end
out = Array{UInt8, 2}(undef, 255, 34)
scores = UInt16[]
for i in 1:255
    temp = single_char_xor(str, keys[i])
    append!(scores, score_text(temp))
    for j in 1:34
        out[i, j] = temp[j]
    end
end
String(out[findmax(scores)[2], :])
```

```julia
# Intermediate Solution
input3 = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"

score_char(c::Char) = c in "aeiou " ? 16 :
    c in "bcdfghjklmnpqrstvwxyz" ? 8 :
    c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" ? 4 :
    Int(c) < 32 ? -10 :
    0

score_text(in::Vector{UInt8}) = sum(score_char.(Char.(in)))

possibles = [xor.(bytes(input3), c) for c in 0x00:0xff]
solution = *(Char.(possibles[argmax(score_text.(possibles))])...)

println("Challenge 3: $solution")
```

This is stylistically night and day, to me. The beginner code is filled with garbage like loops that just fill vectors, multiple-line vowel checks, allocations, etc. The updated solution is much shorter and clearer, thanks to the use of single-line functions, list comprehensions, and the choice to use chars directly rather that the hex codes.

# Challenge 4: Detect Single-Char XOR Ciphers

```julia
# Set 1 Challenge 4
# Detecting Single-Char XOR Ciphers

# Wrap the whole last challenge in a function
function decrypt_single_char_xor(hex)
    str = hex2bytes(hex)

    keys = UInt8[]

    for i in 1:255
        append!(keys, i)
    end

    out = Array{UInt8, 2}(undef, 255, length(str))
    scores = Int16[]

    for i in 1:255
        temp = single_char_xor(str, keys[i])
        append!(scores, score_text(temp))
        for j in 1:length(temp)
            out[i, j] = temp[j]
        end
    end

    return out[findmax(scores)[2], :]
end

# read file
file_in = readlines("D:\\Projects\\cryptopals-jl\\data\\4.txt")

# get the most english of all of these
all_attempts = Array{UInt8, 2}(undef, length(file_in), length(file_in[1]) ÷ 2)
final_scores = Int16[]

for i in 1:length(file_in)
    temp2 = decrypt_single_char_xor(file_in[i])
    append!(final_scores, score_text(temp2))
    for j in 1:length(temp2)
        all_attempts[i, j] = temp2[j]
    end
end

String(all_attempts[findmax(final_scores)[2], :])
```

```julia
input4 = readlines("data/4.txt")

get_best(str::String) = get_best(bytes(str))

function get_best(b::Vector{UInt8})
    possibles = [xor.(b, UInt8(c)) for c in 0x00:0xff]
    scores = score_text.(possibles)
    solution = *(Char.(possibles[argmax(scores)])...)
    return (maximum(scores), solution, (0x00:0xff)[argmax(scores)])
end

each_best = get_best.(input4)

println("Challenge 4: $(each_best[argmax([e[1] for e in each_best])][2])")
```

Better understanding and use of multiple dispatch, relative path rather than a hard-coded path for the file read.

# Challenge 5: Encrypt text with repeating key xor

```julia

stanza = "Burning 'em, if you ain't quick and nimble
I go crazy when I hear a cymbal"

# convert stanza to bytes

function ascii_to_bytes(text)
    bytes = UInt8[]

    for i in 1:length(text)
        append!(bytes, Int(text[i]))
    end

    return bytes
end

input = ascii_to_bytes(stanza)

@assert String(input) == stanza

key = ascii_to_bytes("ICE")

function repeating_key_encrypt(bytes, key)
    ciphertext = UInt8[]
    for i in 1:length(bytes)
        append!(ciphertext, xor(bytes[i], key[1 + mod(i - 1, length(key))]))
    end
    return ciphertext
end

target = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"

@assert bytes2hex(repeating_key_encrypt(input, key)) == target
```

```julia
input5 = """
Burning 'em, if you ain't quick and nimble
I go crazy when I hear a cymbal"""

function recycle_to_length(key, len)
    chars = [c for c in key]
    full_repeats = len ÷ length(key)
    partial = chars[1:rem(len, length(key))]
    return vcat(repeat(chars, full_repeats), partial)
end

ciphertext = xor.(UInt8.([c for c in input5]), UInt8.(recycle_to_length("ICE", length(input5))))
expected = bytes("0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f")

println("Challenge 5: $(ciphertext == expected ? "pass" : "fail")")
```
