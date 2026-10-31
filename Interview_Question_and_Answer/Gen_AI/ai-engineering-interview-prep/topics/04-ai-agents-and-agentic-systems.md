# 04. AI Agents and Agentic Systems

Source entries are in their original order. Use the space after each heading to draft an answer.

## What is an AI agent, and how does it differ from a simple LLM call?

**Answer:**

### Definition

An **AI agent** is a system that uses a model to interpret a goal, decide on one or more actions, observe the results, and continue until it completes the task, reaches a stopping condition, or needs human input. An agent typically combines a model with instructions, tools, state or memory, orchestration logic, and safety controls.

A simple LLM call maps a supplied prompt to a response and normally ends there. It may produce text that looks like a plan, but unless an application executes actions and feeds back observations, that call is not a tool-using agent loop.

### Typical agent loop

1. Receive a goal and relevant state.
2. Decide whether to respond directly or request an allowed action.
3. Validate and execute the action through the host application.
4. Add the tool result as an observation.
5. Continue, ask the user, or stop with a result.

For example, a simple call can explain how to find a flight. A travel agent could search approved booking APIs, compare options under user constraints, present a choice, and—only after explicit authorization—book it.

### What makes the system agentic?

“Agent” is a spectrum, not a binary label. A fixed workflow with one model call and predefined tool can be automation; an adaptive loop that selects tools and adjusts its plan is more agentic. The useful engineering question is how much autonomy is necessary and how reliably it can be bounded.

### Risks and controls

Agents can make incorrect plans, repeat actions, misread tool output, or be manipulated by untrusted content. Limit tool permissions, validate every argument and result, bound steps/time/cost, make side effects idempotent, require confirmation for high-impact actions, and provide logging, recovery, and a stop path. Authorization belongs in the application, not in the model’s judgment.

### Concise interview answer

“A simple LLM call produces a response from one prompt. An agent adds an orchestration loop: it can choose an allowed tool or action, receive observations, update its plan, and continue until a goal or stop condition is reached. The model is only one part; tools, state, policy enforcement, and execution are in the harness. I use the minimum autonomy necessary, with least-privilege tools, validated actions, bounded loops, human confirmation for consequential side effects, and explicit failure recovery.”

### Revision summary

| System | Behavior |
|---|---|
| Simple LLM call | Prompt in → response out. |
| Agent | Goal/state → action selection → tool observation → repeat/stop. |
| Components | Model, tools, state, orchestration, policy, monitoring. |
| Risk controls | Least privilege, validation, budgets, confirmation, recovery. |

<br><br><br>

## AI Agent Memory

**Answer:**

### What “memory” means for an agent

An agent’s **memory** is the state it can use beyond the current model invocation. It may include recent conversation history, task progress, retrieved knowledge, prior events, user preferences, or structured application state. Many model APIs are stateless: the application must explicitly select and supply relevant state on each call.

Memory is not automatically reliable, private, or permanent. Stored content can be stale, false, sensitive, or influenced by prompt injection. Separate durable facts from temporary task state, retain provenance and timestamps, and treat retrieved memory as data rather than as higher-priority instructions.

### Common forms

| Memory type | Example | Best use |
|---|---|---|
| Working/context memory | Current messages, plan, tool observations. | Completing the active task. |
| Episodic memory | A summarized record of a prior interaction or event. | Recalling relevant past experiences. |
| Semantic memory | Stable facts, preferences, or domain knowledge in a store. | Personalization or retrieval across sessions. |
| Procedural memory | Approved workflows, tool schemas, or policies. | Repeatable task execution; usually versioned application configuration. |

These are conceptual categories; implementations may use conversation stores, databases, vector search, summaries, or explicit state machines.

### Design a safe memory lifecycle

1. Decide what information is worth retaining and why; default to data minimization.
2. Store typed facts with source/provenance, timestamp, confidence or status, owner/tenant, and expiration where appropriate.
3. Retrieve only information relevant and authorized for the current task.
4. Resolve conflicts with an explicit policy; do not silently prefer a model-generated summary over an authoritative source.
5. Provide correction, deletion, retention, and consent controls where applicable.
6. Protect memory storage, logs, backups, and cache boundaries; isolate users and tenants.
7. Evaluate retrieval precision, stale-memory errors, privacy behavior, and task success.

### Concise interview answer

“Agent memory is application-managed state the model can use across calls, from the current task’s working context to episodic or semantic long-term records. Since the model may be stateless, the harness selects and supplies relevant memory. I store only what is needed, attach provenance and timestamps, scope retrieval by user permissions, define expiry and correction/deletion behavior, and treat memory as untrusted data rather than instructions. The system should handle stale or conflicting memory explicitly.”

### Revision summary

| Concern | Practice |
|---|---|
| What to store | Minimize; distinguish task state, history, facts, and procedures. |
| Trust | Track provenance, time, confidence/status. |
| Retrieval | Relevant, authorized, and bounded. |
| Lifecycle | Expiry, correction, deletion, retention, consent. |
| Safety | Isolate tenants; never let memory override system policy. |

<br><br><br>

## Harness Engineering in AI

**Answer:**

### Definition

**Harness engineering** is the design of the runtime environment and control system around a model so it can perform work reliably. The harness typically handles context construction, tool discovery and execution, state, planning/loop control, retries, validation, permissions, timeouts, resource budgets, observability, and human approval.

The model supplies learned language and decision capabilities; the harness determines what context and tools it receives, what actions are possible, how results are checked, and when execution stops. A strong model cannot compensate for a harness that leaks secrets, grants excessive permissions, or loses task state.

### Example

For a coding agent, the harness may:

- inspect repository state and provide relevant files;
- expose scoped read/edit/test tools rather than unrestricted access;
- run tests in a controlled environment and feed back failures;
- track changed files and diffs;
- enforce approval for destructive or external side effects; and
- stop after a bounded number of steps or when validation succeeds.

### Engineering principles

1. **Least privilege:** Give only necessary tools, data, and filesystem/network access.
2. **Explicit contracts:** Define typed tool inputs/outputs and validate them.
3. **Bounded execution:** Set step, time, token, retry, and monetary budgets.
4. **State and recovery:** Persist task progress safely; make retries idempotent and recover from partial failure.
5. **Verification:** Use deterministic tests, policy checks, and human review where appropriate.
6. **Observability:** Capture model/tool versions, decisions, latency, failures, and safe traces.
7. **Evaluation:** Test the whole agent system, not just model responses.

### Concise interview answer

“Harness engineering builds the reliable runtime around a model: context assembly, tools, state, orchestration, validation, security, budgets, recovery, and observability. It converts a model’s probabilistic outputs into bounded application behavior. For an agent, I use least-privilege tools, typed contracts, deterministic checks, explicit stopping and retry policies, and safe tracing. I evaluate the entire model-plus-harness system because a capable model with an unsafe or brittle harness is still an unsafe, brittle product.”

### Revision summary

| Harness responsibility | Example |
|---|---|
| Context/state | Select relevant history and task data. |
| Tool runtime | Discover, validate, authorize, execute, return observations. |
| Control | Plan, stop, retry, budget, recover. |
| Safety | Permissions, sandboxing, approvals, policy checks. |
| Quality | Tests, monitoring, traces, end-to-end evaluation. |

<br><br><br>

## What matters more for an agentic coding tool like Claude Code: the model or the harness?

**Answer:**

### Short answer: the system needs both

The **model** provides capabilities such as code understanding, reasoning, instruction following, and choosing likely next steps. The **harness** supplies repository context, tools, execution environment, permissions, state, feedback, and stopping rules. A useful coding agent depends on the interaction between them; neither a capable model with a weak harness nor a strong harness around an incapable model is sufficient.

For example, even a strong model cannot reliably fix a bug if the harness provides incomplete files, stale test output, or no safe way to run tests. A well-designed harness can help a model inspect relevant code, apply a patch, run checks, observe failures, and iterate—but cannot guarantee the model will understand a difficult codebase or produce a correct change.

### What the harness contributes

- **Repository grounding:** Relevant files, project conventions, instructions, and current diffs.
- **Action interfaces:** Read, search, edit, test, and other scoped tools with clear contracts.
- **Feedback loop:** Test results, compiler errors, lint output, and version-control changes.
- **Safety:** Workspace boundaries, permission checks, confirmation gates, and restrictions on external side effects.
- **Reliability:** State management, retries, timeouts, budgets, cancellation, and recovery.
- **Evaluation:** A repeatable way to verify that requested changes work and avoid regressions.

### How to reason about “which matters more?”

It depends on the bottleneck. If the model cannot reason about the task even with complete context and reliable tools, improve or select a better model. If the model is capable but lacks repository context, tool feedback, or safe execution, improve the harness. Benchmark end-to-end task success, regression rate, tool-use reliability, latency, cost, and safety rather than comparing model capability in isolation.

Do not infer a particular coding product’s hidden implementation from its user-facing behavior. Discuss the general engineering trade-off unless implementation details are documented and relevant.

### Concise interview answer

“Neither wins in isolation. The model supplies coding and reasoning capability; the harness supplies repository context, tools, execution feedback, state, permissions, and verification. A strong model with poor context or no reliable test loop can fail, while a good harness cannot compensate for a model that cannot solve the task. I identify the bottleneck with end-to-end benchmarks—task success, regressions, tool reliability, latency, cost, and safety—and improve the corresponding layer.”

### Revision summary

| Layer | Contribution | Failure if weak |
|---|---|---|
| Model | Understands task and proposes code/actions. | Incorrect plan or implementation. |
| Harness | Context, tools, feedback, state, controls. | Blind edits, unsafe actions, no verification. |
| Evaluation | Measures task completion and regressions. | Optimizing intuition instead of outcomes. |
| Best answer | Co-design and benchmark both. | Avoid claiming one universally matters more. |

<br><br><br>

## Explain the ReAct (Reasoning + Acting) agent architecture.

**Answer:**

### Core idea

**ReAct** combines reasoning about a task with actions in an external environment. The model alternates between deciding what it needs to do, requesting an action through a tool, receiving an observation, and using that observation to choose the next step. The host application executes the tool call; the model does not directly gain capabilities merely by naming a tool.

### Conceptual loop

1. **Reason/decide:** Interpret the goal and determine whether more information or an action is needed.
2. **Act:** Emit a structured request for an allowed tool, with arguments.
3. **Observe:** The application validates and executes the request and returns a result or error.
4. **Update:** The model uses the observation to continue, choose another action, ask the user, or provide a final answer.

For instance, to answer a question about a current order, an agent might query an authorized order-status API, inspect the returned status and timestamp, then explain it. It should not invent a current status from training data.

### Why it is useful

ReAct-style interaction grounds answers in live or external information and lets the system adapt actions based on intermediate results. It is useful for search, calculations, APIs, and workflows where the next step depends on prior observations.

### Reliability and safety

Tool schemas should be typed and narrow. Validate arguments and results, authorize every call server-side, treat tool outputs and retrieved text as untrusted, and limit steps, retries, time, and cost. Require confirmation for consequential side effects; make retries idempotent where possible. Define behavior for tool errors, empty results, conflicting observations, and exhausted budgets. Do not rely on a prompt to enforce permissions.

The loop can be expensive or fail through bad action selection, repeated calls, or incorrect interpretation. Evaluate task completion, action correctness, tool errors, latency, cost, and safety, not just the final prose.

### Concise interview answer

“ReAct interleaves reasoning about the next step with tool actions and observations. The model requests an allowed structured action; the application validates, authorizes, and executes it, then returns an observation for the model’s next decision. This makes the agent adaptive and grounds it in external information. I bound the loop, validate tool inputs and outputs, enforce least privilege in code, require approval for sensitive side effects, and handle errors and stopping explicitly.”

### Revision summary

| Element | Responsibility |
|---|---|
| Reason/decide | Select a subgoal or action. |
| Act | Request a typed tool call. |
| Observe | Incorporate execution result or error. |
| Orchestrator | Authorize, execute, track, and enforce limits. |
| Stop | Answer, ask the user, abstain, or report bounded failure. |

<br><br><br>

## What is the Plan-and-Execute agent pattern?

**Answer:**

### Definition

**Plan-and-Execute** separates task planning from task execution. A planner decomposes a goal into steps; an executor performs those steps, often using tools; a controller monitors progress and may replan when observations differ from expectations.

### Typical workflow

1. **Plan:** Translate the user’s goal into ordered, actionable steps with dependencies and completion criteria.
2. **Validate the plan:** Check that steps are in scope, feasible, authorized, and appropriately bounded.
3. **Execute:** Carry out a step or a safe group of steps, collecting tool observations.
4. **Verify:** Compare results against the step’s success condition.
5. **Replan or stop:** Update the remaining plan when facts change; finish only when the goal is verified or report why it cannot be completed.

For a code change, the plan might be inspect the relevant module, implement a targeted change, run focused tests, inspect the diff, and summarize the result. A test failure should inform the next action rather than being reported as success.

### Strengths and trade-offs

Planning can improve transparency and make long tasks easier to monitor, delegate, or resume. It can also add model calls and latency, and an early bad plan can steer many later actions. Plans become stale when execution discovers new information; rigidly following them is often worse than controlled replanning.

Use explicit dependencies, budgets, and checkpoints. Revalidate permissions at execution time rather than assuming a plan authorizes an action. Require user confirmation before irreversible or high-impact steps, and ensure the plan itself does not contain untrusted instructions elevated to policy.

### Concise interview answer

“Plan-and-Execute has a planner decompose the goal into steps, an executor carry them out with tools, and a controller verify outcomes and replan when observations change the situation. It helps with long tasks by making dependencies and progress explicit, but adds latency and can propagate a flawed plan. I use success criteria per step, validate scope and permissions at execution time, bound steps and retries, and replan from tool results rather than following a stale plan blindly.”

### Revision summary

| Phase | Check |
|---|---|
| Plan | Clear steps, dependencies, success criteria, budget. |
| Validate | Scope, permissions, feasibility, side effects. |
| Execute | Typed tools; capture observations and errors. |
| Verify | Check each step rather than trusting a completion claim. |
| Replan/stop | Adapt to new evidence or report bounded failure. |

<br><br><br>

## What is tool use (function calling) in LLMs, and how does it enable agents?

**Answer:**

### Definition

**Tool use** lets a model request an operation provided by the surrounding application, such as a search, calculator, database query, or business API. **Function calling** is a common API pattern for this: the developer supplies tool names and schemas, and the model returns a structured selection and arguments. The host application—not the model—executes the function and returns its result.

The model may decide that a tool would help, but describing or emitting a call does not execute it. The orchestrator owns validation, authorization, execution, error handling, and the decision about whether to call the model again.

### End-to-end flow

1. Developer registers tools with descriptions, argument schemas, and policy constraints.
2. Model receives the user request and available tool definitions.
3. Model returns either a normal response or a tool-call request.
4. Application validates the tool name and arguments, checks permissions, and executes the operation.
5. Application returns a bounded result as an observation.
6. Model interprets the result and answers, requests another allowed action, or reports a failure.

### Design and safety considerations

Tools should be narrow, typed, documented, and have clear error semantics. Validate arguments beyond schema checks, enforce user authorization on every call, apply timeouts and rate limits, and use least-privilege credentials. For writes or external side effects, use confirmation, idempotency keys, or transactional safeguards. Treat tool output as untrusted data and never execute arbitrary generated code or commands without a secure, explicit sandbox and policy.

