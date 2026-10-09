/**
 * Cloudflare Worker for handling comment submissions
 * Stores comments as GitHub issues in a private repository
 */

export default {
  async fetch(request, env) {
    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': 'https://nshkr.com',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // Only accept POST requests
    if (request.method !== 'POST') {
      return new Response('Method not allowed', { 
        status: 405,
        headers: corsHeaders 
      });
    }

    try {
      // Parse request body
      const body = await request.json();
      const { author, email, message, page } = body;

      // Basic validation
      if (!author || !message || !page) {
        return new Response(JSON.stringify({ 
          error: 'Missing required fields' 
        }), {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }

      // Rate limiting by IP
      const ip = request.headers.get('CF-Connecting-IP');
      const rateLimitKey = `rate_limit:${ip}`;
      const submissions = await env.COMMENTS_KV.get(rateLimitKey);
      
      if (submissions && parseInt(submissions) >= 5) {
        return new Response(JSON.stringify({ 
          error: 'Too many submissions. Please try again later.' 
        }), {
          status: 429,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }

      // Basic spam detection
      if (isSpam(message)) {
        return new Response(JSON.stringify({ 
          error: 'Comment rejected' 
        }), {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }

      // Create GitHub issue
      const githubResponse = await fetch(`https://api.github.com/repos/${env.GITHUB_REPO}/issues`, {
        method: 'POST',
        headers: {
          'Authorization': `token ${env.GITHUB_TOKEN}`,
          'User-Agent': 'Cloudflare-Worker',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          title: `Comment on ${page} by ${author}`,
          body: formatIssueBody(author, email, message, page, ip),
          labels: ['comment', 'pending-moderation']
        })
      });

      if (!githubResponse.ok) {
        throw new Error('Failed to create GitHub issue');
      }

      // Update rate limit
      await env.COMMENTS_KV.put(rateLimitKey, 
        (parseInt(submissions || 0) + 1).toString(), 
        { expirationTtl: 3600 } // 1 hour
      );

      // Success response
      return new Response(JSON.stringify({ 
        success: true,
        message: 'Comment submitted for moderation' 
      }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });

    } catch (error) {
      console.error('Error:', error);
      return new Response(JSON.stringify({ 
        error: 'Internal server error' 
      }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }
  }
};

// Basic spam detection
function isSpam(message) {
  const spamPatterns = [
    /viagra/i,
    /casino/i,
    /\b(buy|cheap|discount|offer)\b.*\b(now|today|limited)\b/i,
    /https?:\/\/[^\s]+/g, // URLs (you might want to allow these)
    /(.)\1{5,}/, // Repeated characters
  ];
  
  return spamPatterns.some(pattern => pattern.test(message));
}

// Format GitHub issue body
function formatIssueBody(author, email, message, page, ip) {
  return `## New Comment Submission

**Author:** ${author}
**Email:** ${email || 'Not provided'}
**Page:** ${page}
**IP:** ${ip}
**Timestamp:** ${new Date().toISOString()}

### Message:
${message}

---
To approve this comment:
1. Remove the \`pending-moderation\` label
2. Add the \`approved\` label
3. The site will pick it up on next build`;
}