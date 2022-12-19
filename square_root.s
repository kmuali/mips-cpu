
# this program does
# MEMORY[1] = sqrt( MEMORY[0] )

pre: # to test sqrt(77)
  li $0, 144
  sm $0, 0

# using newton raphson
# x = x - (x^2 - XX) / (2 * x)

main:
  lm $0, 0
  li $1, 20 # a counter = 10
  li $2, 100 # initial sqrt
  li $6, 2  # constant = 2

loop:   # $2 = $2 - ( $2 * $2 - $0 ) / ( $6 * $2 )
  mul $2, $2, $3
  sub $3, $0, $3
  div $3, $6, $3
  div $3, $2, $3
  sub $2, $3, $2
    sm $2, 1

loop_sub:
  subi $1, $1, 1

loop_cond:
  bz end
  br loop

end:
