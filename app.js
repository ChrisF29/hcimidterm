// ============================================
// IT Equipment Inventory System - JavaScript
// Tablet-Optimized Functionality
// ============================================

// ============================================
// Global State Management
// ============================================
const AppState = {
    assets: [],
    categories: [],
    locations: [],
    students: [],
    transactions: [],
    repairLogs: [],
    selectedAsset: null,
    selectedAssets: [], // For batch operations
    isBatchMode: false,
    currentFilter: 'all',
    searchQuery: '',
    currentLab: 'Room 209' // Current laboratory view
};

// API Base URL (adjust for your environment)
const API_BASE_URL = 'api.php';

// ============================================
// Initialization
// ============================================
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 IT Equipment Inventory System Loading...');
    
    initializeApp();
    attachEventListeners();
    loadInitialData();
});

function initializeApp() {
    // Check for localStorage support
    if (!hasLocalStorage()) {
        console.warn('LocalStorage not available. Using in-memory storage.');
    }
    
    // Check for overdue items periodically
    setInterval(checkOverdueItems, 60000); // Every minute
}

function attachEventListeners() {
    // Search functionality
    const searchInput = document.getElementById('universalSearch');
    searchInput?.addEventListener('input', handleSearch);
    
    document.getElementById('btnClearSearch')?.addEventListener('click', clearSearch);
    
    // Filter chips
    document.querySelectorAll('.filter-chip').forEach(chip => {
        chip.addEventListener('click', handleFilterClick);
    });
    
    // Batch mode toggle
    document.getElementById('btnBatchMode')?.addEventListener('click', toggleBatchMode);
    
    // Quick action buttons
    document.getElementById('btnAddNewItem')?.addEventListener('click', openAddItemModal);
    document.getElementById('btnViewLowStock')?.addEventListener('click', showLowStockModal);
    document.getElementById('btnViewOverdue')?.addEventListener('click', showOverdueModal);
    document.getElementById('btnRefresh')?.addEventListener('click', refreshDashboard);
    
    // Tab switching (form tabs)
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', handleTabSwitch);
    });
    
    // Lab switching (floor plan labs) - handled by onclick in HTML
    
    // Form submission
    document.getElementById('itemForm')?.addEventListener('submit', handleFormSubmit);
}

// ============================================
// Data Loading Functions
// ============================================
async function loadInitialData() {
    showLoading(true);
    
    try {
        // In a real app, these would be API calls
        // For demo purposes, using mock data
        
        await Promise.all([
            loadCategories(),
            loadLocations(),
            loadAssets(),
            loadStudents(),
            loadTransactions(),
            loadRepairLogs()
        ]);
        
        renderFloorPlan();
        updateAlertBanner();
        populateFormDropdowns();
        
        console.log('✅ Data loaded successfully');
        console.log('📊 Assets:', AppState.assets.length);
        console.log('📍 Locations:', AppState.locations.length);
        console.log('🏢 Current Lab:', AppState.currentLab);
    } catch (error) {
        console.error('❌ Error loading data:', error);
        showAlert('Error loading data: ' + error.message, 'error');
    } finally {
        showLoading(false);
    }
}

// API data loading functions
async function loadCategories() {
    try {
        const response = await fetch(`${API_BASE_URL}?action=getCategories`);
        const data = await response.json();
        if (data.categories) {
            AppState.categories = data.categories.map(cat => ({
                id: parseInt(cat.id),
                name: cat.name,
                icon: cat.icon
            }));
        }
        console.log('📦 Categories loaded:', AppState.categories.length);
    } catch (error) {
        console.error('Error loading categories:', error);
        throw error;
    }
}

async function loadLocations() {
    try {
        const response = await fetch(`${API_BASE_URL}?action=getLocations`);
        const data = await response.json();
        if (data.locations) {
            AppState.locations = data.locations.map(loc => ({
                id: parseInt(loc.id),
                lab: loc.lab,
                row: parseInt(loc.row),
                position: parseInt(loc.position)
            }));
        }
        console.log('📍 Locations loaded:', AppState.locations.length);
    } catch (error) {
        console.error('Error loading locations:', error);
        throw error;
    }
}

