---
trigger: always_on
---

# Infrastructure Logging Rule (Adapters / Repositories / External Integrations)

## Purpose

This rule enforces **centralized logging behavior** across all outbound integrations (APIs, MongoDB, Redis, Engines, Messaging, OCR, Zen Engine, Service Bus, etc.) ensuring observability, traceability, and standardized error handling.

All infrastructure outbound adapters MUST use the shared logging utilities located in:

```
commons/http-logger/httpLogger.ts
commons/logger/*
```

Two standardized helpers must be used:

* `httpLogger()` → HTTP / REST integrations
* `internalLogger()` → Engines, Mongo, Redis, Messaging, OCR, internal integrations

---

# Scope

This rule applies ONLY to:

* outbound adapters
* repository implementations
* external service clients
* engine adapters
* messaging publishers
* persistence adapters

Controllers, UseCases, and Domain **must NOT implement integration logs**.

---

# Mandatory Logging Rules

## 1. HTTP / External API Calls

All outbound HTTP calls MUST use:

```
httpLogger(logger, ...)
```

Example:

```
this.httpService.post(...)
  .pipe(
     httpLogger(
        this.logger,
        false,
        processId,
        document,
        requestBody,
        headers,
        url
     )
  )
```

This ensures:

* response logging
* request logging
* automatic error capture
* standardized HttpException wrapping
* automatic log level based on status code

---

## 2. Internal Integrations (Mongo / Redis / Zen Engine / OCR / Service Bus / Rules Engines)

All internal integrations MUST use:

```
internalLogger(logger, ...)
```

Example:

```
return someObservable.pipe(
  internalLogger(
     this.logger,
     true,
     processId,
     document,
     payload,
     headers,
     'zen-engine-evaluation'
  )
);
```

This ensures:

* automatic result validation
* NotFoundException when result is empty
* standardized logging structure
* automatic error-level handling
* clean response unwrapping

---

## 3. Database Operations (Persistence Repositories)

Repositories performing persistence must:

* declare a class Logger
* log critical identifiers before persistence
* capture validation errors
* throw controlled exceptions

Example:

```
private readonly logger = new Logger(ClassName.name + ' operation');

this.logger.debug(`document ${documentNumber}`);
```

Error handling:

```
catch (error) {
   this.logger.error(error.message);
   throw new BadRequestException(...);
}
```

---

## 4. Messaging Integrations (Kafka / ServiceBus / Events)

Publishers must:

* log event name
* log correlationId / processId
* log masked payload or payload hash

---

## 5. Logging Placement Rule

Logging must exist only in:

```
infrastructure/adapters/outbound/**
```

Never inside:

```
domain/**
application/**
controllers/**
```

---

# Generator Enforcement Rule

When generating an outbound adapter or repository:

1. Automatically inject `Logger`
2. Use `httpLogger` for HTTP integrations
3. Use `internalLogger` for internal integrations (Mongo, Redis, Engines, Messaging)
4. Add debug log for main identifiers
5. Add error log inside try/catch blocks
6. Never create ad-hoc log systems
7. Always reuse commons logger utilities

---

# Injection Template

```
private readonly logger = new Logger(ClassName.name + ' operation');
```

---

# Final Instruction for Generator

Whenever an adapter or repository is generated:

* Add Logger automatically
* Use `httpLogger` for HTTP integrations
* Use `internalLogger` for engines, persistence, messaging and internal services
* Log critical identifiers
* Capture and log integration errors
* Never implement logs inside domain or application layers
