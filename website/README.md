# Website Directory

This directory contains the landing page and web presence for the project, built with HTML, CSS, and JavaScript.

## Purpose

The `website/` directory houses the main landing page and web presence for the project, showcasing the applications and providing information to users and potential customers. The website consists of three main pages accessible through navigation.

## Structure

```
website/
├── index.html            # Main homepage
├── privacy-policy.html   # Privacy policy page
├── terms-of-service.html # Terms of service page
├── css/                  # Stylesheets
│   ├── main.css         # Main stylesheet
│   ├── components.css   # Component-specific styles
│   ├── animations.css   # Animation styles
│   └── responsive.css   # Responsive design styles
├── js/                   # JavaScript files
│   ├── main.js          # Main JavaScript file
│   ├── navigation.js    # Navigation functionality
│   ├── animations.js    # Animation scripts
│   └── utils.js         # Utility functions
├── assets/               # Static assets
│   ├── images/          # Images and graphics
│   ├── icons/           # Icons and logos
│   └── fonts/           # Custom fonts
└── README.md             # This file
```

## Pages

### 1. Homepage (index.html)
The main landing page showcasing the application with:
- **Hero Section**: Main value proposition and call-to-action
- **Features**: Key features and benefits of the applications
- **About**: Information about the project and team
- **Contact**: Contact information and forms
- **Navigation**: Links to Privacy Policy and Terms of Service
- **Footer**: Links, social media, and legal information

### 2. Privacy Policy (privacy-policy.html)
Dedicated page for privacy policy with:
- **Navigation**: Link back to homepage and Terms of Service
- **Content**: Comprehensive privacy policy information
- **Contact**: Information for privacy-related inquiries
- **Footer**: Consistent footer with all links

### 3. Terms of Service (terms-of-service.html)
Dedicated page for terms of service with:
- **Navigation**: Link back to homepage and Privacy Policy
- **Content**: Comprehensive terms of service information
- **Contact**: Information for legal inquiries
- **Footer**: Consistent footer with all links

## Features

### Modern Design
- Clean, modern, and attractive design
- Professional color scheme and typography
- Consistent branding across all pages
- High-quality graphics and icons

### Animations
- Smooth scroll animations
- Hover effects and transitions
- Loading animations
- Interactive elements with CSS animations
- JavaScript-powered animations for enhanced user experience

### Responsive Design
- Mobile-first approach
- Responsive layout for all screen sizes
- Optimized for desktop, tablet, and mobile devices
- Touch-friendly navigation

### Performance
- Fast loading times
- Optimized images and assets
- SEO-friendly structure
- Progressive Web App (PWA) capabilities
- Minified CSS and JavaScript for production

## Development Guidelines

- **HTML Structure**: Use semantic HTML5 elements
- **CSS Organization**: Use modular CSS with clear naming conventions
- **JavaScript**: Use modern ES6+ syntax and modular structure
- **Responsive Design**: Ensure the website works on all device sizes
- **Performance**: Optimize for fast loading and smooth interactions
- **Accessibility**: Follow WCAG 2.1 guidelines
- **SEO**: Implement proper meta tags and structured data
- **Cross-browser Compatibility**: Test on multiple browsers and devices
- **Documentation**: Document all components and their usage

## Example HTML Structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Template - Mobile Development Solution</title>
    <meta name="description" content="Comprehensive Flutter-based mobile development solution with web panels">
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/animations.css">
    <link rel="stylesheet" href="css/responsive.css">
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-logo">
                <a href="index.html">Project Template</a>
            </div>
            <ul class="nav-menu">
                <li><a href="index.html">Home</a></li>
                <li><a href="privacy-policy.html">Privacy Policy</a></li>
                <li><a href="terms-of-service.html">Terms of Service</a></li>
            </ul>
            <div class="hamburger">
                <span></span>
                <span></span>
                <span></span>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero">
        <div class="hero-content">
            <h1 class="hero-title">Welcome to Our Project</h1>
            <p class="hero-subtitle">A comprehensive Flutter-based mobile development solution</p>
            <button class="cta-button">Get Started</button>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features">
        <div class="container">
            <h2 class="section-title">Key Features</h2>
            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon">📱</div>
                    <h3>Mobile Apps</h3>
                    <p>Cross-platform Flutter applications for iOS and Android</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">🌐</div>
                    <h3>Web Panel</h3>
                    <p>Administrative web interface built with Flutter web</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">☁️</div>
                    <h3>Cloud Backend</h3>
                    <p>Scalable Firebase Cloud Functions for server-side logic</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <div class="footer-content">
                <div class="footer-section">
                    <h4>Project Template</h4>
                    <p>Comprehensive mobile development solution</p>
                </div>
                <div class="footer-section">
                    <h4>Legal</h4>
                    <ul>
                        <li><a href="privacy-policy.html">Privacy Policy</a></li>
                        <li><a href="terms-of-service.html">Terms of Service</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </footer>

    <script src="js/main.js"></script>
    <script src="js/navigation.js"></script>
    <script src="js/animations.js"></script>
