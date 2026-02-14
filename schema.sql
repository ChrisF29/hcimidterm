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
('Power Supply', '⚡');

-- Insert Locations (Lab A: 3 Rows x 5 Positions)
INSERT INTO locations (lab_name, row_number, position_number, coordinates_x, coordinates_y) VALUES
-- Row 1
('Lab A', 1, 1, 100, 100),
('Lab A', 1, 2, 200, 100),
('Lab A', 1, 3, 300, 100),
('Lab A', 1, 4, 400, 100),
('Lab A', 1, 5, 500, 100),
-- Row 2
('Lab A', 2, 1, 100, 250),
('Lab A', 2, 2, 200, 250),
('Lab A', 2, 3, 300, 250),
('Lab A', 2, 4, 400, 250),
('Lab A', 2, 5, 500, 250),
-- Row 3
('Lab A', 3, 1, 100, 400),
('Lab A', 3, 2, 200, 400),
('Lab A', 3, 3, 300, 400),
('Lab A', 3, 4, 400, 400),
('Lab A', 3, 5, 500, 400);

-- Insert sample students
INSERT INTO students (student_name, student_number, email, department) VALUES
('Juan Dela Cruz', '2024-001', 'juan.delacruz@university.edu', 'Computer Science'),
('Maria Santos', '2024-002', 'maria.santos@university.edu', 'Information Technology'),
('Pedro Reyes', '2024-003', 'pedro.reyes@university.edu', 'Computer Engineering');

-- Insert sample assets
INSERT INTO assets (serial_number, asset_name, category_id, location_id, status, brand, model, mac_address, ip_address, specifications) VALUES
('SN-PC-001', 'Desktop PC #1', 1, 1, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:B7', '192.168.1.101', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-PC-002', 'Desktop PC #2', 1, 2, 'warning', 'HP', 'ProDesk 600', '00:1B:44:11:3A:B8', '192.168.1.102', 'Intel i5, 8GB RAM, 256GB SSD'),
('SN-PC-003', 'Desktop PC #3', 1, 3, 'good', 'Dell', 'Optiplex 7090', '00:1B:44:11:3A:B9', '192.168.1.103', 'Intel i7, 16GB RAM, 512GB SSD'),
('SN-MON-001', 'Monitor #1', 2, 1, 'good', 'Samsung', 'S24R350', NULL, NULL, '24-inch, 1920x1080, IPS'),
('SN-MON-002', 'Monitor #2', 2, 2, 'defective', 'LG', '24MK430H', NULL, NULL, '24-inch, 1920x1080, TN Panel'),
('SN-MOUSE-BULK', 'Logitech Mice - Bulk', 4, NULL, 'good', 'Logitech', 'M170', NULL, NULL, 'Wireless Optical Mouse');

-- Update the mouse to be consumable with quantity
UPDATE assets SET is_consumable = TRUE, quantity = 15, min_stock_threshold = 5 WHERE serial_number = 'SN-MOUSE-BULK';

-- Insert a sample transaction (borrowed item)
INSERT INTO transactions (asset_id, student_id, transaction_type, expected_return_date, status) VALUES
(1, 1, 'borrow', DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'active');

-- Insert sample repair logs
INSERT INTO repair_logs (asset_id, log_type, issue_description, action_taken, repair_status, technician_name, parts_replaced, cost) VALUES
(2, 'defect_report', 'Random reboots under load', 'Replaced thermal paste, cleaned CPU fan', 'completed', 'Tech Mike', 'Thermal Paste', 150.00),
(5, 'defect_report', 'Display flickering, no backlight', 'Backlight inverter faulty - pending replacement', 'pending', 'Tech Mike', NULL, 0.00);

-- ============================================
-- USEFUL VIEWS
-- ============================================

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
