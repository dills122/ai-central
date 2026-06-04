---
title: Payload CMS Overview
description: Core principles and quick reference for Payload CMS development
tags: [payload, overview, quickstart]
---

# Payload CMS Development Rules

When working with Payload projects, follow these rules:

## Core Principles

1. Use TypeScript with proper Payload types.
2. Treat access control and Local API usage as security-critical.
3. Run type generation after schema changes.
4. Pass `req` to nested operations in hooks when transaction context matters.
5. Be explicit about `overrideAccess` behavior.

## Project Structure

```txt
src/
  app/
  collections/
  globals/
  components/
  hooks/
  access/
  payload.config.ts
```

## Quick Reference

| Task | Default Pattern |
| --- | --- |
| Restrict by user | Access control with query constraints |
| Local API user operations | Pass `user` and set `overrideAccess: false` when needed |
| Draft/publish | `versions: { drafts: true }` |
| Computed fields | `virtual: true` with `afterRead` |
| Conditional fields | `admin.condition` |
| Prevent hook loops | `req.context` guard |
| Cascading deletes | `beforeDelete` hook |
| Custom routes | Collection custom endpoints |
