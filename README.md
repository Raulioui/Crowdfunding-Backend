# Crowdfunding Platform with Grants Programs

Welcome to the Crowdfunding Platform project! This project is a comprehensive crowdfunding platform that integrates traditional crowdfunding methods with grant programs to support various projects. The platform is built using Solidity and designed to run on Sepolia testnet.

## Features

### Traditional Crowdfunding

The traditional crowdfunding mechanism allows project owners to raise funds by collecting donations from supporters. Key features include:
- **Donations with Messages**: Supporters can donate funds and include a message with their donation.
- **Withdrawal Options**: Project owners can withdraw the collected funds once the crowdfunding target is reached. Supporters can also withdraw their funds before the target is reached, with a small penalty fee.

### Grant Programs

The grant program utilizes quadratic funding to distribute a pool of funds among various projects based on community support. It includes 3 stages:
- **Project Requests**: Project owners can request to participate in the grant program by submitting their project details.
- **Donation Period**: Supporters can donate to their preferred projects during the active funding period.
- **Quadratic Funding Distribution**: Funds are distributed to projects based on the quadratic funding formula, ensuring a fair and balanced distribution of the grant pool.

### Disclaimer
- For include proyects at the grants and to be accepted as a crowdfunding, the have to be accepted at the queque, for the moment is not centralized, but it will be at the future

Examples of the proyects are taken from: https://www.gitcoin.co/

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
