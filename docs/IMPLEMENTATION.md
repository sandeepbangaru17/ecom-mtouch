# IMPLEMENTATION.md — ShopFlow E-Commerce Platform

Developer guide covering project structure, coding standards, backend setup, Flutter architecture, Railway deployment, and CI/CD configuration.

## 1. Development Environment Setup

### 1.1 Required Tools
| Tool | Version | Install |
| :--- | :--- | :--- |
| **Flutter SDK** | ≥ 3.10.0 | https://docs.flutter.dev/get-started/install |
| **Dart** | ≥ 3.0.0 | Bundled with Flutter |
| **Python** | ≥ 3.11 | https://www.python.org/downloads/ |
| **PostgreSQL** | ≥ 15 | https://www.postgresql.org/download/ |
| **Redis** | ≥ 7 | https://redis.io/docs/getting-started/ |
| **Docker** | Latest | https://docs.docker.com/get-docker/ |
| **Railway CLI** | Latest | `npm install -g @railway/cli` |

### 1.2 Recommended VS Code Extensions
*   Dart / Flutter
*   Python (Pylance)
*   Ruff (linting)
*   GitLens
*   REST Client / Thunder Client

## 2. Backend Implementation (Python / FastAPI)

### 2.1 Project Structure
```text
backend/
├── app/
│   ├── api/
│   │   ├── v1/
│   │   │   ├── auth.py
│   │   │   ├── products.py
│   │   │   ├── categories.py
│   │   │   ├── cart.py
│   │   │   ├── orders.py
│   │   │   └── admin/
│   │   └── deps.py         # Dependencies
│   ├── core/               # Config, security, database
│   ├── models/             # SQLAlchemy ORM models
│   ├── schemas/            # Pydantic schemas
│   ├── services/           # Business logic
│   └── utils/              # Helpers (Cloudinary, Email)
├── alembic/                # Migrations
├── tests/                  # Pytest suite
└── main.py                 # Entry point
```

### 2.2 Key Dependencies
*   `fastapi`, `uvicorn`, `sqlalchemy`, `alembic`, `pydantic`, `python-jose`, `passlib`, `redis`, `cloudinary`.

### 2.3 FastAPI App Entry Point
```python
# app/main.py
from fastapi import FastAPI
from app.api.v1.router import api_router

app = FastAPI(title="ShopFlow API", version="1.0.0")
app.include_router(api_router, prefix="/api/v1")
```

## 3. Flutter Implementation

### 3.1 Architecture: Clean Architecture + BLoC
```text
lib/
├── core/               # Constants, network, router, theme
├── data/               # Datasources, models, repositories
├── domain/             # Entities, repo interfaces, usecases
└── presentation/       # BLoC, screens, widgets
```

### 3.2 Key Flutter Dependencies
*   `flutter_bloc`, `go_router`, `dio`, `get_it`, `injectable`, `hive_flutter`, `cached_network_image`.

### 3.3 API Client (Dio Setup)
Standardize all requests through a central `ApiClient` with interceptors for JWT injection and token refresh logic.

## 4. Admin Portal Implementation
*   Shares the same Flutter clean architecture pattern.
*   Uses a `RoleGate` widget to wrap admin-only screens and enforce RBAC.

## 5. Railway Deployment
### 5.1 `railway.toml`
Defines the build (Dockerfile) and deploy commands for the backend.
### 5.2 `Dockerfile`
Multi-stage build using `python:3.11-slim`.

## 6. CI/CD — GitHub Actions
*   **Backend CI**: Runs linting (Ruff) and tests (Pytest) on every push to `backend/**`.
*   **Flutter CI**: Runs flutter analyze and tests on every push to `mobile/**` or `admin/**`.

## 7. Testing Strategy
*   **Backend**: Aim for ≥ 70% coverage. Use `TestClient` for integration tests.
*   **Flutter**: Unit tests for business logic (BLoC) and Widget tests for UI components.

## 8. Coding Standards
*   **Python**: Black formatter + Ruff (PEP 8). Mandatory type hints.
*   **Dart**: `dart format`. BLoC only for state management — no `setState` in business logic.

## 9. Seeding Demo Data
Use `python scripts/seed.py` to populate the database with a super admin user (`admin@shopflow.com` / `admin123`), sample categories, and products.

*Document Version: 1.0 | Last Updated: April 2025*
