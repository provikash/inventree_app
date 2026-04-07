
# InvenTree Desktop Client

A modern, high-performance Flutter-based Windows application that acts as a desktop client for the **InvenTree** inventory management system.

## 🚀 Overview

This application provides a seamless desktop experience for managing parts, tracking stock levels, and viewing warehouse data directly from your Windows machine. It leverages the InvenTree REST API to provide real-time updates and synchronization with your backend server.

## 🏗️ Architecture

The project follows a **Feature-First Clean Architecture**, ensuring scalability, maintainability, and clear separation of concerns:

-   **State Management:** [Riverpod 2.0](https://riverpod.dev) for robust and testable reactive state.
-   **Networking:** [Dio](https://pub.dev/packages/dio) with global singleton configuration for efficient API communication.
-   **Persistence:** `shared_preferences` for storing API credentials and user settings.
-   **UI Design:** Material 3 with desktop-optimized layouts (NavigationRail, GridView).

## ✨ Key Features

-   **Dynamic Dashboard**: Real-time overview of parts count, stock items, and low-stock warnings.
-   **Parts Catalog**: Browse your entire parts library with descriptions, categories, and stock counts.
-   **Stock Management**: Track quantities across different locations with status labels.
-   **Server Configuration**: Easily switch between local and remote InvenTree instances via the Settings screen.
-   **Responsive Layout**: Optimized for both windowed and full-screen desktop use.

## 🛠️ Setup & Installation

### Prerequisites
-   [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel)
-   InvenTree Server (Local or Remote)
-   Windows Development Environment

### Step-by-Step
1.  **Clone the repository:**
    ```bash
    git clone <your-repo-url>
    cd inventree_app
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    ```bash
    flutter run -d windows
    ```

4.  **Connect to InvenTree:**
    -   Open the **Settings** tab in the app.
    -   Enter your **InvenTree API URL** (e.g., `http://127.0.0.1:8000/api/`).
    -   Enter your **Authorization Token**.
    -   Click **Save Settings**.

## 📖 Learning Resources

Check out the [LEARNING.md](./LEARNING.md) file in this repository for a detailed breakdown of the technologies used and how the code is structured.

## 🤝 Contributing

This project was built as part of a technical assignment for Kibou Systems. Feel free to explore, fork, and suggest improvements!
