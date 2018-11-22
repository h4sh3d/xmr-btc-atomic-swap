Cross-chain Bitcoin & Monero Atomic Swap
===

Cross-chain atomic swaps have been discussed for a very long time and are very useful tools. This protocol describes how to achieve atomic swaps between Bitcoin and Monero with two transactions per chain without trusting any central authority, servers, or the other swap participant.

## Scenario
Alice, who owns Monero (XMR), and Bob, who owns Bitcoin (BTC), want to swap their funds. We assume that they already have negotiated the right amount plus some fees or what not.

They want to send funds to a special location on each chain (cross-chain) where each party can take control of the other chain (swap) and the other chain only (atomic).

### Normal scenario
If both follow the protocol 4 transactions will be broadcast into both chains, 2 on Bitcoin and 2 on Monero. The first ones locks the funds and makes them ready for the trade on each chain. The second ones unlock the funds for one participant only and give knowledge to the other that take control of the other chain.

### Worst case scenario
In the swap is cancelled, 3 Bitcoin transactions are needed instead of 2. This is to avoid a race condition that could allow Alice to gain XMR and BTC. The worst case is then 5 transactions in total.

## Prerequisites
Conditional executions must be allowed to achieve the swap and ensure atomicity. Bitcoin has a small stack-based script language that allows conditional execution and timelocks. On the other hand, Monero, with its privacy oriented RingCT design, provides single signature per UTXO. That means that control of UTXOs is only related to who controls the associated private keys. The challenge is then to move control of funds only with knowledge of some private key.

