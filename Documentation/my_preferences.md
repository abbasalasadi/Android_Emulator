# My Project Preferences

This file defines my general project preferences and working conventions. It is intended as a reusable guideline for GPT across any project, not for one specific project only.

These preferences should be treated as default expectations unless I explicitly override them for a particular project.

## 1. General Principles

### 1.1 Security first
Security has priority over convenience.

- Treat backend validation and backend warnings as the source of truth.
- Do not trust client-side validation for security or business-rule enforcement.
- Frontend may provide tips, hints, formatting guidance, and user-friendly input help, but must not be the authority for warnings, restrictions, or final validation.
- Prefer secure defaults in authentication, authorization, input handling, file handling, and configuration.
- Avoid exposing internal details in user-facing errors.

### 1.2 Maintainability over cleverness
Prefer readable, debuggable, maintainable solutions over clever or overly compact implementations.

- Code should be easy to trace and modify later.
- Avoid unnecessary abstraction.
- Avoid hidden behavior and surprising shortcuts.
- Choose consistency over novelty.

### 1.3 Explicit decisions early
Whenever the project includes multiple possible choices, decide the preferred option early and use it consistently.

Examples include:
- frontend framework
- routing approach
- state management approach
- logger format
- migration tool
- environment-loading strategy
- API response format
- Docker strategy

Do not leave major implementation decisions vague for too long.

## 2. Project Structure

### 2.1 Root `scripts/` directory
Keep a `scripts/` folder in the project root for reusable operational scripts.

- Use it for setup, build, run, check, deploy, backup, restore, and other operational helpers.
- Prefer moving complex shell logic into scripts instead of overcrowding the `Makefile`.
- Keep scripts reusable and readable.

### 2.2 Root `var/` directory
Keep a `var/` folder in the project root for runtime-generated files that should not live among source files.

Examples:
- database files
- logs
- temporary files
- runtime caches
- generated runtime artifacts

Runtime files should not pollute source-code directories.

### 2.3 Logs under `var/logs/`
Keep logs in `var/logs/`.

Default preference:
- backend log file
- frontend log file

When the project uses Go and JavaScript, the default preferred names are:
- `var/logs/go.log`
- `var/logs/js.log`

For other stacks, equivalent clear names are acceptable as long as backend and frontend logs remain separate and predictable.

### 2.4 Predictable folder organization
Use a clean, scalable, and readable folder structure from the start.

- Group files by responsibility.
- Avoid structure that grows randomly over time.
- Reorganize early if the layout becomes confusing.
- Keep the folder layout easy to understand for future debugging and collaboration.

### 2.5 Descriptive naming
Prefer descriptive names for files, folders, functions, variables, modules, and components.

Avoid vague names such as:
- `part1`
- `part2`
- `temp`
- `misc`
- `helpers2`
- `newfile`

Names should communicate responsibility clearly.

## 3. Automation and Commands

### 3.1 `Makefile` as the main entry point
Use a `Makefile` as the main developer entry point for common tasks.

It should provide useful commands for:
- local development
- Docker workflows
- deployment workflows
- checks and maintenance

### 3.2 Group command sections clearly
Organize Makefile commands into clear sections such as:
- Local
- Docker
- Deploy

Additional sections are fine when useful, for example:
- Setup
- Test
- Logs
- Database
- Cleanup

### 3.3 Dynamic help output
The Makefile `help` command should be generated from command comments or phony metadata, not hard-coded manually.

The help output should stay accurate automatically when commands are added or changed.

### 3.4 Use `.PHONY` consistently
Mark non-file targets as `.PHONY`.

This avoids accidental collisions with files or directories that share the same name as a command.

### 3.5 Explicit command context
Whenever commands are shown or documented, clearly label the execution context.

Examples:
- LOCAL
- VM
- DOCKER
- CONTAINER
- CI

Avoid ambiguous commands that assume context without stating it.

## 4. Logging and Observability

### 4.1 Professional logger utilities
Create proper logging utilities for backend and frontend.

Examples:
- `logger.go`
- `logger.js`

Logging should be structured and informative.

### 4.2 Log content expectations
Logs should include useful operational details whenever relevant, such as:
- timestamp
- log level
- operation or action name
- relevant IDs or identifiers
- request or event context
- success or failure result
- error details with context

Logs should help reconstruct the execution flow.

### 4.3 Meaningful logging in application flow
Add logging to important functions and transitions throughout the application.

Especially log:
- startup and shutdown
- request handling
- authentication events
- database operations
- file operations
- external calls
- major state changes
- validation failures
- unexpected branches
- error paths

Do not add useless noise. Log enough to make debugging practical without drowning the important signals.

### 4.4 Logs must support debugging
The log system should make it easy to locate where and why an operation stopped working.

Logging should support tracing the full operation flow across backend and frontend when needed.

## 5. Configuration

### 5.1 Centralized configuration modules
When configuration files are needed, centralize configuration in dedicated config modules.

