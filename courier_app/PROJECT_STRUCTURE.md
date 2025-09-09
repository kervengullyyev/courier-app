# Project Structure Overview

## 🎯 **App Purpose**
Simple courier delivery app with 3 main screens for creating deliveries, viewing orders, and managing profile.

## 📂 **File Organization**

### **Root Level**
- `main.dart` - App entry point, routing, and theme configuration
- `pubspec.yaml` - Dependencies and project configuration
- `README.md` - Project documentation

### **Screens Directory** (`lib/screens/`)

#### **🏠 Home** (`lib/screens/home/`)
- `create_delivery_screen.dart` - Main screen for creating delivery orders
  - Service type selection (City/Inter-City)
  - Pickup/Delivery location selection
  - Sender/Recipient information forms
  - Package details
  - Form validation

#### **📦 Orders** (`lib/screens/orders/`)
- `my_deliveries_screen.dart` - Delivery history screen
  - Static sample delivery data
  - Delivery status display
  - Clean list interface

#### **👤 Profile** (`lib/screens/profile/`)
- `profile_screen.dart` - User profile management
  - Editable user information
  - Help & Support
  - Logout functionality

## 🔄 **Navigation Flow**

```
main.dart (Router)
├── /create-delivery → Home Screen
├── /my-deliveries → Orders Screen
└── /profile → Profile Screen
```

## 🎨 **Design System**

- **Font**: Inter (globally applied)
- **Colors**: Blue accent, white backgrounds
- **Navigation**: 3-tab bottom navigation
- **UI**: Clean, modern design with rounded corners

## 📱 **Key Features**

1. **Create Delivery**: Complete form with validation
2. **View Orders**: Static delivery history
3. **Edit Profile**: Click-to-edit user information
4. **Responsive**: Works on different screen sizes
5. **No Backend**: Self-contained with sample data

## 🛠️ **Technical Details**

- **Framework**: Flutter
- **Navigation**: GoRouter
- **State**: Local state management (setState)
- **Dependencies**: Minimal (only essential packages)
- **Architecture**: Simple, clean structure
