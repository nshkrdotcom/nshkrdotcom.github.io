---
title: "Temporal Blockchain: Mathematical Model"
date: 2025-03-05
draft: false
---

# Temporal Blockchain: Mathematical Model

This document compiles all key mathematical equations and formulas used throughout the Temporal Blockchain System, providing a single, consistent reference for all mathematical aspects. Formal definitions of variables and parameters are included.

## 1. Temporal Distributed Trust Architecture

**Equation:**

$$T(C, t) = \sum_{i=1}^{n} w_i(t) \cdot v_i(C, t) \cdot r_i(t)$$

**Definitions:**

*   $T(C, t)$: Trust value of claim $C$ at time $t$.
*   $n$: Total number of Temporal Mining Nodes (TMNs).
*   $w_i(t)$: Weight of TMN $i$ at time $t$.
*   $v_i(C, t)$: Validation score from TMN $i$ for claim $C$ at time $t$ (normalized to a 0-1 range).
*   $r_i(t)$: Temporal reputation coefficient of TMN $i$ at time $t$ (normalized to a 0-1 range).

**Diversity Constraint:**
$$D = -\sum_{i=1}^{n} p_i \log p_i > D_{min}$$

**Definitions**
*  $D$: Diversity value.
* $p_i$: Proportional influence/weight of node "type" (groups of common methods/hardware).
* $D_{min}$: A configured minimum threshold.

## 2. Temporal Asymmetric Resistance

**Equation:**

$$R(a, t) = k \cdot \left(\frac{P(a, t)}{P_{baseline}(t)}\right)^\alpha \cdot TF(a, t)$$

**Definitions:**

*   $R(a, t)$: Systemic resistance encountered by actor $a$ at time $t$.
*   $k$: Scaling constant.
*   $P(a, t)$: Power level of actor $a$ at time $t$.
*   $P_{baseline}(t)$: Baseline power level at time $t$.
*   $\alpha$: Resistance exponent ($\alpha > 1$).
*   $TF(a, t)$: Temporal factor based on $a$'s historical temporal accuracy.

## 3. Temporal Attribution Chains

**Attribution Chain Structure:**

$$A(I) = \{(s_1, r_1, t_1, h_1), (s_2, r_2, t_2, h_2), ..., (s_n, r_n, t_n, h_n)\}$$

**Definitions:**

*   $A(I)$: Attribution chain for information $I$.
*   $s_i$: Source entity at step $i$.
*   $r_i$: Relationship/transformation at step $i$.
*   $t_i$: Hardware-verified timestamp from TMNs at step $i$.
*   $h_i$: Hardware attestation cryptographic proof at step $i$.

**Integrity Verification:**

$$V(A(I)) = \prod_{i=1}^{n} v(s_i, r_i, t_i, h_i, s_{i+1})$$

**Definitions:**
*  $V(A(I))$: Result (boolean) of the validation across the entire chain.
*   $v(s_i, r_i, t_i, h_i, s_{i+1})$: Verification function for each link in the chain.

## 4. Proof of Temporal Authority (PoTA) Consensus

### 4.1 Vote Weighting

**Equation:**

$$W(a) = \alpha \cdot R(a, t) + (1 - \alpha) \cdot S(a, t)$$

**Definitions:**

*   $W(a)$: Voting weight of agent $a$.
*   $R(a, t)$: Temporal reputation of agent $a$ at time $t$ (normalized to a 0-1 range).
*   $S(a, t)$: Stake of agent $a$ at time $t$ (normalized to a 0-1 range).
*   $\alpha$: Parameter controlling the relative importance of reputation vs. stake (0 ≤ α ≤ 1).

### 4.2 Reputation Update Rule

**Equation:**

$$R(a, t+1) = R(a, t) + \beta \cdot (Accuracy(a, t) - R(a, t)) - \gamma \cdot Penalty(a, t)$$

**Definitions:**

