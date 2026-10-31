# Anthropic — AI / GenAI Engineer Interview Bank

**Research snapshot:** October 31, 2026  
**Target:** AI / GenAI engineers building Claude-powered products, API integrations, agent workflows, and production systems. Anthropic roles vary across product engineering, platform/API engineering, applied AI, infrastructure, and research engineering; use the specific job description to narrow preparation.

Anthropic does not publish a definitive AI Engineer interview loop or official role-specific question bank in the sources reviewed here. The questions below are original practice prompts informed by Anthropic's public careers material and current Claude API, agent, evaluation, and safety documentation. They are **not represented as verbatim or guaranteed interview questions**.

## Research signals and confidence

### Officially documented

- Anthropic's careers page describes company principles including acting for global good, being good to users, a race to the top on safety, empirical simplicity, helpfulness/honesty/harmlessness, and personal ownership.
- Anthropic's developer documentation distinguishes direct model access through the Messages API from managed agents for long-running asynchronous work. It also documents tool use, prompt caching, structured outputs, computer use, evaluations, and data-retention controls.
- Anthropic's public computer-use guidance highlights isolation, least privilege, domain restrictions, human confirmation for consequential actions, and prompt-injection risk.

### Publicly reported material

A public interview-notes repository labels its Anthropic material as reconstructed from candidate experiences and includes coding/system-design preparation content, including a concurrent web-crawler exercise. This is a self-published, anecdotal signal, not an official or current hiring rubric; it does not establish that the same exercise is used for AI Engineer roles. This guide does not reproduce that exercise, its solution, or its code.

### Confidence labels

- **Official context:** supported by Anthropic public careers or technical documentation.
- **Reported signal:** a third-party, candidate-reconstruction source; anecdotal and not official.
- **Practice prompt:** an original question synthesized from the target engineering scope and public technical documentation.

## How to use this bank

1. Read the exact job description and determine whether the role is product engineering, platform/API work, applied AI, infrastructure, or research engineering.
2. Prepare a truthful project deep dive covering user need, architecture, trade-offs, evaluation, operational outcomes, and your own contribution.
3. Practice coding with clear requirements, incremental implementation, meaningful tests, and explicit complexity analysis. Public candidate material is only a weak signal; do not assume a particular round or prompt.
4. For system design, make the model one component of the solution. Define success criteria, trust boundaries, failure behavior, and operations before selecting a model or agent framework.
5. Treat privacy and safety as design constraints, not just prompt instructions. Avoid sharing confidential information from current or former employers.
6. Ask the recruiter about the current interview process, role-specific rounds, coding environment, and team preparation materials.

## A. Product judgment and role understanding

### 1. [Practice prompt] What makes an AI product helpful, honest, and safe in a concrete user workflow? How would you make those qualities measurable?

**Answer:**

I would start with a defined user and task, then translate “helpful, honest, and safe” into observable outcomes. Helpfulness means the user can complete the intended task with less effort or better results; honesty means claims are supported, uncertainty is visible when material, and the system does not imply it performed actions it did not; safety means foreseeable harmful or unauthorized outcomes are prevented or escalated.

Build an evaluation set from representative workflows, edge cases, and high-impact scenarios. Measure task completion and time/effort, factual support and citation quality where applicable, calibrated abstention, policy violations, unauthorized actions, and appropriate escalation. Combine deterministic checks, blinded human review, and carefully calibrated model-assisted evaluation. Include user feedback and production outcomes, segmented by task and risk so averages do not hide failures.

Then ship incrementally with explicit guardrails and monitor real behavior. A model's own assertion that it is confident is not a safety control. When evidence is insufficient, the product should ask, qualify, or hand off rather than fabricate. I would also compare against a simpler non-AI baseline to verify that the model adds real user value.

### 2. [Practice prompt] A team proposes an agent for a task users currently complete with a short form and a deterministic workflow. How would you decide whether an LLM adds enough value to justify its failure modes and operating cost?

**Answer:**

I would first identify the user problem the form does not solve. If the task is already predictable, low-friction, and well served by explicit rules, an agent may add ambiguity, latency, cost, and harder-to-debug failures without improving the outcome. I would examine user research and support data to find concrete friction such as unstructured inputs, frequent exceptions, or accessibility needs.

Compare the current workflow, a simpler deterministic improvement, and a narrowly scoped model-assisted version. Define success and guardrails before prototyping: completion, time/effort, correction rate, error severity, escalation, latency, and cost per successful task. Test on representative and adversarial cases, including malformed or ambiguous requests, and pilot with users under a reversible rollout.

Use the model only where its flexibility produces measurable benefit. A useful hybrid may let the model interpret free text into a schema while deterministic code validates and executes the workflow. Keep the form or a human path available when confidence in the input is insufficient. If the model does not outperform the simpler baseline enough to justify its risks and operating burden, I would recommend not using an agent.

### 3. [Practice prompt] How would you decide whether to use a direct Messages API integration, an application-owned agent loop, or a managed agent runtime for a new product?

**Answer:**

I would decide based on the workflow's control requirements rather than framework preference. A direct Messages API integration is a good fit when the application owns a relatively simple request/response flow and can implement its own prompt, context, tool, and error handling. An application-owned agent loop is appropriate when we need custom orchestration, deterministic budgets, explicit approval boundaries, durable state, or specialized observability. A managed runtime may reduce infrastructure work when its supported tools, state model, scaling, and operational controls fit the product.

I would compare each option against requirements: tool and model flexibility, latency, streaming, retries and timeouts, state persistence, human approval, security isolation, data retention, auditability, portability, operational ownership, and total cost. Build a small vertical slice with representative tasks and failure cases, then measure behavior instead of judging from a demo.

Regardless of runtime, the application remains responsible for authentication, authorization, input/output validation, secrets, tenant isolation, user consent, and safe side-effect handling. I would choose the simplest option that meets the requirements, define an exit or migration path for material platform dependencies, and re-evaluate as the workflow and scale change.

### 4. [Practice prompt] A prototype impresses internal reviewers but has not been tested with representative users. What evidence would you gather before expanding access?

**Answer:**

Internal reviewers can identify obvious issues, but they may know the intended behavior, tolerate friction, or share the builders' assumptions. Before broadening access, I would identify target users and their real tasks, then run moderated sessions or a limited pilot with representative workflows, devices, accessibility needs, and relevant language or domain variation.

Observe whether users can complete the task without coaching, where they correct or abandon the assistant, whether they understand its limitations, and whether citations or suggested actions are trusted appropriately. Pair qualitative observations with pre-defined measures for completion, time/effort, correction rate, quality, latency, cost, and safety incidents. Include cases where the system should ask for clarification, abstain, or hand off.

Use a staged rollout with consent and clear feedback/reporting paths, and set stop conditions before launch. Review failures with human evaluators and add them to regression tests. Expand only if user outcomes improve over the baseline and safety/reliability guardrails hold across important slices; enthusiasm from a small group of internal users is not sufficient evidence.

### 5. [Practice prompt] How do you prioritize model quality, latency, cost, user control, privacy, and safety when product requirements conflict?

**Answer:**

I would separate non-negotiable constraints from optimizable trade-offs. Authorization, privacy obligations, and acceptable safety boundaries should be hard requirements, not variables that can be traded away for latency or cost. Within those boundaries, I would identify the user outcome and quantify trade-offs using task-level evidence rather than a single model-quality score.

For example, compare model tiers or routes on representative tasks, measuring task success, error severity, latency percentiles, cost per successful outcome, user corrections, and escalation. Include user control—such as the ability to review, edit, cancel, or choose a human path—as a design requirement, especially before consequential actions. Make quality and safety differences visible by task and affected group.

If requirements conflict, narrow scope, use a deterministic step for the risky part, offer a slower/high-quality path, or stage deployment while gathering evidence. Document who owns the decision, assumptions, and rollback thresholds. I would not claim that a faster or cheaper model is equivalent without testing, nor use vague safety language to justify a material risk.

### 6. [Practice prompt] Anthropic's careers principles include empirical simplicity and personal ownership. Describe a time you chose a simpler solution or took responsibility for an unclear problem.

**Answer:**

Use a truthful example and show both the evidence for simplicity and the actions you personally took:

- **Situation:** “The team faced [unclear problem], and the first proposal was [complex approach].”
- **Evidence:** “I examined [user needs, failure data, prototype results, or operational constraints] and found that [specific part of the complexity] did not improve the outcome.”
- **Ownership:** “I clarified [ambiguous requirement or decision owner], aligned with [people involved], and took responsibility for [concrete deliverable].”
- **Action:** “I proposed [simpler approach], tested it against [baseline or cases], and added [necessary safeguards] rather than assuming simplicity meant ignoring edge cases.”
- **Result and reflection:** “The outcome was [truthful impact]. I learned [lesson], and next time I would [specific improvement].”

If your role was to build the complex option, explain how you raised the concern constructively and what evidence changed the plan. Avoid claiming sole ownership of a team result or inventing an outcome; the important signal is disciplined judgment and follow-through.

### 7. [Practice prompt] How would you respond if a product leader asked you to ship a capability whose benefits are clear but whose misuse risks are not yet understood?

**Answer:**

I would acknowledge the user benefit, then make the uncertainty concrete before agreeing to a broad launch. I would map likely users, capabilities, misuse paths, affected parties, severity and reversibility of harm, and existing safeguards. I would ask what evidence would make the risk acceptable and involve the appropriate safety, security, legal, or domain owners early rather than treating this as an engineering-only decision.

If feasible, I would propose a narrower, reversible pilot: limit access and capability, use synthetic or low-risk data, add rate and action limits, human approval for consequential behavior, monitoring, and a tested shutdown path. Define success metrics and explicit stop conditions in advance; red-team both intended and adversarial use, and measure false positives as well as bypasses.

If the unknowns include plausible severe harm or an ineffective mitigation, I would recommend delaying or restricting release until we have evidence, and document the rationale and remaining uncertainty. If we do ship a scoped version, assign owners for monitoring and incident response and expand only after the evidence supports it. A clear benefit does not by itself establish that an unbounded launch is responsible.

## B. Claude API and application engineering

### 8. [Practice prompt] How would you structure a Messages API integration for a multi-turn application, including system instructions, message history, stop reasons, and error states?

**Answer:**

I would put a provider adapter behind a server-side application service. The server authenticates the user, loads only authorized conversation history, applies a versioned system instruction, validates the incoming turn, and sends a request with explicit model, token, timeout, and tool configuration. Keep secrets server-side and avoid treating model output as trusted application state.

Store conversation messages in a normalized form with role and typed content blocks, preserving tool-use and tool-result relationships. Apply a context budget deliberately—summarize or trim complete turns rather than silently dropping arbitrary content—and honor tenant access and retention rules. On the response, inspect the stop reason and content blocks: a completed turn can be shown, a token-limit ending may need a continuation or a clear incomplete state, and a tool-use ending must go through validated application-side dispatch before a follow-up model request.

Handle provider errors as explicit states: distinguish invalid requests, authentication/permission failures, rate limits, transient availability failures, and timeouts. Retry only eligible failures within a total deadline; do not convert errors or refusals into successful empty answers. Record request IDs and sanitized operational metadata, and use idempotency/reconciliation where retries could duplicate side effects. Test malformed history, refusal, truncation, tool use, stream interruption, and provider error cases.

