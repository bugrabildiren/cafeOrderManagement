# System Architecture

## Overview
The system is composed of three main parts:

1. Angular frontend
2. ASP.NET Core Web API backend
3. PostgreSQL database

## Flow 
User -> Frontend -> Backend API -> PostgreSQL

## Cloud Architecture
User -> Frontend (served application) -> Backend container -> AWS RDS PostgreSQL

## Responsibilities 

### Frontend 
- Display tables, products and orders
- Send HTTP requests to backend API
- Presents responses to the user

### Database
- Stores tables, products, orders, order items, and statuses

## 12-Factor Alignment
- Single codebases in GitHub
- Config managed via environment variables
- Database treated as backing service
- Backend designed as stateless process
- Logs written to standard output
- Docker used for environment consistency

## Planned Deployment
- Frontend: containerized or static hosting
- Backend: Docker container on AWS
- Database: AWS RDS PostgreSQL
- CI/CD: GitHub Actions



