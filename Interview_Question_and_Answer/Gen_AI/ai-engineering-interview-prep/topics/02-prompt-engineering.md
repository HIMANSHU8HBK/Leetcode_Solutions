# 02. Prompt Engineering

Source entries are in their original order. Use the space after each heading to draft an answer.

## What is prompt engineering, and why is it critical for AI applications?

**Answer:**

### Definition

**Prompt engineering** is the disciplined design and iteration of instructions, context, examples, and output constraints provided to a language model so it performs a task reliably. A prompt may include a system-level instruction, user request, retrieved evidence, conversation history, tool descriptions, examples, and a required response format.

It is not a way to change model weights. It shapes the model’s input at inference time and works within the model’s capabilities, context window, and instruction hierarchy.

### Why it matters

- **Clarifies the task:** States the goal, audience, constraints, and what to do when information is missing.
- **Improves consistency:** Examples, schemas, and explicit decision rules reduce ambiguity across similar requests.
- **Grounds responses:** Relevant retrieved context and instructions can steer answers toward supplied evidence.
- **Enables integration:** Output schemas and tool instructions help connect model responses to application workflows.
- **Affects cost and latency:** Input length, repeated context, and number of model calls affect runtime.
- **Makes behavior testable:** Versioned prompts can be evaluated against a stable set of representative cases.

Prompting alone cannot make an unreliable model fully deterministic, guarantee truth, enforce authorization, or safely execute actions. Important constraints must be implemented and validated in application code.

### A practical prompt structure

1. **Task:** One clear objective.
2. **Context:** Relevant, bounded facts or source material.
3. **Rules:** Constraints, priorities, and handling of uncertainty.
4. **Examples:** Representative demonstrations, including edge cases when useful.
5. **Output contract:** A schema or explicit format.
6. **Validation path:** Specify when to ask a clarifying question, abstain, or return an error state.

### Production practices

Treat prompts as versioned application artifacts. Evaluate changes on representative and adversarial examples; monitor task quality, refusal/abstention, cost, latency, and format validity. Avoid putting secrets in prompts, and do not rely on an instruction such as “never reveal this” to protect data or enforce access control.

### Concise interview answer

“Prompt engineering is the systematic design of the instructions, context, examples, and output constraints given to a model at inference time. It matters because model behavior is sensitive to task ambiguity and context, and a well-designed prompt can improve consistency, grounding, formatting, and tool use. In production I version prompts, test them on representative and edge cases, and monitor quality, latency, and cost. Prompting is not a security boundary or truth guarantee, so authorization, validation, and action controls belong in application code.”

### Revision summary

| Prompt element | Purpose |
|---|---|
| Task and constraints | Reduce ambiguity. |
| Context and examples | Ground behavior and demonstrate expectations. |
| Output contract | Make responses easier to validate and consume. |
| Versioned evaluation | Detect regressions and prompt sensitivity. |
| Application controls | Enforce security, truth checks, and permissions beyond prompting. |

<br><br><br>

## Explain zero-shot, one-shot, and few-shot prompting with examples.

**Answer:**

### Definitions

These terms describe how many task demonstrations are included in the prompt:

- **Zero-shot:** Give the task instruction without a worked example.
- **One-shot:** Include one input-output example.
- **Few-shot:** Include a small set of examples to demonstrate the task and desired format.

The model uses examples through **in-context learning**: they condition its response for that request, but do not update model parameters.

### Example: support-ticket classification

**Zero-shot**

```text
Classify the message as Billing, Technical, or Account.
Return only the label.
Message: “I was charged twice for this month.”
```

**One-shot**

```text
Classify the message as Billing, Technical, or Account.
Example: “I cannot reset my password.” -> Account
Message: “I was charged twice for this month.”
Return only the label.
```

**Few-shot**

```text
Classify the message as Billing, Technical, or Account.
“I cannot reset my password.” -> Account
“The app crashes when I upload a file.” -> Technical
“I was charged twice for this month.” -> Billing
Message: “My invoice shows an unfamiliar fee.”
Return only the label.
```

### Choosing an approach

| Strategy | Advantages | Costs and risks |
|---|---|---|
| Zero-shot | Short, low-latency prompt; useful when instructions are clear and task is familiar. | More ambiguity; output behavior may vary. |
| One-shot | Demonstrates a concrete interpretation with modest token cost. | A single example may be atypical or bias the result. |
| Few-shot | Can convey label boundaries, style, and edge cases. | Increases input tokens and latency; example choice/order can skew outputs. |

Use zero-shot first as a baseline. Add carefully selected examples when they measurably improve held-out performance, and test alternative example sets and order. For classification, consider a fixed label set, schema validation, and calibration rather than relying on prose alone.

### Concise interview answer

“Zero-shot prompting gives instructions without demonstrations, one-shot includes one example, and few-shot includes several. The examples provide in-context demonstrations without changing model weights. I start with zero-shot for clear, simple tasks and add representative few-shot examples when they improve evaluated accuracy or consistency. Examples need to cover decision boundaries and be checked for bias and order effects; they also consume context, latency, and cost.”

### Revision summary

| Type | Demonstrations | Use |
|---|---:|---|
| Zero-shot | 0 | Clear tasks; lowest prompt overhead. |
| One-shot | 1 | Show one representative interpretation. |
| Few-shot | A few | Convey format, style, and category boundaries. |
| Key caveat | N/A | Demonstrations condition this request; they do not train the model. |

<br><br><br>

## What is chain-of-thought (CoT) prompting, and when should you use it?

**Answer:**

### Definition

**Chain-of-thought (CoT) prompting** encourages a model to handle a problem through intermediate reasoning steps rather than jumping directly to a final answer. A prompt may request a stepwise solution, provide worked reasoning examples, or ask the model to decompose a problem into subtasks.

For example, for “A team has 24 items and packs them into boxes of 6; how many boxes are needed?”, a model can identify the total, divide by the items per box, and return 4. In a user-facing application, it may be better to expose a concise explanation or verifiable calculation rather than unfiltered private reasoning.

### When it can help

- Multi-step arithmetic or symbolic problems.
- Tasks that benefit from explicit decomposition or intermediate checks.
- Problems where a supplied worked example teaches a useful solution pattern.
- Workflows where intermediate results can be independently validated.

### Limits and safe use

Asking for more reasoning text does **not** guarantee correct reasoning. A plausible explanation can be post-hoc or contain errors. CoT can increase output tokens and latency, expose sensitive or inappropriate internal text, and sometimes distract the model or encourage overconfident speculation.

Prefer task-appropriate, verifiable intermediate representations: equations, code, citations, structured subtask results, or concise rationales. For consequential results, check the answer with tools or deterministic logic. Do not treat a model-generated explanation as proof that its conclusion is correct.

Also distinguish a request for a user-facing explanation from access to the model’s hidden internal reasoning. A system can provide a brief rationale, evidence, and checks without exposing private chain-of-thought.

### Concise interview answer

“Chain-of-thought prompting encourages stepwise decomposition or provides worked reasoning demonstrations for tasks such as multi-step math or logic. It can improve performance when the model benefits from explicit intermediate structure, but it does not guarantee correctness; fluent reasoning can still be wrong. It also adds tokens and may expose reasoning text that should not be shown. I use it only when evaluations demonstrate benefit, prefer concise and verifiable intermediate outputs, and validate important answers with tools or deterministic checks.”

### Revision summary

| Question | Remember |
|---|---|
| What is CoT? | Prompting for or demonstrating intermediate steps. |
| When useful? | Multi-step tasks with a verifiable process. |
| Does it guarantee truth? | No; explanations can be plausible but incorrect. |
| Production practice | Measure benefit, manage output cost, verify results. |
| User-facing output | Provide concise rationale/evidence without assuming hidden reasoning should be exposed. |

<br><br><br>

## Explain self-consistency prompting and how it improves reasoning.

**Answer:**

### Core idea

**Self-consistency prompting** samples multiple reasoning attempts for the same problem, then aggregates their final answers—often by majority vote or another task-specific consensus rule. The intuition is that correct solutions may arrive by different reasoning paths, while some errors are less likely to recur consistently.

For a multiple-choice problem, for example, the system could sample several independent responses and select the most common option, optionally weighting responses only if a validated scoring method supports it.

### Why it may help

If a model has multiple plausible solution paths and incorrect answers vary across samples, aggregation can reduce sampling variance and improve the chance that the most frequent answer is correct. It is most useful when:

- the task has a clear, comparable final answer;
- independent samples have meaningful diversity;
- the answer can be checked or scored reliably; and
- the accuracy gain is worth the added compute.

### Important limitations

