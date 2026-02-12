# Wassal Project Makefile

.PHONY: install backend mobile clean help

# Default target
all: help

help:
	@echo "Mikrotik Wassal Management System"
	@echo "================================="
	@echo "Available commands:"
	@echo "  make install   - Install dependencies for both Backend and Mobile"
	@echo "  make backend   - Start the Backend server (NestJS)"
	@echo "  make mobile    - Start the Mobile application (Flutter)"
	@echo "  make clean     - Remove node_modules and build artifacts"
	@echo "  make check     - Check project status"

install:
	@echo "Installing Backend dependencies..."
	cd backend && npm install
	@echo "Installing Mobile dependencies..."
	cd mobile && flutter pub get
	@echo "Done!"

backend:
	@echo "Starting Backend..."
	cd backend && npm run start:dev

mobile:
	@echo "Starting Mobile App..."
	cd mobile && flutter run

clean:
	@echo "Cleaning Backend..."
	cd backend && rm -rf node_modules dist
	@echo "Cleaning Mobile..."
	cd mobile && flutter clean
	@echo "Clean complete."

check:
	@echo "Checking Environment..."
	@powershell -Command "if (Test-Path backend) { Write-Host 'Backend: OK' -ForegroundColor Green } else { Write-Host 'Backend: MISSING' -ForegroundColor Red }"
	@powershell -Command "if (Test-Path mobile) { Write-Host 'Mobile: OK' -ForegroundColor Green } else { Write-Host 'Mobile: MISSING' -ForegroundColor Red }"
