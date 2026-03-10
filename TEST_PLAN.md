# Wassal -- Pre-Release Test Plan

> **Date:** March 9, 2026
> **Commit:** `97ed41f` -- Pre-release security hardening and crash-fix sweep

---

## Prerequisites

Before testing, ensure the environment is properly configured:

- [ ] Copy `backend/.env.example` to `backend/.env` and fill in **all** values
- [ ] Set `RADIUS_SECRET` in `.env` (required by FreeRADIUS and backend)
- [ ] Set `JWT_SECRET` and `JWT_REFRESH_SECRET` (must not be empty)
- [ ] Set `ENCRYPTION_KEY` (used for router password encryption)
- [ ] Set `DATABASE_URL` with valid PostgreSQL credentials
- [ ] Run `docker compose up --build` and confirm all containers start without errors
- [ ] Verify backend logs show **no** "FATAL: Missing required environment variable" messages
- [ ] Run `npx prisma migrate deploy` inside the backend container

---

## 1. Authentication & Token Flow

### 1.1 Login (Mobile)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Open the app, enter valid email and password | Login succeeds, navigates to dashboard | [ ] |
| 2 | Enter invalid credentials | Shows user-friendly error (not a raw exception) | [ ] |
| 3 | Leave email empty, tap login | Form validation prevents submission | [ ] |
| 4 | Leave password empty, tap login | Form validation prevents submission | [ ] |
| 5 | Login with a deactivated account | Shows appropriate error message | [ ] |

### 1.2 Token Refresh (Mobile)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Login, wait for access token to expire, then perform an action | Token refreshes silently, action succeeds | [ ] |
| 2 | Login, manually invalidate the refresh token in DB, then perform an action | App logs out gracefully, navigates to login | [ ] |
| 3 | Simulate API returning null tokens during refresh (mock) | App does NOT crash, logs user out | [ ] |

### 1.3 Registration (Mobile)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Register with valid data | Account created, navigated to dashboard | [ ] |
| 2 | Register with existing email | Shows "email already in use" error | [ ] |
| 3 | Register with weak/short password | Form validation rejects it | [ ] |

### 1.4 Forgot Password (Mobile)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Submit valid email | Shows success message | [ ] |
| 2 | Submit non-existent email | Shows appropriate error | [ ] |
| 3 | Submit empty email | Form validation prevents submission | [ ] |

### 1.5 Admin Login (Dashboard)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Login with admin credentials | Navigates to admin dashboard | [ ] |
| 2 | Login with non-admin user | Shows unauthorized error | [ ] |
| 3 | Access admin routes with expired JWT | Redirects to login page | [ ] |
| 4 | Manually set an expired token in localStorage, reload | Redirects to login (JWT expiry check) | [ ] |

---

## 2. Dashboard (Mobile)

### 2.1 Loading & Display

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Login and navigate to dashboard | Dashboard loads with router count, session count, revenue | [ ] |
| 2 | Pull to refresh | Data refreshes; if API is down, shows SnackBar error but keeps stale data | [ ] |
| 3 | Login with a new account (no routers) | Dashboard shows empty state (zero counts), no crash | [ ] |

### 2.2 Connectivity Handling

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Turn off WiFi/data, then open dashboard | Shows "No internet connection" error | [ ] |
| 2 | Turn off WiFi/data mid-use, pull to refresh | Shows error SnackBar, previous data remains visible | [ ] |
| 3 | Start with no internet, then enable it and pull to refresh | Dashboard loads successfully | [ ] |

### 2.3 Malformed API Response

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Backend returns `null` for `/routers` response data (simulate) | Dashboard shows 0 routers, does NOT crash | [ ] |
| 2 | Backend returns non-list for `/routers` (simulate) | Dashboard shows 0 routers, does NOT crash | [ ] |

---

## 3. Routers

### 3.1 Add Router (Mobile)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Add router with valid IP and port | Router added successfully | [ ] |
| 2 | Enter invalid IP (e.g., "999.999.999.999") | Form validation rejects it | [ ] |
| 3 | Enter port 0 or 70000 | Form validation rejects (must be 1-65535) | [ ] |
| 4 | Leave required fields empty | Form validation prevents submission | [ ] |