- **Correlated errors:** Samples from the same model can share the same misconception, so majority vote is not independent evidence.
- **Noisy aggregation:** Free-form answers must be normalized carefully; equivalent answers may differ in wording.
- **Confidence is not truth:** Agreement may reflect a systematic error or shared bias.
- **Cost and latency:** Multiple generations multiply inference work, even if sampling is parallelized.
- **Long-form tasks:** Voting over entire prose responses is often ill-defined; aggregate structured decisions or independently verifiable components instead.

Self-consistency can use sampled reasoning internally, but the application need not reveal full reasoning traces. It should return a concise answer with appropriate evidence or uncertainty.

### Production design

Set a bounded sample count, use a well-defined answer representation, normalize equivalent outputs, and compare the consensus against a single-sample baseline on held-out data. Where possible, validate with an external checker—such as unit tests, a calculator, or a rules engine. Escalate low-agreement or uncheckable cases rather than presenting consensus as certainty.

### Concise interview answer

“Self-consistency samples multiple solutions to the same prompt and aggregates their final answers, commonly with a majority vote. It can improve reasoning accuracy when plausible solution paths are diverse and errors do not all correlate. It does not create independent evidence: one model can repeat the same systematic mistake, and agreement is not a truth guarantee. The method raises token cost and latency, so I use structured outputs, normalize answers, cap sampling, evaluate against a single-sample baseline, and verify or abstain on low-consensus cases.”

### Revision summary

| Step | Purpose |
|---|---|
| Sample multiple attempts | Explore varied candidate solutions. |
| Normalize answers | Make equivalent outputs comparable. |
| Aggregate | Vote or apply a task-specific consensus rule. |
| Validate | Check externally when possible; agreement is not proof. |
| Trade-off | Potential accuracy gain versus inference cost and correlated errors. |

<br><br><br>

## What is tree-of-thought prompting?

**Answer:**

### Definition

**Tree-of-thought (ToT) prompting** generalizes stepwise reasoning by exploring multiple candidate intermediate thoughts or partial solutions as branches in a search tree. A controller generates candidate continuations, evaluates them, and decides which branches to expand, keep, backtrack from, or stop.

Instead of committing to one linear chain, the system can consider alternatives. In a planning puzzle, it might enumerate candidate moves, reject states that violate constraints, and explore promising paths until it finds or fails to find a solution.

### Typical procedure

1. Define a state representation and a goal or success condition.
2. Generate several candidate next steps from the current state.
3. Score candidates using a model, a heuristic, or an external verifier.
4. Expand the most promising candidates using breadth-first search, beam search, or another strategy.
5. Stop when a verified goal is reached or a search budget is exhausted.

### When to use it

ToT can help on tasks with branching decisions, planning, puzzles, or search spaces where backtracking is valuable. It is often unnecessary for simple questions that a direct answer or a single reasoning pass handles.

### Limitations and safeguards

Search can grow exponentially. Bound branching factor, depth, model calls, tokens, and wall-clock time; define a fallback when no candidate passes verification. A model-generated score may not rank branches reliably, so use deterministic constraints or domain-specific validators when possible. Treat “thought” nodes as candidate text or states, not guaranteed-valid reasoning, and do not assume search finds a global optimum.

Compared with self-consistency, self-consistency usually samples complete attempts and votes on answers; ToT explicitly searches and evaluates intermediate branches. Both cost more than a single pass and may share model biases.

### Concise interview answer

“Tree-of-thought prompting explores multiple intermediate candidate paths rather than following one chain. A controller generates branches, evaluates them, and expands or backtracks using a search strategy such as beam or breadth-first search, ideally with an external verifier. It suits branching planning and puzzle tasks but can become expensive quickly and depends on the quality of its evaluator. I bound depth, branching, calls, and time, and use deterministic checks where possible; for a simple task, a direct prompt is usually better.”

### Revision summary

| Concept | Remember |
|---|---|
| Structure | Search tree of candidate intermediate states/steps. |
| Controller | Generate, score, expand, prune, or backtrack. |
| Suitable tasks | Problems with meaningful branching and verification. |
| Difference from self-consistency | Explores intermediate branches versus sampling complete attempts and voting. |
| Risks | Search explosion and unreliable model-based evaluation. |

<br><br><br>

## What is ReAct (Reasoning + Acting) prompting, and how does it work?

**Answer:**

### Core idea

**ReAct** (Reasoning + Acting) is a prompting and agent pattern that interleaves a model’s task reasoning with actions taken through tools or an environment. Rather than producing a final answer in one pass, the model decides what information or operation is needed, requests an action, receives an observation, and then continues until it can answer or must stop.

A typical conceptual loop is:

1. **Reason:** Determine the next subgoal or missing information.
2. **Act:** Request a tool call, such as a search, calculator, database lookup, or API operation.
3. **Observe:** Receive the tool’s result from the application.
4. Repeat within bounded limits, then return a response.

For example, to answer “What is the current exchange rate and the value of 100 euros in dollars?”, the model could call an approved rate API, receive a result with its timestamp, calculate the converted value, and report both with appropriate caveats.

### Why interleave reasoning and actions?

Tool results can provide current or exact information that the model cannot reliably infer from its training data. Interleaving lets it adapt later actions to earlier observations. It is particularly useful for tasks needing retrieval, arithmetic, or interaction with a controlled environment.

### Production design and safeguards

The model should request actions through a typed tool interface; the application—not the model—validates arguments, authorizes access, executes the tool, and returns a bounded result. Use least privilege, input validation, timeouts, call limits, audit logs, and confirmation for consequential or irreversible actions. Treat retrieved content as untrusted data and never let it redefine system policy or permissions. Do not execute arbitrary model-generated code or shell commands in a privileged environment.

ReAct-style traces can be verbose and expensive, tool calls can fail, and the model can choose the wrong action or misread an observation. Track task success, tool-call correctness, latency, cost, and safety; provide explicit stopping and error paths.

### Concise interview answer

“ReAct interleaves reasoning about the next step with tool actions and observations: the model identifies what it needs, requests a tool call, reads the result, and continues until it can respond. This grounds tasks in search, APIs, or computation instead of relying only on model memory. In production, tools are exposed through typed, least-privilege interfaces; the application validates and authorizes every call, bounds retries and cost, logs actions, and requires confirmation for consequential operations. Tool outputs are untrusted, and a prompt alone is not a security boundary.”

### Revision summary

| Loop component | Role |
|---|---|
| Reason | Select a subgoal or tool. |
| Act | Request a bounded tool action. |
| Observe | Incorporate the tool’s result. |
| Guardrails | Application validates, authorizes, limits, and audits actions. |
| Failure handling | Timeouts, tool errors, stopping limits, and user escalation. |

<br><br><br>

## What is a system prompt, and how does it influence model behavior?

**Answer:**

### Definition and influence

A **system prompt** is a high-priority instruction message supplied by the application to establish the model’s general behavior for a conversation or request. It can define the assistant’s task, tone, scope, constraints, available tools, and how to handle uncertainty. The exact role hierarchy and precedence are provider/API-specific.

For example, a system instruction might say: “Answer questions about the supplied product documentation. If the documentation does not contain the answer, say so. Return a concise response.” A developer or user message and retrieved context may supply more specific task details, depending on the platform’s message format.

### What it can and cannot do

System prompts can steer the model but do not modify its weights, guarantee obedience, make claims true, or enforce permissions. A model may still produce an undesired response, and prompt content can be exposed through logs, debugging, or model outputs. Never put credentials, private keys, or sensitive business secrets in a prompt and assume the model will keep them confidential.

### Production practices

- Keep instructions concise, prioritized, versioned, and reviewed.
- Separate trusted instructions from user content and retrieved documents in message structure where supported.
- State explicit uncertainty, refusal, and output-format behavior.
- Keep authorization, data access, and policy enforcement in application code.
- Minimize sensitive context; redact data and protect prompt logs.
- Test against prompt injection, conflicting instructions, and provider/model changes.

### Concise interview answer

“A system prompt is an application-provided high-priority instruction that establishes the model’s role, task boundaries, tone, and output behavior. It can improve consistency but does not change model parameters or guarantee compliance. Its hierarchy is API-specific, and users or retrieved documents can still create conflicting content. I keep system instructions versioned and minimal, test them on adversarial and regression cases, avoid secrets in prompts, and enforce authorization and data access outside the model.”

### Revision summary

| Aspect | Remember |
|---|---|
| Purpose | Set application-level behavior and constraints. |
| Mechanism | Inference-time instruction, not weight update. |
| Limits | Not guaranteed, not a permission system, not a secret store. |
| Engineering | Version, test, minimize sensitive content, enforce controls in code. |

<br><br><br>

## How do you structure prompts for consistent structured output (JSON, XML)?

**Answer:**

### Use an output contract

For consistent **JSON or XML**, define a precise contract rather than merely asking for “valid JSON.” Specify:

