<?php

$frontendUrls = array_values(array_filter(array_map(
    'trim',
    explode(',', (string) env('FRONTEND_URLS', ''))
)));

$allowedOrigins = array_values(array_unique(array_filter([
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'https://cityhall-frontend-nu.vercel.app',
    env('FRONTEND_URL', 'http://localhost:3000'),
    ...$frontendUrls,
    'https://cityhall-phi.vercel.app',
])));

$allowedOriginPatterns = array_values(array_filter(array_map(
    'trim',
    explode(',', (string) env('FRONTEND_ORIGIN_PATTERNS', ''))
)));

if (!in_array('^https:\/\/.*\.vercel\.app$', $allowedOriginPatterns, true)) {
    $allowedOriginPatterns[] = '^https:\/\/.*\.vercel\.app$';
}

if (!in_array('^http:\/\/localhost(:\d+)?$', $allowedOriginPatterns, true)) {
    $allowedOriginPatterns[] = '^http:\/\/localhost(:\d+)?$';
}

if (!in_array('^http:\/\/127\.0\.0\.1(:\d+)?$', $allowedOriginPatterns, true)) {
    $allowedOriginPatterns[] = '^http:\/\/127\.0\.0\.1(:\d+)?$';
}

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure your settings for cross-origin resource sharing
    | or "CORS". This determines what cross-origin operations may execute
    | in web browsers. You are free to adjust these settings as needed.
    |
    | To learn more: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    |
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    'allowed_origins' => $allowedOrigins,

    'allowed_origins_patterns' => $allowedOriginPatterns,

    'allowed_headers' => ['*'],

    // Allows the frontend to read the filename from Content-Disposition on downloads.
    'exposed_headers' => ['Content-Disposition'],

    'max_age' => 0,

    'supports_credentials' => true,

];
