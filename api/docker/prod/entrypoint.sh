#!/bin/sh
set -e

echo "⏳ Waiting for Database..."
until nc -z "$DB_HOST" "$DB_PORT"; do
  sleep 2
done

echo "✅ Database is ready!"

if [ $# -gt 0 ]; then
    echo "🛠 Running custom command: $@"
    exec "$@"
else
    echo "🚀 Starting application server..."
    exec node dist/index.js
fi