This protocol is heavily based on an old Monero StackExchange post that can be found [here](https://monero.stackexchange.com/questions/894/can-you-trustlessly-trade-monero-for-bitcoin/895#895). The concept is roughly the same with some changes in the Bitcoin part, but this protocol is explained in more detail.

We describe some components required for each chain.

### Monero
**2-out-of-2 scheme:**
to enable multi-path execution in Monero, a 2-out-of-2 multisig is used. In reality we will not use any multi-signing protocol, the private spend key is split in two parts during the swap process but at the end one participant will gain knowledge of the full key. So it's more a secret sharing that a multisig and then it's not really a requirement for Monero.

**Pre-image non-interactive zero-knowledge proofs of knowledge:**
to prove to the other participant that a valid pre-image to a given hash is known and within a range, e.g. > 0 and < l where l is related to edward25519 curve.

**edward25519 private key non-interactive zero-knowledge proofs of knowledge:**
to prove to the other participant that a valid private key is known, e.g. signatures are valid non-interactive zero-knowledge proof given a public key.

### Bitcoin
**Timelock:**
to enable new execution paths after some predefined amount of time, i.e. cancelling the swap even after having locked funds on-chain.

**Hashlock:**
to reveal secrets to the other participant. Hashlocks are mini-scripts that require the sender to reveal some data (a pre-image) associated with a given hash.

**2-out-of-2 multisig:**
to create the refund path.

## Protocol
The protocol moves XMR funds into an address (e.g. 2-out-of-2 multisig) where each participant controls half of the key. We then use the Bitcoin scripting language to reveal one or the other half of the private spend key. Bitcoin transactions are designed in such a way that if a participant follows the protocol he can't terminate with a loss.

If the deal goes through, Alice spends the BTC by revealing her half private key that allows Bob to spend the XMR. If the deal is cancelled, Bob spends the BTC by revealing his half private key that allows Alice to spend the XMR, both lose chain fees, in this case Bob is disadvantaged because of the 3 "heavy" BTC transactions.

### Bitcoin scripts

#### SWAPLOCK
SWAPLOCK is a P2SH used to lock funds and defines the two execution paths: (1) normal and (2) refund [cancel].

```
OP_IF
    <BTCAlice's pubkey> OP_CHECKSIGVERIFY
    OP_SHA256 <h_0> OP_EQUALVERIFY
    OP_SHA256 <h_2> OP_EQUAL
OP_ESLE
    2 <BTCAlice's pubkey> <BTCBob's pubkey> 2 OP_CHECKMULTISIGVERIFY
    <timelock_0> OP_CHECKSEQUENCE
OP_ENDIF
```

#### REFUND
REFUND is a second P2SH used in the case the swap already started on-chain but is cancelled. This refund script is used as the only output of a transaction that spends the SWAPLOCK output with the 2-out-of-2 timelocked multisig.

```
OP_IF
    <BTCBob's pubkey> OP_CHECKSIGVERIFY
    OP_SHA256 <h_1> OP_EQUAL
OP_ESLE
    <BTCAlice's pubkey> OP_CHECKSIGVERIFY
    <timelock_1> OP_CHECKSEQUENCE
OP_ENDIF
```

### 2-out-of-2 private XMR spend key
Full XMR private key is a pair of edward25519 private/public keys. The first pair is called view keys and the second spend keys. We use small letter to denote private keys and caps for public keys such that

```
A = aG
```

We denote

* the private key `a` as the private view key and `A` the public view key,
* and the private key `x` as the private spend key and `X` the public spend key.

#### Partial keys
We denote partial private keys as `a_0` and `a_1` such that

```
a_0 + a_1 = a mod l
```

where `l` is a edward25519 curve parameter. And then

```
A_0 = a_0G
A_1 = a_1G
A_0 + A_1 = (a_0 + a1)G = aG = A
```

The same is true for `x` with `x_0` and `x_1`.

### Zero-Knowledge proofs
Two zero-knowledge proofs are required at the begining of the protocol for the trustlessness. They are quite symetric but Bob needs to prove one more information to Alice. We denote Alice's ZKP basic ZKP and Bob's one extended ZKP.

#### Basic ZKP
Alice must prove to Bob that

```
x := valid private key on edward25519 curve
X := xG
h := H(x)

Given X, h prove that:

    it exists x such that X = xG and h = H(x)                        (1)

for H := SHA256
```

#### Extended ZKP
Bob must prove to Alice that

```
x  := valid private key on edward25519 curve
X  := xG
h  := H(x)
s  := random 32 bytes data
h' := H(s)

Given X, h, h' prove that:

    there exists x, s such that X = xG and h = H(x) and h' = H(s)    (2)
    with s in range [0, 2^256]                                       (3)

for H := SHA256
```

### Design

```
             Alice (XMR)                             Bob (BTC)

  a_0             [partial priv view key ]     a_1
  x_0             [partial priv spend key]     x_1
  X_0             [partial pub spend key ]     X_1
  b_a             [priv BTC key          ]     b_b
  B_a             [pub BTC key           ]     B_b
  h_0 := H(x_0)                                h_1 := H(x_1)
                                               s := 256 random bits
                                               h_2 := H(s)
  z_0 := zkp(x_0, X_0, h_0)                    z_1 := zkp(x_1, X_1, h_1, s, h_2)


          < a_0, a_1, X_0, X_1, B_a, B_b, h_0, h_1, h_2, z_0, z_1 >
                      <--------------------------->

   verify(z_1)                                  verify(z_0)

                           a = a_0 + a_1 mod l
                           A = aG
                           X = X_0 + X_1

                                                create Btx_1 w/ SWAPLOCK
                                                create Btx_2 w/ REFUND
                                                sign(Btx_2)


                             < Btx_1, Btx_2 >
                      <----------------------------

  verify(Btx_1, Btx_2)
  sign(Btx_2)

                             < Btx_2 signed >
                      ---------------------------->

                                                verif(Btx_2 signed)
                                                broadcast(Btx_1)

                               (watch Btx_1)
                      < - - - - - - - - - - - - - -

  wait for Btx_1 n confirmations
  create Xtx w/ A, X
  broadcast(Xtx)

                            (watch Xtx w/ A, X)
                      - - - - - - - - - - - - - - >

                                                wait for Xtx n' confirmations
                                                verify(Xtx) w/ A, X

                                   < s >
                      <----------------------------

  spend Btx_1 w/ s, x_0, b_a

                             (watch Btx_1 UTXO)
                      - - - - - - - - - - - - - - >

                                                 x = x_0 + x_1 mod l
                                                 spend Xtx w/ x

```