- required fields and their types;
- allowed enum values and whether fields may be null or omitted;
- array/object shape and any length constraints;
- how to represent missing, unknown, or invalid information;
- whether extra fields or prose are forbidden.

For example:

```text
Return one JSON object with exactly these keys:
{"category": "billing|technical|account", "priority": "low|normal|high", "summary": "string"}
Use only the listed enum values. If the category cannot be determined, use null.
Return no Markdown fences or surrounding prose.
```

In production, prefer provider-supported constrained decoding, function/tool calling, or schema modes when available. They can reduce formatting errors, but the result still needs validation.

### Validate and recover safely

Parse the response with a strict JSON/XML parser, validate it against a schema, and reject unexpected fields or invalid types. On a recoverable formatting failure, use a bounded retry with a clear validation error or a safe fallback; do not silently coerce arbitrary malformed content into a success. Keep the original response for diagnostics under appropriate privacy controls.

For XML, use a real parser and disable unsafe external entity resolution where the parser supports it. Treat parsed strings as data, not executable instructions or trusted commands.

### Common pitfalls

- Ambiguous field semantics, especially around absent versus null values.
- Asking for a schema but accepting unvalidated prose.
- Fragile regular expressions instead of a parser.
- Ignoring truncation, incomplete output, or model refusal.
- Assuming valid syntax means semantically correct or authorized output.

### Concise interview answer

“I define an explicit schema with required fields, types, enums, and missing-value behavior, and use constrained decoding or structured tool output when the API supports it. I still parse and validate every response in application code, handle refusal, truncation, and schema errors explicitly, and use only bounded retries. Syntactic validity does not establish semantic correctness or authorization, so business rules and permissions are checked separately.”

### Revision summary

| Step | Purpose |
|---|---|
| Specify schema | Make fields and constraints unambiguous. |
| Constrain generation | Use native structured-output features where available. |
| Parse | Use a real JSON/XML parser. |
| Validate | Enforce types, enums, required fields, and business rules. |
| Handle errors | Explicitly manage refusal, truncation, and invalid output. |

<br><br><br>

## What is prompt injection, and how do you defend against it?

**Answer:**

### Definition

**Prompt injection** is an attack in which untrusted text—such as a user message, retrieved document, web page, email, or tool result—contains instructions that try to override the application’s intended behavior. It exploits the fact that language models process instructions and data as natural-language context and may fail to reliably distinguish the two.

For example, a retrieved page might contain text directing the model to ignore prior instructions and disclose data. Treating the page as untrusted input is essential; placing it between delimiters or telling the model to ignore instructions inside it can help communicate intent but is not sufficient protection.

### Defensive design: contain, don’t just prompt

1. **Minimize authority:** Give the model only the tools and data needed for the task.
2. **Enforce permissions in code:** Authorize every data read and action using the authenticated user and application policy, not model judgment.
3. **Separate instructions and data:** Use structured message roles and explicit data boundaries where supported; label external content as untrusted.
4. **Constrain actions:** Use typed, validated tool inputs; allowlists; scoped credentials; rate limits; and confirmation for sensitive operations.
5. **Protect secrets:** Do not rely on hidden prompts to protect credentials or confidential business logic. Keep secrets in secure services and return only authorized results.
6. **Limit output channels:** Avoid exposing raw internal context or tool results unnecessarily; redact sensitive data.
7. **Test and monitor:** Red-team realistic direct and indirect injection cases, log decisions safely, and investigate policy violations.

### Important distinction

Prompt injection is not solved by adding a stronger “ignore all malicious instructions” sentence. Prompt instructions are one layer of defense; robust security comes from least privilege, data isolation, authorization checks, and safe tool execution even when the model is manipulated.

### Concise interview answer

“Prompt injection is untrusted content attempting to manipulate a model into disregarding the application’s intended instructions, often to expose data or misuse tools. Delimiters and explicit ‘treat this as data’ instructions help but cannot guarantee resistance. I design for containment: least-privilege tools, server-side authorization on every action, scoped data access, typed validation, secret isolation, confirmation for sensitive operations, and adversarial testing. The system should remain safe even if the model follows the injected text.”

### Revision summary

| Layer | Defense |
|---|---|
| Model context | Separate trusted instructions from clearly labeled untrusted content. |
| Tools | Least privilege, allowlists, typed inputs, bounded execution. |
| Data | Server-side authorization, scoped retrieval, secret isolation. |
| Sensitive actions | Confirmation and policy checks outside the model. |
| Validation | Test direct/indirect injection; do not rely on prompt wording alone. |

<br><br><br>

## What is jailbreaking in LLMs, and what are common jailbreak techniques?

**Answer:**

### Definition

**Jailbreaking** is an attempt to induce a model to bypass or ignore its intended safety constraints and produce disallowed or otherwise restricted output. It is often performed through adversarial phrasing, role-play, conflicting instructions, obfuscation, or multi-turn manipulation. These examples describe broad categories; the central defensive concern is behavior that violates policy, not any one prompt string.

Jailbreaking overlaps with prompt injection, but the terms are not identical: prompt injection often concerns malicious instructions in untrusted context or tool-connected workflows, while jailbreaking commonly refers to eliciting behavior that bypasses model safety restrictions.

### High-level technique categories

- **Instruction conflict or authority spoofing:** Claims that previous rules are invalid or that the user has higher authority.
- **Role-play or hypothetical framing:** Recasts a request as fiction, simulation, or an alternate persona.
- **Obfuscation and encoding:** Hides intent through altered spelling, formatting, or transformations.
- **Multi-turn escalation:** Establishes a benign premise, then shifts toward a restricted request.
- **Context contamination:** Embeds override instructions in documents or tool-returned content.

These are broad testing categories, not a guarantee that a given technique works against any particular model.

### Defenses and evaluation

Use layered safety controls: clear policy instructions, model-level safety training, input and output checks appropriate to the application, least-privilege tools, server-side authorization, and human review for high-impact decisions. Treat user and retrieved content as untrusted; avoid exposing sensitive context; and make tool execution safe even if a model response is manipulated.

Evaluate with representative adversarial test suites, measure both unsafe compliance and over-refusal, and retest after model, prompt, or tool changes. Avoid overfitting to a static list of jailbreak strings because attackers can paraphrase and combine techniques. For sensitive domains, route to approved workflows rather than relying solely on a model refusal.

### Concise interview answer

“Jailbreaking is an attempt to bypass a model’s intended safety behavior, often through instruction conflicts, role-play, obfuscation, multi-turn escalation, or injected context. It overlaps with prompt injection, but injection often targets the behavior of a tool-connected application. I defend in depth: model safety, policy-aware input/output controls, least-privilege tools, server-side authorization, and safe handling of untrusted content. I evaluate both unsafe compliance and over-refusal on evolving adversarial tests; no prompt or filter alone guarantees resistance.”

### Revision summary

| Point | Remember |
|---|---|
| Goal of attack | Bypass intended model safety constraints. |
| Common categories | Conflict, role-play, obfuscation, escalation, injected context. |
| Difference | Jailbreak targets model behavior; prompt injection often exploits untrusted context/tool workflows. |
| Defense | Layered controls; safe system behavior even if model is manipulated. |
| Evaluation | Test unsafe compliance and over-refusal; retest changes. |

<br><br><br>

## How do you optimize prompts for cost and latency?

**Answer:**

### Measure before shortening

Start by instrumenting representative requests: input and output tokens, model and settings, time to first token, total latency, retries, tool calls, cost, and task-quality metrics. Optimize against a defined quality floor; a shorter prompt is not an improvement if it reduces correctness, safety, or format validity.

### Practical optimization levers

- **Remove redundancy:** Replace repeated prose with concise, unambiguous rules; keep necessary constraints.
- **Limit context:** Retrieve or include only relevant evidence; deduplicate history and documents.
- **Use compact examples:** Keep few-shot demonstrations only if they measurably improve held-out results.
- **Bound output:** Request the smallest useful format and set an appropriate output-token limit.
- **Route by task:** Use a faster or smaller model for straightforward work and escalate uncertain or complex cases.
- **Cache safely:** Cache deterministic or reusable results where freshness, privacy, tenant isolation, and invalidation are handled correctly.
- **Reduce round trips:** Combine steps when safe, parallelize independent calls, and avoid unnecessary chain-of-thought or tool calls.
- **Use provider features:** Where supported, consider prompt caching, batching, streaming, or structured decoding; verify actual billing and latency behavior.

### Trade-offs and rollout

Input-token reduction often lowers prefill work; output-token reduction often lowers both generation time and cost. But compression can drop a critical instruction or evidence. Model routing and parallelism can improve p95 latency but add complexity or increase total spend. Establish a baseline, change one factor at a time, run quality and adversarial regression tests, then roll out gradually with monitoring and rollback.

