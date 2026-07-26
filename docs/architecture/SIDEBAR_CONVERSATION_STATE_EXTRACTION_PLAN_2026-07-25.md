# Sidebar Conversation State Extraction Plan — 2026-07-25

## Corridor Objective

Move the existing authoritative Matilda conversation selector from the workspace header into the Headquarters sidebar without duplicating conversation state or changing backend conversation behavior.

## Verified Current State

- `MatildaChatWorkspace` currently owns:
  - project-scoped conversation loading
  - active conversation identity
  - conversation creation
  - conversation switching
  - active conversation history
  - message submission
- `NavigationRegion` currently renders static shell placeholders.
- The backend already provides project-scoped conversation listing, creation, activation, and history retrieval.
- The existing shell CSS is intentionally structural and does not yet constitute a finished visual design system.

## Architectural Rule

The sidebar and Matilda workspace must not maintain separate conversation state.

A single shared client-side conversation controller must expose:

- current project conversation list
- active conversation identifier
- active conversation turns
- loading state
- switching state
- submission state
- request error
- create-conversation action
- switch-conversation action
- send-message action

The authoritative backend remains unchanged.

## Target Ownership

ProjectContextProvider
        |
        v
MatildaConversationProvider
        |
        +--> NavigationRegion
        |      - renders real project-scoped conversations
        |      - selects the active conversation
        |      - creates a new conversation
        |
        +--> MatildaChatWorkspace
               - renders the active conversation
               - submits messages
               - no longer owns the conversation selector

## First Implementation Slice

The first implementation slice will only extract the existing conversation lifecycle into a shared provider.

It will not yet redesign the full sidebar.

Authorized changes:

- add `MatildaConversationProvider`
- add `useMatildaConversation`
- wrap the shell with the provider inside the existing project-context boundary
- migrate `MatildaChatWorkspace` to the shared controller
- preserve the existing workspace conversation selector temporarily
- preserve all backend routes and persistence behavior
- preserve current visual output as closely as possible

## Validation Gate

Before moving the selector into the sidebar, the extraction must prove:

1. Existing conversations still load for the active project.
2. Project switching restores the correct project-scoped conversation.
3. Existing conversation switching still restores the correct history.
4. New conversation creation still works.
5. Message submission still appends the persisted authoritative turn.
6. Client build passes.
7. Conversation lineage test passes.
8. No unrelated files change.

Only after this stable extraction is validated may the next slice move the selector into `NavigationRegion`.
