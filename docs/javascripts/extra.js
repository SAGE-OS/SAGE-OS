// SAGE OS Documentation Custom JavaScript

document.addEventListener('DOMContentLoaded', function() {
    // Initialize custom features
    initArchitectureBadges();
    initStatusIndicators();
    initProgressBars();
    initCodeLanguageIndicators();
    initMermaidDiagrams();
    initSearchEnhancements();
    initTableEnhancements();
    initCopyCodeButtons();
});

// Architecture badge functionality
function initArchitectureBadges() {
    const badges = document.querySelectorAll('.arch-badge');
    badges.forEach(badge => {
        badge.addEventListener('click', function() {
            const arch = this.textContent.toLowerCase();
            filterContentByArchitecture(arch);
        });
    });
}

// Filter content by architecture
function filterContentByArchitecture(arch) {
    const codeBlocks = document.querySelectorAll('pre code');
    codeBlocks.forEach(block => {
        const parent = block.closest('.highlight');
        if (parent) {
            const archAttribute = parent.getAttribute('data-arch');
            if (archAttribute && archAttribute !== arch && arch !== 'all') {
                parent.style.display = 'none';
            } else {
                parent.style.display = 'block';
            }
        }
    });
}

// Status indicator animations
function initStatusIndicators() {
    const indicators = document.querySelectorAll('.status-indicator');
    indicators.forEach(indicator => {
        if (indicator.classList.contains('beta') || indicator.classList.contains('alpha')) {
            indicator.style.animation = 'pulse 2s infinite';
        }
    });
}

// Progress bar animations
function initProgressBars() {
    const progressBars = document.querySelectorAll('.progress-bar-fill');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const width = entry.target.getAttribute('data-width') || '0%';
                entry.target.style.width = width;
            }
        });
    });
    
    progressBars.forEach(bar => observer.observe(bar));
}

// Code language indicators
function initCodeLanguageIndicators() {
    const codeBlocks = document.querySelectorAll('pre code[class*="language-"]');
    codeBlocks.forEach(block => {
        const className = block.className;
        const langMatch = className.match(/language-(\w+)/);
        if (langMatch) {
            const lang = langMatch[1];
            const indicator = document.createElement('span');
            indicator.className = 'code-lang';
            indicator.textContent = lang;
            block.parentElement.style.position = 'relative';
            block.parentElement.appendChild(indicator);
        }
    });
}

// Enhanced Mermaid diagram support
function initMermaidDiagrams() {
    if (typeof mermaid !== 'undefined') {
        mermaid.initialize({
            theme: 'base',
            themeVariables: {
                primaryColor: '#1976d2',
                primaryTextColor: '#ffffff',
                primaryBorderColor: '#1565c0',
                lineColor: '#757575',
                secondaryColor: '#f5f5f5',
                tertiaryColor: '#e3f2fd'
            }
        });
        
        // Re-render diagrams when theme changes
        const themeToggle = document.querySelector('[data-md-component="palette"]');
        if (themeToggle) {
            themeToggle.addEventListener('change', () => {
                setTimeout(() => {
                    mermaid.init();
                }, 100);
            });
        }
    }
}

// Search enhancements
function initSearchEnhancements() {
    const searchInput = document.querySelector('[data-md-component="search-query"]');
    if (searchInput) {
        // Add search suggestions
        searchInput.addEventListener('input', function() {
            const query = this.value.toLowerCase();
            if (query.length > 2) {
                showSearchSuggestions(query);
            }
        });
    }
}

// Show search suggestions
function showSearchSuggestions(query) {
    const suggestions = [
        'installation', 'building', 'architecture', 'security',
        'troubleshooting', 'development', 'kernel', 'bootloader',
        'x86_64', 'arm64', 'riscv', 'cve scanning'
    ];
    
    const matches = suggestions.filter(s => s.includes(query));
    // Implementation would show suggestions in UI
}

// Table enhancements
function initTableEnhancements() {
    const tables = document.querySelectorAll('table');
    tables.forEach(table => {
        // Make tables responsive
        if (!table.parentElement.classList.contains('table-wrapper')) {
            const wrapper = document.createElement('div');
            wrapper.className = 'table-wrapper';
            wrapper.style.overflowX = 'auto';
            table.parentElement.insertBefore(wrapper, table);
            wrapper.appendChild(table);
        }
        
        // Add sorting functionality
        const headers = table.querySelectorAll('th');
        headers.forEach((header, index) => {
            header.style.cursor = 'pointer';
            header.addEventListener('click', () => sortTable(table, index));
        });
    });
}

// Table sorting functionality
function sortTable(table, column) {
    const tbody = table.querySelector('tbody');
    const rows = Array.from(tbody.querySelectorAll('tr'));
    
    const isNumeric = rows.every(row => {
        const cell = row.cells[column];
        return cell && !isNaN(parseFloat(cell.textContent));
    });
    
    rows.sort((a, b) => {
        const aVal = a.cells[column].textContent.trim();
        const bVal = b.cells[column].textContent.trim();
        
        if (isNumeric) {
            return parseFloat(aVal) - parseFloat(bVal);
        } else {
            return aVal.localeCompare(bVal);
        }
    });
    
    // Check if already sorted and reverse if needed
    const currentOrder = table.getAttribute('data-sort-order');
    if (currentOrder === 'asc') {
        rows.reverse();
        table.setAttribute('data-sort-order', 'desc');
    } else {
        table.setAttribute('data-sort-order', 'asc');
    }
    
    // Rebuild table body
    tbody.innerHTML = '';
    rows.forEach(row => tbody.appendChild(row));
}

