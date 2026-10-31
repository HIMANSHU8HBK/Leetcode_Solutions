# OpenAI — AI / GenAI Engineer Interview Bank

**Research snapshot:** October 31, 2026  
**Target:** AI / GenAI engineers building model-backed products, API integrations, agent workflows, and production services. OpenAI roles vary significantly across product engineering, platform/API engineering, applied AI, infrastructure, and research engineering; this guide is a shared AI product-engineering preparation bank, not a substitute for the specific job description.

OpenAI does not publish a definitive AI Engineer interview loop or public bank of role-specific interview questions in the sources reviewed for this guide. The questions below are original practice prompts informed by OpenAI's public product/API documentation, careers material, and general engineering responsibilities. They are **not represented as verbatim or guaranteed interview questions**.

## Research signals and confidence

### Officially documented

- OpenAI's careers material describes its mission, values, and operating principles, including humanity-first impact, humility, rigor, learning from new information, and shipping useful products. These are useful themes for preparing authentic project and behavioral examples, not evidence of an interview rubric.
- OpenAI's developer documentation recommends the Responses API for new integrations and describes tools, multi-turn state, multimodal inputs, streaming, agent runtimes, structured outputs, evals, production practices, and data controls.
- OpenAI's public safety material emphasizes testing, red-teaming, feedback from real-world use, human review in appropriate applications, and communicating model limitations.

### Publicly reported material

A public interview-notes repository labels its OpenAI content as reconstructed from candidate experiences and includes coding/system-design preparation material. This is self-published, anecdotal evidence; it does not establish a current or universal hiring loop, and it may mix roles and levels. The repository has a custom license, so this guide does not reproduce its problem statements, solutions, or code.

### Confidence labels

- **Official context:** supported by OpenAI public careers or technical documentation.
- **Reported signal:** a third-party, candidate-reconstruction source; anecdotal and not official.
- **Practice prompt:** an original question synthesized from the target engineering scope and public technical documentation.

## How to use this bank

1. **Start from the job description.** Identify the expected balance of product engineering, API/platform work, model integration, distributed systems, and research collaboration.
2. **Prepare a project deep dive.** Be ready to explain your own decisions, implementation, impact, failure modes, and what you would change, without disclosing confidential information from another employer.
3. **Practice building in a constrained setting.** Clarify requirements, write correct code, test edge cases, and discuss reliability and operational trade-offs as you go.
4. **Design for user outcomes.** For system design, define success metrics and failure behavior before selecting a model or API.
5. **Treat safety and privacy as engineering properties.** Identify trust boundaries, data retention, permissions, abuse paths, and human escalation.
6. Ask the recruiter which rounds, level expectations, coding environment, and team-specific material apply. Do not infer the loop from anecdotes online.

## A. Product judgment and role understanding

### 1. [Practice prompt] What makes an AI product genuinely useful to users rather than merely an impressive model demo? How would you validate that distinction?

**Answer:**

A useful AI product reliably helps a defined user complete a real task better than the existing workflow. A demo can look impressive on a few curated examples, but a product must work across representative inputs, handle uncertainty and failure, fit into users' workflows, and justify its latency, cost, and risk.

I would start by observing users and defining a task-level outcome—for example, successful resolution, time saved without lower accuracy, or fewer steps to complete a task. I would establish a baseline and create an evaluation set that reflects real traffic, edge cases, and important user segments. Then I would compare the AI feature with the current process or a simpler non-AI alternative using offline tests and a controlled pilot.

I would monitor task completion, correction/abandonment rates, quality, latency, cost per successful task, and safety incidents. I would also interview users to understand why outcomes changed. The feature is valuable when measured user outcomes improve sustainably and failure cases are appropriately handled—not merely when people say the model's answers are impressive.

### 2. [Practice prompt] A product request says, “Add an agent that can handle customer support.” What questions would you ask to define the user, tasks, allowed actions, risk, success metrics, and non-AI alternatives?

**Answer:**

I would clarify who the user is—customer, support agent, or both—and which support tasks are in scope. I would ask for common request categories, current workflows and pain points, systems of record, available knowledge sources, volume, languages, and escalation paths. I would distinguish answering questions from taking actions such as changing an account or issuing a refund.

For each task, I would define what counts as success, what evidence is required, what the agent may read or change, and what must require human approval. I would assess the impact of a wrong answer or action, privacy and regulatory constraints, abuse scenarios, identity/authorization, and acceptable latency and cost. I would set success measures such as resolution quality, time to resolution, escalation rate, customer satisfaction, repeat contacts, and safety/error rates.

Before accepting the agent proposal, I would compare it with a better search experience, guided forms, rules, macros, or a single RAG answer. I would start with a narrow, low-risk task and read-only access where possible, build representative evaluations, and expand autonomy only when evidence supports it. A predictable workflow should remain deterministic rather than being made agentic for its own sake.

### 3. [Practice prompt] How would you decide whether a feature should use a model API, a deterministic workflow, retrieval, fine-tuning, or a hybrid approach?

**Answer:**

I would begin with the task's variability, data needs, error cost, and operational constraints. If the task is a stable set of rules or state transitions, a deterministic workflow is usually easier to test and safer. If users need current facts from private or changing content, retrieval can supply relevant evidence to a model; if they only need to find a passage, search alone may be sufficient. A model API is useful when language understanding or generation adds value, while fine-tuning may help teach a stable behavior, format, or domain pattern when suitable examples and evaluation data exist.

I would consider a hybrid when it combines the strengths cleanly: for example, deterministic authorization and business rules, retrieval for current facts, and a model to synthesize a user-friendly response. The model should not be responsible for access control or irreversible decisions.

I would compare the smallest plausible alternatives on a representative dataset using task success, correctness, grounding, safety, latency, cost, maintainability, and failure recovery. Fine-tuning is not a substitute for access to changing facts, and an agent is not justified unless the task needs flexible multi-step tool use. I would choose the simplest approach that meets the requirements and revisit it as evidence changes.

### 4. [Practice prompt] Describe how you would take an AI capability from prototype to a product users can depend on. What evidence would you require at each stage?

**Answer:**

I would move through evidence gates rather than treating a successful prototype as a launch signal:

1. **Problem validation:** Confirm the target user and workflow, record the current baseline, and define the expected user benefit and unacceptable failures.
2. **Feasibility prototype:** Test the smallest end-to-end slice on representative examples. Compare against a non-AI baseline and identify data, model, and dependency limitations.
3. **Evaluation:** Build a versioned test set with normal, edge, adversarial, and high-impact cases. Measure task quality, grounding, safety, latency, and cost; use human review for nuanced judgments.
4. **Production engineering:** Add authentication, authorization, input/output validation, bounded retries, timeouts, rate limits, observability, privacy controls, and clear fallback behavior. Test failure and recovery paths.
5. **Limited rollout:** Canary or pilot with a defined population. Compare user outcomes against the baseline, monitor guardrails and segments, gather feedback, and retain a rollback plan.
6. **Ongoing operation:** Set owners and SLOs, review incidents and drift, update regression tests, and re-evaluate after model, prompt, data, or policy changes.

I would expand only when each gate meets pre-agreed criteria. The evidence should include actual task outcomes and safe behavior, not just model-based scores or a handful of favorable demos.

### 5. [Practice prompt] How do you make a product decision when model quality, latency, cost, user experience, and safety requirements conflict?

**Answer:**

I would first distinguish hard constraints from optimizable goals. Safety, privacy, authorization, and legal requirements are guardrails, not variables to trade away for engagement or latency. Within those boundaries, I would quantify the user value and trade-offs for the specific task: for example, whether a slower but more accurate response is acceptable, or whether a smaller model is sufficient for common requests.

I would use a representative evaluation set and, where appropriate, controlled experiments to compare candidate designs across quality, task completion, latency percentiles, cost per successful task, user effort, and safety. I would segment by task risk and user group because an overall average can hide a critical failure slice. The UI can also make trade-offs explicit—for example, offering a fast answer with citations or a deeper analysis mode—provided users understand the difference.

I would recommend the option that meets safety and reliability gates while delivering the best measured user outcome within budget. If no option meets the requirements, I would narrow the scope, add human review, or delay launch rather than disguise an unacceptable trade-off as a model-quality issue.

### 6. [Practice prompt] OpenAI's careers material emphasizes humility and updating quickly. Tell me about a time new evidence changed your technical direction. What did you change and what happened?

**Answer:**

I would use a truthful example and show that I updated my view based on evidence rather than defending sunk cost:

“On **[project]**, I initially believed **[hypothesis or chosen approach]** because **[reason]**. We then observed **[new evidence: evaluation results, user behavior, an incident, or a technical constraint]**, which challenged that assumption. I checked the evidence by **[method]** and found **[what it showed and any uncertainty]**.

“I changed **[design, scope, model, data, or rollout plan]** and explained the trade-off to **[stakeholders]**. We validated the new direction with **[test or pilot]** and achieved **[specific, verifiable result]**. The experience changed how I now **[lesson or practice]**.”

I would be clear about my own contribution, acknowledge the cost of changing direction, and avoid inventing metrics. A strong answer demonstrates intellectual honesty, timely action, and learning—not merely that the new approach happened to succeed.

## B. OpenAI API integration and application engineering

### 7. [Practice prompt] For a new model-backed application, how would you choose between calling the Responses API directly, using an agent SDK/runtime, or implementing orchestration in your own service?

**Answer:**

I would choose based on how much orchestration the product needs and which layer should own state, policy, and execution. A direct API integration is attractive for a simple request/response or a small, application-controlled tool loop: it keeps the system explicit and gives the team control over authorization, state, retries, and observability. An agent SDK or runtime may be useful when the workflow needs managed multi-step execution, tool coordination, or durable/background work and the runtime's guarantees match the product requirements.

Application-owned orchestration is preferable when the workflow, data boundaries, compliance needs, or side-effect controls require precise behavior, or when the team needs deterministic state transitions and portability. It does mean owning more code and operational complexity.

I would compare each option against task complexity, state durability, latency, privacy/data retention, tool security, cancellation/retries, debugging, deployment constraints, cost, and lock-in. I would prototype the smallest viable path and test failures, not just the happy path. Regardless of framework, trusted application code must own authentication, authorization, tool permissions, validation, and confirmation for consequential actions.

### 8. [Practice prompt] How would you design a provider-facing adapter so application logic is stable across model versions while still exposing model-specific capabilities when needed?

**Answer:**

