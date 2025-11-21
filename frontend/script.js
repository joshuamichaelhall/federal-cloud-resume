// API endpoint
const API_ENDPOINT = 'https://nqi062dhwa.execute-api.us-east-1.amazonaws.com/prod/count';

// Fetch and display visitor count
async function updateVisitorCount() {
  const countElement = document.getElementById('visitor-count');
  
  try {
    countElement.textContent = 'Loading...';
    
    const response = await fetch(API_ENDPOINT);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    countElement.textContent = data.count.toLocaleString();
    
  } catch (error) {
    console.error('Error fetching visitor count:', error);
    countElement.textContent = 'Error loading count';
  }
}

// Run on page load
document.addEventListener('DOMContentLoaded', updateVisitorCount);