### 9. [Practice prompt] What responsibilities belong in your application rather than being delegated to the model API when building an AI product?

**Answer:**

The application must own the security and product guarantees around the model. That includes identity and authentication, authorization and tenant isolation, secrets, input limits, data retention and deletion, tool allowlists, permission checks, domain validation, and confirmation for consequential actions. A model can propose a tool call or response, but the server decides whether it is permitted and whether its arguments satisfy business rules.

The application also owns orchestration and reliability: request deadlines, retry policy, idempotency, rate and spend limits, cancellation, state persistence, fallback eligibility, and explicit handling of refusal, incomplete output, and provider errors. It should validate structured output and verify claims against trusted data where required rather than assuming valid JSON means a correct answer.

Finally, the product team owns evaluation, monitoring, user experience, incident response, and policy decisions. The model API provides inference capabilities and may offer useful controls, but it does not replace least-privilege design, auditing, safe UI confirmation, or evidence that the feature works for its users. These boundaries should be tested independently and end-to-end.

### 10. [Practice prompt] How would you choose among Claude model tiers for a workload with quality, latency, and cost targets? Describe an evaluation-based selection process rather than choosing by model name alone.

**Answer:**

I would first define the workload and acceptance criteria: task types, input sizes, required modalities, quality/error tolerance, latency percentiles, budget, privacy constraints, and expected volume. Build a representative, versioned evaluation set that includes routine cases, difficult examples, and high-risk failures; keep a held-out set for final comparison.

Evaluate eligible model tiers with the same prompts, tools, decoding settings, and input cases. Measure task success and error severity, human-reviewed quality, structured-output validity, refusal/escalation behavior, latency (including time to first token), token usage, and cost per successful task. Segment by task and user-relevant slice; averages can hide a tier that fails a critical category. Include repeated trials when output variability affects the decision.

Choose the least costly tier that meets all hard quality and safety gates with acceptable latency, not simply the cheapest or newest model. If workloads differ, route by task or risk class and test the router itself. Canary the change, compare production outcomes with guardrails, and keep a rollback path. Re-run the suite when models, prompts, tools, or input distributions change.

### 11. [Practice prompt] A model response may end because it completed normally, reached a token limit, or requested a tool. How should the application interpret and handle each state?

**Answer:**

The application should branch on the structured stop reason rather than infer completion from whether text is present. For a normal end-of-turn state, validate the content and return it as a completed answer, subject to any product-specific checks. For a token-limit ending, treat the result as potentially incomplete: do not present partial structured data as valid, and either continue under a bounded policy, ask the model to finish from the preserved context, or return an explicit incomplete state.

For a tool-use ending, validate the requested tool name and arguments against the server's schema, authenticate and authorize the caller, enforce policy and budgets, then execute the tool. Append the correctly correlated tool result and request the model's follow-up; never tell the user the action succeeded before the tool confirms it. Require user approval for consequential actions.

Also handle refusals and provider errors distinctly. Make all terminal states observable and test each branch, including malformed tool calls, tool failures, repeated tool loops, truncation, and a response that mixes text with a tool request. A useful internal response type should preserve status, content, and request identifiers so callers cannot accidentally collapse incomplete or failed work into success.

### 12. [Practice prompt] How would you stream model output to a client while handling partial events, network interruptions, cancellation, backpressure, and a final completion or error state?

**Answer:**

I would have the server translate provider events into a small, versioned application event contract—such as `delta`, `tool_status`, `completed`, and `error`—with a request/turn ID and sequence number. Parse the upstream stream incrementally because network chunks can split event boundaries or UTF-8 characters. Emit text only as deltas, and never represent a partial answer as a completed result.

Propagate client disconnects and explicit cancellation upstream where supported, while tracking whether tools or side effects are already underway. Use bounded buffers and backpressure; if the client cannot keep up, pause reads when possible or terminate cleanly rather than accumulating unbounded memory. Set idle and total deadlines, and distinguish a provider error from an intentional cancellation.

On normal completion send one terminal `completed` event; on failure send a structured, sanitized `error` event and close the stream. If the connection drops, preserve a clear state on the server so a client can query whether the turn completed, failed, or remains active instead of blindly resubmitting. Test split frames, duplicate/out-of-order events, disconnects, cancellation races, slow consumers, and provider truncation.

### 13. [Practice prompt] A client times out while the upstream generation may still be running. How would you design request identity, retry behavior, cancellation, and cost attribution?

**Answer:**

Assign an application-generated request ID and a separate turn/idempotency key before starting generation. Persist a minimal state machine—accepted, running, completed, failed, cancelled—so a client retry with the same key can retrieve the existing result or status instead of starting duplicate work. Scope keys to the authenticated tenant and expire them according to a documented retention policy.

When the client times out or disconnects, signal cancellation upstream and record whether cancellation was acknowledged. A timeout does not prove the provider stopped generating or that a tool side effect did not happen, so reconcile status before retrying. For side-effecting tools, use their own idempotency keys and authoritative operation records. Retry only when the failure is eligible and the request's idempotency semantics are safe.

Attribute provider usage and cost to the request ID, tenant, model, attempt, and outcome, including late completions and failed attempts where usage is available. Avoid logging content merely to correlate costs. Expose status to the client and define whether a late result is stored, discarded, or available for retrieval. Monitor orphaned generations and cancellation effectiveness so timeouts do not silently create unbounded spend.

### 14. [Practice prompt] How would you handle rate limits and transient provider failures without retrying permanent errors or creating a retry storm?

**Answer:**

I would classify failures before retrying. Validation, authentication, permission, and unsupported-feature errors are permanent until the request or configuration changes; return them clearly rather than retrying. For rate limits and transient server/network failures, use a small maximum attempt count, exponential backoff with jitter, a total deadline, and the provider's retry guidance when available.

Add concurrency limits and per-tenant quotas, plus a circuit breaker that temporarily stops sending requests to an unhealthy dependency. Bound retries across layers so an SDK, service, and client do not each multiply attempts. Retry only idempotent operations or requests protected by idempotency keys, and avoid retrying after a tool may have caused a side effect until its state is reconciled.

Measure errors, attempts, delay, queue depth, and recovery by provider/model and tenant. Under sustained overload, shed low-priority traffic or return a retryable response with a sensible retry hint rather than placing everything in an unbounded queue. Any fallback must meet capability, privacy, and quality requirements. Test synchronized failures and recovery to ensure clients do not stampede when the circuit closes.

### 15. [Practice prompt] Your service uses prompt caching for a large stable system prompt and shared reference material. What should remain dynamic, how do you monitor cache effectiveness, and what privacy or freshness issues must you check?

**Answer:**

Keep stable, broadly reusable instructions and reference content in the cacheable prefix, and place per-user context, tenant data, current conversation turns, request-specific instructions, and secrets in the dynamic portion. The exact cache boundary and lifetime depend on the provider's current API behavior, so I would confirm the supported configuration rather than rely on assumptions about implicit caching.

Monitor cache reads/writes or hits where exposed, input tokens and cost, latency, cache creation rate, and quality by prompt version and traffic type. Compare cached and uncached behavior on representative requests to verify that caching changes performance or cost without changing semantics. Version stable content so a policy or reference update invalidates or replaces stale cached material predictably.

Do not place sensitive or tenant-specific content in a shared cache unless isolation and provider controls are explicitly understood and approved. Check retention, residency, eligibility, cache scope, and deletion behavior against current provider documentation and contractual requirements. Avoid assuming that a cache is private, ephemeral, or automatically invalidated. Test cross-tenant isolation and freshness after updates, and keep cache configuration out of user-controlled input.

### 16. [Practice prompt] How would you design an API abstraction that permits model upgrades while preserving a stable application contract and exposing provider-specific features only when required?

**Answer:**

I would define a provider-neutral application contract around the capabilities the product actually uses: typed messages/content blocks, generation settings, streaming events, tool requests/results, usage metadata, refusal/incomplete/error states, and cancellation. Keep provider adapters responsible for translating to and from each provider's request and response format. Preserve raw provider request IDs and sanitized metadata for troubleshooting without coupling business logic to them.

Do not erase meaningful differences to force a false lowest common denominator. Model capabilities should be discoverable or declared (for example, modalities, context limits, structured output, or tool support), and unsupported requests should fail explicitly. When a product needs a provider-specific capability, expose it through a clearly typed extension or capability interface rather than a generic unvalidated “extras” dictionary.

Version the application contract, add contract and conformance tests for every adapter, and test upgrades against a shared behavioral evaluation suite before routing traffic. Keep model identifiers and configuration externalized, record them with each request, and use canaries and rollback. This gives the application a stable interface while acknowledging that model behavior and provider features are not perfectly interchangeable.

### 17. [Practice prompt] How do you keep API keys and user credentials out of browser code, logs, traces, and prompts while still enabling interactive client applications?

**Answer:**

Keep provider API keys exclusively on a trusted server. The browser authenticates to our backend using the product's normal session or OAuth flow; the backend authorizes the user, applies quotas and policy, then calls the provider. If a provider offers short-lived, narrowly scoped client credentials for a specific realtime use case, mint them server-side with the minimum permissions and expiry, and confirm the provider's documented security model.

Never put long-lived keys or user passwords in JavaScript bundles, local storage, URLs, prompts, or client-visible errors. Use a secret manager, rotation, scoped service identities, and separate credentials by environment. Redact authorization headers, cookies, tokens, and sensitive request fields in application logs, traces, crash reports, and analytics; test redaction rather than assuming it works. Keep credentials out of model context and tool results, and provide tools with only the permissions they need.

Use secure cookies or an established token flow, CSRF protections as appropriate, TLS, and short-lived sessions. Audit access to secrets and investigate exposure with a rotation/revocation process. For debugging, correlate with opaque request IDs rather than copying credentials or raw sensitive payloads into traces.

### 18. [Practice prompt] A customer has strict data-retention requirements. How would you determine which request data is retained by your application, the provider, and any enabled API features?

**Answer:**

I would map the complete data lifecycle, not answer from a general assumption about the model API. Inventory what the browser, our services, databases, logs, traces, caches, queues, backups, evaluation systems, and tools collect; identify each data type, purpose, owner, region, retention period, deletion path, and access policy. Include prompts, completions, uploaded files, embeddings, tool results, and derived data.

For the provider, consult current official product/API data-control documentation and the customer's actual organization/project settings and contract. Verify which endpoints and features are covered, what defaults apply, what controls require eligibility or configuration, and how operational or abuse-monitoring retention differs from training use. Confirm any connected third-party service's terms separately. If a detail is uncertain, involve the privacy/account owner and avoid making an unsupported promise.

Document the resulting data-flow and retention matrix, test deletion and access controls end-to-end, and communicate limitations to the customer. Provider-side controls do not automatically govern our own logs, backups, or tools. Minimize collection by default and make retention configuration enforceable, auditable, and consistent across replicas and derived datasets.

## C. Tool use, agents, and computer interaction

### 19. [Practice prompt] Walk through the tool-use lifecycle from model decision to application-side tool execution and the model's follow-up response. Where should validation and authorization occur?

**Answer:**

The application sends the model a request containing context and descriptions of only the tools available for that workflow. The model may return text, a refusal, or a structured tool request with a name and arguments. That request is a proposal, not executable authority. The application validates the response state, checks the tool against a server-side allowlist, validates arguments against a schema and domain rules, authenticates the caller, and authorizes the requested resource and action.

