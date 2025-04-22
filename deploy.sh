#!/bin/bash

# --- CONFIGURATION ---
SERVER_USER="u214605677"
SERVER_IP="147.79.103.136"
REMOTE_PATH="/home/u214605677/domains/test.custospark.com"
PROJECT_ZIP="project.zip"

# --- STEP 1: ZIP the project ---
echo "🗜️  Zipping project (excluding unnecessary files)..."
zip -rq $PROJECT_ZIP . -x "vendor/*" "node_modules/*" ".git/*" "storage/*" ".env"

# --- STEP 2: Upload ZIP to server ---
echo "📤 Uploading $PROJECT_ZIP to server..."
scp $PROJECT_ZIP ${SERVER_USER}@${SERVER_IP}:${REMOTE_PATH}/

# --- STEP 3: SSH into server and deploy ---
echo "🔗 Connecting to server..."
ssh ${SERVER_USER}@${SERVER_IP} << EOF
    set -e
    cd ${REMOTE_PATH}

    echo "📦 Unzipping project..."
    unzip -o ${PROJECT_ZIP}
    rm ${PROJECT_ZIP}

    echo "🎼 Installing PHP dependencies..."
    php ~/composer.phar install --no-dev --optimize-autoloader

    echo "🔗 Ensuring storage link exists..."
    [ -L public/storage ] || ln -s storage/app/public public/storage

    echo "🛠️ Setting permissions..."
    find storage bootstrap/cache -type d -exec chmod 775 {} \;

    echo "⚡ Clearing caches..."
    php artisan config:clear
    php artisan route:clear
    php artisan view:clear
    php artisan cache:clear

    echo "🛤️ Running migrations..."
    php artisan migrate --force

    echo "✅ Deployment completed on server!"
EOF

# --- STEP 4: Clean up local ZIP ---
echo "🧹 Removing local ZIP..."
rm -f $PROJECT_ZIP

echo "🚀 Full Deployment completed successfully!"
