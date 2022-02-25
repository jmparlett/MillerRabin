import Prelude
import Math.NumberTheory.Roots
import System.Random
import System.IO
import System.Environment
import Math.NumberTheory.Powers.Modular


-------------------------UTILITIES---------------------------
isqrt = integerSquareRoot
mpow = powMod --modular power function, this one is deprecated, but it was easier to get working
-- mpow b e m = (b^e) `mod` m --modular power --this one is naive it will die for large nums

sieve :: Integer -> [Integer]
sieve n = sieveh [2.. n]
  where 
    sieveh :: [Integer] -> [Integer]
    sieveh []     = []
    sieveh (x:xs) = x : sieveh [y | y <- xs, y `mod` x /= 0]

naiveisprime :: Integer -> Bool
naiveisprime n | n `mod` 2 == 0 && n /= 2 = False
  | n < 2                                 = False
  | otherwise                             = nhelp n [ x | x <- [3 .. (isqrt n)], odd x]
  where
    nhelp _ []     = True
    nhelp n (x:xs) = if n `mod` x == 0 then False else nhelp n xs


-------------------------RANDOM NUMBERS-----------------------
randBits :: (RandomGen g) => Integer -> g -> [Integer] --return stream of random numbers of n bits
randBits nbits = randomRs (2^nbits, 2^(nbits+1) - 1)

randInt :: (RandomGen g) => Integer -> g -> [Integer] --return stream of random numbers of n bits
randInt n = randomRs (2, n - 1)

-------------------------MILLER/RABIN-------------------------
--find k such that n = 2^k * q where q is some odd
findk :: Integer -> Integer
findk n = if n==0 then 0 else findkhelp n 0 
  where
    findkhelp n k | odd n          = k
                  | otherwise      = findkhelp (div n 2) (k+1)

findq :: Integer -> Integer --find q s.t n = 2^k * q, constraints n > 0
findq n = if even n then findq (div n 2) else n


strongPrimeTest :: Integer -> Integer -> Bool
strongPrimeTest n b | (gcd n b) /= 1        = False
                    | mpow b q n == 1       = True  
                    | mpow b q n == (n - 1) = True  
                    | otherwise             = testSquares (k - 1) n $ mpow b q n --loop part of algorithm
    where
      k = findk $ n - 1
      q = findq $ n - 1

      testSquares i n b | i < 0                     = False --reached end of loop, it did not divide any of the factors it must not be prime
                        | (mpow b 2 n) == (n - 1)   = True  --if it divides one of the factors then it might be prime
                        | otherwise                 = testSquares (i - 1) n (mpow b 2 n)

millerRabin :: (RandomGen g) => Integer -> g -> Bool
millerRabin n g | n <  2    = False --2 is first prime and all primes are positive
                | n == 2    = True --2 is prime
                | even n    = False --all other primes are odd
                | otherwise = checkRandomBases n 10 [x | x <- (randInt (n - 1) g), odd x]
    where 
      checkRandomBases :: Integer -> Integer -> [Integer] -> Bool
      checkRandomBases n iters (r:rs) | iters == 0                   = True --all tests passed
                                      | strongPrimeTest n r == False = False --MR says its not prime it defnitely not prime 
                                      | otherwise                    = checkRandomBases n (iters - 1) rs

isprime :: (RandomGen g) => Integer -> g -> Bool
isprime = millerRabin


genPrime :: (RandomGen g) => Integer -> g -> Integer
genPrime nBits g | nBits < 2 = error "Smallest prime cannot fit in less than 2 bits"
                 | otherwise = findPrime (randBits nBits g) g
    where findPrime (r:rs) g | isprime r g = r
                             | otherwise   = findPrime rs g

printUsage = do
        putStr "Usage: genPrime [nbits]\n" 
        putStr "  Prints a prime number with the specified number of bits\n"
        putStr "  example: 'genPrime 100' creates and prints a 100 bit prime number\n"

main = do
  g <- getStdGen
  args <- getArgs
  if length args /= 1 then 
    printUsage
  else do
    let nBits = read (args !! 0) :: Integer
    print ( genPrime nBits g)
