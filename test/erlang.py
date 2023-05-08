#!/usr/bin/python3
from math import factorial
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-t', '--type', choices=['B', 'C'], help='Type of Erlang function')
parser.add_argument('-E', '--E', help='E parameter of Erlang B function')
parser.add_argument('-m', '--m', help='m parameter of Erlang B function')
parser.add_argument('-A', '--A', help='A parameter of Erlang C function')
parser.add_argument('-N', '--N', help='N parameter of Erlang C function')
args = parser.parse_args()

def ErlangB (E, m):
    if E is None or m is None:
        return None
    E=float(E)
    m=int(m)
    InvB = 1.0
    for j in range(1, m+1):
        InvB = 1.0 + InvB * (j/E)
    return (1.0 / InvB)

def ErlangC(A, N):
    if A is None or N is None:
        return None
    A=float(A)
    N=int(N)
    L = (A**N / factorial(N)) * (N / (N - A))
    sum_ = 0
    for i in range(N):
        sum_ += (A**i) / factorial(i)
    return (L / (sum_ + L))

if __name__ == '__main__':
    if args.type == 'B':
        print(ErlangB(args.E, args.m))
    if args.type == 'C':
        print(ErlangB(args.A, args.N))