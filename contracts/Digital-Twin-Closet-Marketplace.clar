(define-non-fungible-token digital-twin-nft uint)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-exists (err u102))
(define-constant err-token-not-found (err u103))
(define-constant err-invalid-escrow (err u104))
(define-constant err-escrow-already-exists (err u105))
(define-constant err-delivery-already-confirmed (err u106))
(define-constant err-not-buyer (err u107))
(define-constant err-not-seller (err u108))
(define-constant err-insufficient-funds (err u109))
(define-constant err-escrow-not-found (err u110))
(define-constant err-invalid-price (err u111))
(define-constant err-listing-not-found (err u112))
(define-constant err-listing-exists (err u113))

(define-data-var last-token-id uint u0)
(define-data-var platform-fee-percentage uint u250)

(define-map token-metadata
  uint
  {
    creator: principal,
    name: (string-ascii 64),
    description: (string-utf8 256),
    uri: (string-ascii 256),
    physical-item-id: (string-ascii 64),
    mint-block: uint
  }
)

(define-map marketplace-listings
  uint
  {
    seller: principal,
    price: uint,
    listed-at: uint
  }
)

(define-map escrow-data
  uint
  {
    buyer: principal,
    seller: principal,
    amount: uint,
    created-at: uint,
    delivery-confirmed: bool,
    buyer-confirmed: bool,
    seller-confirmed: bool
  }
)

(define-private (is-contract-owner)
  (is-eq tx-sender contract-owner)
)

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some (get uri (unwrap! (map-get? token-metadata token-id) (err err-token-not-found)))))
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? digital-twin-nft token-id))
)

(define-read-only (get-token-metadata (token-id uint))
  (ok (map-get? token-metadata token-id))
)

(define-read-only (get-listing (token-id uint))
  (ok (map-get? marketplace-listings token-id))
)

(define-read-only (get-escrow (token-id uint))
  (ok (map-get? escrow-data token-id))
)

(define-read-only (get-platform-fee-percentage)
  (ok (var-get platform-fee-percentage))
)

(define-public (mint-digital-twin 
  (name (string-ascii 64))
  (description (string-utf8 256))
  (uri (string-ascii 256))
  (physical-item-id (string-ascii 64))
)
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
      (current-block stacks-block-height)
    )
    (asserts! (is-eq (len name) (len name)) err-owner-only)
    (try! (nft-mint? digital-twin-nft token-id tx-sender))
    (map-set token-metadata token-id {
      creator: tx-sender,
      name: name,
      description: description,
      uri: uri,
      physical-item-id: physical-item-id,
      mint-block: current-block
    })
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (asserts! (is-some (map-get? token-metadata token-id)) err-token-not-found)
    (map-delete marketplace-listings token-id)
    (try! (nft-transfer? digital-twin-nft token-id sender recipient))
    (ok true)
  )
)