Tool use enables agents to access current facts and act on systems, but adds failure modes: wrong tool selection, malformed arguments, API errors, stale results, duplicate side effects, and prompt injection. Evaluate action correctness and safety as well as final answer quality.

### Concise interview answer

“Function calling gives the model a structured way to request an application-defined tool. The application validates the request, checks authorization, executes the function, and sends the result back so the model can continue or answer. This enables agents to retrieve current information and perform bounded actions. The model does not execute the function or enforce its own permissions; tools need narrow schemas, server-side authorization, limits, error handling, and confirmation for consequential writes.”

### Revision summary

| Stage | Owner |
|---|---|
| Select tool and arguments | Model proposes structured request. |
| Validate and authorize | Host application enforces contract and permissions. |
| Execute | Trusted tool runtime calls API/service. |
| Observe | Tool result is returned to the model as data. |
| Continue/stop | Orchestrator controls loop and final response. |

<br><br><br>

## What is the difference between structured output and function calling?

**Answer:**

### Different intent

**Structured output** asks the model to return data in a defined shape—such as JSON matching a schema—for the application or user to consume. **Function calling** asks the model to select or request an application-defined operation and provide its arguments. The former describes the shape of an answer; the latter expresses an action request.

Both may use structured schemas and both require validation. A function/tool call is not the same as the function actually running: execution is performed by the host application after its policy checks.

### Comparison

| Dimension | Structured output | Function calling |
|---|---|---|
| Primary purpose | Return a typed result or record. | Request a tool/action with arguments. |
| Example | `{"label":"billing","confidence":0.91}` | `lookup_order({"order_id":"..."})` |
| Side effect by itself | No; it is data. | No; it is still a request until the host executes it. |
| Typical control | Parse and validate schema/business rules. | Validate tool and arguments, authorize, execute, return observation. |
| Useful for | Extraction, classification, API payloads, structured answers. | Search, calculations, database/API interactions, agent actions. |

Provider APIs sometimes implement both through similar constrained-generation mechanisms, so the exact wire format and capabilities vary. Do not infer semantic equivalence from similar JSON syntax.

### Choosing and securing

Use structured output when the model should produce a result in a known schema. Use function calling when it needs to request a capability supplied by the application. An agent may use both: structured output for a plan or final result and tool calls for external actions. Always validate output; tool calls additionally require server-side authorization, safe execution, and confirmation when appropriate.

### Concise interview answer

“Structured output constrains the model’s response to a schema; function calling lets it request an application-defined tool with structured arguments. A structured JSON object is data, while a tool call is an action proposal—but neither executes automatically. The application parses and validates structured results; for tool calls it also authorizes and executes the operation, handles errors, and returns an observation. An agent can use both in the same workflow.”

### Revision summary

| Question | Structured output | Function calling |
|---|---|---|
| Goal | Produce schema-conforming data. | Request a tool/action. |
| Execution | Consumed as a result. | Host decides whether/how to execute. |
| Validation | Schema plus business rules. | Tool schema, authorization, side-effect controls. |
| Combined use | Final answer/plan. | External retrieval or operation. |

<br><br><br>

## How do you design and define tools for an AI agent?

**Answer:**

### Design tools around safe capabilities

An agent tool is an application-defined capability the model can request through a structured interface. Good tools expose a clear, bounded operation rather than a broad escape hatch. Prefer `search_customer_orders` with explicit filters over a generic “run arbitrary database query” tool.

### Tool-design checklist

1. **Single purpose:** Give each tool one understandable responsibility and an action-oriented name.
2. **Precise description:** Explain when to use it, what it does not do, preconditions, side effects, and expected result.
3. **Typed schema:** Require explicit fields, types, enums, ranges, and missing-value behavior; avoid ambiguous free-form arguments.
4. **Least privilege:** Limit accessible resources and operations to the current user/task; use scoped credentials.
5. **Application validation:** Recheck identity, authorization, business rules, and arguments server-side. A valid schema does not make an action authorized.
6. **Safe execution:** Use timeouts, quotas, payload limits, idempotency keys, transactions, and confirmation for consequential writes.
7. **Clear results and errors:** Return bounded structured data with provenance and actionable error categories; avoid leaking secrets or internal stack traces.
8. **Version and test:** Maintain backwards compatibility where possible and test malformed, boundary, unauthorized, duplicate, and failure cases.

Read-only tools are generally safer than mutating tools. For actions such as sending messages, deleting records, or spending money, preview the proposed action and require explicit user confirmation where appropriate.

### Concise interview answer

“I define agent tools as narrow, typed capabilities with clear descriptions, preconditions, side effects, and error semantics. The model may request a call, but the application validates arguments, authenticates and authorizes the user, applies business rules, and executes with least privilege. I add timeouts, quotas, idempotency for writes, bounded results, audit logs, and confirmation for high-impact actions. Then I test malformed and unauthorized requests as well as normal success paths.”

### Revision summary

| Property | Design choice |
|---|---|
| Scope | Narrow, single-purpose operation. |
| Contract | Typed schema, clear descriptions and errors. |
| Security | Least privilege and server-side authorization. |
| Reliability | Timeouts, quotas, idempotency, bounded results. |
| High-impact action | Preview, confirmation, audit, rollback where possible. |

<br><br><br>

## How does an agent decide when to call a tool versus answering from its own knowledge?

**Answer:**

### Decision principle

An agent should call a tool when the task requires information or an operation that is unavailable, unreliable, or inappropriate to infer from the model’s internal knowledge. Examples include current facts, private or user-specific data, exact calculations, authoritative records, and actions that must be performed in an external system.

It may answer directly when the request is general, stable, self-contained, and within the model’s demonstrated capability—provided the application’s risk and quality requirements permit that.

### A practical decision policy

1. **Classify the request:** Is it asking for a current fact, authorized private data, exact computation, or external action?
2. **Check available evidence and capability:** Is the relevant source already present and sufficient? Is confidence calibrated for this task?
3. **Select the minimum necessary tool:** Choose an approved tool and narrowly scoped arguments.
4. **Validate and execute:** The host checks authorization, input constraints, freshness, and policy before calling the tool.
5. **Use the observation:** Cite or summarize the result; distinguish tool evidence from prior model knowledge.
6. **Stop or recover:** If the tool fails, returns stale/empty data, or conflicts with another source, retry within limits, ask the user, or abstain.

Do not treat the model’s self-reported confidence as a reliable probability unless it has been calibrated for the task. Tool use is not always better: unnecessary calls increase latency, cost, and attack surface. Conversely, answering from memory about volatile or private information risks confidently wrong or unauthorized claims.

### Evaluation

Test tool-selection precision and recall: whether the agent called tools when needed and avoided unnecessary calls when not needed. Also measure correctness, authorization violations, stale data, tool errors, latency, and cost. Define policy rules for high-stakes or freshness-critical questions instead of leaving the decision solely to free-form model judgment.

### Concise interview answer

“I call a tool when the request needs current or private data, exact computation, or an external action; I answer directly for stable, self-contained questions when the model is adequate. The decision can be guided by the model, but high-risk and freshness-critical cases should have application-level policy rules. The host chooses only approved tools, authorizes each call, validates results, and handles failures. I evaluate both missed tool calls and unnecessary calls, since tool use adds cost and attack surface.”

### Revision summary

| Need | Preferred path |
|---|---|
| Current/private fact | Authorized source/API. |
| Exact arithmetic or deterministic transformation | Calculator/code tool. |
| External side effect | Approved tool plus authorization/confirmation. |
| Stable general knowledge | Direct answer if quality/risk allow. |
| Tool failure/uncertainty | Bounded retry, clarify, or abstain. |

<br><br><br>

## What is the difference between single-agent and multi-agent systems?

**Answer:**

### Definitions

A **single-agent system** uses one agentic control loop to interpret a task, select tools, maintain state, and produce a result. It may still call many tools or use deterministic components; “single agent” does not mean “one model call.”

A **multi-agent system** uses multiple separately configured agents or model-driven roles that coordinate, delegate, critique, or exchange results. For example, a planner might assign research subtasks to specialized workers, then a coordinator synthesizes their findings.

### Comparison

| Dimension | Single agent | Multi-agent |
|---|---|---|
| Control flow | One primary decision loop. | Multiple loops/roles plus coordination. |
| Strength | Simpler state, debugging, permissions, and cost control. | Parallelism or specialized perspectives for separable work. |
| Risk | One planner may be a bottleneck or lack specialized instructions. | Communication errors, duplicated work, inconsistent state, and compounded failures. |
| Latency/cost | Often lower and easier to bound. | More model calls, coordination overhead, and potentially parallel compute. |
| Best fit | Tasks with shared context and a clear sequence. | Independent subtasks or genuinely distinct capabilities/permissions. |

Multiple personas on one model are not necessarily independent experts; they may share model biases and correlated errors. Use explicit interfaces and evidence, not role names as a substitute for competence.

### Concise interview answer

“A single-agent system has one primary control loop that can still use many tools. A multi-agent system coordinates multiple agent loops, often with different roles or delegated subtasks. Multi-agent designs can parallelize independent work or isolate responsibilities, but they add communication, state, evaluation, latency, and cost overhead. I start with one agent and add agents only when tasks are separable or specialization produces a measured benefit.”

### Revision summary

| Aspect | Single-agent | Multi-agent |
|---|---|---|
| Main benefit | Simplicity and shared state. | Parallel or specialized work. |
| Main cost | Central loop can be a bottleneck. | Coordination and error propagation. |
| Tool use | Fully compatible. | Agents may share or partition tools. |
| Decision rule | Start simple; add only for measurable benefit. | Ensure subtasks/interfaces are explicit. |

<br><br><br>

## When do multi-agent systems break down, and when is a single agent the better choice?

**Answer:**

### Why multi-agent systems break down

Adding agents increases the number of handoffs, model calls, messages, and state transitions. Common failure modes include:

- **Unclear decomposition:** Agents solve overlapping or incomplete subtasks.
- **Coordination overhead:** Planning, negotiation, and synthesis cost more than the work.
- **Error propagation:** A confident but wrong intermediate result is reused downstream.
- **Inconsistent assumptions:** Agents use different definitions, source versions, or constraints.
- **Correlated errors:** Agents using the same model or data may repeat the same bias rather than provide independent validation.
- **Unbounded debate or delegation:** Agents loop, duplicate searches, or exceed time and token budgets.
- **Security boundary mistakes:** A delegated agent receives broader data or tools than the parent task requires.

### Prefer a single agent when

The task has a mostly linear sequence, shared context, limited tool set, modest complexity, or tight latency/cost requirements. A deterministic workflow with a few well-defined model calls may be better than either a fully autonomous single agent or a multi-agent framework.

### When multiple agents can be justified

Use them when work is meaningfully separable and can run in parallel, when distinct context or permission scopes are needed, or when a specialized workflow has measurable benefits. Define typed task/result contracts, provenance requirements, ownership boundaries, timeouts, budgets, and a coordinator that verifies outputs. For “independent review,” use genuinely different evidence or validation methods; simply asking the same model twice is not strong independence.

### How to decide

Benchmark single-agent, multi-agent, and non-agent baselines on task success, error severity, latency, cost, security, and ease of debugging. Measure whether parallelism actually improves end-to-end time and whether coordination reduces or increases failure rates. Add a multi-agent architecture only when its benefit exceeds its complexity.

### Concise interview answer

“Multi-agent systems break down when tasks overlap, interfaces are vague, intermediate errors propagate, agents disagree, or coordination costs exceed the work. They also add latency, spend, and security surface, and agents may share correlated model errors. I prefer a single agent or deterministic workflow for linear, tightly coupled tasks. I use multiple agents for independently verifiable parallel work or distinct scopes, with structured handoffs, bounded budgets, provenance, and a coordinator that validates results.”

### Revision summary

| Symptom | Better choice/control |
|---|---|
| Duplicate work and debate | Single agent or deterministic orchestration. |
| Linear shared-context task | Single agent. |
| Independent parallel subtasks | Multi-agent with explicit result contracts. |
| Correlated “reviewers” | Use independent tools, data, or human verification. |
| Added complexity | Benchmark cost, latency, reliability, and security first. |

<br><br><br>

## What is Model Context Protocol (MCP), and how does it standardize tool integration?

**Answer:**

### Definition

**Model Context Protocol (MCP)** is an open protocol for connecting AI applications (hosts) to external servers that expose context and capabilities. It defines a common way for a host-side MCP client to communicate with an MCP server, discover supported capabilities, and exchange requests and results. The protocol is intended to reduce the need for a bespoke integration for every host-server pair.

Depending on the implementation and negotiated protocol version, MCP servers can expose capabilities such as **tools** (actions), **resources** (context/data), and **prompts** (reusable prompt templates). The host remains responsible for deciding what to connect, what to expose to the model, and what policy applies.

### Typical interaction

1. An MCP host creates a client connection to a configured server using a supported transport.
2. The client initializes and negotiates protocol capabilities/version.
3. The host can discover available server capabilities, subject to its configuration.
4. The model-facing application may present selected tools or context to the model.
5. When a tool is requested, the host/client sends the call to the server and returns the result to the model/application.

MCP standardizes the interface and message exchange; it does not make a server trustworthy, guarantee the quality of its results, or automatically authorize every action.

### Security and operational considerations

Review server provenance and implementation, authenticate connections appropriately, apply least privilege, protect credentials, validate inputs/outputs, and require user approval for sensitive actions where needed. Be careful with untrusted servers, tool descriptions, and returned content. The host should enforce policy, data scope, audit, and user consent; protocol compatibility is not a security review.

### Concise interview answer

“MCP is an open protocol for connecting an AI host to external servers that provide capabilities such as tools, resources, or prompts. A client initializes with a server, negotiates capabilities, discovers what is available, and exchanges calls and results over a supported transport. It standardizes integration interfaces across hosts and servers, but does not guarantee trust, correctness, or authorization. The host still selects capabilities, manages credentials and permissions, validates results, and applies approval and audit policies.”

### Revision summary

| MCP concept | Role |
|---|---|
| Host | AI application that controls model interaction and policy. |
| Client | Protocol participant managed by the host. |
| Server | Exposes tools, resources, and/or prompts. |
| Standardization | Common discovery and request/response interface. |
| Boundary | Does not replace authorization, trust review, or validation. |

<br><br><br>

## How does MCP differ from traditional function calling?

**Answer:**

### Different layers of the system

**Function calling** is generally a model/API interaction pattern: the application gives the model a set of tool definitions, and the model returns a structured request to call one. The host then validates and executes the tool and returns its result.

**Model Context Protocol (MCP)** is a protocol for connecting an AI host to external servers that expose capabilities such as tools, resources, or prompts. It standardizes capability discovery and communication across compatible clients and servers. An MCP host may choose to present discovered MCP tools to a model using that model provider’s function-calling interface.

Thus, they are not necessarily competing alternatives: function calling can be the model-facing mechanism, while MCP can be the host-to-server integration protocol behind it.

### Comparison

