#! /bin/sh

mysql << EOF
SELECT NOW() as 'checked_at'
EOF