For a permitted call, apply timeouts, budgets, idempotency, and any required user confirmation before invoking the tool with least-privilege credentials. Record a sanitized audit event and return a structured result correlated to the tool-call ID. The application then sends the result back to the model for a follow-up response, again handling refusal, error, truncation, or another tool request explicitly. Enforce a bounded loop and stop conditions.

Authorization belongs in trusted application/service code immediately before the action, not in the prompt or model decision. Recheck permissions and resource state at execution time to handle revocation and stale context. Test malformed calls, unknown tools, cross-tenant access, repeated calls, tool failures, timeouts, and side effects that may complete after a client disconnect.

### 20. [Practice prompt] How would you design tool schemas and descriptions so the model selects the intended tool and produces arguments that can be validated deterministically?

**Answer:**

Expose a small set of narrowly scoped tools with distinct, action-oriented names and descriptions that explain when to use each, what it does, and what it must not do. Avoid overlapping tools with ambiguous semantics. Use a strict schema with required fields, explicit enums, bounded strings/numbers/arrays, and clear nullability; represent identifiers and units unambiguously.

Keep the schema aligned with deterministic server validation. Validate type and structure, then enforce domain rules that a JSON schema cannot express—for example, whether a date range is allowed or an account belongs to the caller. Do not accept hidden authorization claims from model arguments. Tool outputs should have stable, typed results and explicit error states so the model cannot mistake a failure for success.

Test selection and argument quality on representative, ambiguous, adversarial, and out-of-scope requests. Measure invalid-call and wrong-tool rates, then refine descriptions or split responsibilities where evidence shows confusion. Keep descriptions concise but include important constraints, and treat tool definitions as versioned API contracts subject to review and regression tests.

### 21. [Practice prompt] A model requests a payment, account change, or data deletion. How would you prevent a tool call from becoming an authorization decision, and when should the user approve the action?

**Answer:**

The model's request is only an intent signal. The server must authenticate the caller, derive the relevant account from trusted identity, verify permissions and current resource state, validate the action against business policy, and enforce limits immediately before execution. Never authorize from a model-generated user ID, prompt statement, or claimed approval. Use least-privilege service credentials and an audit record tied to the authenticated actor and request.

Require explicit confirmation when the action is consequential, externally visible, costly, difficult to reverse, or affects sensitive data. Show the user the exact target, amount or change, and consequence; bind confirmation to that specific action and an expiry so it cannot be replayed for a different request. Some actions may require a second authorized person or domain-specific review rather than ordinary user confirmation.

Use idempotency keys and transactional state changes. For deletion, clarify scope and irreversibility, validate retention/legal constraints, and report asynchronous completion accurately. If execution times out, reconcile the operation before retrying. Provide cancellation or rollback where feasible and test unauthorized, replayed, stale, and cross-tenant requests.

### 22. [Practice prompt] How would you design an agent loop with bounded steps, tool allowlists, deadlines, retries, and explicit termination conditions?

**Answer:**

I would implement the loop as an application-controlled state machine. Set a maximum number of model turns and tool calls, a monotonic total deadline, per-call timeouts, token/cost limits, and an allowlist of tools for the current task. Validate every model response and tool argument; authorize each action at execution time. A refusal, final answer, invalid response, unknown tool, exhausted budget, cancellation, and timeout should be distinct terminal states.

Retry only transient provider/tool failures with bounded exponential backoff and jitter, and only when the operation is safe to repeat or protected by idempotency. Do not retry malformed requests or permission denials. Track tool-call IDs and results to prevent duplicate execution; require approval before consequential side effects. Keep tool outputs bounded and typed, and treat them as untrusted content.

The loop should stop when the model signals a valid final response, policy requires refusal/handoff, or any hard budget/guardrail is reached. If time or budget is exhausted, return an explicit partial/incomplete status rather than fabricating completion. Propagate deadlines and cancellation downstream, persist minimal state if resumption is required, and test loops, repeated calls, late tool results, and failures at every transition.

### 23. [Practice prompt] When would you use a managed agent service instead of an application-owned agent loop? What state, execution, security, and observability responsibilities change?

**Answer:**

I would consider a managed agent service when its orchestration, state, scaling, tool integration, and operational controls meet the product requirements and reduce meaningful engineering burden. An application-owned loop is preferable when we need precise control over execution semantics, custom durability or approval flows, unusual security boundaries, portability, or deep integration with existing systems. I would compare both with a representative end-to-end workflow and failure tests rather than selecting on feature lists.

Managed execution can shift responsibility for orchestration runtime, scheduling, and some state handling, but it does not transfer product ownership. We still own user authentication and authorization, tenant isolation, tool permissions, secret scope, input/output validation, policy and approvals, retention decisions, and safe handling of side effects. Verify who stores conversation/tool state, how it is encrypted and deleted, what regions and retention options apply, and what happens on retries or restarts.

Observability also needs explicit review: can we trace model turns and tool calls, inspect sanitized failure reasons, attribute cost, set budgets, and export data into our incident workflow? Define service-level objectives, test failure/recovery and migration paths, and identify vendor lock-in. A managed runtime is a component, not a substitute for our security review or operational accountability.

### 24. [Practice prompt] A long-running agent must survive restarts and resume work. What state would you persist, how would you version it, and how would you avoid replaying completed side effects?

**Answer:**

Persist the minimum state needed to resume deterministically: workflow/run ID, tenant and authorization context reference (not a stale authorization grant), state-machine version, current step, bounded conversation or summarized context, pending tool-call IDs, approved action details, deadlines, and completed operation references. Store secrets separately in a secret manager and do not serialize them into prompts or checkpoints.

Version the checkpoint schema and workflow definition. On restore, migrate known older versions explicitly or fail safely with a review path; do not silently interpret incompatible state. Re-authenticate or re-check permissions before every resumed operation, because the caller's access may have changed while the agent was paused.

For side effects, use durable operation records and idempotency keys, recording intent before dispatch and confirmed outcome after. On restart, reconcile ambiguous in-flight actions with the authoritative system instead of blindly replaying them. Use transactional outbox/inbox patterns where useful, and distinguish pending, succeeded, failed, and unknown outcomes. Encrypt checkpoints, enforce tenant isolation and retention, audit resumes, and test crashes before and after each external action.

### 25. [Practice prompt] How would you connect an agent to MCP tools while controlling server trust, tool discovery, authentication, user approval, and the data sent to remote servers?

**Answer:**

Treat each MCP server as an external integration with an explicit trust and data-sharing review. Verify its identity, ownership, transport, version, permissions, and operational/security posture; allowlist approved servers rather than discovering and connecting to arbitrary endpoints at runtime. Review tool schemas and descriptions, but still validate calls and results in application code.

Authenticate using the server's supported secure flow and least-privilege scopes. Keep credentials in a secret manager or secure token broker, never in model context or client logs. Present users with understandable consent for sensitive scopes or consequential actions, and require confirmation where appropriate. Limit which tools are available per task and user, and enforce authorization against the underlying resource independently of the model.

Send only the minimum data required to the remote server, considering that prompts, retrieved content, and identifiers may be sensitive. Apply tenant boundaries, data-loss checks, timeouts, rate limits, output size limits, and audit records. Treat remote tool output as untrusted data that may contain prompt injection. Monitor server changes and revoke access when trust or need changes; test malicious outputs, compromised credentials, and server unavailability.

### 26. [Practice prompt] Design a computer-use agent for a browser task. What environment isolation, credentials, domain limits, approval gates, and audit records would you require?

**Answer:**

Run browser automation in an isolated, ephemeral environment with restricted network egress, no access to internal metadata services or unrelated local files, and resource/time limits. Use a dedicated browser profile per task and clear cookies, downloads, and session artifacts afterward. Keep the environment separate from employee or user personal browsers.

Do not expose passwords, session cookies, or broad credentials to the model. Use short-lived, narrowly scoped credentials injected by a trusted broker only for approved domains and actions. Enforce an origin allowlist and re-check redirects and navigation targets; block downloads, uploads, or cross-domain actions unless explicitly required and validated. Treat page content as untrusted instructions/data and never let it override system policy.

Require the user to preview and approve consequential actions such as purchases, messages, account changes, or data deletion; approval should bind to the exact action and target. Apply action budgets and a stop mechanism. Audit the authenticated user, task/run ID, domains visited, high-level actions, approvals, timestamps, and outcome while minimizing captured page content and personal data. Test prompt injection, deceptive UI, credential theft attempts, redirects, stale pages, and recovery from partial side effects.

### 27. [Practice prompt] A webpage contains instructions that conflict with the user's request and could cause the agent to expose data or take an action. How would you design defenses against this prompt-injection path?

**Answer:**

Treat all webpage text, images, and tool output as untrusted data, even when it appears to address the assistant directly. Separate trusted system/developer policy from user intent and retrieved content using explicit structure, but do not assume delimiters or a warning prompt alone prevent injection. The model should not receive secrets or broad capabilities it does not need.

Enforce the security boundary in the application: restrict browser network access and domains, use least-privilege credentials, authorize every action server-side, validate tool arguments, and require explicit user approval for consequential actions. Keep sensitive data out of page context and prevent page content from changing the task's permissions. If a page requests disclosure or an action outside the user's intent, the agent should stop, explain the conflict, and ask the user rather than comply.

Red-team direct and indirect injection across text, hidden page elements, images, redirects, and tool results. Test whether data can cross tenant or origin boundaries and whether approvals are bound to the exact action. Monitor blocked attempts and false positives, and add regressions for every confirmed issue. The key defense is limiting authority and data exposure so a successful injection still cannot cause an unauthorized outcome.

### 28. [Practice prompt] How do you decide whether to expose multiple specialized agents or one agent with a set of tools? What evidence justifies the extra handoff and state-management complexity?

**Answer:**

Start with the smallest architecture that meets the task. A single agent with a well-scoped tool set is easier to reason about, evaluate, secure, and debug. Multiple agents may help when tasks have genuinely distinct expertise, policies, context needs, or parallel work that improves outcomes, but delegation adds handoff errors, latency, duplicated context, more model calls, and a larger authorization surface.

Compare both designs on the same representative task set. Measure task success, factual/support quality, safety violations, handoff failures, latency, token and tool cost, and human effort. Include ambiguous and adversarial tasks, and inspect whether a specialist contributes a measurable capability rather than merely restating or reformatting another agent's result.

If using multiple agents, define typed input/output contracts, explicit authority boundaries, provenance for delegated claims, budgets per agent, and a clear orchestrator that owns final decisions. Avoid passing secrets or unrestricted tools to every agent. Keep single-agent fallback or human escalation where appropriate. Add the complexity only when observed gains exceed the reliability, cost, and operational burden.

## D. Context, prompting, and retrieval

### 29. [Practice prompt] How would you structure a prompt containing instructions, examples, untrusted user input, retrieved passages, and tool results so that their roles and trust levels are explicit?

**Answer:**

Put stable, high-priority application policy in the system/developer instruction channel and keep user intent in its own message. Place demonstrations in a clearly labeled examples section, separate from the current task. Represent retrieved passages and tool results as quoted or typed data with source IDs and provenance; explicitly say that these are evidence to analyze, not instructions to follow. Use structured content blocks or delimiters to reduce ambiguity, not as the only security control.

