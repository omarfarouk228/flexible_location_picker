/// This constant holds the Google Maps API key for the example application.
///
/// **IMPORTANT SECURITY NOTE:**
/// For production applications, **never hardcode API keys directly in your source code**
/// like this. This is highly insecure as anyone can decompile your app and
/// extract the key, potentially leading to unauthorized usage and charges on
/// your Google Cloud account.
///
/// **Recommended Secure Practices for Production:**
/// 1.  **Environment Variables:** Load the key from environment variables during build time.
/// 2.  **Build Flavors/Configurations:** Use Flutter flavors (Android) or
///     build configurations (iOS) to inject different keys per environment
///     (e.g., development, staging, production).
/// 3.  **Backend Proxy:** For server-side APIs, make calls from your backend server
///     where the API key can be securely stored and managed.
/// 4.  **Google Secrets Manager (or similar service):** For more advanced
///     scenarios, use a dedicated secrets management service.
///
const String apiKey = '';
