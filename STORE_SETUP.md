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

## 3. Fill in your details
Edit **`lib/core/constants/shop_config.dart`**:
- `upiId`, `upiPayeeName` — your real UPI handle.
- `adminEmails` — the owner's login email(s).
- (optional) `deliveryFee`, `freeDeliveryOver`.

Edit **`firestore.rules`** → `adminEmails()` — add the **same** admin email(s),
then redeploy rules. (Client-side gating shows the admin UI; the rules are what
actually protect admin writes — both must list the email.)

## 4. Seed products & set prices
1. `flutter run -d chrome`
2. Sign in with an **admin** email.
3. Open the account menu → **Admin** → **Seed products**. This writes the 6
   fruits to Firestore with **placeholder prices**.
4. Update each product's real `price` / `mrp` / `stock` in the Firestore console
   (`products` collection) — or tell me and I'll add inline product editing.

## 5. Test the flow
Add to cart → Checkout → add address → choose COD or UPI → Place order →
see it in **My Orders** and in **Admin** (update status / mark paid).

## 6. Deploy
```bash
flutter build web --release
firebase deploy --only hosting
```

---

## What's built in Phase 1
- Auth: Phone OTP + Google · auto-created `users/{uid}` profile
- Profile + multiple delivery addresses (default address)
- Catalogue from Firestore `products` (price, MRP, discount, stock)
- Cart (persisted per signed-in user) with live header badge
- Checkout: address + COD/UPI(manual) + order summary
- Orders: customer history + detail with status timeline
- Admin dashboard: all orders, update status, mark paid, seed products
- Security rules: public product reads, owner-scoped users/carts/orders,
  admin-only writes, internal order-total consistency check

## Phase 2 (when you're ready)
- Razorpay (UPI/cards) + a Cloud Function to verify payment signatures and
  compute order totals server-side (needs Firebase **Blaze** plan + Razorpay KYC).
- Order confirmation email/WhatsApp.
- Stock auto-decrement on successful order.
