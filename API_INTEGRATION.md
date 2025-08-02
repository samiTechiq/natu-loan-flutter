# API Integration Documentation

## Overview

The Staff Loan Management app now uses Dio for HTTP requests to communicate with a real backend API.

## Setup

### Dependencies

- `dio: ^5.4.0` - HTTP client for API requests

### API Configuration

All API endpoints and configurations are defined in `lib/utils/constants.dart`:

```dart
// Base URL for the API
static const String baseUrl = 'http://10.0.2.2:8000/api';

// Available endpoints
static const String loginEndpoint = '/login';
static const String logoutEndpoint = '/logout';
static const String userProfileEndpoint = '/user/profile';
static const String usersEndpoint = '/users';
static const String loansEndpoint = '/loans';
static const String dashboardEndpoint = '/dashboard';
static const String historyEndpoint = '/history';
```

## Architecture

### 1. ApiService (`lib/services/api_service.dart`)

- Base HTTP client configuration using Dio
- Handles authentication tokens automatically
- Provides error handling and interceptors
- Methods: `get()`, `post()`, `put()`, `delete()`

### 2. DataService (`lib/services/data_service.dart`)

- High-level API interface
- Specific methods for each endpoint
- Methods for login, logout, users, loans, dashboard, etc.

### 3. Controllers

Controllers now use real API calls:

- `AuthController` - Handles authentication with backend
- `DashboardController` - Loads dashboard data from API

## API Usage Examples

### Authentication

```dart
// Login
final success = await authController.login(email, password);

// Logout
await authController.logout();

// Get user profile
await authController.getUserProfile();
```

### Dashboard Data

```dart
// Load dashboard statistics
await dashboardController.loadDashboardData();

// Refresh data
await dashboardController.refreshData();
```

### Direct API Calls

```dart
// Using DataService
final dataService = DataService();

// Get users with pagination
final users = await dataService.getUsers(page: 1, limit: 10);

// Create a loan
final loanData = {'amount': 1000, 'purpose': 'Emergency'};
final result = await dataService.createLoan(loanData);
```

## Error Handling

- Automatic token refresh on 401 errors
- Network error detection
- User-friendly error messages
- Timeout handling (30 seconds)

## Features

- ✅ Authentication with token storage
- ✅ Automatic authorization headers
- ✅ Error interceptors
- ✅ Request/Response logging
- ✅ Dashboard data loading
- ✅ User profile management
- ✅ Refresh functionality

## Backend Requirements

Your backend API should return responses in this format:

### Login Response

```json
{
  "success": true,
  "message": "Login successful",
  "user": {
    "id": 1,
    "name": "James",
    "email": "user@example.com",
    "role": "user"
  },
  "token": "6|6S0ayszuiY..."
}
```

### Dashboard Response

```json
{
  "success": true,
  "data": {
    "active_loans": 5,
    "pending_requests": 2,
    "total_amount": 15000.0,
    "completed_loans": 10
  }
}
```

## Testing

To test with a local backend:

1. Start your backend server on `http://localhost:8000`
2. For Android emulator, the app uses `http://10.0.2.2:8000`
3. For iOS simulator, you may need to use your actual IP address

## Next Steps

- Implement remaining API endpoints
- Add data models for responses
- Implement caching strategies
- Add offline support
- Implement proper logging