### Concise interview answer

“I first measure token counts, latency percentiles, retries, tool calls, cost, and task quality. I then remove redundant instructions, trim history with a relevant retrieval or summarization strategy, retain only useful few-shot examples, cap outputs, route simple tasks to smaller models, cache safely, and reduce unnecessary round trips. I test each change against a quality and safety floor because a shorter prompt can remove important context. I roll out changes gradually and monitor both quality and p95 latency/cost.”

### Revision summary

| Lever | Main benefit | Guardrail |
|---|---|---|
| Trim prompt/context | Fewer input tokens and less prefill work. | Preserve task-critical instructions/evidence. |
| Bound output | Lower generation cost and latency. | Keep response useful and complete. |
| Model routing/caching | Reduce average work. | Protect quality, freshness, privacy, and tenant isolation. |
| Reduce calls | Lower round-trip latency. | Preserve independent validation and safe sequencing. |
| Measurement | Shows real impact. | Track quality alongside cost and latency. |

<br><br><br>

## What is the difference between prompt engineering and prompt tuning?

**Answer:**

### The distinction

**Prompt engineering** changes the human-readable input at inference time: instructions, context, examples, formatting rules, and message structure. It generally requires no training and can be iterated quickly.

**Prompt tuning** is a parameter-efficient training technique. It learns a small set of continuous prompt embeddings—often called soft prompts or virtual tokens—that are prepended or otherwise supplied to a mostly frozen model. These learned embeddings need not correspond to readable words. Terminology varies: “prefix tuning” and related parameter-efficient methods have specific variants and should not be treated as exact synonyms in every paper or library.

### Comparison

| Dimension | Prompt engineering | Prompt tuning |
|---|---|---|
| What changes | Text instructions/examples/context. | Learned continuous prompt parameters. |
| Training required | No. | Yes, using task data and an optimization process. |
| Interpretability | Usually human-readable. | Learned vectors are generally not directly interpretable. |
| Deployment | Prompt text can be versioned in the application. | Requires compatible model/runtime and versioned learned parameters. |
| Best fit | Fast task iteration, per-request context, low-data setup. | Repeated task specialization where training data and infrastructure exist. |
| Limitation | Sensitive to wording/model behavior; does not add model capability guarantees. | Depends on training data and can be less flexible across tasks or model versions. |

Prompt tuning usually updates far fewer parameters than full fine-tuning, but it is still training. It is not the same as adding a few natural-language examples to a prompt.

### Choosing between them

Start with prompt engineering because it is low-cost and easy to debug. Consider prompt tuning if repeated evaluations show a stable task gap, representative labeled examples are available, and serving can manage a learned prompt artifact. Compare it with retrieval, fine-tuning, or other adaptation methods on held-out data, including regression and robustness tests.

### Concise interview answer

“Prompt engineering edits readable instructions, examples, and context at inference time without training. Prompt tuning learns a small set of continuous virtual-token embeddings for a mostly frozen model, so it requires task data and an optimization step. Prompt engineering is easier to inspect and iterate; prompt tuning can specialize a model with fewer trainable parameters than full fine-tuning but adds training and deployment artifacts. I start with prompt engineering and adopt tuning only when offline evaluation shows a stable gain.”

### Revision summary

| Question | Prompt engineering | Prompt tuning |
|---|---|---|
| Updated artifact | Text prompt/context. | Learned embedding parameters. |
| Training | Not required. | Required. |
| Readability | Human-readable. | Usually not directly interpretable. |
| Useful when | Fast iteration and changing context. | Stable task specialization with data. |
| Key distinction | Examples are text; soft prompts are learned parameters. |

<br><br><br>

## What is a prompt template, and how do you design one for production use?

**Answer:**

### Definition

A **prompt template** is a reusable prompt structure with named variables filled at runtime, such as a task instruction, locale, retrieved context, or user question. Templates help keep requests consistent and make prompt versions testable, but they do not themselves guarantee consistent model output.

### Production design

1. **Define the contract:** Specify purpose, intended inputs, response schema, and behavior for missing or invalid values.
2. **Use typed, explicit variables:** Name placeholders clearly and document whether each value is trusted, user-supplied, or retrieved.
3. **Separate instructions from data:** Use structured message roles and safe serialization or delimiters supported by the model API. Do not concatenate untrusted input into trusted instruction text.
4. **Validate inputs:** Enforce type, size, encoding, and allowed-value constraints before rendering.
5. **Protect secrets and access:** Keep credentials and authorization logic out of prompts; fetch only data the user is permitted to see.
6. **Version and test:** Store prompt versions with the code/configuration, maintain regression cases, and test missing fields, long inputs, injection attempts, and model changes.
7. **Observe safely:** Log prompt version and operational metadata; avoid retaining unnecessary personal or sensitive content.

Example:

```text
System: You answer questions using the supplied support documentation.
If the documentation does not support an answer, say that the information is unavailable.

User question:
{{question}}

Untrusted documentation excerpts:
{{retrieved_context}}

Return the response using the configured answer schema.
```

The “untrusted” label and separation aid clarity but are not security controls. The application must enforce document access, output validation, and tool permissions.

### Common mistakes

Unescaped delimiter collisions, unbounded context, ambiguous placeholders, hidden defaults, mixing tenant data, and editing a production template without regression tests can cause serious failures. Ensure rendering is deterministic and test exactly what the model receives.

### Concise interview answer

“A prompt template is a versioned structure with named runtime variables. For production I define the task and output contract, type and validate inputs, separate trusted instructions from user or retrieved data, bound context size, and test missing values and adversarial content. I keep secrets and authorization outside the template, record a prompt version for observability, and run regression tests before rollout. Delimiters help communicate boundaries but do not replace application security.”

### Revision summary

| Design area | Practice |
|---|---|
| Variables | Named, typed, validated, size-bounded. |
| Trust boundaries | Separate instructions from untrusted input and retrieved text. |
| Security | Enforce data access and permissions in application code. |
| Lifecycle | Version, test, monitor, and roll back templates. |
| Reliability | Define missing-value and output-schema behavior. |

<br><br><br>

## How do you handle multi-turn conversations with LLMs?

**Answer:**

### Manage explicit conversation state

Most LLM APIs are stateless between calls unless the provider explicitly offers a stateful conversation feature. A typical application sends the relevant sequence of role-tagged messages on each request. The application should therefore own conversation state and decide what to retain, summarize, or discard.

### A robust approach

1. Store messages with conversation and user/tenant identifiers, timestamps, and appropriate retention controls.
2. Preserve the system/developer instructions separately from user content and tool observations.
3. Include only relevant recent history; enforce token budgets and avoid unbounded transcript growth.
4. Summarize older turns when useful, retaining key entities, decisions, constraints, and unresolved questions with provenance where possible.
5. Retrieve durable facts from an authorized memory store only when needed; provide correction and deletion mechanisms.
6. Treat each user turn and tool result as untrusted input; do not allow prior text to grant new privileges.
7. Handle truncation, model refusal, interrupted tool calls, and retries with explicit state transitions and idempotency where appropriate.

### Memory is not authority

Conversation history helps preserve context, but it may contain stale, incorrect, or sensitive claims. Summaries can lose qualifiers or introduce errors. Validate consequential facts against authoritative sources and re-check permissions on each request. Do not use prior assistant text as authorization evidence.

### Evaluation and operations

Test long conversations, topic changes, conflicting instructions, corrections, user separation, and history truncation. Track answer relevance, memory retrieval precision, context-token use, latency, and privacy incidents. Provide controls for data retention and user deletion consistent with the product’s requirements.

### Concise interview answer

“I treat multi-turn state as an application responsibility unless using a provider’s explicit stateful feature. I retain role-tagged history with tenant isolation and retention controls, send only relevant context under a token budget, and summarize older turns carefully. Durable memory is retrieved with authorization and can be corrected or deleted. I treat conversation and tool content as untrusted, re-check permissions every turn, and test long-history, topic-switch, correction, truncation, and privacy behavior.”

### Revision summary

| State item | Handling |
|---|---|
| Recent turns | Include selectively within context budget. |
| Older history | Summarize with care; retain provenance and uncertainty. |
| Durable memory | Store/retrieve with authorization, retention, correction, deletion. |
| Tool outputs | Treat as untrusted observations, not instructions. |
| Reliability | Test topic switches, truncation, retries, and tenant isolation. |

<br><br><br>

## What is role prompting, and when is it effective?

**Answer:**

### Definition and examples

**Role prompting** frames the model as a particular role or expertise, such as “Act as a technical editor” or “You are a customer-support assistant.” It can help establish tone, audience, vocabulary, and a useful response perspective when combined with a concrete task.

