Cross-chain Bitcoin & Monero Atomic Swap
===

Cross-chain atomic swaps have been discussed for a very long time and are very useful tools. This protocol describes how to achieve atomic swaps between Bitcoin and Monero with two transactions per chain without trusting any central authority, servers, or the other swap participant.

## Scenario
Alice, who owns Monero (XMR), and Bob, who owns Bitcoin (BTC), want to swap their funds. We assume that they already have negotiated the right amount plus some fees or what not.

They want to send funds to a special location on each chain (cross-chain) where each party can take control of the other chain (swap) and the other chain only (atomic).

### Normal scenario
If both follow the protocol 4 transactions will be broadcast into both chains, 2 on Bitcoin and 2 on Monero. The first ones locks the funds and makes them ready for the trade on each chain. The second one unlocks the funds for one participant only and gives knowledge to the other participant who takes control of the output on the other chain.

### Worst case scenario
If the swap is cancelled, 3 Bitcoin transactions are needed instead of 2. This is to avoid a race condition that could allow Alice to gain XMR and BTC. Therefore the worst case is 5 transactions in total across both chains.

## Prerequisites
Conditional executions must be possible in order to achieve trustless swap functionality and ensure atomicity. Bitcoin has a small stack-based script language that allows conditional execution and timelocks. On the other hand, Monero, with its privacy oriented RingCT design, provides single signature per UTXO. That means that control of UTXOs is only related to who controls the associated private keys. The challenge is then to move control of funds only with knowledge of some private key.

This protocol is heavily based on a 2016 Monero StackExchange post that can be found [here](https://monero.stackexchange.com/questions/894/can-you-trustlessly-trade-monero-for-bitcoin/895#895). The concept is roughly the same with some changes in the Bitcoin part, but this protocol is explained in more detail.

