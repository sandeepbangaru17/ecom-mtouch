# SCOPE.md — ShopFlow E-Commerce Platform

Defines project boundaries, deliverables, team responsibilities, timeline, and what is explicitly out of scope.

## 1. Project Summary
*   **Project Name**: ShopFlow
*   **Target Launch**: TBD (est. 16 weeks)
*   **Version**: 1.0.0

ShopFlow is a multi-platform e-commerce system built around a Cash on Delivery (COD) payment model. The system encompasses a customer-facing Flutter mobile app, a Flutter Web storefront, a Python/FastAPI backend API, and a Flutter Web admin portal — all deployed on Railway.

## 2. Goals & Objectives
| # | Objective |
| :--- | :--- |
| 1 | Provide customers a seamless shopping experience on mobile and web |
| 2 | Enable Cash on Delivery as the primary (and initially only) checkout mode |
| 3 | Equip admins with tools to manage products, inventory, and orders |
| 4 | Ensure order status is trackable end-to-end by both customers and admins |
| 5 | Deploy a scalable, maintainable system on Railway with CI/CD |

## 3. In-Scope Deliverables

### 3.1 Customer Mobile App (Flutter — iOS & Android)
*   User registration and login (email/password + Google OAuth)
*   Browse product catalog (categories, filters, search)
*   Product detail page (images, description, variants, stock status)
*   Shopping cart (add, remove, update quantities)
*   Checkout flow with Cash on Delivery option
*   Delivery address entry and management
*   Order confirmation screen with order ID
*   Order history and per-order detail view
*   Real-time order status tracking (Placed → Processing → Shipped → Delivered)
*   Push notifications for order status changes
*   User profile management

### 3.2 Customer Web App (Flutter Web)
*   All features of the mobile app adapted for desktop/tablet viewports
*   Responsive layout for screens ≥ 320px

### 3.3 Admin Portal (Flutter Web)
*   Secure admin login (role-based: Super Admin, Manager, Staff)
*   Dashboard with KPIs: total orders, revenue, pending COD, inventory alerts
*   Product management: create, edit, delete, archive products
*   Category management
*   Inventory management: stock levels, low-stock alerts
*   Image upload to Cloudinary
*   Order management: list, filter, search orders by status/date/customer
*   Order detail view: update status, add internal notes
*   Customer list view (read-only)
*   Basic sales analytics (daily/weekly/monthly charts)
*   Export orders to CSV

### 3.4 Backend API (Python + FastAPI)
*   RESTful API with full OpenAPI (Swagger) documentation
*   Authentication: JWT (access + refresh tokens)
*   Role-based access control (RBAC)
*   Products, categories, inventory endpoints
*   Orders CRUD with COD workflow state machine
*   User/customer management endpoints
*   File upload integration (Cloudinary)
*   Pagination, filtering, sorting on all list endpoints
*   PostgreSQL database with Alembic migrations
*   Redis caching for product catalog
*   Background tasks for notifications (Celery or FastAPI BackgroundTasks)
*   Health check endpoint for Railway

### 3.5 Infrastructure & DevOps
*   Railway deployment for API, PostgreSQL, Redis
*   Dockerfile and `railway.toml` configuration
*   GitHub Actions CI/CD pipeline (test → lint → deploy)
*   Environment-based configuration (dev / staging / prod)
*   Database backup strategy (Railway automated backups)

## 4. Out of Scope (v1.0)
The following items are explicitly excluded from this engagement:
1. Online payment gateways (Stripe, PayPal, etc.) — COD only for v1
2. Vendor/multi-seller marketplace features
3. Product reviews and ratings system
4. Loyalty points / rewards program
5. Live chat / customer support chat widget
6. Native iOS/Android push notifications via APNs/FCM setup (mocked in v1)
7. Advanced SEO optimizations for Flutter Web
8. Third-party logistics (3PL) integration
9. Invoice PDF generation and email delivery
10. Coupon/discount engine
11. Wishlists / saved items
12. Social media sharing integrations
13. Native dark mode theming in mobile app

## 5. Assumptions
1. The client will provide product catalog data (or use seeded demo data for testing).
2. Railway free/hobby tier is acceptable for initial deployment.
3. Cloudinary free tier is sufficient for media storage during development.
4. The admin portal will be web-only.
5. All currency is single-currency.
6. Delivery logistics are handled manually by the business.
7. A single language (English) is required for v1.

## 6. Constraints
| Constraint | Detail |
| :--- | :--- |
| **Timeline** | 16-week delivery window |
| **Platform** | Backend on Railway; iOS 14+; Android 8+ |
| **Framework** | Flutter for frontends; Python/FastAPI for backend |
| **Auth** | Google OAuth + Email/Password |

## 7. Delivery Timeline
*   **Week 1-2**: Project Setup, Architecture Design, DB Schema
*   **Week 3-5**: Backend API Core (Auth, Products, Orders, COD)
*   **Week 6-8**: Flutter Mobile App (Browse, Cart, Checkout, Orders)
*   **Week 9-10**: Flutter Web App (responsive adaptation)
*   **Week 11-13**: Admin Portal (Dashboard, Product Mgmt, Order Mgmt)
*   **Week 14**: Integration Testing & Bug Fixes
*   **Week 15**: Railway Deployment, CI/CD, Staging Sign-off
*   **Week 16**: Production Launch & Handover

## 8. Team & Responsibilities
*   **Backend Engineer**: FastAPI, PostgreSQL, Redis, Railway
*   **Flutter Developer**: Mobile app, Web app, Admin portal
*   **UI/UX Designer**: Figma designs, component library
*   **QA Engineer**: Test plans, manual + automated testing
*   **Project Manager**: Sprint planning, communication
*   **DevOps**: GitHub Actions, Railway config

## 9. Acceptance Criteria
1. All in-scope features implemented and pass QA sign-off.
2. System deployed and accessible on Railway.
3. Flutter apps build successfully for Android, iOS, and Web.
4. API documentation live at `/docs`.
5. Post-deployment smoke test confirms end-to-end COD flow.
6. Test coverage targets met (≥ 70% backend, ≥ 60% Flutter).

## 10. Change Management
Any additions or changes to the scope defined in this document must go through a formal Change Request (CR) process.

*Document Version: 1.0 | Last Updated: April 2025*