</body>
</html>
```

## Example CSS Structure

```css
/* main.css */
:root {
    --primary-color: #2563eb;
    --secondary-color: #1e40af;
    --text-color: #1f2937;
    --light-bg: #f8fafc;
    --white: #ffffff;
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Inter', sans-serif;
    line-height: 1.6;
    color: var(--text-color);
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}

/* Navigation */
.navbar {
    position: fixed;
    top: 0;
    width: 100%;
    background: var(--white);
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    z-index: 1000;
}

.nav-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem 2rem;
}

.nav-menu {
    display: flex;
    list-style: none;
    gap: 2rem;
}

.nav-menu a {
    text-decoration: none;
    color: var(--text-color);
    font-weight: 500;
    transition: color 0.3s ease;
}

.nav-menu a:hover {
    color: var(--primary-color);
}

/* Hero Section */
.hero {
    min-height: 100vh;
    background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    color: var(--white);
}

.hero-title {
    font-size: 3.5rem;
    font-weight: 700;
    margin-bottom: 1rem;
}

.hero-subtitle {
    font-size: 1.25rem;
    margin-bottom: 2rem;
    opacity: 0.9;
}

.cta-button {
    background: var(--white);
    color: var(--primary-color);
    border: none;
    padding: 1rem 2rem;
    font-size: 1.1rem;
    font-weight: 600;
    border-radius: 8px;
    cursor: pointer;
    transition: transform 0.3s ease;
}

.cta-button:hover {
    transform: translateY(-2px);
}
```

## Example JavaScript Structure

```javascript
// main.js
document.addEventListener('DOMContentLoaded', function() {
    // Initialize animations
    initAnimations();
    
    // Initialize navigation
    initNavigation();
    
    // Initialize smooth scrolling
    initSmoothScrolling();
});

// animations.js
function initAnimations() {
    // Intersection Observer for scroll animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
            }
        });
    }, observerOptions);
    
    // Observe elements for animation
    document.querySelectorAll('.animate-on-scroll').forEach(el => {
        observer.observe(el);
    });
}

// navigation.js
function initNavigation() {
    const hamburger = document.querySelector('.hamburger');
    const navMenu = document.querySelector('.nav-menu');
    
    hamburger.addEventListener('click', () => {
        hamburger.classList.toggle('active');
        navMenu.classList.toggle('active');
    });
    
    // Close mobile menu when clicking on a link
    document.querySelectorAll('.nav-menu a').forEach(link => {
        link.addEventListener('click', () => {
            hamburger.classList.remove('active');
            navMenu.classList.remove('active');
        });
    });
}
```

## Setup Instructions

1. **Navigate to website directory**:
   ```bash
   cd website
   ```

2. **Open in browser**:
   ```bash
   # Using Python (if available)
   python -m http.server 8000
   
   # Using Node.js (if available)
   npx serve .
   
   # Or simply open index.html in your browser
   ```

3. **Development server**:
   - Use any local development server
   - Recommended: Live Server extension in VS Code
   - Or use tools like `live-server` or `browser-sync`

4. **Build for production**:
   - Minify CSS and JavaScript files
   - Optimize images
   - Compress assets
   - Use tools like `gulp`, `webpack`, or `parcel`

## Best Practices

1. **Performance**: Optimize images, use lazy loading, minimize CSS/JS files
2. **SEO**: Use proper meta tags, structured data, and semantic HTML5
3. **Accessibility**: Follow WCAG 2.1 guidelines, use proper ARIA labels
4. **Responsive Design**: Test on multiple devices and screen sizes
5. **Cross-browser Compatibility**: Test on Chrome, Firefox, Safari, Edge
6. **Security**: Follow web security best practices, use HTTPS
7. **Analytics**: Implement web analytics for tracking user behavior
8. **Testing**: Test across different browsers and devices
9. **Documentation**: Document all components and their usage
10. **Code Organization**: Use modular CSS and JavaScript structure 