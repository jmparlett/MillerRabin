primeGen: primeGen.hs
	ghc primeGen.hs -no-keep-hi-files -no-keep-o-files -o genPrime

run: genPrime
	./genPrime
	rm genPrime 

repl: 
	ghci primeGen

