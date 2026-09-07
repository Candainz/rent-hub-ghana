# Rent Hub Ghana - Quick Reference

## 🚀 Start the App (5 minutes)

### Terminal 1 - Start Backend
```powershell
cd "c:\Users\CANDAINZ\Desktop\rent hub\rent_hub_ghana\backend"
.\venv\Scripts\python manage.py runserver 0.0.0.0:8000
```
✅ Server running at: http://localhost:8000

### Terminal 2 - Start Frontend
```powershell
cd "c:\Users\CANDAINZ\Desktop\rent hub\rent_hub_ghana\frontend\rent_hub_app"
flutter run
```
✅ App running on device/emulator

---

## 📱 How to Use the App

### 1. First Time Setup
- App opens to Role Selection screen
- Choose "Renter" or "Landlord" role
- Click "Continue"

### 2. Register
- Click "Sign up" on login screen
- Enter email, password, phone, name
- Click "Create account"

### 3. As a Renter
- Browse properties in Explore tab
- Use filters to find properties
- Save favorites
- Contact landlords via inquiries
- View notifications

### 4. As a Landlord
- Navigate to Landlord Dashboard
- Add new properties
- View inquiries from renters
- Manage listings

---

## 🧪 Test Accounts

| Role | Email | Password | Status |
|------|-------|----------|--------|
| Demo Owner | - | demo-password | Pre-created |
| Admin | admin@renthub.com | admin123 | For admin panel |

**Demo Properties (Pre-loaded):**
- Sunlit apartment, East Legon - 3 listings
- See admin panel to modify

---

## 🔗 Important URLs

| Service | URL |
|---------|-----|
| Django Admin | http://localhost:8000/admin |
| API Base | http://localhost:8000/api |
| Listings | http://localhost:8000/api/listings |
| Auth | http://localhost:8000/api/auth |

---

## 📋 API Quick Test

Test endpoints with Postman/Thunder Client:

```http
GET http://localhost:8000/api/listings/
GET http://localhost:8000/api/locations/
POST http://localhost:8000/api/auth/login/
  Body: {"username": "admin", "password": "admin123"}
```

---

## ⚙️ Configuration

### Change API URL (LAN Connection)
```powershell
# Get your IP
ipconfig

# Run Flutter with custom API
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000/api
```

### Database (Reset)
```powershell
cd backend
rm db.sqlite3
.\venv\Scripts\python manage.py migrate
.\venv\Scripts\python manage.py seed_demo.py
```

---

## 🛠️ Common Commands

```powershell
# Frontend
flutter pub get          # Install dependencies
flutter clean            # Clean build
flutter analyze          # Check code quality
flutter build apk        # Build APK

# Backend
python manage.py shell   # Python shell
python manage.py makemigrations  # Create migrations
python manage.py migrate         # Apply migrations
python manage.py createsuperuser # Add admin
```

---

## 📞 Troubleshooting

**App won't connect to backend?**
- Check backend is running
- Verify IP address in `lib/services/api_service.dart`
- Ensure same Wi-Fi network

**Database error?**
- Delete `db.sqlite3` and re-migrate
- Check migrations: `python manage.py showmigrations`

**Flutter won't run?**
- `flutter doctor` to check setup
- `flutter pub get` to install dependencies
- `flutter clean` if issues persist

---

**Need help?** Check SETUP_GUIDE.md for detailed instructions.