For example:

```text
You are a technical editor for API documentation.
Rewrite the supplied paragraph for a developer audience.
Preserve all technical claims; flag any claim that is unclear instead of inventing details.
```

The task and constraints do most of the operational work; a role label alone is usually underspecified.

### When it is effective

Role prompting can be useful to:

- align level of detail and terminology with an audience;
- set a consistent communication style;
- focus a broad task on a relevant analytical perspective; and
- improve consistency across a product’s interaction style.

### Limitations

A role label does not grant real credentials, create missing expertise, guarantee factual accuracy, or authorize access. “Act as a doctor” does not make a model a clinician. It can also bias the model toward confident-sounding responses. Give explicit task criteria, require uncertainty when evidence is lacking, and validate high-stakes claims with trusted sources or professionals.

Role prompting is also not a security mechanism: do not use it as an authorization check or as a substitute for tool restrictions.

### Concise interview answer

“Role prompting assigns a communication or analytical perspective—for example, a technical editor for a developer audience. It can help calibrate tone, terminology, and level of detail, but a role alone is not a precise task specification and does not create expertise, truth, or permissions. I pair it with clear instructions, evidence and output constraints, evaluate the effect on representative cases, and use external validation for consequential decisions.”

### Revision summary

| Role prompt can influence | Role prompt cannot guarantee |
|---|---|
| Tone, audience, framing, vocabulary. | Factuality, credentials, or domain competence. |
| Consistency of style. | Authorization or tool access. |
| Task perspective when paired with instructions. | Safe behavior without application controls. |

<br><br><br>

## What is prompt chaining, and how do you design a chain of prompts for complex tasks?

**Answer:**

### Definition

**Prompt chaining** decomposes a complex task into a sequence or graph of smaller model calls. Each step has a defined subtask and passes a bounded, structured result to a later step. A chain may also combine model calls with retrieval, deterministic code, and external tools.

For example, a document-review workflow might:

1. extract candidate claims and source references;
2. verify each claim against retrieved policy documents;
3. classify supported, contradicted, or unknown claims;
4. generate a concise report from those structured findings.

### Designing a reliable chain

- **Decompose by responsibility:** Each stage should have a clear input, output, and success condition.
- **Define interfaces:** Pass typed structured results, not ambiguous prose where possible.
- **Preserve provenance:** Carry source IDs, offsets, and confidence/uncertainty with extracted facts.
- **Validate between stages:** Parse schemas and apply deterministic checks before downstream use.
- **Choose control flow deliberately:** Run independent stages in parallel; use conditionals or loops only with explicit bounds.
- **Plan failure behavior:** Handle timeouts, malformed outputs, empty retrieval, refusals, and partial completion explicitly.
- **Minimize shared context:** Pass only what the next stage needs, reducing token use and accidental instruction mixing.
- **Version and evaluate end to end:** Test intermediate quality and final task success, not just whether each call returned text.

### Trade-offs

Chaining can improve modularity, observability, and specialization, but each call adds latency, cost, and a potential error boundary. An incorrect early extraction can propagate through every later stage. For simple tasks, a single well-designed call is often better. Use retries sparingly and idempotently; avoid retry loops that duplicate side effects.

### Concise interview answer

“Prompt chaining decomposes a complex task into stages, with each model or tool call receiving a clear input and producing a defined result for the next step. I design explicit schemas and success conditions, validate at stage boundaries, preserve source provenance, parallelize independent work, and bound loops and retries. Chaining improves modularity and can make intermediate outputs testable, but adds latency, cost, and error propagation. I use a chain only when end-to-end evaluation shows an advantage over a single call.”

### Revision summary

| Design decision | Good practice |
|---|---|
| Stage boundaries | Clear responsibility and typed input/output. |
| Evidence | Preserve references and uncertainty between stages. |
| Control flow | Parallelize independent steps; bound loops and retries. |
| Reliability | Validate each handoff and define error paths. |
| When to chain | When measured quality or control outweighs added cost/latency. |

<br><br><br>

## How do you evaluate and iterate on prompt quality?

**Answer:**

### Start with a measurable task definition

Define what a successful response means before editing the prompt. Choose metrics that match the task: exact match or F1 for classification, schema validity for structured output, groundedness and citation correctness for retrieval, task completion for tool use, and human ratings for nuanced quality. Include safety, abstention, latency, and cost when they matter.

### Build a representative evaluation set

Create a versioned set of realistic inputs covering common cases, important edge cases, ambiguity, long inputs, multilingual examples if relevant, and adversarial content. Keep a held-out set so prompt changes are not tuned only to the same examples. Protect the evaluation data from leaking into prompt examples or training.

### Iteration loop

1. Record a baseline with the current prompt, model, parameters, and relevant system configuration.
2. Inspect failures and categorize them—for example, ambiguous instruction, missing evidence, format error, or model capability limit.
3. Change one meaningful factor at a time where practical.
4. Run automated and human evaluation, comparing overall and slice-level results.
5. Check regressions, variance across repeated runs, safety, and cost/latency.
6. Version the prompt and evaluation results; stage rollout and monitor production behavior.

For subjective tasks, use clear rubrics, blinded review, multiple raters for a sample, and agreement checks. Model-based evaluators can scale review but can also share the same biases as the model being evaluated; calibrate them against human judgments and objective checks.

### Avoid common evaluation mistakes

Do not treat one good example, a single model-judge score, or a more polished answer as proof of improvement. Control model version and sampling settings, distinguish prompt regressions from upstream changes, and evaluate across user/task slices rather than relying only on an aggregate score.

### Concise interview answer

“I define task-specific success metrics and create a versioned evaluation set that covers normal, edge, and adversarial cases. I record a baseline, categorize failures, change prompts systematically, and compare the candidate on held-out examples with slice-level quality, safety, latency, and cost metrics. For subjective quality I use a rubric and human review; an LLM judge is calibrated rather than treated as ground truth. I keep prompt/model versions and stage the rollout so regressions are detectable and reversible.”

### Revision summary

| Step | Purpose |
|---|---|
| Define metrics | Turn vague “better” into measurable outcomes. |
| Build test set | Represent real use and failure slices. |
| Establish baseline | Separate actual improvement from intuition. |
| Iterate and compare | Diagnose failures and test changes. |
| Deploy carefully | Version, monitor, and roll back regressions. |

<br><br><br>

## What are meta-prompts, and how can they be used to generate prompts?

**Answer:**

### Definition

A **meta-prompt** is a prompt whose task is to create, critique, transform, or optimize another prompt. For instance, it can take a task description and produce a candidate instruction with examples and an output schema, or review an existing prompt against a checklist.

### A controlled workflow

1. Provide the task, intended users, constraints, examples, and known failure cases.
2. Ask the meta-prompt to produce a candidate prompt in a fixed structure, such as task, inputs, rules, output contract, and edge-case behavior.
3. Review the candidate for ambiguity, unsupported assumptions, unsafe requests, and leakage of sensitive content.
4. Evaluate it against a representative held-out test set.
5. Keep only changes that improve measured performance and preserve safety; version the prompt and record its evaluation.

The meta-prompt can propose candidates, but it should not be the sole judge of its own quality. Use objective validators and human review where appropriate.

### Benefits and limitations

Meta-prompts can speed up prompt drafting, standardize prompt structure, and explore alternative phrasings. They can also produce verbose or overfit instructions, embed incorrect assumptions from the task description, or optimize for a model-judge score without improving real users’ outcomes. Generated prompts may vary between runs, and the producing model may be vulnerable to the same ambiguities or injection attempts as the target model.

Treat generated prompts as code/configuration: review, test, version, and approve them before production. Do not let an untrusted user cause an unreviewed meta-prompt to rewrite privileged system instructions.

### Concise interview answer

“A meta-prompt instructs a model to generate or improve another prompt. It can accelerate drafting by turning a task description and examples into a structured candidate, but it does not establish that the candidate works. I constrain the output format, review assumptions and safety, test the prompt on held-out representative and adversarial cases, and version only validated changes. The model generating a prompt should not be its only evaluator, and user input should not directly rewrite privileged production instructions.”

### Revision summary

| Stage | Practice |
|---|---|
| Generate | Supply task, constraints, examples, and failure cases. |
| Inspect | Review correctness, ambiguity, security, and assumptions. |
| Evaluate | Use held-out tests and independent checks. |
| Govern | Version and approve prompt changes before deployment. |
| Limitation | Self-generated prompt is a candidate, not proof of quality. |

<br><br><br>

## What are the common failure modes in prompting, and how do you debug them?

**Answer:**

### Common failure modes

