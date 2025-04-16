;; Asset Registration Contract
;; Records details of purchased equipment

(define-data-var last-asset-id uint u0)

(define-map assets
  { asset-id: uint }
  {
    owner: principal,
    serial-number: (string-ascii 50),
    model: (string-ascii 100),
    manufacturer: (string-ascii 100),
    purchase-date: uint,
    registered: bool
  }
)

(define-public (register-asset
    (serial-number (string-ascii 50))
    (model (string-ascii 100))
    (manufacturer (string-ascii 100))
    (purchase-date uint))
  (let
    (
      (new-asset-id (+ (var-get last-asset-id) u1))
    )
    (asserts! (> (len serial-number) u0) (err u1)) ;; Serial number cannot be empty
    (asserts! (> (len model) u0) (err u2)) ;; Model cannot be empty
    (asserts! (> (len manufacturer) u0) (err u3)) ;; Manufacturer cannot be empty
    (asserts! (> purchase-date u0) (err u4)) ;; Purchase date must be valid

    (map-set assets
      { asset-id: new-asset-id }
      {
        owner: tx-sender,
        serial-number: serial-number,
        model: model,
        manufacturer: manufacturer,
        purchase-date: purchase-date,
        registered: true
      }
    )

    (var-set last-asset-id new-asset-id)
    (ok new-asset-id)
  )
)

(define-read-only (get-asset (asset-id uint))
  (map-get? assets { asset-id: asset-id })
)

(define-read-only (get-asset-count)
  (var-get last-asset-id)
)

(define-public (transfer-asset (asset-id uint) (new-owner principal))
  (let
    (
      (asset (unwrap! (map-get? assets { asset-id: asset-id }) (err u10))) ;; Asset not found
    )
    (asserts! (is-eq (get owner asset) tx-sender) (err u11)) ;; Not the owner

    (map-set assets
      { asset-id: asset-id }
      (merge asset { owner: new-owner })
    )

    (ok true)
  )
)