Keep dynamic fields narrowly scoped and avoid including credentials, unrelated personal data, or unnecessary conversation history. Preserve source metadata and trust level so the model can distinguish authoritative sources from user-provided or external content. If sources conflict, define how the assistant should report that uncertainty rather than silently selecting one.

Test the exact prompt template with adversarial instructions embedded in each untrusted source, malformed delimiters, and missing or contradictory evidence. Check whether the model follows policy, cites the right source, and abstains when appropriate. Authorization, tool permissions, and output validation must remain enforced by code regardless of prompt structure.

### 30. [Practice prompt] When would XML-style structure or other explicit delimiters help Claude interpret a complex prompt, and how would you test whether the structure actually improves behavior?

**Answer:**

Explicit tags or delimiters can help when a request contains distinct sections—such as task instructions, examples, retrieved documents, untrusted input, and output requirements—or when a long prompt must make boundaries easy to identify. Use consistent, unambiguous labels and escape or encode user content so it cannot accidentally close a delimiter. Structured formats are most useful for clarity and parsing, not as a security boundary or guarantee of correct reasoning.

I would create a controlled comparison between the current prompt and the structured version using the same representative and adversarial inputs, model settings, and evaluation rubric. Measure task success, instruction adherence, source attribution, schema validity, refusal/abstention, and failure rates; include repeated trials if outputs vary. Review failures manually and make sure any observed gain is not just formatting preference or benchmark overfit.

If the difference is small or inconsistent, prefer the simpler prompt. If structure helps, version it and add regression cases for nested delimiters, empty sections, very long content, and malicious instructions inside data blocks. Validate output separately in application code.

### 31. [Practice prompt] How would you decide whether a poor result should be addressed by changing the prompt, retrieval, model, tools, or product workflow?

**Answer:**

First classify the failure using a reproducible trace: Was the user intent understood? Was the needed evidence available and authorized? Did retrieval return the right material? Did the model follow instructions and use the evidence? Did a tool fail, or did the workflow ask the model to make a decision that should be deterministic or human-owned? Avoid changing the prompt before locating the failing stage.

Build a small failure taxonomy and evaluate each candidate fix against the same cases. A prompt change may address ambiguous instructions or output format; retrieval changes may address missing, stale, or poorly ranked evidence; a model change may help a demonstrated reasoning/capability gap; a tool change may improve data access or deterministic execution; and workflow changes may add clarification, validation, approval, or a non-AI step.

Prefer the least complex fix that resolves the root cause without regressing other slices. Measure quality, safety, latency, and cost, and use ablations or paired comparisons where possible. Add the failure as a regression test, stage the change, and monitor production behavior. If evidence is insufficient, gather targeted examples rather than applying a broad speculative prompt rewrite.

### 32. [Practice prompt] A conversation grows beyond the context budget. How would you preserve key instructions and evidence while summarizing or dropping history?

**Answer:**

Treat the context budget as an explicit resource. Preserve current system/developer policy and the latest user request exactly. Retain recent turns that are needed to resolve references and complete tool-call/result pairs atomically; do not keep an unmatched tool call or result. Older conversational content can be summarized into a structured, labeled note that distinguishes user-stated facts, decisions, open questions, and source-backed evidence.

Do not promote a model-generated summary into trusted policy or verified fact. Preserve citations/source IDs for important evidence and re-fetch authoritative data when freshness or permissions matter. Avoid summarizing sensitive information unless needed, and apply the same access and retention controls to summaries as to the original conversation.

Use the target model's tokenizer or a conservative estimate and reserve room for the expected output. If required instructions and the current request alone exceed the budget, ask the user to narrow the task or return an explicit limit error rather than silently dropping critical context. Test long conversations, tool sequences, ambiguous references, and summaries that omit or distort key constraints.

### 33. [Practice prompt] How would you build a document question-answering system with citations and abstention when the retrieved context does not support an answer?

**Answer:**

Ingestion should preserve document identity, version, timestamps, access labels, and chunk-to-source mappings. At query time, authenticate the user and filter for authorization before sending passages to the model. Retrieve with suitable lexical/semantic methods, rerank, and include only relevant, bounded passages with provenance. For time-sensitive content, apply freshness rules and make document updates/deletions propagate to indexes and caches.

Ask the model for claims tied to source IDs and passages, and instruct it to abstain or ask a follow-up when evidence is missing, contradictory, or irrelevant. Validate citations deterministically: each ID must be in the retrieved set and resolve to an accessible source. Citation presence alone does not prove a claim is supported, so evaluate support with human review or calibrated checks on representative cases. Do not treat retrieved text as instructions.

Measure retrieval recall, citation correctness/support, answer accuracy, appropriate abstention, and task success separately. Include questions with no answer, stale/conflicting sources, adversarial documents, and authorization boundaries. If evidence is insufficient, return a clear limitation and useful next step rather than filling gaps from model memory.

### 34. [Practice prompt] Retrieval finds relevant passages, but answer quality is inconsistent. How would you separate problems in parsing, chunking, ranking, context assembly, and generation?

**Answer:**

Trace the pipeline for each failed query and evaluate each stage independently with labeled examples. For parsing, inspect whether tables, headings, lists, metadata, and page boundaries were extracted correctly. For chunking, check that passages preserve semantic units and required neighboring context without becoming too broad. For ranking, measure whether relevant evidence appears near the top and whether lexical, semantic, and reranking methods miss particular query types.

For context assembly, review what actually reached the model: ordering, duplicates, truncation, token budget, source freshness, access filters, and whether conflicting evidence was represented. For generation, assess whether the answer follows the evidence, cites the right passages, and handles gaps or contradictions appropriately. Use retrieval-only relevance judgments and answer-level human review to avoid blaming generation for evidence that was never retrieved.

Run targeted ablations—such as corrected parsing, alternate chunk sizes, reranking, or a controlled prompt/model—on the same evaluation cases. Track stage-specific metrics and user outcomes. Fix the earliest faulty stage when possible, then re-evaluate end-to-end to ensure local gains improve final answers without harming latency, cost, authorization, or coverage.

### 35. [Practice prompt] How would you use prompt caching for long shared context while preventing one tenant's confidential information from appearing in another tenant's request?

**Answer:**

Cache only stable, non-sensitive shared instructions or reference content whose reuse and cache scope are understood. Keep tenant-specific records, user history, credentials, and private retrieved passages outside any shared cache. If private content must be cached, use an explicitly tenant-scoped design with documented provider isolation and deletion behavior; never infer isolation from a cache key without verification.

Separate shared and tenant-specific prompt construction in code, use explicit versioning/invalidation for changed policies or reference material, and test that cache keys cannot collide across tenants. Review provider documentation and contractual terms for cache lifetime, scope, retention, residency, and eligibility. Do not assume cached content is immediately removed or invisible to all other contexts.

Monitor cache effectiveness alongside quality and privacy signals. Create cross-tenant adversarial tests that attempt to retrieve another tenant's unique canary text through prompts, caching, or stale state. Enforce authorization before retrieval and before prompt assembly, minimize data sent, and ensure logs and traces do not leak the private content. Caching is an optimization, never an access-control mechanism.

## E. Evaluation, reliability, and safety

### 36. [Practice prompt] How do you define success criteria for a new LLM feature before tuning prompts or selecting a model?

**Answer:**

Start with the user, workflow, and baseline: what task should improve, for whom, and how is it done today? Define a measurable primary outcome such as successful task completion or reduced effort, then add guardrails for factuality/grounding, safety, privacy, accessibility, latency, availability, and cost. Specify denominators, target populations, time windows, and what counts as a harmful or unacceptable failure.

Create representative test cases before tuning, including normal traffic, edge cases, no-answer cases, and high-impact scenarios. Decide which criteria can be checked deterministically, which require domain-expert or user review, and how production outcomes will be measured. Segment by task and relevant user groups so a global average cannot hide a critical regression.

Set launch gates and rollback conditions in advance, and compare against a non-AI or current-workflow baseline. Treat user satisfaction and model-judge scores as useful but incomplete signals. Only after the success definition is clear would I compare prompts, models, or retrieval choices, so optimization targets the real product outcome rather than a convenient proxy.

### 37. [Practice prompt] Build an evaluation plan combining exact checks, domain-specific tests, human review, and model-based grading. What limitations would you communicate about each?

**Answer:**

I would translate the product requirement into separate, versioned metrics and use the method best suited to each. Exact checks are ideal for objective properties such as schema validity, required fields, tool arguments, citation IDs, permission enforcement, and latency limits. They are fast and reproducible, but cannot establish that a fluent answer is helpful or that a citation actually supports its claim.

Domain-specific tests should encode task rules and high-risk edge cases, ideally with subject-matter input. They catch failures generic benchmarks miss, but can be incomplete, brittle, or overfit if their data overlaps tuning examples. Human review is valuable for nuance, ambiguity, and harm severity; use clear rubrics, trained reviewers, blinded comparisons, and agreement checks. It is slower, costly, and itself subject to inconsistency and sampling bias.

Model-based graders can scale pairwise or rubric-based review, but must be calibrated against human judgments and checked for position, style, and model-family bias. They are not ground truth. Combine these methods with production outcomes, held-out data, and slice analysis; report uncertainty and known coverage gaps. A release decision should not be reduced to one blended score when a hard safety or correctness guardrail fails.

### 38. [Practice prompt] How would you create a representative evaluation set when user traffic is skewed, labels are expensive, and behavior changes over time?

**Answer:**

Start by defining the target population and task/risk segments, then sample from production in a privacy-preserving way rather than letting the most frequent traffic dominate. Preserve a traffic-weighted sample for expected aggregate behavior, and deliberately oversample rare, high-impact, underserved, and difficult cases for slice-level evaluation. Report weighted and unweighted results separately so oversampling does not distort estimates of overall traffic.

When labels are expensive, prioritize cases with high risk, uncertainty, disagreement, novelty, or likely product impact. Use expert labels for domain-critical judgments, clear annotation rubrics, double-label a subset, and adjudicate disagreements. Weak labels or model-assisted triage can reduce effort, but validate their error rates and do not silently treat them as truth.

Maintain a held-out regression set, a rotating recent-traffic set to detect drift, and a documented set of challenge cases. Track dataset provenance, consent, access, and retention. Refresh samples as user behavior, products, and models change; monitor distribution shift and label quality. Avoid tuning repeatedly on the final holdout, and communicate uncertainty where sample sizes for a segment remain small.

### 39. [Practice prompt] A prompt change improves average evaluation scores but causes a serious regression for one user segment. How would you detect, investigate, and decide whether to ship?

**Answer:**

I would treat a serious segment regression as a release blocker until its impact is understood, even if the global average improves. First verify the finding: check instrumentation, segment definitions, assignment, sample size, uncertainty, and whether the comparison used the same cases and model settings. Ensure the segment can be evaluated without exposing sensitive attributes unnecessarily.

Review failure examples with appropriate domain expertise and determine whether the change affected instruction interpretation, language coverage, accessibility, refusal behavior, retrieval, or another factor. Compare baseline and candidate on paired examples for the affected segment and related slices. Check whether the regression is caused by the prompt itself, interaction with a model/provider change, or a skewed evaluation set.