| Symptom | Likely cause |
|---|---|
| Vague or off-task response | Objective, audience, or constraints are underspecified. |
| Hallucinated facts | Missing evidence, excessive ambiguity, or no abstention path. |
| Inconsistent results | Sampling variability, unstable examples, or underspecified criteria. |
| Invalid output format | Ambiguous schema, truncation, or missing parser/validation. |
| Missed context | Irrelevant/oversized context, lost-in-the-middle effects, or poor retrieval. |
| Tool misuse | Unclear tool descriptions, weak argument validation, or broad permissions. |
| Prompt injection susceptibility | Untrusted content is treated as instruction; controls rely only on wording. |
| Excessive cost/latency | Too much context/output, unnecessary calls, or inefficient routing. |

### Debug systematically

1. **Reproduce the failure:** Save the exact input, rendered messages, model/version, parameters, retrieved context, tool results, and output, subject to privacy controls.
2. **Classify the cause:** Separate prompt ambiguity from missing data, retrieval errors, model capability limits, parser failures, and application bugs.
3. **Inspect boundaries:** Verify token limits, truncation, role ordering, variable rendering, and whether instructions or context were omitted.
4. **Create a focused regression case:** Add the failure and nearby edge cases to the evaluation suite.
5. **Make a targeted change:** Clarify the task, add representative examples, improve evidence/context, or enforce output constraints in code.
6. **Compare and monitor:** Check quality and regressions across slices, plus latency and cost; roll out gradually.

Avoid piling on contradictory instructions or repeatedly tweaking wording on a single example. If the task is outside model capability, no amount of prompt polish will reliably fix it; change the system design, use a tool/model better suited to the task, or abstain.

### Concise interview answer

“I first reproduce the issue with the exact rendered request and fixed model settings, then classify whether it is prompt ambiguity, missing or bad evidence, model limitation, truncation, parser failure, tool behavior, or application logic. I add a regression case, make one targeted change, and evaluate across representative slices for quality, safety, cost, and latency. I avoid prompt patch accumulation; if the root cause is retrieval, validation, or capability, I fix that layer rather than pretending wording alone can solve it.”

### Revision summary

| Debugging step | Question |
|---|---|
| Reproduce | What exact request and configuration failed? |
| Diagnose | Prompt, context, model, tool, parser, or application? |
| Test | Can the failure become a regression case? |
| Fix | Which layer owns the root cause? |
| Verify | Did the change improve the suite without new regressions? |

<br><br><br>

## How do you handle edge cases and adversarial inputs in prompt design?

**Answer:**

### Specify behavior for boundary cases

Identify inputs that are empty, malformed, too long, ambiguous, contradictory, out of scope, unsupported, or missing required information. State the expected behavior explicitly: ask a clarifying question, return a documented error, abstain, or use a defined fallback. Bound input length and allowed values before constructing the model request.

### Treat adversarial content as untrusted

Adversarial inputs may try to override instructions, induce disclosure, manipulate tool use, exploit parsing, or create resource exhaustion. Delimit user and retrieved content and label it as data, but do not assume wording alone will prevent the model from following embedded instructions. Enforce authorization, rate limits, output validation, and tool restrictions in application code.

### Layered handling

- **Validate at the boundary:** Type-check, normalize where appropriate, enforce size and encoding limits, and reject malformed requests.
- **Constrain the model task:** Use clear scope, explicit uncertainty/abstention rules, and a strict response contract.
- **Limit capabilities:** Give only necessary tools and data; check every action server-side.
- **Validate responses:** Parse, schema-check, and apply business rules before downstream use.
- **Test adversarially:** Include direct and indirect injection, conflicting instructions, unusual Unicode/formatting, long inputs, and malformed structured data.
- **Monitor and respond:** Log safely, detect abuse patterns, and provide human escalation for consequential cases.

### Concise interview answer

“I first define expected behavior for empty, malformed, ambiguous, unsupported, and oversized inputs. I validate and bound requests before prompting, label external text as untrusted, and specify when the model should clarify or abstain. Because prompt instructions are not a security boundary, tools and data are protected with server-side authorization, least privilege, rate limits, and strict output validation. I test injection and malformed-input cases and monitor failures without retaining unnecessary sensitive data.”

### Revision summary

| Risk | Control |
|---|---|
| Invalid/oversized input | Boundary validation and size limits. |
| Ambiguity or missing facts | Clarify, abstain, or documented fallback. |
| Malicious instructions in data | Treat as untrusted; enforce security outside the prompt. |
| Unsafe tool/output | Least privilege, authorization, parsing, business-rule validation. |
| Unknown attacks | Adversarial tests, monitoring, and human escalation. |

<br><br><br>

## What is the "lost in the middle" problem in long-context prompting?

**Answer:**

### What it describes

The **“lost in the middle”** problem refers to an observed tendency for some language models to use information less reliably when it appears in the middle of a long input than when it appears near the beginning or end. The effect depends on model, task, prompt structure, and context length; it is not a universal rule that every model ignores the center.

A model may technically accept the full context window while still failing to attend to, retrieve, or apply all evidence in it. Context-window capacity is therefore not the same as effective context use.

### Why it matters

In long documents, transcripts, or retrieved passages, relevant facts can be missed even though they are present. This can lead to incorrect answers, selective evidence use, or a false impression that a larger context window solved the retrieval problem.

### Mitigation and evaluation

- Retrieve or select relevant passages rather than placing all available text into one prompt.
- Put the task and critical constraints in clear, stable locations; avoid relying on position alone.
- Preserve source identifiers and use concise, labeled chunks.
- Summarize or hierarchically process long material while retaining citations and uncertainty.
- For high-stakes tasks, ask targeted questions over smaller evidence sets or verify claims against source passages.
- Test with position-controlled evaluations: place the same evidence at the beginning, middle, and end, and measure answer accuracy and citation faithfulness.

Repeating a fact at multiple positions may help a particular system but increases tokens and can create contradictory context; validate this tactic instead of assuming it works.

### Concise interview answer

“Lost in the middle is the observation that some models use information in the middle of long contexts less reliably than information near the beginning or end. A context window that accepts many tokens does not guarantee effective use of every token. I mitigate it with relevant retrieval, clear chunking and source references, hierarchical processing where needed, and targeted verification. I also evaluate with controlled tests that move evidence across positions, because the effect varies by model and task.”

### Revision summary

| Point | Remember |
|---|---|
| Problem | Mid-context evidence may be used less reliably. |
| Implication | Maximum context length is not effective-retrieval quality. |
| Mitigation | Relevant retrieval, chunking, source links, verification. |
| Evaluation | Position-controlled tests across the context. |

<br><br><br>

## What are output parsers, and why are they needed for production applications?

**Answer:**

### Definition and purpose

An **output parser** converts a model’s response into an application-level representation and checks that it meets an expected format or schema. For example, a parser may turn a JSON string into a typed object, validate required fields and enum values, or parse XML into a structured document.

Parsers matter because model output is not inherently a reliable API contract. Even when a prompt requests JSON, the model may return extra prose, malformed syntax, an incomplete response, or valid syntax with incorrect values.

### A robust processing pipeline

1. Prefer provider-supported structured output or constrained decoding when available.
2. Parse using a real format parser rather than regular-expression extraction.
3. Validate types, required fields, allowed values, lengths, and cross-field/business rules.
4. Handle refusal, truncation, invalid syntax, and schema failures as explicit outcomes.
5. Use bounded retries only when appropriate, supplying a concise validation error; avoid unbounded repair loops.
6. Log validation categories and prompt/model versions safely for diagnosis.

Do not silently coerce invalid data into a success-shaped response. A syntactically valid response is not necessarily factually correct or authorized to trigger an action.

### Security considerations

Treat parsed values as untrusted input. Validate before using them in database queries, HTML, shell commands, or tool calls; use parameterized APIs, output encoding, and server-side authorization. For XML, configure the parser safely, including disabling external entity resolution where applicable.

### Concise interview answer

“An output parser turns model text into a structured application value and validates it against a contract. In production I prefer constrained structured output where available, then still parse and validate types, required fields, enums, and business rules. Refusal, truncation, and malformed output are explicit error states with bounded recovery, not silent coercion. Parsed values remain untrusted and must be safely handled and authorized before they drive downstream actions.”

### Revision summary

| Stage | Responsibility |
|---|---|
| Generation | Request the expected structure; use constraints if available. |
| Parsing | Convert with a format-aware parser. |
| Validation | Check schema and business invariants. |
| Recovery | Handle refusal/truncation/errors explicitly and bound retries. |
| Downstream use | Treat values as untrusted; authorize and safely encode. |

<br><br><br>

## How do you handle multi-language prompting effectively?

**Answer:**

### Design for language explicitly

For multilingual applications, specify the expected input and response language, including how to handle code-switching, names, technical terms, and quoted text. If users may write in multiple languages, detect or accept a language preference rather than assuming English. Keep the task semantics and output schema consistent across locales.

