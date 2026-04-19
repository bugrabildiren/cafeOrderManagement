# Cafe Order Management

## Overview 
  Cafe Order Management is a cloud-native full-stack application developed for managing cafe tables,
products, orders and other order items. The project is designed as a 12-Factor application and is planned
to run on a cloud provider.

## Project Goals 
- Manage cafe tables
- List products and categories
- Create and track orders
- Manage order items
- Deploy the system in the cloud
- Follow 12-Factor app principles

## Technology Stack
- Backend: ASP.NET Core Web API
- Frontend: Angular
- Database: PostgreSQL
- Containerization: Docker
- Cloud: AWS
- CI/CD: GitHub Actions

## Project Structure
cafeOrderManagement/
├── backend/                     # ASP.NET Core Web API
├── frontend/                    # Angular application
├── infrastructure/              # Docker and cloud-related files
├── docs/                        # Proposal and architecture documents
├── .github/workflows/           # CI/CD workflows
├── docker-compose.yml           # Local multi-container setup
├── .env.example                 # Example environment variables
└── README.md                    # Project documentation

## Core Features
- Table management
- Product listing
- Order creation
- Order item management
- Order status tracking

## 12-Factor App Principles 
- Config stored in environment variables
- Stateless backend design
- Backing services managed externally
- Consistent environments through containers
- Logs written to standard output
- Build and deployment automation

## Environment Variables
  Example variables are provided in .env.example.
