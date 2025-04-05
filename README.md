# 🌍 Crowdfunding Platform with Grants Programs

A fully decentralized crowdfunding protocol integrating **traditional funding** with **quadratic grant programs**, built in **Solidity** and deployed on the **Sepolia testnet**. This platform empowers communities to fund individual campaigns or allocate shared grant pools using quadratic funding mechanics.

---

## 🚀 Live Demo

👉 [quadraticcrowdfunding.vercel.app](https://quadraticcrowdfunding.vercel.app)

---

## 📦 Features

### 🧱 Traditional Crowdfunding
- 💸 **Donate with messages**: Supporters can contribute ETH and leave a note.
- 🧑‍💼 **Campaign ownership**: Creators can withdraw funds once the target is met or the deadline expires.
- 🔙 **Early withdrawal**: Donators can reclaim funds (with a 5% penalty) if the campaign hasn’t completed.

### 🎓 Grants via Quadratic Funding
The grant program operates in **three phases**:
1. **Project Requests**: Creators request to join the grant pool with project metadata (stored on IPFS).
2. **Donation Period**: Supporters donate to the projects they value most.
3. **Fair Distribution**: Funds are distributed using the quadratic funding algorithm:
   > Matching is proportional to the square of the sum of square roots of individual contributions.

This ensures a **more democratic and fair** allocation of grant resources.

---

## 🔐 Governance (Multisig Queues)

To ensure decentralization and avoid spam, **all campaigns and grant submissions must be approved via multisig**:
- ✅ Queque.sol: Crowdfunding campaigns must be approved by a quorum of trusted owners.
- ✅ GrantQueque.sol: Projects entering grants must pass through a similar multisig flow.

ℹ️ *Currently the multisig queues are permissionless, but in future versions we will add an admin DAO or governance layer.*

## 🧱 Architecture

## Usage

- 📝 Alice creates a crowdfunding project and submits it to the Queque contract.
- ✅ Bob and Carol (multisig owners) approve the request.
- 🚀 The project contract is deployed, and donations can begin.
- 🎓 Alice also submits her project to a grant program.
- 🤝 Community members donate to her project during the grant’s active funding period.
- 📊 After the grant round ends, Alice receives a fairly calculated match using quadratic funding.


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
