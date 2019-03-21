[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

Bitcoin & Monero Cross-chain Atomic Swap
===

[Paper](./whitepaper/xmr-btc.pdf)

## Introduction

Cross-chain atomic swaps have been discussed for a very long time and are very useful tools. In blockchains where hashed timelock contracts are doable atomic swaps are already deployed, but when one blockchain doesn't have this capability it becomes a challenge. This protocol describes how to achieve atomic swaps between Bitcoin and Monero with two transactions per chain without trusting any central authority, servers, nor the other swap participant.

We propose a swap between two participants, one holding bitcoin and the other monero, in which when both follow the protocol their funds are not at risk at any moment. The protocol does not require timelocks on Monero side nor script capabilities.

This protocol is heavily based on a Monero StackExchange post discussing if it's possible to trade Monero and Bitcoin in a trustless manner. The concept is roughly the same, with changes in Bitcoin construction, less prerequisites in Monero, and more detailed explainations.

Participants send funds into a specific address generated during the process (the lock) on each chain (cross-chain) where each party can take control of the funds on the other chain (swap) only (atomic; i.e. claiming of funds on either chain is mutually exclusive from the ability to claim funds from another chain.)

## Known limitations

### Liveness
To provide liveness (if at least one participant is still online) we allow for the worst case scenario in which a participant may end up loosing funds (by not being able to claim on the other chain). This can happen in the case where they do not follow the protocol, e.g. remaining online during pending swap or claiming funds in time. The rationale behind this design is explained in.

**Rationale**: This choice is made to avoid the following case: if monero are locked, Alice will be able to refund them only if Bob refunds his bitcoin first. We need an incentive mechanism to force Bob to spend his refund to prevent a deadlock in the refund process or compensate Alice if Bob does not follow the protocol correctly.

### Fees
Fees are different from one chain to the other partly because of internal blockchain parameters \& transaction complexity, and also due to external factors such as demand for blockspace. Note that within this protocol the Bitcoin blockchain is used as a decision engine, where we use advanced features of bitcoin, which causes bigger transactions on the bitcoin side. These two factors combined make the Bitcoin transactions more expensive in general than those on the Monero chain.

### Instantaneity
Instant user feedback in a cross-chain atomic swap is hard to achieve.  The slowest chain and the number of confirmations required by each participant to consider a transaction final, dictates the speed of the protocol, making front runs possible in some setups. But the protocol can be extended to avoid front runs within certain setups. It is worth noting that front runs cannot be enforced to the other participant, thus making the worst case scenario a redund with fee costs on each chain.

## Building LaTex

A `Makefile` is provided into `whitepaper` folder to compile the project, use

```
make
```

About
===

This is a research project sponsored by TrueLevel, developed by h4sh3d.