If the harm is material or plausibly high impact, do not ship broadly; roll back, revise the change, or restrict it to a cohort where it passes the gates. A canary does not justify knowingly exposing a harmed segment. Add the failures and segment metric to regression tests, then repeat evaluation and a guarded rollout. Document the decision, uncertainty, and rollback threshold.

### 40. [Practice prompt] What red-team cases would you create for a tool-using assistant, and which failure classes should block a release?

**Answer:**

I would map trust boundaries, user roles, data assets, tools, and possible impacts, then test direct and indirect prompt injection in user messages, retrieved documents, webpages, images, and tool outputs. Include attempts at cross-tenant access, secret disclosure, unauthorized writes, tool-name/argument manipulation, replayed approvals, privilege escalation, destructive actions, rate-limit abuse, and failures when dependencies time out or return malformed data.

Test end-to-end controls—not only whether the model says “no”: authentication, permission checks, retrieval filters, output validation, UI confirmation, audit, cancellation, and recovery. Use isolated accounts and synthetic data so tests cannot cause real side effects. Include benign near-miss cases to measure overblocking, and record reproducible cases, impact, likelihood, and mitigation.

Block launch on reproducible unauthorized data disclosure or action, bypass of required approval, exposure of secrets, cross-tenant leakage, or uncontrolled high-impact behavior. Also block when a safety-critical failure lacks an effective mitigation or monitoring path. Lower-severity issues need an owner and documented risk decision. Retest fixes and preserve regression cases for future model, prompt, and tool changes.

### 41. [Practice prompt] How would you test a model's refusal behavior without over-optimizing for refusals and degrading legitimate user requests?

**Answer:**

Build a balanced evaluation set with requests that clearly require refusal, clearly benign requests in the same topic area, ambiguous cases needing clarification, and requests that should be safely redirected. Include paraphrases, indirect wording, multilingual or accessibility-relevant variants, and adversarial attempts to elicit disallowed behavior. Define the expected action—answer, refuse, clarify, or hand off—before evaluation.

Measure both sides of the error: unsafe compliance and false refusal, segmented by request type and relevant population. Review representative failures with trained human evaluators; automated classifiers and model judges can help scale triage but need calibration and should not be treated as ground truth. Evaluate the response's helpfulness and safe alternative, not only whether a refusal token or phrase appeared.

Use held-out cases so tuning does not overfit the test set. When thresholds or policy change, assess impacts on benign tasks and high-risk cases together. Release only if safety gates pass without unacceptable degradation to legitimate use, and monitor refusal reports, user rephrasing, and escalation outcomes in production. Refusal behavior is a product-level outcome, not a single prompt metric.

### 42. [Practice prompt] What safety controls belong in application code, model instructions, moderation or classification systems, and human review?

**Answer:**

Application code should enforce controls that must be reliable: authentication, authorization, tenant isolation, tool allowlists, argument and domain validation, rate/action limits, secret handling, safe rendering, audit, and confirmation for consequential side effects. These boundaries must remain effective even if the model follows malicious instructions or produces unexpected output.

Model instructions can establish scope, explain safe behavior, ask for clarification, and direct the model to cite evidence or abstain. They guide behavior but cannot guarantee compliance or grant permission. Moderation/classification systems can flag risky inputs or outputs and route them to a restricted workflow, but classifiers have false positives/negatives and should be tested on the product's actual contexts. Do not rely on a single classifier as the only gate for a high-impact action.

Human review is appropriate when errors are consequential, ambiguous, irreversible, or outside the system's validated envelope. Reviewers need sufficient context, clear criteria, authority to stop the action, and a manageable workload. Use defense in depth: assign each control a failure mode and owner, test bypasses and dependency failures, measure both over- and under-blocking, and define escalation and incident response.

### 43. [Practice prompt] How would you decide when a human must verify a model output before it is acted on, especially in high-impact or irreversible workflows?

**Answer:**

Assess severity and reversibility of a wrong output, who may be affected, uncertainty and evidence quality, the system's demonstrated performance on the exact task, and applicable policy or legal requirements. Human review is more important when errors can materially affect health, safety, finances, legal status, access to essential services, or sensitive personal data; when evidence conflicts; or when the action is difficult to undo.

Define a validated operating envelope and use deterministic checks for fields, permissions, and constraints. Route cases outside it—low evidence, novelty, disagreement, missing data, or model/tool uncertainty—to a qualified reviewer. For an irreversible action, show the reviewer the source evidence, proposed action, uncertainty, and consequences, and require an explicit approval bound to that exact action. Do not use model-reported confidence alone as a trigger.

Measure reviewer error and agreement, queue latency, override rates, and downstream outcomes. Human review is not automatically safe: reviewers can be fatigued or over-rely on automation. Provide training, independent verification where warranted, escalation, and audit trails. Reduce review only after representative evidence demonstrates acceptable residual risk, with staged rollout and stop criteria.

### 44. [Practice prompt] What would you log for production debugging of an agent, and how would you balance reproducibility with data minimization and retention requirements?

**Answer:**

For routine observability, log structured metadata: request/run ID, tenant-safe pseudonymous identifier, model and prompt/tool versions, timestamps, latency, token usage, retrieval/tool IDs and outcomes, termination status, and sanitized error categories. Avoid raw prompts, completions, screenshots, credentials, or retrieved content in general logs. Redact sensitive fields before data leaves the request path and verify the redaction with tests.

For a reported or rare incident requiring content, use a separately controlled diagnostic path with purpose limitation, approved access, encryption, short documented retention, and audit logs. Capture only the minimum relevant excerpt or use a user-provided report/synthetic reproduction when possible. Keep identity mappings separate from traces and honor deletion requirements across backups and derived datasets.

Reproducibility can often come from configuration snapshots, model/version identifiers, hashes or IDs for authorized source data, deterministic tool fixtures, and synthetic cases—not indefinite storage of user conversations. Be transparent that nondeterministic models and provider-side changes may prevent exact replay. Define who can access traces, why, and for how long, and measure both privacy-control effectiveness and diagnostic coverage.

### 45. [Practice prompt] How would you safely roll out a model or prompt change using offline tests, limited traffic, monitoring, and rollback criteria?

**Answer:**

Version the full candidate configuration—model, prompt, tools, retrieval/index version, and relevant application code—so results are attributable and rollback is reproducible. Run deterministic contract and safety checks, followed by a representative offline suite with held-out cases, segment analysis, human review where needed, and latency/cost evaluation. Establish release gates and minimum sample requirements before looking at results.

If shadow testing is appropriate, duplicate eligible requests without exposing candidate responses or allowing side effects; minimize/redact copied data and stub tools. Then canary a small, defined cohort and ramp gradually. Monitor task outcomes, refusal/unsafe-compliance rates, latency, errors, cost, and critical segment metrics against the baseline. Use alerts and stop conditions for hard safety or reliability regressions.

Keep rollback simple and tested, with a known-good configuration available even if the new model dependency is degraded. If a gate fails, halt the ramp or revert, investigate affected traffic, and communicate impact. Add confirmed failures to the regression set before retrying. Do not treat “no statistically significant difference” as proof of equivalence when evidence is insufficient.

### 46. [Practice prompt] Users report that the model is less helpful after a provider-side model update, although your application code is unchanged. How would you detect and respond to the regression?

**Answer:**

First establish timing and scope: correlate user reports with model/provider version, region, request type, traffic mix, latency, errors, and application configuration. Check that instrumentation and evaluation data have not changed. Compare recent production examples and a fixed regression set against a known baseline, stratified by task, language, and relevant user segment.

Review failures to distinguish capability/behavior change from retrieval drift, prompt interaction, provider configuration, or changing user traffic. Where possible, run paired evaluations with the same inputs and settings, including repeated trials for stochastic behavior. Track task success and qualitative helpfulness alongside safety, refusal, latency, and cost so a gain in one dimension does not obscure a loss in another.

If the regression is material, reduce exposure or route eligible traffic to a previously validated model/configuration, but only if privacy and capability requirements remain satisfied. Communicate a factual status and avoid promising a provider fix. Add the failures to evaluations, raise the issue through the provider's support path with minimal necessary data, and canary the replacement. Treat model behavior as a dependency that requires monitoring even when application code is unchanged.

## F. Multimodal and real-time applications

### 47. [Practice prompt] Design a real-time voice assistant that supports turn-taking, interruption, tool use, and low latency. Explain client/server responsibilities and failure handling.

**Answer:**

I would start by defining an end-to-end latency budget for audio capture, transport, endpointing, inference, tool execution, and playback. The client should capture and stream bounded audio frames, render partial output, expose mute/stop controls, and detect local disconnects. The server authenticates the session, enforces per-user limits, owns conversation and tool state, and brokers model access so long-lived provider credentials never reach the client.

Use a persistent low-latency transport and explicit turn IDs and event types for audio, transcript, tool status, cancellation, completion, and errors. Keep session state compact and tenant-scoped; persist audio only when necessary and with clear consent/retention. Tools should be allowlisted, validated and authorized server-side, with approval for consequential actions.

For interruption, stop playback immediately, mark the current turn obsolete, cancel generation where supported, and prevent late responses from being presented as current. Reconcile any tool action that may already have caused a side effect. Apply backpressure, session deadlines, concurrency limits, and cost controls. If audio or a provider fails, offer a clear retry or text fallback only when it meets privacy and capability requirements. Monitor time-to-first-audio, turn latency, interruption success, task completion, errors, and cost.

### 48. [Practice prompt] Compare speech-to-speech with a chained speech-recognition, text-reasoning, and speech-generation architecture. Which product and operational requirements drive the choice?

**Answer:**

Speech-to-speech can reduce handoff latency and preserve acoustic information such as timing, prosody, and speaker cues. It may provide more natural turn-taking, but can be harder to inspect, debug, and independently control at each stage; transcription, content moderation, and detailed evaluation may require additional instrumentation.

A chained design—speech recognition, text reasoning, then speech generation—makes intermediate transcripts and decisions easier to inspect, edit, evaluate, and route. Components can be selected or upgraded independently, and text can support accessibility or audit. The trade-offs are extra latency, more service boundaries and failure modes, and possible loss of information in transcription, plus voice-generation consistency concerns.

I would compare both on representative conversations for task success, transcription quality, interruption behavior, latency percentiles, accessibility, safety, privacy, reliability, and total cost. The decision depends on whether natural interaction and low latency outweigh explainability and modular control, and on the sensitivity of the audio data. A hybrid can use speech-to-speech for simple dialogue and switch to a visible transcript or explicit confirmation for complex or consequential actions. Keep a safe failure path if any stage is unavailable.

### 49. [Practice prompt] How would a voice agent handle barge-in while it is speaking, including cancellation of generation and any in-flight tool action?

**Answer:**

Represent each utterance as a turn with an ID and cancellation token. When new user speech is detected, stop client playback immediately, mark the previous assistant turn superseded, and send a cancellation event to the server. Propagate cancellation to the model stream and any safe-to-cancel tool call; discard late deltas or results associated with the old turn rather than appending them to the new response.

Cancellation is not proof that a side effect did not happen. For a tool that may have submitted a payment, sent a message, or changed an account, reconcile its operation status using an idempotency key before retrying or telling the user it was cancelled. Require confirmation for consequential actions before execution, and define whether the user's interruption can revoke an already-approved action.

Use sequence numbers or turn IDs to prevent out-of-order audio from being played. Handle false interruption detection with a short, product-appropriate endpointing strategy, while keeping the user's stop control immediate. Test interruptions during generation, tool execution, network delay, and after the action commits; track cancellation latency and stale-output incidents.