### Practical techniques

- Provide clear examples in the target language when they improve task performance.
- Use native-language instructions for important constraints and validate their interpretation.
- Preserve named entities, numbers, dates, units, and domain terminology; define translation behavior for terms that should remain unchanged.
- Separate the response language from the source language: a user may ask in one language for an answer in another.
- Localize formats such as dates, decimal separators, address conventions, and politeness level.
- For retrieval, use multilingual embeddings or language-aware indexes and test cross-language query/document matching.
- Evaluate each supported language with native or domain-qualified reviewers, not only translated English test cases.

Tokenization efficiency, model quality, safety behavior, and retrieval coverage can differ by language and script. Monitor quality and latency by language; do not infer equal support from a model’s general multilingual claim.

### Concise interview answer

“I make language behavior explicit: detect or accept the user’s preferred language, specify the response language, and define code-switching, terminology, and localization rules. I use target-language examples where helpful, preserve entities and units carefully, and make retrieval multilingual when queries and sources differ in language. I evaluate each language with representative native or domain-qualified examples and track quality, safety, and cost by language, because multilingual performance is not uniform.”

### Revision summary

| Concern | Practice |
|---|---|
| Input/output language | Detect or ask; specify response language. |
| Terminology | Preserve entities, units, and domain terms consistently. |
| Localization | Adapt dates, numbers, and conventions. |
| Retrieval | Test cross-language search and grounding. |
| Quality | Evaluate and monitor per language and script. |

<br><br><br>

## Your few-shot prompting gives inconsistent results across similar inputs. How do you stabilize it?

**Answer:**

### Diagnose the source of variability

First determine whether the inconsistency comes from model sampling, ambiguous labels, unstable examples, prompt rendering, retrieved context, or upstream model/version changes. Re-run identical requests with fixed settings and compare the exact rendered prompt, model identifier, temperature, seed if supported, and context. Low temperature can reduce sampling variation but does not guarantee deterministic output across providers, model updates, or infrastructure.

### Stabilization steps

1. **Clarify the task and decision boundaries.** Define labels and tie/unknown behavior precisely.
2. **Curate demonstrations.** Use representative, correctly labeled examples that cover common cases and boundary cases.
3. **Balance examples.** Avoid overrepresenting one class or letting example order correlate with the answer.
4. **Control rendering.** Use a fixed template and stable serialization; ensure examples and input fields are not accidentally reordered or truncated.
5. **Normalize output.** Require a fixed label/schema and validate it programmatically.
6. **Tune decoding carefully.** Set appropriate sampling parameters and measure repeatability; use deterministic decoding only when it fits the task and API.
7. **Evaluate sensitivity.** Test alternate input phrasings, example order, and similar cases on a held-out set.
8. **Escalate persistent needs.** If the task requires reliable classification, compare a fine-tuned classifier or rules/hybrid system rather than continually adding prompt examples.

### Concise interview answer

“I reproduce identical calls and inspect model/version, sampling settings, rendered prompt, context, and truncation to isolate the source of variance. Then I make label boundaries explicit, curate balanced representative demonstrations, keep serialization and example order stable, and require a validated fixed output schema. I measure repeatability and sensitivity to example order and paraphrases on held-out data. Lower temperature may help but is not a determinism guarantee; if reliability remains insufficient, I evaluate fine-tuning or a conventional classifier.”

### Revision summary

| Cause | Stabilizing action |
|---|---|
| Sampling | Control decoding and measure repeated runs. |
| Ambiguous labels | Define boundaries, unknowns, and ties. |
| Example bias | Curate balanced, representative examples. |
| Rendering variation | Fix template, ordering, and truncation behavior. |
| Persistent unreliability | Compare tuned or non-LLM alternatives. |

<br><br><br>

## Your LLM classification system is too sensitive to prompt wording changes. How do you reduce prompt sensitivity?

**Answer:**

### Treat sensitivity as a robustness problem

If small wording changes flip classifications, the system may be relying on prompt phrasing rather than stable task-relevant features. Establish a baseline with representative labeled data and define acceptable accuracy, calibration, and robustness targets before changing the prompt.

### Reduce sensitivity systematically

- State the classification objective, label definitions, decision boundaries, and behavior for ambiguous or out-of-scope inputs.
- Use a stable, concise template and fixed label order; avoid conflicting instructions or decorative wording.
- Add balanced examples specifically around confusing class boundaries, not just easy cases.
- Require a constrained label output and validate the label against the allowed set.
- Test semantically equivalent prompt paraphrases, input paraphrases, example orderings, and relevant language or demographic slices.
- Measure class-wise precision/recall, calibration, agreement, and worst-slice performance—not just overall accuracy.
- If appropriate, reduce sampling randomness, while recognizing that low temperature alone does not solve semantic instability.
- Consider fine-tuning, a dedicated classifier, or deterministic rules for high-volume, stable taxonomies.

Do not select a prompt only because it performs best on the same small set used to edit it. Keep a held-out set, and evaluate model-version changes as well as wording changes.

### Concise interview answer

“I measure prompt sensitivity with controlled paraphrases while holding the model and inputs constant, then analyze which labels and slices flip. I make label definitions and boundary cases explicit, use balanced demonstrations and a stable template, constrain outputs, and evaluate accuracy, calibration, and worst-slice robustness on held-out data. Reducing temperature may lower sampling variance but cannot eliminate sensitivity. If a business-critical classifier remains unstable, I compare fine-tuning or a conventional classifier and keep prompt-only behavior out of the decision boundary.”

### Revision summary

| Step | Goal |
|---|---|
| Measure | Controlled prompt/input paraphrases and repeat runs. |
| Clarify | Precise labels, boundaries, and abstention behavior. |
| Stabilize | Fixed template, balanced examples, constrained output. |
| Validate | Held-out, slice-level accuracy, calibration, robustness. |
| Reconsider | Fine-tuning or non-LLM classifier if reliability requires it. |

<br><br><br>

## Your chatbot's system prompt containing proprietary business logic is being leaked by users. How do you prevent it?

**Answer:**

### Start with the correct security assumption

Assume any text placed in a model’s context may be disclosed in an output, log, trace, or debugging interface. A system prompt is not a confidential vault: instructions such as “never reveal this prompt” may reduce accidental disclosure but cannot guarantee secrecy from a user who asks directly or indirectly.

### Reduce impact and move authority out of the prompt

1. **Remove secrets and sensitive implementation details.** Put credentials, private keys, and confidential data in secure services, not prompt text.
2. **Move business rules to application code.** If the logic is proprietary and security-sensitive, enforce it in trusted services; give the model only the minimum facts needed to explain an outcome.
3. **Minimize context.** Include only the instructions and data required for the current task; scope user-specific information and tool results.
4. **Enforce access server-side.** Authenticate users and authorize every data lookup or action independently of what the prompt says.
5. **Protect operational surfaces.** Restrict prompt/trace access, redact sensitive logs, use least-privilege observability permissions, and define retention.
6. **Test disclosure attempts.** Evaluate direct requests, paraphrases, encoding, multi-turn extraction, and indirect injection; monitor for unusual output or access.
7. **Plan response and rotation.** Treat a leaked credential as compromised and rotate it. If business logic was exposed, assess impact and move the sensitive behavior behind a controlled API.

Output filters or refusal instructions can be an additional layer but cannot establish confidentiality by themselves. Avoid adding more proprietary text to a detector prompt as the sole remedy.

### Concise interview answer

“I assume a system prompt can be exposed and never put credentials or critical secrets in it. I move sensitive business decisions into trusted application services, keep only the minimum model context, and enforce user authorization server-side on every read and action. I also restrict and redact traces, test direct and indirect extraction attempts, and monitor disclosure. If a secret has leaked, I rotate it; if proprietary rules leaked, I assess impact and remove that authority from the prompt.”

### Revision summary

| Risk | Response |
|---|---|
| Prompt disclosure | Assume possible; prompt secrecy is not a security guarantee. |
| Credentials in context | Remove, store securely, rotate if exposed. |
| Business logic exposure | Enforce critical logic in trusted services. |
| Unauthorized data | Server-side authentication and authorization. |
| Detection | Adversarial tests, protected logs, incident response. |

<br><br><br>

## Your LLM agent is vulnerable to prompt injection that reveals the system prompt. How do you defend it?

**Answer:**

### Threat model

An agent may receive instructions from users, retrieved documents, web pages, emails, and tool outputs. Any of these untrusted sources may ask the model to reveal its system prompt or take an unintended action. Since prompt-level instructions cannot reliably prevent the model from following injected text, the defense must ensure that disclosure or manipulation does not grant access or authority.

