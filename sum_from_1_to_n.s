
main:
  li  $0, 0
  li  $1, 1
  li  $2, 10

loop:
  add  $0, $1, $0
  beq  $1, $2, end
  addi $1, $1, 1
  br   loop

end:
  sm   $0, 0