| Dimension | Traditional function calling | MCP |
|---|---|---|
| Main boundary | Model/API ↔ host application. | Host/client ↔ external MCP server. |
| Primary role | Let model request a defined tool with arguments. | Standardize discovery and exchange of tools/resources/prompts. |
| Tool definitions | Often authored/configured in the application and sent to the model. | Exposed by servers and discovered by compatible clients. |
| Execution | Host application executes after validation and authorization. | Host/client communicates with server; host still applies policy. |
| Portability | Often provider/framework-specific. | Aims for interoperable host-server integrations. |

Exact features, transport, and behavior depend on protocol version and implementation. MCP does not guarantee that a discovered server is trustworthy, that its tool is safe, or that a user is authorized to invoke it.

### Concise interview answer

“Function calling is typically the model-facing mechanism for requesting an application-defined tool. MCP standardizes how an AI host connects to external servers, discovers capabilities such as tools/resources/prompts, and exchanges calls and results. An MCP host can expose a server’s tools to a model through function calling, so they operate at different layers. MCP improves integration portability, but authorization, server trust, validation, and execution policy remain the host’s responsibility.”

### Revision summary

| Layer | Mechanism |
|---|---|
| Model requests action | Function/tool calling interface. |
| Host discovers external capability | MCP client/server protocol. |
| Action execution | Trusted host/server after validation and authorization. |
| Relationship | Can be composed; not mutually exclusive. |
| Security | Protocol compatibility is not an authorization decision. |

<br><br><br>

## What are AI SubAgents?

**Answer:**

### Definition

**Subagents** are separately invoked agent instances that handle delegated subtasks on behalf of a coordinating agent or application. A subagent may have its own prompt, model configuration, tools, context, and execution budget. The main agent or orchestrator defines the task, supplies relevant input, receives the result, and decides how to use it.

For example, a coding workflow might delegate a read-only test investigation to one subagent while the primary agent works on a separate implementation task. Delegation is useful only when the subtask can be isolated and its result checked.

### Common roles and workflow

- **Coordinator/planner:** Decomposes the goal, delegates work, integrates results, and decides when to stop.
- **Specialist worker:** Performs a bounded task such as retrieval, code analysis, or document extraction.
- **Reviewer/verifier:** Checks an output against explicit criteria or independent evidence.

Typical flow:

1. Define a narrow subtask, expected output schema, constraints, and completion criterion.
2. Provide only the context and tool permissions needed.
3. Execute within a bounded time/token/tool budget.
4. Return a result with evidence, provenance, uncertainty, and errors.
5. Validate and integrate it; do not treat a subagent’s confident assertion as ground truth.

### Benefits and risks

Subagents can isolate context, run independent work in parallel, and apply specialized instructions. They also add orchestration overhead, latency, cost, state synchronization, and more failure/security boundaries. Workers may duplicate effort, make incompatible assumptions, or share correlated errors if they use the same model and evidence.

Use explicit contracts, least privilege, bounded concurrency, cancellation, and traceable provenance. A subagent is not inherently independent simply because it has a separate name or prompt.

### Concise interview answer

“A subagent is a bounded agent instance delegated a subtask by a coordinator or application. It may have separate context, tools, and instructions, then returns a result for validation and integration. Subagents can parallelize independent work or isolate context, but they add cost, latency, coordination, and security surface. I delegate only separable tasks, provide least-privilege tools and explicit output contracts, bound execution, and verify results rather than assuming a subagent is an independent source of truth.”

### Revision summary

| Component | Responsibility |
|---|---|
| Coordinator | Decompose, delegate, integrate, stop. |
| Subagent | Complete one bounded task and report evidence/errors. |
| Contract | Input scope, output schema, budget, success criterion. |
| Benefit | Parallelism, context isolation, specialization. |
| Risk | Overhead, correlated errors, duplicated work, permission sprawl. |

<br><br><br>

## What are the different types of agent memory (short-term, long-term, episodic)?

**Answer:**

### Short-term or working memory

**Short-term memory** is the state needed for the current conversation or task: recent turns, current plan, tool observations, intermediate results, and unresolved questions. It is often represented in the active context window or in an external task-state store. It is temporary and should be trimmed or summarized when it grows beyond the context budget.

### Long-term memory

**Long-term memory** persists across tasks or sessions. It may store user preferences, stable facts, domain knowledge, or prior experiences in a database, document store, or searchable index. It should be retrieved selectively rather than copied wholesale into every prompt.

### Episodic memory

**Episodic memory** records specific events or interactions—for example, what was requested, what action was taken, what result occurred, and when. It can help an agent recall prior task outcomes, but must preserve provenance and distinguish observed facts from summaries or inferences.

These categories describe the information’s purpose and lifetime; they are not tied to one storage technology. Episodic memory is often a subtype or organizational view of long-term memory rather than a separate physical store.

### Design considerations

| Type | Typical contents | Main concern |
|---|---|---|
| Short-term/working | Current task, recent turns, tool results. | Context limits, stale intermediate state. |
| Long-term/semantic | Durable facts, preferences, knowledge. | Relevance, freshness, privacy, conflict resolution. |
| Episodic | Past events and outcomes with time/provenance. | Accurate attribution, retention, sensitive history. |

For all memory, minimize retention, isolate users/tenants, attach timestamps and provenance, define expiry/correction/deletion, and re-check authorization on retrieval. Memory is data, not a trusted instruction source; it may be wrong, stale, or maliciously influenced.

### Concise interview answer

“Short-term or working memory holds the current task state and recent interactions; long-term memory persists useful information across sessions; episodic memory captures specific prior events and outcomes with timestamps. These are conceptual categories and can share storage implementations. I retrieve only relevant, authorized memory, track provenance and freshness, define retention and deletion, and treat memory as fallible data rather than instructions.”

### Revision summary

| Memory type | Time horizon | Example |
|---|---|---|
| Short-term/working | Current task/session | Plan and recent tool observations. |
| Long-term | Across sessions | Stable preference or domain fact. |
| Episodic | Past event records | Prior interaction and its outcome. |
| Shared safeguards | All types | Provenance, access control, expiry, correction, deletion. |

<br><br><br>

## How do you handle agent failures and implement error recovery?

**Answer:**

### Treat failures as explicit states

Agent failures include model timeouts, malformed tool arguments, tool/API errors, empty or contradictory observations, rate limits, context overflow, repeated loops, invalid plans, and partial side effects. The system should distinguish transient failures (possibly retryable) from permanent errors (bad input, denied permission, unsupported task) and from ambiguous outcomes (the action may have succeeded but its response was lost).

### Recovery strategy

1. **Classify and report:** Return typed errors with safe, actionable details; do not convert failure into a fabricated success.
2. **Retry selectively:** Use bounded exponential backoff with jitter for transient, idempotent operations; respect `Retry-After` and provider limits.
3. **Protect side effects:** Use idempotency keys, transactions, status checks, or compensating actions to avoid duplicate writes after uncertain outcomes.
4. **Replan from observations:** Give the agent the actual error/result and allow a bounded alternative path only when policy permits.
5. **Use fallback paths:** Switch to a safe read-only method, ask the user, or hand off to a human when available.
6. **Enforce budgets and stops:** Cap tool calls, retries, elapsed time, tokens, and cost; detect repeated identical states/actions.
7. **Persist checkpoints:** Record completed steps and verified outputs so recovery resumes without repeating unsafe work.
8. **Observe and learn:** Trace model/tool versions, state transitions, and error categories with privacy-aware logging; add incidents to regression tests.

Always revalidate identity and permissions on retries or replans. If an operation is destructive or irreversible, pause for confirmation or escalation rather than attempting speculative recovery.

### Concise interview answer

“I model errors explicitly and distinguish retryable transport/rate-limit failures from permanent validation or authorization failures and ambiguous side-effect outcomes. I use bounded backoff for idempotent calls, idempotency keys or status checks for writes, and feed real tool errors back into a bounded replan. I checkpoint verified progress, enforce step/time/cost limits, detect loops, and ask a human or user when recovery is unsafe. Failures are surfaced—not silently converted into success.”

### Revision summary

| Failure | Recovery |
|---|---|
| Transient timeout/rate limit | Bounded backoff, jitter, provider guidance. |
| Invalid arguments/permission denied | Surface error; correct input or stop; do not retry blindly. |
| Ambiguous write outcome | Idempotency key, transaction/status check. |
| Repeated plan/action | Loop detection, budget limit, alternative or stop. |
| Unrecoverable/high impact | Checkpoint, explain, request confirmation or human review. |

<br><br><br>

## What is an agent loop, and how does it decide when to stop?

**Answer:**

### Definition and basic cycle

An **agent loop** repeatedly lets the model observe current task state, choose a next action, receive the result, and update its state until a completion or stop condition is reached. A common cycle is:

```text
observe state -> choose response/tool -> validate and execute -> record result -> repeat or stop
```

The loop can be driven by a model decision, a deterministic workflow controller, or a combination. The model should not be the only enforcement mechanism for hard limits.

### Stop conditions

Stop when one of the following is true:

- The user’s requested goal is completed and verified against explicit success criteria.
- The model returns a final response with sufficient evidence and no further action is required.
- A required human approval or clarification is needed.
- The agent cannot proceed safely or reliably because of missing permissions, conflicting evidence, or a permanent tool error.
- A hard budget is reached: maximum steps, tool calls, elapsed time, tokens, or cost.
- The loop repeats without meaningful progress or detects a repeated state/action.

If a budget is exhausted before success, report incomplete status and what remains; do not claim completion.

### Robust loop design

Track state transitions, tool-call IDs, observations, and verified milestones. Make actions idempotent where possible, authorize each action at execution time, and ensure cancellation works. Define separate criteria for “done,” “needs user input,” and “failed.” Evaluate both premature stopping and unnecessary continuation.

### Concise interview answer

“An agent loop observes state, selects an answer or tool action, executes through a controlled runtime, incorporates the result, and repeats. It should stop when success criteria are verified, when user input or approval is needed, when a permanent failure blocks progress, or when a hard step/time/token/cost budget is exhausted. I add repeated-state detection and make the orchestrator enforce limits, because model-generated ‘I’m done’ is not sufficient. If the task is incomplete, the system must report that honestly.”

### Revision summary

| Stop reason | Required behavior |
|---|---|
| Verified completion | Return result with evidence/status. |
| Clarification/approval required | Pause and ask the user. |
| Unsafe or permanent failure | Stop and explain; do not fabricate success. |
| Budget/loop limit | Terminate safely and report incomplete progress. |
| Control mechanism | Enforce in the orchestrator, not only in prompt text. |

<br><br><br>

## Context Engineering

**Answer:**

### Definition

**Context engineering** is the deliberate selection, organization, and updating of the information supplied to a model for a particular inference step. It includes more than writing a prompt: system/developer instructions, user input, conversation history, retrieved documents, tool descriptions and results, memory, examples, and structured task state all contribute to context.

The goal is to provide enough relevant information for the model to act correctly while keeping the context bounded, coherent, current, and safe. A larger prompt is not automatically a better prompt.

### Practical workflow

1. **Define the task and policy:** Keep trusted instructions explicit and versioned.
2. **Select task-relevant state:** Include the current request, required history, and verified tool observations.
3. **Retrieve evidence selectively:** Apply authorization and freshness checks before including external content.
4. **Structure and label content:** Separate instructions, user data, retrieved evidence, and tool results; preserve sources and uncertainty.
5. **Manage the token budget:** Prioritize critical rules and evidence; summarize or omit stale/redundant history.
6. **Validate and observe:** Inspect the exact rendered request, token counts, truncation, and outcome in evaluation traces.

Untrusted context can contain malicious instructions, stale claims, or sensitive information. Labeling it as data helps clarify intent but does not enforce security; permissions, secret handling, and tool limits belong in the host application.

### Concise interview answer

“Context engineering is the end-to-end work of deciding what information a model sees, how it is organized, and how it changes across a task. It includes instructions, history, retrieved evidence, tool results, memory, and schemas. I select only relevant and authorized content, preserve provenance, separate trusted instructions from untrusted data, manage token limits, and inspect the exact rendered request. This improves grounding and cost, but security and permissions must still be enforced outside the prompt.”

### Revision summary

| Context source | Engineering task |
|---|---|
| Instructions | Prioritize, version, keep explicit. |
| Conversation/memory | Select, summarize, expire, preserve key state. |
| Retrieval/tool results | Authorize, bound, label, preserve provenance. |
| Token budget | Prioritize; avoid irrelevant and duplicate content. |
| Evaluation | Inspect rendered context, truncation, quality, and cost. |

<br><br><br>

## How does context compaction work?

**Answer:**

### Definition

**Context compaction** reduces a long interaction or task state so it can continue within a model’s context limit. It may discard redundant or obsolete messages, summarize earlier turns, retain selected facts and decisions, or move detailed state to an external store and retrieve it when needed.

Compaction should preserve task-critical information rather than blindly shortening text. A summary is lossy: it can omit qualifiers, exact identifiers, unresolved questions, or provenance.

### A reliable compaction strategy

1. **Track structured state separately:** Store verified task goal, constraints, completed steps, pending work, tool outputs, and key source references in explicit fields.
2. **Identify what is safe to remove:** Drop repeated greetings, superseded plans, and irrelevant history; preserve recent turns and unverified/conflicting evidence as needed.
3. **Summarize with provenance:** Distinguish user statements, tool observations, model inferences, and unresolved assumptions. Keep links/IDs to original records.
4. **Retain critical instructions verbatim:** Do not rely on an LLM summary to preserve security policy or exact requirements.
5. **Validate after compaction:** Compare the summary against a checklist, ensure identifiers and constraints survive, and test that the task can resume.
6. **Keep a recovery path:** Retain source history according to privacy/retention policy or store checkpoints externally; support correction and deletion.

When a fact must be exact or auditable, retrieve it from the original source instead of trusting a compressed summary. Avoid summarization loops that repeatedly compress already lossy summaries without checking information loss.

### Concise interview answer

“Context compaction reduces long history by removing redundancy, summarizing older content, and preserving important state. I keep critical requirements and policy verbatim, store task progress and verified facts structurally, and label provenance and uncertainty in summaries. I retain source references for exact details, validate the compacted context against a checklist, and test that work can resume correctly. Compaction is lossy, so I avoid treating a summary as authoritative when the original evidence is available.”

### Revision summary

| Keep | Compact/drop |
|---|---|
| Goal, constraints, verified progress, pending steps. | Repeated and irrelevant conversation. |
| Exact IDs, policies, source links. | Superseded plans when state is recorded. |
| Provenance and uncertainty. | Verbose text when a checked summary suffices. |
| Recovery data | Do not repeatedly compress without validation. |

<br><br><br>

## Loop Engineering

**Answer:**

### Definition and scope

**Loop engineering** is the design of the repeated observe–decide–act cycle used by an agent. The phrase is broad rather than one standardized algorithm: it covers how state is updated, actions are executed, observations are incorporated, progress is assessed, and the system terminates or recovers.

### Designing a robust loop

