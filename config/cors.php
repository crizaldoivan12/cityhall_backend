<?php

$frontendUrls = array_values(array_filter(array_map(
    'trim',
    explode(',', (string) env('FRONTEND_URLS', ''))
)));

'allowed_origins' => [
    'https://cityhall-phi.vercel.app',
],


$allowedOriginPatterns = array_values(array_filter(array_map(
    'trim',
    explode(',', (string) env('FRONTEND_ORIGIN_PATTERNS', ''))
)));

if (!in_array('^https:\/\/.*\.vercel\.app$', $allowedOriginPatterns, true)) {
    $allowedOriginPatterns[] = '^https:\/\/.*\.vercel\.app$';
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

    'allowed_origins' => [
    'https://cityhall-phi.vercel.app',
],
'supports_credentials' => true,

];
