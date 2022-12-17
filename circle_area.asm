

pre:
  li $0, 195
  sm $0, 0

data:
  lm $0, 0
  li $1, 22
  li $2, 7


# r * r * 22 / 7

area:
  mul $0, $0, $0
  mul $0, $1, $0
  div $0, $2, $0

ans:
  sm $0, 1
