#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Log function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Success function
success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Warning function
warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Error function
error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if brew is installed
check_brew() {
    if ! command_exists brew; then
        error "Homebrew is not installed. Please install Homebrew first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    success "Homebrew is installed"
}

# Check if Bun is installed
check_bun() {
    if ! command_exists bun; then
        error "Bun is not installed. Please install Bun first:"
        echo "  curl -fsSL https://bun.sh/install | bash"
        exit 1
    fi
    success "Bun is installed ($(bun --version))"
}

# Setup PostgreSQL
setup_postgresql() {
    if command_exists pg_isready && pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
        success "PostgreSQL is running on port 5432"
        return
    fi

    log "Setting up PostgreSQL..."
    brew install postgresql@16

    # Start PostgreSQL service
    brew services start postgresql@16

    # Wait for PostgreSQL to start
    local retries=30
    while [ $retries -gt 0 ]; do
        if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
            success "PostgreSQL is now running on port 5432"
            return
        fi
        sleep 1
        retries=$((retries - 1))
    done

    error "PostgreSQL failed to start"
    exit 1
}

# Setup database and user
setup_database() {
    log "Setting up rag_demo_db database..."

    # Check if database already exists
    if psql -h localhost -p 5432 -U postgres -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw rag_demo_db; then
        success "Database rag_demo_db already exists"
        return
    fi

    # Create database and user
    psql -h localhost -p 5432 -U postgres -c "CREATE DATABASE rag_demo_db;" 2>/dev/null || true
    psql -h localhost -p 5432 -U postgres -c "CREATE USER rag_user WITH PASSWORD 'password';" 2>/dev/null || true
    psql -h localhost -p 5432 -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE rag_demo_db TO rag_user;" 2>/dev/null || true

    success "Database rag_demo_db created with user rag_user"
}

# Setup backend dependencies
setup_backend() {
    log "Setting up backend..."
    cd "$PROJECT_ROOT/backend"

    if [ -d "node_modules" ]; then
        success "Backend dependencies already installed"
    else
        log "Installing backend dependencies..."
        bun install
        success "Backend dependencies installed"
    fi

    # Generate Prisma client if schema exists
    if [ -f "prisma/schema.prisma" ]; then
        log "Generating Prisma client..."
        bunx prisma generate
        success "Prisma client generated"

        log "Running Prisma migrations..."
        bunx prisma migrate dev --name init 2>/dev/null || bunx prisma migrate deploy 2>/dev/null || warning "No migrations to run"
    fi
}

# Setup MCP server dependencies
setup_mcp_server() {
    log "Setting up MCP server..."
    cd "$PROJECT_ROOT/mcp-server"

    if [ -d "node_modules" ]; then
        success "MCP server dependencies already installed"
    else
        log "Installing MCP server dependencies..."
        bun install
        success "MCP server dependencies installed"
    fi
}

# Setup frontend dependencies
setup_frontend() {
    log "Setting up frontend..."
    cd "$PROJECT_ROOT/frontend"

    if [ -d "node_modules" ]; then
        success "Frontend dependencies already installed"
    else
        log "Installing frontend dependencies..."
        bun install
        success "Frontend dependencies installed"
    fi
}

# Main setup function
main() {
    log "Starting RAG Demo application bootstrap..."

    check_brew
    check_bun
    setup_postgresql
    setup_database
    setup_backend
    setup_mcp_server
    setup_frontend

    success "Bootstrap completed successfully!"
    echo ""
    echo "To start the application:"
    echo "  Backend:    cd backend && bun run dev"
    echo "  MCP Server: cd mcp-server && bun run dev"
    echo "  Frontend:   cd frontend && bun run dev"
    echo ""
    echo "Default ports:"
    echo "  Backend:    http://localhost:3000"
    echo "  MCP Server: http://localhost:3001"
    echo "  Frontend:   http://localhost:5173"
    echo ""
    echo "Database: PostgreSQL on localhost:5432 (rag_demo_db)"
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