I would define an application-level interface around the capabilities the product actually needs—such as input content, structured output, streaming events, tool definitions/results, usage, refusal/error state, and cancellation—rather than attempting to normalize every provider feature. The adapter would translate stable application requests into provider-specific calls and convert responses into typed internal events/results.

I would keep model-specific capabilities explicit through capability discovery or typed extensions, not silently drop them into a lowest-common-denominator abstraction. For example, if one model supports a modality or tool mode another does not, routing should validate compatibility and either select a suitable model or return a clear unsupported-capability error.

Version model IDs, API behavior, prompts, and adapter mappings; maintain contract tests with recorded fixtures and integration tests against supported endpoints. Preserve provider request IDs and useful error codes for diagnosis while redacting sensitive data. Test streaming order, partial output, refusals, tool calls, timeouts, rate limits, and schema behavior across upgrades. The adapter should reduce accidental coupling but not hide meaningful model differences or prevent use of new capabilities.

### 9. [Practice prompt] A service is migrating from a message-oriented API integration to a response/item-oriented API. What behavior, state handling, tool flow, storage, and test compatibility would you verify?

**Answer:**

I would begin with a behavior inventory of the current integration: input roles and content parts, system/developer instructions, tool definitions and execution loop, conversation history, streaming events, structured outputs, refusals, usage accounting, errors, and data-retention assumptions. Then I would map each behavior to the new API's request/response and item/state model rather than translating fields mechanically.

I would decide whether conversation state remains application-managed or uses response chaining/server-side storage, considering privacy, retention, recovery, and cost. For tool use, verify that model-proposed calls are validated and executed by the application, results are associated with the right call, and the continuation semantics handle multiple or partial calls correctly. For streaming, update event parsing and client contracts to handle new event types, ordering, completion, cancellation, and errors.

I would use a compatibility layer or feature flag to migrate incrementally. Run contract, regression, and shadow tests on representative requests, comparing outputs, tool behavior, latency, tokens/cost, refusals, and failure paths. Avoid dual execution for side-effecting tools unless the shadow path is read-only. Roll out gradually, monitor differences, and retain rollback until the new path meets quality and operational gates.

### 10. [Practice prompt] How would you manage conversation state across requests? Compare client-managed history, response chaining, and server-side conversation storage in terms of privacy, reliability, and cost.

**Answer:**

I would choose the state model based on the product's continuity needs, privacy/retention rules, recovery requirements, and token cost:

- **Client-managed history:** The application stores and resends the needed history. This gives explicit control over what is retained and sent, and is portable, but requires careful token budgeting, integrity checks, and secure client/server storage. Do not trust client-supplied history as authorization or system policy.
- **Response chaining:** The application references a prior response to continue a conversation. This can reduce repeated history transfer and simplify continuity, but depends on provider state/retention semantics and may create portability or deletion considerations. Verify what context is retained and for how long.
- **Server-side conversation storage:** The application or a managed service persists conversation state keyed by an authenticated owner/tenant. This supports cross-device continuity and worker recovery, but adds storage, access-control, deletion, encryption, and operational responsibilities.

In all cases, persist only what is needed, scope state to the user/tenant, enforce retention and deletion, and keep tool results and side effects idempotent. Use explicit state versions, maximum history/token budgets, and summarization only when quality is validated. Test concurrent turns, retries, reconnects, tenant isolation, deletion, and recovery after failure. The model should receive the minimum context needed for the current task.

### 11. [Practice prompt] How would you stream model output to a web client while handling partial events, cancellation, backpressure, connection loss, and a final completion/error signal?

**Answer:**

I would expose a streaming endpoint using a well-defined event protocol, such as server-sent events or WebSockets, and translate provider events into stable application events: response started, text/content delta, tool status if exposed, completed, refused, or failed. The client must treat deltas as partial and append them safely; it should not assume each event is a complete sentence or structured object. Only mark the answer complete when receiving an explicit terminal event.

The server should propagate cancellation when the client disconnects or explicitly cancels, subject to provider capabilities, and stop downstream work where possible. Apply bounded buffers and backpressure so a slow client cannot cause unbounded memory growth; if the transport cannot keep up, pause reads or terminate cleanly with a resumable request/status mechanism. Include request IDs and sequence numbers if reconnect/resume is supported.

Handle connection loss as an uncertain state: either support reconnecting to a durable run/event stream, or tell the client the response may be incomplete and let it query status. Do not silently retry a side-effecting tool workflow. Emit sanitized errors and distinguish a provider failure from a completed answer. Test disconnects during generation, cancellation races, malformed/out-of-order events, slow consumers, empty output, refusals, and upstream errors.

### 12. [Practice prompt] A request times out at the application gateway, but the upstream model request may still be running. How do you design retries, request identity, cancellation, and cost accounting?

**Answer:**

I would assign an application request/run ID before calling the provider and persist the request state, provider request ID when available, deadline, and status. A gateway timeout does not prove that the upstream computation stopped, so I would not immediately issue an identical retry and risk duplicate cost or, for an agent, repeated tool actions.

If supported, propagate cancellation when the client or gateway deadline expires and record whether cancellation was acknowledged. Make retry decisions based on the operation's idempotency and known upstream state: a pure generation request might be retried under a bounded policy, while a workflow with side effects must first reconcile whether the action occurred. Use idempotency keys at the application/tool boundary; do not assume provider request IDs guarantee exactly-once execution.

Track each attempt separately under the parent request ID, including model, timestamps, tokens/usage if returned, timeout/cancel state, and estimated or billed cost. If the final usage is unknown, mark it unknown and reconcile with provider usage data rather than recording zero. Expose a clear client status—completed, still processing, cancelled, or outcome unknown—and support polling or resumption for long-running work.

### 13. [Practice prompt] How would you implement bounded retries for rate limits and transient provider failures without retrying non-retryable errors or creating a retry storm?

**Answer:**

I would classify errors first. Retry only transient conditions such as rate limits, selected server errors, or connection failures where the request outcome is safe to retry. Do not retry invalid requests, authentication/permission errors, policy refusals, or other permanent client errors. Respect provider retry guidance such as `Retry-After` when present.

Use exponential backoff with jitter, a small maximum attempt count, an overall deadline, and a per-request retry budget. Add concurrency limits, queueing/admission control, and a circuit breaker or load-shedding policy so a failing provider does not trigger synchronized retries. For timeouts with uncertain completion, consider whether retrying can duplicate cost or side effects; use request idempotency and status reconciliation where available.

Record attempt count, error category, provider request ID, and final outcome for observability, without logging credentials or sensitive content. Test retryable and non-retryable statuses, `Retry-After`, deadline exhaustion, cancellation, bursts of rate limits, and recovery after an outage. Monitor retry amplification, not just request success rate.

### 14. [Practice prompt] What should an API contract expose when the model refuses, the response is incomplete, a tool fails, or the upstream service is unavailable?

**Answer:**

The contract should distinguish a successful complete answer from a refusal, partial/incomplete response, tool failure, timeout, and provider/service unavailability. I would return a stable application-level status and machine-readable error code, a safe user-facing message, a request/run ID, and a retryability or next-action indication where appropriate. Avoid exposing raw provider errors, internal prompts, credentials, or stack traces.

For streaming, send explicit terminal events so clients can tell completed output from a truncated stream. If a tool fails, report whether the model response is still usable, whether the workflow is paused for retry/approval, or whether the run failed. For partial results, mark them as partial and include a completion state rather than returning them as ordinary success.

Include only the metadata clients need, such as a refusal indicator, safe retry-after hint, or status URL for a background run. Keep authorization and policy details appropriately abstract to avoid creating an information leak. Document idempotency and cancellation semantics, and ensure the client can safely render, retry, or escalate each state.

### 15. [Practice prompt] How would you make structured model output safe to consume in a business workflow? Discuss schema constraints, semantic validation, refusals, authorization, and downstream side effects.

**Answer:**

I would constrain the output format with a schema—required fields, types, enums, bounds, and additional-property policy—but treat schema validity as only the first check. The application must parse the response, handle refusal or incomplete states explicitly, and perform semantic validation against authoritative data: referenced records exist, values are allowed, and the requested transition is valid for the record's current state.

Authorization comes from the authenticated user and trusted policy system, not from fields generated by the model. Before any mutation, validate the caller's permission and recheck relevant state at execution time. For high-impact or irreversible actions, present a clear preview and obtain confirmation bound to the exact action and parameters. Use transactions, conditional updates, and idempotency keys to avoid races or duplicate execution.

On invalid output, do not guess, coerce dangerous values, or continue with a side effect. Return a recoverable validation error, ask the model for a constrained correction only when safe, or request clarification/human review. Test schema-valid but nonexistent IDs, out-of-range values, cross-tenant references, refusals, truncation, duplicate retries, and state changes between validation and execution.

### 16. [Practice prompt] How would you control latency and cost for a high-volume model API feature? Include token budgets, output limits, caching, batching where appropriate, and per-user controls.

**Answer:**

I would first measure latency and cost per successful task, split by model, route, tenant, and request type. Control input growth by limiting conversation history, retrieved context, and tool output; count tokens before submission where practical and reserve budget for the system instructions and answer. Set output limits aligned to the task, with clear behavior when a response is truncated.

Route simple tasks to a smaller/faster model only if evaluations show it meets quality and safety thresholds. Reuse stable prompt prefixes or cache deterministic retrieval/results where semantics and privacy allow; use batch inference for offline work that does not need interactive latency. For online traffic, tune concurrency and batching against time-to-first-token and tail-latency targets rather than optimizing throughput alone.

Apply per-user/tenant quotas, rate limits, concurrency caps, and spend alerts/hard limits. Bound retries and agent steps to prevent hidden fan-out. Monitor cache hit rate, input/output token distribution, model route, latency percentiles, errors, and cost per completed task. Canary each optimization and recheck quality, fairness across workload slices, and user experience so cost reduction does not silently degrade outcomes.

### 17. [Practice prompt] How do you keep API keys and user credentials out of browsers, logs, traces, and error messages while still supporting interactive clients?

**Answer:**

I would keep long-lived provider API keys on the server in a managed secret store, inject them at runtime using least-privilege service identities, and rotate them. The browser calls my authenticated backend, which validates the user, applies quotas and policy, and makes the provider request. If a product requires direct client-to-provider connectivity, I would use narrowly scoped, short-lived, purpose-limited tokens where the provider supports them, never ship a reusable server key.

