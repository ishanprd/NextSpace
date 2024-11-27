# Next Space Mobile Application

A modern mobile application for discovering, booking, and managing coworking spaces. The app provides a seamless experience for users to find spaces, book them, communicate with space owners, and more, all from their mobile devices.

---

## Table of Contents

1. [Features](#features)
2. [Technologies Used](#technologies-used)
3. [Setup Instructions](#setup-instructions)

---

## Features

### User Authentication
- Email and Password login.
- Google Login integration.
- Forgot Password functionality.

### User Roles
- **Coworkers:** Book and review spaces.
- **Space Owners:** Manage space listings.
- **Admins:** Oversee platform operations.

### Search and Discover
- **Search Filters:**
  - Location-based.
  - Price Range.
  - Space Type (Private Rooms, Open Desk, Meeting Rooms).
  - Amenities (Wi-Fi, Conference Room, Coffee, Parking, etc.).
  - Availability (Date and Time).
- Display nearby coworking spaces based on user location.

### List Coworking Spaces
- Space details include:
  - Name.
  - Address.
  - Description.
  - Photos and Videos.
  - Pricing.
  - Amenities.

### Booking System
- Instant booking or request-based booking.
- Select Date and Time for reservations.
- Payment Gateway Integration.
- Booking Confirmation via:
  - Email.
  - In-app push notifications.

### Reviews and Ratings
- Space reviews by coworkers.
- Ratings for spaces and space owners.
- Moderate inappropriate reviews.

### Communication
- In-app chat between coworkers and space owners.
- Chat moderation and reporting options.
- Automated FAQs for space-related questions.

### Admin Features
- Overview of platform statistics.
- Approve or reject:
  - New space owners.
  - Coworking space listings.
- Analytics Dashboard.
- Manage complaints and issues.

### Notifications
- Confirmation of Booking.
- Booking Reminders.
- Updates on platform changes.
- Promotions, discounts, and special offers.

### Loyalty Programs
- Points for regular bookings.
- Discounts for referrals or frequent bookings.
- Subscription plans for premium features.

### Export Booking Details
- Export booking details to PDF or CSV format.

---

## Technologies Used

- **Framework:** Flutter
- **Backend API:** Django
- **Database:** Firebase/ sql
- **Authentication:** Firebase Authentication with OAuth2 (Google Login)
- **Payment Gateway:** esewa Integration
- **Notifications:** Firebase Cloud Messaging (FCM)
- **Map Integration:** Google Maps API
- **Storage:** Firebase Storage (for photos and videos)

---

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/ishanprad/NextSpace.git
   
2. Navigate to the project directory:
   ```bash
   cd NextSpace
   
3. Install dependencies
   ```bash
   flutter pub get
4. Run the app on an emulator or a physical device:
   ```bash
   flutter run
