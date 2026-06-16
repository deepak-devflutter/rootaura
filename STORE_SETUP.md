# Rootaura Store — Phase 1 Setup (Go-Live Checklist)

Phase 1 is **COD + UPI (manual confirm)**, web only, on Firebase Spark (free) plan.
No Cloud Functions needed yet. Follow these steps in order.

## 1. Firebase Authentication
Firebase Console → **Authentication → Sign-in method**:
- Enable **Phone** and **Google**.
- Under **Settings → Authorized domains**, add `localhost` and your live hosting
  domain (e.g. `rootaura-farms.web.app`). Phone OTP (reCAPTCHA) and the Google
  popup will not work otherwise.

## 2. Firestore
Console → **Firestore Database → Create database** (Production mode, region
`asia-south1` recommended for India).

Deploy the security rules and indexes shipped in this repo:
```bash
firebase deploy --only firestore:rules,firestore:indexes
```
(The `orders` query needs a composite index `uid + createdAt`. It's in
`firestore.indexes.json`; if you skip the deploy, the first run will print a
one-click "create index" link in the console.)

### Firebase Storage (for product images)
Console → **Storage → Get started** (same region). Then deploy the storage
rules (public read, admin-only upload):
```bash
firebase deploy --only storage
```

## 3. Fill in your details
Edit **`lib/core/constants/shop_config.dart`**:
- `upiId`, `upiPayeeName` — your real UPI handle.
- `adminEmails` — the owner's login email(s).
- (optional) `deliveryFee`, `freeDeliveryOver`.

Edit **`firestore.rules`** → `adminEmails()` — add the **same** admin email(s),
then redeploy rules. (Client-side gating shows the admin UI; the rules are what
actually protect admin writes — both must list the email.)

## 4. Add products
1. `flutter run -d chrome`
2. Sign in with an **admin** account (role `admin`, set in the `users` doc).
3. Account menu → **Admin → Products → Add Product**.
4. For each fruit: enter name, description, benefit, **price / MRP / stock**,
   pick one or more **images** (uploaded to Storage, shown as a carousel to
   customers), toggle **Active**, and Save. Edit/stock-update any product the
   same way; toggle Active to hide it without deleting.

## 5. Test the flow
Add to cart → Checkout → add address → choose COD or UPI → Place order →
see it in **My Orders** and in **Admin** (update status / mark paid).

## 6. Deploy
```bash
flutter build web --release
firebase deploy --only hosting,firestore:rules,firestore:indexes,storage
```

---

## What's built in Phase 1
- Auth: Phone OTP + Google · auto-created `users/{uid}` profile
- Profile + multiple delivery addresses (default address, pincode auto-fill)
- Catalogue from Firestore `products` (price, MRP, discount, stock, multi-image)
- Product detail with swipeable image **carousel**
- Cart (persisted per signed-in user) with live header badge
- Checkout: address + **COD** + order summary (UPI behind a config flag)
- Orders: customer history + detail with status timeline + shipment tracking
- **Admin console:**
  - **Products** — add/edit, multi-image upload to Storage, stock & price,
    active/hide, delete
  - **Orders** — filter (New default / Processing / Completed / Cancelled / All),
    search by name or order ID, update status, mark paid **with rollback**,
    add **courier + tracking ID + URL** (shown to the customer)
- Security rules: public product reads, owner-scoped users/carts/orders,
  admin-only writes (Firestore + Storage), order-total consistency check

## Phase 2 (when you're ready)
- Razorpay (UPI/cards) + a Cloud Function to verify payment signatures and
  compute order totals server-side (needs Firebase **Blaze** plan + Razorpay KYC).
- Order confirmation email/WhatsApp.
- Stock auto-decrement on successful order.
