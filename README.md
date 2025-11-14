# 👗 Digital Twin Closet Marketplace

A blockchain-powered marketplace where fashion creators can mint digital twins (NFTs) of physical fashion pieces, enabling metaverse wearability and secure real-world delivery through smart escrow.

## ✨ Features

- 🎨 **NFT Minting** - Designers mint digital twins of physical fashion items
- 🛍️ **Marketplace** - List and trade fashion NFTs with transparent pricing
- 🔒 **Smart Escrow** - Secure payment system for physical item delivery validation
- 🚚 **Delivery Confirmation** - Dual-confirmation system (buyer & seller)
- 💰 **Platform Fees** - Configurable fee structure (default 2.5%)
- 🔥 **NFT Burning** - Token holders can permanently burn their NFTs

## 🚀 Quick Start

### Mint a Digital Twin

```clarity
(contract-call? .Digital-Twin-Closet-Marketplace mint-digital-twin 
  "Vintage Denim Jacket"
  u"Limited edition denim jacket with custom embroidery"
  "ipfs://QmXx..."
  "PHY-001-JKT"
)
```

### List on Marketplace

```clarity
(contract-call? .Digital-Twin-Closet-Marketplace list-on-marketplace u1 u1000000)
```

### Purchase with Escrow

```clarity
(contract-call? .Digital-Twin-Closet-Marketplace purchase-with-escrow u1)
```

### Confirm Delivery (Buyer)

```clarity
(contract-call? .Digital-Twin-Closet-Marketplace confirm-delivery-buyer u1)
```

### Confirm Delivery (Seller)

```clarity
(contract-call? .Digital-Twin-Closet-Marketplace confirm-delivery-seller u1)
```

### Release Escrow (After Confirmation)

```clarity
(contract-call? .Digital-Twin-Closet-Marketplace release-escrow u1)
```

## 📖 Function Reference

### Public Functions

| Function | Description |
|----------|-------------|
| `mint-digital-twin` | Create new fashion NFT with metadata |
| `transfer` | Transfer NFT ownership |
| `list-on-marketplace` | List NFT for sale with price |
| `unlist-from-marketplace` | Remove listing from marketplace |
| `purchase-with-escrow` | Buy NFT and lock funds in escrow |
| `confirm-delivery-buyer` | Buyer confirms physical item received |
| `confirm-delivery-seller` | Seller confirms physical item shipped |
| `release-escrow` | Release funds to seller after confirmation |
| `cancel-escrow` | Cancel and refund escrow (after 1440 blocks) |
| `update-platform-fee` | Update platform fee (owner only) |
| `burn` | Permanently destroy NFT |

### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-last-token-id` | Returns last minted token ID |
| `get-token-uri` | Get token metadata URI |
| `get-owner` | Get current owner of token |
| `get-token-metadata` | Get full metadata for token |
| `get-listing` | Get marketplace listing details |
| `get-escrow` | Get escrow status and details |
| `get-platform-fee-percentage` | Get current platform fee |

## 🔐 Escrow System

The smart escrow protects both buyers and sellers:

1. **Purchase** - Buyer sends payment to contract escrow
2. **Shipping** - Seller ships physical item and confirms
3. **Delivery** - Buyer receives item and confirms
4. **Release** - Funds released to seller (minus platform fee)
5. **Cancellation** - Automatic refund after 1440 blocks (~10 days) if unconfirmed

## 💎 Token Metadata Structure

```clarity
{
  creator: principal,
  name: (string-ascii 64),
  description: (string-utf8 256),
  uri: (string-ascii 256),
  physical-item-id: (string-ascii 64),
  mint-block: uint
}
```

## 🛠️ Development

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed

### Testing

```bash
clarinet check
clarinet test
```

### Deploy

```bash
clarinet deploy
```

## 🎯 Use Cases

- 🎨 Fashion designers tokenizing collections
- 👔 Luxury brands creating digital-physical twins
- 🎮 Metaverse fashion wearables with physical redemption
- 💼 Fashion NFT trading with delivery guarantees

## 📝 Error Codes

| Code | Description |
|------|-------------|
| u100 | Owner only action |
| u101 | Not token owner |
| u102 | Token already exists |
| u103 | Token not found |
| u104 | Invalid escrow |
| u105 | Escrow already exists |
| u106 | Delivery already confirmed |
| u107 | Not buyer |
| u108 | Not seller |
| u109 | Insufficient funds |
| u110 | Escrow not found |
| u111 | Invalid price |
| u112 | Listing not found |
| u113 | Listing already exists |

## 🔮 Future Enhancements

- Multi-signature escrow release
- Royalty system for secondary sales
- Fractional ownership of fashion pieces
- Integration with metaverse platforms
- Dispute resolution mechanism

## 📄 License

MIT

## 🤝 Contributing

Contributions welcome! Feel free to submit PRs or open issues.

---

Built with ❤️ using Clarity on Stacks