1. **Represent state explicitly:** Goal, constraints, completed steps, pending work, observations, and errors.
2. **Choose an action:** The model proposes a response or tool call; the orchestrator validates it.
3. **Execute safely:** Enforce permissions, input schemas, timeouts, idempotency, and user approval as needed.
4. **Record the observation:** Preserve the result, provenance, and status; do not silently treat an error as success.
5. **Check progress:** Compare the new state with success criteria and detect no-progress or repeated actions.
6. **Replan or stop:** Continue within budget, ask the user, use a fallback, or report incomplete work.

Set hard maximums for steps, tool calls, time, tokens, and cost. Add cancellation, checkpoints, and loop detection; prompts alone cannot reliably enforce these bounds. For non-idempotent actions, account for uncertain outcomes before retrying.

### Evaluate the loop

Measure task completion, success-criterion verification, unnecessary actions, tool errors, loops, recovery success, side effects, latency, and cost. Test interrupted runs and partial completion, not just clean successes.

### Concise interview answer

“Loop engineering designs the agent’s observe–decide–act cycle and its state, recovery, and stopping behavior. I represent task state explicitly, validate proposed actions in the orchestrator, record tool observations and errors, and check progress against success criteria. The loop has hard step/time/token/cost limits, repeated-state detection, cancellation, and safe retry semantics. I evaluate not only task success but unnecessary actions, failure recovery, side effects, latency, and cost.”

### Revision summary

| Loop concern | Control |
|---|---|
| State | Explicit goal, progress, observations, and pending work. |
| Actions | Validate, authorize, execute with bounded tools. |
| Progress | Success checks and repeated-state/no-progress detection. |
| Termination | Hard budgets, cancellation, honest incomplete status. |
| Recovery | Checkpoints, idempotency, explicit errors and fallback. |

<br><br><br>

## Graph Engineering

**Answer:**

### Clarify the term

**Graph engineering** is a broad term for representing a system or workflow as nodes and relationships, then designing how it is built, traversed, validated, and operated. In agentic systems, “graph” may refer to a directed workflow/state graph (nodes are steps and edges are transitions), a knowledge graph (nodes are entities and edges are facts), or a computation/dependency graph. These are related representations but serve different purposes; identify which meaning is intended.

### Workflow/state graphs for agents

A workflow graph makes control flow explicit: a node might retrieve data, call a tool, validate a result, or request human approval; edges encode conditions for moving to the next node. Cycles can support bounded retries or iterative refinement. Explicit graphs can improve observability, state persistence, branching, and human-in-the-loop behavior compared with an unconstrained free-form loop.

Design considerations include:

- define typed state passed between nodes;
- make transitions and error edges explicit;
- validate node inputs/outputs and side effects;
- bound cycles and retries;
- persist checkpoints for recovery;
- keep authorization and policy checks at action nodes; and
- version and test each path, including failure and cancellation paths.

### Knowledge graphs

A knowledge graph represents entities and relationships, often extracted from or linked to source documents. It can support multi-hop queries and relationship traversal, but depends on correct entity resolution and edge provenance. Preserve source evidence and timestamps, and verify graph-derived claims against authoritative sources.

### Concise interview answer

“Graph engineering can mean workflow graphs for agent control flow or knowledge graphs for domain relationships, so I clarify the term. A workflow graph represents steps as nodes and conditional transitions as edges, making state, retries, approvals, and failure paths explicit. A knowledge graph represents entities and sourced relations for multi-hop retrieval. Both need typed state, provenance, validation, bounded cycles, and tests; graph structure does not guarantee correct execution or facts.”

### Revision summary

| Graph type | Nodes/edges represent | Main value |
|---|---|---|
| Workflow/state graph | Actions, states, conditional transitions. | Control, branching, persistence, observability. |
| Knowledge graph | Entities and sourced relationships. | Relationship and multi-hop retrieval. |
| Dependency graph | Tasks/artifacts and prerequisites. | Ordering and parallel scheduling. |
| Shared guardrail | Provenance, validation, bounded cycles, permissions. | Correctness and safe operations. |

<br><br><br>

## How AI Agents Communicate?

**Answer:**

### Communication channels

Agents can communicate through several patterns:

- **Shared orchestrator/state:** A controller passes explicit tasks, results, and state between agents.
- **Message passing:** Agents exchange structured requests, answers, status, or events.
- **Shared storage/blackboard:** Agents write artifacts to a common store and reference them by stable IDs.
- **Tool or protocol interfaces:** Agents invoke services through APIs or interoperability protocols such as MCP, when supported.

Not every multi-agent design has agents communicate directly. A hub-and-spoke orchestrator is often simpler to govern and observe than peer-to-peer conversations.

### Make handoffs reliable

Each message should carry a task ID, sender/recipient or role, purpose, bounded input, output schema, provenance, status, and relevant deadline/budget. Separate facts from hypotheses and preserve citations or artifact references. Define who owns final decisions, how conflicts are escalated, and what happens on timeout, malformed output, or disagreement.

Avoid passing entire transcripts to every agent. Provide least-privilege context and tools, isolate tenant data, and treat messages and shared artifacts as untrusted inputs. Use idempotent task IDs and explicit states to avoid duplicate work or side effects.

### Concise interview answer

“Agents communicate through an orchestrator, structured messages, shared artifacts, or service/tool protocols. I prefer explicit typed handoffs with task IDs, bounded context, provenance, status, and clear ownership rather than unrestricted transcript sharing. The coordinator handles timeouts, retries, conflicts, and final verification. Messages remain untrusted data, and each agent receives only the permissions and information needed for its subtask.”

### Revision summary

| Pattern | Example |
|---|---|
| Orchestrated | Coordinator delegates and integrates. |
| Message passing | Typed task/result events. |
| Shared workspace | Versioned artifacts referenced by ID. |
| Protocol/API | Capability calls through a defined interface. |
| Reliability | Provenance, ownership, budgets, error/timeout handling. |

<br><br><br>

## What are Agent Skills?

**Answer:**

### Definition

**Agent skills** are reusable, named capabilities or procedures that help an agent complete a class of tasks. A skill may package instructions, examples, workflow steps, schemas, references, or links to approved tools. The term is used differently across platforms: some define a specific file format or loading convention, while others use “skill” more generally for a reusable workflow or capability.

A skill is not necessarily a model weight or an autonomous agent. It is often an application-level artifact that the host selects and supplies when relevant.

### How skills are used

1. The application or agent identifies the task and available skills.
2. It selects a relevant skill, ideally using explicit metadata and descriptions.
3. It loads only the required instructions/resources into the current context.
4. The agent follows the procedure and uses only tools allowed by the host.
5. The host validates outputs and records the skill/version used.

For example, a “summarize incident report” skill might define required fields, severity terminology, source-citation behavior, and a response schema.

### Benefits and risks

Skills can make behavior reusable, modular, and easier to maintain than duplicating long instructions in every prompt. They can also become stale, conflict with system instructions, consume context, or carry malicious instructions if sourced from an untrusted author.

Version and review skills like code/configuration. Keep trusted policy separate from task guidance; use allowlisted skills, scoped resources/tools, provenance, tests, and controlled rollout. A skill instruction should never grant authority that the application has not separately authorized.

### Concise interview answer

“An agent skill is a reusable capability or procedure—often instructions plus examples, schemas, references, or tool guidance—that the host can load for relevant tasks. The term and packaging vary by platform, so I would clarify the specific implementation. Skills improve modularity and reuse but can be stale, conflicting, or unsafe if untrusted. I version and review them, load only what is needed, test them, and keep permissions and security policy in the application rather than in the skill text.”

### Revision summary

| Skill element | Purpose |
|---|---|
| Instructions/workflow | Reuse task-specific process. |
| Examples/schema | Standardize expected inputs and outputs. |
| References/tools | Provide supporting information/capabilities. |
| Lifecycle | Version, review, test, and selectively load. |
| Security boundary | Skill text cannot authorize tools or data access. |

<br><br><br>

## How do you evaluate and test AI agents?

**Answer:**

### Evaluate the complete system

An agent’s quality depends on the model, prompts, tools, orchestrator, state, data, and environment. Test end-to-end tasks as well as individual components; a fluent final answer does not prove that the correct action was taken or that side effects were safe.

### Build a representative task suite

Include successful tasks, ambiguous requests, missing information, tool errors, stale or conflicting data, adversarial content, permission boundaries, long-running tasks, cancellation, and partial completion. Define expected outcomes and acceptable action traces—not necessarily one exact sequence of model tokens.

### Useful metrics

- **Task outcome:** Completion rate and correctness against explicit acceptance criteria.
- **Action quality:** Tool selection, argument validity, unnecessary calls, and side-effect correctness.
- **Safety:** Unauthorized access/actions, policy violations, injection success, and severity of failures.
- **Recovery:** Handling of timeouts, retries, partial success, cancellation, and loop detection.
- **Evidence quality:** Source relevance, citation support, and use of tool observations.
- **Operations:** Latency percentiles, token/call cost, timeout rate, and human escalation.

Use deterministic checks for exact outputs and side effects, simulator environments for repeatable interaction, and human review for nuanced quality. LLM-as-judge can assist but must be calibrated against human/ground-truth labels; it is not automatically independent or reliable.

### Evaluation lifecycle

Version the task set, prompts, model, tools, and harness. Run regression tests before changes, perform adversarial and permission testing, then use staged rollout and production monitoring. Analyze failures by task and user/data slice, and add incidents to the evaluation suite. Avoid optimizing a single aggregate score that hides rare high-impact failures.

### Concise interview answer

“I evaluate agents end to end on representative tasks and failure cases, measuring whether the goal was correctly completed, which actions were taken, whether side effects were safe, and how the agent recovered from errors. I use deterministic assertions and simulators where possible, human review for subjective results, and calibrated LLM judges only as supporting signals. I track safety, tool correctness, evidence use, latency, cost, and escalation, with versioned regression tests and staged deployment.”

### Revision summary

| Dimension | Example metric/test |
|---|---|
| Task success | Acceptance criteria, completion/correctness rate. |
| Tool behavior | Selection, argument validity, action trace. |
| Safety | Authorization boundary and adversarial tests. |
| Reliability | Retries, loops, cancellation, recovery. |
| Operations | Latency, cost, timeouts, escalations. |

<br><br><br>

## What are the security risks of agentic systems, and how do you mitigate them?

**Answer:**

### Threats

Agentic systems combine model uncertainty with tools, data, and state. Key risks include:

- **Prompt injection:** Untrusted user or retrieved content manipulates instructions.
- **Excessive agency/permissions:** A tool can read or change more than the task requires.
- **Data exfiltration:** Sensitive prompt, memory, or tool data is revealed through output or external actions.
- **Unsafe side effects:** The agent sends, deletes, purchases, publishes, or modifies without proper authorization.
- **Tool/API abuse:** Malformed arguments, injection into downstream systems, rate abuse, or arbitrary code execution.
- **Memory and tenant leakage:** Cross-user retrieval, stale permissions, or unsafe caches expose data.
- **Supply-chain risk:** Untrusted tools, plugins, skills, prompts, or dependencies introduce malicious behavior.
- **Reliability failures:** Loops, retries, or hallucinated success create operational or financial harm.

### Defense in depth

1. **Least privilege:** Expose only necessary tools, data, scopes, and credentials; use read-only access by default.
2. **Server-side authorization:** Authenticate and authorize every data read and action; never let the model decide permissions.
3. **Isolate untrusted content:** Treat user, retrieved, and tool-returned text as data. Prompt separation helps but is not a security boundary.
4. **Validate and constrain:** Typed schemas, allowlists, parameterized queries, output encoding, and domain/business-rule checks.
5. **Gate side effects:** Require previews, explicit confirmation, approvals, or two-person controls for high-impact actions.
6. **Sandbox execution:** Restrict filesystem/network/process access; avoid executing arbitrary model-generated code in privileged environments.
7. **Bound the loop:** Set tool, time, token, and spend limits; add rate limiting, idempotency, cancellation, and anomaly detection.
8. **Protect secrets and observability:** Keep credentials outside model context, scope/rotate them, and redact/protect logs and traces.
9. **Test and respond:** Threat-model tools and data flows, red-team direct/indirect injection, audit actions, and maintain incident/rollback procedures.

### Concise interview answer

“Agentic risks include prompt injection, excessive permissions, data leakage, unsafe side effects, tool abuse, memory/tenant leaks, supply-chain compromise, and runaway loops. I use least privilege, server-side authorization for every call, typed validation, untrusted-input handling, sandboxing, explicit approval for high-impact actions, strict budgets, and protected audit logs. Prompts are not security controls by themselves. I test adversarial workflows end to end and make the system safe even when the model chooses incorrectly.”

### Revision summary

| Risk | Core mitigation |
|---|---|
| Injection | Treat external content as untrusted; enforce controls outside prompt. |
| Unauthorized tool/data access | Least privilege and server-side authorization. |
| Harmful side effects | Preview, confirmation, approvals, idempotency. |
| Data leakage | Secret isolation, tenant-safe memory/cache, log redaction. |
| Runaway/abuse | Budgets, sandboxing, rate limits, monitoring, rollback. |

<br><br><br>

## Your agent reads untrusted content (emails, web pages, documents) and can call tools. How do you prevent indirect prompt injection and data exfiltration?

**Answer:**

### Threat model

**Indirect prompt injection** occurs when untrusted content the agent reads—such as an email, web page, or document—contains instructions that try to change the agent’s behavior. If the agent also has tools or access to sensitive context, an attacker may try to make it retrieve or transmit data. Delimiters and instructions to “ignore commands in documents” can help convey intent, but cannot reliably prevent the model from following injected text.

The goal is therefore not to assume the model will always resist. Design the system so that an injected instruction cannot obtain unauthorized data or cause an unauthorized side effect.

### Layered containment

1. **Keep secrets out of context:** Store credentials in a secret manager and expose only scoped operations; do not include system secrets or unrelated private data in prompts.
2. **Separate data from authority:** Label external content as untrusted and keep trusted policy/configuration outside retrieved documents. This is a clarity measure, not a hard boundary.
3. **Use least-privilege tools:** Provide narrow read/write tools, scoped to the authenticated user and task; avoid generic send-anywhere, arbitrary SQL, shell, or filesystem tools.
4. **Enforce authorization at execution:** Check identity, destination, record scope, and business policy server-side for every tool call, regardless of the model’s rationale.
5. **Constrain data egress:** Use destination allowlists, DLP/redaction, payload limits, and explicit user approval before sending sensitive content externally.
6. **Gate high-impact actions:** Preview recipient, content, and effect; require confirmation for sends, deletes, purchases, or permission changes.
7. **Prevent side channels:** Do not reveal hidden prompts, unauthorized document titles, snippets, counts, or raw tool errors. Isolate caches, memory, and logs by tenant.
8. **Bound and monitor:** Limit calls, data volume, time, and spend; record safe audit events and detect suspicious access/exfiltration patterns.
9. **Test full attack paths:** Use adversarial documents that attempt to retrieve protected data, alter destinations, or trigger actions; verify server-side denial even if the model obeys them.

For email or web agents, treat content and URLs as hostile, restrict outbound destinations, and avoid automatically following instructions embedded in the content. Use a human approval step when the task crosses a trust boundary.

### Concise interview answer

