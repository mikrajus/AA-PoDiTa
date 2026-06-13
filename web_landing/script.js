// Efek blur/glassmorphism pada navbar saat di-scroll
const navbar = document.querySelector('.navbar');

window.addEventListener('scroll', () => {
    if (window.scrollY > 50) {
        navbar.classList.add('glass-effect');
        navbar.style.padding = '10px 0';
    } else {
        navbar.style.padding = '15px 0';
    }
});

// Animasi smooth scrolling untuk anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        
        const targetId = this.getAttribute('href');
        if (targetId === '#') return;
        
        const targetElement = document.querySelector(targetId);
        
        if (targetElement) {
            window.scrollTo({
                top: targetElement.offsetTop - 80, // Offset untuk header
                behavior: 'smooth'
            });
        }
    });
});
