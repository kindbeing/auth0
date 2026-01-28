# Multi-Tenant RAG with FGA

## Goal
Prove secure multi-tenant AI agent with Auth0 FGA-enforced data isolation.

## Architecture

**Frontend (React + Vite)**
- Auth0 login
- Chat interface
- Document list (shows user's accessible docs)

**Backend (Express + TS)**
- Auth0 JWT middleware
- LangChain agent
- MCP client

**MCP Server (Node + TS)**
- Tool: `query_user_data`
- JWT validation (aud, azp, iat/exp, RS256, scopes)
- FGA filtering before data access
- Scope: `tool:query_data`

## Data Setup

**Documents:**
- Doc 1: "Q3 Sales Report" (Alice only)
- Doc 2: "Company Handbook" (Alice + Bob)
- Doc 3: "HR Policy" (Bob only)

**FGA Relationships:**
```
user:alice viewer doc:1
user:alice viewer doc:2
user:bob viewer doc:2
user:bob viewer doc:3
```

## Demo Flow

**Alice queries "Q3 report":**
```
FE → BE (alice token) → MCP (validates token)
                         ↓ FGA: alice sees [1,2]
                         ↓ Returns Doc 1
```

**Bob queries "Q3 report":**
```
FE → BE (bob token) → MCP (validates token)
                      ↓ FGA: bob sees [2,3]
                      ↓ Returns "No access"
```

## Stack
- Bun + TypeScript
- React + Auth0 React SDK
- Express + @auth0/express-oauth2-jwt-bearer
- Prisma (PostgreSQL)
- Auth0 FGA SDK
- LangChain (optional)
- MCP SDK

## File Structure
demo-app/
├── packages/
│   ├── frontend/
│   │   ├── src/
│   │   │   ├── components/
│   │   │   │   ├── LoginButton.tsx
│   │   │   │   ├── ChatInterface.tsx
│   │   │   │   └── DocumentList.tsx
│   │   │   ├── hooks/
│   │   │   │   └── useAuth0.ts
│   │   │   ├── App.tsx
│   │   │   └── main.tsx
│   │   ├── package.json
│   │   └── vite.config.ts
│   │
│   ├── backend/
│   │   ├── src/
│   │   │   ├── routes/
│   │   │   │   ├── chat.ts
│   │   │   │   └── documents.ts
│   │   │   ├── middleware/
│   │   │   │   └── auth.ts
│   │   │   ├── services/
│   │   │   │   ├── agent.ts
│   │   │   │   └── mcp-client.ts
│   │   │   ├── prisma/
│   │   │   │   ├── schema.prisma
│   │   │   │   └── migrations/
│   │   │   └── index.ts
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   └── mcp-server/
│       ├── src/
│       │   ├── middleware/
│       │   │   └── auth.ts
│       │   ├── tools/
│       │   │   └── query-data.ts
│       │   ├── services/
│       │   │   ├── fga.ts
│       │   │   └── retrieval.ts
│       │   ├── env.ts
│       │   ├── server.ts
│       │   └── index.ts
│       ├── specs/
│       │   ├── auth.spec.ts
│       │   └── server.spec.ts
│       ├── package.json
│       └── tsconfig.json
│
├── scripts/
│   ├── seed-documents.ts
│   └── setup-fga.ts
│
├── package.json (workspace root)
├── turbo.json
└── README.md