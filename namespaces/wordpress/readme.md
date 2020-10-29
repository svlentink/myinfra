# Wordpress

## Reset password

```
cat << 'EOF' > reset-my-password-ab12fe23.php
<?php
define('WP_USE_THEMES', false);
require('wp-load.php');

wp_set_password('REDACTED', 1);

#$user_info = get_userdata(1);
echo 'Username: ' . $user_info->user_login . "\n";
echo 'User roles: ' . implode(', ', $user_info->roles) . "\n";
echo 'User ID: ' . $user_info->ID . "\n";
?>
EOF
```