async function loadAssets() {
    try {
        const response = await fetch(`${API_BASE_URL}?action=getAssets`);
        const data = await response.json();
        if (data.assets) {
            AppState.assets = data.assets.map(asset => ({
                id: parseInt(asset.id),
                serialNumber: asset.serialNumber,
                name: asset.name,
                categoryId: parseInt(asset.categoryId),
                locationId: asset.locationId ? parseInt(asset.locationId) : null,
                status: asset.status,
                brand: asset.brand,
                model: asset.model,
                mac: asset.mac,
                ip: asset.ip,
                specs: asset.specs,
                isConsumable: asset.isConsumable,
                quantity: parseInt(asset.quantity) || 1,
                minStock: parseInt(asset.minStock) || 5
            }));
        }
        console.log('🖥️ Assets loaded:', AppState.assets.length);
    } catch (error) {
        console.error('Error loading assets:', error);
        throw error;
    }
}

async function loadStudents() {
    try {
        const response = await fetch(`${API_BASE_URL}?action=getStudents`);
        const data = await response.json();
        if (data.students) {
            AppState.students = data.students.map(student => ({
                id: parseInt(student.id),
                name: student.name,
                number: student.number,
                email: student.email,
                department: student.department
            }));
        }
        console.log('👨‍🎓 Students loaded:', AppState.students.length);
    } catch (error) {
        console.error('Error loading students:', error);
        throw error;
    }
}

async function loadTransactions() {
    try {
        const response = await fetch(`${API_BASE_URL}?action=getTransactions`);
        const data = await response.json();
        if (data.transactions) {
            AppState.transactions = data.transactions.map(trans => ({
                id: parseInt(trans.id),
                assetId: parseInt(trans.assetId),
                studentId: parseInt(trans.studentId),
                type: trans.type,
                date: trans.date,
                expectedReturn: trans.expectedReturn,
                actualReturn: trans.actualReturn,
                status: trans.status
            }));
        }
        console.log('📋 Transactions loaded:', AppState.transactions.length);
    } catch (error) {
        console.error('Error loading transactions:', error);
        throw error;
    }
}

async function loadRepairLogs() {
    try {
        const response = await fetch(`${API_BASE_URL}?action=getRepairLogs`);
        const data = await response.json();
        if (data.repairLogs) {
            AppState.repairLogs = data.repairLogs.map(log => ({
                id: parseInt(log.id),
                assetId: parseInt(log.assetId),
                type: log.type,
                description: log.description,
                action: log.action,
                date: log.date,
                status: log.status,
                cost: log.cost,
                technician: log.technician
            }));
        }
        console.log('🔧 Repair logs loaded:', AppState.repairLogs.length);
    } catch (error) {
        console.error('Error loading repair logs:', error);
        throw error;
    }
}

// ============================================
// Floor Plan Rendering
// ============================================
function renderFloorPlan() {
    try {
        const gridContainer = document.getElementById('floorPlanGrid');
        if (!gridContainer) {
            console.warn('Floor plan grid container not found');
            return;
        }
        
        gridContainer.innerHTML = '';
        
        // Determine number of rows based on current lab (5 rows, 8 PCs per row, 2 columns of 4)
        const maxRows = 5;
        const positionsPerColumn = 4;
        
        // Create rows dynamically
        for (let rowNum = 1; rowNum <= maxRows; rowNum++) {
            const rowDiv = document.createElement('div');
            rowDiv.className = 'floor-row';
            rowDiv.dataset.row = rowNum;
            
            // Row label
            const rowLabel = document.createElement('div');
            rowLabel.className = 'row-label';
            rowLabel.textContent = `Row ${rowNum}`;
            rowDiv.appendChild(rowLabel);
            
            // Row items container
            const rowItems = document.createElement('div');
            rowItems.className = 'row-items';
            rowItems.id = `${AppState.currentLab.replace(' ', '')}-row${rowNum}`;
            
            // Get assets for this row in current lab
            const rowAssets = AppState.assets.filter(asset => {
                const location = AppState.locations.find(loc => loc.id === asset.locationId);
                return location && location.lab === AppState.currentLab && location.row === rowNum;
            });
            
            // Sort by position
            rowAssets.sort((a, b) => {
                const locA = AppState.locations.find(loc => loc.id === a.locationId);
                const locB = AppState.locations.find(loc => loc.id === b.locationId);
                return (locA?.position || 0) - (locB?.position || 0);
            });
            
            // Add assets to row with aisle separator between columns
            rowAssets.forEach((asset, index) => {
                // Insert aisle separator between column 1 (positions 1-4) and column 2 (positions 5-8)
                if (index === positionsPerColumn) {
                    const aisle = document.createElement('div');
                    aisle.className = 'row-aisle';
                    rowItems.appendChild(aisle);
                }
                rowItems.appendChild(createFloorItem(asset));
            });
            
            rowDiv.appendChild(rowItems);
            gridContainer.appendChild(rowDiv);
        }
        
        // Update lab counts
        updateLabCounts();
    } catch (error) {
        console.error('Error rendering floor plan:', error);
        throw error;
    }
}

