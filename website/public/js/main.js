/**
 * Main JavaScript file for Project Template Website
 * Handles core functionality, utilities, and initialization
 */

// Utility functions
const Utils = {
    /**
     * Debounce function to limit how often a function can be called
     * @param {Function} func - Function to debounce
     * @param {number} wait - Wait time in milliseconds
     * @returns {Function} Debounced function
     */
    debounce: function(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    },

    /**
     * Throttle function to limit function execution frequency
     * @param {Function} func - Function to throttle
     * @param {number} limit - Time limit in milliseconds
     * @returns {Function} Throttled function
     */
    throttle: function(func, limit) {
        let inThrottle;
        return function() {
            const args = arguments;
            const context = this;
            if (!inThrottle) {
                func.apply(context, args);
                inThrottle = true;
                setTimeout(() => inThrottle = false, limit);
            }
        };
    },

    /**
     * Check if element is in viewport
     * @param {Element} element - Element to check
     * @returns {boolean} True if element is in viewport
     */
    isInViewport: function(element) {
        const rect = element.getBoundingClientRect();
        return (
            rect.top >= 0 &&
            rect.left >= 0 &&
            rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
            rect.right <= (window.innerWidth || document.documentElement.clientWidth)
        );
    },

    /**
     * Check if element is partially in viewport
     * @param {Element} element - Element to check
     * @param {number} threshold - Threshold percentage (0-1)
     * @returns {boolean} True if element is partially in viewport
     */
    isPartiallyInViewport: function(element, threshold = 0.1) {
        const rect = element.getBoundingClientRect();
        const windowHeight = window.innerHeight || document.documentElement.clientHeight;
        const windowWidth = window.innerWidth || document.documentElement.clientWidth;
        
        const visibleHeight = Math.min(rect.bottom, windowHeight) - Math.max(rect.top, 0);
        const visibleWidth = Math.min(rect.right, windowWidth) - Math.max(rect.left, 0);
        
        const visibleArea = visibleHeight * visibleWidth;
        const totalArea = rect.height * rect.width;
        
        return visibleArea / totalArea >= threshold;
    },

    /**
     * Smooth scroll to element
     * @param {Element|string} target - Element or selector to scroll to
     * @param {number} offset - Offset from top
     */
    scrollTo: function(target, offset = 0) {
        const element = typeof target === 'string' ? document.querySelector(target) : target;
        if (element) {
            const elementPosition = element.getBoundingClientRect().top + window.pageYOffset;
            const offsetPosition = elementPosition - offset;
            
            window.scrollTo({
                top: offsetPosition,
                behavior: 'smooth'
            });
        }
    },

    /**
     * Get current scroll position
     * @returns {number} Scroll position
     */
    getScrollPosition: function() {
        return window.pageYOffset || document.documentElement.scrollTop;
    },

    /**
     * Format number with commas
     * @param {number} num - Number to format
     * @returns {string} Formatted number
     */
    formatNumber: function(num) {
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    },

    /**
     * Animate number counting
     * @param {Element} element - Element to animate
     * @param {number} target - Target number
     * @param {number} duration - Animation duration in milliseconds
     */
    animateNumber: function(element, target, duration = 2000) {
        const start = 0;
        const increment = target / (duration / 16);
        let current = start;
        
        const timer = setInterval(() => {
            current += increment;
            if (current >= target) {
                current = target;
                clearInterval(timer);
            }
            element.textContent = Math.floor(current);
        }, 16);
    },

    /**
     * Validate email format
     * @param {string} email - Email to validate
     * @returns {boolean} True if email is valid
     */
    validateEmail: function(email) {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    },

    /**
     * Show notification
     * @param {string} message - Message to show
     * @param {string} type - Type of notification (success, error, warning, info)
     * @param {number} duration - Duration in milliseconds
     */
    showNotification: function(message, type = 'info', duration = 5000) {
        const notification = document.createElement('div');
        notification.className = `alert alert-${type} notification`;
        notification.textContent = message;
        
        // Add styles
        notification.style.position = 'fixed';
        notification.style.top = '20px';
        notification.style.right = '20px';
        notification.style.zIndex = '9999';
        notification.style.maxWidth = '300px';
        notification.style.animation = 'slideInRight 0.3s ease-out';
        
        document.body.appendChild(notification);
        
        // Remove after duration
        setTimeout(() => {
            notification.style.animation = 'slideOutRight 0.3s ease-out';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        }, duration);
    },

    /**
     * Load image with loading state
     * @param {string} src - Image source
     * @param {Element} element - Element to replace with image
     */
    loadImage: function(src, element) {
        const img = new Image();
        img.onload = function() {
            element.src = src;
            element.classList.add('loaded');
        };
        img.onerror = function() {
            element.classList.add('error');
        };
        img.src = src;
    },

    /**
     * Get URL parameters
     * @returns {Object} URL parameters
     */
    getUrlParams: function() {
        const params = new URLSearchParams(window.location.search);
        const result = {};
        for (const [key, value] of params) {
            result[key] = value;
        }
        return result;
    },

    /**
     * Set URL parameter
     * @param {string} key - Parameter key
     * @param {string} value - Parameter value
     */
    setUrlParam: function(key, value) {
        const url = new URL(window.location);
        url.searchParams.set(key, value);
        window.history.replaceState({}, '', url);
    },

    /**
     * Remove URL parameter
     * @param {string} key - Parameter key to remove
     */
    removeUrlParam: function(key) {
        const url = new URL(window.location);
        url.searchParams.delete(key);
        window.history.replaceState({}, '', url);
    },

    /**
     * Copy text to clipboard
     * @param {string} text - Text to copy
     * @returns {Promise<boolean>} Success status
     */
    copyToClipboard: async function(text) {
        try {
            await navigator.clipboard.writeText(text);
            return true;
        } catch (err) {
            // Fallback for older browsers
            const textArea = document.createElement('textarea');
            textArea.value = text;
            document.body.appendChild(textArea);
            textArea.select();
            const success = document.execCommand('copy');
            document.body.removeChild(textArea);
            return success;
        }
    },

    /**
     * Generate random ID
     * @param {number} length - Length of ID
     * @returns {string} Random ID
     */
    generateId: function(length = 8) {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let result = '';
        for (let i = 0; i < length; i++) {
            result += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return result;
    },

    /**
     * Format date
     * @param {Date|string} date - Date to format
     * @param {string} format - Format string
     * @returns {string} Formatted date
     */
    formatDate: function(date, format = 'YYYY-MM-DD') {
        const d = new Date(date);
        const year = d.getFullYear();
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        const hours = String(d.getHours()).padStart(2, '0');
        const minutes = String(d.getMinutes()).padStart(2, '0');
        const seconds = String(d.getSeconds()).padStart(2, '0');
        
        return format
            .replace('YYYY', year)
            .replace('MM', month)
            .replace('DD', day)
            .replace('HH', hours)
            .replace('mm', minutes)
            .replace('ss', seconds);
    },

    /**
     * Calculate time ago
     * @param {Date|string} date - Date to calculate from
     * @returns {string} Time ago string
     */
    timeAgo: function(date) {
        const now = new Date();
        const past = new Date(date);
        const diff = now - past;
        
        const seconds = Math.floor(diff / 1000);
        const minutes = Math.floor(seconds / 60);
        const hours = Math.floor(minutes / 60);
        const days = Math.floor(hours / 24);
        const months = Math.floor(days / 30);
        const years = Math.floor(months / 12);
        
        if (years > 0) return `${years} year${years > 1 ? 's' : ''} ago`;
        if (months > 0) return `${months} month${months > 1 ? 's' : ''} ago`;
        if (days > 0) return `${days} day${days > 1 ? 's' : ''} ago`;
        if (hours > 0) return `${hours} hour${hours > 1 ? 's' : ''} ago`;
        if (minutes > 0) return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
        return `${seconds} second${seconds > 1 ? 's' : ''} ago`;
    }
};

// Form handling
const FormHandler = {
    /**
     * Initialize form handlers
     */
    init: function() {
        this.handleContactForm();
        this.handleNewsletterForm();
    },

    /**
     * Handle contact form submission
     */
    handleContactForm: function() {
        const form = document.querySelector('.form');
        if (!form) return;

        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formData = new FormData(form);
            const data = Object.fromEntries(formData);
            
            // Validate form
            if (!FormHandler.validateContactForm(data)) {
                return;
            }
            
            // Show loading state
            const submitBtn = form.querySelector('button[type="submit"]');
            const originalText = submitBtn.textContent;
            submitBtn.textContent = 'Sending...';
            submitBtn.disabled = true;
            
            // Simulate form submission (replace with actual API call)
            setTimeout(() => {
                Utils.showNotification('Message sent successfully!', 'success');
                form.reset();
                submitBtn.textContent = originalText;
                submitBtn.disabled = false;
            }, 2000);
        });
    },

    /**
     * Validate contact form data
     * @param {Object} data - Form data
     * @returns {boolean} Validation result
     */
    validateContactForm: function(data) {
        if (!data.name || data.name.trim().length < 2) {
            Utils.showNotification('Please enter a valid name (minimum 2 characters)', 'error');
            return false;
        }
        
        if (!data.email || !Utils.validateEmail(data.email)) {
            Utils.showNotification('Please enter a valid email address', 'error');
            return false;
        }
        
        if (!data.message || data.message.trim().length < 10) {
            Utils.showNotification('Please enter a message (minimum 10 characters)', 'error');
            return false;
        }
        
        return true;
    },

    /**
     * Handle newsletter form submission
     */
    handleNewsletterForm: function() {
        const form = document.querySelector('.newsletter-form');
        if (!form) return;

        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const email = form.querySelector('input[type="email"]').value;
            
            if (!Utils.validateEmail(email)) {
                Utils.showNotification('Please enter a valid email address', 'error');
                return;
            }
            
            // Show loading state
            const submitBtn = form.querySelector('button[type="submit"]');
            const originalText = submitBtn.textContent;
            submitBtn.textContent = 'Subscribing...';
            submitBtn.disabled = true;
            
            // Simulate subscription (replace with actual API call)
            setTimeout(() => {
                Utils.showNotification('Successfully subscribed to newsletter!', 'success');
                form.reset();
                submitBtn.textContent = originalText;
                submitBtn.disabled = false;
            }, 1500);
        });
    }
};

