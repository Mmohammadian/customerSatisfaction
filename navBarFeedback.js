document.querySelectorAll('.report-star-rating').forEach(function(icon) {
    const label = icon.parentElement.querySelector('.t-Button-label');
    const rating = parseFloat(label?.textContent.trim() || 0);

    // مخفی کردن عدد نمایش داده شده
    if (label) label.style.display = 'none';

    const fullStars = Math.floor(rating);
    const decimal = rating - fullStars;

    let halfStar = false;
    let adjustedFullStars = fullStars;

    if (decimal < 0.01) {
        // هیچ نیمه ستاره‌ای نیست
    } else if (decimal < 0.99) {
        halfStar = true;
    } else {
        adjustedFullStars = fullStars + 1;
    }

    icon.innerHTML = '';

    // ستاره‌های کامل
    for (let i = 0; i < adjustedFullStars; i++) {
        const star = document.createElement('span');
        star.classList.add('star', 'full');
        star.textContent = '★';
        icon.appendChild(star);
    }

    // نیمه ستاره
    if (halfStar) {
        const star = document.createElement('span');
        star.classList.add('star', 'half');
        star.textContent = '★';
        icon.appendChild(star);
    }

    // ستاره‌های خالی
    const emptyStars = 5 - adjustedFullStars - (halfStar ? 1 : 0);
    for (let i = 0; i < emptyStars; i++) {
        const star = document.createElement('span');
        star.classList.add('star');
        star.textContent = '★';
        icon.appendChild(star);
    }
});


document.querySelectorAll('.report-star-rating-cs').forEach(function(icon) {
    const rating = parseFloat(icon.getAttribute('data-rating') || 0);

    const fullStars = Math.floor(rating);
    const decimal = rating - fullStars;

    icon.innerHTML = '';

    // ستاره‌های کامل
    for (let i = 0; i < fullStars; i++) {
        const star = document.createElement('span');
        star.classList.add('star', 'full');
        star.textContent = '★';
        star.style.color = 'gold';
        icon.appendChild(star);
    }

    // ستاره‌ی جزئی (بر اساس اعشار)
    if (decimal > 0) {
        const star = document.createElement('span');
        star.classList.add('star', 'partial');
        star.textContent = '★';
        const percent = decimal * 100;
        star.style.background = `linear-gradient(90deg, gold ${percent}%, lightgray ${percent}%)`;
        star.style.webkitBackgroundClip = 'text';
        star.style.webkitTextFillColor = 'transparent';
        icon.appendChild(star);
    }

    // ستاره‌های خالی
    const totalStars = fullStars + (decimal > 0 ? 1 : 0);
    const emptyStars = 5 - totalStars;
    for (let i = 0; i < emptyStars; i++) {
        const star = document.createElement('span');
        star.classList.add('star', 'empty');
        star.textContent = '★';
        star.style.color = 'lightgray';
        icon.appendChild(star);
    }
});

