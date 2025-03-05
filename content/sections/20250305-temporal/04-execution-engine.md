---
title: "Temporal Blockchain: Temporal Execution Engine Specification"
date: 2025-03-05
draft: false
---

# Temporal Blockchain: Temporal Execution Engine Specification

This document specifies the Temporal Execution Engine (TEE), the component of the Temporal Blockchain System responsible for executing smart contracts with native temporal capabilities. The TEE extends traditional blockchain execution engines with features that allow contracts to interact directly with the hardware-secured consensus time, enabling autonomous, time-triggered operations.

## 1. Overview

The Temporal Execution Engine is a deterministic, sandboxed virtual machine that executes smart contract code.  It builds upon existing virtual machine technology (e.g., EVM-compatible) but adds crucial temporal extensions:

*   **Hardware-Secured Time Access:**  Contracts can access the consensus-verified time directly through new opcodes, without relying on external oracles.
*   **Temporal Scheduling:**  Contracts can schedule future function calls to be executed at specific times, verified by the blockchain's consensus mechanism.
*   **Temporal State Management:** The engine manages the scheduling and execution of time-based operations, ensuring they are processed in the correct order and with proper validation.
*   **Security Enhancements:**  Mechanisms to prevent time-based exploits and ensure the integrity of temporal operations.

## 2. New Opcodes

The TEE introduces new opcodes to enable temporal functionality:

*   **`TIMESTAMP_NOW` (0x40):**
    *   **Input:** None
    *   **Output:**  The current consensus-verified time, as a 256-bit unsigned integer representing nanoseconds since the Unix epoch.
    *   **Gas Cost:**  Low (similar to other basic opcodes like `GAS`).
    *   **Description:**  Provides direct access to the hardware-secured consensus time. This value is guaranteed to be monotonically increasing and consistent across all nodes in the network.

*   **`SCHEDULE_CALL` (0x41):**
    *   **Input:**
        *   `gas`:  The amount of gas to allocate for the scheduled call.
        *   `target_address`: The address of the contract to be called.
        *   `value`: The amount of native currency (if any) to transfer with the call.
        *   `data_offset`:  Offset into memory for the call data.
        *   `data_length`: Length of the call data.
        *   `timestamp`: The consensus-verified time at which the call should be executed.
    *   **Output:**  A unique identifier for the scheduled call (e.g., a hash of the parameters).  This ID can be used to check the status of the scheduled call or (optionally) to cancel it.
    *   **Gas Cost:**  Medium-high (depends on the size of the data and the scheduled time).  A portion of the gas cost might be charged upfront, with the remainder refunded if the call is executed successfully.
    *   **Description:**  Schedules a function call to be executed at a specific future time. The call will *only* be executed *after* the specified `timestamp` has been reached and confirmed by consensus.

*   **`AFTER` (0x42):**
    *    **Input**:
        * `timestamp`: The timestamp for a check if *that has occurred already* in consensus (verified global clock on the system).
    * **Output:** Boolean. True: time reached. False: not met.
    *   **Gas Cost:** Low.
    *   **Description:** A simplified conditional to provide easy-to-use syntax: executes that program branch if global blockchain time has exceeded the provided parameter; otherwise fails/halts/or could include a `BEFORE`/`AFTER`/`ELSE` construction.