User credentials should be handled through the appropriate authentication flow and stored only as needed; use secure, short-lived session tokens and avoid placing credentials in prompts or model-visible tool results. Logs and traces should redact authorization headers, secrets, and sensitive payloads at the source. Error responses should expose a request ID and safe error category, not raw headers, stack traces, or provider request bodies.

I would add automated secret scanning, structured logging with redaction, restricted access and retention for traces, and tests that inject canary secrets to verify they never appear in logs or client responses. Monitor for unusual key usage and rotate immediately if exposure is suspected.

## C. Tool use, agents, and orchestration

### 18. [Practice prompt] Explain the full tool-calling lifecycle from model request to validated tool execution, tool result, and final model response. Which parts must remain under application control?

**Answer:**

The application sends the model a user request plus a constrained set of tool schemas and instructions. The model may return a tool call with a tool name and arguments; this is a proposal, not an execution. The application parses the call, validates its schema and semantics, authenticates the user, checks authorization and business rules, and decides whether approval is required. Only then does trusted application code invoke the tool with scoped credentials.

The application captures the tool result, handles errors and timeouts, validates/filters the result, and returns it to the model as tool output associated with the correct call. The model may then produce a final answer or another tool proposal. The application repeats this under step, time, token, and cost bounds and terminates explicitly on completion, refusal, failure, cancellation, or budget exhaustion.

Application control must include tool allowlisting, authorization, argument validation, execution, secret handling, side-effect confirmation, idempotency, rate limits, output filtering, and final response validation. Retrieved/tool content is untrusted and must not override policy. Trace the workflow with privacy controls, and ensure tool failures cannot be disguised as successful completion.

### 19. [Practice prompt] How would you design tool schemas and descriptions so the model selects the right capability and supplies arguments that can be validated safely?

**Answer:**

I would expose a small set of narrowly scoped tools with distinct purposes rather than one overly broad “do anything” function. Each schema should use explicit required fields, types, enums, formats, and numeric/string limits, and reject unexpected fields where possible. Descriptions should explain when to use the tool, what it does not do, units/time zones, identifier semantics, and whether it is read-only or has a side effect.

Use examples for ambiguous fields and encode mutually exclusive choices directly in the schema where supported. Avoid asking the model for information the application can safely derive, such as the authenticated user's identity or tenant. The application must still validate arguments against live domain state and authorize every call; a valid schema is not proof of permission or correctness.

I would test tool selection and arguments on representative, ambiguous, adversarial, and out-of-scope requests. Track invalid-call rate, unnecessary calls, omissions, and side-effect errors. If the model frequently confuses tools, improve boundaries and names or simplify the tool set rather than relying only on longer instructions.

### 20. [Practice prompt] A model requests a refund using a function call. How would you separate model intent from the authorization decision and avoid executing a duplicate or unauthorized refund?

**Answer:**

I would treat the function call as a suggested intent only. The application would authenticate the user, load the order/refund state from the system of record, verify ownership, eligibility, refund limits, and policy, then determine whether the user is authorized to proceed. The model cannot establish those facts or grant permission.

Before execution, validate the amount and currency against the refundable balance and business rules. For consequential refunds, show the user a clear confirmation that names the order and exact amount; bind the approval to those parameters and revalidate them at commit time. Execute through a trusted payment service using an idempotency key derived from the request/action ID. Persist the action state so retries or worker restarts can check whether the refund already succeeded rather than issuing another.

If the provider result is ambiguous due to timeout, reconcile with the payment system before retrying. Audit the user, decision, action ID, amount, and outcome while protecting payment data. Test cross-user orders, expired/partially refunded orders, changed balances, duplicate calls, replayed confirmations, and uncertain provider outcomes. Return a clear status to the user and never report success until the source of truth confirms it.

### 21. [Practice prompt] When would you use hosted tools, application-defined functions, or an MCP server? Compare control, trust, deployment, observability, and operational ownership.

**Answer:**

I would choose based on where the capability runs, what data it can access, and how much control the product needs:

- **Hosted tools** are useful when a provider-managed capability fits the task and its data handling, availability, and behavior meet product requirements. They can reduce integration work, but the team must understand the provider's operational boundaries, supported configuration, and observability.
- **Application-defined functions** fit domain-specific operations that require tight integration with business systems and deterministic authorization. The application owns execution, credentials, validation, retries, and monitoring, giving strong control but adding implementation and operational work.
- **MCP servers** can provide a reusable, standardized tool interface across compatible clients and services. They are valuable when tools need to be shared or independently deployed, but introduce another trust and network boundary: server identity, tool discovery, permissions, versioning, availability, and auditability must be managed.

I would compare data sensitivity, permission model, deployment ownership, latency, reliability, audit requirements, and failure isolation. Regardless of mechanism, model-proposed calls are not trusted authorization: the application must enforce least privilege, validate arguments and outputs, and require confirmation for consequential actions. I would start with the smallest safe integration and test its failure and revocation behavior before expanding tool access.

### 22. [Practice prompt] How would you decide which MCP tool calls require explicit approval, and how should a user understand what information or action they are approving?

**Answer:**

I would classify tools by consequence, reversibility, scope, and data exposure. Read-only retrieval of non-sensitive information may not need per-call confirmation if the user has already granted the relevant access. Writes, external communication, financial actions, deletion, permission changes, or disclosure of sensitive data should generally require explicit approval unless a narrowly scoped, informed standing authorization is appropriate.

The approval should be shown in the product UI, not inferred from conversational text alone. It should identify the exact action, target, key parameters, data to be shared, destination, and likely consequence—for example, “send this message to these recipients” rather than “continue.” Bind the approval to the exact normalized action and parameters, expire it, and re-check current authorization and state immediately before execution. If any material parameter changes, ask again.

I would log the approver, action ID, policy decision, and result with appropriate privacy controls. Tests should include replayed approvals, changed parameters, revoked permissions, misleading tool descriptions, and prompt injection. The model may explain the proposed action, but trusted code decides whether approval is required and whether the action is allowed.

### 23. [Practice prompt] Design an agent loop with a maximum step budget, tool allowlist, timeouts, retries, and a clear termination policy. What should happen when the budget is exhausted?

**Answer:**

I would implement the loop as an explicit state machine: receive input, request the model's next response, validate whether it is a final response or a tool proposal, authorize and execute an allowed tool, append the validated result, and continue. The application enforces an allowlist and schema validation; each tool has a timeout and bounded retry policy, and the overall run has a deadline, maximum model/tool steps, and token or spend budget.

Termination should be explicit for successful completion, refusal, cancellation, unrecoverable tool/model error, and budget exhaustion. I would detect repeated identical calls or cycles with no progress and stop them early. Side-effecting tools need idempotency keys and, where appropriate, user approval; tool output is untrusted input.

When the budget is exhausted, stop issuing new model or tool calls, persist the run state and completed actions, and return a clear partial/incomplete status. Summarize what was completed, what remains, and whether any action has uncertain status; offer a safe resume or human handoff if supported. Never report success just because the loop stopped, and never retry a side effect blindly. Monitor exhaustion and loop rates to diagnose whether the budget is too small or the agent is failing to make progress.

### 24. [Practice prompt] How do you decide whether to use multiple specialized agents or one agent with tools? What evidence would justify the additional orchestration complexity?

**Answer:**

I would start with one agent and a small set of well-defined tools unless the task has genuinely separable subtasks that benefit from independent context, expertise, or parallel execution. Multiple agents can help when, for example, research and verification can proceed independently or specialized components have distinct permissions, but they add coordination, latency, cost, state management, and more failure surfaces.

I would establish a baseline and compare architectures on end-to-end task completion, correctness, grounding, safety, latency, cost, and debuggability using the same representative workload. A multi-agent design is justified only if it produces a meaningful, repeatable improvement that outweighs the added complexity. I would test disagreement resolution, duplicated work, inconsistent state, tool permissions, and failure of one sub-agent.

If using multiple agents, define each role narrowly, restrict shared state and tools, specify how outputs are validated and combined, and bound concurrency and total steps. If a deterministic workflow can coordinate predictable stages, use that instead of asking agents to negotiate everything. Keep the system simpler when evidence does not show a durable gain.

### 25. [Practice prompt] How would you preserve task state for a long-running agent and recover safely after a worker crash without repeating irreversible tool actions?

**Answer:**

I would persist a durable run record keyed by an opaque run ID, scoped to the authenticated owner/tenant, with status, deadline, versioned state, completed steps, pending action, and references to any large payloads. Store the model/tool configuration and enough trace metadata to resume and investigate, while applying encryption, access controls, retention, and deletion rules to conversation content.

Use a durable queue or workflow store with leases/checkpoints so a replacement worker can resume from the last committed safe point. For a side effect, persist an action intent and unique idempotency key before calling the external system; after the call, persist the result and action status. If the worker crashes after the external system may have acted but before the result is committed, reconcile using the idempotency key or query the source of truth before retrying. Do not assume exactly-once execution across systems.

Make cancellation and user approvals durable state transitions. Bind approvals to exact action parameters and revalidate authorization/state before execution. Test crashes before and after each persistence and tool boundary, duplicate queue delivery, lease expiry, schema migration, and uncertain external outcomes. The user should see whether the run is active, completed, failed, or awaiting action—not a false success.

### 26. [Practice prompt] A user asks an agent to complete a task, but the agent is uncertain whether it has enough evidence to act. How should the system decide to ask a clarifying question, request approval, continue gathering information, or stop?

**Answer:**

I would distinguish uncertainty about the user's intent, uncertainty about facts, and uncertainty about authorization or consequences; each needs a different response. If essential parameters are missing or ambiguous, ask a focused clarifying question. If the required evidence is available through an authorized, bounded read-only tool, continue gathering it and verify the result. If the action is understood and allowed but consequential, present the exact proposed action and request explicit approval. If authorization is absent, sources conflict, evidence remains insufficient, or the risk exceeds the system's permitted scope, stop or hand off rather than guess.

These decisions should be governed by application policy and task-specific thresholds, not by a free-form confidence statement from the model. The system can use evidence coverage, source reliability, validation results, action impact, and policy checks as signals. A low-risk reversible action may tolerate a different threshold from a financial or irreversible one.

I would make the user-facing state clear: what is uncertain, what information is needed, what will happen next, and what the system will not do. Evaluate each branch with ambiguous requests, conflicting sources, prompt injection, denied permissions, and high-impact scenarios. The goal is calibrated action—not asking unnecessary questions for every uncertainty or acting beyond evidence.

