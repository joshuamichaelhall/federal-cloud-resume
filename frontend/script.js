// Visitor Counter Script
// This script calls the API Gateway endpoint to increment and retrieve the visitor count

const API_URL = 'YOUR_API_GATEWAY_URL'; // Will be replaced during deployment

async function updateVisitorCount() {
    const countElement = document.getElementById('visitor-count');

    try {
        // Call the API to get and increment the visitor count
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            mode: 'cors'
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();

        // Update the count on the page
        if (data.count !== undefined) {
            countElement.textContent = data.count.toLocaleString();
            countElement.style.animation = 'none';
        } else {
            countElement.textContent = 'Error';
        }
    } catch (error) {
        console.error('Error fetching visitor count:', error);
        countElement.textContent = 'Unavailable';
        countElement.style.animation = 'none';
    }
}

// Call the function when the page loads
document.addEventListener('DOMContentLoaded', updateVisitorCount);