“I assume an indirect injection may succeed at influencing the model, so I prevent that influence from granting authority. Secrets stay outside the prompt; external documents are labeled untrusted; tools are narrow and scoped; and every retrieval or action is authorized server-side. I constrain outbound destinations and data volume, redact sensitive payloads, require confirmation for external side effects, and isolate caches/logs. I test malicious documents end to end and verify that the application denies unauthorized access even if the agent follows the injection.”

### Revision summary

| Attack goal | Containment |
|---|---|
| Read protected data | ACL check on every retrieval/tool call. |
| Exfiltrate content | Destination allowlists, DLP, payload limits, approval. |
| Abuse tools | Narrow capabilities, typed validation, least privilege. |
| Leak prompts/secrets | No secrets in context; protect traces and outputs. |
| Evade through injection | Safe-by-construction runtime; adversarial end-to-end tests. |

<br><br><br>

## What is the difference between reactive and proactive agents?

**Answer:**

### Definitions

A **reactive agent** responds to an external request, event, or observation. It selects an action based on the current input and state, such as answering a user question or responding to an alert.

A **proactive agent** can initiate work without a fresh user request, based on a schedule, monitored event, goal, or trigger—for example, notifying an operator when a monitored service crosses a threshold. “Proactive” describes when an action is initiated, not a guarantee of greater intelligence or autonomy.

### Comparison

| Dimension | Reactive | Proactive |
|---|---|---|
| Trigger | User request or current event. | Schedule, monitored condition, or ongoing goal. |
| Main challenge | Correctly interpret and respond to input. | Decide when action is appropriate and avoid nuisance actions. |
| Risk | Incorrect response or tool action. | Unwanted, repeated, stale, or poorly timed actions. |
| Required controls | Input validation and action authorization. | Also trigger thresholds, cooldowns, quiet hours, opt-in and escalation policy. |

Proactive systems need explicit scopes and objectives, event deduplication, rate limits, cooldowns, auditability, cancellation, and user controls. High-impact actions should generally require approval. A background schedule should not be treated as permission to access or change any resource.

### Concise interview answer

“Reactive agents act in response to a user request or incoming observation. Proactive agents may initiate work from a schedule, monitored event, or ongoing goal without a new prompt. Proactive behavior can improve monitoring and automation but increases the risk of unwanted or repeated actions. I define explicit triggers and scopes, use thresholds and cooldowns, provide opt-in and cancellation, reauthorize each action, and require approval for consequential side effects.”

### Revision summary

| Aspect | Reactive | Proactive |
|---|---|---|
| Initiation | External request/event. | Agent/system trigger or schedule. |
| Additional need | Interpret the current task. | Trigger policy, cooldown, opt-in, cancellation. |
| Safety | Validate and authorize action. | Also prevent unsolicited/repeated actions. |
| High-impact work | Confirmation as needed. | Stronger approval and audit controls. |

<br><br><br>

## How do you manage token consumption and cost in long-running agent workflows?

**Answer:**

### Measure cost by workflow stage

Long-running agents may resend instructions, history, tool descriptions, and observations on every model call. Cost can therefore grow with both the number of steps and the amount of repeated context. Instrument token usage and cost by model call, task, user/tenant, tool, and workflow stage; also track latency and success so cost cuts are not made blindly.

### Practical controls

- **Set budgets:** Enforce per-call and per-task limits for input/output tokens, model calls, tools, wall-clock time, and spend.
- **Keep context focused:** Include only relevant history and tool output; deduplicate retrieved data and use compact structured state.
- **Compact carefully:** Summarize older turns while preserving goals, constraints, verified results, provenance, and unresolved issues; keep critical instructions verbatim.
- **Use the right model:** Route routine classification or extraction to smaller/cheaper models and escalate only when quality requires it.
- **Bound the loop:** Use explicit stop conditions, progress checks, and repeated-state detection to avoid unproductive calls.
- **Avoid redundant calls:** Cache safe reusable results, batch independent work, and parallelize only when it reduces end-to-end latency without multiplying unnecessary work.
- **Control tool output:** Return bounded, relevant results rather than entire pages, records, or logs.
- **Apply retries selectively:** Retry transient, idempotent failures within a limit; do not loop on permanent errors or ambiguous side effects.

Cache keys and stored state must respect tenant isolation, permissions, freshness, and data-retention requirements. Evaluate changes on held-out tasks for success, safety, and quality as well as tokens and cost; aggressive truncation or lower-cost routing can cause silent failures.

### Concise interview answer

“I instrument token and dollar cost per call and task, then enforce hard per-task budgets for tokens, calls, tools, time, and spend. I reduce repeated context with structured state and validated compaction, bound tool outputs and loops, route simple steps to smaller models, cache only when privacy and freshness permit, and retry selectively. I parallelize independent work when it helps latency. Every optimization is checked against task success, safety, and quality so cost reduction does not simply hide failure.”

### Revision summary

| Cost driver | Control |
|---|---|
| Repeated history/context | Relevant state, deduplication, careful compaction. |
| Too many model calls | Stop/progress checks, bounded retries, simpler workflow. |
| Expensive model for all steps | Risk/complexity-based model routing. |
| Large tool responses | Filter, paginate, summarize with provenance. |
| Hidden regressions | Track cost beside success, quality, latency, and safety. |

<br><br><br>

## What is the human-in-the-loop pattern for agents, and when is it needed?

**Answer:**

### Definition

**Human-in-the-loop (HITL)** is a design pattern in which a person reviews, approves, corrects, or supplies information at defined points in an agent workflow. The human can be a prerequisite for an action, a reviewer of uncertain output, or an escalation path when the agent cannot safely proceed.

### When it is useful

- High-impact or irreversible actions, such as deleting data, sending external communications, changing permissions, or making purchases.
- Decisions with legal, medical, financial, employment, safety, or significant reputational consequences.
- Low confidence, conflicting evidence, missing information, or a policy exception.
- Novel situations outside the agent’s validated operating envelope.
- Workflows where accountability or an explicit approval record is required.

HITL is not needed for every low-risk, reversible step; excessive approvals can make a system unusable and lead to rubber-stamping.

### Design an effective approval point

1. Define trigger conditions by risk, uncertainty, and action type.
2. Show the reviewer the proposed action, relevant evidence and sources, target/recipient, consequences, and what the agent will do next.
3. Offer clear approve, reject, edit, or request-more-information choices.
4. Bind approval to the exact action payload and current state; if the payload changes, require renewed approval.
5. Apply timeouts, cancellation, and safe behavior when no reviewer is available.
6. Record the decision, reviewer, timestamp, and relevant version for audit, subject to privacy policy.
7. Monitor approval rates, reversal rates, reviewer workload, and downstream outcomes.

Human approval does not replace server-side authorization or validation. A reviewer should not be asked to approve an opaque action without evidence or a clear explanation.

### Concise interview answer

“HITL inserts a person at explicit decision points to review, correct, approve, or escalate an agent’s work. I use it for high-impact or irreversible actions, policy exceptions, low-confidence results, and decisions requiring accountability. The review screen should expose the exact action, target, evidence, and consequences; approval is bound to that payload and invalidated if it changes. I also define timeout behavior and audit decisions. For routine low-risk actions, I automate with guardrails to avoid approval fatigue.”

### Revision summary

| HITL element | Purpose |
|---|---|
| Trigger | Risk, uncertainty, exception, or accountability requirement. |
| Review context | Evidence, exact action, target, and impact. |
| Decision | Approve, reject, edit, or request clarification. |
| Binding | Approval applies only to the reviewed payload/state. |
| Operations | Timeout, audit, workload and outcome monitoring. |

<br><br><br>

## How do you implement guardrails for AI agents to prevent harmful actions?

**Answer:**

### Use layered, enforceable controls

Agent guardrails should constrain what the system can access and do, not rely only on instructions asking the model to behave. Put critical controls in the trusted orchestrator, tool services, identity layer, and execution environment.

### Defense-in-depth design

1. **Define policy and risk tiers:** Classify tools/actions by sensitivity, impact, reversibility, and data type.
2. **Use least privilege:** Expose only required tools, resources, and credentials; default to read-only where possible.
3. **Authorize every operation:** Check the authenticated user, tenant, resource, and action server-side at execution time.
4. **Validate inputs and outputs:** Enforce schemas, ranges, allowlists, business invariants, parameterized queries, and safe output encoding.
5. **Gate side effects:** Preview actions and require explicit confirmation or human approval for high-impact operations.
6. **Sandbox risky execution:** Restrict filesystem, network, process, and resource access; do not run arbitrary generated code with production privileges.
7. **Bound the agent:** Limit calls, steps, time, tokens, spend, rate, and data volume; provide cancellation and stop conditions.
8. **Handle untrusted content:** Treat user, retrieved, and tool-returned text as data; isolate secrets and prevent unauthorized egress.
9. **Audit and recover:** Log decisions safely, use idempotency and rollback where possible, and define incident response.
10. **Test continuously:** Red-team prompt injection, misuse, boundary conditions, and permission changes; monitor false blocks and harmful successes.

Guardrails can reduce risk but do not make probabilistic systems infallible. For prohibited or high-consequence operations, use deterministic policy enforcement and human oversight rather than asking the model to judge whether its own action is permitted.

### Concise interview answer

“I implement guardrails in layers: policy tiers, least-privilege tools, server-side authorization, strict validation, sandboxing, hard resource limits, and approval for high-impact side effects. I keep secrets outside model context, treat external content as untrusted, constrain data egress, and provide audit, cancellation, and recovery. Prompts and classifiers can be supplementary, but critical restrictions must be enforced by trusted code. I continuously test adversarial paths and monitor both harmful actions and excessive false blocking.”

### Revision summary

| Guardrail | Enforced by |
|---|---|
| Identity and permissions | Trusted application/service. |
| Valid action/arguments | Schema and business-rule validation. |
| Execution scope | Least privilege and sandbox. |
| High-impact changes | Preview, confirmation, approval. |
| Runaway or leakage | Budgets, egress controls, audit, monitoring. |

<br><br><br>

## What is agent reflection, and how does it improve agent performance?

**Answer:**

### Definition

**Agent reflection** is a step in which an agent reviews its plan, intermediate results, tool observations, or completed answer and decides whether to revise, verify, continue, or stop. Reflection may be a self-critique prompt, a separate evaluator, comparison against explicit criteria, or a structured checkpoint in the workflow.

It is not the same as model training or guaranteed self-improvement. A model can critique its own work incorrectly, repeat the same assumptions, or produce a persuasive but invalid justification.

### How it can help

Reflection can catch omitted requirements, inconsistent results, incomplete tool execution, or missing evidence—especially when the agent compares its work with a concrete checklist or external verification result. A code agent might inspect test output and confirm that the requested behavior is covered before summarizing completion.

### Make reflection evidence-based and bounded

1. Define explicit criteria for completeness and correctness.
2. Provide the actual observations, sources, tests, and current state to review.
3. Ask for specific checks (missing requirement, unsupported claim, failed test), not a vague “think again.”
4. Use deterministic validators or independent evidence for objective properties.
5. Permit at most a bounded number of revisions and measure whether they improve results.
6. Record the original and revised outcomes for evaluation; stop if reflection makes no progress.

Reflection adds calls, latency, and tokens; self-review may share the same model’s blind spots. For simple tasks, it may not help. Evaluate error reduction and regression rate against a no-reflection baseline, and do not expose hidden chain-of-thought when a concise checklist result is sufficient.

### Concise interview answer

“Reflection is a review step where an agent checks its plan or output against criteria and may revise, verify, or stop. It can catch omissions or inconsistency when grounded in tool results, tests, citations, or a concrete checklist. It is not a guarantee of correctness: self-critique can share the original error and adds cost and latency. I bound the number of passes, use independent or deterministic checks where possible, and keep reflection only when evaluation shows a measurable benefit.”

### Revision summary

| Reflection input | Useful check |
|---|---|
| User requirements | Completeness and scope. |
| Tool observations/tests | Whether execution actually succeeded. |
| Retrieved sources | Claim support and citation accuracy. |
| Current state | Progress, unresolved issues, stop decision. |
| Safeguard | Bound revisions and compare with baseline. |

<br><br><br>

## What is the difference between code-generating agents and tool-calling agents?

**Answer:**

### Distinction

A **code-generating agent** produces source code or scripts as an artifact. That code may be reviewed, tested, and then executed by a separate controlled system. A **tool-calling agent** requests operations through a predefined tool interface; the host application validates and executes those operations.

The categories can overlap: a coding agent may use tools to inspect files, edit code, and run tests, while a tool-calling agent may generate code as one step. The key distinction is how the action is represented and executed—not whether the model is capable of writing code.

### Comparison

| Dimension | Code-generating agent | Tool-calling agent |
|---|---|---|
| Output/action | Code or script artifact. | Structured request to an exposed capability. |
| Execution | Must be separately run in a controlled environment. | Host calls a predefined tool after checks. |
| Flexibility | High; code can express many operations. | Bounded by tool set and schemas. |
| Risk | Arbitrary code execution, dependency or data access risks. | Tool misuse, bad arguments, authorization and side-effect risks. |
| Controls | Sandbox, static analysis, tests, review, resource/network limits. | Narrow tools, schema/business validation, authorization, confirmation. |

Never assume generated code is safe merely because the model produced it. Likewise, predefined tools are not automatically safe; they can be overbroad or misconfigured. Use the narrowest capability that meets the task.

### Concise interview answer

“A code-generating agent returns code that a separate runtime may execute; a tool-calling agent requests an operation through a predefined interface that the host executes after validation and authorization. Code offers greater flexibility but needs strong sandboxing, review, and testing. Tool calls are easier to constrain but still require least privilege and side-effect controls. The approaches can be combined, and I choose the narrowest execution mechanism that safely satisfies the task.”

### Revision summary

| Property | Code generation | Tool calling |
|---|---|---|
| Action form | Code artifact. | Typed operation request. |
| Execution authority | Separate runtime. | Host/tool service. |
| Key controls | Sandbox, review, tests, resource limits. | Schema, authorization, allowlists, confirmation. |
| Shared principle | Treat model output as untrusted; verify before execution. |

<br><br><br>

## How do you handle multi-modal inputs and outputs in agentic systems?

**Answer:**

### Treat modality as part of the task and tool contract

Multimodal agents may receive or produce text, images, audio, video, or structured spatial data. The agent runtime must preserve the modality and its metadata; converting everything to plain text can lose visual layout, speaker identity, timing, coordinates, or uncertainty.

### Input handling

- **Normalize and validate:** Check file type, size, duration, resolution, encoding, and supported modality before processing.
- **Preserve provenance:** Keep source IDs, timestamps, page/frame numbers, regions, and speaker labels where applicable.
- **Choose modality-aware models/tools:** Use vision encoders for images, speech recognition for audio, frame sampling for video, or domain-specific parsers for documents.
- **Segment long media:** Split audio/video into bounded windows while retaining timestamps and cross-window context.
- **Protect privacy and access:** Apply the same authentication, ACL, retention, and redaction controls to media and derived transcripts/captions.
- **Treat derived text as uncertain:** OCR, ASR, and model-generated captions can be wrong; preserve links to the original input and confidence where available.

### Output and action handling

Define output schemas for text plus media references, timestamps, or structured values. Validate generated media and metadata before delivery. If an agent uses an external tool based on an image/audio interpretation, verify critical entities and actions; require user confirmation for consequential decisions. Bound media-processing calls and resource use.