// ============================================
// Lab Switching Functions
// ============================================

function switchLab(labName) {
    AppState.currentLab = labName;
    
    // Update tab active states
    const tabs = document.querySelectorAll('.lab-tab');
    tabs.forEach(tab => {
        if (tab.textContent.includes(labName)) {
            tab.classList.add('active');
        } else {
            tab.classList.remove('active');
        }
    });
    
    // Update current lab display
    const currentLabName = document.getElementById('currentLabName');
    if (currentLabName) {
        currentLabName.textContent = labName;
    }
    
    // Re-render floor plan for new lab
    renderFloorPlan();
}

function updateLabCounts() {
    // Count assets in each lab
    let count209 = 0;
    let count210 = 0;
    
    AppState.assets.forEach(asset => {
        const location = AppState.locations.find(loc => loc.id === asset.locationId);
        if (location) {
            if (location.lab === 'Room 209') {
                count209++;
            } else if (location.lab === 'Room 210') {
                count210++;
            }
        }
    });
    
    // Update count displays
    const count209Element = document.getElementById('count209');
    const count210Element = document.getElementById('count210');
    
    if (count209Element) {
        count209Element.textContent = `${count209} items`;
    }
    if (count210Element) {
        count210Element.textContent = `${count210} items`;
    }
}

// ============================================
// Floor Item Creation
// ============================================

function createFloorItem(asset) {
    const div = document.createElement('div');
    div.className = `floor-item status-${asset.status}`;
    div.dataset.assetId = asset.id;
    
    // Check if overdue
    if (asset.status === 'borrowed') {
        const transaction = AppState.transactions.find(t => 
            t.assetId === asset.id && t.status === 'active'
        );
        if (transaction && isOverdue(transaction.expectedReturn)) {
            div.classList.add('overdue');
        }
    }
    
    // Apply filter
    if (!shouldShowAsset(asset)) {
        div.style.display = 'none';
    }
    
    // Selection checkbox (for batch mode)
    const checkbox = document.createElement('div');
    checkbox.className = 'selection-checkbox';
    div.appendChild(checkbox);
    
    // Icon
    const category = AppState.categories.find(c => c.id === asset.categoryId);
    const icon = document.createElement('div');
    icon.className = 'item-icon';
    icon.textContent = category?.icon || '📦';
    div.appendChild(icon);
    
    // Label
    const label = document.createElement('div');
    label.className = 'item-label';
    label.textContent = asset.name;
    div.appendChild(label);
    
    // Event listener
    div.addEventListener('click', (e) => {
        if (AppState.isBatchMode) {
            toggleItemSelection(asset.id);
        } else {
            showItemDetails(asset.id);
        }
    });
    
    // Check if selected
    if (AppState.selectedAssets.includes(asset.id)) {
        div.classList.add('selected');
    }
    
    // Add batch mode class if active
    if (AppState.isBatchMode) {
        div.classList.add('batch-mode');
    }
    
    return div;
}