## D. Multimodal and real-time product design

### 27. [Practice prompt] Design a real-time voice assistant that supports natural turn-taking, interruptions, tool use, and low first-audio latency. Describe the client/server responsibilities and main failure modes.

**Answer:**

I would use a streaming audio session with explicit turn and cancellation state. The client captures audio with user consent, performs appropriate buffering/encoding, streams input, renders partial text/audio promptly, and supports barge-in. The server authenticates the user, enforces session and rate limits, forwards audio to the model service, coordinates allowed tools, and applies authorization before any tool action. Keep credentials and policy enforcement server-side; use short-lived scoped tokens if direct client connectivity is required.

To reduce first-audio latency, stream input and output, avoid unnecessary serial preprocessing, and keep tool calls out of the critical path unless the request requires them. Define turn detection and interruption semantics: when a new user utterance begins, cancel or mark the previous generation stale, stop playback, and ensure late events from the old turn cannot overwrite the new response. Tool calls need deadlines and idempotency.

Plan for noisy audio, packet loss, reconnects, endpoint/provider outages, slow tools, false turn boundaries, duplicate events, and cancellation races. A lost connection should produce an explicit incomplete/failed status or resumable session, not a fabricated completion. Measure first-audio latency, interruption response, task success, transcription/understanding errors, tool correctness, and user-perceived quality across representative accents and environments.

### 28. [Practice prompt] Compare a speech-to-speech model with a chained speech-recognition, text-reasoning, and speech-generation pipeline. What requirements drive the choice?

**Answer:**

A speech-to-speech model can support more direct, low-latency interaction and preserve paralinguistic cues such as tone or timing, depending on the system. It may simplify the pipeline and enable natural turn-taking, but can be harder to inspect, constrain, debug, or evaluate at intermediate stages, and may provide less direct control over transcription and voice generation.

A chained pipeline—speech recognition, text reasoning, then speech generation—provides explicit intermediate text that can be inspected, corrected, logged selectively, or routed through existing text tools. It can make component-level evaluation and substitutions easier, but adds latency and error propagation: an ASR mistake can distort reasoning, and generated speech may not match the intended conversational timing or prosody.

I would choose using measured requirements: first-audio latency, transcription accuracy, interruption behavior, multilingual and accessibility needs, need for transcripts/citations, user privacy, moderation, debugging, voice control, and operational complexity. Evaluate end-to-end task completion and conversation quality, not just component benchmark scores. A hybrid can be appropriate, but I would add stages only when the control or observability benefit justifies the latency and failure surface.

### 29. [Practice prompt] How would you handle barge-in and cancellation when the assistant is speaking and a user begins a new utterance?

**Answer:**

I would treat a new user utterance as an interruption event that advances the conversation turn and invalidates the prior generation. The client should immediately stop or fade current playback and begin capturing the new utterance. The server should cancel the upstream generation if supported, cancel pending nonessential work, and mark the previous turn as interrupted rather than completed.

Every event and tool call should carry a turn/run ID so late audio or text from the old response is discarded and cannot contaminate the new turn. If a tool action is already in progress, cancellation semantics depend on its effect: cancel a safe read where possible; for a write, reconcile its status and do not assume cancellation rolled it back. Use idempotency and approval rules for consequential operations.

I would handle false interruptions with configurable turn detection and UX affordances, and measure interruption-to-stop latency, lost user speech, accidental cancellations, and task success. Test barge-in during generation, during tool execution, at turn boundaries, under packet reordering, and after reconnect. The system should clearly indicate whether an action already occurred.

### 30. [Practice prompt] A multimodal request includes images or audio and may contain sensitive personal data. How would you design preprocessing, access control, retention, observability, and user-facing disclosure?

**Answer:**

I would collect only the media needed for the user's task and explain what will be processed and by which service. Authenticate and authorize the request, enforce file/type/size limits, scan or decode safely, and remove unnecessary metadata such as geolocation when appropriate. Keep media out of prompts and tools that do not require it, and send it only to approved processors consistent with the product's privacy commitments and data-handling requirements.

Define retention separately for the original media, derived transcripts/embeddings, model inputs/outputs, and diagnostic traces. Encrypt data in transit and at rest, restrict access by least privilege, and support deletion propagation to caches, indexes, and derived artifacts according to policy. For observability, prefer metadata and redacted events; do not log raw images, audio, transcripts, or face/voice identifiers by default. Any exceptional content capture for debugging should have explicit approval, strict access, and short retention.

The UI should disclose relevant processing and controls—such as recording/ upload status, purpose, retention or memory behavior, and how to delete or opt out—without making unsupported privacy guarantees. Test unauthorized access, oversized/malformed content, accidental metadata leakage, retention/deletion, and provider failure. Consider whether sensitive content requires on-device processing, additional consent, or a more restrictive product path.

### 31. [Practice prompt] How would you evaluate a voice agent beyond transcription accuracy? Include turn-taking, task completion, interruption behavior, tool correctness, latency, and user experience.

**Answer:**

I would evaluate the complete conversation and task, not only word error rate. Build scenario-based tests that vary accents, speaking rate, background noise, overlapping speech, ambiguous requests, and multi-turn context. Measure task completion and correctness, whether the assistant asks useful clarifying questions, and whether it uses tools appropriately with correct arguments and authorization.

For interaction quality, measure turn-taking errors, barge-in detection, time to stop speaking after interruption, missed or duplicated user speech, first-audio latency, response latency, and recovery after connection or tool failures. Use human ratings for naturalness, perceived responsiveness, and whether the user felt interrupted or understood; automated metrics can support but not replace this assessment.

Segment results by language, acoustic conditions, task type, and user needs. Include safety and privacy cases, such as correctly declining or escalating high-impact requests. Combine offline replay, controlled user studies, and a staged production pilot with opt-in feedback. Define launch gates for task success and critical safety behavior; do not allow strong transcription scores to hide poor interaction or tool outcomes.

### 32. [Practice prompt] How do you make a multimodal experience robust when a modality is missing, malformed, unsupported, or too large to process?

**Answer:**

I would validate the request at the API boundary: supported media types, encoding, dimensions/duration, size, number of parts, and required fields. Reject malformed or unsupported content with a stable, actionable error rather than silently dropping it. For oversized input, apply documented limits and, if safe, offer a user-visible option to resize, compress, segment, or summarize it before retrying.

The application should represent modality availability explicitly so a model is not asked to reason over missing data. If a modality is optional, continue with the supported content and state the limitation; if it is essential to the task, ask the user to provide it or stop. Keep preprocessing bounded and sandboxed, and avoid automatic transformations that alter critical details without disclosure.

Test partial requests, corrupted media, unsupported codecs, empty files, extremely long audio/video, mixed modalities, and provider-side failures. Measure failure rates and latency by modality and device. Ensure fallbacks preserve privacy and access controls and do not send media to an unapproved alternate provider.

## E. Evaluation, safety, and privacy

### 33. [Practice prompt] How would you translate a product requirement into an evaluation suite that combines deterministic checks, human review, model judges, and real-user outcomes?

**Answer:**

I would convert the requirement into observable success criteria and failure boundaries, then create a versioned dataset that represents ordinary traffic, edge cases, important user segments, and high-impact scenarios. For example, “answer support questions correctly” should be decomposed into task completion, factual support, citation validity, refusal/escalation correctness, latency, and cost.

Use deterministic checks for properties with objective ground truth: schema validity, required fields, permission denials, citation IDs, tool arguments, and latency/error thresholds. Use human review for nuanced judgments such as helpfulness, completeness, and whether an answer is misleading. Model judges can scale some reviews, but calibrate them against blinded human labels and watch for style, position, or model-family bias.

Then connect offline results to real-user outcomes through a controlled pilot or A/B test, measuring task completion, correction/abandonment, satisfaction, and safety incidents. Track sample coverage and uncertainty, segment results, and predefine release gates. Preserve held-out examples so prompt or model tuning is not evaluated only on its training cases; turn reviewed production failures into new regression tests.

### 34. [Practice prompt] A model update improves a benchmark but worsens user task completion. How would you investigate the gap and make a release decision?

**Answer:**

I would first verify that the task-completion regression is real: check instrumentation, cohort assignment, traffic mix, exposure, sample size, and uncertainty. A benchmark improvement may not reflect the product's actual task distribution, or the update may optimize a proxy such as answer preference while making responses slower, less actionable, or less grounded.

I would compare the old and new models on the same representative and held-out cases, stratified by task type, language, user group, context length, and risk. Review concrete failures and inspect retrieval, tool use, refusal behavior, verbosity, latency, and cost. Confirm that the benchmark is not contaminated, overfit, or misaligned with user goals, and use human review where automated metrics disagree.

If task completion is materially worse, I would not promote based only on benchmark gains. I would pause or roll back, identify the affected slices, and decide whether to narrow routing to cases where the new model is demonstrably better. Add regressions to the suite and recalibrate the benchmark/metric if it failed to predict the user outcome. A staged release should meet both task and safety guardrails.

### 35. [Practice prompt] How would you detect regressions in a nondeterministic application? Explain paired comparisons, repeated trials, confidence, task slices, and release gates.

**Answer:**

I would compare candidate and baseline systems on the same inputs, retrieval snapshots, tool fixtures, and user/task slices. Paired comparisons reduce variance from differences in case difficulty. Because outputs are stochastic, run multiple trials where generation variability is meaningful, keep decoding/configuration controlled, randomize execution order, and record exact model, prompt, and application versions.

Choose metrics before the experiment: deterministic correctness checks, human or calibrated pairwise preference, task completion, grounding, safety, latency, and cost. Report effect sizes and confidence intervals, not only point estimates, and check whether results are practically meaningful. Slice results by important populations and task categories so a global average cannot hide a critical regression. Correct for repeated testing where many metrics or slices are examined.

Release gates should include hard safety/privacy requirements and predefined minimums for task success, reliability, latency, and cost. Use offline regression tests followed by shadow or canary traffic; shadow executions must not trigger side effects. Monitor for drift and rollback when guardrails fail. If sample size is insufficient, gather more evidence rather than treating “no statistically significant difference” as proof of equivalence.

### 36. [Practice prompt] How would you red-team a tool-using assistant for prompt injection, data exposure, unsafe actions, and misuse? What findings should block launch?

**Answer:**