### Defense in depth

- **Do not store secrets in the prompt.** Treat system instructions as potentially observable; move sensitive logic and credentials to protected services.
- **Minimize exposed context.** Include only the policy and data needed for this specific request.
- **Separate trusted instructions from untrusted data.** Use roles and clear data boundaries where supported, while recognizing that this improves clarity but is not a hard security barrier.
- **Constrain agent capabilities.** Give the agent only necessary tools, with narrow scopes, typed arguments, and allowlisted operations.
- **Authorize outside the model.** The server must check identity, tenant, and permission on every tool call and data retrieval.
- **Validate actions and outputs.** Apply policy checks, rate limits, output filtering where appropriate, and human confirmation for sensitive or irreversible operations.
- **Protect traces and logs.** Restrict access, redact sensitive content, and set retention policies.
- **Test end to end.** Include direct and indirect injection, multi-turn attempts, and tool-chain scenarios; confirm that even a manipulated model cannot access unauthorized data or perform privileged actions.

### Concise interview answer

“I treat prompt injection as an expected failure mode and ensure it cannot create privilege. I do not put secrets in the system prompt; I minimize context, label external content as untrusted, and constrain tools with least privilege. Every data access and tool action is authorized server-side, validated, and audited, with confirmation for high-impact operations. I protect traces and test direct, indirect, and multi-turn attacks. A prompt asking the model not to reveal itself is only a supplementary signal, not the defense.”

### Revision summary

| Layer | Control |
|---|---|
| Prompt/context | Minimize and separate instructions from untrusted content. |
| Secrets | Keep out of model context; protect and rotate. |
| Tools/data | Least privilege and server-side authorization per action. |
| Operations | Validate, rate-limit, audit, and require confirmation when needed. |
| Assurance | Test injection paths end to end; safety must hold if the model errs. |

<br><br><br>

## Your chain-of-thought prompting is not improving LLM accuracy on reasoning tasks. What do you fix?

**Answer:**

### Diagnose before adding more reasoning instructions

Requesting longer step-by-step text may not address the actual failure. First inspect representative wrong answers and determine whether the bottleneck is task ambiguity, missing or misleading context, incorrect retrieval, model capability, arithmetic, tool use, or a flawed evaluation metric. Establish a baseline with fixed model version and decoding settings.

### Improvements to test

1. **Clarify the task and output.** Remove ambiguity and define assumptions, constraints, and what counts as correct.
2. **Break the task into verifiable steps.** Ask for a compact plan, intermediate values, or structured subanswers—not necessarily a long free-form chain.
3. **Provide a relevant worked example.** Use examples that teach the actual reasoning pattern and cover boundary cases.
4. **Use tools where appropriate.** Delegate arithmetic, code execution, retrieval, or symbolic checks to deterministic tools.
5. **Improve evidence quality.** If the task depends on facts, retrieve authoritative context and require citations or evidence links.
6. **Add verification.** Check intermediate results and final outputs with unit tests, constraints, or an independent method.
7. **Compare alternatives.** Evaluate direct prompting, few-shot examples, decomposition, self-consistency, or a specialized model on held-out data.

If longer reasoning is not measurably helping, remove it: it can increase cost and create more opportunities for unsupported claims. For user-facing behavior, return concise explanations or verified steps rather than exposing internal reasoning traces.

### Concise interview answer

“I would inspect errors and establish a controlled baseline before asking for more chain-of-thought. I diagnose whether the issue is ambiguity, missing evidence, retrieval, model capability, or computation. Then I test focused decomposition, relevant demonstrations, authoritative context, and tools or deterministic checks for arithmetic and code. I compare accuracy and cost on held-out cases. Longer reasoning is not inherently better; if it does not improve measured results, I remove it and return a concise, verifiable explanation.”

### Revision summary

| Failure source | Candidate fix |
|---|---|
| Ambiguous task | Specify assumptions, constraints, and success criteria. |
| Missing facts | Improve retrieval and provide authoritative evidence. |
| Computation | Use a calculator, code, or symbolic tool. |
| Reasoning structure | Decompose into compact, verifiable intermediate outputs. |
| No measured gain | Remove unnecessary CoT and optimize for cost/quality. |

<br><br><br>

## Your AI system works in English but fails for other languages. How do you add multilingual support?

**Answer:**

### Diagnose by language and pipeline stage

Do not treat “multilingual failure” as a single prompt problem. Measure quality separately by language, script, locale, and task, then identify whether the issue is language detection, tokenization, model capability, prompt interpretation, retrieval, safety behavior, or output localization. Include native speakers or domain-qualified reviewers in diagnosis.

### Build support end to end

1. **Prioritize languages and use cases.** Set quality targets based on user and business needs rather than claiming broad support from model metadata.
2. **Create representative evaluation data.** Include native-language examples, dialects, code-switching, scripts, transliteration, domain terms, and edge cases.
3. **Make language behavior explicit.** Detect or ask for preference, specify response language, and define how to handle quoted text and code-switching.
4. **Improve retrieval.** Use multilingual embeddings or language-specific indexes as appropriate; test cross-language query-to-document matching and preserve source references.
5. **Localize, do not merely translate.** Validate dates, numbers, units, names, tone, and domain terminology with qualified reviewers.
6. **Review safety and policy parity.** Test refusals, abuse detection, and sensitive-topic handling per language so weaker moderation does not create a gap.
7. **Roll out gradually.** Monitor accuracy, hallucination, safety, latency, and cost by language; maintain fallback or human escalation where quality is insufficient.

If a model cannot meet the required quality for a language, consider translation pipelines, language-specific fine-tuning, or a different model—but evaluate meaning preservation and error propagation across each stage.

### Concise interview answer

“I first measure failures by language and pipeline stage rather than simply translating the prompt. I build native, representative evaluations, make input and response language explicit, add multilingual retrieval where needed, and localize terminology and formats. I also test safety parity and monitor quality, latency, and cost per language with qualified reviewers. If the base model is weak, I compare translation-assisted or language-specific adaptation approaches and keep human fallback for unsupported cases.”

### Revision summary

| Area | Work required |
|---|---|
| Diagnosis | Segment metrics by language, script, task, and pipeline stage. |
| Data | Native and domain-reviewed evaluation examples. |
| Prompt/retrieval | Explicit language policy and cross-lingual retrieval tests. |
| Localization | Terminology, formats, and cultural conventions. |
| Operations | Safety parity, per-language monitoring, fallback. |

<br><br><br>

## Your zero-shot cross-lingual transfer from English fails on other languages. How do you fix it?

**Answer:**

### Check whether transfer is a reasonable assumption

Zero-shot cross-lingual transfer assumes a model can apply an English-described task to another language without target-language demonstrations. It may fail because the model has weaker coverage of that language, the task instructions do not transfer, labels are culturally or linguistically ambiguous, or the tokenizer and training data provide uneven support. First identify which languages and task slices fail; do not assume one English prompt will work equally well everywhere.

### A measured remediation plan

1. **Verify the target-language input.** Check script, encoding, normalization, language detection, and whether mixed-language text is expected.
2. **Rewrite instructions in the target language.** Have a native or domain-qualified reviewer validate semantics, constraints, and label definitions.
3. **Add a small target-language few-shot set.** Use balanced, representative examples around decision boundaries; measure whether this improves held-out transfer.
4. **Localize labels and rubric.** Confirm categories have equivalent meanings; some taxonomies need language- or locale-specific definitions.
5. **Use cross-lingual retrieval or translation carefully.** Evaluate translation fidelity and error propagation; preserve original text and evidence.
6. **Adapt if needed.** Compare language-specific fine-tuning, adapters, or a stronger multilingual model using an appropriate held-out dataset.
7. **Monitor per-language behavior.** Include accuracy, calibration, safety, and abstention; route unsupported cases to a fallback.

Avoid evaluating only on machine-translated English benchmarks: translation artifacts can hide real-world ambiguity, dialect, and cultural variation.

### Concise interview answer

“I would not assume English zero-shot transfer is reliable. I segment errors by target language, validate tokenization and language detection, and have native reviewers check task instructions and label semantics. Then I test target-language examples, multilingual retrieval or carefully evaluated translation, and language-specific adaptation if needed. I use native held-out data and monitor quality and safety per language; when performance remains below threshold, the system should abstain or route to a supported workflow.”

### Revision summary

| Transfer gap | Fix to evaluate |
|---|---|
| Poor instruction transfer | Native-reviewed target-language instructions. |
| Sparse task grounding | Balanced target-language few-shot examples. |
| Label mismatch | Localized rubric and category definitions. |
| Weak model coverage | Multilingual model, adapter, or fine-tuning. |
| Evaluation blind spot | Native held-out data and per-language monitoring. |

<br><br><br>
