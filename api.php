<?php
// ============================================
// IT Equipment Inventory System - API
// PHP Backend with MySQL Database
// ============================================

// Error reporting for development (disable in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Set headers for JSON response
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ============================================
// Database Configuration
// ============================================
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'it_inventory');

// ============================================
// Database Connection
// ============================================
function getDBConnection() {
    try {
        $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
        
        if ($conn->connect_error) {
            throw new Exception("Connection failed: " . $conn->connect_error);
        }
        
        $conn->set_charset("utf8mb4");
        return $conn;
    } catch (Exception $e) {
        sendError("Database connection error: " . $e->getMessage(), 500);
        exit();
    }
}

// ============================================
// Utility Functions
// ============================================
function sendResponse($data, $status = 200) {
    http_response_code($status);
    echo json_encode($data);
    exit();
}

function sendError($message, $status = 400) {
    http_response_code($status);
    echo json_encode(['error' => $message]);
    exit();
}

function validateRequired($data, $fields) {
    foreach ($fields as $field) {
        if (!isset($data[$field]) || empty(trim($data[$field]))) {
            sendError("Required field missing: $field", 400);
        }
    }
}

// ============================================
// Get Request Data
// ============================================
function getRequestData() {
    $method = $_SERVER['REQUEST_METHOD'];
    
    if ($method === 'GET') {
        return $_GET;
    } else {
        $input = file_get_contents('php://input');
        return json_decode($input, true) ?: $_POST;
    }
}

// ============================================
// Main Router
// ============================================
$action = $_GET['action'] ?? '';
$method = $_SERVER['REQUEST_METHOD'];

$conn = getDBConnection();

try {
    switch ($action) {
        // Categories
        case 'getCategories':
            getCategories($conn);
            break;
        
        // Locations
        case 'getLocations':
            getLocations($conn);
            break;
        
        // Assets
        case 'getAssets':
            getAssets($conn);
            break;
        
        case 'getAsset':
            getAsset($conn, $_GET['id'] ?? null);
            break;
        
        case 'createAsset':
            createAsset($conn, getRequestData());
            break;
        
        case 'updateAsset':
            updateAsset($conn, $_GET['id'] ?? null, getRequestData());
            break;
        
        case 'deleteAsset':
            deleteAsset($conn, $_GET['id'] ?? null);
            break;
        
        case 'batchUpdateAssets':
            batchUpdateAssets($conn, getRequestData());
            break;
        
        // Students
        case 'getStudents':
            getStudents($conn);
            break;
        
        // Transactions
        case 'getTransactions':
            getTransactions($conn);
            break;
        
        case 'borrowAsset':
            borrowAsset($conn, getRequestData());
            break;
        
        case 'returnAsset':
            returnAsset($conn, getRequestData());
            break;
        
        case 'getOverdueTransactions':
            getOverdueTransactions($conn);
            break;
        
        // Repair Logs
        case 'getRepairLogs':
            getRepairLogs($conn, $_GET['assetId'] ?? null);
            break;
        
        case 'createRepairLog':
            createRepairLog($conn, getRequestData());
            break;
        
        // Dashboard
        case 'getDashboard':
            getDashboard($conn);
            break;
        
        case 'getLowStock':
            getLowStock($conn);
            break;
        
        case 'getAssetLifecycle':
            getAssetLifecycle($conn, $_GET['assetId'] ?? null);
            break;
        
        case 'search':
            universalSearch($conn, $_GET['query'] ?? '');
            break;
        
        default:
            sendError("Unknown action: $action", 404);
    }
} catch (Exception $e) {
    sendError("Error: " . $e->getMessage(), 500);
} finally {
    $conn->close();
}

// ============================================
// API Functions - Categories
// ============================================
function getCategories($conn) {
    $sql = "SELECT category_id as id, category_name as name, icon FROM categories ORDER BY category_name";
    $result = $conn->query($sql);
    
    $categories = [];
    while ($row = $result->fetch_assoc()) {
        $categories[] = $row;
    }
    
    sendResponse(['categories' => $categories]);
}

