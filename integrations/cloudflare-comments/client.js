/**
 * Client-side comment form handler
 * Add this to any page where you want comments
 */

class CommentSystem {
  constructor(config = {}) {
    this.endpoint = config.endpoint || 'https://comments.your-worker.workers.dev';
    this.page = config.page || window.location.pathname;
    this.formId = config.formId || 'comment-form';
    this.containerId = config.containerId || 'comments-container';
    
    this.init();
  }

  init() {
    // Create comment form if it doesn't exist
    if (!document.getElementById(this.formId)) {
      this.createForm();
    }
    
    // Attach event listener
    const form = document.getElementById(this.formId);
    if (form) {
      form.addEventListener('submit', (e) => this.handleSubmit(e));
    }
  }

  createForm() {
    const container = document.getElementById(this.containerId);
    if (!container) return;

    const formHTML = `
      <div class="comment-form-wrapper">
        <h3>Leave a Comment</h3>
        <form id="${this.formId}" class="comment-form">
          <div class="form-group">
            <label for="author">Name *</label>
            <input type="text" id="author" name="author" required>
          </div>
          
          <div class="form-group">
            <label for="email">Email (optional)</label>
            <input type="email" id="email" name="email">
          </div>
          
          <div class="form-group">
            <label for="message">Comment *</label>
            <textarea id="message" name="message" rows="5" required></textarea>
          </div>
          
          <button type="submit" class="submit-btn">Submit Comment</button>
          
          <div class="form-message" style="display: none;"></div>
        </form>
      </div>
      
      <style>
        .comment-form-wrapper {
          max-width: 600px;
          margin: 2rem 0;
          padding: 1.5rem;
          background: rgba(255, 255, 255, 0.05);
          border-radius: 8px;
          border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .comment-form .form-group {
          margin-bottom: 1rem;
        }
        
        .comment-form label {
          display: block;
          margin-bottom: 0.5rem;
          color: #e0e0e0;
          font-weight: 500;
        }
        
        .comment-form input,
        .comment-form textarea {
          width: 100%;
          padding: 0.5rem;
          background: rgba(255, 255, 255, 0.1);
          border: 1px solid rgba(255, 255, 255, 0.2);
          border-radius: 4px;
          color: #fff;
          font-family: inherit;
        }
        
        .comment-form input:focus,
        .comment-form textarea:focus {
          outline: none;
          border-color: #0fbcf9;
          background: rgba(255, 255, 255, 0.15);
        }
        
        .submit-btn {
          background: linear-gradient(135deg, #0fbcf9, #1b6ca8);
          color: white;
          border: none;
          padding: 0.75rem 2rem;
          border-radius: 4px;
          cursor: pointer;
          font-weight: 500;
          transition: transform 0.2s;
        }
        
        .submit-btn:hover {
          transform: translateY(-2px);
        }
        
        .submit-btn:disabled {
          opacity: 0.6;
          cursor: not-allowed;
        }
        
        .form-message {
          margin-top: 1rem;
          padding: 0.75rem;
          border-radius: 4px;
          text-align: center;
        }
        
        .form-message.success {
          background: rgba(76, 175, 80, 0.2);
          color: #4caf50;
          border: 1px solid rgba(76, 175, 80, 0.4);
        }
        
        .form-message.error {
          background: rgba(244, 67, 54, 0.2);
          color: #f44336;
          border: 1px solid rgba(244, 67, 54, 0.4);
        }
      </style>
    `;

    container.innerHTML = formHTML;
  }

  async handleSubmit(e) {
    e.preventDefault();
    
    const form = e.target;
    const submitBtn = form.querySelector('.submit-btn');
    const messageDiv = form.querySelector('.form-message');
    
    // Disable form
    submitBtn.disabled = true;
    submitBtn.textContent = 'Submitting...';
    
    // Get form data
    const formData = new FormData(form);
    const data = {
      author: formData.get('author'),
      email: formData.get('email'),
      message: formData.get('message'),
      page: this.page
    };
    
    try {
      const response = await fetch(this.endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(data)
      });
      
      const result = await response.json();
      
      if (response.ok) {
        // Success
        messageDiv.className = 'form-message success';
        messageDiv.textContent = result.message || 'Comment submitted successfully!';
        messageDiv.style.display = 'block';
        
        // Reset form
        form.reset();
      } else {
        // Error
        messageDiv.className = 'form-message error';
        messageDiv.textContent = result.error || 'Failed to submit comment';
        messageDiv.style.display = 'block';
      }
    } catch (error) {
      messageDiv.className = 'form-message error';
      messageDiv.textContent = 'Network error. Please try again.';
      messageDiv.style.display = 'block';
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = 'Submit Comment';
      
      // Hide message after 5 seconds
      setTimeout(() => {
        messageDiv.style.display = 'none';
      }, 5000);
    }
  }
}

// Auto-initialize if data attribute is present
document.addEventListener('DOMContentLoaded', () => {
  const commentContainers = document.querySelectorAll('[data-comments="true"]');
  commentContainers.forEach(container => {
    new CommentSystem({
      containerId: container.id,
      endpoint: container.dataset.endpoint
    });
  });
});