# Financial Treasury & Card Management System (Trading Edition)

## Software Requirements Specification & System Documentation

---

# 1. Overview

## 1.1 Purpose

The system is a cross-platform application (Desktop & Mobile) tailored for financial traders to manage multiple treasuries, currency exchange, and bank card trading lifecycles.

---

# 2. Module 1: Treasury Management

This module allows creating and monitoring different "wallets" or "accounts".

## 2.1 Treasury Fields

* **Name**: Descriptive name (e.g., Dubai Safe, Office Cash, Bank Al-Aman).
* **Currency**: Type of currency (LYD, USD, TRY, etc.).
* **Balance**: Current amount in the safe.

## 2.2 Operations

* **Add Treasury**: Create a new safe with a starting balance.
* **Edit/Delete**: Modify or remove treasury (data protection rules apply).

---

# 3. Module 2: Transaction Management

Handles the daily movement of funds within and between treasuries.

## 3.1 Basic Operations

* **Deposit**: Add money to a specific treasury (External entry -> Safe).
* **Withdraw**: Take money out (Safe -> External expense).

## 3.2 Operations Hub (مركز العمليات)

Each operation now has its own **dedicated full-screen interface** located in the "Operations Hub".

* **Deposit Screen**: For adding funds.
* **Withdraw Screen**: For deducting funds.
* **Transfer Screen**: For internal movement between same-currency safes.
* **Exchange Screen**: For currency swapping with rate calculation.
* **Purchase Screen**: For buying USD using LYD.

## 3.3 Transfers (Between Treasuries)

Allows moving money from one safe to another of the same currency.

* **Source**: Safe to deduct from.
* **Destination**: Safe to add to.
* **Amount**: Value to move.
* **Logic**: Balance is subtracted from source and added to destination immediately.

---

# 4. Module 3: Currency Purchase ($)

A specialized module for buying foreign currency (e.g., USD) using local currency (e.g., LYD).

## 4.1 Input Fields

* **Paying Safe (LYD)**: The safe used to pay for the purchase.
* **Receiving Safe (USD)**: The safe where the purchased dollars will go.
* **USD Amount**: Quantity of dollars purchased.
* **Purchase Rate**: Successive price (e.g., 7.50).
* **Total Cost**: Automatically calculated as `USD Amount * Rate`.

## 4.2 System Behavior

* Deduct **Total Cost** from Paying Safe.
* Add **USD Amount** to Receiving Safe.
* Generate a dual-entry transaction record for auditing.

---

# 5. Module 4: Bank Card Trading (The 10k Cards)

Management of personal allowance cards (10,000 USD cards).

## 5.1 Card Fields

* **Reference Code**: 4-digit UNIQUE code written on the physical card.
* **Holder Name**: Full name of the card owner.
* **Card Number**: 16 digits.
* **Bank Name**: Issuing bank.
* **USD Limit**: Fixed at 10,000 USD.
* **Spent USD**: Tracking how much has been cashed out.
* **Status**: `جديدة`, `محجوزة`, `تم الإيداع`, `مرسلة للسحب`, `مكتملة`.

## 5.2 Card Deposit Logic

When charging the card:

* Select **Treasury** (LYD safe).
* Input **Dinar Amount** paid to the bank.
* **Effect**: Mark card as `تم الإيداع`, deduct money from treasury, and transition status.

---

# 6. Module 5: Reporting & Dashboard

* **Quick Stats**: Total dollar limits, total spent USD, and total card count.
* **Balance Distribution**: Visual representation (Pie Chart) of money across different treasuries.
* **Recent Activity**: Stream of the last 5-10 operations.

---

# 7. Module 6: System Safety

* **Backup**: Exporting the local database to a `.db` file in the downloads folder.
* **Restore**: Importing a previous backup.
* **Clear Data**: Secure function to wipe the database with confirmation.

---

# End of Documentation
