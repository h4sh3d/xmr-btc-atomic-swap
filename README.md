Cross-chain Bitcoin & Monero Atomic Swap
===

Cross-chain atomic swap are discussed for a very long time and are a very useful feature.
This paper describe how to do an atomic swap between Bitcoin and Monero with only one transaction
per blockchain (without spending the swap).

## Prerequisites
To be faisible some prerequisites are needed on both blockchains. Bitcoin has a very flexible
scripting language that allows conditional execution and timelocks. Thus, Monero has very
limited capabilities when it comes to lock funds in a custom way. Nevertheless, it is possible
to achive conditional execution with some tricks.

### Monero
**T-of-N multi-signature scheme:**
to enable multi-path execution in Monero, a t-of-n multi-signature scheme is used, more precisely
a 3-of-4 scheme.


### Bitcoin
**Timelock:**
to enable the possibility of cancel the swap even if the transaction is on the blockchain.

**Hashlock:**
to enable the trigger mechanism to activate the swap. A hashlock is a condition that require
a party to reveal a secret (pre-image) associated to a given hash.

## Scheme
Alice, who owns Monero (XMR), and Bob, who owns Bitcoin (BTC), want to swap an arbitrary amount.
To enable the swap they need to create a XMR transaction and a BTC transaction and broadcast them
on each blockchain. When both transaction are on-chain, Bob can trigger the swap or cancel after
an pre-define amount of time (timelock). If Bob trigger the swap, Alice---before the end of the
timelock---can spend the BTC. If the BTC are spend, Bob can spend the XMR, if Bob cancel the swap
after the timelock, Alice can spend the XMR.

### Worst case scenario
Like described in the previous scheme, if Bob doesn't unlock the BTC, Alice cannot get back her XMR.
In the case of an non-cooperation by Bob both funds are locked, both party loose in the trade.
(thus, to attack an other party one can bet on change of the value over the time.)
In the case when Bob disappear (death) and nobody can access the BTC and spend it, XMR are locked
forever.

### Protocol
The protocol describe how to achieve the broadcasting of both transaction in a trustless manner
and safely.

#### BTCSwapScript
The BTCSwapScript is a custom Bitcoin script used to insure the sequence of the swap. There are
two possible execution paths: Alice can spend with two secrets and hes signature, and Bob can
spend, after a timelock, with one secret and his signature.

```
OP_IF
    <BTCAlice's pubkey> OP_CHECKSIGVERIFY
    OP_HASH160 <h> OP_EQUALVERIFY
    OP_HASH160 <h''> OP_EQUAL
OP_ESLE
    <BTCBob's pubkey> OP_CHECKSIG
    OP_HASH160 <h'> OP_EQUALVERIFY
    <timelock> OP_CHECKSEQUENCEVERIFY OP_DROP
OP_ENDIF
```

#### T-of-N XMR multi-signature
The Bitcoin kind of notation is used to describe the multi-signature.

```
3 <s> <s'> <XMRAlice's pubkey> <XMRBob's pubkey> 4
```

#### Design

```
             Alice (XMR)                             Bob (BTC)

  s <- 2^256 bits random
  h <- HASH(s)

                        < h, BTCAlice's pubkey >
                      ---------------------------->

                                                s' <- 2^256 bits random
                                                h' <- HASH(s')
                                                s'' <- 2^256 bits random
                                                h'' <- HASH(s')
                                                BTX <- create BTC tx

                    < h', h'', BTX, XMRBob's pubkey >
                      <----------------------------

  verify BTX
  broadcast BTX

  (watch BTX for cancelation after timelock)

  XTX <- create XMR tx

                                  < XTX >
                      ---------------------------->

                                                validate XTX
                                                broadcast XTX

                                  < s'' >
                      <----------------------------

  spend BTX w/ s, s'', BTCAlice

                                (watch BTX)
                      - - - - - - - - - - - - - - >

                                                 spend XTX w/ s, s', XMRBob
```

First Alice create the first secret (s) and compute the hash of it (h) and she send her
BTC address and the hash (h). When Bob receive the hash and Alice's public key he create
to secret (s' and s'') and their hashes (h' and h'') and he create the Bitcoin transaction
with the custom script BTCSwapScript as the P2SH swap output. He sent to Alice the two
hashes (h' and h''), the Bitcoin transaction and his Monero address. When Alice receive
the data, she verify the Bitcoin transaction and, if correct, broadcast it. Then she create
the Monero transaction and sent it to Bob. When Bob receive the Monero transaction, he verify
it and, if correct, broadcast it. Then he sent the third secret (s'') to trigger the swap.

At this point (before sending the secret s''), Alice knows: s, BTCAlice's private key,
and XMRAlice's private key; Bob knows: s', s'', BTCBob's private key, and XMRBob's private
key. So nobody can claim their funds in the other chain, only Bob can, after the timelock,
cancel the swap by tacking his BTC back and reveal the secret need by Alice to unlock her XMR.
After sharing the secret s'', Alice can claims the BTC with s, s'', and her signature,
to doing it she needs to reveal the secret s, so Bob can spend the XMR with s, s', and his
signature.
