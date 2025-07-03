# VehicleVerified 🚗✅

**VehicleVerified** is a comprehensive mobile application built with Flutter and Firebase, designed to digitize and simplify the management and verification of vehicle documents. The app provides a secure and efficient platform for both vehicle owners and traffic enforcement officials, inspired by a modern, user-centric interface.

![App Banner](https://placehold.co/1200x400/1A237E/FFFFFF?text=VehicleVerified)

## 🚀 Core Features

The application is split into two primary user roles with a rich feature set.

### For Vehicle Owners:

* **Dynamic Tab-Based Dashboard:** A modern dashboard that allows users to switch between their vehicles using tabs. Each tab provides a dedicated overview for that specific vehicle.
* **Secure Registration & Login:** Easy and secure onboarding with Firebase Authentication, including options for password recovery.
* **Digital Garage:** Add and manage multiple vehicles. The dashboard provides a personalized "Digital Garage" experience.
* **Document Wallet:** Upload and store essential documents like the Registration Certificate (RC), Insurance Policy, and Pollution Under Control (PUC) certificate securely in Firebase Storage.
* **Action Grid:** A quick-access grid for each vehicle to:
    * View Detailed Information
    * Generate a Unique QR Code
    * Manage All Documents
    * Book Services
    * View Service History
    * Check Vehicle Health Status
* **Expiry Alerts:** Get timely notifications and see urgent alerts directly on the dashboard for documents that are expiring soon.
* **Service Management:** Book various vehicle services (General Maintenance, AC Repair, etc.) and view a complete, itemized service history.
* **Profile Management:** A comprehensive profile section to edit personal details, change passwords, manage notifications, and select app language.

### For Traffic Police:

* **Official & Secure Login:** A separate, verified login portal for officials.
* **Professional Dashboard:** A clean home screen for officials, showing key stats and providing clear action buttons.
* **Instant QR Code Scanner:** A dedicated screen to quickly scan a vehicle's QR code and fetch its document status in real-time.
* **Clear Verification Status:** Instantly see if all documents are "VERIFIED" or "NOT VERIFIED" with details on any expired or missing documents.
* **Manual Entry:** Option to manually enter a vehicle number as a fallback for verification.
* **Official Profile:** A dedicated profile screen for officials to view their details and log out securely.

## 📸 Screenshots

Here's a glimpse of the VehicleVerified app in action.

| Owner Dashboard                                                                      | Vehicle Details                                                                      | Police Scanner                                                                         |
| :----------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------- |
| ![Owner Dashboard](https://placehold.co/300x600/E3F2FD/000000?text=Owner+Dashboard)   | ![Vehicle Details](https://placehold.co/300x600/E3F2FD/000000?text=Vehicle+Details)   | ![Police Scanner](https://placehold.co/300x600/212121/FFFFFF?text=Police+Scanner)       |
| **Profile Screen** | **Service Booking** | **Verification Result** |
| ![Profile Screen](https://placehold.co/300x600/E3F2FD/000000?text=Profile+Screen) | ![Service Booking](https://placehold.co/300x600/E3F2FD/000000?text=Service+Booking) | ![Verification Result](https://placehold.co/300x600/4CAF50/FFFFFF?text=VERIFIED) |

## 🛠️ Tech Stack

* **Framework:** Flutter
* **Backend & Database:** Google Firebase
    * **Authentication:** For user management.
    * **Cloud Firestore:** For storing user, vehicle, and document data.
    * **Firebase Storage:** For hosting uploaded document images.
* **Key Packages:** `firebase_auth`, `cloud_firestore`, `qr_flutter`, `mobile_scanner`, `image_picker`

## ⚙️ Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

* Flutter SDK installed.
* A code editor like VS Code or Android Studio.
* A Firebase project.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/vehicle-verified.git](https://github.com/your-username/vehicle-verified.git)
    ```

2.  **Set up Firebase:**
    * Create a new project on the [Firebase Console](https://console.firebase.google.com/).
    * Add an Android and/or iOS app to your Firebase project.
    * Download the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) files and place them in the correct directories (`android/app/` and `ios/Runner/`).
    * **Note:** These files are included in the `.gitignore` to protect sensitive keys. You must use your own.

3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Run the app:**
    ```bash
    flutter run
    ```

## 🌟 Future Scope

* Implement local/push notifications for document expiry.
* Create a web-based admin panel for approving traffic official accounts.
* Integrate a payment gateway for service booking.
* Add detailed analytics for vehicle health and expenses.
