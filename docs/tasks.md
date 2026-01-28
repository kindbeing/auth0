# Implementation Tasks

> **Last Updated**: 2026-01-28

## Phase 1: Foundation & Security

### 1.1 Monorepo Setup
- [ ] Initialize Bun workspace (`package.json`, `turbo.json`)
- [ ] Create package structure: `frontend/`, `backend/`, `mcp-server/`
- [ ] Configure TypeScript for each package
- [ ] Add `.env.example` with Auth0 config template

### 1.2 MCP Server - Auth & Tests
- [ ] Port `reference/auth.ts` → `packages/mcp-server/src/middleware/auth.ts`
- [ ] Port `reference/specs/auth.spec.ts` → `packages/mcp-server/specs/auth.spec.ts`
- [ ] Port `reference/specs/server.spec.ts` → `packages/mcp-server/specs/server.spec.ts`
- [ ] Create `env.ts` (MCP_SERVER_URL, AUTHORIZATION_SERVER_URL)
- [ ] Verify all auth tests pass

### 1.3 FGA Integration (TDD)
- [ ] **Write failing test**: `specs/fga.integration.spec.ts` - Bob accessing Alice's Doc 1
- [ ] Implement `services/fga.ts` (Auth0 FGA client, check permissions)
- [ ] Implement `services/retrieval.ts` (document query with FGA filter)
- [ ] Implement `tools/query-data.ts` (MCP tool with FGA enforcement)
- [ ] **Verify test passes**: Bob gets "No access", Alice gets Doc 1

## Phase 2: Backend & Data

### 2.1 Database
- [ ] Create `backend/src/prisma/schema.prisma` (Document model)
- [ ] Run migration
- [ ] Create `scripts/seed-documents.ts` (Doc 1, 2, 3)
- [ ] Create `scripts/setup-fga.ts` (alice/bob relationships)

### 2.2 Express Backend
- [ ] Implement `middleware/auth.ts` (Auth0 JWT validation)
- [ ] Implement `services/mcp-client.ts` (MCP protocol client)
- [ ] Implement `services/agent.ts` (LangChain orchestration - optional)
- [ ] Implement `routes/chat.ts` (POST /chat → MCP)
- [ ] Implement `routes/documents.ts` (GET /documents → user's docs via FGA)
- [ ] Create `index.ts` (Express server)

## Phase 3: Frontend

### 3.1 Auth & UI
- [ ] Implement `hooks/useAuth0.ts` (Auth0 React SDK wrapper)
- [ ] Implement `components/LoginButton.tsx`
- [ ] Implement `components/DocumentList.tsx` (fetch from /documents)
- [ ] Implement `components/ChatInterface.tsx` (message UI)
- [ ] Implement `App.tsx` (protected routes)
- [ ] Configure `vite.config.ts` (proxy to backend)

## Phase 4: Integration & Demo

### 4.1 End-to-End Testing
- [ ] Test Alice login → sees Doc 1, 2
- [ ] Test Bob login → sees Doc 2, 3
- [ ] Test Alice queries "Q3 report" → gets Doc 1 content
- [ ] Test Bob queries "Q3 report" → gets "No access"
- [ ] Test both query "Company Handbook" → both get Doc 2

### 4.2 Documentation
- [ ] Update README.md (setup instructions, Auth0 config)
- [ ] Document demo flow with screenshots
- [ ] Add architecture diagram

## Status Legend
- [ ] TODO
- [x] DONE
- ⚠️ BLOCKED

## Dependencies
- **Phase 2** requires **Phase 1.3** (FGA service)
- **Phase 3** requires **Phase 2.2** (Backend routes)
- **Phase 4** requires all previous phases