### 50. [Practice prompt] A vision model receives screenshots from a user-controlled website. How would you handle hidden prompt injection, sensitive visual data, and potentially consequential clicks?

**Answer:**

Treat screenshots and page content as untrusted input. Hidden text, overlays, QR codes, or visual instructions may attempt prompt injection, so the model should not receive authority to change task policy, access secrets, or independently authorize actions. Limit the agent to an isolated browser, approved origins, minimal network egress, and a narrow task-specific capability set.

Minimize visual data: capture only the relevant viewport, avoid unrelated tabs and notifications, redact sensitive fields where feasible, and define whether screenshots are transient or retained. Use explicit user consent and retention rules, tenant-scoped storage, and restricted access for any diagnostic capture. Never put credentials or session tokens into model-visible screenshots if they can be avoided; use a secure credential broker.

Before a click or submission, validate the target and action in application code. Require user preview and confirmation for consequential actions such as purchases, sending messages, account changes, or deletion, binding approval to the exact target and operation. Test adversarial page content, misleading controls, redirects, stale screenshots, and accidental cross-origin navigation. Log high-level action metadata rather than indiscriminately storing page images.

### 51. [Practice prompt] How would you evaluate a multimodal assistant for task success, modality-specific quality, latency, user experience, and safety?

**Answer:**

Define task-level success first, then build a versioned evaluation set across relevant modalities and their combinations: text, image, audio, video, and mixed inputs where supported. Include realistic device and capture variation, noisy or incomplete media, accessibility needs, edge cases, and cases where the system should ask for clarification or abstain. Keep a held-out set and document data rights, consent, and retention.

Measure end-task completion and user effort alongside modality-specific quality—for example, transcription accuracy, visual grounding, temporal understanding, or alignment between generated speech and text. Track latency by stage (upload, preprocessing, inference, tool calls, time to first audio/result), reliability, cost, and user corrections. Evaluate safety for sensitive content, identity or privacy leakage, prompt injection, and unsafe actions, with human review for nuanced outcomes.

Segment results by modality, task, language, device/quality conditions, and relevant user groups; averages can hide a failure in one input path. Compare against a baseline workflow and assess confidence intervals or repeated trials where outputs vary. Use a staged rollout with safety gates, monitoring, and rollback, then feed reviewed production failures into the regression suite.

## G. Coding and implementation practice

These are original practice exercises based on common model-backed product engineering work. They are not sourced from a reported interview prompt.

### 52. [Practice prompt] Implement an event-stream parser that reconstructs complete events when network chunks split at arbitrary byte boundaries and handles a terminal event cleanly.

**Answer:**

For a Server-Sent Events stream, the network can split both delimiters and UTF-8 characters, so I would buffer bytes until a full frame is available and decode only complete lines. This simplified parser supports LF/CRLF frames and multi-line `data`; a production version should also cap frame size and handle provider-specific terminal markers.

```python
from collections.abc import Iterable, Iterator


def parse_sse(chunks: Iterable[bytes]) -> Iterator[dict[str, str]]:
    buffer = bytearray()
    for chunk in chunks:
        buffer.extend(chunk)
        while True:
            boundaries = [
                (buffer.find(b"\n\n"), 2),
                (buffer.find(b"\r\n\r\n"), 4),
            ]
            found = [(i, size) for i, size in boundaries if i >= 0]
            if not found:
                break
            end, delimiter_size = min(found)
            frame = bytes(buffer[:end])
            del buffer[:end + delimiter_size]

            fields: dict[str, str] = {}
            data: list[str] = []
            for raw_line in frame.splitlines():
                line = raw_line.decode("utf-8").rstrip("\r")
                if not line or line.startswith(":"):
                    continue
                key, sep, value = line.partition(":")
                if sep and value.startswith(" "):
                    value = value[1:]
                if key == "data":
                    data.append(value)
                elif key in {"event", "id"}:
                    fields[key] = value
            if data:
                fields["data"] = "\n".join(data)
                if fields["data"] == "[DONE]":
                    return
                yield fields
    if buffer.strip():
        raise ValueError("Stream ended with an incomplete event")
```

I would test each delimiter split point, multibyte UTF-8 split points, multiple events in one chunk, comments, empty data, terminal event, and truncated input. A maximum buffered-frame size prevents an unterminated stream from consuming unbounded memory.

### 53. [Practice prompt] Implement a retry wrapper for a model request with jittered exponential backoff, retryable-status classification, a deadline, and a maximum attempt count.

**Answer:**

Use a monotonic deadline so wall-clock changes do not affect the time budget. Retry only known transient statuses, respect `Retry-After` if supplied, and ensure the underlying request timeout is no longer than the remaining budget. Requests that can trigger side effects need idempotency protection.

```python
import random
import time
from collections.abc import Callable
from typing import TypeVar

T = TypeVar("T")
RETRYABLE = {408, 429, 500, 502, 503, 504}


class ProviderError(Exception):
    def __init__(self, status: int, retry_after: float | None = None):
        self.status = status
        self.retry_after = retry_after


def with_retry(
    request: Callable[[float], T],
    *,
    timeout: float,
    max_attempts: int = 4,
    base_delay: float = 0.2,
    max_delay: float = 3.0,
) -> T:
    deadline = time.monotonic() + timeout
    for attempt in range(max_attempts):
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise TimeoutError("Request deadline exceeded")
        try:
            return request(remaining)
        except ProviderError as exc:
            if exc.status not in RETRYABLE or attempt + 1 == max_attempts:
                raise
            remaining = deadline - time.monotonic()
            cap = min(max_delay, base_delay * (2 ** attempt))
            delay = exc.retry_after
            if delay is None:
                delay = random.uniform(0, cap)
            if delay >= remaining:
                raise TimeoutError("No time remains for another attempt") from exc
            time.sleep(delay)
    raise AssertionError("unreachable")
```

The request callback must apply `remaining` to its connect/read timeouts; otherwise an individual attempt can overrun the deadline. I would test permanent errors, rate limits, server errors, deadline exhaustion, and a server-provided retry delay.

### 54. [Practice prompt] Implement a tool dispatcher that validates tool names and arguments, checks authorization, enforces a timeout, and returns a structured success or error result.

**Answer:**

Treat model-generated tool calls as untrusted proposals. Keep an allowlist and schema/domain validation in application code, authorize the caller immediately before execution, and return explicit failures rather than success-shaped defaults.

```python
import asyncio
from collections.abc import Awaitable, Callable
from dataclasses import dataclass
from typing import Any


@dataclass
class Tool:
    validate: Callable[[dict[str, Any]], dict[str, Any]]
    authorize: Callable[[str, dict[str, Any]], bool]
    run: Callable[[dict[str, Any]], Awaitable[Any]]


async def dispatch(
    name: str,
    raw_args: dict[str, Any],
    caller: str,
    tools: dict[str, Tool],
    timeout: float = 5.0,
) -> dict[str, Any]:
    tool = tools.get(name)
    if tool is None:
        return {"ok": False, "error": "unknown_tool"}
    try:
        args = tool.validate(raw_args)
    except (TypeError, ValueError):
        return {"ok": False, "error": "invalid_arguments"}
    if not tool.authorize(caller, args):
        return {"ok": False, "error": "forbidden"}
    try:
        result = await asyncio.wait_for(tool.run(args), timeout=timeout)
    except TimeoutError:
        return {"ok": False, "error": "timeout"}
    except Exception:
        return {"ok": False, "error": "tool_failed"}
    return {"ok": True, "result": result}
```

In production, log sanitized failure details with a correlation ID, add output-size limits, and use idempotency/approval for side effects. A coroutine timeout does not guarantee a remote side effect stopped; reconcile its status before retrying.

### 55. [Practice prompt] Implement a bounded agent runner that tracks elapsed time and tool calls and produces distinct outcomes for success, refusal, provider error, and budget exhaustion.

**Answer:**

Keep budgets and termination states in application code. Each model turn and tool call consumes the same total deadline; an unknown tool or malformed response is not a successful completion.

```python
import asyncio
import time
from collections.abc import Awaitable, Callable
from typing import Any


async def run_agent(
    step: Callable[[list[dict[str, Any]]], Awaitable[dict[str, Any]]],
    tools: dict[str, Callable[[dict[str, Any]], Awaitable[Any]]],
    *,
    max_tool_calls: int,
    timeout: float,
) -> dict[str, Any]:
    deadline = time.monotonic() + timeout
    messages: list[dict[str, Any]] = []
    calls = 0
    while True:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            return {"status": "budget_exhausted"}
        try:
            response = await asyncio.wait_for(step(messages), remaining)
        except TimeoutError:
            return {"status": "budget_exhausted"}
        except Exception:
            return {"status": "provider_error"}

        if response.get("refusal"):
            return {"status": "refusal"}
        if response.get("done"):
            return {"status": "success", "result": response.get("text", "")}
        call = response.get("tool_call")
        if not isinstance(call, dict) or call.get("name") not in tools:
            return {"status": "provider_error", "reason": "invalid_tool_call"}
        if calls >= max_tool_calls:
            return {"status": "budget_exhausted"}

        calls += 1
        try:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                return {"status": "budget_exhausted"}
            result = await asyncio.wait_for(
                tools[call["name"]](call.get("arguments", {})), remaining
            )
        except TimeoutError:
            return {"status": "budget_exhausted"}
        except Exception:
            return {"status": "provider_error", "reason": "tool_failed"}
        messages.append({"tool": call["name"], "result": result})
```

The example omits tool schemas and authorization for brevity; a real runner must validate and authorize every call and bound result size. Distinguish provider failures from tool failures in telemetry, even if both map to a user-safe error. Test refusal, completion, unknown tools, repeated calls, tool exceptions, and deadline exhaustion.

### 56. [Practice prompt] Given a conversation and token budget, trim or summarize old turns without dropping system instructions or separating a tool call from its corresponding result.

**Answer:**

I would preserve system instructions and the newest user turn, then remove the oldest complete conversational groups until the token budget fits. A group should include an assistant tool call and all corresponding tool results so the remaining history is valid. If required content alone exceeds the budget, return an explicit error or ask the user to narrow the request rather than dropping the system message.

```python
def trim_history(messages, budget, count_tokens):
    system = [m for m in messages if m["role"] == "system"]
    conversation = [m for m in messages if m["role"] != "system"]
    groups, current = [], []
    for message in conversation:
        if message["role"] == "user" and current:
            groups.append(current)
            current = []
        current.append(message)
    if current:
        groups.append(current)

    for group in groups:
        requested = {
            call["id"]
            for message in group if message["role"] == "assistant"
            for call in message.get("tool_calls", [])
        }
        returned = {
            message.get("tool_call_id")
            for message in group if message["role"] == "tool"
        }
        if requested != returned:
            raise ValueError("Incomplete tool-call/result group")

    newest_user = next(
        (i for i in range(len(groups) - 1, -1, -1)
         if any(m["role"] == "user" for m in groups[i])),
        None,
    )
    if newest_user is None:
        raise ValueError("No user turn to preserve")
    kept = [groups[newest_user]]
    if count_tokens(system + kept[0]) > budget:
        raise ValueError("Required context exceeds token budget")
    for group in reversed(groups[:newest_user]):
        candidate = system + group + sum(kept, [])
        if count_tokens(candidate) <= budget:
            kept.insert(0, group)
    return system + sum(kept, [])
```