*   $R(a, t+1)$: Updated reputation of agent $a$ at time $t+1$.
*   $R(a, t)$: Reputation of agent $a$ at time $t$.
*   $\beta$: Learning rate for reputation updates (0 < β < 1).
*   $Accuracy(a, t)$: Accuracy of agent $a$'s timestamps in the block at time $t$ (normalized to a 0-1 range).
*   $\gamma$: Penalty coefficient (γ ≥ 0).
*   $Penalty(a, t)$: Penalty applied to agent $a$ at time $t$ (normalized to a 0-1 range).

### 4.3 Accuracy Calculation

**Equation:**

$$Accuracy(a, t) = 1 - \frac{|T_{node}(a, t) - T_{consensus}(t)|}{ToleranceWindow(t)}$$

**Definitions:**

*    $T_{node}(a, t)$: Timestamp provided by node $a$ in the block at time $t$.
*    $T_{consensus}(t)$: Final consensus timestamp for the block at time $t$.
*   $ToleranceWindow(t)$: Acceptable tolerance window at time $t$.
*    Result is normalized (0-1) scale.

### 4.4 Byzantine Fault Tolerance Condition

**Equation:**

$$W_{faulty} < \frac{1}{3} W_{total}$$

**Definitions:**

*   $W_{faulty}$: Total voting power of faulty validators.
*   $W_{total}$: Total voting power of all validators.

Or, if using a *reputation based model* for voting/governance, a rule *can* exist: where the **total** influence from actors *proven, later* as bad/malicious: cannot ever exceed 1/3 of total.

### 4.5 System-Wide Temporal Accuracy

**Equation:**

$$Accuracy_{system}(t) = 1 - \frac{|T_{consensus}(t) - T_{true}(t)|}{MaximumDeviation}$$

**Definitions:**

*   $T_{consensus}(t)$: Consensus timestamp for block at time $t$.
*   $T_{true}(t)$: "True" time at time $t$ (as determined by the TMNs' atomic clocks).
*   $MaximumDeviation$: System-wide parameter defining the maximum acceptable deviation.

## 5. Drift Compensation (Kalman Filter - Simplified)

While the full Kalman filter involves multiple equations, a simplified representation for the drift correction is:

**Equation:**

$$T_{corrected}(t) = T_{measured}(t) - DriftEstimate(t)$$

**Definitions:**

*    $T_{corrected}(t)$: Corrected time at time $t$.
*   $T_{measured}(t)$: Measured time from the atomic clock at time $t$.
*   $DriftEstimate(t)$: Estimated clock drift at time $t$, calculated by the Kalman filter.

## 6. Offline Timestamp Verification

Verification involves checking against pre-shared initialization vectors. No single equation fully captures this; it is a multi-step process.

## 7. Time-Manipulation Resistance

**Equation:**
$$R_{time}(a) = C \cdot (1 - e^{-k \cdot N_{diverse}}) \cdot \log(S_{temporal})$$

**Definitions**:
* $R_{time}(a)$: System's resistance against an actor `a` attempting to change time values.
*   $C$: System constant.
*   $N_{diverse}$: Number of diverse TMNs in the network.
*    $S_{temporal}$: Temporal stake required to participate in consensus.

## 8. Long-Term Time Security
**Equation:**
$$S_{long}(t) = S_0 \cdot e^{-\lambda t} \cdot \sqrt{N_{TMN}(t)}$$

**Definitions**:
* $S_{long}(t)$: Long term security levels at a time `t`.
*    $S_0$: Initial security parameter.
*    $\lambda$: Decay constant related to cryptographic security.
*    $N_{TMN}(t)$: Projected number of active TMNs at time $t$.

## 9. Offline Security Guarantee
**Equation:**
$$S_{offline}(t, \Delta t) = S_{base} \cdot (1 - \frac{\Delta t}{t_{max}})^2 \cdot e^{-\alpha \cdot \Delta t}$$

**Definitions:**
*   $S_{offline}(t, \Delta t)$: Security guarantees during an offline period, that begins at `t`, lasting `\Delta t` units of time.
*  $\Delta t$: Duration of offline operation.
*   $t_{max}$: Maximum secure offline period.
*   $\alpha$: Drift coefficient of the atomic clocks.
* $S_{base}$: Security when the system is online.

This document serves as a comprehensive reference for the core mathematical underpinnings of the Temporal Blockchain system.

---