*   **`BEFORE` (0x43):**
  *   **Input**:
     *   `timestamp`: The value for clock that hasn't occurred in consensus yet (according to consensus' system of time).
  * **Output**: Boolean: TRUE (hasn't happened), or FALSE (already happened).
    *   **Gas Cost:**  Low.
  * Description: As the logical opposite of the `AFTER` opcode, designed to be simple to use, offering standard and typical uses/requirements.

*  **`CANCEL_SCHEDULED_CALL` (0x44) (Optional):**
    * **Input:**
        *  `call_id`: unique id generated for a prior scheduling operation
    *  **Output**: Success/Failure code
    * **Gas Cost**: Medium.
     * **Description:** If supported, this offers a path to reverse calls added into the processing queue.

* **`CHECK_SCHEDULED_CALL` (0x45) (Optional)**
   * **Input:**
        *   `call_id`: The unique identifier of the scheduled call.
   *   **Output:** status code (indicating if call is Pending, Executed, Cancelled, Failed - with reason)
  *   **Gas Cost**: Low

## 3. Self-Triggering Contracts

The combination of `TIMESTAMP_NOW` and `SCHEDULE_CALL` enables the creation of *self-triggering contracts*.  These contracts can execute autonomously based on temporal conditions, without requiring external triggers.

**Example:**  A simple time-locked savings contract:

```solidity
pragma solidity ^0.8.0;

contract TimeLockedSavings {
    address public beneficiary;
    uint256 public unlockTime;

    constructor(address _beneficiary, uint256 _unlockTime) {
        beneficiary = _beneficiary;
        unlockTime = _unlockTime;
    }

    function withdraw() public {
        require(block.timestamp >= unlockTime, "Funds are still locked"); //Using Block.Timestamp for comparisons.
        require(msg.sender == beneficiary, "Only beneficiary can withdraw");

        payable(beneficiary).transfer(address(this).balance);
    }

     function withdraw_tee() public {
          require(TIMESTAMP_NOW >= unlockTime, "Funds Locked");
          require(msg.sender == beneficiary, "Not Authorized");
          payable(beneficiary).transfer(address(this).balance);
      }
}
```

This contract can be modified, by including SCHEDULE_CALL, such that the contract can execute the `withdraw` logic *automatically*. The `unlockTime` is not tied to the blockchain *block time*: this time-lock leverages global time consensus as verified on the system.

## 4. Temporal State Management

The TEE maintains a schedule of pending function calls, ordered by their execution timestamps. This schedule is part of the blockchain state and is replicated across all nodes.

*   **Scheduling:** When a `SCHEDULE_CALL` opcode is executed, the call details (target address, value, data, timestamp) are added to the schedule.
*   **Ordering:** The schedule is maintained as a priority queue, ordered by the execution timestamp.
*   **Execution:** At each block, the TEE checks the schedule for any calls whose execution timestamp has been reached or passed.  These calls are executed in order.
*   **Atomicity:**  A scheduled call is executed atomically.  If the call fails (e.g., due to insufficient gas or a revert), the entire transaction is reverted, and the call is removed from the schedule (or potentially rescheduled, depending on the contract logic).
*   **Persistence:** The schedule is persisted across blocks, ensuring that scheduled calls are not lost if a node restarts or if there is a chain reorganization.
*   **State Root Integration:** The root hash of the scheduling queue gets included in the general Block Header as other critical blockchain state verification data would.

## 5. Integration with Hardware-Secured Time

The TEE interacts closely with the underlying hardware-secured time layer:

*   **`TIMESTAMP_NOW` Implementation:** The `TIMESTAMP_NOW` opcode retrieves the current consensus time directly from the STPU. This ensures that all contracts have a consistent view of time.
*   **Timestamp Validation:**  The TEE validates the timestamps provided as input to `SCHEDULE_CALL` and `AFTER/BEFORE` to prevent obvious attacks (e.g., scheduling calls far in the future or past).
*   **Synchronization:** The TEE is continuously synchronized with the consensus time maintained by the PoTA protocol.

## 6. Security Considerations

*   **Time Manipulation Attacks:**  The hardware-secured time and PoTA consensus mechanism make it extremely difficult to manipulate the system time.  However, contracts should still be designed to be robust against small variations in timing.
*   **Gas Cost Manipulation:**  Attackers might try to exploit the gas costs of temporal operations.  Careful gas cost calibration and limits on the number of scheduled calls per block are essential.
*   **Reentrancy Attacks:** Scheduled calls can potentially introduce reentrancy vulnerabilities.  Contracts should follow established best practices for preventing reentrancy.
*   **Denial-of-Service (DoS) Attacks:**  Attackers might try to flood the schedule with a large number of calls.  Limits on the number of scheduled calls per contract and per block can mitigate this risk.
*  **"Time-Travel" Exploits:**  Logical flaws related to assumptions about block ordering. All developers *must* be educated on the change (subtle, but relevant, with user code), regarding: `block.timestamp` versus system's verified time: `TIMESTAMP_NOW`

## 7. Compatibility and Extensibility

*   **EVM Compatibility:** The TEE is designed to be compatible with existing Ethereum Virtual Machine (EVM) bytecode. Existing contracts can run on the TEE without modification (although they won't be able to use the new temporal features).
*   **Extensibility:**  The opcode set can be extended in the future to add new temporal functionalities.

This document provides a detailed technical specification of the Temporal Execution Engine. This, as a key functional component to support Temporal Smart Contracts, offers substantial flexibility and opens entirely new classes of decentralized applications that depend on verifiable time.

---