// Copy code button functionality
function initCopyCodeButtons() {
    const codeBlocks = document.querySelectorAll('pre code');
    codeBlocks.forEach(block => {
        const button = document.createElement('button');
        button.className = 'copy-code-btn';
        button.innerHTML = '📋';
        button.title = 'Copy code';
        button.style.cssText = `
            position: absolute;
            top: 0.5em;
            right: 0.5em;
            background: var(--md-primary-fg-color);
            color: white;
            border: none;
            border-radius: 0.25em;
            padding: 0.25em 0.5em;
            cursor: pointer;
            font-size: 0.8em;
            opacity: 0.7;
            transition: opacity 0.2s;
        `;
        
        button.addEventListener('click', () => {
            navigator.clipboard.writeText(block.textContent).then(() => {
                button.innerHTML = '✅';
                setTimeout(() => {
                    button.innerHTML = '📋';
                }, 2000);
            });
        });
        
        button.addEventListener('mouseenter', () => {
            button.style.opacity = '1';
        });
        
        button.addEventListener('mouseleave', () => {
            button.style.opacity = '0.7';
        });
        
        block.parentElement.style.position = 'relative';
        block.parentElement.appendChild(button);
    });
}

// Architecture comparison functionality
function createArchComparisonTable(data) {
    const table = document.createElement('table');
    table.className = 'arch-comparison';
    
    // Create header
    const thead = document.createElement('thead');
    const headerRow = document.createElement('tr');
    headerRow.innerHTML = '<th>Feature</th><th>x86_64</th><th>ARM64</th><th>RISC-V</th>';
    thead.appendChild(headerRow);
    table.appendChild(thead);
    
    // Create body
    const tbody = document.createElement('tbody');
    data.forEach(feature => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${feature.name}</td>
            <td class="feature-${feature.x86_64}">${getFeatureIcon(feature.x86_64)}</td>
            <td class="feature-${feature.arm64}">${getFeatureIcon(feature.arm64)}</td>
            <td class="feature-${feature.riscv}">${getFeatureIcon(feature.riscv)}</td>
        `;
        tbody.appendChild(row);
    });
    table.appendChild(tbody);
    
    return table;
}

// Get feature support icon
function getFeatureIcon(status) {
    switch (status) {
        case 'supported': return '✅';
        case 'partial': return '🚧';
        case 'unsupported': return '❌';
        default: return '❓';
    }
}

// Performance monitoring
function initPerformanceMonitoring() {
    // Monitor page load performance
    window.addEventListener('load', () => {
        const perfData = performance.getEntriesByType('navigation')[0];
        console.log('Page load time:', perfData.loadEventEnd - perfData.loadEventStart, 'ms');
    });
    
    // Monitor scroll performance
    let scrollTimeout;
    window.addEventListener('scroll', () => {
        if (scrollTimeout) {
            clearTimeout(scrollTimeout);
        }
        scrollTimeout = setTimeout(() => {
            // Lazy load images or content if needed
            lazyLoadContent();
        }, 100);
    });
}

// Lazy load content
function lazyLoadContent() {
    const lazyElements = document.querySelectorAll('[data-lazy]');
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const element = entry.target;
                const src = element.getAttribute('data-lazy');
                if (src) {
                    element.src = src;
                    element.removeAttribute('data-lazy');
                    observer.unobserve(element);
                }
            }
        });
    });
    
    lazyElements.forEach(el => observer.observe(el));
}

// Theme detection and adaptation
function adaptToTheme() {
    const isDark = document.body.getAttribute('data-md-color-scheme') === 'slate';
    
    // Adapt Mermaid diagrams
    if (typeof mermaid !== 'undefined') {
        const theme = isDark ? 'dark' : 'base';
        mermaid.initialize({ theme });
    }
    
    // Adapt other components as needed
    const customElements = document.querySelectorAll('.custom-theme-element');
    customElements.forEach(el => {
        if (isDark) {
            el.classList.add('dark-theme');
        } else {
            el.classList.remove('dark-theme');
        }
    });
}

// Initialize theme adaptation
document.addEventListener('DOMContentLoaded', adaptToTheme);

// Listen for theme changes
const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
        if (mutation.type === 'attributes' && mutation.attributeName === 'data-md-color-scheme') {
            adaptToTheme();
        }
    });
});

observer.observe(document.body, {
    attributes: true,
    attributeFilter: ['data-md-color-scheme']
});

// Keyboard shortcuts
document.addEventListener('keydown', (e) => {
    // Ctrl/Cmd + K for search
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        const searchInput = document.querySelector('[data-md-component="search-query"]');
        if (searchInput) {
            searchInput.focus();
        }
    }
    
    // Escape to close search
    if (e.key === 'Escape') {
        const searchInput = document.querySelector('[data-md-component="search-query"]');
        if (searchInput && document.activeElement === searchInput) {
            searchInput.blur();
        }
    }
});

// Analytics and user behavior tracking (privacy-respecting)
function initAnalytics() {
    // Track page views
    const pageView = {
        page: window.location.pathname,
        timestamp: new Date().toISOString(),
        userAgent: navigator.userAgent,
        referrer: document.referrer
    };
    
    // Only log to console in development
    if (window.location.hostname === 'localhost') {
        console.log('Page view:', pageView);
    }
}

// Initialize analytics
initAnalytics();

// Export functions for external use
window.SAGEDocs = {
    filterContentByArchitecture,
    createArchComparisonTable,
    adaptToTheme,
    initPerformanceMonitoring
};