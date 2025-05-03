#!/bin/bash
# Start cron service
service cron start

# Start Apache in foreground
apache2-foreground