(define-public (list-on-marketplace (token-id uint) (price uint))
  (let
    (
      (token-owner (unwrap! (nft-get-owner? digital-twin-nft token-id) err-token-not-found))
      (current-block stacks-block-height)
    )
    (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
    (asserts! (> price u0) err-invalid-price)
    (asserts! (is-none (map-get? marketplace-listings token-id)) err-listing-exists)
    (map-set marketplace-listings token-id {
      seller: tx-sender,
      price: price,
      listed-at: current-block
    })
    (ok true)
  )
)

(define-public (unlist-from-marketplace (token-id uint))
  (let
    (
      (listing (unwrap! (map-get? marketplace-listings token-id) err-listing-not-found))
      (token-owner (unwrap! (nft-get-owner? digital-twin-nft token-id) err-token-not-found))
    )
    (asserts! (is-eq tx-sender (get seller listing)) err-not-seller)
    (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
    (map-delete marketplace-listings token-id)
    (ok true)
  )
)

(define-public (purchase-with-escrow (token-id uint))
  (let
    (
      (listing (unwrap! (map-get? marketplace-listings token-id) err-listing-not-found))
      (seller (get seller listing))
      (price (get price listing))
      (current-block stacks-block-height)
    )
    (asserts! (is-none (map-get? escrow-data token-id)) err-escrow-already-exists)
    (asserts! (not (is-eq tx-sender seller)) err-not-buyer)
    (try! (stx-transfer? price tx-sender (as-contract tx-sender)))
    (map-set escrow-data token-id {
      buyer: tx-sender,
      seller: seller,
      amount: price,
      created-at: current-block,
      delivery-confirmed: false,
      buyer-confirmed: false,
      seller-confirmed: false
    })
    (ok true)
  )
)

(define-public (confirm-delivery-buyer (token-id uint))
  (let
    (
      (escrow (unwrap! (map-get? escrow-data token-id) err-escrow-not-found))
    )
    (asserts! (is-eq tx-sender (get buyer escrow)) err-not-buyer)
    (asserts! (not (get buyer-confirmed escrow)) err-delivery-already-confirmed)
    (map-set escrow-data token-id (merge escrow { buyer-confirmed: true }))
    (ok true)
  )
)

(define-public (confirm-delivery-seller (token-id uint))
  (let
    (
      (escrow (unwrap! (map-get? escrow-data token-id) err-escrow-not-found))
    )
    (asserts! (is-eq tx-sender (get seller escrow)) err-not-seller)
    (asserts! (not (get seller-confirmed escrow)) err-delivery-already-confirmed)
    (map-set escrow-data token-id (merge escrow { seller-confirmed: true }))
    (ok true)
  )
)

(define-public (release-escrow (token-id uint))
  (let
    (
      (escrow (unwrap! (map-get? escrow-data token-id) err-escrow-not-found))
      (buyer (get buyer escrow))
      (seller (get seller escrow))
      (amount (get amount escrow))
      (platform-fee (/ (* amount (var-get platform-fee-percentage)) u10000))
      (seller-amount (- amount platform-fee))
      (token-owner (unwrap! (nft-get-owner? digital-twin-nft token-id) err-token-not-found))
    )
    (asserts! (or (get buyer-confirmed escrow) (get seller-confirmed escrow)) err-invalid-escrow)
    (asserts! (is-eq tx-sender buyer) err-not-buyer)
    (try! (as-contract (stx-transfer? seller-amount tx-sender seller)))
    (try! (as-contract (stx-transfer? platform-fee tx-sender contract-owner)))
    (try! (nft-transfer? digital-twin-nft token-id token-owner buyer))
    (map-delete marketplace-listings token-id)
    (map-delete escrow-data token-id)
    (ok true)
  )
)

(define-public (cancel-escrow (token-id uint))
  (let
    (
      (escrow (unwrap! (map-get? escrow-data token-id) err-escrow-not-found))
      (buyer (get buyer escrow))
      (amount (get amount escrow))
      (current-block stacks-block-height)
      (escrow-age (- current-block (get created-at escrow)))
    )
    (asserts! (or (is-eq tx-sender buyer) (is-eq tx-sender (get seller escrow))) err-not-buyer)
    (asserts! (or (> escrow-age u1440) (and (not (get buyer-confirmed escrow)) (not (get seller-confirmed escrow)))) err-invalid-escrow)
    (try! (as-contract (stx-transfer? amount tx-sender buyer)))
    (map-delete escrow-data token-id)
    (ok true)
  )
)

(define-public (update-platform-fee (new-fee uint))
  (begin
    (asserts! (is-contract-owner) err-owner-only)
    (asserts! (<= new-fee u1000) err-invalid-price)
    (var-set platform-fee-percentage new-fee)
    (ok true)
  )
)

(define-public (burn (token-id uint))
  (let
    (
      (token-owner (unwrap! (nft-get-owner? digital-twin-nft token-id) err-token-not-found))
    )
    (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
    (map-delete marketplace-listings token-id)
    (map-delete token-metadata token-id)
    (try! (nft-burn? digital-twin-nft token-id token-owner))
    (ok true)
  )
)
