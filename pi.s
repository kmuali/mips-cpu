

main:
  li $0, 220
  li $1, 7
  li $2, 10

mult:
  mul $0, $2, $0
  div $0, $1, $0

end:
  sm $0, 0