I would map assets, trust boundaries, user roles, tools, data flows, and possible impacts before testing. Build adversarial scenarios for direct and retrieved prompt injection, malicious tool output, cross-tenant access, secret exfiltration, unauthorized writes, replayed approvals, malformed arguments, rate-limit abuse, and attempts to bypass refusals. Include benign lookalikes to measure overblocking as well as bypasses.

Test the complete system, not just model responses: authentication, retrieval filters, tool authorization, output validation, UI confirmation, logging, and incident handling. Use isolated test accounts and non-production tools/data so red-team actions cannot cause real harm. Record reproducible cases and severity, likelihood, affected users, and existing mitigations.

Launch should be blocked by any reproducible unauthorized data disclosure or action, bypass of required approval/authorization, exposure of secrets, uncontrolled high-impact behavior, or a critical safety failure without an effective mitigation. Lower-severity findings still need owners, mitigations, monitoring, and documented risk acceptance. Retest after fixes and keep a process for new reports and post-launch red-teaming.

### 37. [Practice prompt] What safety layers would you use for a model-backed product, and which failure modes cannot be solved by adding a stricter prompt?

**Answer:**

I would use defense in depth: clear product scope and policy; input and output checks appropriate to the task; least-privilege tools and data access; deterministic validation and authorization; rate and action limits; human confirmation for consequential actions; monitoring, incident response, and user reporting; and evaluations/red-teaming before and after release. The UI should communicate limitations and offer safe escalation.

A stricter prompt may influence model behavior, but it cannot enforce identity, permissions, transaction correctness, data isolation, or exactly-once side effects. It cannot guarantee that retrieved content is trustworthy, prevent all prompt injection, or eliminate hallucinations and model drift. Those require system-level controls, source grounding, validation, access enforcement, bounded execution, and safe fallbacks.

I would test each layer independently and end-to-end, including how controls fail when a dependency is unavailable. Safety measures should be calibrated to reduce harmful outcomes without blocking legitimate use unnecessarily, and production findings should feed back into the evaluation set and release gates.

### 38. [Practice prompt] A product team wants to remove human review to improve speed in a high-impact workflow. How would you assess the risk and propose an appropriate escalation or verification design?

**Answer:**

I would first define the decisions and consequences involved, who is affected, the reversibility of actions, applicable policy/regulatory requirements, and the error modes that human review currently catches. Then I would measure the system's performance on representative and adversarial cases, including worst-case slices, uncertainty calibration, reviewer disagreement, and the cost of false approvals versus false rejections.

I would not treat speed as the only objective. A safer alternative may be to automate low-risk, reversible cases with deterministic validation and sample-based audit while retaining human review for ambiguous, high-impact, or low-confidence cases. Add independent checks, limits, and a clear escalation path; require confirmation for irreversible actions; and make overrides and rationale auditable.

Any reduction in review should be staged, independently evaluated, approved by appropriate domain/risk owners, and monitored with predefined stop conditions. If the evidence does not establish that risk remains acceptable, keep the review requirement or narrow the automated scope. The model's self-reported confidence alone is not sufficient justification to remove a human safeguard.

### 39. [Practice prompt] How would you explain model limitations and uncertainty to users without making the product unusably cautious?

**Answer:**

I would make uncertainty actionable and proportional to the task. For ordinary low-risk requests, the assistant can answer directly while linking evidence or noting a specific limitation. When sources are missing or conflicting, say what is unknown and ask a focused follow-up rather than adding generic disclaimers to every answer. For high-impact domains, use stronger verification, scoped language, and human escalation.

The product should distinguish sourced facts from generated synthesis, show citations that users can inspect, and avoid confidence percentages unless they are calibrated and meaningful for that task. It should provide a useful next step—such as uploading a source, checking a detail, or contacting a human—rather than simply refusing.

I would evaluate both overconfidence and overcaution through representative user studies and task outcomes. Track unsupported claims, unnecessary refusals, user corrections, and completion rates, segmented by domain and risk. Clear capability boundaries and reliable behavior build trust more effectively than either pretending certainty or warning users indiscriminately.

### 40. [Practice prompt] A customer asks whether their API content is used for model training and how long it is retained. How would you answer accurately, distinguish defaults from eligible controls, and identify what your application must manage itself?

**Answer:**

I would not improvise a blanket promise. I would consult the current official OpenAI API data-controls and retention documentation for the specific product, account configuration, and applicable agreement, then explain the documented default, any eligibility requirements for additional controls, and the scope/limits of those controls. I would distinguish model-training use from abuse monitoring, operational logs, application state, and data retained by tools or third parties; they are not necessarily governed identically.

I would verify the customer's actual organization/project settings and contractual terms with the appropriate account or privacy owner. If uncertain, I would say I need to confirm rather than make an unsupported guarantee. I would direct the customer to the authoritative documentation and explain that product/API behavior and policy can change.

Separately, our application must manage its own stored prompts, completions, uploaded files, traces, caches, and derived data: minimize collection, enforce access and retention, support deletion, and disclose relevant handling. We should not imply provider-side controls automatically delete our application data or third-party tool records.

### 41. [Practice prompt] How would you collect production feedback and traces for quality improvement while minimizing personal data, limiting access, and honoring retention requirements?

**Answer:**

I would collect only signals needed to improve the product: task outcome, latency, error category, model/prompt/retrieval versions, user feedback, and a trace of relevant tool and retrieval events. I would avoid logging raw prompts and completions by default. Where content is necessary to diagnose a failure, use explicit purpose limits, redaction or pseudonymization, sampling, and a documented retention window; do not assume that removing names alone de-identifies text.

Separate operational telemetry from content-bearing traces. Encrypt data in transit and at rest, restrict access by role and purpose, audit access, and keep production debugging access time-limited. Honor tenant boundaries and user deletion/retention requirements across logs, exports, backups, and derived datasets. Make opt-in or consent requirements clear where applicable, and ensure feedback controls do not accidentally capture unrelated sensitive information.

Before launch, define ownership, retention and deletion behavior, incident procedures, and which signals may be used for evaluation or training. Monitor whether redaction itself is working, and use synthetic or curated examples where possible. Quality analysis should be useful without making broad, indefinite storage of user conversations the default.

### 42. [Practice prompt] What would you measure in production for quality, safety, availability, latency, and cost? How would you avoid treating a single aggregate score as a complete picture?

**Answer:**

I would define a small set of outcome and guardrail metrics for each dimension:

- **Quality:** task completion, correction/retry rate, groundedness or citation validity where relevant, and reviewed answer quality.
- **Safety:** policy-violation rate, unauthorized tool actions, privacy incidents, refusal correctness, and escalation outcomes.
- **Availability:** successful request rate, dependency-specific errors, timeouts, and recovery rate.
- **Latency:** end-to-end and time-to-first-token p50/p95/p99, separated by model, route, and task.
- **Cost:** input/output tokens and total cost per successful task, including retries, tools, retrieval, and other infrastructure.

I would also track adoption and user feedback, but treat them as signals rather than proof of correctness. Define each metric's denominator, instrumentation, and owner; alert on actionable service-level objectives and hard safety thresholds. Break results down by task, model/version, language, tenant or user segment where appropriate, and risk level. A stable overall average can hide a regression in a small but important group, while an aggregate score can conceal tradeoffs between quality, safety, latency, and cost. Pair dashboards with sampled human review and investigation of representative failures.

## F. Coding and implementation practice

These are original practice exercises based on common AI application engineering needs. They are not sourced from a reported interview prompt.

### 43. [Practice prompt] Implement an event-stream parser that assembles model text deltas into complete events when network chunks split at arbitrary byte boundaries.

**Answer:**

Network reads are byte chunks, not event boundaries. For a Server-Sent Events stream, I would buffer bytes until a blank-line delimiter, then parse each complete frame. Keeping the buffer as bytes also avoids corrupting a multibyte UTF-8 character split across reads.

```python
from collections.abc import Iterator


def parse_sse(chunks: Iterator[bytes]) -> Iterator[dict[str, str]]:
    buffer = bytearray()

    for chunk in chunks:
        buffer.extend(chunk)
        while True:
            boundary = buffer.find(b"\n\n")
            crlf_boundary = buffer.find(b"\r\n\r\n")
            candidates = [i for i in (boundary, crlf_boundary) if i >= 0]
            if not candidates:
                break

            end = min(candidates)
            delimiter_size = 4 if end == crlf_boundary else 2
            frame = bytes(buffer[:end])
            del buffer[: end + delimiter_size]

            event: dict[str, str] = {}
            data_lines: list[str] = []
            for raw_line in frame.splitlines():
                line = raw_line.decode("utf-8").rstrip("\r")
                if not line or line.startswith(":"):  # blank/comment line
                    continue
                field, separator, value = line.partition(":")
                if separator and value.startswith(" "):
                    value = value[1:]
                if field == "data":
                    data_lines.append(value)
                elif field in {"event", "id"}:
                    event[field] = value
            if data_lines:
                event["data"] = "\n".join(data_lines)
                yield event

    if buffer.strip():
        raise ValueError("Stream ended with an incomplete SSE frame")
```

In production I would also enforce a maximum frame size, define handling for the provider's end marker, and test LF/CRLF delimiters, split delimiters, split UTF-8 characters, comments, multiple `data` lines, and truncated streams.

### 44. [Practice prompt] Implement a retry wrapper for a model API that handles retryable status codes, jittered exponential backoff, a total deadline, and a maximum attempt count.

**Answer:**

Retries should be bounded by both attempts and a monotonic-clock deadline. I would retry only explicitly transient failures, respect `Retry-After` when available, and ensure the request is safe to retry (for example, use an idempotency key for operations that may have side effects).

```python
import random
import time
from collections.abc import Callable
from typing import TypeVar

T = TypeVar("T")
RETRYABLE_STATUS = {408, 429, 500, 502, 503, 504}


class ApiError(Exception):
    def __init__(self, status: int, retry_after: float | None = None):
        self.status = status
        self.retry_after = retry_after


def call_with_retry(
    call: Callable[[], T],
    *,
    timeout_seconds: float,
    max_attempts: int = 4,
    base_delay: float = 0.25,
    max_delay: float = 4.0,
) -> T:
    deadline = time.monotonic() + timeout_seconds
    for attempt in range(max_attempts):
        if time.monotonic() >= deadline:
            raise TimeoutError("Total request deadline exceeded")
        try:
            return call()
        except ApiError as exc:
            if exc.status not in RETRYABLE_STATUS or attempt + 1 == max_attempts:
                raise

            remaining = deadline - time.monotonic()
            exponential_cap = min(max_delay, base_delay * (2**attempt))
            delay = exc.retry_after
            if delay is None:
                delay = random.uniform(0, exponential_cap)  # full jitter
            if delay >= remaining:
                raise TimeoutError("Insufficient deadline for another retry") from exc
            time.sleep(delay)

    raise AssertionError("unreachable")
```