function shouldShowAsset(asset) {
    // Filter by status
    if (AppState.currentFilter !== 'all' && asset.status !== AppState.currentFilter) {
        return false;
    }
    
    // Filter by search
    if (AppState.searchQuery) {
        const query = AppState.searchQuery.toLowerCase();
        
        // Search in asset name
        if (asset.name.toLowerCase().includes(query)) {
            return true;
        }
        
        // Search in serial number
        if (asset.serialNumber.toLowerCase().includes(query)) {
            return true;
        }
        
        // Search in borrower name (if borrowed)
        if (asset.status === 'borrowed') {
            const transaction = AppState.transactions.find(t => 
                t.assetId === asset.id && t.status === 'active'
            );
            if (transaction) {
                const student = AppState.students.find(s => s.id === transaction.studentId);
                if (student && student.name.toLowerCase().includes(query)) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    return true;
}

// ============================================
// Universal Search
// ============================================
function handleSearch(e) {
    const query = e.target.value.trim();
    AppState.searchQuery = query;
    
    // Show/hide clear button
    const btnClear = document.getElementById('btnClearSearch');
    if (btnClear) {
        btnClear.style.display = query ? 'block' : 'none';
    }
    
    // Re-render floor plan with filter
    renderFloorPlan();
    
    // Highlight search results
    if (query) {
        console.log(`🔍 Searching for: ${query}`);
    }
}

function clearSearch() {
    const searchInput = document.getElementById('universalSearch');
    if (searchInput) {
        searchInput.value = '';
        searchInput.dispatchEvent(new Event('input'));
        searchInput.focus();
    }
}

// ============================================
// Filter Management
// ============================================
function handleFilterClick(e) {
    const chip = e.currentTarget;
    const filter = chip.dataset.filter;
    
    // Update active state
    document.querySelectorAll('.filter-chip').forEach(c => c.classList.remove('active'));
    chip.classList.add('active');
    
    // Update state
    AppState.currentFilter = filter;
    
    // Re-render
    renderFloorPlan();
    
    console.log(`🎯 Filter changed to: ${filter}`);
}

// ============================================
// Batch Mode & Selection
// ============================================
function toggleBatchMode() {
    AppState.isBatchMode = !AppState.isBatchMode;
    
    const btn = document.getElementById('btnBatchMode');
    const panel = document.getElementById('batchActionsPanel');
    
    if (AppState.isBatchMode) {
        btn.textContent = '✖ Exit Batch Mode';
        btn.classList.add('active');
        if (panel) panel.style.display = 'block';
        
        // Add batch-mode class to all items
        document.querySelectorAll('.floor-item').forEach(item => {
            item.classList.add('batch-mode');
        });
    } else {
        btn.textContent = '☑️ Batch Select';
        btn.classList.remove('active');
        if (panel) panel.style.display = 'none';
        
        // Clear selection
        clearSelection();
        
        // Remove batch-mode class
        document.querySelectorAll('.floor-item').forEach(item => {
            item.classList.remove('batch-mode');
        });
    }
}

function toggleItemSelection(assetId) {
    const index = AppState.selectedAssets.indexOf(assetId);
    
    if (index > -1) {
        AppState.selectedAssets.splice(index, 1);
    } else {
        AppState.selectedAssets.push(assetId);
    }
    
    updateBatchUI();
}

function updateBatchUI() {
    // Update item visual states
    document.querySelectorAll('.floor-item').forEach(item => {
        const assetId = parseInt(item.dataset.assetId);
        if (AppState.selectedAssets.includes(assetId)) {
            item.classList.add('selected');
        } else {
            item.classList.remove('selected');
        }
    });
    
    // Update count
    const countEl = document.getElementById('batchSelectedCount');
    if (countEl) {
        const count = AppState.selectedAssets.length;
        countEl.textContent = `${count} item${count !== 1 ? 's' : ''} selected`;
    }
}

function selectAllVisible() {
    const visibleItems = document.querySelectorAll('.floor-item:not([style*="display: none"])');
    
    visibleItems.forEach(item => {
        const assetId = parseInt(item.dataset.assetId);
        if (!AppState.selectedAssets.includes(assetId)) {
            AppState.selectedAssets.push(assetId);
        }
    });
    
    updateBatchUI();
}

function clearSelection() {
    AppState.selectedAssets = [];
    updateBatchUI();
}

function batchUpdateStatus(newStatus) {
    if (AppState.selectedAssets.length === 0) {
        showAlert('Please select at least one item.', 'warning');
        return;
    }
    
    const count = AppState.selectedAssets.length;
    const confirmed = confirm(`Update ${count} item(s) to status: ${newStatus}?`);
    
    if (!confirmed) return;
    
    showLoading(true);
    
    // Simulate API call
    setTimeout(() => {
        AppState.selectedAssets.forEach(assetId => {
            const asset = AppState.assets.find(a => a.id === assetId);
            if (asset) {
                asset.status = newStatus;
            }
        });
        
        // Clear selection and refresh
        clearSelection();
        renderFloorPlan();
        showLoading(false);
        
        showAlert(`${count} item(s) updated successfully!`, 'success');
        console.log(`✅ Batch update: ${count} items → ${newStatus}`);
    }, 500);
}

// ============================================
// Item Details Display
// ============================================
function showItemDetails(assetId) {
    const asset = AppState.assets.find(a => a.id === assetId);
    if (!asset) return;
    
    AppState.selectedAsset = asset;
    
    const card = document.getElementById('itemDetailsCard');
    if (!card) return;
    
    // Populate details
    document.getElementById('detailItemName').textContent = asset.name;
    document.getElementById('detailSerial').textContent = asset.serialNumber;
    document.getElementById('detailCategory').textContent = 
        AppState.categories.find(c => c.id === asset.categoryId)?.name || '-';
    
    const location = AppState.locations.find(loc => loc.id === asset.locationId);
    document.getElementById('detailLocation').textContent = 
        location ? `${location.lab}, Row ${location.row}, Pos ${location.position}` : '-';
    
    document.getElementById('detailBrandModel').textContent = 
        asset.brand && asset.model ? `${asset.brand} ${asset.model}` : '-';
    document.getElementById('detailMAC').textContent = asset.mac || '-';
    document.getElementById('detailIP').textContent = asset.ip || '-';
    document.getElementById('detailSpecs').textContent = asset.specs || '-';
    
    // Status badge
    const statusBadge = document.getElementById('detailStatus');
    statusBadge.className = `status-badge status-${asset.status}`;
    statusBadge.textContent = asset.status.toUpperCase();
    
    // Show card
    card.style.display = 'block';
    
    // Hide lifecycle card if open
    const lifecycleCard = document.getElementById('lifecycleCard');
    if (lifecycleCard) lifecycleCard.style.display = 'none';
}

function closeDetails() {
    const card = document.getElementById('itemDetailsCard');
    if (card) card.style.display = 'none';
    AppState.selectedAsset = null;
}

// ============================================
// Asset Lifecycle History
// ============================================
function viewHistory() {
    if (!AppState.selectedAsset) return;
    
    const lifecycleCard = document.getElementById('lifecycleCard');
    const timeline = document.getElementById('lifecycleTimeline');
    
    if (!lifecycleCard || !timeline) return;
    
    // Clear timeline
    timeline.innerHTML = '';
    
    // Get history for this asset
    const repairs = AppState.repairLogs.filter(r => r.assetId === AppState.selectedAsset.id);
    const transactions = AppState.transactions.filter(t => t.assetId === AppState.selectedAsset.id);
    
    // Combine and sort by date
    const history = [];
    
    repairs.forEach(repair => {
        history.push({
            type: 'repair',
            date: repair.date,
            description: repair.description,
            details: repair.action
        });
    });
    
    transactions.forEach(trans => {
        const student = AppState.students.find(s => s.id === trans.studentId);
        history.push({
            type: 'transaction',
            date: trans.date,
            description: `${trans.type} - ${student?.name || 'Unknown'}`,
            details: `Expected return: ${trans.expectedReturn || 'N/A'}`
        });
    });
    
    // Sort by date (newest first)
    history.sort((a, b) => new Date(b.date) - new Date(a.date));
    
    // Render timeline
    if (history.length === 0) {
        timeline.innerHTML = '<p style="text-align: center; color: var(--text-secondary);">No history records found.</p>';
    } else {
        history.forEach(item => {
            const timelineItem = document.createElement('div');
            timelineItem.className = `timeline-item ${item.type}`;
            
            timelineItem.innerHTML = `
                <div class="timeline-type">${item.type}</div>
                <div class="timeline-description">${item.description}</div>
                <div class="timeline-date">${formatDate(item.date)}</div>
                ${item.details ? `<div class="timeline-details">${item.details}</div>` : ''}
            `;
            
            timeline.appendChild(timelineItem);
        });
    }
    
    lifecycleCard.style.display = 'block';
}

function closeLifecycle() {
    const card = document.getElementById('lifecycleCard');
    if (card) card.style.display = 'none';
}

// ============================================
// Tab Switching
// ============================================
function handleTabSwitch(e) {
    const btn = e.currentTarget;
    const tabId = btn.dataset.tab;
    
    // Update button states
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    
    // Update content visibility
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    
    const targetTab = document.getElementById(`tab-${tabId}`);
    if (targetTab) {
        targetTab.classList.add('active');
    }
}

// ============================================
// Modal Management
// ============================================
function openAddItemModal() {
    const modal = document.getElementById('modalAddItem');
    const form = document.getElementById('itemForm');
    
    if (!modal || !form) return;
    
    // Reset form
    form.reset();
    
    // Reset to first tab
    document.querySelectorAll('.tab-btn')[0]?.click();
    
    // Update title
    document.getElementById('modalTitle').textContent = '➕ Add New Item';
    
    modal.style.display = 'flex';
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.style.display = 'none';
    }
}

function showMoreActions() {
    const modal = document.getElementById('modalMoreActions');
    if (modal) {
        modal.style.display = 'flex';
    }
}

// ============================================
// Form Handling
// ============================================
function populateFormDropdowns() {
    // Populate categories
    const categorySelect = document.getElementById('inputCategory');
    if (categorySelect) {
        categorySelect.innerHTML = '<option value="">-- Select Category --</option>';
        AppState.categories.forEach(cat => {
            const option = document.createElement('option');
            option.value = cat.id;
            option.textContent = `${cat.icon} ${cat.name}`;
            categorySelect.appendChild(option);
        });
    }
    
    // Populate locations
    const locationSelect = document.getElementById('inputLocation');
    if (locationSelect) {
        locationSelect.innerHTML = '<option value="">-- Select Location --</option>';
        AppState.locations.forEach(loc => {
            const option = document.createElement('option');
            option.value = loc.id;
            option.textContent = `${loc.lab} - Row ${loc.row}, Position ${loc.position}`;
            locationSelect.appendChild(option);
        });
    }
}

function handleFormSubmit(e) {
    e.preventDefault();
    
    // Get form data
    const formData = {
        serialNumber: document.getElementById('inputSerial').value.trim(),
        name: document.getElementById('inputName').value.trim(),
        categoryId: parseInt(document.getElementById('inputCategory').value),
        status: document.getElementById('inputStatus').value,
        brand: document.getElementById('inputBrand').value.trim(),
        model: document.getElementById('inputModel').value.trim(),
        locationId: parseInt(document.getElementById('inputLocation').value) || null,
        purchaseDate: document.getElementById('inputPurchaseDate').value,
        mac: document.getElementById('inputMAC').value.trim(),
        ip: document.getElementById('inputIP').value.trim(),
        warranty: document.getElementById('inputWarranty').value,
        price: parseFloat(document.getElementById('inputPrice').value) || null,
        specs: document.getElementById('inputSpecs').value.trim(),
        isConsumable: document.getElementById('inputIsConsumable').checked,
        quantity: parseInt(document.getElementById('inputQuantity').value) || 1,
        minStock: parseInt(document.getElementById('inputMinStock').value) || 5,
        notes: document.getElementById('inputNotes').value.trim()
    };
    
    // Validate required fields
    if (!formData.serialNumber) {
        showAlert('Serial Number is required!', 'error');
        return;
    }
    
    if (!formData.name) {
        showAlert('Item Name is required!', 'error');
        return;
    }
    
    if (!formData.categoryId) {
        showAlert('Category is required!', 'error');
        return;
    }
    
    showLoading(true);
    
    // Determine if editing or creating
    const isEditing = AppState.selectedAsset && document.getElementById('modalTitle').textContent.includes('Edit');
    
    if (isEditing) {
        // UPDATE existing asset via API
        const assetId = AppState.selectedAsset.id;
        fetch(`api.php?action=updateAsset&id=${assetId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(formData)
        })
        .then(response => response.json())
        .then(data => {
            // Update the asset in local state
            const index = AppState.assets.findIndex(a => a.id === assetId);
            if (index > -1) {
                AppState.assets[index] = { ...AppState.assets[index], ...formData };
            }
            
            // Close modal
            closeModal('modalAddItem');
            
            // Refresh dashboard
            closeDetails();
            renderFloorPlan();
            showLoading(false);
            
            showAlert('Item updated successfully!', 'success');
            console.log('✅ Asset updated:', assetId);
        })
        .catch(error => {
            console.error('Error updating asset:', error);
            showLoading(false);
            showAlert('Error updating item. Please try again.', 'error');
        });
    } else {
        // CREATE new asset via API
        fetch('api.php?action=createAsset', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(formData)
        })
        .then(response => response.json())
        .then(data => {
            // Add to local state with the new ID from server
            const newAsset = {
                id: data.id || (AppState.assets.length + 1),
                ...formData
            };
            AppState.assets.push(newAsset);
            
            // Close modal
            closeModal('modalAddItem');
            
            // Refresh dashboard
            renderFloorPlan();
            showLoading(false);
            
            showAlert('Item added successfully!', 'success');
            console.log('✅ New asset added:', newAsset);
        })
        .catch(error => {
            console.error('Error creating asset:', error);
            showLoading(false);
            showAlert('Error adding item. Please try again.', 'error');
        });
    }
}

// ============================================
// Low Stock & Overdue Modals
// ============================================
function showLowStockModal() {
    const modal = document.getElementById('modalLowStock');
    const tbody = document.getElementById('lowStockTableBody');
    
    if (!modal || !tbody) return;
    
    // Filter consumable items with low stock
    const lowStockItems = AppState.assets.filter(asset => 
        asset.isConsumable && asset.quantity <= asset.minStock
    );
    
    tbody.innerHTML = '';
    
    if (lowStockItems.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align: center;">No low stock items</td></tr>';
    } else {
        lowStockItems.forEach(item => {
            const category = AppState.categories.find(c => c.id === item.categoryId);
            const shortage = item.minStock - item.quantity;
            
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${item.name}</td>
                <td>${category?.name || '-'}</td>
                <td>${item.quantity}</td>
                <td>${item.minStock}</td>
                <td class="text-danger">${shortage}</td>
            `;
            tbody.appendChild(row);
        });
    }
    
    modal.style.display = 'flex';
}

function showOverdueModal() {
    const modal = document.getElementById('modalOverdue');
    const tbody = document.getElementById('overdueTableBody');
    
    if (!modal || !tbody) return;
    
    tbody.innerHTML = '';
    
    // Find overdue transactions
    const overdueTransactions = AppState.transactions.filter(t => 
        t.status === 'active' && isOverdue(t.expectedReturn)
    );
    
    if (overdueTransactions.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center;">No overdue items</td></tr>';
    } else {
        overdueTransactions.forEach(trans => {
            const asset = AppState.assets.find(a => a.id === trans.assetId);
            const student = AppState.students.find(s => s.id === trans.studentId);
            const daysOverdue = calculateDaysOverdue(trans.expectedReturn);
            
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${asset?.name || '-'}</td>
                <td>${student?.name || '-'}</td>
                <td>${formatDate(trans.date)}</td>
                <td>${formatDate(trans.expectedReturn)}</td>
                <td class="text-danger">${daysOverdue} days</td>
                <td><button class="btn-secondary" onclick="processReturn(${trans.id})">Return</button></td>
            `;
            tbody.appendChild(row);
        });
    }
    
    modal.style.display = 'flex';
}

// ============================================
// More Actions
// ============================================
function editItem() {
    if (!AppState.selectedAsset) return;
    
    // Populate form with current data
    document.getElementById('inputSerial').value = AppState.selectedAsset.serialNumber;
    document.getElementById('inputName').value = AppState.selectedAsset.name;
    document.getElementById('inputCategory').value = AppState.selectedAsset.categoryId;
    document.getElementById('inputStatus').value = AppState.selectedAsset.status;
    document.getElementById('inputBrand').value = AppState.selectedAsset.brand || '';
    document.getElementById('inputModel').value = AppState.selectedAsset.model || '';
    document.getElementById('inputLocation').value = AppState.selectedAsset.locationId || '';
    document.getElementById('inputMAC').value = AppState.selectedAsset.mac || '';
    document.getElementById('inputIP').value = AppState.selectedAsset.ip || '';
    document.getElementById('inputSpecs').value = AppState.selectedAsset.specs || '';
    
    // Update title
    document.getElementById('modalTitle').textContent = '✏️ Edit Item';
    
    // Open modal
    document.getElementById('modalAddItem').style.display = 'flex';
}

function reportDefect() {
    closeModal('modalMoreActions');
    // In a real app, open a defect reporting form
    alert('Defect reporting form would open here');
}

function recordUpgrade() {
    closeModal('modalMoreActions');
    alert('Upgrade recording form would open here');
}

function borrowItem() {
    closeModal('modalMoreActions');
    alert('Borrowing form would open here');
}

function returnItem() {
    closeModal('modalMoreActions');
    alert('Return processing form would open here');
}

function confirmDelete() {
    if (!AppState.selectedAsset) return;
    
    const confirmed = confirm(`Are you sure you want to delete "${AppState.selectedAsset.name}"?\n\nThis action cannot be undone.`);
    
    if (confirmed) {
        closeModal('modalMoreActions');
        
        // Remove asset
        const index = AppState.assets.findIndex(a => a.id === AppState.selectedAsset.id);
        if (index > -1) {
            AppState.assets.splice(index, 1);
            closeDetails();
            renderFloorPlan();
            showAlert('Item deleted successfully', 'success');
        }
    }
}

function processReturn(transactionId) {
    const confirmed = confirm('Process return for this item?');
    
    if (confirmed) {
        // Update transaction
        const trans = AppState.transactions.find(t => t.id === transactionId);
        if (trans) {
            trans.status = 'completed';
            trans.actualReturnDate = new Date().toISOString().split('T')[0];
            
            // Update asset status
            const asset = AppState.assets.find(a => a.id === trans.assetId);
            if (asset) {
                asset.status = 'good';
            }
        }
        
        closeModal('modalOverdue');
        renderFloorPlan();
        showAlert('Item returned successfully!', 'success');
    }
}

// ============================================
// Alert Banner
// ============================================
function updateAlertBanner() {
    const banner = document.getElementById('alertBanner');
    const message = document.getElementById('alertMessage');
    
    if (!banner || !message) return;
    
    // Check for overdue items
    const overdueCount = AppState.transactions.filter(t => 
        t.status === 'active' && isOverdue(t.expectedReturn)
    ).length;
    
    // Check for low stock
    const lowStockCount = AppState.assets.filter(asset => 
        asset.isConsumable && asset.quantity <= asset.minStock
    ).length;
    
    if (overdueCount > 0 || lowStockCount > 0) {
        let msg = '';
        if (overdueCount > 0) {
            msg += `⚠️ ${overdueCount} overdue return(s)`;
        }
        if (lowStockCount > 0) {
            if (msg) msg += ' | ';
            msg += `📦 ${lowStockCount} low stock alert(s)`;
        }
        
        message.textContent = msg;
        banner.style.display = 'block';
    } else {
        banner.style.display = 'none';
    }
}

function closeAlert() {
    const banner = document.getElementById('alertBanner');
    if (banner) banner.style.display = 'none';
}

// ============================================
// Utility Functions
// ============================================
function showLoading(show) {
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) {
        overlay.style.display = show ? 'flex' : 'none';
    }
}

function showAlert(message, type = 'info') {
    // Simple alert for now - could be enhanced with a toast notification
    const icon = {
        success: '✅',
        error: '❌',
        warning: '⚠️',
        info: 'ℹ️'
    }[type] || 'ℹ️';
    
    alert(`${icon} ${message}`);
}

function refreshDashboard() {
    showLoading(true);
    loadInitialData();
}

function checkOverdueItems() {
    // Mark overdue transactions
    AppState.transactions.forEach(trans => {
        if (trans.status === 'active' && isOverdue(trans.expectedReturn)) {
            trans.status = 'overdue';
        }
    });
    
    updateAlertBanner();
}

function isOverdue(expectedReturn) {
    if (!expectedReturn) return false;
    const returnDate = new Date(expectedReturn);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return returnDate < today;
}

function calculateDaysOverdue(expectedReturn) {
    const returnDate = new Date(expectedReturn);
    const today = new Date();
    const diffTime = today - returnDate;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return Math.max(0, diffDays);
}

function formatDate(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric' 
    });
}

function hasLocalStorage() {
    try {
        const test = '__test__';
        localStorage.setItem(test, test);
        localStorage.removeItem(test);
        return true;
    } catch (e) {
        return false;
    }
}

// ============================================
// API Communication (for future implementation)
// ============================================
async function apiCall(endpoint, method = 'GET', data = null) {
    const options = {
        method: method,
        headers: {
            'Content-Type': 'application/json'
        }
    };
    
    if (data && method !== 'GET') {
        options.body = JSON.stringify(data);
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}?action=${endpoint}`, options);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return await response.json();
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
}

// ============================================
// Export for debugging
// ============================================
window.AppState = AppState;
window.renderFloorPlan = renderFloorPlan;

console.log('✅ IT Equipment Inventory System Loaded');
