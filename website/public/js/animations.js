/**
 * Animations JavaScript
 * Handles scroll-triggered animations, intersection observer, and smooth transitions
 */

// Animation controller
const Animations = {
    /**
     * Initialize animations
     */
    init: function() {
        this.setupScrollAnimations();
        this.setupIntersectionObserver();
        this.setupParallaxEffects();
        this.setupTypingAnimation();
        this.setupCounterAnimations();
        this.setupProgressAnimations();
        this.setupStaggerAnimations();
        this.setupHoverEffects();
    },

    /**
     * Setup scroll-triggered animations
     */
    setupScrollAnimations: function() {
        const animatedElements = document.querySelectorAll('.animate-on-scroll');
        
        if (animatedElements.length === 0) return;
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate');
                    
                    // Add delay based on data attribute
                    const delay = entry.target.dataset.delay || 0;
                    if (delay > 0) {
                        setTimeout(() => {
                            entry.target.classList.add('animate');
                        }, delay);
                    }
                    
                    // Unobserve after animation
                    observer.unobserve(entry.target);
                }
            });
        }, {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        });
        
        animatedElements.forEach(element => {
            observer.observe(element);
        });
    },

    /**
     * Setup intersection observer for various animations
     */
    setupIntersectionObserver: function() {
        // Fade in animations
        const fadeElements = document.querySelectorAll('.fade-in, .fade-in-up, .fade-in-down, .fade-in-left, .fade-in-right');
        
        const fadeObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0) translateX(0)';
                }
            });
        }, {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        });
        
        fadeElements.forEach(element => {
            // Set initial state
            element.style.opacity = '0';
            element.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            
            if (element.classList.contains('fade-in-up')) {
                element.style.transform = 'translateY(30px)';
            } else if (element.classList.contains('fade-in-down')) {
                element.style.transform = 'translateY(-30px)';
            } else if (element.classList.contains('fade-in-left')) {
                element.style.transform = 'translateX(-30px)';
            } else if (element.classList.contains('fade-in-right')) {
                element.style.transform = 'translateX(30px)';
            }
            
            fadeObserver.observe(element);
        });
        
        // Scale animations
        const scaleElements = document.querySelectorAll('.scale-in');
        
        const scaleObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.transform = 'scale(1)';
                    entry.target.style.opacity = '1';
                }
            });
        }, {
            threshold: 0.1
        });
        
        scaleElements.forEach(element => {
            element.style.transform = 'scale(0.9)';
            element.style.opacity = '0';
            element.style.transition = 'transform 0.6s ease, opacity 0.6s ease';
            scaleObserver.observe(element);
        });
    },

    /**
     * Setup parallax effects
     */
    setupParallaxEffects: function() {
        const parallaxElements = document.querySelectorAll('.parallax');
        
        if (parallaxElements.length === 0) return;
        
        const handleParallax = Utils.throttle(() => {
            const scrolled = Utils.getScrollPosition();
            
            parallaxElements.forEach(element => {
                const speed = element.dataset.speed || 0.5;
                const yPos = -(scrolled * speed);
                element.style.transform = `translateY(${yPos}px)`;
            });
        }, 16);
        
        window.addEventListener('scroll', handleParallax);
    },

    /**
     * Setup typing animation
     */
    setupTypingAnimation: function() {
        const typingElements = document.querySelectorAll('.typing-animation');
        
        typingElements.forEach(element => {
            const text = element.textContent;
            element.textContent = '';
            element.style.borderRight = '2px solid var(--primary-color)';
            
            let i = 0;
            const typeWriter = () => {
                if (i < text.length) {
                    element.textContent += text.charAt(i);
                    i++;
                    setTimeout(typeWriter, 100);
                } else {
                    element.style.borderRight = 'none';
                }
            };
            
            // Start typing when element is in view
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        typeWriter();
                        observer.unobserve(entry.target);
                    }
                });
            }, { threshold: 0.5 });
            
            observer.observe(element);
        });
    },

    /**
     * Setup counter animations
     */
    setupCounterAnimations: function() {
        const counterElements = document.querySelectorAll('.counter');
        
        counterElements.forEach(element => {
            const target = parseInt(element.dataset.target) || 0;
            const duration = parseInt(element.dataset.duration) || 2000;
            const prefix = element.dataset.prefix || '';
            const suffix = element.dataset.suffix || '';
            
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        Utils.animateNumber(element, target, duration);
                        observer.unobserve(entry.target);
                    }
                });
            }, { threshold: 0.5 });
            
            observer.observe(element);
        });
    },

    /**
     * Setup progress bar animations
     */
    setupProgressAnimations: function() {
        const progressElements = document.querySelectorAll('.progress-animate');
        
        progressElements.forEach(element => {
            const progressBar = element.querySelector('.progress-bar');
            const target = parseInt(element.dataset.progress) || 0;
            
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        element.classList.add('animate');
                        progressBar.style.width = `${target}%`;
                        observer.unobserve(entry.target);
                    }
                });
            }, { threshold: 0.5 });
            
            observer.observe(element);
        });
    },

    /**
     * Setup stagger animations for lists
     */
    setupStaggerAnimations: function() {
        const staggerContainers = document.querySelectorAll('.stagger-children');
        
        staggerContainers.forEach(container => {
            const children = Array.from(container.children);
            
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        container.classList.add('animate');
                        observer.unobserve(entry.target);
                    }
                });
            }, { threshold: 0.1 });
            
            observer.observe(container);
        });
    },

    /**
     * Setup hover effects
     */
    setupHoverEffects: function() {
        // Magnetic effect for buttons
        const magneticElements = document.querySelectorAll('.magnetic');
        
        magneticElements.forEach(element => {
            element.addEventListener('mousemove', (e) => {
                const rect = element.getBoundingClientRect();
                const x = e.clientX - rect.left - rect.width / 2;
                const y = e.clientY - rect.top - rect.height / 2;
                
                element.style.transform = `translate(${x * 0.1}px, ${y * 0.1}px)`;
            });
            
            element.addEventListener('mouseleave', () => {
                element.style.transform = 'translate(0, 0)';
            });
        });
        
        // Tilt effect for cards
        const tiltElements = document.querySelectorAll('.tilt');
        
        tiltElements.forEach(element => {
            element.addEventListener('mousemove', (e) => {
                const rect = element.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;
                
                const centerX = rect.width / 2;
                const centerY = rect.height / 2;
                
                const rotateX = (y - centerY) / 10;
                const rotateY = (centerX - x) / 10;
                
                element.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg)`;
            });
            
            element.addEventListener('mouseleave', () => {
                element.style.transform = 'perspective(1000px) rotateX(0) rotateY(0)';
            });
        });
    },

    /**
     * Add floating animation to elements
     * @param {string} selector - CSS selector for elements
     * @param {number} duration - Animation duration in seconds
     */
    addFloatingAnimation: function(selector, duration = 6) {
        const elements = document.querySelectorAll(selector);
        
        elements.forEach((element, index) => {
            element.style.animation = `float ${duration}s ease-in-out infinite`;
            element.style.animationDelay = `${index * 0.5}s`;
        });
    },

    /**
     * Add wave animation to elements
     * @param {string} selector - CSS selector for elements
     */
    addWaveAnimation: function(selector) {
        const elements = document.querySelectorAll(selector);
        
        elements.forEach((element, index) => {
            element.style.animation = `wave 1.5s ease-in-out infinite`;
            element.style.animationDelay = `${index * 0.1}s`;
        });
    },

    /**
     * Add pulse animation to elements
     * @param {string} selector - CSS selector for elements
     */
    addPulseAnimation: function(selector) {
        const elements = document.querySelectorAll(selector);
        
        elements.forEach(element => {
            element.style.animation = 'pulse 2s ease-in-out infinite';
        });
    },

    /**
     * Add heartbeat animation to elements
     * @param {string} selector - CSS selector for elements
     */
    addHeartbeatAnimation: function(selector) {
        const elements = document.querySelectorAll(selector);
        
        elements.forEach(element => {
            element.style.animation = 'heartbeat 1.5s ease-in-out infinite';
        });
    },

    /**
     * Add loading dots animation
     * @param {string} selector - CSS selector for elements
     */
    addLoadingDotsAnimation: function(selector) {
        const elements = document.querySelectorAll(selector);
        
        elements.forEach((element, index) => {
            element.style.animation = 'loadingDots 1.4s ease-in-out infinite both';
            element.style.animationDelay = `${index * 0.2}s`;
        });
    },

    /**
     * Animate element entrance
     * @param {Element} element - Element to animate
     * @param {string} animation - Animation type
     * @param {number} delay - Delay in milliseconds
     */
    animateEntrance: function(element, animation = 'fadeInUp', delay = 0) {
        const animations = {
            fadeInUp: { opacity: 0, transform: 'translateY(30px)' },
            fadeInDown: { opacity: 0, transform: 'translateY(-30px)' },
            fadeInLeft: { opacity: 0, transform: 'translateX(-30px)' },
            fadeInRight: { opacity: 0, transform: 'translateX(30px)' },
            scaleIn: { opacity: 0, transform: 'scale(0.9)' },
            rotateIn: { opacity: 0, transform: 'rotate(-180deg)' }
        };
        
        const initialState = animations[animation];
        if (!initialState) return;
        
        // Set initial state
        Object.assign(element.style, {
            ...initialState,
            transition: 'all 0.6s ease'
        });
        
        // Animate to final state
        setTimeout(() => {
            Object.assign(element.style, {
                opacity: 1,
                transform: 'translateY(0) translateX(0) scale(1) rotate(0deg)'
            });
        }, delay);
    },

    /**
     * Animate element exit
     * @param {Element} element - Element to animate
     * @param {string} animation - Animation type
     * @param {Function} callback - Callback after animation
     */
    animateExit: function(element, animation = 'fadeOutUp', callback) {
        const animations = {
            fadeOutUp: { opacity: 0, transform: 'translateY(-30px)' },
            fadeOutDown: { opacity: 0, transform: 'translateY(30px)' },
            fadeOutLeft: { opacity: 0, transform: 'translateX(-30px)' },
            fadeOutRight: { opacity: 0, transform: 'translateX(30px)' },
            scaleOut: { opacity: 0, transform: 'scale(0.9)' },
            rotateOut: { opacity: 0, transform: 'rotate(180deg)' }
        };
        
        const finalState = animations[animation];
        if (!finalState) return;
        
        Object.assign(element.style, {
            ...finalState,
            transition: 'all 0.6s ease'
        });
        
        setTimeout(() => {
            if (callback) callback();
        }, 600);
    },

    /**
     * Add scroll-triggered class toggles
     * @param {string} selector - CSS selector for elements
     * @param {string} className - Class to add/remove
     * @param {number} threshold - Scroll threshold
     */
    addScrollClassToggle: function(selector, className, threshold = 100) {
        const elements = document.querySelectorAll(selector);
        
        const handleScroll = Utils.throttle(() => {
            const scrollTop = Utils.getScrollPosition();
            
            elements.forEach(element => {
                if (scrollTop > threshold) {
                    element.classList.add(className);
                } else {
                    element.classList.remove(className);
                }
            });
        }, 100);
        
        window.addEventListener('scroll', handleScroll);
        handleScroll(); // Initial check
    },

    /**
     * Add mouse follow effect
     * @param {string} selector - CSS selector for elements
     */
    addMouseFollowEffect: function(selector) {
        const elements = document.querySelectorAll(selector);
        
        document.addEventListener('mousemove', (e) => {
            const mouseX = e.clientX;
            const mouseY = e.clientY;
            
            elements.forEach(element => {
                const rect = element.getBoundingClientRect();
                const centerX = rect.left + rect.width / 2;
                const centerY = rect.top + rect.height / 2;
                
                const deltaX = (mouseX - centerX) * 0.01;
                const deltaY = (mouseY - centerY) * 0.01;
                
                element.style.transform = `translate(${deltaX}px, ${deltaY}px)`;
            });
        });
    }
};

// Initialize animations when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    Animations.init();
    
    // Add specific animations
    Animations.addFloatingAnimation('.floating-card');
    Animations.addWaveAnimation('.wave-animation');
    Animations.addPulseAnimation('.pulse-animation');
    Animations.addHeartbeatAnimation('.heartbeat-animation');
    Animations.addLoadingDotsAnimation('.loading-dots');
    
    // Add scroll class toggles
    Animations.addScrollClassToggle('.navbar', 'scrolled', 100);
    
    // Add mouse follow effect to hero elements
    Animations.addMouseFollowEffect('.hero-visual');
});

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = Animations;
} 