### 3.2 Router List & Monitoring (Mobile)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | View router list with active routers | Shows all routers with correct status indicators | [ ] |
| 2 | Tap a router to view monitoring page | Shows router stats (CPU, memory, uptime) | [ ] |

### 3.3 Router Management (Admin Dashboard)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | View all routers across all users | List displays correctly | [ ] |
| 2 | Create router with invalid IP | Validation error returned | [ ] |
| 3 | Edit a router's details | Changes persisted correctly | [ ] |

---

## 4. Sessions

### 4.1 Session Listing (Mobile)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | View active sessions for a router | Sessions display with correct data | [ ] |
| 2 | View sessions when none exist | Empty state shown, no crash | [ ] |
| 3 | API error while loading sessions | User-friendly error message shown | [ ] |

### 4.2 Session Authorization

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | User A's sessions are NOT visible to User B | Each user sees only their own sessions | [ ] |
| 2 | Attempt to terminate another user's session via API | Returns 404 or forbidden | [ ] |

### 4.3 Session Statistics

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | View session statistics page | Stats load correctly | [ ] |
| 2 | Revenue figures match actual sales data | Revenue aggregation is correct | [ ] |

---

## 5. Vouchers

### 5.1 Generate Vouchers (Mobile)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Generate vouchers with valid parameters | Vouchers created successfully | [ ] |
| 2 | Leave quantity/duration empty | Form validation prevents submission | [ ] |
| 3 | Generate vouchers for a router | Vouchers appear in list | [ ] |

### 5.2 Voucher Statistics (Mobile)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | View voucher stats page | Displays totalRevenue correctly | [ ] |
| 2 | If `totalRevenue` is missing from API response | Shows 0, does NOT crash | [ ] |

### 5.3 Voucher List (Admin Dashboard)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | View voucher list | Voucher usernames and plan names display correctly | [ ] |
| 2 | Voucher with `<script>` tag in username (XSS test) | Script is escaped, NOT executed | [ ] |

---

## 6. Subscriptions & Payments

### 6.1 Subscription Display (Mobile)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | User with active subscription | Shows plan name, status, expiry | [ ] |
| 2 | User with no subscription | Shows "no subscription" state, no crash | [ ] |
| 3 | User with subscription where `plan` is null in API | Shows "Unknown Plan", no crash | [ ] |

### 6.2 Payment Proof Upload (Mobile)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Upload payment proof under 5MB | Upload succeeds | [ ] |
| 2 | Try to upload file over 5MB | Shows "file too large" SnackBar, upload blocked | [ ] |

### 6.3 Subscription Management (Admin)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Assign subscription to user | Subscription created | [ ] |
| 2 | Extend subscription | Expiry date updated | [ ] |
| 3 | View user with/without subscription | Displays correctly with optional chaining (no crash) | [ ] |

---

## 7. RADIUS / Hotspot

### 7.1 FreeRADIUS Configuration

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Start freeradius container | Starts without errors, reads `RADIUS_SECRET` from env | [ ] |
| 2 | Run `radtest user pass 127.0.0.1 0 <RADIUS_SECRET>` from within container | Gets Access-Accept or Access-Reject (not connection error) | [ ] |
| 3 | Run `radtest "" "" 127.0.0.1 0 <RADIUS_SECRET>` (empty password) | Gets Access-Reject (NOT Accept) | [ ] |
| 4 | Verify `clients.conf` uses `$ENV{RADIUS_SECRET}` (not shell-style) | Confirmed via `cat /etc/freeradius/clients.conf` | [ ] |

### 7.2 Hotspot Profiles (Mobile)

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Create hotspot profile | Profile created on router | [ ] |
| 2 | View hotspot profiles list | Profiles display correctly | [ ] |

---

## 8. WireGuard VPN

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Setup WireGuard for a router | Script generated with HMAC-signed callback URL | [ ] |
| 2 | Verify callback URL contains valid HMAC signature | Signature is non-empty (JWT_SECRET is enforced) | [ ] |
| 3 | Start backend without `JWT_SECRET` set | Backend refuses to start with FATAL error | [ ] |

---

## 9. Admin Dashboard