Use the target model's tokenizer or a conservative estimate and reserve output tokens. A production summarizer should summarize only complete older groups, preserve source IDs and explicit uncertainty, and never convert generated summaries into trusted instructions. Test missing tool results, multiple calls, long system instructions, and a newest turn that exceeds the budget.

### 57. [Practice prompt] Given usage events grouped by model, tenant, status, and timestamp, compute cost and latency summaries while handling failed requests and missing usage fields explicitly.

**Answer:**

I would aggregate by the requested dimensions and keep missing values distinct from zero. Failed requests may still incur token charges and should count in operational latency/error summaries, while success rates and cost per successful task need their own denominators. Use a versioned price table and avoid estimating unknown usage as free.

```python
from collections import defaultdict
from collections.abc import Iterable
from math import ceil


def percentile(values: list[float], p: float) -> float | None:
    if not values:
        return None
    ordered = sorted(values)
    return ordered[max(0, ceil(p * len(ordered)) - 1)]


def summarize(events: Iterable[dict], prices: dict[str, tuple[float, float]]) -> dict:
    groups = defaultdict(lambda: {
        "requests": 0, "failed": 0, "latencies_ms": [],
        "known_cost": 0.0, "priced_requests": 0, "missing_usage": 0,
    })
    for event in events:
        key = (event.get("tenant", "unknown"),
               event.get("model", "unknown"),
               event.get("status", "unknown"),
               event.get("timestamp", "unknown"))
        row = groups[key]
        row["requests"] += 1
        if event.get("status") != "success":
            row["failed"] += 1
        latency = event.get("latency_ms")
        if isinstance(latency, (int, float)) and latency >= 0:
            row["latencies_ms"].append(float(latency))

        model = event.get("model")
        inp, out = event.get("input_tokens"), event.get("output_tokens")
        if (model not in prices or not isinstance(inp, int) or inp < 0
                or not isinstance(out, int) or out < 0):
            row["missing_usage"] += 1
            continue
        input_price, output_price = prices[model]
        row["known_cost"] += (inp * input_price + out * output_price) / 1000
        row["priced_requests"] += 1

    return {
        key: {
            **{name: value for name, value in row.items()
               if name != "latencies_ms"},
            "p50_latency_ms": percentile(row["latencies_ms"], 0.50),
            "p95_latency_ms": percentile(row["latencies_ms"], 0.95),
        }
        for key, row in groups.items()
    }
```

In production I would aggregate timestamps into explicit time windows, document percentile and pricing conventions, and account for provider-specific cached tokens or other billable features. Report coverage (`priced_requests` versus `requests`) so partial usage data is visible; a failed request's known usage still contributes cost.

### 58. [Practice prompt] Implement a job scheduler for agent tasks with dependencies and limited concurrency. Explain cycle detection, retries, idempotency, and what happens when a worker crashes.

**Answer:**

I would validate the dependency graph before dispatch so cycles fail fast. Then execute topological waves with a concurrency semaphore; if a task fails after bounded retries, mark its dependents blocked while allowing independent tasks to continue.

```python
import asyncio
import logging
from collections import defaultdict
from collections.abc import Awaitable, Callable

logger = logging.getLogger(__name__)


async def schedule(
    tasks: set[str],
    dependencies: list[tuple[str, str]],  # (task, prerequisite)
    run: Callable[[str, str], Awaitable[None]],  # task ID is idempotency key
    *,
    concurrency: int,
    max_attempts: int = 3,
) -> dict[str, str]:
    if concurrency < 1 or max_attempts < 1:
        raise ValueError("concurrency and max_attempts must be positive")
    children = defaultdict(list)
    indegree = {task: 0 for task in tasks}
    prereqs = defaultdict(list)
    for task, prerequisite in dependencies:
        if task not in tasks or prerequisite not in tasks:
            raise ValueError("Unknown task in dependency")
        children[prerequisite].append(task)
        prereqs[task].append(prerequisite)
        indegree[task] += 1

    ready = sorted(task for task, degree in indegree.items() if degree == 0)
    waves = []
    seen = 0
    while ready:
        wave = ready
        waves.append(wave)
        seen += len(wave)
        next_ready = []
        for task in wave:
            for child in children[task]:
                indegree[child] -= 1
                if indegree[child] == 0:
                    next_ready.append(child)
        ready = sorted(next_ready)
    if seen != len(tasks):
        raise ValueError("Dependency cycle detected")

    semaphore = asyncio.Semaphore(concurrency)
    status: dict[str, str] = {}

    async def execute(task: str) -> str:
        if any(status[parent] != "succeeded" for parent in prereqs[task]):
            return "blocked"
        async with semaphore:
            for attempt in range(max_attempts):
                try:
                    await run(task, task)
                    return "succeeded"
                except Exception:
                    logger.exception("Task attempt failed: %s", task)
                    if attempt + 1 < max_attempts:
                        await asyncio.sleep(min(2 ** attempt, 8))
        return "failed"

    for wave in waves:
        results = await asyncio.gather(*(execute(task) for task in wave))
        status.update(zip(wave, results))
    return status
```

The worker must honor the stable task ID as an idempotency key; otherwise a crash after a side effect but before recording success can duplicate work on retry. In production, persist task state and reconcile ambiguous outcomes with the downstream system before retrying. Add bounded backoff, failure logs, and a dead-letter/manual-recovery path; the example keeps retry handling intentionally compact.

## H. System-design practice

### 59. [Practice prompt] Design a multi-tenant Claude-powered assistant API with streaming responses, authentication, quotas, state management, data-retention controls, observability, and graceful degradation.

**Answer:**

Place an authenticated gateway in front of stateless request workers. The gateway derives tenant identity from a trusted credential, checks project membership, enforces per-tenant concurrency/rate/spend quotas, and attaches a trusted tenant context. Every state read, retrieval, and tool operation must be scoped to that tenant. Store conversation state encrypted with explicit retention/deletion controls; keep provider keys server-side.

Workers call the model through a provider adapter with request deadlines, bounded retries, and circuit breakers. Stream normalized events to clients with backpressure, sequence IDs, and cancellation propagation; a disconnect should stop safe-to-cancel work. Represent refusal, incomplete output, tool use, and provider errors as distinct states. Execute tools only after schema validation and authorization, and require confirmation for consequential actions.

Instrument request IDs, model/prompt versions, latency, token usage, tool outcomes, and sanitized failures without putting raw content in general logs. Degrade with load shedding, clear retryable errors, or a previously approved fallback only when capability, privacy, and quality requirements match. Test tenant isolation, quota enforcement, partial streams, provider outages, cancellation races, and recovery. Monitor per-tenant fairness, task outcomes, p95/p99 latency, error rates, and cost per successful task.

### 60. [Practice prompt] Design a research assistant that retrieves sources, summarizes evidence, cites claims, and can call external tools. How do you handle source trust, freshness, privacy, and unsupported answers?

**Answer:**

Ingest sources with provenance, owner, version, timestamps, access labels, and deletion metadata. At query time, authenticate the user and filter for access before passages reach the model; post-filtering alone can expose restricted content. Use a retrieval strategy suited to the corpus, such as lexical and semantic search with reranking, and freshness rules for time-sensitive material. External tools should be individually allowlisted and permission-checked.

Ask the assistant to connect material claims to source IDs and passages. Validate that citations resolve to retrieved, authorized, current sources, then evaluate whether they actually support the claims. Treat source and tool contents as untrusted data, not instructions. If sources are missing, stale, or contradictory, the assistant should disclose uncertainty, ask a clarifying question, or abstain rather than invent support.

Measure retrieval recall and precision, citation validity/support, factual correctness, freshness, appropriate abstention, and user task completion separately. Test no-answer cases, adversarial documents, permission boundaries, and source deletion/update propagation. Minimize data sent to external tools, keep an auditable source trail, and monitor failures in production with privacy-aware telemetry.

### 61. [Practice prompt] Design an agent that can operate a browser to complete user-approved tasks. Cover sandboxing, credential handling, prompt-injection defenses, approval boundaries, durable state, and auditability.

**Answer:**

Run browser work in an ephemeral, isolated environment with restricted egress, resource/time limits, and no access to internal metadata services or unrelated local files. Use a dedicated profile per task and clear cookies/downloads afterward. Enforce origin allowlists and re-check redirects and navigation targets.

Keep passwords and broad session credentials out of model context. Use a secure broker for short-lived, least-privilege credentials scoped to approved domains and actions. Treat page text, images, and tool output as untrusted; prompt instructions and delimiters help but are not the security boundary. The application must enforce allowed actions, validate targets, and prevent page content from expanding permissions.

Require user preview and confirmation for consequential actions, binding approval to the exact action and target. Persist minimal versioned workflow state, approval status, and idempotent operation references so the task can resume safely; re-check authorization on resume. Audit actor, run ID, domains, high-level actions, approvals, and outcomes while minimizing stored page content. Test prompt injection, deceptive UI, credential exposure, replay, and crashes around side effects.

### 62. [Practice prompt] Design an evaluation and rollout platform for model, prompt, and tool changes. How would you support reproducible offline testing, human feedback, canaries, and rollback?

**Answer:**

Package each candidate as an immutable version of model/configuration, prompt, tool schemas/policies, retrieval index, and application code. Run deterministic contract/security tests first, then representative offline evaluations with held-out cases, segment coverage, human review for nuanced outcomes, and cost/latency checks. Preserve dataset provenance and avoid tuning against the final holdout.

Use paired comparisons against the baseline where possible and report effect sizes, uncertainty, and slice results. Model judges can scale review only after calibration against human labels; retain the rubric and human audit trail. Shadow eligible production requests without exposing candidate responses or allowing side effects, and minimize/redact copied data.

Canary a small cohort after gates pass, then ramp gradually while monitoring task success, safety incidents, refusals, latency, errors, and cost. Define stop thresholds in advance, keep a known-good configuration, and test rollback independently of the failing model dependency. If a gate fails, halt/revert, investigate, and add confirmed failures to the suite before retrying.

### 63. [Practice prompt] Design a long-running asynchronous agent service that can pause for user approval, resume after a restart, and avoid duplicate side effects.

**Answer:**

Represent each run as a durable state machine with states such as queued, running, awaiting approval, succeeded, failed, cancelled, and expired. Persist a versioned checkpoint containing run/tenant IDs, current step, bounded context, pending tool request, deadline, and operation references; keep secrets in a secret manager, not in the checkpoint. Use a queue and worker leases/heartbeats so abandoned jobs can be recovered after crashes.

When approval is required, store the exact proposed action, target, relevant evidence, approver, and expiration. Present it through an authenticated channel; bind approval to that immutable action and re-check current authorization and resource state at resume. Expired or changed requests require new approval.

For side effects, record intent before dispatch and use downstream idempotency keys and durable operation IDs. After restart or timeout, reconcile ambiguous operations instead of blindly replaying them. Apply bounded retries, per-run budgets, cancellation, tenant quotas, retention/deletion, and audit. Test crashes before/after dispatch, duplicate queue delivery, revoked permissions, approval replay, and partial external completion.

### 64. [Practice prompt] A high-volume product must route between model tiers to meet quality and latency objectives under a strict budget. Design routing, fallback, evaluation, and spend controls.

