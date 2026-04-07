# SPECIFICATIONS.md — ShopFlow E-Commerce Platform

Functional and technical specifications covering data models, API contracts, UI flows, and system behavior.

## 1. Functional Specifications

### 1.1 User Roles
| Role | Access Level |
| :--- | :--- |
| **Guest** | Browse products, view categories, view product details |
| **Customer** | All guest access + cart, checkout, order history, profile |
| **Staff** | Admin portal: view orders and update order status |
| **Manager** | Staff access + product management, inventory management |
| **Super Admin** | Full access including user management, analytics, system config |

### 1.2 Customer — User Stories
#### Authentication
*   **AUTH-01**: As a guest, I can register with email and password.
*   **AUTH-02**: As a guest, I can register or log in with Google OAuth.
*   **AUTH-03**: As a customer, I can log in and receive a JWT session.
*   **AUTH-04**: As a customer, I can log out and invalidate my session.
*   **AUTH-05**: As a customer, I can request a password reset via email.

#### Product Discovery
*   **PROD-01**: As a customer, I can browse a paginated list of products.
*   **PROD-02**: As a customer, I can filter products by category, price range, and availability.
*   **PROD-03**: As a customer, I can search products by name or keyword.
*   **PROD-04**: As a customer, I can view a product detail page with images, description, price, and stock.
*   **PROD-05**: As a customer, I can see product variants (e.g., size, color) where applicable.

#### Cart
*   **CART-01**: As a customer, I can add a product to my cart.
*   **CART-02**: As a customer, I can update the quantity of a cart item.
*   **CART-03**: As a customer, I can remove an item from my cart.
*   **CART-04**: As a customer, my cart persists across sessions.
*   **CART-05**: As a customer, I can view an order summary in the cart.

#### Checkout (COD)
*   **CHK-01**: As a customer, I can proceed to checkout from my cart.
*   **CHK-02**: As a customer, I must enter a delivery address to complete checkout.
*   **CHK-03**: As a customer, I can save multiple delivery addresses.
*   **CHK-04**: As a customer, I can select "Cash on Delivery" as the payment method.
*   **CHK-05**: As a customer, I receive an order confirmation with a unique order number.

#### Orders
*   **ORD-01**: As a customer, I can view my order history.
*   **ORD-02**: As a customer, I can view the detail of each order.
*   **ORD-03**: As a customer, I receive a push notification when my order status changes.
*   **ORD-04**: As a customer, I can track my order through statuses: Placed → Processing → Shipped → Out for Delivery → Delivered.
*   **ORD-05**: As a customer, I can cancel an order that is still in "Placed" status.

### 1.3 Admin — User Stories
#### Dashboard
*   **ADM-01**: As an admin, I can view total orders, revenue, pending COD, and alerts.
*   **ADM-02**: As an admin, I can view sales charts.

#### Product Management
*   **ADM-03**: As a manager, I can create products.
*   **ADM-04**: As a manager, I can edit existing products.
*   **ADM-05**: As a manager, I can deactivate/archive a product.
*   **ADM-06**: As a manager, I can manage product categories (CRUD).
*   **ADM-07**: As a manager, I can upload product images directly to Cloudinary.

#### Order Management
*   **ADM-08**: As a staff member, I can view all orders with filters.
*   **ADM-09**: As a staff member, I can view the full detail of an order.
*   **ADM-10**: As a staff member, I can update an order's status through the COD workflow.
*   **ADM-11**: As a staff member, I can add internal notes to an order.
*   **ADM-12**: As a manager, I can export orders to CSV.

#### User Management
*   **ADM-13**: As a super admin, I can view all registered customers.
*   **ADM-14**: As a super admin, I can create and manage admin users and assign roles.

## 2. Data Models

### 2.1 User
*   `id`: UUID PK
*   `email`: VARCHAR UNIQUE
*   `hashed_password`: VARCHAR
*   `full_name`: VARCHAR
*   `phone`: VARCHAR
*   `role`: ENUM(customer, staff, manager, super_admin)
*   `is_active`: BOOLEAN
*   `google_id`: VARCHAR NULLABLE

### 2.2 Address
*   `id`: UUID PK
*   `user_id`: UUID FK → users.id
*   `label`: VARCHAR (e.g., "Home")
*   `full_name`: VARCHAR
*   `line_1`: VARCHAR
*   `city`: VARCHAR
*   `state`: VARCHAR
*   `postal_code`: VARCHAR
*   `country`: VARCHAR (Default: 'Philippines')
*   `is_default`: BOOLEAN

### 2.3 Category
*   `id`: UUID PK
*   `name`: VARCHAR UNIQUE
*   `slug`: VARCHAR UNIQUE
*   `image_url`: VARCHAR
*   `parent_id`: UUID FK (supports subcategories)

### 2.4 Product
*   `id`: UUID PK
*   `name`: VARCHAR
*   `slug`: UNIQUE
*   `price`: NUMERIC
*   `stock_quantity`: INTEGER
*   `category_id`: UUID FK
*   `images`: JSONB (url, alt, is_primary)
*   `attributes`: JSONB (size, color, etc.)

### 2.5 Order & OrderItem
*   `order_number`: UNIQUE (e.g., "SF-20250001")
*   `status`: ENUM(placed, processing, shipped, out_for_delivery, delivered, cancelled)
*   `payment_method`: ENUM(cod)
*   `total`: NUMERIC
*   `order_items`: [product_id, quantity, unit_price]

## 3. API Specifications
Production: `https://shopflow-api.up.railway.app/api/v1`
Development: `http://localhost:8000/api/v1`

### 3.1 Core Endpoints
*   **Auth**: `/auth/register`, `/auth/login`, `/auth/refresh`, `/auth/google`
*   **Products**: `GET /products`, `POST /products` (Manager+)
*   **Cart**: `GET /cart`, `POST /cart/items`
*   **Orders**: `POST /orders`, `GET /orders`, `PATCH /admin/orders/{id}/status`

## 4. Order Status Workflow (COD)
1.  **PLACED**: Customer confirms order.
2.  **PROCESSING**: Admin confirms and begins preparation.
3.  **SHIPPED**: Item handed to courier.
4.  **OUT FOR DELIVERY**: Courier is on the way.
5.  **DELIVERED**: Final state (COD collected).
6.  **CANCELLED**: Valid from PLACED or PROCESSING.

## 5. Non-Functional Requirements
*   **Performance**: API response time < 300ms.
*   **Scalability**: Supports horizontal scaling via Railway.
*   **Security**: HTTPS enforced, JWT tokens, bcrypt hashing.
*   **Availability**: 99.5% uptime SLA.

*Document Version: 1.0 | Last Updated: April 2025*