### 9.1 Dashboard Page

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Load admin dashboard | Shows stats (users, routers, revenue in SDG) | [ ] |
| 2 | API returns error | Shows error state with retry button | [ ] |
| 3 | Click retry button | Re-fetches data | [ ] |

### 9.2 User Management

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | View users list | All users displayed | [ ] |
| 2 | View user details | User info, subscription details shown (no crash if no subscription) | [ ] |
| 3 | Toggle user active status | Status changes correctly | [ ] |

### 9.3 System Configuration

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Open system page | API health status shows dynamically (from API call) | [ ] |
| 2 | Feature flags section | Shows "Coming Soon", toggles are disabled | [ ] |
| 3 | Change admin password with valid data | Password updated | [ ] |

---

## 10. Notifications

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Register device token | Token saved to DB for current user | [ ] |
| 2 | Remove device token | Token deleted, only owner can remove | [ ] |
| 3 | Try removing another user's token via direct API call | Fails (IDOR protection) | [ ] |

---

## 11. Localization

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Switch app language to Arabic | All UI strings show in Arabic | [ ] |
| 2 | Switch app language to English | All UI strings show in English | [ ] |
| 3 | Trigger network error with Arabic locale | Error message shown in Arabic | [ ] |
| 4 | Trigger network error with English locale | Error message shown in English | [ ] |

---

## 12. Security Checks

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Backend starts without `JWT_SECRET` | Exits with FATAL error, does NOT start | [ ] |
| 2 | Backend starts without `DATABASE_URL` | Exits with FATAL error, does NOT start | [ ] |
| 3 | No hardcoded JWT fallback secrets in code | Confirmed (all removed) | [ ] |
| 4 | No `|| 'secret'` fallback in `crypto.scryptSync` calls | Confirmed (all removed) | [ ] |
| 5 | CORS origin is set via `CORS_ORIGINS` env var | API rejects requests from unknown origins | [ ] |
| 6 | Nginx returns security headers (`X-Frame-Options`, `X-Content-Type-Options`) | Confirmed via `curl -I` | [ ] |
| 7 | Nginx rate limiting blocks excessive API requests | Returns 429 after burst limit | [ ] |
| 8 | Router password decryption failure does NOT leak ciphertext | Throws error instead of returning raw value | [ ] |

---

## 13. Docker / Deployment

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | `docker compose up --build` (dev) | All services start, no errors | [ ] |
| 2 | `docker compose -f docker-compose.prod.yml up --build` | All services start (with proper `.env`) | [ ] |
| 3 | Backend container runs `node dist/main` (not `dist/src/main`) | Confirmed in Dockerfile CMD | [ ] |
| 4 | `@prisma/client` is in `dependencies` (not devDependencies) | Confirmed in `package.json` | [ ] |
| 5 | `RADIUS_SECRET` is passed to freeradius service | Confirmed in both compose files | [ ] |
| 6 | All `.env.example` variables are documented | Confirmed | [ ] |

---

## 14. Splash Screen / App Startup

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Open app with backend running | Splash completes, navigates to login or dashboard | [ ] |
| 2 | Open app with backend down | Splash times out after ~15s, shows server error | [ ] |
| 3 | Open app with very slow backend (simulate) | Splash times out, does NOT hang forever | [ ] |

---

## 15. Edge Cases & Crash Prevention

| # | Step | Expected Result | Pass |
|---|------|----------------|------|
| 1 | Backend returns user JSON with `id: null` | App does NOT crash (falls back to empty string) | [ ] |
| 2 | Backend returns user JSON with `email: null` | App does NOT crash (falls back to empty string) | [ ] |
| 3 | Token refresh returns `{ accessToken: null }` | App does NOT crash, logs user out | [ ] |
| 4 | `/routers` endpoint returns `null` body | Dashboard shows 0 routers, no crash | [ ] |
| 5 | App is backgrounded and resumed | Data refreshes after 2s delay, no connection errors | [ ] |
| 6 | App is backgrounded for extended period, timers fire | Polling timers skip API calls while backgrounded | [ ] |

---

## Sign-off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Developer | | | |
| QA Tester | | | |
| Project Lead | | | |
