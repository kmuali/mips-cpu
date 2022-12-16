
# calculate 3 to the power 4
# answer is written to M[0]

main:
        li  $0, 1 # answer
        li  $1, 3 # base
        li  $2, 4 # start power
        li  $3, 1 # end power

loop:
        blt  $2, $3, end
        mul  $0, $1, $0
        subi $2, $2, 1
        br   loop



end:   
      sm $0, 0
