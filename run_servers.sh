#!/bin/bash
set -e

cd /app/backend
pip install -r requirements.txt
python main.py &

cd /app/frontend
npm install
npm run build && npx vite preview --port 3000 --host 0.0.0.0 --strictPort &
