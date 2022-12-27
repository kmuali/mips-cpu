main:
  li   $0, 3
  li   $1, 3
  addi $0, $0, 2
  mul  $0, $1, $0
  subi $0, $0, 10
  sm   $0, 0

fact_init:
 lm    $0, 0
 li    $1, 1 

fact_loop:
  mul  $1, $0, $1
  sm   $1, 0
  subi $0, $0, 1
  bz end
  br fact_loop

end:
