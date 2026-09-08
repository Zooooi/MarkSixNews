document.addEventListener("DOMContentLoaded", function() {
    const copyBtns = document.querySelectorAll('.copy-btn');
    
    copyBtns.forEach(btn => {
    btn.addEventListener('click', function() {
        const textToCopy = this.getAttribute('data-copy');
        
        if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(textToCopy).then(showToast);
        } else {
        // 相容舊版 WebView 的複製方式
        const textArea = document.createElement("textarea");
        textArea.value = textToCopy;
        textArea.style.position = "fixed";
        textArea.style.opacity = "0";
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
        try {
            navigator.clipboard.writeText(textToCopy);
            showToast();
        } catch (err) {
            console.error('Copy failed', err);
        }
        document.body.removeChild(textArea);
        }
    });
    });

    function showToast() {
        const toast = document.getElementById('toast');
        toast.style.display = 'block';
        setTimeout(() => { toast.style.display = 'none'; }, 3000);
    }
});