The HTTP client's own connect/read timeouts must also be set to fit within the remaining deadline; otherwise a single attempt can overrun the wrapper's budget. I would emit attempt count and final failure metrics without logging request content.

### 45. [Practice prompt] Given a model tool-call request, implement dispatch that validates the tool name and arguments, checks caller authorization, applies a timeout, and returns a structured tool result.

**Answer:**

I would treat the model-provided tool call as untrusted input. The model may suggest a tool and arguments, but application code owns the allowlist, schema/domain validation, authorization, timeout, and side-effect policy.

```python
import asyncio
import logging
from collections.abc import Awaitable, Callable
from dataclasses import dataclass
from typing import Any

logger = logging.getLogger(__name__)


@dataclass
class Tool:
    validate: Callable[[dict[str, Any]], dict[str, Any]]
    authorize: Callable[[str, dict[str, Any]], bool]
    run: Callable[[dict[str, Any]], Awaitable[Any]]


async def dispatch_tool(
    name: str,
    raw_args: dict[str, Any],
    caller_id: str,
    tools: dict[str, Tool],
    timeout_seconds: float = 5.0,
) -> dict[str, Any]:
    tool = tools.get(name)
    if tool is None:
        return {"ok": False, "error": {"code": "unknown_tool"}}
    try:
        args = tool.validate(raw_args)
    except (TypeError, ValueError) as exc:
        return {"ok": False, "error": {"code": "invalid_arguments",
                                       "message": str(exc)}}
    if not tool.authorize(caller_id, args):
        return {"ok": False, "error": {"code": "forbidden"}}
    try:
        result = await asyncio.wait_for(tool.run(args), timeout_seconds)
    except TimeoutError:
        return {"ok": False, "error": {"code": "tool_timeout"}}
    except Exception:
        logger.error("Tool execution failed")
        return {"ok": False, "error": {"code": "tool_failed"}}
    return {"ok": True, "result": result}
```

The broad exception at the tool boundary is deliberate only if failures are logged and surfaced as an explicit structured error; it must not turn a failed action into success. For irreversible operations, I would add a confirmation/approval step and idempotency controls. A coroutine timeout alone cannot guarantee that an external side effect was cancelled, so tools need their own deadlines and reconciliation strategy.

### 46. [Practice prompt] Implement a bounded agent runner that tracks tool calls and elapsed time, rejects unknown tools, and returns a distinct status for completion, refusal, timeout, and budget exhaustion.

**Answer:**

I would keep the loop's budget and termination states in application code, not in instructions to the model. The step function below represents one model turn; each requested tool is checked against an explicit allowlist before execution.

```python
import logging
import asyncio
import time
from collections.abc import Awaitable, Callable
from typing import Any

logger = logging.getLogger(__name__)


async def run_agent(
    step: Callable[[list[dict[str, Any]]], Awaitable[dict[str, Any]]],
    tools: dict[str, Callable[[dict[str, Any]], Awaitable[Any]]],
    *,
    max_tool_calls: int,
    timeout_seconds: float,
) -> dict[str, Any]:
    deadline = time.monotonic() + timeout_seconds
    messages: list[dict[str, Any]] = []
    calls = 0

    while True:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            return {"status": "timeout"}
        try:
            response = await asyncio.wait_for(step(messages), timeout=remaining)
        except TimeoutError:
            return {"status": "timeout"}

        if response.get("refusal") is True:
            return {"status": "refusal", "message": response.get("text", "")}
        if response.get("done") is True:
            return {"status": "completed", "result": response.get("text", "")}

        requested = response.get("tool_call")
        if not isinstance(requested, dict):
            return {"status": "invalid_response"}
        name = requested.get("name")
        args = requested.get("arguments")
        if name not in tools or not isinstance(args, dict):
            return {"status": "unknown_tool"}
        if calls >= max_tool_calls:
            return {"status": "budget_exhausted"}

        calls += 1
        try:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                return {"status": "timeout"}
            result = await asyncio.wait_for(tools[name](args), timeout=remaining)
        except TimeoutError:
            return {"status": "timeout"}
        except Exception:
            logger.error("Agent tool execution failed: %s", name)
            return {"status": "tool_failed", "tool": name}
        else:
            messages.append({"tool": name, "result": result})
```

I would additionally constrain per-tool duration and output size, validate arguments and authorization, and avoid returning raw exception details. The runner's deadline must be propagated to model and tool clients: checking time between steps does not interrupt a blocking call already in progress.

### 47. [Practice prompt] Write a function that validates a structured model response against both a schema and domain rules, preserving refusal and incomplete-response states instead of converting them into success.

**Answer:**

I would model response status explicitly and validate only a completed, non-refusal payload. Schema validity is necessary but does not establish domain correctness—for example, an amount may be numeric and still violate a business limit.

```python
from collections.abc import Callable
from typing import Any


def validate_response(
    response: dict[str, Any],
    *,
    schema_validate: Callable[[Any], None],
    domain_validate: Callable[[Any], None],
) -> dict[str, Any]:
    if response.get("status") == "refused" or response.get("refusal"):
        return {"status": "refusal", "reason": response.get("refusal")}
    if response.get("status") in {"incomplete", "length"}:
        return {"status": "incomplete", "reason": response.get("status")}
    if response.get("status") != "completed":
        return {"status": "invalid", "reason": "unexpected_response_status"}

    payload = response.get("output")
    try:
        schema_validate(payload)
        domain_validate(payload)
    except (TypeError, ValueError) as exc:
        return {"status": "invalid", "reason": str(exc)}
    return {"status": "valid", "data": payload}
```

In a real integration I would normalize provider-specific finish/refusal states at the adapter boundary, preserve the original response ID for diagnostics, and validate against a versioned schema. Validation errors should be observable and recoverable (for example, a bounded repair attempt or human review), never silently converted into an empty successful result.

### 48. [Practice prompt] Given API request records with token usage, latency, status, model, and tenant, calculate p50/p95 latency and cost by tenant while handling missing data and failed requests correctly.

**Answer:**

I would keep service latency and cost accounting separate from successful-task quality. Failed requests can still consume tokens and incur cost; include their measured latency in service-latency percentiles, but do not count them as successful tasks. Missing usage is unknown, not zero.

```python
from collections import defaultdict
from collections.abc import Iterable
from math import ceil


def percentile(values: list[float], p: float) -> float | None:
    if not values:
        return None
    ordered = sorted(values)
    return ordered[max(0, ceil(p * len(ordered)) - 1)]


def summarize(
    records: Iterable[dict],
    price_per_1k: dict[str, tuple[float, float]],  # model -> input, output price
) -> dict[str, dict]:
    groups: dict[str, dict] = defaultdict(
        lambda: {"latencies": [], "cost": 0.0, "cost_records": 0,
                 "requests": 0, "failed": 0, "missing_usage": 0}
    )
    for row in records:
        g = groups[row.get("tenant") or "unknown"]
        g["requests"] += 1
        if isinstance(row.get("latency_ms"), (int, float)):
            g["latencies"].append(float(row["latency_ms"]))
        if row.get("status") != "success":
            g["failed"] += 1

        model = row.get("model")
        input_tokens, output_tokens = row.get("input_tokens"), row.get("output_tokens")
        if (model not in price_per_1k or
                not isinstance(input_tokens, int) or input_tokens < 0 or
                not isinstance(output_tokens, int) or output_tokens < 0):
            g["missing_usage"] += 1
            continue
        input_price, output_price = price_per_1k[model]
        g["cost"] += (input_tokens * input_price +
                      output_tokens * output_price) / 1000
        g["cost_records"] += 1

    return {
        tenant: {
            **{k: v for k, v in g.items() if k != "latencies"},
            "latency_p50_ms": percentile(g["latencies"], 0.50),
            "latency_p95_ms": percentile(g["latencies"], 0.95),
        }
        for tenant, g in groups.items()
    }
```

I would label the percentile convention and currency/pricing version, deduplicate retries according to the reporting question, and report cost coverage (`cost_records` versus requests) so partial usage data cannot look complete. In production, pricing should be versioned and account for cached tokens, tools, and provider-specific billing where applicable.

### 49. [Practice prompt] Implement conversation-history trimming under a token budget while preserving system instructions, the newest user turn, and complete tool-call/result pairs.

**Answer:**

I would trim whole conversational units, not arbitrary messages. Treat a tool call and its corresponding result as one atomic group; otherwise the retained history can contain an orphaned result or an unanswered call. Preserve system instructions and the newest user turn, and fail explicitly if those required messages alone exceed the budget.

```python
def trim_history(messages, token_budget, count_tokens):
    systems = [m for m in messages if m["role"] == "system"]
    conversation = [m for m in messages if m["role"] != "system"]

    # Keep each user turn and its assistant/tool exchanges as one atomic group.
    groups, current = [], []
    for message in conversation:
        if message["role"] == "user" and current:
            groups.append(current)
            current = []
        current.append(message)
    if current:
        groups.append(current)

    for group in groups:
        pending_ids = {
            call["id"]
            for message in group
            if message["role"] == "assistant"
            for call in message.get("tool_calls", [])
        }
        returned_ids = {
            message.get("tool_call_id")
            for message in group
            if message["role"] == "tool"
        }
        if pending_ids - returned_ids:
            raise ValueError("History contains an incomplete tool-call/result group")

    newest_user_index = next(
        (i for i in range(len(groups) - 1, -1, -1)
         if any(m["role"] == "user" for m in groups[i])),
        None,
    )
    if newest_user_index is None:
        raise ValueError("History has no user turn")
    required = systems + groups[newest_user_index]
    if count_tokens(required) > token_budget:
        raise ValueError("Required system instructions and newest user turn exceed budget")

    kept = [groups[newest_user_index]]
    for group in reversed(groups[:newest_user_index]):
        candidate = systems + group + sum(kept, [])
        if count_tokens(candidate) <= token_budget:
            kept.insert(0, group)
    return systems + sum(kept, [])
```

