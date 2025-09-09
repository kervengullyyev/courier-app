# Courier App

A simple Flutter courier delivery app with 3 main screens.

## 📱 App Structure

### **3 Main Screens:**

1. **🏠 Home (Create Delivery)**
   - Location: `lib/screens/home/create_delivery_screen.dart`
   - Purpose: Create new delivery orders
   - Features: Service type selection, pickup/delivery location selection, sender/recipient info

2. **📦 My Orders**
   - Location: `lib/screens/orders/my_deliveries_screen.dart`
   - Purpose: View delivery history
   - Features: List of past deliveries with status

3. **👤 Profile**
   - Location: `lib/screens/profile/profile_screen.dart`
   - Purpose: User profile management
   - Features: Edit personal info, help & support, logout

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point & routing
└── screens/
    ├── home/
    │   └── create_delivery_screen.dart # Create new delivery (Home page)
    ├── orders/
    │   └── my_deliveries_screen.dart   # View delivery history
    └── profile/
        └── profile_screen.dart         # User profile management
```

## 🎨 Design Features

- **Inter Font**: Custom font family applied globally
- **White AppBars**: Consistent white header styling
- **Blue Accent**: Blue color scheme throughout
- **No Backend**: Static data, no API connections
- **Clean Navigation**: 3-tab bottom navigation

## 🚀 Getting Started

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

## 📱 Navigation Flow

- **Home Tab** → Create Delivery Screen
- **My Orders Tab** → Delivery History Screen  
- **Profile Tab** → User Profile Screen

## 🛠️ Dependencies

- `flutter`: SDK
- `cupertino_icons`: iOS-style icons
- `go_router`: Navigation routing
- `flutter_lints`: Code linting

## 📝 Notes

- No backend integration
- Static sample data
- Form validation included
- Responsive design
- Clean, minimal codebase