Examples:
- `config/config.go`
- `js/config/config.js`

Avoid scattering configuration logic and magic values across the codebase.

### 5.2 Defaults first, overrides second
Define safe and sensible default values at the beginning of the config files.

Then allow those defaults to be overridden by:
- environment variables
- JSON files
- equivalent external configuration sources

The configuration loading order should be explicit and predictable.

### 5.3 Environment file preference
My preferred environment file convention is:
- `.env` for local development
- `.env.vm` for deployed VM environments

Because I mainly use private repositories, I do not require `.env.example` or `.env.vm.example` unless a project explicitly needs them.

### 5.4 Avoid hard-coded config where configuration is expected
If a value is environment-dependent, operational, or likely to vary across environments, it should be configurable rather than hard-coded throughout the application.

## 6. Architecture and Separation of Responsibilities

### 6.1 Clear separation of responsibilities
Keep a clear separation between major responsibilities.

Typical separation should distinguish between:
- routing / transport layer
- handlers / controllers
- services / business logic
- repositories / data access
- configuration
- utilities
- frontend presentation
- frontend state management

Avoid mixing business logic, transport logic, persistence logic, and presentation logic in the same place.

### 6.2 Stable contracts between backend and frontend
Backend and frontend contracts should be explicit and consistent.

This includes:
- route naming
- payload shapes
- response formats
- error formats
- field naming conventions
- status handling

Avoid ad hoc API behavior.

### 6.3 Standard response and error shape
Define consistent response and error patterns early.

Use predictable formats so the frontend can handle success and failure consistently.

### 6.4 Database changes through migrations
All database schema changes should go through migrations, not through manual database editing.

Migration files should be:
- ordered
- traceable
- reversible where practical
- stored in a dedicated migrations directory

### 6.5 Incremental and testable implementation stages
Prefer implementation in clear phases or stages.

- Each stage should have a clear goal.
- Each stage should be testable.
- Each stage should be stable before moving to the next.
- Avoid large unfocused rewrites whenever possible.

## 7. Validation, Errors, and User-Facing Messages

### 7.1 Backend is the authority for validation and warnings
All authoritative warnings, restrictions, and validations should come from the backend.

Frontend may assist the user with tips, but backend determines final validity.

### 7.2 Proper error handling
Proper error handling must be followed everywhere.

This means:
- do not swallow errors silently
- do not ignore returned errors
- return or log errors with useful context
- fail early for invalid states when appropriate
- avoid vague generic error handling
- avoid hiding root causes during debugging

### 7.3 Safe and clear user-facing errors
Messages shown to users should be:
- clear
- professional
- understandable
- safe

Do not expose sensitive internals, stack traces, secrets, or unnecessary implementation details in user-facing responses.

### 7.4 Detailed internal error context
Internal logs and developer-facing diagnostics may contain deeper technical context, as long as they remain appropriately protected.

## 8. Runtime and Deployment Preferences

### 8.1 Projects should be easy to run
Project setup and execution should be straightforward.

Common operations should be easy to find and run through:
- Makefile commands
- scripts
- clear operational structure

### 8.2 Local and deployment workflows should both be considered
I usually care about both local development and real deployment, so projects should be designed with both in mind from the beginning.

This includes:
- environment handling
- build commands
- runtime directories
- logging
- ports
- deployment scripts

### 8.3 Online deployment mindset
My projects are usually intended to be deployable online, so decisions should not assume a local-only environment.

## 9. Working Style Preferences for GPT

When helping me on a project, GPT should generally follow these preferences:

- preserve a clean project structure
- prefer descriptive naming
- place runtime artifacts under `var/`
- place scripts under `scripts/`
- use the `Makefile` as the command entry point
- keep command help dynamic, not hard-coded
- separate backend and frontend logs
- design meaningful logger utilities
- include logging in important operational paths
- define defaults first in config files, then override from env or config sources
- prefer `.env` and `.env.vm` for my normal workflow
- prioritize backend-driven validation and warnings
- maintain strong error handling
- keep architecture responsibilities separated
- keep API contracts explicit and consistent
- use migrations for DB changes
- prefer stage-based implementation
- prefer secure, maintainable, production-minded solutions

## 9.1 Batch baseline continuity

When GPT provides implementation batches across one or more chats, GPT should preserve baseline continuity explicitly.

- At the beginning of each chat, GPT should clearly state that the current batch is based on the **latest provided batch**.
- GPT should treat the **latest provided batch** as the working baseline even if I have not yet tested or explicitly accepted it.
- At the end of each chat, GPT should clearly state that the **next batch** will be based on the **batch provided in that chat**.
- GPT should never prepare a new batch from an older project snapshot when a newer provided batch already exists.

## 10. Override Rule

These preferences are my default guidelines.

If I explicitly request a different structure, naming scheme, workflow, or convention for a particular project, then that project-specific instruction overrides this file.

This includes stricter batch-baseline rules for a specific project when I define them.

