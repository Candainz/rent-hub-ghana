# Rent Hub Ghana - Complete Setup & Deployment Guide

## ✅ Project Status: COMPLETE & READY TO USE

This guide covers everything you need to run, develop, test, and deploy the Rent Hub Ghana application.

---

## 🚀 Quick Start

### Backend Setup (Django)

```powershell
# Navigate to backend directory
cd backend

# Create and activate virtual environment
python -m venv venv
.\venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Seed demo data
python manage.py seed_demo.py

# Create admin account (if needed)
python manage.py createsuperuser

# Start development server
python manage.py runserver 0.0.0.0:8000
```

**Admin Access:**
- URL: `http://localhost:8000/admin`
- Username: `admin`
- Password: `admin123`

### Frontend Setup (Flutter)

```powershell
# Navigate to frontend directory
cd frontend\rent_hub_app

# Get dependencies
flutter pub get

# Run on Android (requires Android emulator or device)
flutter run

# Or run on specific device
flutter devices  # List available devices
flutter run -d <device_id>

# For custom API URL (if LAN IP changes)
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8000/api
```

---

## 📋 Project Structure

```
rent_hub_ghana/
├── backend/                    # Django REST API
│   ├── config/                # Django configuration
│   ├── users/                 # User management app
│   ├── listings/              # Property listings app
│   ├── favorites/             # Favorites management
│   ├── inquiries/             # Inquiry tracking
│   ├── locations/             # Location/area data
│   ├── notifications/         # Notification system
│   ├── media/                 # Uploaded media files
│   ├── manage.py              # Django CLI
│   ├── requirements.txt       # Python dependencies
│   └── seed_demo.py           # Demo data seeder
│
├── frontend/rent_hub_app/     # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart          # App entry point
│   │   ├── screens/           # UI screens
│   │   ├── services/          # API & business logic
│   │   ├── models/            # Data models
│   │   ├── widgets/           # Reusable widgets
│   │   └── theme/             # App theming
│   └── pubspec.yaml           # Flutter dependencies
│
└── docs/                       # Documentation
    ├── API_DOCUMENTATION.md
    ├── DATABASE_DESIGN.md
    ├── SYSTEM_DESIGN.md
    └── USER_GUIDE.md
```

---

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/login/` - User login
- `POST /api/auth/register/` - User registration
- `POST /api/auth/logout/` - User logout

### Listings
- `GET /api/listings/` - List all properties
- `GET /api/listings/{id}/` - Property details
- `POST /api/listings/` - Create new listing (Landlord)
- `PUT /api/listings/{id}/` - Update listing (Landlord)
- `DELETE /api/listings/{id}/` - Delete listing (Landlord)

### Favorites
- `GET /api/favorites/` - User's favorite listings
- `POST /api/favorites/` - Add to favorites
- `DELETE /api/favorites/{id}/` - Remove from favorites

### Inquiries
- `GET /api/inquiries/` - List inquiries
- `POST /api/inquiries/` - Create inquiry
- `PATCH /api/inquiries/{id}/` - Update inquiry status

### Locations
- `GET /api/locations/` - List all locations
- `GET /api/locations/{id}/` - Location details

### Notifications
- `GET /api/notifications/` - List notifications
- `POST /api/notifications/` - Create notification
- `PATCH /api/notifications/{id}/` - Mark as read

---

## 🎯 Features Implemented

### User Features
- ✅ Role-based authentication (Renter, Landlord, Agent)
- ✅ User registration and login
- ✅ Profile management
- ✅ Password recovery
- ✅ Biometric authentication (local_auth)

### Property Management
- ✅ Browse property listings with filters
- ✅ Advanced search (by area, price, bedrooms, property type)
- ✅ Property details with images
- ✅ Favorite listings management
- ✅ Property inquiry system

### Landlord Features
- ✅ Add/edit/delete properties
- ✅ Dashboard with property analytics
- ✅ Manage inquiries from renters
- ✅ Property verification status

### Mobile UI
- ✅ Material Design 3
- ✅ Bottom navigation (Explore, Saved, Profile)
- ✅ Property filtering and search
- ✅ Responsive layouts
- ✅ Dark theme ready

---

## 🧪 Testing

### Backend Tests
```powershell
cd backend
.\venv\Scripts\python manage.py test
```

### API Testing with Django Admin
```
http://localhost:8000/admin
Username: admin
Password: admin123
```

### Manual Testing
1. Start backend: `python manage.py runserver 0.0.0.0:8000`
2. Start frontend: `flutter run`
3. Register as renter and landlord
4. Create listings as landlord
5. Search and save favorites as renter
6. Send and manage inquiries

---

## 📱 Development Workflow

### Adding a New Feature

1. **Backend:**
   ```powershell
   # Create new app if needed
   python manage.py startapp feature_name
   
   # Define models in feature_name/models.py
   # Create serializers in feature_name/serializers.py
   # Define views in feature_name/views.py
   # Create URLs in feature_name/urls.py
   # Add to settings.INSTALLED_APPS
   
   # Create migrations
   python manage.py makemigrations
   python manage.py migrate
   ```

2. **Frontend:**
   - Add new screen in `lib/screens/feature_name/`
   - Create service in `lib/services/` if needed
   - Update main navigation if required
   - Add models in `lib/models/`

3. **Integration:**
   - Update API service to call new endpoints
   - Handle authentication tokens
   - Test end-to-end

### Environment Variables

Backend `.env`:
```
PORT=8000
SECRET_KEY=your-secret-key
DEBUG=True
DATABASE_URL=your-database-url
JWT_SECRET=your-jwt-secret
```

Frontend `.dart-define`:
```
API_BASE_URL=http://192.168.x.x:8000/api
```

---

## 🔐 Security Checklist

- [x] CORS configured for development
- [x] JWT/Token authentication implemented
- [x] User roles and permissions set up
- [x] Database configured with SQLite (dev) / PostgreSQL (prod)
- [ ] HTTPS enabled (production only)
- [ ] Environment variables secured
- [ ] API rate limiting (recommended for production)
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention (Django ORM)

**Production Recommendations:**
```python
# In settings.py for production:
DEBUG = False
ALLOWED_HOSTS = ['your-domain.com', 'www.your-domain.com']
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
```

---

## 📦 Deployment

### Backend Deployment (Django)

**Option 1: Railway/Heroku**
```bash
# Create Procfile
web: gunicorn config.wsgi
release: python manage.py migrate

