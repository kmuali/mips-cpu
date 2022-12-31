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
                print(
                    'when x"{}" => D <= "{}";'.format(
                        ("" if i >= 16 else "0") + hex(i)[2:], ln
                    )
                )
            print('when others => D <= x"0000";', end="\n\n")


KW_CPL = ["cpl"]
KW_NOP = ["nop"]
KW_LI = ["li"]
KW_IMM = "addi subi andi ori xori".split()
KW_ARITH = "add sub mul div and or xor".split()
KW_BR1 = "bc bz br".split()
KW_BR2 = "beq bgt blt".split()
KW_MEM = "lm sm".split()
RES_KW = KW_ARITH + KW_CPL + KW_IMM + KW_LI + KW_MEM + KW_BR2 + KW_BR1 + KW_NOP


def error(index, message):
    exit(f"-- Error: {message} at line {index + 1}")


def argerror(i, cmd):
    error(i, f"Invalid {cmd} arguments")


def alert(message):
    print(f"-- Alert: {message}")


def islabel(s):
    s = s.replace("_", "")
    return s not in RES_KW and s.isalnum()


def isreg(s):
    return s.isdigit() and 0 <= int(s) < 8


def isintable(s):
    return (len(s) <= 1 and s.isdigit()) or (
        (s[0] == "-" or s[0].isdigit()) and s[1:].isdigit()
    )


def isimm(s, n):
    return isintable(s) and -(2 ** (n - 1)) <= int(s) < 2 ** (n - 1)


def tobin(s, n):
    s = bin(int(s))[2:]
    return "0" * (n - len(s)) + s


def tosbin(s, n):
    isneg = int(s) < 0
    s = bin(abs(int(s)))[2:]
    s = "0" * (n - len(s)) + s
    if isneg:
        s = "".join(map(lambda c: str(1 - int(c)), s))
        return tobin(int(s, 2) + 1, n)
    return s


def labeled_blocks_to_bin(labels, blocks):
    bin_lns = []
    for [cmd, *args], i in blocks:
        if cmd in KW_NOP:
            bin_ln = tobin(0, 16)

        elif cmd in KW_MEM:  # $ r , m
            if (
                len(args) == 4
                and args[0] == "$"
                and isreg(args[1])
                and args[2] == ","
                and isimm(args[3], 9)
            ):
                bin_ln = (
                    tobin(KW_MEM.index(cmd) + 8, 4)
                    + tobin(args[1], 3)
                    + tobin(args[3], 9)
                )
            else:
                return argerror(i, cmd)

        elif cmd in KW_LI:  # $ r , n
            if (
                len(args) == 4
                and args[0] == "$"
                and isreg(args[1])
                and args[2] == ","
                and isimm(args[3], 9)
            ):
                bin_ln = "0111" + tobin(args[1], 3) + tosbin(args[3], 9)
            else:
                return argerror(i, cmd)

        elif cmd in KW_BR2:  # $ r , $ r , l
            if (
                len(args) == 7
                and args[0] == args[3] == "$"
                and args[2] == args[5] == ","
                and isreg(args[1])
                and isreg(args[4])
                and args[6] in labels.keys()
            ):
                bin_ln = (
                    tobin(KW_BR2.index(cmd) + 10, 4)
                    + tobin(args[1], 3)
                    + tobin(args[4], 3)
                    + tobin(labels[args[6]], 6)
                )
            else:
                return argerror(i, cmd)

        elif cmd in KW_BR1:  # l
            if len(args) == 1 and args[0] in labels.keys():
                bin_ln = (
                    tobin(KW_BR1.index(cmd) + 13, 4)
                    + tobin(0, 6)
                    + tobin(labels[args[0]], 6)
                )
            else:
                return argerror(i, cmd)

        elif cmd in KW_CPL:  # $ r , $ r
            if (
                len(args) == 5
                and args[0] == args[3] == "$"
                and args[2] == ","
                and isreg(args[1])
                and isreg(args[4])
            ):
                bin_ln = "0001" + tobin(args[1], 3) + "000" + tobin(args[4], 3) + "111"
            else:
                return argerror(i, cmd)

        elif cmd in KW_ARITH:  # $ r , $ r , $ r
            if (
                len(args) == 8
                and args[0] == args[3] == args[6] == "$"
                and args[2] == args[5] == ","
                and isreg(args[1])
                and isreg(args[4])
                and isreg(args[7])
            ):
                bin_ln = (
                    "0001"
                    + tobin(args[1], 3)
                    + tobin(args[4], 3)
                    + tobin(args[7], 3)
                    + tobin(KW_ARITH.index(cmd), 3)
                )
            else:
                return argerror(i, cmd)

        elif cmd in KW_IMM:  # $ r , $ r , n
            if (
                len(args) == 7
                and args[0] == args[3] == "$"
                and args[2] == args[5] == ","
                and isreg(args[1])
                and isreg(args[4])
                and isimm(args[6], 6)
            ):
                bin_ln = (
                    tobin(KW_IMM.index(cmd) + 2, 4)
                    + tobin(args[1], 3)
                    + tobin(args[4], 3)
                    + tosbin(args[6], 6)
                )
            else:
                return argerror(i, cmd)

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
            ln = ln[: ln.index("#")]
        ln = ln.lower()

        # tokenize
        for ch in ":$,":
            ln = ln.replace(ch, f" {ch} ")
        tks = ln.split()

        # labeling
        if ":" in tks:
            if (
                len(tks) == 2
                and tks[0] not in labels.keys()
                and islabel(tks[0])
                and tks[1] == ":"
            ):
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

    return labeled_blocks_to_bin(labels, blocks)


if __name__ == "__main__":
    main()
