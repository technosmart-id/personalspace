<?php
/**
 * Plugin Name: HTTPS Fix for Reverse Proxy
 * Description: Forces HTTPS when behind a reverse proxy
 */

// Force HTTPS when behind reverse proxy
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}

// Force HTTPS in URLs
add_filter('site_url', function($url) {
    if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
        return str_replace('http://', 'https://', $url);
    }
    return $url;
});

add_filter('home_url', function($url) {
    if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
        return str_replace('http://', 'https://', $url);
    }
    return $url;
});

add_filter('script_loader_src', function($src) {
    if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
        return str_replace('http://', 'https://', $src);
    }
    return $src;
});

add_filter('style_loader_src', function($src) {
    if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
        return str_replace('http://', 'https://', $src);
    }
    return $src;
});