// Analytics tracking
const Analytics = {
    /**
     * Track page view
     * @param {string} page - Page name
     */
    trackPageView: function(page = window.location.pathname) {
        // Replace with your analytics service
        console.log('Page view:', page);
        
        // Example: Google Analytics
        if (typeof gtag !== 'undefined') {
            gtag('config', 'GA_MEASUREMENT_ID', {
                page_path: page
            });
        }
    },

    /**
     * Track event
     * @param {string} action - Action name
     * @param {string} category - Event category
     * @param {string} label - Event label
     * @param {number} value - Event value
     */
    trackEvent: function(action, category, label, value) {
        // Replace with your analytics service
        console.log('Event:', { action, category, label, value });
        
        // Example: Google Analytics
        if (typeof gtag !== 'undefined') {
            gtag('event', action, {
                event_category: category,
                event_label: label,
                value: value
            });
        }
    },

    /**
     * Track button click
     * @param {string} buttonText - Button text
     * @param {string} section - Section name
     */
    trackButtonClick: function(buttonText, section) {
        this.trackEvent('click', 'button', `${section}_${buttonText}`, 1);
    }
};

// Performance monitoring
const Performance = {
    /**
     * Initialize performance monitoring
     */
    init: function() {
        this.measurePageLoad();
        this.measureUserInteractions();
    },

    /**
     * Measure page load performance
     */
    measurePageLoad: function() {
        window.addEventListener('load', () => {
            const navigation = performance.getEntriesByType('navigation')[0];
            const loadTime = navigation.loadEventEnd - navigation.loadEventStart;
            
            console.log('Page load time:', loadTime + 'ms');
            
            // Send to analytics
            Analytics.trackEvent('timing_complete', 'page_load', 'load_time', loadTime);
        });
    },

    /**
     * Measure user interactions
     */
    measureUserInteractions: function() {
        let firstInteraction = true;
        
        const interactionEvents = ['click', 'scroll', 'keydown', 'mousemove'];
        
        interactionEvents.forEach(eventType => {
            document.addEventListener(eventType, () => {
                if (firstInteraction) {
                    const timeToFirstInteraction = performance.now();
                    console.log('Time to first interaction:', timeToFirstInteraction + 'ms');
                    
                    Analytics.trackEvent('timing_complete', 'user_interaction', 'first_interaction', timeToFirstInteraction);
                    firstInteraction = false;
                }
            }, { once: true });
        });
    }
};

// Initialize everything when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    console.log('Project Template Website initialized');
    
    // Initialize modules
    FormHandler.init();
    Performance.init();
    
    // Track page view
    Analytics.trackPageView();
    
    // Add global utility functions to window
    window.Utils = Utils;
    window.Analytics = Analytics;
    
    // Global scroll to section function
    window.scrollToSection = function(sectionId) {
        Utils.scrollTo(`#${sectionId}`, 80);
    };
    
    // Track button clicks
    document.addEventListener('click', function(e) {
        if (e.target.matches('.btn')) {
            const buttonText = e.target.textContent.trim();
            const section = e.target.closest('section')?.id || 'unknown';
            Analytics.trackButtonClick(buttonText, section);
        }
    });
});

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { Utils, FormHandler, Analytics, Performance };
} 