The token counter should use the target model's tokenizer or a conservative provider-compatible estimate. I would test multiple tool calls, missing results, old and newest turns, and a single required turn that exceeds the limit. Systems that allow tool calls after the newest user turn may need a more general grouping policy, but should still retain only complete groups.

### 50. [Practice prompt] Given a set of tasks with dependencies and limited worker concurrency, return a valid execution schedule and explain how you detect cycles and recover from a failed task.

**Answer:**

I would represent dependencies as a directed acyclic graph and use Kahn's topological algorithm. A ready queue contains tasks whose prerequisites are complete; if the algorithm processes fewer nodes than exist, the remaining nodes are cyclic or depend on a cycle. With limited workers, dispatch ready tasks up to the concurrency limit and release dependents only after successful completion.

```python
from collections import defaultdict, deque


def schedule(tasks: set[str], dependencies: list[tuple[str, str]]) -> list[str]:
    # Each pair is (task, prerequisite).
    dependents = defaultdict(list)
    indegree = {task: 0 for task in tasks}
    for task, prerequisite in dependencies:
        if task not in tasks or prerequisite not in tasks:
            raise ValueError("Dependency references an unknown task")
        dependents[prerequisite].append(task)
        indegree[task] += 1

    ready = deque(sorted(task for task, degree in indegree.items() if degree == 0))
    order = []
    while ready:
        task = ready.popleft()
        order.append(task)
        for child in dependents[task]:
            indegree[child] -= 1
            if indegree[child] == 0:
                ready.append(child)
    if len(order) != len(tasks):
        raise ValueError("Dependency cycle detected")
    return order
```

This returns a valid ordering; a concurrent scheduler would dispatch from the ready queue to at most `worker_limit` workers and update dependency counts as each task succeeds. On failure, stop dispatching descendants of that task, mark them blocked, and either retry the failed task under a bounded idempotent retry policy or surface it for intervention. Independent tasks may continue if safe. Persist task state and use idempotency/checkpointing so a scheduler restart does not repeat completed side effects. Graph construction and ordering are O(V + E); the worker limit affects execution time, not the dependency validation.

## G. System-design practice

### 51. [Practice prompt] Design a reliable multi-tenant API service for an AI assistant. Cover authentication, quotas, model routing, streaming, state, observability, privacy, and graceful degradation.

**Answer:**

I would put an authenticated API gateway in front of stateless request workers. The gateway validates identity and project membership, enforces per-tenant rate and spend limits, and attaches a trusted tenant context. Every downstream data lookup and tool action must use that context; tenant identity must never come from model output or an untrusted request field. Keep conversation state in a tenant-scoped store, encrypted and subject to explicit retention/deletion rules.

Workers route requests using policy and capability requirements—latency, context size, modality, quality tier, data controls, and cost—not model preference alone. Apply request deadlines, bounded retries, concurrency limits, and circuit breakers around provider calls. Stream responses with backpressure and cancellation propagation; disconnecting clients should cancel work where safe. Use idempotency keys for retryable client requests and carefully define how partially streamed responses are represented.

Instrument request IDs, tenant-safe metrics, model/version, latency, token usage, tool outcomes, and sanitized error categories. Avoid putting raw content in general-purpose logs. Degrade deliberately: reject requests before exceeding quotas, serve non-generative cached/static functionality where appropriate, or route only to a fallback that meets the same privacy and capability requirements. If no safe fallback exists, return a clear retryable error. Use per-tenant isolation, load shedding, staged capacity tests, and recovery drills to prevent one tenant or provider incident from destabilizing the service.

### 52. [Practice prompt] Design a research assistant that searches a large corpus, cites evidence, and can call external tools. How do you handle retrieval, source freshness, authorization, unsupported claims, and evaluation?

**Answer:**

I would ingest sources through a versioned pipeline that extracts text and metadata, records provenance and timestamps, applies access labels, and indexes both lexical and semantic representations. At query time, authenticate the user first and filter by authorization before results reach the model; post-filtering alone risks leaking restricted snippets. Use hybrid retrieval and reranking, with freshness-aware ranking or explicit source-age rules for time-sensitive questions. External tools should be separately allowlisted and permission-checked.

Require the answer generator to ground material claims in retrieved evidence and return citations linked to stable source IDs, passages, and versions. Validate that citations resolve and support the associated claims; if evidence is weak, stale, or contradictory, communicate that limitation, ask a clarifying question, or abstain rather than fill gaps with plausible text. Treat retrieved documents and tool output as untrusted data, not instructions.

Evaluate retrieval recall/precision and authorization isolation separately from answer correctness, citation support, freshness, and task completion. Build a versioned test set with permission boundaries, adversarial documents, stale/conflicting sources, and hard negatives. Use human review for evidence quality, run privacy/security tests, and monitor production failures. Track source updates and deletes through the index and caches so a citation remains auditable and revoked content stops being retrievable.

### 53. [Practice prompt] Design a customer-support agent that can answer questions and perform account actions. Explain authorization boundaries, approval for consequential actions, idempotency, audit, and rollback.

**Answer:**

I would separate read-only support answers from account-changing actions. The user authenticates through the product's normal identity flow; the server derives the account and permissions from that identity, then exposes only narrowly scoped tools. The model may propose an action, but a deterministic policy service validates the target account, arguments, current state, and authorization immediately before execution. Never use a prompt instruction as an authorization control.

For consequential or irreversible changes—such as closing an account, issuing a large refund, or changing ownership—show the exact action and consequences to the user and require confirmation or an authorized human approval. Use idempotency keys and transactional state transitions to prevent duplicate execution after retries. Return structured tool outcomes to the assistant so it can communicate whether the action succeeded, failed, or needs follow-up.

Audit the authenticated actor, policy decision, confirmation, tool/version, request ID, and outcome while minimizing sensitive content in logs. Prefer reversible operations or compensating actions where possible; define rollback ownership and procedures before enabling tools. If a timeout occurs after a possible side effect, reconcile the operation by its idempotency key before retrying or claiming failure. Test cross-account attempts, stale state, replay, partial failures, and revoked permissions.

### 54. [Practice prompt] Design a real-time voice agent platform for many concurrent sessions. Identify latency budgets, session state, audio transport, scaling, interruption handling, and cost controls.

**Answer:**

I would begin with an end-to-end latency budget, measuring audio capture, transport, endpointing, inference, tool work, and audio playback separately. Use a persistent low-latency transport such as WebRTC or a WebSocket-based stream, with explicit session authentication, bounded message sizes, and backpressure. Choose streaming speech recognition/generation or a speech-to-speech model based on quality, latency, accessibility, and operational constraints.

Keep session state explicit and compact: conversation context, turn IDs, active tool operations, and cancellation state. Store durable state only when required, tenant-scope it, and apply retention controls; avoid persisting raw audio by default. Scale stateless session gateways and worker pools horizontally, while managing provider concurrency, per-tenant quotas, regional capacity, and load shedding. Observe time-to-first-audio, turn latency percentiles, interruption rate, dropped frames, task success, and cost per completed session.

Support barge-in: when the user interrupts, cancel or mark the current response obsolete, stop playback, and prevent late tool/model results from being spoken as if current. Propagate cancellation to safe downstream work and reconcile side effects that cannot be cancelled. Degrade gracefully to text or a clear unavailable message if audio/model capacity fails; do not silently switch to a provider with incompatible privacy terms. Control cost through session timeouts, turn limits, adaptive model routing, and detection of idle or looping sessions.

### 55. [Practice prompt] Design an evaluation and rollout platform for model, prompt, and tool changes. How would you support offline suites, shadow evaluation, canary release, monitoring, and rollback?

**Answer:**

I would make each candidate release an immutable, versioned bundle: model identifier/settings, prompt, tool schemas and policies, retrieval/index version, and application code. The platform runs deterministic contract, safety, and regression tests first, then representative offline evaluations with task-specific metrics, human review, and calibrated model judges where suitable. Keep holdout data and track dataset provenance to reduce leakage and overfitting.

For shadow evaluation, duplicate eligible production requests to the candidate without exposing its response or allowing side effects. Minimize or redact copied content, respect consent and retention rules, and stub tools or make them read-only. Compare candidate and baseline on the same traffic and slices. Canary only after offline gates pass; ramp exposure in stages with predefined quality, safety, latency, error, and cost thresholds and sufficient sample size.

Monitor segmented results and alerts in near-real time. Preserve a one-step rollback to a known-good bundle and make rollback independent of the model-serving control plane where possible. If a guardrail fails, stop the ramp or revert, investigate affected cohorts, and retain only the data needed for incident analysis. After mitigation, add the failure to regression suites and document the release decision.

### 56. [Practice prompt] Design an API that lets developers build agents with custom tools while isolating untrusted tool output from instructions and secrets.

**Answer:**

I would treat developer-defined tools as capabilities granted by the application, not as arbitrary functions the model can invoke. Register tools with explicit schemas, owner, scopes, timeout, resource limits, and data classification. Validate each call server-side, authenticate the end user, authorize the requested operation, and pass only the minimum required credentials through a secret manager—never in prompts or model-visible tool definitions.

Keep tool output in a typed, clearly delimited data channel and label it untrusted. Do not concatenate it into privileged instructions. The orchestrator should enforce policy outside the model: tool allowlists, argument validation, output-size limits, network egress controls, sandboxing for executable code, and approval for consequential actions. Redact secrets and sensitive fields from tool results before returning any content to the model.

Use tenant-isolated execution, least-privilege credentials, audit logs, quotas, and per-tool deadlines. Prompt-injection defenses can reduce risk but cannot replace authorization and isolation. Test malicious tool responses, attempts to expose secrets, cross-tenant access, oversized output, timeout/cancellation, and replay. Version tool contracts and provide developers clear error and revocation behavior when a tool is disabled or its permissions change.

### 57. [Practice prompt] A model provider has an outage during peak demand. Design the degradation strategy, including circuit breaking, fallback eligibility, queueing, user communication, and recovery.

**Answer:**

I would detect the incident from provider-specific errors, timeouts, and latency against defined thresholds, then open a circuit breaker to stop sending requests likely to fail. Apply bounded retries with jitter only where idempotent and within the request deadline; uncontrolled retries can amplify the outage. Enforce concurrency limits and load shed or reject low-priority work early so critical requests retain capacity.

A fallback is eligible only if it meets the request's required capability, privacy/data-residency constraints, safety behavior, and acceptable quality/latency/cost. Route only approved request classes and clearly record which provider served them. If no compatible fallback exists, return an explicit temporary-unavailability response with a retry hint; queue only work that can be delayed safely, with per-tenant limits, expiry, and deduplication.