### Evaluation

Test each modality and cross-modal task separately: OCR/ASR accuracy, visual grounding, timestamp alignment, speaker attribution, structured extraction, output validity, and end-to-end task success. Include noisy, adversarial, incomplete, and unsupported inputs.

### Concise interview answer

“I handle multimodal agents with modality-aware ingestion and tools, preserving the original media and metadata such as page regions, timestamps, or speakers. I validate size and format, segment long media carefully, and treat OCR, transcripts, and captions as fallible derived evidence. The same ACL, privacy, and retention controls apply to media and its derivatives. Outputs are schema-validated, consequential actions require confirmation, and each modality is evaluated with appropriate grounding and alignment metrics.”

### Revision summary

| Modality concern | Practice |
|---|---|
| Input fidelity | Use appropriate vision/audio/video processing; preserve originals. |
| Long inputs | Segment with timestamps and bounded context. |
| Provenance | Track pages, regions, frames, speakers, and source IDs. |
| Safety/privacy | Validate, authorize, minimize retention, confirm actions. |
| Quality | Evaluate modality-specific accuracy and cross-modal grounding. |

<br><br><br>

## How do you implement state management in complex agent workflows?

**Answer:**

### Separate durable workflow state from prompt context

Complex agent state includes the user goal, inputs, current step, completed work, pending actions, tool results, approvals, errors, and version information. Do not rely on the model’s conversational context as the only source of truth. Persist structured workflow state in an application-controlled store; construct a bounded model context from that state for each invocation.

### State-management design

1. **Define a typed schema:** Include workflow/task ID, status, goal, constraints, step list, outputs, provenance, retries, and timestamps.
2. **Use explicit states and transitions:** For example, `pending`, `running`, `waiting_for_approval`, `completed`, `failed`, or `cancelled`; validate legal transitions.
3. **Persist checkpoints:** Record verified outputs and side-effect status after each meaningful step so a workflow can resume safely.
4. **Version state and prompts/tools:** Record model, prompt, tool, workflow, and data/index versions needed to reproduce a run.
5. **Handle concurrency:** Use transactions, optimistic concurrency/version checks, or locks so parallel workers do not overwrite newer state.
6. **Make actions idempotent:** Store operation IDs and idempotency keys to prevent duplicate effects during retries or resume.
7. **Protect and expire data:** Enforce tenant boundaries, encryption/access control, retention, deletion, and audit policies.
8. **Separate context selection:** Provide the model only current relevant state, not the entire event log; summarize with provenance when necessary.

### Recovery and observability

On restart, reconstruct the next action from durable state and actual tool status—not from a model-generated summary alone. Track state transitions, retries, approvals, and errors; provide cancellation and manual intervention. Test crashes between action execution and result persistence, since that is a common source of duplicate or uncertain side effects.

### Concise interview answer

“I keep authoritative workflow state outside the model context in a typed, versioned store. It records goal, status, steps, verified outputs, provenance, approvals, retries, and side-effect IDs. The orchestrator enforces legal transitions, checkpoints progress, uses transactions or concurrency control, and makes actions idempotent so retries and restarts are safe. Each model call receives only a bounded view of current state. I also enforce tenant isolation, retention, cancellation, and recovery from crashes between execution and persistence.”

### Revision summary

| State concern | Control |
|---|---|
| Progress | Typed status and explicit state transitions. |
| Resume | Checkpoints and source-of-truth tool status. |
| Duplicate effects | Idempotency keys and operation IDs. |
| Concurrent work | Transactions/version checks/locks. |
| Context and privacy | Bounded context, tenant isolation, retention controls. |

<br><br><br>

## How do you build a customer support agent with escalation logic?

**Answer:**

### Start with scope, data, and outcomes

Define which support intents the agent may handle, which knowledge sources and account systems it may access, and which actions it may take. Set explicit quality and safety thresholds. The agent should not invent account status, policy exceptions, refunds, or commitments that are not supported by authorized sources.

### Typical support workflow

1. **Authenticate and identify the request:** Collect the minimum information needed; verify identity before exposing account-specific data.
2. **Classify and route:** Determine intent, urgency, language, and whether the issue is in scope.
3. **Retrieve trusted knowledge:** Search current, versioned support policies with user-specific ACLs and citations.
4. **Resolve or gather facts:** Use narrowly scoped read tools; validate account/order state in the source system.
5. **Draft a response:** Explain supported steps clearly, cite relevant policy, and ask targeted clarification if needed.
6. **Escalate when required:** Create or transfer a ticket with a concise, factual summary, sources, actions already tried, and unresolved questions.
7. **Confirm side effects:** Require approval for refunds, account changes, cancellations, or outbound commitments unless a separately approved policy explicitly permits automation.

### Escalation logic

Escalate for low confidence, conflicting or missing evidence, out-of-scope requests, repeated failed resolution, sensitive/high-impact cases, explicit user request, policy exceptions, suspected fraud/security incidents, or a negative customer sentiment threshold if that signal is validated. Preserve conversation context and do not make the user repeat information unnecessarily.

### Evaluation and operations

Measure resolution accuracy, containment and escalation rates, time to resolution, repeat contacts, customer satisfaction, policy adherence, hallucination rate, privacy/access incidents, and quality by intent/language. Audit sampled conversations and tune thresholds to avoid both unsafe containment and excessive escalation.

### Concise interview answer

“I build a support agent around authenticated identity, scoped intents, authoritative knowledge retrieval, and read tools for account facts. It cites policy, asks clarifying questions, and escalates for uncertainty, conflict, high impact, policy exceptions, repeated failure, security concerns, or user request. Handoffs include a concise evidence-backed summary and attempted steps. Writes such as refunds or account changes require explicit policy and approval. I monitor resolution, escalation, repeat contacts, safety, and customer experience by intent and language.”

### Revision summary

| Stage | Responsibility |
|---|---|
| Authenticate | Verify user before private account data. |
| Retrieve | Use current authorized policy and source citations. |
| Resolve | Read-only facts first; validate before claims/actions. |
| Escalate | Uncertainty, risk, exception, repeated failure, or user request. |
| Measure | Resolution, policy compliance, customer outcomes, safety. |

<br><br><br>

## What is agent orchestration, and how do you implement it?

**Answer:**

### Definition

**Agent orchestration** coordinates model calls, tools, state, and possibly multiple agents into an executable workflow. It decides which step runs next, what context is passed, how results are validated, how failures are handled, and when the task completes or pauses for a person.

Orchestration may be a simple application loop, a deterministic workflow/state machine, a graph, or a multi-agent coordinator. The appropriate design depends on branching, persistence, observability, and reliability needs; a framework is not required for every workflow.

### Implementation principles

1. **Model the workflow:** Identify steps, dependencies, branches, success criteria, and human-approval points.
2. **Separate decisions from enforcement:** Let the model propose actions, but have trusted code validate, authorize, and execute them.
3. **Define typed contracts:** Give each model/tool/worker clear inputs, outputs, and error states.
4. **Persist state:** Store checkpointed progress and operation IDs outside the prompt.
5. **Bound execution:** Enforce step, tool, time, token, concurrency, and cost budgets.
6. **Handle failures:** Use bounded retries, idempotency, fallback, cancellation, and explicit incomplete status.
7. **Trace and evaluate:** Record stage timings and version metadata safely; measure end-to-end outcomes and side effects.

For a linear, predictable task, deterministic orchestration is often simpler and safer. Use model-driven branching only where its adaptivity adds measurable value.

### Concise interview answer

“Agent orchestration coordinates planning, model calls, tools, state, validation, and stopping. I represent the workflow as explicit steps or a state graph with typed inputs/outputs, legal transitions, checkpoints, and failure paths. The model can propose the next action, but the orchestrator enforces permissions, budgets, and approvals. I add idempotent execution, retries and cancellation, and stage-level traces. I choose deterministic workflow control for predictable paths and model-driven branching only when it improves measured performance.”

### Revision summary

| Orchestration responsibility | Implementation |
|---|---|
| Control flow | Steps, branches, dependencies, stop conditions. |
| State | Durable checkpoints, task IDs, operation status. |
| Security | Trusted authorization and policy enforcement. |
| Reliability | Timeouts, idempotency, recovery, cancellation. |
| Observability | Versioned traces, per-stage metrics, end-to-end tests. |

<br><br><br>

## What is Sakana Fugu, and how does it orchestrate a team of AI models?

**Answer:**

### Be precise about the name

The source question names **“Sakana Fugu,”** but that label alone is not enough to establish a specific public system, paper, or implementation. Without a verifiable source defining what “Fugu” refers to, it would be unsafe to claim exact architecture, capabilities, or that it orchestrates a team of models in a particular way. Confirm the intended reference—such as a specific Sakana AI project, article, or repository—before making product-specific claims.

### General pattern: orchestrating multiple models

In a generic multi-model orchestration system, a controller routes tasks to specialized models, runs independent work in parallel, combines results, and optionally uses a verifier or human reviewer. A robust design defines:

1. **Routing criteria:** Which model handles which task, based on capability, latency, cost, modality, and policy.
2. **Task contracts:** Typed inputs/outputs and a bounded objective for each model.
3. **Coordination:** Sequential handoffs, parallel fan-out/fan-in, or a workflow graph.
4. **Evidence and provenance:** Track which model and sources produced each claim.
5. **Conflict resolution:** Use deterministic criteria, independent verification, or surface disagreement rather than blindly majority-voting.
6. **Safety and budgets:** Restrict tools/data, enforce privacy boundaries, and cap calls, tokens, latency, and spend.
7. **Evaluation:** Compare the ensemble with the best single-model baseline on quality, reliability, cost, and latency.

Multiple models do not guarantee independent judgments; models can share training data, blind spots, or prompt sensitivity. Model routing and consensus only help when measured on the target workload.

### Concise interview answer

“I cannot infer a specific architecture from the name ‘Sakana Fugu’ alone; I would verify the intended Sakana AI project or source before attributing implementation details. In general, a system that orchestrates multiple models uses a controller to route bounded subtasks, run independent work, combine results, and verify conflicts. It needs typed contracts, provenance, safety controls, and call/cost budgets. I would compare it with the strongest single-model baseline because model count alone does not establish a benefit.”

### Revision summary

| Question | Reliable answer |
|---|---|
| What does “Sakana Fugu” mean? | Verify the referenced source; the name alone is ambiguous. |
| Generic orchestration | Controller routes, delegates, combines, verifies. |
| Risks | Correlated errors, extra latency/cost, privacy boundaries. |
| Evidence | Track model/source provenance and expose unresolved conflict. |
| Decision | Benchmark against a single-model baseline. |

<br><br><br>

## How do you build a code execution agent safely using sandboxed environments?

**Answer:**

### Treat generated code as untrusted

Code produced by a model must be assumed capable of mistakes or malicious behavior, whether caused by the prompt, retrieved content, dependencies, or the model itself. Do not execute it inside the agent host process or with production credentials.

### Sandbox architecture

1. **Isolate execution:** Use a disposable, strongly isolated environment such as a hardened container or microVM with a non-root identity; choose isolation strength based on the threat model.
2. **Restrict resources:** Enforce CPU, memory, process, file-size, and wall-clock limits; kill the environment after the run.
3. **Constrain filesystem access:** Mount only required inputs and a bounded output directory; avoid host sockets and sensitive paths.
4. **Control networking:** Default to no network. If required, use explicit destination allowlists and egress controls; do not expose cloud metadata endpoints.
5. **Protect secrets:** Never place production credentials in the sandbox. Use short-lived, scoped credentials only when indispensable.
6. **Control dependencies:** Use pinned, reviewed dependencies or an approved package mirror; consider disabling package installation in the execution path.
7. **Separate proposal from execution:** Review or statically analyze code where appropriate, then execute only in the sandbox. Treat static checks as a layer, not a proof of safety.
8. **Validate outputs:** Treat files, logs, and results as untrusted; scan/size-limit them and do not automatically execute follow-on artifacts.
9. **Audit and clean up:** Record task and image versions, resource usage, exit status, and safe logs; destroy the sandbox and temporary data according to retention rules.

### Operational safeguards

Require human approval for production-affecting actions. Keep sandbox images patched, test escape resistance, monitor resource exhaustion, and isolate concurrent jobs. If the task requires access to production data, provide a sanitized snapshot or a narrowly scoped read-only API rather than a production credential.

### Concise interview answer

“I assume generated code is untrusted and never execute it in the agent host or with production credentials. I run it in a disposable, strongly isolated sandbox with non-root identity, no network by default, restricted filesystem mounts, CPU/memory/time limits, and controlled dependencies. Outputs are treated as untrusted, scanned and bounded, and the environment is destroyed after execution. Static analysis and review are additional layers, not substitutes for isolation; production changes require separate authorization and approval.”

### Revision summary

| Risk | Control |
|---|---|
| Host/data access | Strong isolation, minimal mounts, no host sockets. |
| Exfiltration | No network by default; egress allowlist if essential. |
| Resource abuse | CPU, memory, process, output, and time limits. |
| Credential exposure | No production secrets; scoped short-lived access only if necessary. |
| Persistence | Disposable environment, audited execution, cleanup. |

<br><br><br>

## Your AI agent is stuck in an infinite loop. How do you detect and break the cycle?

**Answer:**

### Detect lack of progress

An agent may loop through repeated tool calls, rephrase the same search, alternate between two states, retry a permanent error, or produce slightly different text without advancing the task. Track structured signals rather than relying only on identical text:

- repeated tool name and normalized arguments;
- repeated state hashes, observations, or plan steps;
- no change in verified task state over several iterations;
- recurring error codes or oscillation between states;
- step, call, token, latency, or spend budget approaching its limit.

### Break the cycle safely

1. Set hard maximums for steps, tool calls, retries, elapsed time, and cost in the orchestrator.
2. Detect repeated actions/states and stop or require a materially different next action.
3. Classify the error: retry transient failures with bounded backoff; stop on invalid input, authorization denial, or other permanent errors.
4. Feed the agent concise, factual error/observation data and ask for a different bounded plan only when policy allows.
5. Checkpoint verified progress and make side effects idempotent before resuming.
6. Escalate to the user or a human if the task remains blocked; report what completed and what did not.

Do not silently reset state and let the same loop repeat. For non-idempotent tools, first determine whether a prior call may have succeeded before retrying.

### Concise interview answer

“I detect loops from repeated normalized tool calls, repeated state hashes, recurring errors, and lack of verified progress—not just identical model text. The orchestrator enforces hard step/time/token/cost budgets and stops repeated states. It retries only transient, idempotent failures with bounded backoff; permanent errors trigger a stop or escalation. I checkpoint progress, verify uncertain side effects before retrying, and tell the user honestly when the task is incomplete.”

### Revision summary

| Signal | Response |
|---|---|
| Same tool/arguments repeatedly | Stop or require a changed plan. |
| State not advancing | Terminate at no-progress threshold. |
| Transient error | Bounded backoff and retry if idempotent. |
| Permanent/authorization error | Stop; do not retry blindly. |
| Uncertain side effect | Check operation status before resuming. |

<br><br><br>

## Your AI agent gets conflicting answers from different tools. How does it reconcile them?

**Answer:**

### Preserve each result and establish its meaning

