
# this program does
# MEMORY[1] = sqrt( MEMORY[0] )

# using newton raphson
# x = x - (x^2 - XX) / (2 * x)

main:
  li $0, 77
  li $1, 20 # a counter = 10
  li $2, 100 # initial sqrt
  li $6, 2  # constant = 2

# $2 <= $2 - ( $2 * $2 - $0 ) / ( $6 * $2 )
# $2 <= ( $2 * $2 + $0 ) / ( $6 * $2 )
loop_body:   
  mul $2, $2, $3
  add $3, $0, $3
  div $3, $6, $3
  div $3, $2, $2
  sm $2, 1

loop_sub:
  subi $1, $1, 1

loop_cond:
  bz end
  br loop

end:
