# 15. Context Engineering and AI API Design

Supplemental practice questions based on current AI engineering documentation and production practices. These questions are not part of the original source repository, and this collection does not claim to rank interview frequency. Evaluation, RAG assessment, LLM-as-a-judge, online/offline evaluation, and related testing are already covered in depth in topics 09 and 13, so they are not repeated here. Use the space after each heading to draft an answer.

## Context Engineering

## How do you distinguish context engineering from prompt engineering, and what additional responsibilities does context engineering introduce in a production application?

**Answer:**

<br><br><br>

## When context contains system instructions, the current request, retrieved evidence, conversation history, memory, and tool results, how do you prioritize sources and handle conflicting or stale information?

**Answer:**

<br><br><br>

## How do you allocate a fixed context-token budget across instructions, evidence, and conversation state without allowing low-value content to displace critical information?

**Answer:**

<br><br><br>

## How would you organize cacheable and dynamic prompt content in a multi-tenant application so cache reuse does not expose one user's data to another or serve stale context?

**Answer:**

<br><br><br>

## AI API Contracts

## How would you design a durable asynchronous API for a long-running AI task, including job state, polling or callbacks, cancellation, expiry, and safe client retries?

**Answer:**

<br><br><br>

## How would you evolve a client-facing AI API when the underlying provider or model changes, while preserving compatibility and exposing only capabilities clients can rely on?

**Answer:**

<br><br><br>

## A client retries a request after a timeout, but the original request may still be running and may trigger a tool with side effects. How would you prevent duplicate actions and communicate the request's outcome?

**Answer:**

<br><br><br>

## For a streaming AI API, what should happen when a client disconnects after receiving partial output, and how should the API communicate cancellation versus completed generation?

**Answer:**

<br><br><br>

## AI Observability and Privacy

## What should an end-to-end GenAI trace record across context assembly, retrieval, model calls, and tools, and how can it remain useful for debugging without retaining sensitive prompt or response content?

**Answer:**

<br><br><br>

## Research references

- [Anthropic: Effective context engineering for AI agents](https://www.anthropic.com/research/effective-context-engineering-for-ai-agents)
- [OpenAI: Prompt caching](https://developers.openai.com/api/docs/guides/prompt-caching)
- [OpenAI: Production best practices](https://developers.openai.com/api/docs/guides/production-best-practices)
- [OpenTelemetry GenAI semantic conventions](https://github.com/open-telemetry/semantic-conventions-genai)
