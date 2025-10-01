# Security Report: Authentication in MoMo Transactions API

## Weaknesses of Basic Authentication
The current API uses **Basic Authentication** with a static username and password. Unfortunatley this has huge huge weaknesses:

- **Plain Base64 Encoding**: Credentials are only base64 encoded, not encrypted. Anyone who intercepts traffic can easily decode them.  

- **Sent with Every Request**: The username and password are included in the header of every API call, increasing the risk of exposure.  

- **No Expiration or Rotation**: Credentials remain valid indefinitely unless manually changed, which increases the risk if they are leaked.  

---

## Stronger Alternatives
To improve security, more robust authentication methods should be considered:

### 1. JSON Web Tokens (JWT)
- Stateless and scalable: the server does not need to store session data.  
- Tokens are signed and can include expiration times.  
- Widely used in APIs for secure authentication.  

### 2. OAuth2
- Industry standard for delegated access.  
- Used by providers like Google, GitHub, and Facebook.  
- Provides secure flows for web apps, mobile apps, and third-party integrations.  

### 3. Session-Based Authentication
- Server issues a session ID stored in cookies.  
- Sessions can expire, be revoked, or rotated.  
- More secure than static credentials, especially when combined with HTTPS.

In actuality, basic authentication was used for this project but in practicality, the authentication type is weak. For something to be published, stronger technique of authentication used such as the ones mentioned above.