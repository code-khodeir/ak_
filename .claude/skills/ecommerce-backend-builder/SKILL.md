---
name: ecommerce-backend-builder
description: >-
  Scaffolds, extends, or reviews a production-minded, Shopify-style admin backend —
  products, variants, collections, inventory, pricing and discounts, customers,
  orders, payments/refunds, and sales reporting — on a Next.js + Supabase + Vercel
  stack. Use whenever the user asks to build, extend, or review an ecommerce, catalog,
  or order-management backend or admin panel, or mentions a product catalog, inventory,
  stock, pricing, discounts, orders, customers, or a sales/admin dashboard in a build
  request. Plan-first and verification-first: it gathers stack details, writes a plan,
  defines schema, implements typed validated APIs and non-technical-friendly admin
  screens, drives core business logic with TDD, and runs testing + security passes
  before anything is called done. Not for public-facing marketing/storefront copy or
  site structure, and not for trivial one-off edits.
---

# Ecommerce Backend Builder

Build a focused, production-minded backend for managing products, availability,
pricing, orders, customers, and sales — comparable in capability to a Shopify
admin — on a **Next.js + Supabase (Postgres) + Vercel** stack.

This skill is plan-first and verification-first. Never jump straight to code.
Gather inputs, write a plan, then build in the standard sequence below, checking
each layer before moving on.

---

## When to invoke

Invoke when the user asks to **build, extend, or review** an ecommerce / catalog /
order backend or admin panel, or mentions product catalog, inventory, stock,
pricing, discounts, orders, customers, or a sales/admin dashboard in a build
request. For a trivial one-off edit (rename a field, fix a typo), skip the full
sequence — just make the change.

## Companion skills (use if present)

- **zero-hallucination-coder** (or any equivalent verification skill): wrap schema,
  migration, and business-logic work in its Discuss → Map → Decompose → Execute →
  Verify loop. This is the project's verification discipline — prefer it over
  claiming work "should" function.
- **test-driven-development** (superpowers): RED → GREEN → REFACTOR for core logic.
- **webapp-testing**: Playwright checks against admin flows.
- **/security-review** (built-in) or a `security-guidance` skill: the pre-done
  security pass.
- **postgresql-best-practices / nextjs-react-typescript / drizzle-orm|prisma**
  (if vendored): lean on these for schema, framework, and ORM conventions.

If a companion skill is not installed, do the equivalent work by hand — do not skip
the verification, testing, or security step.

---

## Step 0 — Gather required inputs before starting

Ask these in a single message and wait for answers. Do not assume.

1. **Stack specifics**: Next.js version; App Router or Pages Router; ORM choice
   (Drizzle or Prisma); Supabase project reference (and whether migrations run via
   Supabase SQL, the Supabase CLI, or the ORM's migration tool).
2. **New vs. existing**: a fresh project, or a new module inside an existing repo?
   If existing, **list the relevant existing structure and pause** if anything is
   ambiguous — do not guess at conventions.
3. **Domain shape**: bilingual requirements (e.g. English/Arabic), currency/currencies,
   and any domain-specific fields (clinical, retail, subscription, etc.).
4. **Users & access**: who uses the backend, and whether role-based access control
   (e.g. admin vs. staff) is required.

Restate the answers as a one-paragraph situation summary and get confirmation before
writing the plan.

---

## Standard build sequence

Build in this order. Verify each layer before starting the next.

### 1. Plan
Write `/tmp/<project>-backend-plan.md` covering: entities and their relationships,
the API surface (routes + methods + purpose), and the admin screens. Have the user
confirm the plan before touching schema.

### 2. Schema (Drizzle or Prisma, per Step 0)
Define tables covering at minimum:
- **Products & catalog**: products, variants, collections (and product↔collection links).
- **Inventory**: inventory levels per variant + an **inventory log** (every adjustment,
  with reason, delta, actor, timestamp — never mutate stock without a log row).
- **Pricing**: prices (per variant/currency) and discount codes (type, value, validity
  window, usage limits, conditions).
- **Customers**.
- **Orders**: orders + order items (snapshot price/qty at purchase time), with an
  explicit status lifecycle.
- **Payments**: payment records and refund records.
Generate and run the migration with the project's chosen tooling (Supabase CLI / ORM
migrate / `apply_migration`), never by hand-editing the DB. After migrating, confirm
the tables exist (list_tables or equivalent) before claiming success.

### 3. Typed API handlers
Implement handlers with: input validation (e.g. Zod) on every mutating route,
consistent typed error responses, and authorization checks where RBAC was requested.
No silent failures.

### 4. Admin UI screens
Build: product list + editor; inventory view with explicit adjustment actions;
discounts; orders list + detail (with status transitions); customers; and a simple
sales dashboard. Keep every screen usable by a non-technical staff member (see Hard
constraints).

### 5. TDD for core business logic
Apply RED → GREEN → REFACTOR to the logic that must not silently break:
- stock adjustments (no negative stock unless explicitly allowed; log every change),
- pricing math (including currency + any tax rules),
- discount validity (window, usage limits, eligibility),
- order status transitions (only legal transitions allowed).

### 6. Browser / E2E checks
Run webapp-testing (Playwright) or equivalent against the main admin flows:
create/edit a product, adjust stock, apply a discount, view an order, change order
status. Report pass/fail per flow.

### 7. Security pass
Run `/security-review` or a `security-guidance` skill before considering the module
done. At minimum check: authz on every mutating route, input validation coverage,
Supabase Row Level Security posture, and secret handling. Fix findings, don't just
list them.

### 8. Decision log
Maintain `/tmp/<project>-backend-log.md` with key decisions and open questions as you go.

---

## Hard constraints (always apply)

- **Non-technical usability**: every admin screen must be usable by a staff member
  without training — plain labels, clear actions, confirmations on anything
  consequential.
- **Stay in the backend lane**: never let backend users edit public-facing marketing
  content or site structure unless explicitly requested.
- **Verify, never assert**: never claim a migration, API handler, or UI flow works
  without actually checking it (run it, query it, test it). Use zero-hallucination-coder
  or an equivalent verification discipline.
- **No silent assumptions about an existing repo**: list your assumptions and pause if
  uncertain, especially about structure, naming, and conventions.
- **Explicit over clever, especially for destructive actions**: stock removal, refunds,
  and discount/product deletion must be confirmable and auditable — prefer an explicit
  confirmation step and an audit-log row over clever one-click automation.

---

## Output expectations (every run)

End each run with:

1. **Summary** — a short description of what was built or changed.
2. **File paths** — for schema/migrations, API handlers, and admin routes.
3. **Test results** — what was run and the pass/fail status (not "should pass").
4. **Staff usage note** — a short day-to-day note for a non-technical staff member.
5. **Production-readiness checklist** — Vercel (env vars, build, deployment protection)
   and Supabase (migrations applied, RLS enabled, advisors/linter clean, backups).
