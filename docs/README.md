# ShopFlow — E-Commerce Platform

A full-stack e-commerce solution with Cash on Delivery support, built with Flutter (Mobile & Web) and Python (FastAPI backend), deployable on Railway.

## Project Overview
ShopFlow is a production-ready e-commerce platform designed for businesses that need a reliable online store with Cash on Delivery (COD) checkout. It includes a customer-facing mobile app, a web storefront, a Python REST API backend, and an admin portal for full order and product management.

## Architecture at a Glance
```text
┌──────────────────────────────────────────────────────────────┐
│                           CLIENTS                            │
│ Flutter Mobile App  │  Flutter Web App  │    Admin Portal    │
└────────────┬──────────┴────────┬──────────┴────────┬─────────┘
             │                   │                   │
             └───────────────────▼───────────────────┘
                       FastAPI (Python)
                     REST API + WebSockets
                             │
             ┌────────────────┼────────────────┐
             ▼                ▼                ▼
        PostgreSQL          Redis          Cloudinary
       (Primary DB)       (Caching)      (Media Storage)
```

## Tech Stack
| Layer | Technology |
| :--- | :--- |
| **Mobile App** | Flutter 3.x (iOS & Android) |
| **Web Frontend** | Flutter Web |
| **Admin Portal** | Flutter Web (separate build target) |
| **Backend API** | Python 3.11 + FastAPI |
| **Database** | PostgreSQL 15 |
| **Cache** | Redis 7 |
| **Media Storage** | Cloudinary |
| **Deployment** | Railway (Backend + DB + Redis) |
| **Auth** | JWT (access + refresh tokens) |
| **CI/CD** | GitHub Actions |

## Quick Start
### Prerequisites
*   Flutter SDK >= 3.10.0
*   Python >= 3.11
*   PostgreSQL >= 15
*   Redis >= 7
*   Railway CLI (`npm install -g @railway/cli`)

### 1. Clone the Repository
```bash
git clone https://github.com/your-org/shopflow.git
cd shopflow
```

### 2. Backend Setup
```bash
cd backend
# Create virtual environment
python -m venv venv
source venv/bin/activate # Windows: venv\Scripts\activate
# Install dependencies
pip install -r requirements.txt
# Copy environment file and configure
cp .env.example .env
# Run database migrations
alembic upgrade head
# Seed demo data (optional)
python scripts/seed.py
# Start development server
uvicorn app.main:app --reload --port 8000
```
API docs available at: `http://localhost:8000/docs`

### 3. Flutter Mobile App
```bash
cd mobile
flutter pub get
flutter run # Runs on connected device/emulator
flutter run -d chrome # Runs as web app
```

### 4. Admin Portal
```bash
cd admin
flutter pub get
flutter run -d chrome --web-port=8080
```

### 5. Deploy to Railway
```bash
# Login to Railway
railway login
# Link project
railway link
# Deploy backend
cd backend
railway up
```
*Note: Set environment variables on Railway dashboard (DATABASE_URL, REDIS_URL, SECRET_KEY, CLOUDINARY_URL, etc.)*

## Repository Structure
```text
shopflow/
├── backend/                # Python FastAPI application
│   ├── app/
│   │   ├── api/            # Route handlers
│   │   ├── core/           # Config, security, dependencies
│   │   ├── models/         # SQLAlchemy ORM models
│   │   ├── schemas/        # Pydantic request/response schemas
│   │   ├── services/       # Business logic layer
│   │   └── main.py         # Application entry point
│   ├── alembic/            # Database migrations
│   ├── tests/              # Pytest test suite
│   ├── requirements.txt
│   ├── Dockerfile
│   └── railway.toml
├── mobile/                 # Flutter mobile + web app
│   ├── lib/
│   │   ├── core/           # Theme, routing, constants
│   │   ├── data/           # Repositories, API clients
│   │   ├── domain/         # Entities, use cases
│   │   └── presentation/   # Screens, widgets, BLoC
│   └── pubspec.yaml
├── admin/                  # Flutter admin portal
│   ├── lib/
│   │   ├── core/
│   │   ├── data/
│   │   └── presentation/
│   └── pubspec.yaml
├── docs/                   # Project documentation
│   ├── README.md
│   ├── SCOPE.md
│   ├── SPECIFICATIONS.md
│   └── IMPLEMENTATION.md
└── .github/
    └── workflows/          # CI/CD pipelines
```

## Environment Variables
### Backend `.env`
```env
# App
APP_ENV=development
SECRET_KEY=your-secret-key-here
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/shopflow

# Redis
REDIS_URL=redis://localhost:6379

# Cloudinary
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret

# JWT
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
```

## Features Summary
*   ✅ Product catalog with categories and search
*   ✅ Shopping cart with persistent sessions
*   ✅ Cash on Delivery (CODE) checkout
*   ✅ Real-time order status tracking
*   ✅ Customer authentication (email + social login)
*   ✅ Admin product & inventory management
*   ✅ Order management with status workflow
*   ✅ Push notifications (order updates)
*   ✅ Sales analytics dashboard (Admin)
*   ✅ Mobile-first responsive design

## Documentation
| Document | Description |
| :--- | :--- |
| [SCOPE.md](SCOPE.md) | Project boundaries, deliverables & timeline |
| [SPECIFICATIONS.md](SPECIFICATIONS.md) | Functional & technical specs |
| [IMPLEMENTATION.md](IMPLEMENTATION.md) | Setup guide, architecture details |

## Running Tests
### Backend
```bash
cd backend
pytest --cov=app tests/
```
### Flutter
```bash
cd mobile
flutter test
```

## License
MIT License © 2025 ShopFlow Team