Conflicting tool results may differ because they answer different questions, use different scopes or timestamps, reflect stale caches, or come from sources with different authority. Do not simply average values or let the model choose the most plausible one.

For each result, retain source identity, timestamp, query/parameters, scope, version, units, status, and provenance. Verify that the tools refer to the same entity, time period, jurisdiction, and definition.

### Reconciliation workflow

1. **Check the request and parameters:** Confirm both tools were called with equivalent identifiers, filters, units, and date ranges.
2. **Check freshness and status:** Compare timestamps, effective dates, and whether a record is current, provisional, or superseded.
3. **Apply a defined source-of-truth policy:** Prefer an authoritative system for that data type, established by the application/domain owner.
4. **Requery or cross-check:** If practical, call the authoritative source or an independent validation tool; avoid unbounded retries.
5. **Expose unresolved conflict:** If there is no policy or evidence to resolve the disagreement, present both values and their sources, qualify uncertainty, or ask for human review.
6. **Prevent recurrence:** Fix stale caches, inconsistent schemas, unit conversion, tool descriptions, or ownership of the source of truth.

For high-impact decisions, fail closed or escalate rather than selecting silently. Tool confidence scores are not automatically calibrated and should not substitute for authority rules.

### Concise interview answer

“I preserve source, timestamp, scope, units, and parameters for every tool result, then verify that the results are truly comparable. I apply an explicit source-of-truth hierarchy and freshness policy, requery the authoritative system when appropriate, and correct stale caches or schema mismatches. If the conflict remains unresolved, the agent should disclose it with provenance or escalate—not guess. High-impact actions should fail closed until the discrepancy is resolved.”

### Revision summary

| Conflict cause | Check |
|---|---|
| Different inputs | IDs, filters, units, time ranges, scope. |
| Stale results | Timestamp, effective version, cache/index freshness. |
| Authority | Domain-approved source-of-truth policy. |
| No resolution | Explain conflict, qualify, or escalate. |
| Systemic issue | Fix schema, cache, source ownership, or tool contract. |

<br><br><br>

## Your AI agent burns too many tokens per task. How do you reduce token consumption?

**Answer:**

### Measure where tokens are spent

Instrument input and output tokens for every model call, grouped by task, step, model, and content source. Long workflows often spend more on repeated system prompts, full conversation history, verbose tool results, and unnecessary reasoning than on the final answer itself.

### Reduce waste without losing necessary information

- **Use targeted context:** Retrieve relevant files/documents and send bounded excerpts instead of whole corpora or logs.
- **Keep structured state:** Pass a compact task summary and verified milestones rather than replaying every prior turn.
- **Compact carefully:** Remove redundant or superseded content while preserving constraints, IDs, provenance, decisions, and pending work.
- **Trim tool outputs:** Filter, paginate, or summarize results close to the source; retain links/IDs to fetch details on demand.
- **Reduce unnecessary calls:** Improve stopping conditions, avoid repeated searches, and parallelize only independent work.
- **Route appropriately:** Use smaller/cheaper models for simple extraction, classification, or formatting, with quality-based escalation.
- **Constrain responses:** Ask for the needed format and set output limits; avoid verbose chain-of-thought when it does not help.
- **Cache safely:** Reuse stable results when the key respects tenant, permissions, freshness, and model/index versions.

### Validate the savings

Compare tokens and cost alongside task success, evidence coverage, safety, and latency. Context compression is lossy; shorter prompts can increase tool retries or cause the agent to forget a constraint. For long-running workflows, enforce a per-task budget and stop before further calls exceed it.

### Concise interview answer

“I first break token usage down by call and content source. Then I reduce repeated history through structured state and validated compaction, retrieve only relevant context, bound tool outputs, eliminate repeated calls, use smaller models for suitable steps, and constrain output length. Caching is permission- and freshness-aware. I verify the change against task success, evidence use, safety, latency, and retries, because token reduction that makes the agent forget constraints is not a real improvement.”

### Revision summary

| Token source | Optimization |
|---|---|
| Replayed history | Compact state with provenance and pending steps. |
| Oversized context/tool results | Retrieve, filter, paginate, or fetch on demand. |
| Excess model calls | Stop/progress checks and deduplicated actions. |
| Costly model/output | Model routing and bounded response format. |
| Regression risk | Evaluate quality and safety beside token savings. |

<br><br><br>

## Your AI agent keeps exceeding its budget per task. How do you enforce budget limits?

**Answer:**

### Enforce budgets outside the model

Asking an agent to “stay within budget” is not enforcement. The orchestrator and tool runtime should track usage and deny or pause work when hard limits are reached. Define budgets per task and, where needed, by tenant/user and workflow stage.

### Budget dimensions and controls

- **Model calls/tokens:** Track actual usage, including retries, tool-selection calls, input, and output tokens.
- **Money:** Estimate cost using the selected model/tool pricing and reconcile against actual billing data.
- **Time:** Use wall-clock deadlines, per-call timeouts, and queue limits.
- **Actions:** Cap tool calls, external requests, parallel workers, and high-impact operations.
- **Resources:** Bound concurrency, CPU/memory, sandbox execution, and output volume.

Before each operation, estimate or reserve its maximum possible cost; after completion, settle against actual usage. Use a central budget ledger or atomic reservation to avoid concurrent subtasks each spending the full remaining balance. Define warning thresholds, a hard stop, and safe degradation—for example, summarize verified progress or ask the user whether to continue.

### Safe budget behavior

When a limit is reached, stop initiating new work, cancel safe in-flight operations where possible, and report completed versus pending steps and incurred cost. Do not drop safety checks or authorization to save money. Allow an authorized user to increase a limit explicitly; record the change. Test boundary cases, concurrency, retries, and provider billing discrepancies.

### Concise interview answer

“I enforce budgets in the orchestrator, not through prompt instructions. I set per-task caps for tokens, dollars, time, tool calls, concurrency, and resource-heavy execution; reserve estimated cost before starting work and reconcile actual usage afterward. A shared atomic ledger prevents parallel workers from overspending. At a threshold, the system warns, degrades safely, or stops and reports progress. It never bypasses security checks to meet a budget, and budget increases require explicit authorization.”

### Revision summary

| Budget | Enforcement |
|---|---|
| Tokens/cost | Usage tracking, reservation, hard cap. |
| Time | Deadline, per-call timeout, cancellation. |
| Tool actions | Call quotas, rate limits, operation caps. |
| Parallel work | Shared atomic budget and concurrency limits. |
| Exhaustion | Safe stop, honest status, explicit authorized extension. |

<br><br><br>

## Your AI agent hallucinates tool capabilities and passes wrong inputs. How do you fix it?

**Answer:**

### Separate model assumptions from the actual tool contract

The model may invent a parameter, use the wrong field name, assume an unsupported operation, or infer capabilities from a vague description. First capture the exact tool definitions and request, then inspect whether the problem is ambiguous tool documentation, overlapping tools, a missing schema constraint, stale capability metadata, or a task the interface cannot express.

### Improve the interface and runtime

1. **Make tools narrow and explicit:** Use one clear responsibility per tool, action-oriented names, concise descriptions, preconditions, side effects, and limitations.
2. **Use strict schemas:** Define required fields, types, enums, ranges, formats, and explicit null/omission behavior. Avoid free-form arguments where a constrained field is possible.
3. **Expose only available capabilities:** Do not advertise operations that are disabled, unauthorized, or unavailable in the current environment; keep tool catalogs synchronized with runtime behavior.
4. **Validate server-side:** Reject unknown tools and invalid arguments before execution; apply domain/business rules and authorization even when the schema passes.
5. **Return useful, bounded errors:** Distinguish invalid arguments, permission denial, not found, and transient failure. Do not silently coerce invalid input or expose secrets in error text.
6. **Use clarification for ambiguity:** Ask the user when a required value cannot be safely inferred; do not guess identifiers, amounts, recipients, or destructive targets.
7. **Add examples and tests:** Provide valid/invalid examples where helpful; test boundary values, omissions, hallucinated fields, and unauthorized inputs.

For high-impact operations, validate a preview and require confirmation. Tool schema constraints reduce errors but do not replace execution-time checks.

### Concise interview answer

“I inspect the exact tool definition and failing call to find whether the schema, description, or exposed capability is ambiguous or stale. I make tools narrow, document preconditions and side effects, use strict typed schemas, and expose only currently available operations. The runtime rejects unknown tools and validates arguments, authorization, and business rules before execution; ambiguous required values trigger clarification rather than guessing. I add explicit error categories and regression tests, with confirmation for high-impact calls.”

### Revision summary

| Failure | Fix |
|---|---|
| Invented capability | Expose only registered, available tools. |
| Wrong/missing field | Strict schema and clear examples/descriptions. |
| Plausible but invalid value | Server-side domain and authorization checks. |
| Ambiguous request | Ask for clarification; never guess critical fields. |
| Regressions | Test malformed, boundary, and unauthorized calls. |

<br><br><br>

## Your AI agent deleted a production database. How do you prevent irreversible actions?

**Answer:**

### Immediate incident response

If a production deletion has occurred, first stop further destructive actions: disable or revoke the affected tool/credential, pause the agent workflow, preserve audit logs and request traces, and notify the responsible incident responders. Assess scope and data integrity, follow the organization’s incident and recovery procedures, and restore from verified backups or replicas only under authorized change control. Do not let the agent attempt speculative repair.

### Prevent recurrence by construction

1. **Remove production destructive capabilities by default:** Use separate environments and credentials; development agents should not have production write access.
2. **Apply least privilege:** Prefer read-only roles, resource-scoped credentials, and narrow APIs over generic SQL or administrative tools.
3. **Require staged, explicit approval:** For destructive operations, show the exact target, scope, and consequence; bind approval to the exact action and current state.
4. **Add deterministic policy gates:** Block disallowed operations in the service layer, regardless of model output or prompt.
5. **Use reversible mechanisms:** Soft-delete, transactions, snapshots, backups, point-in-time recovery, and tested restore procedures where available.
6. **Protect against duplicate or stale actions:** Use idempotency keys, precondition/version checks, and safe retry semantics.
7. **Separate duties:** Require stronger approval or dual control for high-impact production changes.
8. **Audit and test:** Log actor, identity, tool, parameters, approvals, and outcome; run destructive-action simulations in staging and verify backup recovery.

A confirmation prompt is only one layer. It cannot replace least privilege, service-side authorization, backups, and tested recovery.

### Concise interview answer

“I would first halt the agent’s destructive access, preserve evidence, assess impact, and follow incident recovery using verified backups or point-in-time restore under change control. To prevent recurrence, I remove production write access by default, use least-privilege scoped APIs, enforce deterministic server-side policy, and require approval bound to the exact target and action. I add soft-delete/transactions, preconditions, idempotency, tested backups, and audit trails. Prompt instructions alone are not a safeguard against irreversible operations.”

### Revision summary

| Layer | Prevention/recovery |
|---|---|
| Capability | No production destructive access by default. |
| Authorization | Scoped role and deterministic service-side policy. |
| Approval | Exact action/target preview; dual control where warranted. |
| Reversibility | Soft-delete, transaction, snapshots, tested restore. |
| Incident response | Stop access, preserve logs, assess, restore safely, audit. |

<br><br><br>

## Your AI agent has many tools, but keeps picking the wrong one. How do you improve tool selection?

**Answer:**

### Diagnose selection errors

Measure tool choice separately from argument extraction and execution. Review representative traces to see whether tools overlap in purpose, descriptions are vague, tool lists are too large, a relevant tool is missing, or the task itself is ambiguous. Build a labeled evaluation set mapping requests to acceptable tools (including “no tool” or “ask user”).

### Improve tool discoverability and choice

- **Clarify tool boundaries:** Give each tool a distinct name, concise description, examples, preconditions, side effects, and “do not use when” guidance.
- **Reduce choice set:** Expose only tools relevant to the task, user permissions, and current workflow stage; group or retrieve tool definitions when the catalog is large.
- **Normalize overlap:** Merge redundant tools or make differences explicit (for example, search versus exact lookup; read versus write).
- **Use routing when appropriate:** A deterministic router or lightweight classifier can narrow candidate tools for stable workflows; preserve a safe “none/clarify” option.
- **Improve task context:** Include necessary constraints, available identifiers, and current state without flooding the prompt.
- **Validate before execution:** The host confirms tool availability and authorization; a model selection never grants permission.

### Evaluate changes

Measure tool-selection accuracy, false tool calls, missed required calls, argument validity, task success, latency, and cost. Test paraphrases, ambiguous requests, permission-restricted tools, and tasks requiring no tool. Do not optimize only top-1 tool accuracy if multiple tools are acceptable or if abstention is the correct choice.

### Concise interview answer

“I first separate tool-choice errors from parameter and execution errors, then inspect whether descriptions overlap, the catalog is too large, or required tools are missing. I make boundaries and side effects explicit, expose only relevant authorized tools, and use deterministic routing to narrow choices where stable. The system retains a no-tool/clarify path and validates availability and permission before execution. I measure missed and unnecessary calls, task success, cost, and latency on labeled, paraphrased, and adversarial requests.”

### Revision summary

| Root cause | Mitigation |
|---|---|
| Overlapping tools | Clarify boundaries or consolidate. |
| Too many choices | Contextual tool discovery or routing. |
| Vague descriptions | Add examples, preconditions, effects, exclusions. |
| Missing/no-tool path | Support clarify/answer directly/abstain options. |
| Wrong evaluation | Measure both false and missed calls plus end-task success. |

<br><br><br>

## Your AI agent takes too long to complete a task. How do you speed it up?

**Answer:**

### Profile the end-to-end task

First measure wall-clock time and break it down into queueing, model calls, tool calls, retries, human approvals, and waiting on external services. Track p50/p95/p99, step count, tool-call count, input/output tokens, and task success. A long total duration may be caused by sequential dependencies, slow APIs, repeated planning, oversized context, or deliberate approval—not simply a slow model.

### Optimize the actual bottleneck

1. **Remove unnecessary steps:** Simplify the workflow and stop once acceptance criteria are verified.
2. **Parallelize independent work:** Run separate reads/searches concurrently, but keep dependent actions sequential and respect rate limits.
3. **Reduce round trips:** Batch related reads or combine safe independent checks; avoid repeated model replanning when a deterministic step suffices.
4. **Route by complexity:** Use a faster/smaller model for routine steps and escalate only when quality requires it.
5. **Bound tool results and context:** Return relevant fields/snippets, avoid replaying full history, and compact state carefully.
6. **Use timeouts and efficient clients:** Set realistic per-tool deadlines, reuse connections, and avoid blocking on unneeded tools.
7. **Stream progress where useful:** Improve perceived latency while still validating completion and final output.

Do not parallelize side-effecting or dependent actions without appropriate ordering and idempotency. Do not speed up the system by dropping authorization or validation. Verify improvements against task success, safety, and cost.

### Concise interview answer

“I profile end-to-end p95 latency by model, tool, queue, retry, and approval time, and correlate it with step and token counts. I remove redundant steps, parallelize only independent reads, batch safe operations, route simple work to faster models, bound tool outputs and context, and add appropriate timeouts. Side effects remain ordered and idempotent. I compare latency gains against task success, safety, and cost so speed does not come from skipped checks.”

