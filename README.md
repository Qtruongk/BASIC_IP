# APB3 Basic Slave IP Core

## 1. Overview
This repository contains a synthesizable **APB3 Slave IP Core** (`basic_ip_core`) along with a complete verification environment. The IP demonstrates a standard AMBA APB (Advanced Peripheral Bus) implementation featuring an 8-bit data width, adjustable wait-states, and error response handling.

The project is designed to verify the read/write integrity of internal registers using a custom CPU Bus Functional Model (BFM).

## 2. Key Features
- **Protocol Compliance:** AMBA 3 APB (Standard handshake with `PREADY` and `PSLVERR`).
- **Data Width:** 8-bit.
- **Address Space:** 8 internal R/W registers mapped from offset `0x00` to `0x07`
- **Wait States:** Simulates hardware latency by inserting **2 wait cycles** per transaction (Configurable via `WAIT_CYCLES` parameter)
- **Error Handling:** Asserts `PSLVERR` when accessing invalid addresses (Address > `0x07`)
- **Verification:** Includes a self-checking testbench (`test_bench.v`) with randomized stimulus.

## 3. Project Structure

```text
.
├── rtl
│   └── basic_ip.v        # DUT: The APB Slave IP with 8 registers
├── tb
│   ├── cpu_model.v       # BFM: Simulates an APB Master (CPU)
│   ├── system_signals.v  # Clock and Reset generation
│   └── test_bench.v      # Top: Connects Master and Slave, runs tests
└── README.md
```
## Contact
For any inquiries or feedback regarding this IP, please contact:
- **Facebook:** https://www.facebook.com/qtrwuongnee
- **Email:** [tranquangkaito@gmail.com](mailto:tranquangkaito@gmail.com)