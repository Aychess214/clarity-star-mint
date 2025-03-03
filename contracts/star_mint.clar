;; StarMint - NFTs for commemorating milestones
(define-non-fungible-token milestone uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-milestone (err u101))
(define-constant err-not-owner (err u102))
(define-constant err-invalid-input (err u103))
(define-constant err-milestone-burned (err u104))

;; Data Variables
(define-data-var last-token-id uint u0)
(define-map milestones uint 
  {
    title: (string-ascii 64),
    description: (string-ascii 256),
    date: (string-ascii 10),
    type: (string-ascii 32),
    creator: principal,
    owner: principal,
    verified: bool,
    metadata-uri: (optional (string-utf8 256)),
    burned: bool
  }
)

;; Private Functions
(define-private (is-valid-date (date (string-ascii 10)))
  (let ((len (len date)))
    (and (is-eq len u10)
         (is-eq (unwrap-panic (element-at date u4)) "-")
         (is-eq (unwrap-panic (element-at date u7)) "-"))
  )
)

;; Mint new milestone NFT
(define-public (mint-milestone 
  (title (string-ascii 64))
  (description (string-ascii 256))
  (date (string-ascii 10))
  (type (string-ascii 32))
  (metadata-uri (optional (string-utf8 256)))
  (recipient principal))
  (let
    ((token-id (+ (var-get last-token-id) u1)))
    (asserts! (> (len title) u0) err-invalid-input)
    (asserts! (> (len description) u0) err-invalid-input)
    (asserts! (is-valid-date date) err-invalid-input)
    (begin
      (try! (nft-mint? milestone token-id recipient))
      (map-set milestones token-id
        {
          title: title,
          description: description, 
          date: date,
          type: type,
          creator: tx-sender,
          owner: recipient,
          verified: false,
          metadata-uri: metadata-uri,
          burned: false
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
  (let ((milestone-data (unwrap! (map-get? milestones token-id) err-invalid-milestone)))
    (asserts! (not (get burned milestone-data)) err-milestone-burned)
    (asserts! (is-eq tx-sender (get owner milestone-data)) err-not-owner)
    (begin
      (try! (nft-transfer? milestone token-id tx-sender recipient))
      (map-set milestones token-id
        (merge milestone-data
          { owner: recipient }))
      (ok true)
    )
  )
)

;; Burn milestone NFT
(define-public (burn-milestone (token-id uint))
  (let ((milestone-data (unwrap! (map-get? milestones token-id) err-invalid-milestone)))
    (asserts! (is-eq tx-sender (get owner milestone-data)) err-not-owner)
    (asserts! (not (get burned milestone-data)) err-milestone-burned)
    (begin
      (try! (nft-burn? milestone token-id tx-sender))
      (map-set milestones token-id
        (merge milestone-data
          { burned: true }))
      (ok true)
    )
  )
)

;; Update milestone metadata
(define-public (update-milestone-metadata
  (token-id uint)
  (new-description (string-ascii 256))
  (new-metadata-uri (optional (string-utf8 256))))
  (let ((milestone-data (unwrap! (map-get? milestones token-id) err-invalid-milestone)))
    (asserts! (is-eq tx-sender (get owner milestone-data)) err-not-owner)
    (asserts! (not (get burned milestone-data)) err-milestone-burned)
    (begin
      (map-set milestones token-id
        (merge milestone-data
          {
            description: new-description,
            metadata-uri: new-metadata-uri
          }))
      (ok true)
    )
  )
)

;; Verify milestone (contract owner only)
(define-public (verify-milestone (token-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set milestones token-id
      (merge (unwrap! (map-get? milestones token-id) err-invalid-milestone)
        { verified: true }))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-milestone-details (token-id uint))
  (ok (map-get? milestones token-id))
)

(define-read-only (get-milestone-owner (token-id uint))
  (ok (nft-get-owner? milestone token-id))
)

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)