Communicate impact through status channels and in-product messaging without promising an unsupported recovery time. Preserve request IDs for support, but avoid logging sensitive payloads. Recovery should use a half-open probe and gradual traffic ramp, monitoring error rates, latency, quality, and duplicate side effects. Afterward, review provider SLAs and capacity plans, improve failover tests, and document whether queued work was completed or expired.

### 58. [Practice prompt] How would you design a privacy-aware telemetry system for AI products that still enables debugging of rare quality and safety incidents?

**Answer:**

I would separate high-volume operational metrics from content-bearing diagnostic traces. Default telemetry should contain minimal structured fields such as request/correlation ID, model and prompt version, latency, token counts, error category, tool names, and outcome—not raw prompt, completion, audio, or retrieved documents. Use aggregation and sampling for routine analysis, with tenant-safe dimensions and safeguards against identifying individuals from small cohorts.

For rare incidents requiring content review, use a narrowly scoped, documented path: user report or approved sampling, purpose limitation, redaction where feasible, encrypted storage, short retention, role-based and just-in-time access, and auditable access logs. Keep identifiers pseudonymous and separated from content; understand that pseudonymized data may still be personal data. Honor deletion requests and ensure retention behavior covers replicas and derived datasets as required.

Build debugging capability through versioned traces, reproducible synthetic cases, evaluation fixtures, and metadata that links a failure to the exact system configuration. Define incident access approvals and escalation, and periodically test redaction and deletion. This allows investigation without making indefinite collection of conversations the default. Measure both privacy-control effectiveness and diagnostic coverage so minimization does not become an unexamined blind spot.

## H. Behavioral and project deep-dive practice

OpenAI's careers material emphasizes mission, humility, rigor, learning, and useful impact. Use truthful examples from your own work; these prompts are preparation, not a claim about exact interview questions.

### 59. [Practice prompt] Tell me about a project where you shipped a model-backed feature to real users. What did you own, what did you measure, and what changed after launch?

**Answer:**

Use a truthful project and answer in a concise situation–action–result structure:

- **Context:** “We were trying to help [user group] accomplish [task], and the existing process had [specific pain].”
- **Ownership:** “I owned [specific parts: problem framing, retrieval/data pipeline, model integration, evaluation, deployment, or monitoring]. The key constraint was [latency, privacy, quality, or cost].”
- **Decision and execution:** “I compared [approach A] with [approach B], chose [choice] because [evidence], and added [grounding/validation/fallback/human review] to address [failure mode].”
- **Measurement:** “Before launch, we defined [task-success metric] and guardrails for [quality/safety/latency/cost]. I evaluated [test set or pilot] and monitored [specific production signals].”
- **Result and learning:** “After rollout, [truthful measured outcome] changed. We also found [unexpected failure or limitation], so I [specific adjustment].”

Be precise about what you personally did versus what the team delivered. If you have not shipped a model-backed feature to real users, say so plainly and use the closest relevant project, prototype, or operational experience without implying production deployment. Do not invent metrics; explain the measurement method and limitations instead.

### 60. [Practice prompt] Describe a time you discovered that a technically impressive solution was not the right product solution. How did you recognize that and what did you do?

**Answer:**

Choose a real example where evidence changed your view, then structure it this way:

- **Situation:** “We had built or proposed [solution] to address [user problem]. It was technically appealing because [brief reason].”
- **Signal:** “I recognized the mismatch when [user research, pilot, task data, operational burden, or cost] showed [specific evidence]. The original success metric was not capturing [user outcome or constraint].”
- **Response:** “I shared the evidence and uncertainty with [relevant stakeholders], revisited the requirement, and compared [simpler or alternative approaches]. We chose [decision] and adjusted scope by [concrete action].”
- **Outcome:** “The change led to [truthful result], or avoided [specific risk/waste]. We learned [lesson] and changed [measurement or decision process] afterward.”

Emphasize curiosity and accountability rather than portraying technical ambition as a mistake by itself. If the idea was yours, own that and explain how you updated your position. Use actual outcomes; if the decision did not produce a measurable result, be transparent about what you would measure next time.

### 61. [Practice prompt] Tell me about a time you received feedback that challenged your assumptions. How did you update your approach?

**Answer:**

Use a specific, truthful example and make the change in your thinking clear:

- **Context:** “I was working on [project/decision] and initially assumed [assumption].”
- **Feedback:** “A teammate, user, or result challenged that because [specific evidence]. My first reaction was [brief and honest], but I checked [data, test, or user context] rather than defending the original plan.”
- **Update:** “I changed [technical or product decision] by [concrete action], and made the revised assumption testable through [measure or experiment].”
- **Outcome:** “The result was [truthful outcome]. I learned [lesson] and now [specific practice] helps me surface disconfirming evidence earlier.”

Give credit to the person who raised the feedback, distinguish facts from interpretation, and show how your actions changed—not just that you agreed. If the feedback did not prove correct, explain how you investigated it and what evidence led to your final decision.

### 62. [Practice prompt] Describe a difficult production incident or model-quality regression. How did you communicate uncertainty, mitigate impact, and prevent recurrence?

**Answer:**

Choose a real incident and explain it in a clear timeline:

- **Impact and detection:** What users or workflows were affected, how did you detect it, and what was known versus still uncertain?
- **Containment:** What immediate safe action did you take—rollback, disable a tool/model route, reduce traffic, or add human review—and who did you notify?
- **Investigation:** How did you isolate the change (model, prompt, retrieval, dependency, traffic mix, or instrumentation) and validate the suspected cause?
- **Recovery and prevention:** How did you restore service, communicate status, and add tests, alerts, rollout gates, or operational controls to prevent recurrence?

Use actual impact and metrics if available, but do not overstate causal certainty. Explain how you kept updates factual while investigating and how you balanced restoring service with preserving evidence. If you have not owned a production incident, use a real quality regression in a project and be explicit about its scope.

### 63. [Practice prompt] Tell me about a time you made a trade-off between shipping quickly and reducing risk. What evidence informed your decision?

**Answer:**

Use an example where you made the trade-off explicit rather than presenting speed and risk as a binary:

- **Goal and deadline:** “We needed to deliver [user value] by [real constraint].”
- **Risk:** “The main failure mode was [specific harm or reliability/privacy issue], affecting [users or operation].”
- **Evidence and options:** “We considered [full launch, narrower scope, staged rollout, or delay]. The evidence was [tests, pilot results, incident history, or uncertainty], with [known limitation].”
- **Decision and safeguards:** “I recommended [choice], narrowed [scope] or added [guardrail], and set [release criteria/rollback trigger].”
- **Outcome:** “We shipped/paused [truthful result], measured [outcome], and revisited the risk after [feedback or monitoring].”

Be candid if you underestimated risk or if a safeguard added cost. The strongest answer shows proportionate mitigation and a clear point at which you would stop or roll back, not a claim that every risk was eliminated.

### 64. [Practice prompt] Walk through a technical project you are proud of. Which decisions were yours, what alternatives did you reject, and what would you improve if you restarted it today?

**Answer:**

Select a project you can discuss in depth and organize the walkthrough around your own decisions:

1. **Problem and constraints:** Who needed what, and what made the problem technically or operationally hard?
2. **Your role:** Which components and decisions did you personally own? Be clear about collaborators.
3. **Architecture:** Describe the data flow and key components, including the model's role, evaluation, deployment, and important failure handling.
4. **Trade-offs:** Compare the chosen approach with at least one plausible alternative. Explain why you rejected it using evidence such as quality, complexity, latency, cost, or safety.
5. **Result:** State what changed for users or the system and how you measured it. Use only metrics you can substantiate.
6. **Reflection:** Identify one design or process choice you would revisit, what you would do differently, and how you would validate that improvement.

Keep the initial explanation concise, then invite deeper questions. Do not present team outcomes as solely your work, and do not disclose confidential information. A thoughtful limitation or lesson makes the project discussion more credible than claiming the design was optimal.

## Final readiness checklist

- I can describe the specific OpenAI team and role I am applying to and connect my experience to its stated requirements.
- I can explain a model-backed product from user need through API/model choices, evaluation, deployment, and post-launch learning.
- I can implement and reason about API reliability, streaming, tool dispatch, and state handling.
- I can discuss safety, privacy, and abuse mitigation as design constraints rather than prompt-only solutions.
- I can solve coding problems incrementally, test edge cases, and explain complexity and failure behavior.
- I have evidence-based examples of ownership, humility, collaboration, iteration, and user impact.
- I have confirmed the current interview format and role-specific preparation expectations with the recruiter.

## Research references

### Official OpenAI sources

- [OpenAI Careers](https://openai.com/careers/) — mission, values, and operating principles.
- [Responses API migration guide](https://developers.openai.com/api/docs/guides/migrate-to-responses) — API concepts and migration considerations.
- [Agents guide](https://developers.openai.com/api/docs/guides/agents) — choosing an agent runtime and orchestration approach.
- [Function calling](https://developers.openai.com/api/docs/guides/function-calling) — tool-calling lifecycle and application-side execution.
- [MCP servers](https://developers.openai.com/api/docs/guides/tools-connectors-mcp) — remote MCP connections and approval controls.
- [Structured outputs](https://developers.openai.com/api/docs/guides/structured-outputs) — JSON Schema-constrained responses.
- [Evals](https://developers.openai.com/api/docs/guides/evals) — evaluation workflows and quality measurement.
- [Production best practices](https://developers.openai.com/api/docs/guides/production-best-practices) — reliability and production considerations.
- [Realtime API](https://developers.openai.com/api/docs/guides/realtime) — real-time voice agents, transport, events, and safety identifiers.
- [Safety best practices](https://developers.openai.com/api/docs/guides/safety-best-practices) — red-teaming, human review, input constraints, and user feedback.
- [Data controls](https://developers.openai.com/api/docs/guides/your-data) — API data use, retention, and available controls. Specific eligibility and endpoint behavior can change; consult current documentation for the exact deployment.
- [Safety at OpenAI](https://openai.com/safety/) — high-level safety approach.

### Public candidate-reconstruction reference

- [Dark Interview Questions — OpenAI directory](https://github.com/harry-the-nerd/interview-notes-questions/tree/main/openai) — self-described candidate-reconstructed material. Treat as anecdotal only; this guide does not reproduce its prompts, solutions, or code.