# Deploy
git push heroku main
```

**Option 2: AWS/DigitalOcean**
```bash
# Install dependencies
pip install gunicorn psycopg2-binary

# Run with Gunicorn
gunicorn config.wsgi:application --bind 0.0.0.0:8000
```

### Frontend Deployment (Flutter)

**Android APK:**
```bash
cd frontend/rent_hub_app
flutter build apk
# APK available at: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (Google Play):**
```bash
flutter build appbundle
# Bundle available at: build/app/outputs/bundle/release/app-release.aab
```

**iOS App:**
```bash
flutter build ios
# Follow iOS deployment instructions
```

---

## 🐛 Troubleshooting

### Backend Won't Start
```powershell
# Clear cache
python manage.py clear_cache

# Rebuild migrations
python manage.py makemigrations --merge

# Check migrations
python manage.py showmigrations

# Reset database (DEV ONLY)
rm db.sqlite3
python manage.py migrate
python manage.py seed_demo.py
```

### Flutter App Can't Connect to API
- Check backend is running: `http://localhost:8000/api/listings/`
- Verify LAN IP: `ipconfig`
- Update API URL if IP changed: `flutter run --dart-define=API_BASE_URL=http://NEW_IP:8000/api`
- Check Windows Firewall allows Python on port 8000

### Login Issues
- Verify user exists: `python manage.py shell`
- Check token authentication in settings.py
- Verify API endpoint: `POST /api/auth/login/`

### Database Issues
```powershell
# Check SQLite database
python manage.py dbshell

# Rebuild from scratch
rm db.sqlite3
python manage.py migrate
python manage.py seed_demo.py
```

---

## 📚 Documentation Links

- [Django Documentation](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language](https://dart.dev/)

---

## 📞 Support & Maintenance

### Regular Maintenance
- Update dependencies: `pip install --upgrade -r requirements.txt`
- Run security checks: `python manage.py check --deploy`
- Clear old migrations if needed
- Monitor database size

### Monitoring
- Django Debug Toolbar (dev only)
- Application logs: Check Django console output
- Database backups: Implement daily backups for production

---

## ✅ Checklist for Production

- [ ] Database migrated to PostgreSQL
- [ ] Environment variables properly secured
- [ ] SSL/HTTPS enabled
- [ ] Static files collected: `python manage.py collectstatic`
- [ ] Media files properly configured
- [ ] Backup strategy implemented
- [ ] Error logging configured (Sentry/Rollbar)
- [ ] API rate limiting enabled
- [ ] CORS properly restricted
- [ ] Admin password changed from default
- [ ] Flutter app tested on real devices
- [ ] App signed and ready for store submission

---

## 🎉 You're All Set!

Your Rent Hub Ghana application is complete and ready to use. Follow the Quick Start section above to begin development and testing.

**Happy coding!** 🚀
