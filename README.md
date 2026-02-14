# 🛠️ IT Equipment & Hardware Inventory System

A comprehensive web-based inventory management system optimized for tablet use, specifically designed for IT Lab Custodians to track PC parts, peripherals, and specialized equipment with ease.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [System Requirements](#system-requirements)
- [Installation Guide](#installation-guide)
- [Database Setup](#database-setup)
- [Usage Guide](#usage-guide)
- [User Persona](#user-persona)
- [API Documentation](#api-documentation)
- [File Structure](#file-structure)
- [Troubleshooting](#troubleshooting)

---

## ✨ Features

### 🎯 Core Functionality

1. **Visual Floor Plan**
   - Interactive map for 3 locations:
     - Room 209: 5 rows × 8 positions (2 columns of 4) = 40 PCs (grid view)
     - Room 210: 5 rows × 8 positions (2 columns of 4) = 40 PCs (grid view)
     - CCS Office: 10 Drawing Tablets (list view with detailed information)
   - Tab switching between locations
   - Color-coded status indicators:
     - ✅ Good (Green)
     - ⚠️ Warning (Yellow)
     - ❌ Defective (Red)
     - 📤 Borrowed (Blue)
   - Flash animation for overdue borrowed items

2. **Universal Search**
   - Search by **Student Name** OR **Item Name**
   - Real-time filtering with instant results
   - Highlights matching items on floor plan

3. **Asset Lifecycle History**
   - Complete "medical record" for each device
   - Repair history with costs and parts replaced
   - Previous borrowers and transaction history
   - Upgrade logs and maintenance records

4. **Batch Updates**
   - Select multiple items simultaneously
   - Bulk status updates (Good/Warning/Defective)
   - "Select All Visible" function
   - Visual selection indicators

5. **Low-Stock Alerts**
   - Automatic alerts when spare peripherals fall below threshold
   - Consumable item tracking (mice, cables, etc.)
   - Visual notifications on dashboard

6. **Borrowing System**
   - Track student borrowers
   - Expected return dates
   - Automatic overdue detection
   - Return processing workflow

---

## 🔧 Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | HTML5, CSS3, Vanilla JavaScript |
| **Backend** | PHP 7.4+ |
| **Database** | MySQL 5.7+ / MariaDB 10.3+ |
| **Server** | Apache (XAMPP) |

---

## 💻 System Requirements

- **Web Server**: Apache 2.4+
- **PHP**: Version 7.4 or higher
- **MySQL/MariaDB**: Version 5.7+ / 10.3+
- **Browser**: Modern browser (Chrome, Firefox, Safari, Edge)
- **Recommended**: Tablet device (768px - 1024px screen)

---

## 📥 Installation Guide

### Step 1: Install XAMPP

1. Download XAMPP from [https://www.apachefriends.org](https://www.apachefriends.org)
2. Install XAMPP to default location (`C:\xampp`)
3. Start Apache and MySQL from XAMPP Control Panel

### Step 2: Deploy Files

The files are already in the correct location:
```
C:\xampp\htdocs\hcimidterm\
├── index.html          (Main dashboard)
├── styles.css          (Tablet-optimized styles)
├── app.js              (Frontend logic)
├── api.php             (Backend API)
├── schema.sql          (Database schema)
├── setup-check.html    (Installation checker)
└── README.md           (This file)
```

### Step 3: Create Database

1. Open phpMyAdmin: [http://localhost/phpmyadmin](http://localhost/phpmyadmin)
2. Click "New" to create a database
3. Database name: `it_inventory`
4. Collation: `utf8mb4_general_ci`
5. Click "Create"

### Step 4: Import Database Schema

**Option A: Using phpMyAdmin**
1. Select the `it_inventory` database
2. Click "Import" tab
3. Choose file: `schema.sql`
4. Click "Go"

**Option B: Using MySQL Command Line**
```bash
cd C:\xampp\htdocs\hcimidterm
mysql -u root -p it_inventory < schema.sql
```

### Step 5: Configure Database Connection

Open `api.php` and verify these settings (lines 20-23):
```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');           // Set password if you have one
define('DB_NAME', 'it_inventory');
```

### Step 6: Access the Application

Open your browser and navigate to:
```
http://localhost/hcimidterm/
```

---

## 🗄️ Database Setup

The system includes 6 main tables:

### Tables Overview

| Table | Purpose |
|-------|---------|
| `categories` | Equipment categories (PC, Monitor, Mouse, Drawing Tablet, etc.) |
| `locations` | Physical locations (Room 209, Room 210, CCS Office) |
| `students` | Student/borrower information |
| `assets` | Main inventory table for all equipment |
| `transactions` | Borrowing and return history |
| `repair_logs` | Repair, defect, and upgrade records |

### Sample Data

The schema includes sample data:
- 11 equipment categories (PC, Monitor, Keyboard, Mouse, Headset, Webcam, Printer, RAM, SSD, Power Supply, Drawing Tablet)
- 90 locations:
  - Room 209: 5 rows × 8 positions = 40
  - Room 210: 5 rows × 8 positions = 40
  - CCS Office: 2 rows × 5 positions = 10
- 3 sample students
- 91 sample assets:
  - 40 PCs in Room 209
  - 40 PCs in Room 210
  - 10 Drawing Tablets in CCS Office (for faculty borrowing)
  - 1 consumable item
- Sample transactions and repair logs
  - 1 borrowed PC (Room 210)
  - 2 borrowed Drawing Tablets (CCS Office)
  - 2 defective PCs with repair logs

### Useful Views

The system includes 3 pre-built views:

1. **`low_stock_items`** - Consumables below minimum threshold
2. **`currently_borrowed`** - Active borrowing transactions with overdue detection
3. **`asset_health_dashboard`** - Complete asset overview with statistics

### Stored Procedures

1. **`update_overdue_transactions()`** - Mark overdue items
2. **`get_asset_lifecycle(asset_id)`** - Get complete history for an asset

---

## 📱 Usage Guide

### For Kuya Dante (Lab Custodian)

#### Adding New Equipment

1. Click **"➕ Add New Item"** button
2. Fill in **Tab 1: Basic Info** (required fields marked with *)
   - Serial Number (REQUIRED)
   - Item Name (REQUIRED)
   - Category (REQUIRED)
   - Status
3. Switch to **Tab 2: Advanced Tech** for technical details
   - MAC Address, IP Address, Specifications
4. Use **Tab 3: Stock Info** for bulk items
   - Check "consumable" for mice, cables, etc.
   - Set quantity and minimum stock threshold
5. Click **"💾 Save Item"**

#### Searching for Items

Use the search bar to find:
- **By Item**: "Desktop PC #1", "Mouse", "Monitor"
- **By Student**: "Juan Dela Cruz" (finds borrowed items)
- **By Serial**: "SN-PC-001"

#### Batch Updating Status

1. Click **"☑️ Batch Select"** button
2. Click items to select them (checkboxes appear)
3. Use "Select All Visible" to select filtered items
4. Click status button:
   - **✅ Mark as Good**
   - **⚠️ Mark as Warning**
   - **❌ Mark as Defective**
5. Confirm the update

#### Viewing Item History

1. Click any item on the floor plan
2. Item details card appears on the right
3. Click **"📜 View History"** button
4. See complete timeline:
   - Repairs and defects
   - Previous borrowers
   - Upgrades and maintenance

#### Processing Returns

1. Click **"⏰ Overdue Returns"** button
2. View list of overdue items (highlighted in yellow)
3. Click **"Return"** button for the item
4. Confirm return

#### Checking Low Stock

1. Click **"📦 Low Stock Alerts"** button
2. View items below minimum threshold
3. Note shortage amounts
4. Order more supplies as needed

---

## 🎨 Design & UX Features

### Error Prevention

- **Serial Number is REQUIRED** - Form cannot be submitted without it
- **Confirmation dialogs** for destructive actions (delete, batch update)
- **Delete button hidden** in sub-menu to prevent accidental deletion

### Visual Feedback

- **Color-coded status** throughout the system
- **Overdue items flash yellow** on the floor plan
- **Touch targets** minimum 48px for tablet use
- **Hover effects** on all interactive elements
- **Loading spinner** during data operations

### Tablet Optimization

- **Large buttons** optimized for finger tapping
- **Spacing** designed for touch accuracy
- **Responsive grid** adapts to tablet orientation
- **No tiny links** - everything is easily tappable

---

## 🔌 API Documentation

The system uses a RESTful PHP API (`api.php`).

### Endpoints

#### Assets

```
GET  api.php?action=getAssets           - Get all assets
GET  api.php?action=getAsset&id=1       - Get single asset
POST api.php?action=createAsset         - Create new asset
PUT  api.php?action=updateAsset&id=1    - Update asset
DEL  api.php?action=deleteAsset&id=1    - Delete asset (soft delete)
POST api.php?action=batchUpdateAssets   - Batch update status
```

#### Dashboard & Search

```
GET  api.php?action=getDashboard                    - Get all dashboard data
GET  api.php?action=getLowStock                     - Get low stock items
GET  api.php?action=getOverdueTransactions          - Get overdue returns
GET  api.php?action=getAssetLifecycle&assetId=1     - Get asset history
GET  api.php?action=search&query=searchterm         - Universal search
```

#### Transactions

```
GET  api.php?action=getTransactions     - Get all transactions
POST api.php?action=borrowAsset         - Borrow an asset
POST api.php?action=returnAsset         - Return an asset
```

#### Reference Data

```
GET  api.php?action=getCategories       - Get all categories
GET  api.php?action=getLocations        - Get all locations
GET  api.php?action=getStudents         - Get all students
```

### Example API Call (JavaScript)

```javascript
// Get all assets
fetch('api.php?action=getAssets')
  .then(response => response.json())
  .then(data => {
    console.log(data.assets);
  });

// Create new asset
fetch('api.php?action=createAsset', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    serialNumber: 'SN-PC-999',
    name: 'Desktop PC #999',
    categoryId: 1,
    status: 'good'
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

---

## 📁 File Structure

```
hcimidterm/
│
├── index.html              # Main dashboard HTML structure
│   ├── Header with user info
│   ├── Universal search bar
│   ├── Visual floor plan grid
│   ├── Item details panel
│   ├── Modals (Add item, Low stock, Overdue)
│   └── Loading overlay
│
├── styles.css              # Tablet-optimized styling
│   ├── CSS variables for theming
│   ├── Touch-friendly button styles
│   ├── Status color system
│   ├── Responsive grid layouts
│   ├── Modal and animation styles
│   └── Print styles
│
├── app.js                  # Frontend JavaScript logic
│   ├── AppState management
│   ├── Floor plan rendering
│   ├── Universal search
│   ├── Batch selection
│   ├── Tab switching
│   ├── Form handling
│   ├── Modal management
│   └── API communication helpers
│
├── api.php                 # Backend PHP API
│   ├── Database connection
│   ├── CRUD operations for assets
│   ├── Transaction management
│   ├── Search functionality
│   ├── Dashboard aggregation
│   └── Error handling
│
├── schema.sql              # MySQL database schema
│   ├── Table definitions
│   ├── Foreign key constraints
│   ├── Indexes for performance
│   ├── Views for common queries
│   ├── Stored procedures
│   └── Sample data
│
└── README.md               # This documentation file
```

---

## 🐛 Troubleshooting

### Issue: "Database connection error"

**Solution:**
1. Verify MySQL is running in XAMPP Control Panel
2. Check database name: `it_inventory`
3. Verify credentials in `api.php` (lines 20-23)
4. Test connection: [http://localhost/phpmyadmin](http://localhost/phpmyadmin)

### Issue: "Page not found (404)"

**Solution:**
1. Verify Apache is running in XAMPP
2. Check URL: `http://localhost/hcimidterm/`
3. Ensure files are in `C:\xampp\htdocs\hcimidterm\`

### Issue: "API returns empty data"

**Solution:**
1. Import database schema: `schema.sql`
2. Check browser console (F12) for errors
3. Test API directly: `http://localhost/hcimidterm/api.php?action=ping`
4. Verify sample data was imported

### Issue: "Floor plan doesn't show items"

**Solution:**
1. Open browser console (F12) and check for JavaScript errors
2. Ensure `app.js` is loading correctly
3. Verify API is returning data: `api.php?action=getAssets`
4. Clear browser cache (Ctrl + F5)

### Issue: "Buttons too small on tablet"

**Solution:**
- The system is optimized for tablets (768px+)
- Zoom browser to 100%
- Touch targets are minimum 48×48px per design guidelines

### Issue: "Search not working"

**Solution:**
1. Check console for JavaScript errors
2. Verify database has data
3. Test search endpoint: `api.php?action=search&query=test`
4. Ensure JavaScript is enabled

---

## 🎯 Testing Checklist

After installation, test these features:

- [ ] Dashboard loads with sample data
- [ ] Floor plan shows color-coded items
- [ ] Search by item name works
- [ ] Search by student name works
- [ ] Filter chips change displayed items
- [ ] Batch mode enables selection
- [ ] Item details card opens on click
- [ ] Asset lifecycle shows history
- [ ] Add new item form validates serial number
- [ ] Tab switching works in forms
- [ ] Low stock modal displays correctly
- [ ] Overdue modal shows overdue items
- [ ] Alert banner appears when needed
- [ ] Touch/click interactions feel responsive

---

## 👤 User Persona

**Name:** "Kuya" Dante  
**Role:** Senior Lab Custodian  
**Age:** 45  
**Tech Skills:** Intermediate (great with hardware, prefers simple software)

**Needs:**
- ✅ Large, easy-to-tap buttons
- ✅ Visual UI rather than text-heavy spreadsheets
- ✅ Fast batch processing to prevent data entry fatigue
- ✅ Mobile/tablet access during lab inspections

**Pain Points Solved:**
- ❌ No more manual spreadsheet hunting
- ❌ No more lost equipment without tracking
- ❌ No more overdue items forgotten
- ❌ No more uncertainty about stock levels

---

## 📊 Future Enhancements

Potential features for future versions:

1. **QR Code Scanning** - Quick asset lookup via QR codes
2. **Additional Labs** - Support for Lab C, D, etc. (currently supports 2 labs)
3. **Email Notifications** - Automatic reminders for overdue items
4. **Advanced Reports** - PDF exports, asset utilization reports
5. **User Roles** - Admin vs. Regular custodian permissions
6. **Maintenance Scheduling** - Preventive maintenance reminders
7. **Photo Uploads** - Asset photos and defect documentation
8. **Offline Mode** - PWA with offline capabilities
9. **Barcode Scanner** - Hardware barcode scanner integration
10. **Dashboard Analytics** - Charts and graphs for insights

---

## 📄 License

This project is created for educational purposes (HCI Midterm Project).

---

## 👨‍💻 Support

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review the [Usage Guide](#usage-guide)
3. Inspect browser console (F12) for errors
4. Check Apache and MySQL are running in XAMPP

---

## 🎉 Credits

**Developed by:** [Your Name]  
**Date:** February 14, 2026  
**Purpose:** HCI Midterm Project - IT Equipment Inventory System  
**Optimized for:** Tablet Use (iPad, Android Tablets)

---

## 🚀 Quick Start Commands

```bash
# Start XAMPP services (Windows)
# Use XAMPP Control Panel to start Apache and MySQL

# Access phpMyAdmin
http://localhost/phpmyadmin

# Access Application
http://localhost/hcimidterm/

# Test API
http://localhost/hcimidterm/api.php?action=ping

# Import Database
# From MySQL command line:
mysql -u root -p it_inventory < schema.sql
```

---

**Enjoy managing your IT equipment inventory! 🛠️✨**