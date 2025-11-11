#!/bin/bash

INSTALL_DIR="__INSTALL_DIR__"
LOG_DIR="/var/log/__APP__"

cleanup() {
    echo "Arrêt des applications..."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
    wait $BACKEND_PID $FRONTEND_PID 2>/dev/null
    exit 0
}

trap cleanup SIGTERM SIGINT

cd "$INSTALL_DIR/backend"
/venv/bin/python3 -m app.main --host 127.0.0.1 --port __PORT_BACKEND__ >> "$LOG_DIR/backend.log" 2>&1 &
BACKEND_PID=$!

cd "$INSTALL_DIR/web"
PORT=__PORT__ npm start >> "$LOG_DIR/frontend.log" 2>&1 &
FRONTEND_PID=$!

echo $BACKEND_PID > /tmp/__APP__-backend.pid
echo $FRONTEND_PID > /tmp/__APP__-frontend.pid

# Attendre que les processus se terminent
wait $BACKEND_PID $FRONTEND_PID