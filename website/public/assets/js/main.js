/**
 * Main JavaScript file for Rezerwacja Biurek Landing Page
 * Handles: smooth scrolling, mobile menu, FAQ accordion, lazy loading
 */

(function() {
    'use strict';

    // DOM elements
    const navToggle = document.getElementById('nav-toggle');
    const navMenu = document.getElementById('nav-menu');
    const navClose = document.getElementById('nav-close');
    const navLinks = document.querySelectorAll('.nav__link');
    const header = document.getElementById('header');
    const faqItems = document.querySelectorAll('.faq__item');

    // ===== MOBILE MENU FUNCTIONALITY =====
    function initMobileMenu() {
        // Show menu
        if (navToggle) {
            navToggle.addEventListener('click', () => {
                navMenu.classList.add('show-menu');
                document.body.style.overflow = 'hidden'; // Prevent scrolling when menu is open
            });
        }

        // Hide menu
        if (navClose) {
            navClose.addEventListener('click', () => {
                navMenu.classList.remove('show-menu');
                document.body.style.overflow = ''; // Restore scrolling
            });
        }

        // Hide menu when clicking on nav links
        navLinks.forEach(link => {
            link.addEventListener('click', () => {
                navMenu.classList.remove('show-menu');
                document.body.style.overflow = '';
            });
        });

        // Hide menu when clicking outside (on overlay)
        document.addEventListener('click', (e) => {
            const isClickInsideMenu = navMenu.contains(e.target);
            const isClickOnToggle = navToggle && navToggle.contains(e.target);
            
            if (!isClickInsideMenu && !isClickOnToggle && navMenu.classList.contains('show-menu')) {
                navMenu.classList.remove('show-menu');
                document.body.style.overflow = '';
            }
        });

        // Handle escape key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && navMenu.classList.contains('show-menu')) {
                navMenu.classList.remove('show-menu');
                document.body.style.overflow = '';
            }
        });
    }

    // ===== SMOOTH SCROLLING =====
    function initSmoothScrolling() {
        // Handle navigation links
        navLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                const href = link.getAttribute('href');
                
                // Only handle internal links (starting with #)
                if (href.startsWith('#')) {
                    e.preventDefault();
                    const targetId = href.substring(1);
                    const targetElement = document.getElementById(targetId);
                    
                    if (targetElement) {
                        const headerHeight = header.offsetHeight;
                        const targetPosition = targetElement.getBoundingClientRect().top + window.pageYOffset - headerHeight;
                        
                        window.scrollTo({
                            top: targetPosition,
                            behavior: 'smooth'
                        });
                    }
                }
            });
        });

        // Handle other smooth scroll links (like CTA buttons)
        const smoothScrollLinks = document.querySelectorAll('a[href^="#"]');
        smoothScrollLinks.forEach(link => {
            // Skip nav links (already handled above)
            if (!link.classList.contains('nav__link')) {
                link.addEventListener('click', (e) => {
                    const href = link.getAttribute('href');
                    if (href !== '#') {
                        e.preventDefault();
                        const targetId = href.substring(1);
                        const targetElement = document.getElementById(targetId);
                        
                        if (targetElement) {
                            const headerHeight = header.offsetHeight;
                            const targetPosition = targetElement.getBoundingClientRect().top + window.pageYOffset - headerHeight;
                            
                            window.scrollTo({
                                top: targetPosition,
                                behavior: 'smooth'
                            });
                        }
                    }
                });
            }
        });
    }

    // ===== FAQ ACCORDION =====
    function initFAQAccordion() {
        faqItems.forEach(item => {
            const question = item.querySelector('.faq__question');
            const answer = item.querySelector('.faq__answer');
            
            if (question && answer) {
                question.addEventListener('click', () => {
                    const isExpanded = question.getAttribute('aria-expanded') === 'true';
                    
                    // Close all other FAQ items
                    faqItems.forEach(otherItem => {
                        const otherQuestion = otherItem.querySelector('.faq__question');
                        const otherAnswer = otherItem.querySelector('.faq__answer');
                        
                        if (otherItem !== item) {
                            otherQuestion.setAttribute('aria-expanded', 'false');
                            otherAnswer.style.maxHeight = '0px';
                        }
                    });
                    
                    // Toggle current item
                    if (isExpanded) {
                        question.setAttribute('aria-expanded', 'false');
                        answer.style.maxHeight = '0px';
                    } else {
                        question.setAttribute('aria-expanded', 'true');
                        answer.style.maxHeight = answer.scrollHeight + 'px';
                    }
                });
            }
        });
    }

    // ===== HEADER SCROLL EFFECT =====
    function initHeaderScrollEffect() {
        let lastScrollY = window.scrollY;
        
        window.addEventListener('scroll', () => {
            const currentScrollY = window.scrollY;
            
            if (currentScrollY > 100) {
                header.style.backgroundColor = 'rgba(255, 255, 255, 0.95)';
                header.style.backdropFilter = 'blur(10px)';
            } else {
                header.style.backgroundColor = '';
                header.style.backdropFilter = '';
            }
            
            lastScrollY = currentScrollY;
        });
    }

    // ===== LAZY LOADING FOR IMAGES =====
    function initLazyLoading() {
        const images = document.querySelectorAll('img[loading="lazy"]');
        
        // Check if intersection observer is supported
        if ('IntersectionObserver' in window) {
            const imageObserver = new IntersectionObserver((entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        
                        // Create a new image element to handle loading
                        const newImg = new Image();
                        newImg.onload = () => {
                            img.src = newImg.src;
                            img.classList.add('loaded');
                        };
                        
                        newImg.onerror = () => {
                            img.alt = 'Nie można załadować obrazu';
                            img.classList.add('error');
                        };
                        
                        newImg.src = img.src;
                        observer.unobserve(img);
                    }
                });
            }, {
                rootMargin: '50px 0px',
                threshold: 0.01
            });
            
            images.forEach(img => {
                imageObserver.observe(img);
            });
        } else {
            // Fallback for browsers without IntersectionObserver
            images.forEach(img => {
                img.classList.add('loaded');
            });
        }
    }

    // ===== ACCESSIBILITY ENHANCEMENTS =====
    function initAccessibility() {
        // Add keyboard navigation support for custom elements
        const customButtons = document.querySelectorAll('[role="button"]');
        customButtons.forEach(button => {
            button.addEventListener('keydown', (e) => {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    button.click();
                }
            });
        });

        // Ensure proper focus management for mobile menu
        if (navMenu && navClose) {
            navMenu.addEventListener('transitionend', () => {
                if (navMenu.classList.contains('show-menu')) {
                    navClose.focus();
                }
            });
        }

        // Add focus trap for mobile menu
        if (navMenu) {
            const focusableElements = navMenu.querySelectorAll(
                'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
            );
            const firstFocusableElement = focusableElements[0];
            const lastFocusableElement = focusableElements[focusableElements.length - 1];

            navMenu.addEventListener('keydown', (e) => {
                if (e.key === 'Tab') {
                    if (e.shiftKey) {
                        if (document.activeElement === firstFocusableElement) {
                            e.preventDefault();
                            lastFocusableElement.focus();
                        }
                    } else {
                        if (document.activeElement === lastFocusableElement) {
                            e.preventDefault();
                            firstFocusableElement.focus();
                        }
                    }
                }
            });
        }
    }

    // ===== PERFORMANCE OPTIMIZATION =====
    function debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    // ===== SCROLL SPY FUNCTIONALITY =====
    function initScrollSpy() {
        const sections = document.querySelectorAll('section[id]');
        const navLinksArray = Array.from(navLinks);
        
        const scrollSpy = debounce(() => {
            const scrollPos = window.scrollY + header.offsetHeight + 50;
            
            sections.forEach(section => {
                const sectionTop = section.offsetTop;
                const sectionHeight = section.offsetHeight;
                const sectionId = section.getAttribute('id');
                
                if (scrollPos >= sectionTop && scrollPos < sectionTop + sectionHeight) {
                    navLinksArray.forEach(link => {
                        link.classList.remove('active');
                        if (link.getAttribute('href') === `#${sectionId}`) {
                            link.classList.add('active');
                        }
                    });
                }
            });
        }, 10);
        
        window.addEventListener('scroll', scrollSpy);
    }

    // ===== FORM VALIDATION (if contact form exists) =====
    function initFormValidation() {
        const forms = document.querySelectorAll('form');
        
        forms.forEach(form => {
            form.addEventListener('submit', (e) => {
                const inputs = form.querySelectorAll('input[required], textarea[required]');
                let isValid = true;
                
                inputs.forEach(input => {
                    if (!input.value.trim()) {
                        isValid = false;
                        input.classList.add('error');
                        
                        // Remove error class when user starts typing
                        input.addEventListener('input', () => {
                            input.classList.remove('error');
                        }, { once: true });
                    }
                });
                
                if (!isValid) {
                    e.preventDefault();
                }
            });
        });
    }

    // ===== INITIALIZATION =====
    function init() {
        // Wait for DOM to be fully loaded
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', init);
            return;
        }
        
        try {
            initMobileMenu();
            initSmoothScrolling();
            initFAQAccordion();
            initHeaderScrollEffect();
            initLazyLoading();
            initAccessibility();
            initScrollSpy();
            initFormValidation();
            
            // Add loaded class to body for CSS animations
            document.body.classList.add('loaded');
            
            console.log('Rezerwacja Biurek - Landing page initialized successfully');
        } catch (error) {
            console.error('Error initializing landing page:', error);
        }
    }
    
    // Handle page load
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
    
    // Handle page visibility changes (for performance)
    document.addEventListener('visibilitychange', () => {
        if (document.hidden) {
            // Page is hidden, pause any animations or timers if needed
        } else {
            // Page is visible again
        }
    });

})();