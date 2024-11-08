document.addEventListener('DOMContentLoaded', function() {
    // Add copy buttons to all pre elements
    document.querySelectorAll('pre').forEach(function(codeBlock) {
        // Create wrapper div
        const wrapper = document.createElement('div');
        wrapper.className = 'code-wrapper';
        codeBlock.parentNode.insertBefore(wrapper, codeBlock);
        wrapper.appendChild(codeBlock);

        // Create copy button
        const button = document.createElement('button');
        button.className = 'copy-button';
        button.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"></path><rect x="8" y="2" width="8" height="4" rx="1" ry="1"></rect></svg>';

        button.addEventListener('click', async function() {
            try {
                await navigator.clipboard.writeText(codeBlock.textContent);
                button.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>';

                setTimeout(() => {
                    button.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"></path><rect x="8" y="2" width="8" height="4" rx="1" ry="1"></rect></svg>';
                }, 1000);
            } catch (err) {
                console.error('Failed to copy text: ', err);
            }
        });

        wrapper.appendChild(button);
    });
});