**Answer:**

Define task classes and hard requirements first: quality/safety threshold, latency SLO, modality/context needs, privacy constraints, and budget. Evaluate candidate tiers on the same representative and held-out examples, measuring task success, error severity, latency percentiles, token usage, and cost per successful outcome. Route using explicit features such as task type, input length, required capability, and risk—not an unvalidated model self-confidence score.

Use the least costly tier that passes the gates for a task class, escalating to a stronger tier only when a measured condition warrants it. Keep routing rules versioned and evaluate them end-to-end to detect misclassification. A fallback is eligible only if it meets the same privacy, capability, and safety requirements; otherwise return a clear temporary error or offer a non-model path.

Enforce tenant and global spend/concurrency limits, token ceilings, deadlines, and load shedding. Monitor quality, safety, latency, retries, and cost by route and segment; canary routing changes with rollback thresholds. Prevent retries or escalation loops from multiplying spend, and alert on budget anomalies before quotas are exhausted.

### 65. [Practice prompt] Design privacy-aware observability for an AI application so engineers can investigate rare failures without indiscriminately storing raw user content.

**Answer:**

Separate routine metrics from content-bearing diagnostics. Default telemetry should include request/run IDs, model and prompt versions, latency, token counts, tool/retrieval IDs and outcomes, termination state, and sanitized error categories—not raw prompts, completions, screenshots, or retrieved documents. Use aggregation and sampling with tenant-safe dimensions.

For rare incidents requiring content, create an access-controlled diagnostic path with a specific purpose, approval, encryption, short documented retention, and audit logs. Capture only the minimum relevant excerpt, preferably from a user report or reproducible synthetic case. Keep identity mappings separate, redact where feasible, and honor deletion requirements across logs, backups, and derived datasets.

Reproducibility can rely on immutable configuration snapshots, source/version IDs, hashes, deterministic tool fixtures, and synthetic inputs rather than indefinite conversation storage. Be transparent that nondeterministic models and provider updates can limit exact replay. Test redaction, access controls, retention, and deletion; monitor both diagnostic coverage and privacy-control effectiveness.

### 66. [Practice prompt] Design a safe migration from a short-context workflow to a long-context agent. How would you compare quality, manage state, limit risk, and decide whether the increased complexity is worthwhile?

**Answer:**

Start by identifying the user problem the current workflow cannot handle and establishing a baseline. A larger context window or agent loop is not a benefit by itself; compare the existing short-context workflow, a retrieval/summarization improvement, and the proposed long-context agent on the same representative tasks. Measure task completion, evidence use, recall of relevant details, latency, cost, failure severity, and user effort.

For migration, version the prompt and state schema, preserve source provenance and access labels, and define how history is selected, summarized, or expired. Do not treat generated summaries as trusted instructions or allow stale context to override current policy. Bound tool calls, time, and spend; require confirmation for side effects; and preserve a simple fallback path.

Run offline and shadow evaluations, then a reversible canary with segment and safety gates. Expand only if the agent produces a meaningful improvement over simpler alternatives without unacceptable privacy, quality, latency, or operational costs. If it does not, retain the simpler workflow. Define rollback criteria, monitor drift, and add migration failures to regression tests.

## I. Behavioral and project deep-dive practice

Anthropic's careers material describes mission, user care, humility implicit in empirical iteration, safety, and ownership. Prepare genuine examples from your own experience; these are practice prompts, not claims about exact interview questions.

### 67. [Practice prompt] Tell me about a time you shipped a user-facing feature and then changed it based on real-world feedback. What did you learn and what improved?

**Answer:**

Use a real example and explain the feedback loop, not just the initial launch:

- **Context:** “We shipped [feature] for [user group] to help with [task]. I owned [your specific responsibilities].”
- **Signal:** “After launch, [interviews, support reports, usage data, or task outcomes] showed [specific mismatch or friction]. We had expected [assumption], but observed [evidence].”
- **Change:** “I worked with [partners] to change [workflow/model behavior/UI/guardrail], then tested it with [users or evaluation cases].”
- **Result and learning:** “The change led to [truthful, measured outcome] or reduced [specific failure]. I learned [lesson] and now [concrete practice] helps us collect feedback earlier.”

Be clear about your personal contribution and the limits of the evidence. If metrics were not available, describe the qualitative signal honestly and explain what you would instrument next time. Do not invent launch outcomes or imply that a team result was solely yours.

### 68. [Practice prompt] Describe a time you surfaced a safety, privacy, or reliability concern that could have delayed a launch. How did you handle the trade-off?

**Answer:**

Choose an actual example and show how you made the concern actionable:

- **Risk:** “I noticed [specific failure mode], which could affect [users/data/system] with [severity or likelihood].”
- **Evidence:** “I reproduced or assessed it by [test, threat model, monitoring, or review]. What we knew was [facts]; what remained uncertain was [unknown].”
- **Response:** “I raised it with [decision-makers] and proposed [mitigation, narrower scope, staged rollout, or delay], including [cost/trade-off].”
- **Decision and outcome:** “We decided [what happened], with [owner, guardrail, and stop condition]. The result was [truthful outcome], and I learned [lesson].”

Demonstrate respectful escalation and ownership rather than framing safety as an obstacle or claiming risk was eliminated. If you have not faced a launch decision, use a real reliability or privacy concern from a project and be explicit about its scope.

### 69. [Practice prompt] Tell me about a time you chose a simpler technical approach over a more sophisticated one. How did you validate that the simpler approach was sufficient?

**Answer:**

Use a genuine trade-off where simplicity was supported by evidence:

- **Need:** “We needed to solve [problem] under [constraints]. The sophisticated option was [approach], while a simpler option was [alternative].”
- **Evaluation:** “I compared them on [correctness, user outcome, latency, cost, reliability, or maintenance], using [prototype, benchmark, or user evidence].”
- **Decision:** “The simpler design met [explicit acceptance criteria] and avoided [unneeded complexity or operational burden], so I chose [approach]. I retained [specific safeguard] for the edge case.”
- **Outcome:** “It resulted in [truthful impact]. The limitation was [honest limitation], and I would revisit the decision if [trigger].”

Avoid equating “simple” with “quick hack.” Explain what you tested and which requirements would have invalidated the choice. If the alternative was not implemented, state how you assessed it without pretending to have comparative production data.

### 70. [Practice prompt] Describe a disagreement with a teammate about a technical decision. How did you communicate directly and kindly, and what evidence helped resolve it?

**Answer:**

Tell a specific story without making the teammate a villain:

- **Decision:** “We disagreed about [technical choice]. I preferred [option] because [reason], while my teammate prioritized [their concern].”
- **Conversation:** “I asked what constraints or evidence I might be missing, then explained my concerns directly and respectfully. We agreed on criteria such as [correctness, quality, latency, cost, safety, or maintainability].”
- **Evidence:** “We used [experiment, benchmark, incident data, design review, or user need] to compare options. The result showed [what it did and did not establish].”
- **Resolution:** “We chose [outcome], documented the trade-off, and [follow-up]. I learned [lesson] about collaborating or validating assumptions.”

If you changed your position, explain why; if the team chose the other option, explain how you supported it. Use a real example and distinguish measurable evidence from judgment.

### 71. [Practice prompt] Tell me about a difficult failure or incident. What did you own, how did you communicate uncertainty, and what did you do to repair the system or relationship?

**Answer:**

Use a truthful incident and separate immediate response from the later learning:

- **Impact and ownership:** “The failure was [what happened], affecting [users/system]. I owned [specific responsibility] and recognized [what I did or missed].”
- **Communication:** “At first, we knew [facts] but not [unknowns]. I told [stakeholders/users] what was confirmed, what we were investigating, and when they would hear back.”
- **Mitigation:** “I took [containment/rollback/recovery action], coordinated with [people], and verified recovery using [signals].”
- **Repair and prevention:** “Afterward, I [follow-up with affected people/team], and added [test, monitoring, process, or design change].”
- **Reflection:** “The lesson was [specific change in how you work].”

Do not overstate certainty or blame others. If the failure involved a relationship, explain how you listened, acknowledged your part, and followed through. If it was not a production incident, be transparent about scale and use a real project failure.

### 72. [Practice prompt] Walk through an AI or infrastructure project you personally built. What decisions were yours, what did you measure, and what would you change now?

**Answer:**

Choose a project you can explain deeply and organize it around your own work:

1. **Problem and constraints:** Who needed what, and what were the correctness, data, latency, cost, or reliability constraints?
2. **Your role:** Identify the parts and decisions you personally owned, and credit collaborators.
3. **Design:** Walk through the important components and data flow. Explain why you selected the model, retrieval, infrastructure, or algorithm and what alternatives you rejected.
4. **Validation:** Describe the tests, measurements, baselines, and failure cases. State hardware/configuration or dataset details where they affect the result.
5. **Outcome:** Share only results you can substantiate and explain their limitations.
6. **Reflection:** Name one decision you would revisit, what evidence you would gather, and how you would improve it today.

Keep the opening concise, then go deeper based on follow-up questions. Do not present team outcomes as solely your work, disclose confidential details, or invent metrics. A credible account of constraints and what you would change is stronger than claiming the project was optimal.

## Final readiness checklist

- I can explain why the specific Anthropic role fits my skills without assuming every team has the same interview process.
- I can build and debug a Messages API integration, tool loop, streaming endpoint, and stateful application.
- I can explain when an agent is warranted and how to bound its authority, state, time, and spend.
- I can discuss computer-use and prompt-injection risks with concrete isolation and human-approval controls.
- I can design evaluations for useful behavior, safety, and reliability and use them to make release decisions.
- I can solve coding problems incrementally and explain correctness, edge cases, and complexity.
- I have truthful stories demonstrating user focus, ownership, iteration, safety judgment, and collaboration.
- I have confirmed current interview format and role-specific expectations with the recruiter.

## Research references

### Official Anthropic sources

- [Anthropic Careers](https://www.anthropic.com/careers) — mission and company principles.
- [Intro to Claude](https://platform.claude.com/docs/en/intro) — Messages API and managed-agent use cases, model selection, and product entry points.
- [Features overview](https://platform.claude.com/docs/en/build-with-claude/overview) — Claude API capabilities.
- [Tool use overview](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview) — tools and application-side execution.
- [Claude Managed Agents](https://platform.claude.com/docs/en/managed-agents/overview) — managed agent runtime concepts.
- [Prompt engineering overview](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview) — success criteria, empirical tests, and prompt iteration.
- [Prompt caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching) — cache prefixes, breakpoints, and usage.
- [Computer use tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool) — desktop interaction and security considerations.
- [Define success criteria and build evaluations](https://platform.claude.com/docs/en/test-and-evaluate/develop-tests) — evaluation design.
- [API data retention](https://platform.claude.com/docs/en/manage-claude/api-and-data-retention) — current data-handling and retention details.
- [Building effective agents](https://www.anthropic.com/research/building-effective-agents) — agent architecture principles; the article notes that its tooling landscape has changed and points to newer Managed Agents documentation.

### Public candidate-reconstruction reference

- [Dark Interview Questions — Anthropic directory](https://github.com/harry-the-nerd/interview-notes-questions/tree/main/anthropic) — self-described candidate-reconstructed material. Treat as anecdotal only; this guide does not reproduce its problem statement, solution, or code.