// ============================================
// API Functions - Locations
// ============================================
function getLocations($conn) {
    $sql = "SELECT location_id as id, lab_name as lab, row_number as row, 
            position_number as position, coordinates_x as x, coordinates_y as y 
            FROM locations WHERE is_active = TRUE ORDER BY lab_name, row_number, position_number";
    $result = $conn->query($sql);
    
    $locations = [];
    while ($row = $result->fetch_assoc()) {
        $row['row'] = (int)$row['row'];
        $row['position'] = (int)$row['position'];
        $row['x'] = (int)$row['x'];
        $row['y'] = (int)$row['y'];
        $locations[] = $row;
    }
    
    sendResponse(['locations' => $locations]);
}

// ============================================
// API Functions - Assets
// ============================================
function getAssets($conn) {
    $sql = "SELECT 
                a.asset_id as id,
                a.serial_number as serialNumber,
                a.asset_name as name,
                a.category_id as categoryId,
                a.location_id as locationId,
                a.status,
                a.brand,
                a.model,
                a.mac_address as mac,
                a.ip_address as ip,
                a.specifications as specs,
                a.is_consumable as isConsumable,
                a.quantity,
                a.min_stock_threshold as minStock,
                a.notes,
                c.category_name as categoryName,
                c.icon as categoryIcon
            FROM assets a
            LEFT JOIN categories c ON a.category_id = c.category_id
            WHERE a.status != 'retired'
            ORDER BY a.asset_id";
    
    $result = $conn->query($sql);
    
    $assets = [];
    while ($row = $result->fetch_assoc()) {
        $row['id'] = (int)$row['id'];
        $row['categoryId'] = (int)$row['categoryId'];
        $row['locationId'] = $row['locationId'] ? (int)$row['locationId'] : null;
        $row['isConsumable'] = (bool)$row['isConsumable'];
        $row['quantity'] = (int)$row['quantity'];
        $row['minStock'] = (int)$row['minStock'];
        $assets[] = $row;
    }
    
    sendResponse(['assets' => $assets]);
}

function getAsset($conn, $id) {
    if (!$id) {
        sendError("Asset ID is required", 400);
    }
    
    $stmt = $conn->prepare("SELECT 
                a.*,
                c.category_name as categoryName,
                c.icon as categoryIcon,
                l.lab_name as lab,
                l.row_number as row,
                l.position_number as position
            FROM assets a
            LEFT JOIN categories c ON a.category_id = c.category_id
            LEFT JOIN locations l ON a.location_id = l.location_id
            WHERE a.asset_id = ?");
    
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendError("Asset not found", 404);
    }
    
    $asset = $result->fetch_assoc();
    sendResponse(['asset' => $asset]);
}