### Revision summary

| Bottleneck | Optimization |
|---|---|
| Too many agent turns | Clear stop criteria; remove redundant replanning. |
| Sequential independent calls | Bounded parallelism/batching. |
| Slow tool/API | Profile, timeout, efficient client, scoped query. |
| Large context | Relevant state and bounded tool results. |
| Safety checks | Keep mandatory; optimize their implementation, not remove them. |

<br><br><br>

## Your long-running agent drifts after hours and confidently works on the wrong thing. How do you diagnose and fix it?

**Answer:**

### Diagnose why the task drifted

Capture a trace across the full run: original goal and constraints, each plan revision, context summaries, tool calls/results, approvals, model/prompt versions, and state transitions. Look for context truncation or lossy compaction, stale or incorrect memory, an unverified assumption becoming a premise, repeated failures, an early goal misunderstanding, changed external state, or an interruption that resumed from incomplete state.

“Confidently” is not a reliability signal. Compare the agent’s current beliefs against the original request, source evidence, and verified task state.

### Stabilize long-running execution

1. **Keep a durable task specification:** Store the original goal, non-negotiable constraints, success criteria, and owner separately from conversational summaries.
2. **Use explicit checkpoints:** Persist completed steps and evidence; resume from verified state, not a model-generated narrative alone.
3. **Re-anchor periodically:** At checkpoints, compare the proposed next action and current plan against the original goal and acceptance criteria.
4. **Preserve provenance and uncertainty:** Distinguish user statements, tool observations, and model inference; never promote an assumption to fact without evidence.
5. **Compact with safeguards:** Keep key constraints and identifiers verbatim, retain links to original evidence, and validate summaries.
6. **Detect drift/no progress:** Check for repeated states, changing goals without authorization, unsupported claims, and action sequences unrelated to success criteria.
7. **Bound and escalate:** Set time/step budgets, require approval for scope changes, and ask the user when goals conflict or the environment changes materially.

Add regression tests that simulate long histories, compaction, restarts, changing tool results, and conflicting instructions. Measure goal adherence and action relevance throughout the trace, not just final completion.

### Concise interview answer

“I diagnose drift from a full trace of the original goal, plan revisions, context compaction, memory, tool observations, and state transitions. Common causes are lossy summaries, stale state, unverified assumptions, and resuming from incomplete checkpoints. I keep the goal and acceptance criteria in durable structured state, checkpoint verified evidence, re-anchor at milestones, preserve provenance, and detect no-progress or off-goal actions. Scope changes require user approval, and long runs have budgets and honest escalation paths.”

### Revision summary

| Drift source | Control |
|---|---|
| Lost original requirements | Durable task spec and periodic re-anchoring. |
| Bad compaction/memory | Validated summaries with provenance and source links. |
| Unverified assumptions | Separate observations from inference; require evidence. |
| Restart/partial failure | Checkpoint verified state and operation status. |
| Scope drift | Detect off-goal actions; ask approval for scope changes. |

<br><br><br>

## Your LLM selects the right tool but extracts the wrong parameters. How do you fix parameter extraction?

**Answer:**

### Diagnose the parameter error

Inspect the user request, tool schema shown to the model, model-generated arguments, and validated execution payload. Common causes include ambiguous field descriptions, missing units or formats, optional fields with unclear defaults, entity-resolution errors, context truncation, and a mismatch between what the user said and what the tool requires.

### Make extraction reliable

1. **Improve schema semantics:** Use explicit names and descriptions, types, enums, formats, units, ranges, and required/optional status. Define null, omission, and default behavior.
2. **Preserve source values:** Keep user-provided identifiers, dates, amounts, and names distinct from model-inferred values. Normalize through deterministic code where possible.
3. **Resolve ambiguity explicitly:** Ask a clarifying question for missing or ambiguous critical values rather than guessing.
4. **Validate server-side:** Check syntax and domain constraints, such as valid date ranges, known account IDs, currency, and user authorization.
5. **Use staged extraction for complex requests:** First extract fields into a schema, validate them, then call the tool; this can make errors easier to detect.
6. **Return actionable validation errors:** Tell the model which field failed and what formats are allowed, without exposing sensitive data; allow only bounded correction attempts.
7. **Add examples and tests:** Include realistic, boundary, multilingual, malformed, and ambiguous inputs; measure field-level precision/recall and downstream task success.

For high-impact calls, show a preview of the resolved values and require confirmation. Schema-constrained generation can reduce malformed arguments, but it does not ensure the values are factually correct or authorized.

### Concise interview answer

“I inspect the request-to-argument path and identify whether the issue is schema ambiguity, entity resolution, normalization, missing context, or validation. I make fields, formats, units, ranges, and defaults explicit; preserve user-provided values; and ask for clarification rather than guessing critical fields. The host validates syntax, business rules, and authorization before execution. For complex requests I use a staged extraction-and-validation step, bounded correction, and field-level evaluation on realistic edge cases.”

### Revision summary

| Error type | Remedy |
|---|---|
| Wrong format/type | Constrained schema and deterministic parsing. |
| Wrong entity/value | Explicit source mapping and entity resolution. |
| Missing/ambiguous value | Clarify; do not infer critical parameters. |
| Invalid but well-formed value | Business-rule and authorization validation. |
| Regressions | Field-level tests, preview, confirmation for high impact. |

<br><br><br>

## How do Computer-Use Agents work?

**Answer:**

### Definition and interaction loop

A **computer-use agent** operates a graphical user interface (GUI) by observing a screen or application state and issuing actions such as clicks, keystrokes, scrolling, or text entry. Depending on the implementation, it may use screenshots and coordinates, accessibility/UI trees, DOM-backed controls, or a combination. It is not necessarily a single standardized architecture.

Typical loop:

1. Receive a goal and observe the current UI state.
2. Identify relevant controls and determine the next action.
3. Propose a click, keypress, text entry, or navigation action.
4. Execute the action through a controlled computer-use runtime.
5. Observe the resulting screen/state and verify whether the intended transition occurred.
6. Continue, recover, ask for help, or stop when completion criteria are met.

### Strengths and challenges

Computer-use agents can interact with legacy or third-party applications that lack suitable APIs. GUI state is dynamic, however: controls move, pages load slowly, dialogs appear, and visual interpretation can be uncertain. Coordinate clicks can be brittle; accessibility/UI semantics may be more robust when available. Actions can also have real side effects.

### Safety and reliability

Use a dedicated, isolated session with least-privilege accounts and scoped data. Restrict allowed applications and actions, validate targets before clicking, and verify state after each consequential step. Require confirmation for payments, deletion, sending messages, permissions, or other high-impact operations. Use timeouts, action budgets, screenshots/state logs with privacy controls, and a safe stop/recovery path. Never treat a visual indication alone as authorization.

### Concise interview answer

“A computer-use agent observes a GUI, selects an action such as a click or keystroke, executes it through a controlled runtime, then observes the new state and verifies progress. It can automate applications without APIs but is vulnerable to dynamic layouts, perception errors, and unintended side effects. I prefer semantic accessibility controls where available, isolate the session, use least privilege, verify each important state transition, and require human confirmation for consequential actions.”

### Revision summary

| Step | Purpose |
|---|---|
| Observe | Screenshot, UI tree, or accessible controls. |
| Act | Bounded click, key, text, or navigation operation. |
| Verify | Confirm the UI reached the intended state. |
| Protect | Isolate, least privilege, confirmation, audit. |
| Recover | Timeouts, retries with checks, stop/escalation. |

<br><br><br>

## How do Browser Agents work?

**Answer:**

### Definition and typical workflow

A **browser agent** uses browser state and browser-facing tools to complete tasks such as finding information, filling forms, or navigating a web application. Implementations may interact through a DOM/accessibility tree, browser automation APIs, screenshots, or a combination.

1. Interpret the request and determine whether browsing is needed.
2. Navigate to approved sites and inspect page content or accessible elements.
3. Select links, enter bounded form data, or invoke approved browser actions.
4. Observe page changes and verify that the expected content/action occurred.
5. Cite or summarize retrieved sources, or stop for user confirmation before a consequential submission.

### Browser-specific risks

Web pages are untrusted: they may contain prompt injection, deceptive UI, malicious downloads, or content designed to induce data exfiltration. Pages can also change after observation, causing stale or misdirected actions. Browser cookies and logged-in sessions may expose sensitive accounts.

### Defensive design

Use isolated browser profiles, scoped credentials, domain allowlists where appropriate, download restrictions, and strong separation between page content and trusted instructions. Do not send secrets to pages based on model judgment. Validate the destination and form fields, restrict cross-origin access, and require confirmation before submitting purchases, messages, account changes, or uploads. Record actions safely and verify final state.

For information retrieval, retain URL, title, access time, and source excerpts. A page’s presence in the browser does not prove its claims are authoritative; compare sources and communicate uncertainty.

### Concise interview answer

“A browser agent observes web pages through a DOM, accessibility tree, automation API, or screenshot, then navigates or interacts and verifies each state change. It is useful for workflows without APIs, but web content and UI are untrusted and dynamic. I isolate browser sessions, scope credentials and domains, validate destinations and inputs, protect secrets from page instructions, and require confirmation for high-impact submissions. For research answers I preserve URLs and timestamps and assess source authority.”

### Revision summary

| Concern | Control |
|---|---|
| Page interaction | Observe → act → verify state. |
| Untrusted content | Treat page text as data; injection defenses in host. |
| Account exposure | Isolated profile and scoped credentials. |
| Side effects | Validate destination/payload; require confirmation. |
| Research | Preserve URL/time/provenance; assess source reliability. |

<br><br><br>

## How does LangChain work?

**Answer:**

### High-level description

**LangChain** is an open-source framework/ecosystem for building applications that use language models and related components. At a high level, it provides abstractions and integrations for model calls, prompt templates, structured outputs, tools, retrievers, document processing, and composing application steps. Exact APIs and package organization evolve, so an implementation answer should be tied to the framework version in use.

A common application flow is to prepare inputs, call a chat model, optionally invoke a tool or retriever, process the result, and return a response. These components can be composed into chains or runnable workflows. LangChain can also integrate with orchestration systems such as LangGraph for stateful, branching agent workflows.

### What it does not do automatically

Using a framework does not guarantee correct retrieval, secure tool execution, reliable state, or an accurate answer. The developer still designs data flow, validates tool arguments and outputs, enforces authorization, handles errors, and evaluates the complete application. Abstractions can speed development but may add dependency/version complexity or obscure underlying behavior if not instrumented.

### When it is useful

It can be useful when an application benefits from reusable model/retriever/tool integrations, standard composition patterns, and ecosystem connectors. For a small or latency-critical workflow, direct provider SDK calls and explicit application code may be simpler. Choose based on maintainability, observability, required integrations, and version stability.

### Concise interview answer

“LangChain is a framework for composing LLM applications from model, prompt, tool, retriever, and document-processing components. A typical flow prepares context, invokes a model, optionally calls a tool or retriever, and transforms the result. It can speed integration and composition, while stateful branching can be handled with an orchestration layer such as LangGraph. The framework does not supply correctness or security automatically; I still enforce permissions, validate outputs, handle failures, and evaluate behavior. I also pin and test the specific version because APIs evolve.”

### Revision summary

| Component family | Role |
|---|---|
| Models/prompts | Configure and invoke model behavior. |
| Tools/retrievers | Connect to actions and external knowledge. |
| Composition | Combine application steps into reusable flows. |
| Orchestration | Manage stateful branching where needed. |
| Developer responsibility | Security, correctness, evaluation, versioning. |

<br><br><br>

## How does LangGraph work?

**Answer:**

### High-level description

**LangGraph** is an orchestration framework for building stateful, graph-based LLM and agent workflows. A workflow is represented as nodes that perform operations and edges that determine transitions. Nodes may call a model, execute a tool, validate a result, or wait for human input. State is passed and updated as the graph runs; conditional edges can branch and cycles can support bounded iterative behavior.

### Typical execution model

1. Define a shared state schema for the workflow.
2. Implement nodes that read state and return controlled updates.
3. Connect nodes with fixed or conditional edges.
4. Compile/run the graph through the framework’s runtime.
5. Persist/checkpoint state if the configured deployment supports it, then resume or interrupt at defined points.
6. Add error handling, retries, human approval, and termination conditions explicitly.

The exact APIs, persistence features, and integrations vary by LangGraph version and deployment. Verify those details against the version being used rather than assuming every capability is available in every runtime.

### Why use graph orchestration?

An explicit graph can make branching, state transitions, retries, and human-in-the-loop steps easier to reason about than a free-form loop. It can also introduce framework concepts, state-schema maintenance, and operational complexity. A simple linear chain may not need a graph.

### Concise interview answer

“LangGraph models an agent workflow as nodes operating on shared state and edges that define fixed or conditional transitions. Nodes can call models, tools, validators, or approval steps; cycles allow controlled iteration. This makes branching and stateful orchestration explicit, and supported deployments can checkpoint or resume workflow state. I still define budgets, stop conditions, permissions, and error paths myself, and I verify persistence/API details for the framework version in use.”

### Revision summary

| Graph element | Function |
|---|---|
| State | Shared typed task context and progress. |
| Node | Model, tool, validation, or human step. |
| Edge | Transition, including conditional branching. |
| Cycle | Bounded retry/iteration with explicit stop rules. |
| Use decision | Helpful for stateful branching; unnecessary for simple linear flows. |

<br><br><br>

## What is OKF (Open Knowledge Format)?

**Answer:**

### Verify the intended reference first

The label **“OKF (Open Knowledge Format)”** is ambiguous without a source or specification. I cannot verify from the name alone that it refers to a particular standardized format, protocol, schema, or project, and should not invent its fields or claim interoperability. Before describing its exact capabilities, ask which specification, repository, or product the interviewer means.

### A careful way to answer the underlying design question

If the intent is to ask about a format for representing knowledge for AI systems, describe the requirements without attributing them to OKF:

- **Explicit schema:** Define entities, relations, content, metadata, and versioning.
- **Provenance:** Preserve source IDs, timestamps, authorship, and transformation history.
- **Interoperability:** Specify serialization, identifiers, compatibility, and extension rules.
- **Trust and access:** Represent trust/permissions as metadata, while enforcing authorization outside the format.
- **Validation:** Provide schemas, validators, and clear behavior for unknown fields or malformed records.
- **Evaluation:** Test whether the format can round-trip representative data and support the intended retrieval/use cases.

These are general requirements, not verified claims about a specific “OKF.”

### Concise interview answer

“I would first clarify the reference: ‘OKF’ and ‘Open Knowledge Format’ are not enough for me to identify a specific specification confidently, so I would not guess its schema or capabilities. If the question means a general AI knowledge-exchange format, I would evaluate its schema, provenance, versioning, interoperability, validation, and access-control integration. I would then verify those properties against the cited specification or repository.”

### Revision summary

| Question | Reliable response |
|---|---|
| Is OKF identifiable from this name alone? | Not confidently; request the specification/source. |
| What not to do | Invent fields, protocol behavior, or adoption claims. |
| General evaluation | Schema, provenance, versioning, interoperability, validation. |
| Security boundary | A data format does not itself enforce authorization. |

<br><br><br>
