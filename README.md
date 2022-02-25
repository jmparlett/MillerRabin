# genPrime
### Created: 2022-February-6

This program generates prime numbers of a given length. It implements the Miller Rabin primality test
in Haskell, and uses it to check primality of the randomly generated number.

## **Warning!**
Dont use this to generate primes for any security purposes. The underlying randomness is not
up to par with any dedicated crypto library.

## Usage
Prints a prime number with the specified number of bits
- Usage: `genPrime [nbits]`
- example: `genPrime 100` creates and prints a 100 bit prime number

## Building
Type `make` to generate the executeable `genPrime`

## Dependencies
1. Haskell `ghc` compiler.
2. `cabal`
3. The `random` package (`cabal install random`)
4. The `arithmoi` package for the `Math.NumberTheory.Powers.Modular`. We use the deprecated powMod function.


