#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Info function
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Kill process on specific port
kill_port() {
    local port=$1
    local name=$2

    # Find process using the port
    local pid=$(lsof -ti :$port 2>/dev/null)

    if [ -n "$pid" ]; then
        log "Killing $name process on port $port (PID: $pid)..."
        kill -TERM $pid 2>/dev/null || kill -KILL $pid 2>/dev/null || true

        # Wait a bit for graceful shutdown
        sleep 2

        # Check if still running
        if lsof -ti :$port >/dev/null 2>&1; then
            warning "$name process still running on port $port"
        else
            success "$name process stopped on port $port"
        fi
    else
        info "No $name process found on port $port"
    fi
}

# Check PostgreSQL status
check_postgresql() {
    log "Checking PostgreSQL status..."

    if command -v pg_isready >/dev/null 2>&1; then
        if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
            success "PostgreSQL is running on port 5432"

            # Try to connect to the database
            if psql -h localhost -p 5432 -U postgres -d rag_demo_db -c "SELECT 1;" >/dev/null 2>&1; then
                success "Database 'rag_demo_db' is accessible"
            else
                warning "Cannot connect to database 'rag_demo_db' (may need authentication)"
            fi
        else
            error "PostgreSQL is not responding on port 5432"
        fi
    else
        warning "pg_isready command not found - cannot check PostgreSQL status"
    fi
}

# Kill Backend (port 3000)
kill_backend() {
    kill_port 3000 "Backend"
}

# Kill MCP Server (port 3001)
kill_mcp_server() {
    kill_port 3001 "MCP Server"
}

# Kill Vite frontend (port 5173)
kill_frontend() {
    kill_port 5173 "Vite Frontend"
}

# Main shutdown function
main() {
    log "Starting RAG Demo application shutdown..."

    # Kill application processes
    kill_backend
    kill_mcp_server
    kill_frontend

    echo ""

    # Report on persistent services
    check_postgresql

    echo ""
    success "Application shutdown completed!"
    echo ""
    info "PostgreSQL remains active for data persistence."
    echo "To stop PostgreSQL completely, run:"
    echo "  brew services stop postgresql@16"
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
