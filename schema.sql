-- IT Equipment & Hardware Inventory System
-- Database Schema for MySQL
-- Created: 2026-02-14

-- Drop existing tables if they exist (for clean reinstall)
DROP TABLE IF EXISTS repair_logs;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS assets;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS categories;

-- ============================================
-- TABLE: categories
-- Stores equipment categories (PC, Monitor, Mouse, etc.)
-- ============================================
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    icon VARCHAR(50) DEFAULT '💻',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- TABLE: locations
-- Stores physical locations (Lab A, Row 1, etc.)
-- ============================================
CREATE TABLE locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    lab_name VARCHAR(50) NOT NULL,
    row_number INT NOT NULL,
    position_number INT NOT NULL,
    coordinates_x INT DEFAULT 0,
    coordinates_y INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_position (lab_name, row_number, position_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- TABLE: students
-- Stores student/borrower information
-- ============================================
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(150) NOT NULL,
    student_number VARCHAR(50) UNIQUE,
    email VARCHAR(150),
    phone VARCHAR(20),
    department VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_student_name (student_name),
    INDEX idx_student_number (student_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- TABLE: assets
-- Main inventory table for all equipment
-- ============================================
CREATE TABLE assets (
    asset_id INT AUTO_INCREMENT PRIMARY KEY,
    serial_number VARCHAR(100) NOT NULL UNIQUE,
    asset_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    location_id INT,
    
    -- Status: 'good', 'warning', 'defective', 'borrowed', 'retired'
    status ENUM('good', 'warning', 'defective', 'borrowed', 'retired') DEFAULT 'good',
    
    -- Basic Info
    brand VARCHAR(100),
    model VARCHAR(100),
    purchase_date DATE,
    warranty_expiry DATE,
    purchase_price DECIMAL(10, 2),
    
    -- Advanced Technical Info
    mac_address VARCHAR(17),
    ip_address VARCHAR(45),
    specifications TEXT,
    notes TEXT,
    
    -- Stock Management (for peripherals)
    is_consumable BOOLEAN DEFAULT FALSE,
    quantity INT DEFAULT 1,
    min_stock_threshold INT DEFAULT 5,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id),
    INDEX idx_status (status),
    INDEX idx_asset_name (asset_name),
    INDEX idx_serial (serial_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- TABLE: transactions
-- Borrowing and returning history
-- ============================================
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_id INT NOT NULL,
    student_id INT NOT NULL,
    
    -- Transaction Type: 'borrow', 'return'
    transaction_type ENUM('borrow', 'return') NOT NULL,
    
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    expected_return_date DATE,
    actual_return_date DATE,
    
    -- Status: 'active', 'completed', 'overdue'
    status ENUM('active', 'completed', 'overdue') DEFAULT 'active',
    
    notes TEXT,
    handled_by VARCHAR(100) DEFAULT 'Kuya Dante',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_status (status),
    INDEX idx_asset_student (asset_id, student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- TABLE: repair_logs
-- "Medical Record" for each device
-- ============================================
CREATE TABLE repair_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_id INT NOT NULL,
    
    -- Log Type: 'repair', 'upgrade', 'maintenance', 'defect_report'
    log_type ENUM('repair', 'upgrade', 'maintenance', 'defect_report') NOT NULL,
    
    issue_description TEXT NOT NULL,
    action_taken TEXT,
    
    -- Cost tracking
    cost DECIMAL(10, 2) DEFAULT 0.00,
    
    -- Parts replaced/upgraded
    parts_replaced TEXT,
    
    -- Status: 'pending', 'in_progress', 'completed'
    repair_status ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending',
    
    technician_name VARCHAR(100),
    log_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_date DATETIME,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id) ON DELETE CASCADE,
    INDEX idx_asset_id (asset_id),
    INDEX idx_log_date (log_date),
    INDEX idx_log_type (log_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- SAMPLE DATA
-- ============================================

-- Insert Categories
INSERT INTO categories (category_name, icon) VALUES
('Desktop PC', '🖥️'),
('Monitor', '🖥️'),
('Keyboard', '⌨️'),
('Mouse', '🖱️'),
('Printer', '🖨️'),
('Network Cable', '🔌'),
('Headset', '🎧'),
('Webcam', '📷'),
('External HDD', '💾'),
('Power Supply', '⚡'),
('Drawing Tablet', '🎨');

-- Insert Locations (Room 209: 5 Rows x 8 Positions = 40 PCs, 2 columns of 4)
-- Insert Locations (Room 210: 5 Rows x 8 Positions = 40 PCs, 2 columns of 4)
-- Insert Locations (CCS Office: 2 Rows x 5 Positions = 10 Drawing Tablets)
INSERT INTO locations (lab_name, row_number, position_number, coordinates_x, coordinates_y) VALUES
-- Room 209 (IDs 1-40)
('Room 209', 1, 1, 100, 100), ('Room 209', 1, 2, 200, 100), ('Room 209', 1, 3, 300, 100), ('Room 209', 1, 4, 400, 100), ('Room 209', 1, 5, 550, 100), ('Room 209', 1, 6, 650, 100), ('Room 209', 1, 7, 750, 100), ('Room 209', 1, 8, 850, 100),
('Room 209', 2, 1, 100, 200), ('Room 209', 2, 2, 200, 200), ('Room 209', 2, 3, 300, 200), ('Room 209', 2, 4, 400, 200), ('Room 209', 2, 5, 550, 200), ('Room 209', 2, 6, 650, 200), ('Room 209', 2, 7, 750, 200), ('Room 209', 2, 8, 850, 200),
('Room 209', 3, 1, 100, 300), ('Room 209', 3, 2, 200, 300), ('Room 209', 3, 3, 300, 300), ('Room 209', 3, 4, 400, 300), ('Room 209', 3, 5, 550, 300), ('Room 209', 3, 6, 650, 300), ('Room 209', 3, 7, 750, 300), ('Room 209', 3, 8, 850, 300),
('Room 209', 4, 1, 100, 400), ('Room 209', 4, 2, 200, 400), ('Room 209', 4, 3, 300, 400), ('Room 209', 4, 4, 400, 400), ('Room 209', 4, 5, 550, 400), ('Room 209', 4, 6, 650, 400), ('Room 209', 4, 7, 750, 400), ('Room 209', 4, 8, 850, 400),
('Room 209', 5, 1, 100, 500), ('Room 209', 5, 2, 200, 500), ('Room 209', 5, 3, 300, 500), ('Room 209', 5, 4, 400, 500), ('Room 209', 5, 5, 550, 500), ('Room 209', 5, 6, 650, 500), ('Room 209', 5, 7, 750, 500), ('Room 209', 5, 8, 850, 500),
-- Room 210 (IDs 41-80)
('Room 210', 1, 1, 100, 100), ('Room 210', 1, 2, 200, 100), ('Room 210', 1, 3, 300, 100), ('Room 210', 1, 4, 400, 100), ('Room 210', 1, 5, 550, 100), ('Room 210', 1, 6, 650, 100), ('Room 210', 1, 7, 750, 100), ('Room 210', 1, 8, 850, 100),
('Room 210', 2, 1, 100, 200), ('Room 210', 2, 2, 200, 200), ('Room 210', 2, 3, 300, 200), ('Room 210', 2, 4, 400, 200), ('Room 210', 2, 5, 550, 200), ('Room 210', 2, 6, 650, 200), ('Room 210', 2, 7, 750, 200), ('Room 210', 2, 8, 850, 200),
('Room 210', 3, 1, 100, 300), ('Room 210', 3, 2, 200, 300), ('Room 210', 3, 3, 300, 300), ('Room 210', 3, 4, 400, 300), ('Room 210', 3, 5, 550, 300), ('Room 210', 3, 6, 650, 300), ('Room 210', 3, 7, 750, 300), ('Room 210', 3, 8, 850, 300),
('Room 210', 4, 1, 100, 400), ('Room 210', 4, 2, 200, 400), ('Room 210', 4, 3, 300, 400), ('Room 210', 4, 4, 400, 400), ('Room 210', 4, 5, 550, 400), ('Room 210', 4, 6, 650, 400), ('Room 210', 4, 7, 750, 400), ('Room 210', 4, 8, 850, 400),
('Room 210', 5, 1, 100, 500), ('Room 210', 5, 2, 200, 500), ('Room 210', 5, 3, 300, 500), ('Room 210', 5, 4, 400, 500), ('Room 210', 5, 5, 550, 500), ('Room 210', 5, 6, 650, 500), ('Room 210', 5, 7, 750, 500), ('Room 210', 5, 8, 850, 500),
-- CCS Office (IDs 81-90)
('CCS Office', 1, 1, 100, 100), ('CCS Office', 1, 2, 200, 100), ('CCS Office', 1, 3, 300, 100), ('CCS Office', 1, 4, 400, 100), ('CCS Office', 1, 5, 500, 100),
('CCS Office', 2, 1, 100, 200), ('CCS Office', 2, 2, 200, 200), ('CCS Office', 2, 3, 300, 200), ('CCS Office', 2, 4, 400, 200), ('CCS Office', 2, 5, 500, 200);

-- Insert sample students
INSERT INTO students (student_name, student_number, email, department) VALUES
('Juan Dela Cruz', '2024-001', 'juan.delacruz@university.edu', 'Computer Science'),
('Maria Santos', '2024-002', 'maria.santos@university.edu', 'Information Technology'),
('Pedro Reyes', '2024-003', 'pedro.reyes@university.edu', 'Computer Engineering');

-- Insert sample assets for both Room 209 and Room 210 (40 PCs each)
INSERT INTO assets (serial_number, asset_name, category_id, location_id, status, brand, model, mac_address, ip_address, specifications) VALUES
-- Room 209 Assets (40 PCs - 5 Rows x 8 Positions - Location IDs 1-40)
('SN-PC-209-001', 'Desktop PC 209-R1P1', 1, 1, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:01', '192.168.209.1', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-002', 'Desktop PC 209-R1P2', 1, 2, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:02', '192.168.209.2', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-003', 'Desktop PC 209-R1P3', 1, 3, 'good', 'HP', 'ProDesk 600', '00:1B:44:11:3A:03', '192.168.209.3', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-209-004', 'Desktop PC 209-R1P4', 1, 4, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:04', '192.168.209.4', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-005', 'Desktop PC 209-R1P5', 1, 5, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3A:05', '192.168.209.5', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-006', 'Desktop PC 209-R1P6', 1, 6, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:06', '192.168.209.6', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-007', 'Desktop PC 209-R1P7', 1, 7, 'warning', 'HP', 'ProDesk 600', '00:1B:44:11:3A:07', '192.168.209.7', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-209-008', 'Desktop PC 209-R1P8', 1, 8, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3A:08', '192.168.209.8', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-009', 'Desktop PC 209-R2P1', 1, 9, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:09', '192.168.209.9', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-010', 'Desktop PC 209-R2P2', 1, 10, 'good', 'HP', 'EliteDesk 800', '00:1B:44:11:3A:10', '192.168.209.10', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-011', 'Desktop PC 209-R2P3', 1, 11, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:11', '192.168.209.11', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-012', 'Desktop PC 209-R2P4', 1, 12, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3A:12', '192.168.209.12', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-013', 'Desktop PC 209-R2P5', 1, 13, 'good', 'HP', 'ProDesk 600', '00:1B:44:11:3A:13', '192.168.209.13', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-209-014', 'Desktop PC 209-R2P6', 1, 14, 'defective', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:14', '192.168.209.14', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-015', 'Desktop PC 209-R2P7', 1, 15, 'good', 'HP', 'EliteDesk 800', '00:1B:44:11:3A:15', '192.168.209.15', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-016', 'Desktop PC 209-R2P8', 1, 16, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:16', '192.168.209.16', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-017', 'Desktop PC 209-R3P1', 1, 17, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3A:17', '192.168.209.17', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-018', 'Desktop PC 209-R3P2', 1, 18, 'good', 'HP', 'ProDesk 600', '00:1B:44:11:3A:18', '192.168.209.18', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-209-019', 'Desktop PC 209-R3P3', 1, 19, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:19', '192.168.209.19', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-020', 'Desktop PC 209-R3P4', 1, 20, 'warning', 'HP', 'EliteDesk 800', '00:1B:44:11:3A:20', '192.168.209.20', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-021', 'Desktop PC 209-R3P5', 1, 21, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:21', '192.168.209.21', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-022', 'Desktop PC 209-R3P6', 1, 22, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3A:22', '192.168.209.22', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-023', 'Desktop PC 209-R3P7', 1, 23, 'good', 'HP', 'ProDesk 600', '00:1B:44:11:3A:23', '192.168.209.23', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-209-024', 'Desktop PC 209-R3P8', 1, 24, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:24', '192.168.209.24', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-025', 'Desktop PC 209-R4P1', 1, 25, 'good', 'HP', 'EliteDesk 800', '00:1B:44:11:3A:25', '192.168.209.25', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-026', 'Desktop PC 209-R4P2', 1, 26, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:26', '192.168.209.26', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-027', 'Desktop PC 209-R4P3', 1, 27, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3A:27', '192.168.209.27', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-028', 'Desktop PC 209-R4P4', 1, 28, 'good', 'HP', 'ProDesk 600', '00:1B:44:11:3A:28', '192.168.209.28', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-209-029', 'Desktop PC 209-R4P5', 1, 29, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:29', '192.168.209.29', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-030', 'Desktop PC 209-R4P6', 1, 30, 'good', 'HP', 'EliteDesk 800', '00:1B:44:11:3A:30', '192.168.209.30', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-031', 'Desktop PC 209-R4P7', 1, 31, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:31', '192.168.209.31', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-032', 'Desktop PC 209-R4P8', 1, 32, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3A:32', '192.168.209.32', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-033', 'Desktop PC 209-R5P1', 1, 33, 'good', 'HP', 'ProDesk 600', '00:1B:44:11:3A:33', '192.168.209.33', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-209-034', 'Desktop PC 209-R5P2', 1, 34, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:34', '192.168.209.34', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-035', 'Desktop PC 209-R5P3', 1, 35, 'good', 'HP', 'EliteDesk 800', '00:1B:44:11:3A:35', '192.168.209.35', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-036', 'Desktop PC 209-R5P4', 1, 36, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:36', '192.168.209.36', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-037', 'Desktop PC 209-R5P5', 1, 37, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3A:37', '192.168.209.37', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-038', 'Desktop PC 209-R5P6', 1, 38, 'good', 'HP', 'ProDesk 600', '00:1B:44:11:3A:38', '192.168.209.38', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-209-039', 'Desktop PC 209-R5P7', 1, 39, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:39', '192.168.209.39', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-209-040', 'Desktop PC 209-R5P8', 1, 40, 'good', 'HP', 'EliteDesk 800', '00:1B:44:11:3A:40', '192.168.209.40', 'Intel i7, 16GB RAM, 512GB SSD'),
-- Room 210 Assets (40 PCs - 5 Rows x 8 Positions - Location IDs 41-80)
('SN-PC-210-001', 'Desktop PC 210-R1P1', 1, 41, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:01', '192.168.210.1', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-002', 'Desktop PC 210-R1P2', 1, 42, 'good', 'HP', 'EliteDesk 800', '00:1B:44:11:3B:02', '192.168.210.2', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-003', 'Desktop PC 210-R1P3', 1, 43, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3B:03', '192.168.210.3', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-210-004', 'Desktop PC 210-R1P4', 1, 44, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:04', '192.168.210.4', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-005', 'Desktop PC 210-R1P5', 1, 45, 'good', 'HP', 'ProDesk 600', '00:1B:44:11:3B:05', '192.168.210.5', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-210-006', 'Desktop PC 210-R1P6', 1, 46, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:06', '192.168.210.6', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-007', 'Desktop PC 210-R1P7', 1, 47, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3B:07', '192.168.210.7', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-008', 'Desktop PC 210-R1P8', 1, 48, 'warning', 'HP', 'ProDesk 600', '00:1B:44:11:3B:08', '192.168.210.8', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-210-009', 'Desktop PC 210-R2P1', 1, 49, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:09', '192.168.210.9', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-010', 'Desktop PC 210-R2P2', 1, 50, 'good', 'HP', 'EliteDesk 800', '00:1B:44:11:3B:10', '192.168.210.10', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-011', 'Desktop PC 210-R2P3', 1, 51, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:11', '192.168.210.11', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-012', 'Desktop PC 210-R2P4', 1, 52, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3B:12', '192.168.210.12', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-013', 'Desktop PC 210-R2P5', 1, 53, 'good', 'HP', 'ProDesk 600', '00:1B:44:11:3B:13', '192.168.210.13', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-210-014', 'Desktop PC 210-R2P6', 1, 54, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:14', '192.168.210.14', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-015', 'Desktop PC 210-R2P7', 1, 55, 'defective', 'HP', 'EliteDesk 800', '00:1B:44:11:3B:15', '192.168.210.15', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-016', 'Desktop PC 210-R2P8', 1, 56, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:16', '192.168.210.16', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-017', 'Desktop PC 210-R3P1', 1, 57, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3B:17', '192.168.210.17', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-018', 'Desktop PC 210-R3P2', 1, 58, 'good', 'HP', 'ProDesk 600', '00:1B:44:11:3B:18', '192.168.210.18', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-210-019', 'Desktop PC 210-R3P3', 1, 59, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:19', '192.168.210.19', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-020', 'Desktop PC 210-R3P4', 1, 60, 'good', 'HP', 'EliteDesk 800', '00:1B:44:11:3B:20', '192.168.210.20', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-021', 'Desktop PC 210-R3P5', 1, 61, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:21', '192.168.210.21', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-022', 'Desktop PC 210-R3P6', 1, 62, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3B:22', '192.168.210.22', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-023', 'Desktop PC 210-R3P7', 1, 63, 'good', 'HP', 'ProDesk 600', '00:1B:44:11:3B:23', '192.168.210.23', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-210-024', 'Desktop PC 210-R3P8', 1, 64, 'borrowed', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:24', '192.168.210.24', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-025', 'Desktop PC 210-R4P1', 1, 65, 'good', 'HP', 'EliteDesk 800', '00:1B:44:11:3B:25', '192.168.210.25', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-026', 'Desktop PC 210-R4P2', 1, 66, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:26', '192.168.210.26', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-027', 'Desktop PC 210-R4P3', 1, 67, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3B:27', '192.168.210.27', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-028', 'Desktop PC 210-R4P4', 1, 68, 'good', 'HP', 'ProDesk 600', '00:1B:44:11:3B:28', '192.168.210.28', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-210-029', 'Desktop PC 210-R4P5', 1, 69, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:29', '192.168.210.29', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-030', 'Desktop PC 210-R4P6', 1, 70, 'good', 'HP', 'EliteDesk 800', '00:1B:44:11:3B:30', '192.168.210.30', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-031', 'Desktop PC 210-R4P7', 1, 71, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:31', '192.168.210.31', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-032', 'Desktop PC 210-R4P8', 1, 72, 'warning', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3B:32', '192.168.210.32', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-033', 'Desktop PC 210-R5P1', 1, 73, 'good', 'HP', 'ProDesk 600', '00:1B:44:11:3B:33', '192.168.210.33', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-210-034', 'Desktop PC 210-R5P2', 1, 74, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:34', '192.168.210.34', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-035', 'Desktop PC 210-R5P3', 1, 75, 'good', 'HP', 'EliteDesk 800', '00:1B:44:11:3B:35', '192.168.210.35', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-036', 'Desktop PC 210-R5P4', 1, 76, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:36', '192.168.210.36', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-037', 'Desktop PC 210-R5P5', 1, 77, 'good', 'Lenovo', 'ThinkCentre M90', '00:1B:44:11:3B:37', '192.168.210.37', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-038', 'Desktop PC 210-R5P6', 1, 78, 'good', 'HP', 'ProDesk 600', '00:1B:44:11:3B:38', '192.168.210.38', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-210-039', 'Desktop PC 210-R5P7', 1, 79, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3B:39', '192.168.210.39', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-210-040', 'Desktop PC 210-R5P8', 1, 80, 'good', 'HP', 'EliteDesk 800', '00:1B:44:11:3B:40', '192.168.210.40', 'Intel i7, 16GB RAM, 512GB SSD'),
-- CCS Office Assets (10 Drawing Tablets - Location IDs 81-90)
('SN-TABLET-001', 'Drawing Tablet CCS-R1P1', 11, 81, 'good', 'Wacom', 'Intuos Pro', NULL, NULL, 'Medium size, 8192 pressure levels'),
('SN-TABLET-002', 'Drawing Tablet CCS-R1P2', 11, 82, 'good', 'Wacom', 'Intuos Pro', NULL, NULL, 'Medium size, 8192 pressure levels'),
('SN-TABLET-003', 'Drawing Tablet CCS-R1P3', 11, 83, 'borrowed', 'Wacom', 'Intuos Pro', NULL, NULL, 'Medium size, 8192 pressure levels'),
('SN-TABLET-004', 'Drawing Tablet CCS-R1P4', 11, 84, 'good', 'XP-Pen', 'Artist 15.6', NULL, NULL, 'Display tablet, Full HD'),
('SN-TABLET-005', 'Drawing Tablet CCS-R1P5', 11, 85, 'borrowed', 'XP-Pen', 'Artist 15.6', NULL, NULL, 'Display tablet, Full HD'),
('SN-TABLET-006', 'Drawing Tablet CCS-R2P1', 11, 86, 'good', 'Wacom', 'Cintiq 16', NULL, NULL, 'Display tablet, 1920x1080'),
('SN-TABLET-007', 'Drawing Tablet CCS-R2P2', 11, 87, 'good', 'Wacom', 'Intuos Pro', NULL, NULL, 'Medium size, 8192 pressure levels'),
('SN-TABLET-008', 'Drawing Tablet CCS-R2P3', 11, 88, 'warning', 'XP-Pen', 'Artist 12', NULL, NULL, 'Compact display tablet'),
('SN-TABLET-009', 'Drawing Tablet CCS-R2P4', 11, 89, 'good', 'Wacom', 'Intuos Pro', NULL, NULL, 'Medium size, 8192 pressure levels'),
('SN-TABLET-010', 'Drawing Tablet CCS-R2P5', 11, 90, 'good', 'Huion', 'Kamvas Pro 13', NULL, NULL, 'Display tablet, 1920x1080'),
-- Consumables (no specific location)
('SN-MOUSE-BULK', 'Logitech Mice - Bulk', 4, NULL, 'good', 'Logitech', 'M170', NULL, NULL, 'Wireless Optical Mouse');

-- Update the mouse to be consumable with quantity
UPDATE assets SET is_consumable = TRUE, quantity = 15, min_stock_threshold = 5 WHERE serial_number = 'SN-MOUSE-BULK';

-- Insert a sample transaction (borrowed item - Desktop PC 210-R5P4)
INSERT INTO transactions (asset_id, student_id, transaction_type, expected_return_date, status) VALUES
((SELECT asset_id FROM assets WHERE serial_number = 'SN-PC-210-024'), 1, 'borrow', DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'active');

-- Insert sample repair logs
INSERT INTO repair_logs (asset_id, log_type, issue_description, action_taken, repair_status, technician_name, parts_replaced, cost) VALUES
((SELECT asset_id FROM assets WHERE serial_number = 'SN-PC-209-007'), 'defect_report', 'Random reboots under load', 'Replaced thermal paste, cleaned CPU fan', 'completed', 'Tech Mike', 'Thermal Paste', 150.00),
((SELECT asset_id FROM assets WHERE serial_number = 'SN-PC-210-015'), 'defect_report', 'Display artifacts, GPU overheating', 'GPU fan faulty - pending replacement', 'pending', 'Tech Mike', NULL, 0.00);

-- ============================================
-- USEFUL VIEWS
-- ============================================

-- Drop existing views if they exist
DROP VIEW IF EXISTS low_stock_items;
DROP VIEW IF EXISTS currently_borrowed;
DROP VIEW IF EXISTS asset_health_dashboard;

-- View: Low Stock Alerts
CREATE VIEW low_stock_items AS
SELECT 
    a.asset_id,
    a.asset_name,
    a.serial_number,
    c.category_name,
    a.quantity,
    a.min_stock_threshold,
    (a.min_stock_threshold - a.quantity) AS shortage
FROM assets a
JOIN categories c ON a.category_id = c.category_id
WHERE a.is_consumable = TRUE 
  AND a.quantity <= a.min_stock_threshold
ORDER BY shortage DESC;

-- View: Currently Borrowed Items
CREATE VIEW currently_borrowed AS
SELECT 
    t.transaction_id,
    a.asset_id,
    a.asset_name,
    a.serial_number,
    s.student_name,
    s.student_number,
    t.transaction_date,
    t.expected_return_date,
    DATEDIFF(CURDATE(), t.expected_return_date) AS days_overdue,
    CASE 
        WHEN CURDATE() > t.expected_return_date THEN 'overdue'
        ELSE 'active'
    END AS computed_status
FROM transactions t
JOIN assets a ON t.asset_id = a.asset_id
JOIN students s ON t.student_id = s.student_id
WHERE t.status = 'active' 
  AND t.transaction_type = 'borrow'
ORDER BY t.expected_return_date ASC;

-- View: Asset Health Dashboard
CREATE VIEW asset_health_dashboard AS
SELECT 
    a.asset_id,
    a.asset_name,
    a.serial_number,
    c.category_name,
    c.icon,
    l.lab_name,
    l.row_number,
    l.position_number,
    l.coordinates_x,
    l.coordinates_y,
    a.status,
    a.brand,
    a.model,
    (SELECT COUNT(*) FROM repair_logs WHERE asset_id = a.asset_id) AS total_repairs,
    (SELECT COUNT(*) FROM transactions WHERE asset_id = a.asset_id) AS total_borrows
FROM assets a
JOIN categories c ON a.category_id = c.category_id
LEFT JOIN locations l ON a.location_id = l.location_id
WHERE a.status != 'retired'
ORDER BY l.lab_name, l.row_number, l.position_number;

-- ============================================
-- STORED PROCEDURES
-- ============================================

-- Drop existing procedures if they exist
DROP PROCEDURE IF EXISTS update_overdue_transactions;
DROP PROCEDURE IF EXISTS get_asset_lifecycle;

DELIMITER //

-- Procedure: Mark overdue transactions
CREATE PROCEDURE update_overdue_transactions()
BEGIN
    UPDATE transactions 
    SET status = 'overdue'
    WHERE transaction_type = 'borrow'
      AND status = 'active'
      AND expected_return_date < CURDATE();
END //

-- Procedure: Get asset lifecycle (complete history)
CREATE PROCEDURE get_asset_lifecycle(IN p_asset_id INT)
BEGIN
    SELECT 
        'Asset Info' AS record_type,
        CONCAT(a.asset_name, ' (', a.serial_number, ')') AS description,
        a.created_at AS date,
        NULL AS details
    FROM assets a
    WHERE a.asset_id = p_asset_id
    
    UNION ALL
    
    SELECT 
        'Repair' AS record_type,
        r.issue_description AS description,
        r.log_date AS date,
        CONCAT('Action: ', COALESCE(r.action_taken, 'Pending'), ' | Cost: ₱', r.cost) AS details
    FROM repair_logs r
    WHERE r.asset_id = p_asset_id
    
    UNION ALL
    
    SELECT 
        'Transaction' AS record_type,
        CONCAT(t.transaction_type, ' - ', s.student_name) AS description,
        t.transaction_date AS date,
        CONCAT('Expected Return: ', COALESCE(t.expected_return_date, 'N/A')) AS details
    FROM transactions t
    JOIN students s ON t.student_id = s.student_id
    WHERE t.asset_id = p_asset_id
    
    ORDER BY date DESC;
END //

DELIMITER ;

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
-- Already added inline above, but here for reference:
-- INDEX on assets: status, asset_name, serial_number
-- INDEX on transactions: transaction_date, status
-- INDEX on repair_logs: asset_id, log_date
-- INDEX on students: student_name, student_number
