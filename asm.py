#!/bin/python3

# written by Karim M. Ali in Dec 15~16 2022
# created to serve our MIPS design on VHDL

import os.path
import sys

def main():
    if len(sys.argv) == 1:
        return alert("Provide at least a file to assemble")
    for arg in sys.argv[1:]:
        if not os.path.isfile(arg):
            alert(f"File {arg} is not a file")
        else:
            alert(f"Assembling {arg}")
            for i, ln in enumerate(asm_to_bin(open(arg).readlines()).splitlines()):
                print('when x"{}" => D <= "{}";'.format(
                    ("" if i >= 16 else "0")+hex(i)[2:],
                    ln
                ))
            print('when others => D <= x"0000";')


RES_KW = "add sub mul div and or xor cpl addi subi andi ori xori \
    li lm sm beq blt bgt bc bz br nop".split()

def error(index, message):
    exit(f"[ERROR] {message} at line {index + 1}")

def alert(message):
    print(f"[ALERT] {message}")

def islabel(s):
    s=s.replace("_","")
    return s not in RES_KW and s.isalnum()

def isreg(s):
    return s.isdigit() and 0<=int(s)<8

def isimm(s, n):
    n=n if n<8 else 8
    return s.isdigit() and 0<=int(s)<2**n

def tobin(s, n):
    s=bin(int(s))[2:]
    return "0"*(n-len(s))+s

def make_bin(labels, blocks):
    bin_lns=[]
    for [cmd, *args], i in blocks:
        if cmd=="nop":
            bin_ln=tobin(0,16)
        elif cmd in ("lm", "sm"): # $ r , m
            if len(args)==4 and args[0]=="$" and \
                    isreg(args[1]) and args[2]=="," and \
                    isimm(args[3],9):
                bin_ln=tobin(("lm", "sm").index(cmd)+8,4) + tobin(args[1], 3) + tobin(args[3], 9)
            else:
                return error(i, f"Invalid {cmd} arguments")
        elif cmd=="li": # $ r , n
            if len(args)==4 and args[0]=="$" and \
                    isreg(args[1]) and args[2]=="," and \
                    isimm(args[3],9):
                bin_ln="0111"+tobin(args[1],3)+tobin(args[3],9)
            else:
                return error(i, f"Invalid {cmd} arguments")
        elif cmd in ("beq", "bgt", "blt"): # $ r , $ r , l
            if len(args)==7 and args[0]==args[3]=="$" and args[2]==args[5]=="," and \
                    isreg(args[1]) and isreg(args[4]) and args[6] in labels.keys():
                bin_ln=tobin("egl".index(cmd[1])+10,4) + tobin(args[1],3) + tobin(args[4],3) + tobin(labels[args[6]],6)
            else:
                return error(i, f"Invalid {cmd} arguments")
        elif cmd in ("bc", "bz", "br"): # l
            if len(args)==1 and args[0] in labels.keys():
                bin_ln=tobin("czr".index(cmd[1])+13,4)+tobin(0,6)+tobin(labels[args[0]],6)
            else:
                return error(i, f"Invalid {cmd} arguments")
        elif cmd=="cpl": # $ r , $ r
            if len(args)==5 and args[0]==args[3]=="$" and args[2]=="," and \
                    isreg(args[1]) and isreg(args[4]):
                bin_ln="0001"+tobin(args[1],3)+"000"+tobin(args[4],3)+"111"
            else:
                return error(i, f"Invalid {cmd} arguments")
        elif cmd in "add sub mul div and or xor".split(): # $ r , $ r , $ r
            if len(args)==8 and args[0]==args[3]==args[6]=="$" and args[2]==args[5]=="," and \
                    isreg(args[1]) and isreg(args[4]) and isreg(args[7]):
                bin_ln="0001"+tobin(args[1],3)+tobin(args[4],3)+tobin(args[7],3)+tobin(
                    "add sub mul div and or xor".split().index(cmd), 3)
            else:
                return error(i, f"Invalid {cmd} arguments")
        elif cmd in "addi subi andi ori xori".split(): # $ r , $ r , n
            if len(args)==7 and args[0]==args[3]=="$" and args[2]==args[5]=="," and \
                    isreg(args[1]) and isreg(args[4]) and isimm(args[6],6):
                bin_ln=tobin("addi subi andi ori xori".split().index(cmd)+2,4)+\
                    tobin(args[1],3)+tobin(args[4],3)+tobin(args[6],6)
            else:
                return error(i, f"Invalid {cmd} arguments")
        else:
            return error(i, f"Command {cmd} is not implemented yet")
        bin_lns.append(bin_ln)

    # print(labels)
    # print(blocks)
    return "\n".join(bin_lns)

def asm_to_bin(asm_lines):
    labels = dict()
    blocks = []
    act_idx = 0
    for i, ln in enumerate(asm_lines):
        # cutting comments
        if "#" in ln:
            ln=ln[:ln.index("#")]
        ln=ln.lower()
        # tokenize
        for ch in ":$,":
            ln=ln.replace(ch, f" {ch} ")
        tks=ln.split()
        # labeling
        if ":" in tks:
            if len(tks)==2 and tks[0] not in labels.keys() and \
                    islabel(tks[0]) and tks[1]==":":
                labels.update({tks[0]: act_idx})
                # blocks.append([  ])
            else:
                return error(i, "Invalid labeling")
        elif tks:
            if tks[0] in RES_KW:
                # if not labels:
                    # return error(i, "Initial labeling expected")
                blocks.append([tks, i])
                act_idx += 1
            else:
                return error(i, "Unknown keyword")
    return make_bin(labels, blocks)


if __name__=="__main__":
    main()
