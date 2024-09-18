<?php
define('DB_NAME', getenv('WORDPRESS_DB_NAME'));
define('DB_USER', getenv('WORDPRESS_DB_USER'));
define('DB_PASSWORD', getenv('WORDPRESS_DB_PASSWORD'));
define('DB_HOST', getenv('WORDPRESS_DB_HOST'));
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

define('AUTH_KEY',         'something1');
define('SECURE_AUTH_KEY',  'something2');
define('LOGGED_IN_KEY',    'something3');
define('NONCE_KEY',        'something4');
define('AUTH_SALT',        'something5');
define('SECURE_AUTH_SALT', 'something6');
define('LOGGED_IN_SALT',   'something7');
define('NONCE_SALT',       'something8');

$table_prefix = 'wp_';

define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);

if ( !defined('ABSPATH') )
    define('ABSPATH', __DIR__ . '/');

require_once(ABSPATH . 'wp-settings.php');
