;; StarMint - NFTs for commemorating milestones
(define-non-fungible-token milestone uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-milestone (err u101))
(define-constant err-not-owner (err u102))

;; Data Variables
(define-data-var last-token-id uint u0)
(define-map milestones uint 
  {
    title: (string-ascii 64),
    description: (string-ascii 256),
    date: (string-ascii 10),
    type: (string-ascii 32),
    creator: principal,
    owner: principal
  }
)

;; Mint new milestone NFT
(define-public (mint-milestone 
  (title (string-ascii 64))
  (description (string-ascii 256))
  (date (string-ascii 10))
  (type (string-ascii 32))
  (recipient principal))
  (let
    ((token-id (+ (var-get last-token-id) u1)))
    (begin
      (try! (nft-mint? milestone token-id recipient))
      (map-set milestones token-id
        {
          title: title,
          description: description, 
          date: date,
          type: type,
          creator: tx-sender,
          owner: recipient
        })
      (var-set last-token-id token-id)
      (ok token-id)
    )
  )
)

;; Transfer milestone NFT
(define-public (transfer-milestone
  (token-id uint)
  (recipient principal))
  (let ((milestone-owner (get owner (map-get? milestones token-id))))
    (if (is-eq tx-sender milestone-owner)
      (begin
        (try! (nft-transfer? milestone token-id tx-sender recipient))
        (map-set milestones token-id
          (merge (unwrap-panic (map-get? milestones token-id))
            { owner: recipient }))
        (ok true))
      err-not-owner
    )
  )
)

;; Get milestone details
(define-read-only (get-milestone-details (token-id uint))
  (ok (map-get? milestones token-id))
)

;; Check milestone ownership
(define-read-only (get-milestone-owner (token-id uint))
  (ok (nft-get-owner? milestone token-id))
)
