# Reporting and Excel synchronization

Firestore is BM's authoritative operational database. Microsoft Excel is a private, eventually-consistent reporting destination. A failed Graph call never changes order creation, status changes, payment updates, or financial updates.

## Outbox and retry

`reportSyncJobs/{orderId}` is created in the same Firestore transaction as an order or relevant admin order mutation. Its state moves through `PENDING`, `PROCESSING`, `RETRYING`, `COMPLETED`, `FAILED`, or `DEAD_LETTER`. A write-trigger processes newly queued jobs and a five-minute scheduled worker processes due retries. The worker uses a lease to avoid concurrent processing.

Transient Graph failures retry after 1, 5, 30 and 120 minutes. After five attempts they are `DEAD_LETTER`. Missing Graph configuration and permanent errors become visible `FAILED` jobs. An admin can requeue any failed/dead-letter job from **Reports & Sync**. `reportSyncState/{orderId}` exposes the current safe status and last synced timestamp to admins.

## Microsoft Graph configuration

Use an organization-owned OneDrive or SharePoint workbook and an Entra ID application using client-credentials authentication. Store every value only as a Firebase Functions secret; never put it in Flutter, Firestore settings, source control, logs, or CSV URLs.

Set these values in the development Functions project:

```powershell
firebase functions:secrets:set MICROSOFT_TENANT_ID
firebase functions:secrets:set MICROSOFT_CLIENT_ID
firebase functions:secrets:set MICROSOFT_CLIENT_SECRET
firebase functions:secrets:set MICROSOFT_DRIVE_ID
firebase functions:secrets:set MICROSOFT_WORKBOOK_ITEM_ID
firebase functions:secrets:set MICROSOFT_ORDERS_TABLE
firebase functions:secrets:set MICROSOFT_ORDER_ITEMS_TABLE
```

## Workbook schema

Create Excel tables called by the configured names. `Orders` must have these columns in order: `Order ID`, `Order Number`, `Created At`, `Customer Name`, `Phone`, `Location`, `Address`, `Product Summary`, `Item Count`, `Estimated Subtotal`, `Confirmed Subtotal`, `Delivery Charge`, `Final Total`, `Payment Status`, `Order Status`, `Customer Note`, `Admin Note`, `Last Updated`.

`OrderItems` must have: `Order Item Key`, `Order Number`, `Product ID`, `Product Name`, `Quantity`, `Unit`, `Price At Order`, `Subtotal`, `Location`.

The worker scans for the stable `Order ID` / `Order Item Key` and patches an existing row before appending. This makes retries idempotent even if a prior Graph request succeeded before Firestore received its acknowledgement.

## CSV fallback and live test

`exportOrdersCsv` remains the authenticated, admin-only export callable and accepts an allow-listed report type. It can produce orders, paid/non-cancelled revenue, products, or customers CSV content, each capped at 500 authoritative records. Flutter prefixes clipboard exports with a Unicode BOM so Tamil text opens correctly in common spreadsheet tools. This is a fallback, not a replacement for Excel sync; do not host it at a public URL.

The Admin Reports screen derives total/completed/cancelled/pending orders, paid and unpaid totals, recognized revenue, daily chart points, and top-material quantity/order-count/revenue from at most the latest 500 orders. Today, 7-day, 30-day and custom (up to one year per chart render) filters operate on that retrieved source set. Firestore remains authoritative; if the business grows past this bounded operational view, replace it with scheduled aggregate documents or a warehouse rather than removing the read bound.

Create the development workbook/tables, set all seven secrets, deploy Functions/rules/indexes, create an order, then update its status and verify the same row changes. Temporarily remove a secret: order creation must still work while Reports & Sync shows `FAILED`; restore it, retry and verify no duplicate row appears.
