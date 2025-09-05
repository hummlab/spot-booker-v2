/**
 * Navigation JavaScript
 * Handles mobile menu, smooth scrolling, and navigation state
 */

// Navigation controller
const Navigation = {
    /**
     * Initialize navigation functionality
     */
    init: function() {
        this.mobileMenu = document.querySelector('.hamburger');
        this.navMenu = document.querySelector('.nav-menu');
        this.navLinks = document.querySelectorAll('.nav-link');
        this.navbar = document.querySelector('.navbar');
        
        this.bindEvents();
        this.setupSmoothScrolling();
        this.setupScrollEffects();
        this.setupActiveNavigation();
    },

    /**
     * Bind navigation events
     */
    bindEvents: function() {
        // Mobile menu toggle
        if (this.mobileMenu) {
            this.mobileMenu.addEventListener('click', () => {
                this.toggleMobileMenu();
            });
        }

        // Close mobile menu when clicking outside
        document.addEventListener('click', (e) => {
            if (!this.navbar.contains(e.target) && this.isMobileMenuOpen()) {
                this.closeMobileMenu();
            }
        });

        // Close mobile menu on escape key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.isMobileMenuOpen()) {
                this.closeMobileMenu();
            }
        });

        // Handle window resize
        window.addEventListener('resize', Utils.debounce(() => {
            if (window.innerWidth >= 768 && this.isMobileMenuOpen()) {
                this.closeMobileMenu();
            }
        }, 250));
    },

    /**
     * Toggle mobile menu
     */
    toggleMobileMenu: function() {
        if (this.isMobileMenuOpen()) {
            this.closeMobileMenu();
        } else {
            this.openMobileMenu();
        }
    },

    /**
     * Open mobile menu
     */
    openMobileMenu: function() {
        this.mobileMenu.classList.add('active');
        this.navMenu.classList.add('active');
        document.body.style.overflow = 'hidden';
        
        // Focus management
        const firstNavLink = this.navMenu.querySelector('.nav-link');
        if (firstNavLink) {
            firstNavLink.focus();
        }
        
        // Track event
        Analytics.trackEvent('click', 'navigation', 'mobile_menu_open', 1);
    },

    /**
     * Close mobile menu
     */
    closeMobileMenu: function() {
        this.mobileMenu.classList.remove('active');
        this.navMenu.classList.remove('active');
        document.body.style.overflow = '';
        
        // Return focus to hamburger button
        if (this.mobileMenu) {
            this.mobileMenu.focus();
        }
        
        // Track event
        Analytics.trackEvent('click', 'navigation', 'mobile_menu_close', 1);
    },

    /**
     * Check if mobile menu is open
     * @returns {boolean} True if mobile menu is open
     */
    isMobileMenuOpen: function() {
        return this.navMenu && this.navMenu.classList.contains('active');
    },

    /**
     * Setup smooth scrolling for navigation links
     */
    setupSmoothScrolling: function() {
        this.navLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                const href = link.getAttribute('href');
                
                // Only handle internal links
                if (href && href.startsWith('#')) {
                    e.preventDefault();
                    
                    const targetId = href.substring(1);
                    const targetElement = document.getElementById(targetId);
                    
                    if (targetElement) {
                        // Close mobile menu if open
                        if (this.isMobileMenuOpen()) {
                            this.closeMobileMenu();
                        }
                        
                        // Smooth scroll to target
                        Utils.scrollTo(targetElement, 80);
                        
                        // Update URL without page reload
                        history.pushState(null, null, href);
                        
                        // Track navigation
                        Analytics.trackEvent('click', 'navigation', `scroll_to_${targetId}`, 1);
                    }
                }
            });
        });
    },

    /**
     * Setup scroll effects for navbar
     */
    setupScrollEffects: function() {
        let lastScrollTop = 0;
        const scrollThreshold = 100;
        
        const handleScroll = Utils.throttle(() => {
            const scrollTop = Utils.getScrollPosition();
            
            // Add/remove scrolled class for styling
            if (scrollTop > scrollThreshold) {
                this.navbar.classList.add('scrolled');
            } else {
                this.navbar.classList.remove('scrolled');
            }
            
            // Hide/show navbar on scroll (optional)
            if (scrollTop > lastScrollTop && scrollTop > 200) {
                // Scrolling down - hide navbar
                this.navbar.classList.add('navbar-hidden');
            } else {
                // Scrolling up - show navbar
                this.navbar.classList.remove('navbar-hidden');
            }
            
            lastScrollTop = scrollTop;
        }, 100);
        
        window.addEventListener('scroll', handleScroll);
    },

    /**
     * Setup active navigation highlighting
     */
    setupActiveNavigation: function() {
        const sections = document.querySelectorAll('section[id]');
        const navLinks = document.querySelectorAll('.nav-link[href^="#"]');
        
        const updateActiveNav = () => {
            const scrollPosition = Utils.getScrollPosition() + 100;
            
            sections.forEach(section => {
                const sectionTop = section.offsetTop;
                const sectionHeight = section.offsetHeight;
                const sectionId = section.getAttribute('id');
                
                if (scrollPosition >= sectionTop && scrollPosition < sectionTop + sectionHeight) {
                    // Remove active class from all nav links
                    navLinks.forEach(link => {
                        link.classList.remove('active');
                    });
                    
                    // Add active class to current section's nav link
                    const activeLink = document.querySelector(`.nav-link[href="#${sectionId}"]`);
                    if (activeLink) {
                        activeLink.classList.add('active');
                    }
                }
            });
        };
        
        // Update on scroll
        window.addEventListener('scroll', Utils.throttle(updateActiveNav, 100));
        
        // Initial update
        updateActiveNav();
    },

    /**
     * Handle browser back/forward buttons
     */
    setupBrowserNavigation: function() {
        window.addEventListener('popstate', () => {
            const hash = window.location.hash;
            if (hash) {
                const targetElement = document.querySelector(hash);
                if (targetElement) {
                    Utils.scrollTo(targetElement, 80);
                }
            }
        });
    },

    /**
     * Setup keyboard navigation
     */
    setupKeyboardNavigation: function() {
        // Handle tab navigation within mobile menu
        this.navMenu.addEventListener('keydown', (e) => {
            const navItems = Array.from(this.navMenu.querySelectorAll('.nav-link'));
            const currentIndex = navItems.indexOf(document.activeElement);
            
            let nextIndex;
            
            switch (e.key) {
                case 'ArrowDown':
                    e.preventDefault();
                    nextIndex = currentIndex < navItems.length - 1 ? currentIndex + 1 : 0;
                    navItems[nextIndex].focus();
                    break;
                    
                case 'ArrowUp':
                    e.preventDefault();
                    nextIndex = currentIndex > 0 ? currentIndex - 1 : navItems.length - 1;
                    navItems[nextIndex].focus();
                    break;
                    
                case 'Home':
                    e.preventDefault();
                    navItems[0].focus();
                    break;
                    
                case 'End':
                    e.preventDefault();
                    navItems[navItems.length - 1].focus();
                    break;
                    
                case 'Escape':
                    e.preventDefault();
                    this.closeMobileMenu();
                    break;
            }
        });
    },

    /**
     * Setup navigation analytics
     */
    setupAnalytics: function() {
        // Track navigation link clicks
        this.navLinks.forEach(link => {
            link.addEventListener('click', () => {
                const href = link.getAttribute('href');
                const text = link.textContent.trim();
                
                Analytics.trackEvent('click', 'navigation', `nav_link_${text.toLowerCase().replace(/\s+/g, '_')}`, 1);
            });
        });
    },

    /**
     * Get current active section
     * @returns {string|null} Active section ID
     */
    getActiveSection: function() {
        const activeLink = document.querySelector('.nav-link.active');
        if (activeLink) {
            const href = activeLink.getAttribute('href');
            return href ? href.substring(1) : null;
        }
        return null;
    },

    /**
     * Scroll to specific section
     * @param {string} sectionId - Section ID to scroll to
     */
    scrollToSection: function(sectionId) {
        const targetElement = document.getElementById(sectionId);
        if (targetElement) {
            Utils.scrollTo(targetElement, 80);
            
            // Update URL
            history.pushState(null, null, `#${sectionId}`);
            
            // Update active navigation
            this.navLinks.forEach(link => {
                link.classList.remove('active');
            });
            
            const activeLink = document.querySelector(`.nav-link[href="#${sectionId}"]`);
            if (activeLink) {
                activeLink.classList.add('active');
            }
        }
    },

    /**
     * Add scroll progress indicator
     */
    addScrollProgress: function() {
        const progressBar = document.createElement('div');
        progressBar.className = 'scroll-progress';
        progressBar.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 0%;
            height: 3px;
            background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
            z-index: 9999;
            transition: width 0.1s ease;
        `;
        
        document.body.appendChild(progressBar);
        
        const updateProgress = () => {
            const scrollTop = Utils.getScrollPosition();
            const docHeight = document.documentElement.scrollHeight - window.innerHeight;
            const scrollPercent = (scrollTop / docHeight) * 100;
            
            progressBar.style.width = `${scrollPercent}%`;
        };
        
        window.addEventListener('scroll', Utils.throttle(updateProgress, 16));
    }
};

// Initialize navigation when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    Navigation.init();
    Navigation.setupBrowserNavigation();
    Navigation.setupKeyboardNavigation();
    Navigation.setupAnalytics();
    Navigation.addScrollProgress();
});

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = Navigation;
} 