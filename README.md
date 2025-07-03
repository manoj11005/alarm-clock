# Alarm Clock Module (Verilog)

**This Verilog module implements a basic alarm clock that tracks the current time in hours, minutes, and seconds.**  
**It allows for setting the current time and an alarm time, and it raises an alarm signal when the current time matches the set alarm time.**  
**The module also handles resetting the alarm and generating a 1-second clock pulse from a given system clock.**

---

## 🔌 Inputs

- **`reset`**: Resets the clock and alarm settings.
- **`clk`**: System clock input.
- **`H_in1`, `H_in0`**: Inputs for setting the hour (tens and units place).
- **`M_in1`, `M_in0`**: Inputs for setting the minute (tens and units place).
- **`LD_time`**: Load signal for setting the current time.
- **`LD_alarm`**: Load signal for setting the alarm time.
- **`STOP_al`**: Signal to stop the alarm.
- **`AL_ON`**: Signal to turn on the alarm.

---

## 🔦 Outputs

- **`Alarm`**: Output signal indicating whether the alarm is active.
- **`H_out1`, `H_out0`**: Outputs for the current hour (tens and units place).
- **`M_out1`, `M_out0`**: Outputs for the current minute (tens and units place).
- **`S_out1`, `S_out0`**: Outputs for the current second (tens and units place).

---

## 🧠 Internal Registers

- **`clk_1s`**: 1-second clock signal.
- **`tmp_1s`**: Temporary counter for generating the 1-second clock signal.
- **`tmp_hour`, `tmp_minute`, `tmp_second`**: Temporary registers for holding the current hour, minute, and second values.
- **`c_hour1`, `c_hour0`, `c_min1`, `c_min0`, `c_sec1`, `c_sec0`**: Registers for the current time's tens and units place.
- **`a_hour1`, `a_hour0`, `a_min1`, `a_min0`, `a_sec1`, `a_sec0`**: Registers for the alarm time's tens and units place.

---

## ⚙️ Functionality

### ✅ `mod_10` Function

- **Returns the tens digit of a given number.**
- **Used to extract the tens place of minutes and seconds.**

---

### 🕒 Main Clock and Alarm Logic

#### ⏱️ 1-Second Clock Pulse Generation

- The `always` block generates a 1-second clock pulse (`clk_1s`) from the system clock (`clk`).
- It uses a temporary counter (`tmp_1s`) to count clock cycles and toggle the `clk_1s` signal.

#### 🕹️ Time and Alarm Settings

- When **`reset`** is asserted, the alarm time and current time are reset to zero.
- When **`LD_alarm`** is asserted, the input values (`H_in1`, `H_in0`, `M_in1`, `M_in0`) are loaded into the alarm time registers.
- When **`LD_time`** is asserted, the input values are loaded into the current time registers, and the seconds are reset to zero.
- The **`tmp_second`** register increments every second. When it reaches 59:
  - It resets to 0 and increments the **minute** register.
  - If **minutes = 59**, it resets to 0 and increments the **hour** register.
  - If **hours = 24**, it resets to 0.

#### 🔄 Time Conversion

- An `always @(*)` block calculates the **tens** and **units** place of the current hour, minute, and second using the `mod_10` function and basic arithmetic.

#### 🔔 Alarm Logic

- When `clk_1s` pulse or `reset` signal is asserted:
  - The logic checks if **current time == alarm time**.
  - If so, and if **`AL_ON`** is active, **`Alarm`** is activated.
- If **`STOP_al`** is asserted, the alarm is deactivated.

#### 📤 Output Assignments

- The outputs for the current **hour**, **minute**, and **second** are assigned from the corresponding internal registers.

---

## 📌 Summary

**This module provides a simple yet functional implementation of an alarm clock with time and alarm setting capabilities and a basic timekeeping mechanism.**
