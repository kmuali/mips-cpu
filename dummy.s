
start:
  li $0, -77
  addi $0, $0, -23

complement:
  cpl $0, $0
  addi $0, $0, 1

store:
  sm $0, 0