function createAsset($conn, $data) {
    validateRequired($data, ['serialNumber', 'name', 'categoryId', 'status']);
    
    $stmt = $conn->prepare("INSERT INTO assets 
        (serial_number, asset_name, category_id, location_id, status, brand, model, 
         mac_address, ip_address, specifications, is_consumable, quantity, 
         min_stock_threshold, notes, purchase_date, warranty_expiry, purchase_price)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    
    $locationId = $data['locationId'] ?? null;
    $isConsumable = isset($data['isConsumable']) ? (int)$data['isConsumable'] : 0;
    $quantity = $data['quantity'] ?? 1;
    $minStock = $data['minStock'] ?? 5;
    $purchaseDate = $data['purchaseDate'] ?? null;
    $warranty = $data['warranty'] ?? null;
    $price = $data['price'] ?? null;
    
    $stmt->bind_param("ssiissssssiiisssd",
        $data['serialNumber'],
        $data['name'],
        $data['categoryId'],
        $locationId,
        $data['status'],
        $data['brand'] ?? null,
        $data['model'] ?? null,
        $data['mac'] ?? null,
        $data['ip'] ?? null,
        $data['specs'] ?? null,
        $isConsumable,
        $quantity,
        $minStock,
        $data['notes'] ?? null,
        $purchaseDate,
        $warranty,
        $price
    );
    
    if ($stmt->execute()) {
        $newId = $conn->insert_id;
        sendResponse(['success' => true, 'id' => $newId, 'message' => 'Asset created successfully'], 201);
    } else {
        sendError("Error creating asset: " . $stmt->error, 500);
    }
}

function updateAsset($conn, $id, $data) {
    if (!$id) {
        sendError("Asset ID is required", 400);
    }
    
    // Build dynamic update query
    $fields = [];
    $types = "";
    $values = [];
    
    $fieldMap = [
        'serialNumber' => 'serial_number',
        'name' => 'asset_name',
        'categoryId' => 'category_id',
        'locationId' => 'location_id',
        'status' => 'status',
        'brand' => 'brand',
        'model' => 'model',
        'mac' => 'mac_address',
        'ip' => 'ip_address',
        'specs' => 'specifications',
        'isConsumable' => 'is_consumable',
        'quantity' => 'quantity',
        'minStock' => 'min_stock_threshold',
        'notes' => 'notes'
    ];
    
    foreach ($fieldMap as $key => $dbField) {
        if (isset($data[$key])) {
            $fields[] = "$dbField = ?";
            
            if (in_array($key, ['categoryId', 'locationId', 'quantity', 'minStock'])) {
                $types .= "i";
                $values[] = (int)$data[$key];
            } elseif ($key === 'isConsumable') {
                $types .= "i";
                $values[] = (int)$data[$key];
            } else {
                $types .= "s";
                $values[] = $data[$key];
            }
        }
    }
    
    if (empty($fields)) {
        sendError("No fields to update", 400);
    }
    
    $sql = "UPDATE assets SET " . implode(", ", $fields) . " WHERE asset_id = ?";
    $types .= "i";
    $values[] = $id;
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param($types, ...$values);
    
    if ($stmt->execute()) {
        sendResponse(['success' => true, 'message' => 'Asset updated successfully']);
    } else {
        sendError("Error updating asset: " . $stmt->error, 500);
    }
}

function deleteAsset($conn, $id) {
    if (!$id) {
        sendError("Asset ID is required", 400);
    }
    
    // Soft delete by setting status to 'retired'
    $stmt = $conn->prepare("UPDATE assets SET status = 'retired' WHERE asset_id = ?");
    $stmt->bind_param("i", $id);
    
    if ($stmt->execute()) {
        sendResponse(['success' => true, 'message' => 'Asset deleted successfully']);
    } else {
        sendError("Error deleting asset: " . $stmt->error, 500);
    }
}

function batchUpdateAssets($conn, $data) {
    if (!isset($data['assetIds']) || !isset($data['status'])) {
        sendError("Asset IDs and status are required", 400);
    }
    
    $ids = $data['assetIds'];
    $status = $data['status'];
    
    if (empty($ids)) {
        sendError("No assets selected", 400);
    }
    
    $placeholders = implode(',', array_fill(0, count($ids), '?'));
    $sql = "UPDATE assets SET status = ? WHERE asset_id IN ($placeholders)";
    
    $stmt = $conn->prepare($sql);
    
    $types = str_repeat('i', count($ids));
    $types = 's' . $types;
    
    $params = array_merge([$status], $ids);
    $stmt->bind_param($types, ...$params);
    
    if ($stmt->execute()) {
        sendResponse(['success' => true, 'updated' => $stmt->affected_rows, 'message' => 'Assets updated successfully']);
    } else {
        sendError("Error updating assets: " . $stmt->error, 500);
    }
}

// ============================================
// API Functions - Students
// ============================================
function getStudents($conn) {
    $sql = "SELECT student_id as id, student_name as name, student_number as number, 
            email, phone, department 
            FROM students WHERE is_active = TRUE ORDER BY student_name";
    
    $result = $conn->query($sql);
    
    $students = [];
    while ($row = $result->fetch_assoc()) {
        $row['id'] = (int)$row['id'];
        $students[] = $row;
    }
    
    sendResponse(['students' => $students]);
}

// ============================================
// API Functions - Transactions
// ============================================
function getTransactions($conn) {
    $sql = "SELECT 
                t.transaction_id as id,
                t.asset_id as assetId,
                t.student_id as studentId,
                t.transaction_type as type,
                t.transaction_date as date,
                t.expected_return_date as expectedReturn,
                t.actual_return_date as actualReturn,
                t.status,
                a.asset_name as assetName,
                s.student_name as studentName
            FROM transactions t
            LEFT JOIN assets a ON t.asset_id = a.asset_id
            LEFT JOIN students s ON t.student_id = s.student_id
            ORDER BY t.transaction_date DESC";
    
    $result = $conn->query($sql);
    
    $transactions = [];
    while ($row = $result->fetch_assoc()) {
        $row['id'] = (int)$row['id'];
        $row['assetId'] = (int)$row['assetId'];
        $row['studentId'] = (int)$row['studentId'];
        $transactions[] = $row;
    }
    
    sendResponse(['transactions' => $transactions]);
}

function borrowAsset($conn, $data) {
    validateRequired($data, ['assetId', 'studentId', 'expectedReturn']);
    
    $conn->begin_transaction();
    
    try {
        // Create transaction record
        $stmt = $conn->prepare("INSERT INTO transactions 
            (asset_id, student_id, transaction_type, expected_return_date, status)
            VALUES (?, ?, 'borrow', ?, 'active')");
        
        $stmt->bind_param("iis", $data['assetId'], $data['studentId'], $data['expectedReturn']);
        $stmt->execute();
        
        // Update asset status
        $stmt2 = $conn->prepare("UPDATE assets SET status = 'borrowed' WHERE asset_id = ?");
        $stmt2->bind_param("i", $data['assetId']);
        $stmt2->execute();
        
        $conn->commit();
        sendResponse(['success' => true, 'message' => 'Asset borrowed successfully']);
    } catch (Exception $e) {
        $conn->rollback();
        sendError("Error borrowing asset: " . $e->getMessage(), 500);
    }
}

function returnAsset($conn, $data) {
    validateRequired($data, ['transactionId']);
    
    $conn->begin_transaction();
    
    try {
        // Get asset ID from transaction
        $stmt = $conn->prepare("SELECT asset_id FROM transactions WHERE transaction_id = ?");
        $stmt->bind_param("i", $data['transactionId']);
        $stmt->execute();
        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $assetId = $row['asset_id'];
        
        // Update transaction
        $stmt2 = $conn->prepare("UPDATE transactions 
            SET status = 'completed', actual_return_date = CURDATE()
            WHERE transaction_id = ?");
        $stmt2->bind_param("i", $data['transactionId']);
        $stmt2->execute();
        
        // Update asset status
        $newStatus = $data['newStatus'] ?? 'good';
        $stmt3 = $conn->prepare("UPDATE assets SET status = ? WHERE asset_id = ?");
        $stmt3->bind_param("si", $newStatus, $assetId);
        $stmt3->execute();
        
        $conn->commit();
        sendResponse(['success' => true, 'message' => 'Asset returned successfully']);
    } catch (Exception $e) {
        $conn->rollback();
        sendError("Error returning asset: " . $e->getMessage(), 500);
    }
}

function getOverdueTransactions($conn) {
    $sql = "SELECT * FROM currently_borrowed WHERE computed_status = 'overdue' ORDER BY days_overdue DESC";
    $result = $conn->query($sql);
    
    $overdue = [];
    while ($row = $result->fetch_assoc()) {
        $overdue[] = $row;
    }
    
    sendResponse(['overdue' => $overdue]);
}

// ============================================
// API Functions - Repair Logs
// ============================================
function getRepairLogs($conn, $assetId = null) {
    if ($assetId) {
        $stmt = $conn->prepare("SELECT * FROM repair_logs WHERE asset_id = ? ORDER BY log_date DESC");
        $stmt->bind_param("i", $assetId);
        $stmt->execute();
        $result = $stmt->get_result();
    } else {
        $result = $conn->query("SELECT * FROM repair_logs ORDER BY log_date DESC");
    }
    
    $logs = [];
    while ($row = $result->fetch_assoc()) {
        $logs[] = $row;
    }
    
    sendResponse(['repairLogs' => $logs]);
}

function createRepairLog($conn, $data) {
    validateRequired($data, ['assetId', 'logType', 'description']);
    
    $stmt = $conn->prepare("INSERT INTO repair_logs 
        (asset_id, log_type, issue_description, action_taken, cost, parts_replaced, 
         repair_status, technician_name)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    
    $cost = $data['cost'] ?? 0.00;
    $status = $data['status'] ?? 'pending';
    
    $stmt->bind_param("isssdsss",
        $data['assetId'],
        $data['logType'],
        $data['description'],
        $data['action'] ?? null,
        $cost,
        $data['parts'] ?? null,
        $status,
        $data['technician'] ?? null
    );
    
    if ($stmt->execute()) {
        sendResponse(['success' => true, 'message' => 'Repair log created successfully'], 201);
    } else {
        sendError("Error creating repair log: " . $stmt->error, 500);
    }
}

// ============================================
// API Functions - Dashboard & Reports
// ============================================
function getDashboard($conn) {
    // Get all dashboard data in one call
    $data = [
        'assets' => [],
        'categories' => [],
        'locations' => [],
        'students' => [],
        'transactions' => [],
        'lowStock' => [],
        'overdue' => []
    ];
    
    // Assets
    $result = $conn->query("SELECT * FROM asset_health_dashboard");
    while ($row = $result->fetch_assoc()) {
        $data['assets'][] = $row;
    }
    
    // Categories
    $result = $conn->query("SELECT * FROM categories");
    while ($row = $result->fetch_assoc()) {
        $data['categories'][] = $row;
    }
    
    // Locations
    $result = $conn->query("SELECT * FROM locations WHERE is_active = TRUE");
    while ($row = $result->fetch_assoc()) {
        $data['locations'][] = $row;
    }
    
    // Students
    $result = $conn->query("SELECT * FROM students WHERE is_active = TRUE");
    while ($row = $result->fetch_assoc()) {
        $data['students'][] = $row;
    }
    
    // Transactions
    $result = $conn->query("SELECT * FROM currently_borrowed");
    while ($row = $result->fetch_assoc()) {
        $data['transactions'][] = $row;
    }
    
    // Low Stock
    $result = $conn->query("SELECT * FROM low_stock_items");
    while ($row = $result->fetch_assoc()) {
        $data['lowStock'][] = $row;
    }
    
    // Overdue
    $result = $conn->query("SELECT * FROM currently_borrowed WHERE computed_status = 'overdue'");
    while ($row = $result->fetch_assoc()) {
        $data['overdue'][] = $row;
    }
    
    sendResponse($data);
}

function getLowStock($conn) {
    $result = $conn->query("SELECT * FROM low_stock_items");
    
    $items = [];
    while ($row = $result->fetch_assoc()) {
        $items[] = $row;
    }
    
    sendResponse(['lowStock' => $items]);
}

function getAssetLifecycle($conn, $assetId) {
    if (!$assetId) {
        sendError("Asset ID is required", 400);
    }
    
    $stmt = $conn->prepare("CALL get_asset_lifecycle(?)");
    $stmt->bind_param("i", $assetId);
    $stmt->execute();
    
    $result = $stmt->get_result();
    $history = [];
    
    while ($row = $result->fetch_assoc()) {
        $history[] = $row;
    }
    
    sendResponse(['lifecycle' => $history]);
}

function universalSearch($conn, $query) {
    if (empty($query)) {
        sendError("Search query is required", 400);
    }
    
    $searchTerm = "%$query%";
    
    // Search in assets and borrowed items
    $stmt = $conn->prepare("SELECT DISTINCT
                a.asset_id as id,
                a.asset_name as name,
                a.serial_number as serialNumber,
                a.status,
                c.category_name as category,
                l.lab_name as lab,
                l.row_number as row,
                l.position_number as position,
                s.student_name as borrower
            FROM assets a
            LEFT JOIN categories c ON a.category_id = c.category_id
            LEFT JOIN locations l ON a.location_id = l.location_id
            LEFT JOIN transactions t ON a.asset_id = t.asset_id AND t.status = 'active'
            LEFT JOIN students s ON t.student_id = s.student_id
            WHERE a.asset_name LIKE ? 
               OR a.serial_number LIKE ?
               OR s.student_name LIKE ?
            ORDER BY a.asset_name");
    
    $stmt->bind_param("sss", $searchTerm, $searchTerm, $searchTerm);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $results = [];
    while ($row = $result->fetch_assoc()) {
        $results[] = $row;
    }
    
    sendResponse(['results' => $results, 'count' => count($results)]);
}

// ============================================
// Health Check
// ============================================
if ($action === '' || $action === 'ping') {
    sendResponse([
        'status' => 'ok',
        'message' => 'IT Equipment Inventory API',
        'version' => '1.0.0',
        'timestamp' => date('Y-m-d H:i:s')
    ]);
}
?>
