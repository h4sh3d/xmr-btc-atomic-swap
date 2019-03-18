Bitcoin & Monero Cross-chain Atomic Swap
===

[Paper](./whitepaper/xmr-btc.pdf)

## Introduction

Cross-chain atomic swaps have been discussed for a very long time and are very useful tools. This protocol describes how to achieve atomic swaps between Bitcoin and Monero with two transactions per chain without trusting any central authority, servers, nor the other swap participant. We propose a swap between two parties, one holding bitcoins and the other monero.

We describe a protocol for an on-chain atomic swap between Monero and Bitcoin, but the protocol can be generalize to Monero and any other cryptocurrencies that fulfill the same requirements as Bitcoin.

This protocol is heavily based on a Monero StackExchange post discussing if it's possible to trade Monero and Bitcoin in a trustless manner \cite{MoneroStackexchangeSwap}. The concept is roughly the same, with some changes in the Bitcoin part and is explained in more detail; they send funds to a special location on each chain (cross-chain) where each party can take control of the other chain (swap) and the other chain only (atomic).

## Known limitations
To provide finality (if at least one participant is still online) we allow the worst case scenario to end up with one participant loosing his funds, but this case should only happen with negligible probability.

**Rationale**: This choice is made to avoid the following case: if monero are locked, Alice will be able to refund them only if Bob refund his bitcoins first, we need an incentive mechanisme to force Bob to spend his refund.

Fees are different from one chain to the other because of internal blockchain parameters and transaction complexity. Because the Bitcoin blockchain is used as a decision engine transactions are, related to Bitcoin transactions, complexe and then expensive. Thus making the Bitcoin chain expensier than the Monero chain.

Speed in cross-chain atomic swap is hard to achieve, the slowest chain and the number of confirmations dictate the speed of the protocol, making front runs possible in some cases.


## Building laTex

A `Makefile` is provided into `whitepaper` folder to compile the project, use

```
make
```

About
===

This is a research project sponsored by TrueLevel, developed by h4sh3d.
