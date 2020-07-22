[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

Bitcoin & Monero Cross-chain Atomic Swap
===

[Paper](./whitepaper/xmr-btc.pdf)

## Abstract

In blockchains where hashed timelock contracts are possible atomic swaps are already deployed, but when one blockchain doesn't have this capability it becomes a challenge. This protocol describes how to achieve atomic swaps between Bitcoin and Monero with two transactions per chain without trusting any central authority, servers, nor the other swap participant.  We propose a swap between two participants, one holding bitcoin and the other monero, in which when both follow the protocol their funds are not at risk at any moment. The protocol does not require timelocks on Monero side nor script capabilities but does require two proofs of knowledge of equal discrete logarithm across  the edward25519 and the secp256k1 groups and ECDSA one-time VES.

## Building LaTex

A `Makefile` is provided into `whitepaper` folder to compile the project, use

```
make
```

## About

This research project have been sponsored by the Monero Community and initiated by TrueLevel SA in 2018, developed by h4sh3d and presented at 36C3 with zkao.
