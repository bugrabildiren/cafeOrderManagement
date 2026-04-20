# Cloud-Native Cafe Order Management System

## Project Description
This project is a cloud-native full-stack cafe order management system developed for the **12-Factor Application running on a cloud provider** assignment.

The system supports essential cafe operations such as table management, product listing, order creation, order item management, and order status tracking. The application is built with **ASP.NET Core Web API**, **Angular**, and **PostgreSQL**, and is containerized using **Docker**.

---

## Objective
The objective of this project is to develop a modern application that reflects the principles of **12-Factor App design** and can be deployed in a cloud-oriented environment.

The project demonstrates:
- separation of frontend, backend, and database services
- environment-based configuration
- containerized execution
- automated database initialization
- database-level business rule enforcement

---

## Technology Stack
- **Backend:** ASP.NET Core Web API
- **Frontend:** Angular
- **Database:** PostgreSQL
- **Containerization:** Docker
- **Cloud Target:** AWS
- **CI/CD Target:** GitHub Actions

---

## Project Structure

    cafeOrderManagement/
    ├── backend/                     # ASP.NET Core Web API
    ├── frontend/                    # Angular application
    ├── postgres/
    │   └── init/                    # Auto-run SQL initialization files
    ├── sql/                         # Additional SQL files for testing/demo
    ├── infrastructure/              # Deployment-related files
    ├── docs/                        # Proposal and architecture documents
    ├── .github/workflows/           # CI/CD workflows
    ├── docker-compose.yml           # Multi-container setup
    ├── .env.example                 # Example environment variables
    └── README.md                    # Project documentation

---

## Core Features
- List cafe tables
- List products and categories
- Create and manage orders
- Add and manage order items
- Update order statuses
- Apply database-level business rules

---

## Database Design
The project uses PostgreSQL as the relational database system.

Main tables:
- `cafe_tables`
- `product_categories`
- `products`
- `orders`
- `order_items`
- `order_statuses`

The database layer also includes:
- SQL views
- business rules
- SQL functions

---

## Automatic Database Initialization
The database is initialized automatically when the containers start for the first time.

The following SQL files are executed automatically:
- `01_schema.sql`
- `02_seed.sql`
- `05_views.sql`
- `06_business_rules.sql`
- `07_order_item_functions.sql`

These files are mounted into PostgreSQL’s `/docker-entrypoint-initdb.d` directory through the `postgres/init` folder.

The following SQL files are included for testing and demonstration purposes, but are **not executed automatically**:
- `03_crud.sql`
- `04_query_examples.sql`
- `08_sample_flow.sql`

---

## Running the Project
To start the full system:

    docker compose up --build

### Service URLs
- **Frontend:** `http://localhost:4200`
- **Backend:** `http://localhost:8080`

To recreate the database from scratch:

    docker compose down --volumes --remove-orphans
    docker compose up --build

---

## 12-Factor App Alignment
This project follows the 12-Factor App approach in the following ways:
- single version-controlled codebase
- explicit dependency management
- configuration separated from code
- database treated as an attached backing service
- container-based build and run workflow
- stateless backend service design
- standardized logging through container output
- development and deployment consistency through Docker

---

## Current Status
At the current stage, the project:
- runs successfully with Docker
- initializes the database automatically
- serves frontend, backend, and database as separate services
- returns data correctly through the backend API
- displays data correctly on the frontend

---

## Future Work
Planned improvements for the final version include:
- deployment to AWS
- CI/CD integration with GitHub Actions
- improved environment separation for local and container-based execution
- expanded documentation for deployment and usage
