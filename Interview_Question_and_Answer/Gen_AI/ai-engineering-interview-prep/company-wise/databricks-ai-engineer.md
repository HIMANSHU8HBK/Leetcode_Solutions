# Databricks — AI / GenAI Engineer Interview Bank

**Research snapshot:** October 31, 2026  
**Target:** AI Engineer / GenAI Engineer roles building or deploying data-grounded AI systems. This is not a Databricks-only product certification guide, nor is it aimed at pure ML research or a customer-facing Solutions Architect role.

This bank is designed to prepare for the engineering judgment behind Databricks' Data + AI platform: governed enterprise data, retrieval and agents, evaluation, deployment, and production operations. Publicly available material does **not** establish a fixed AI Engineer interview loop or a definitive list of questions asked by Databricks. Treat the prompts below as structured practice, not predictions.

## How to interpret the research

### What is confirmed by Databricks

- Databricks says its interview process varies by role. Its engineering page lists a hiring-manager phone screen, technical phone screen, virtual panel interviews, reference checks, and hiring committee as the process candidates may expect.
- The official interview-preparation page describes behavioral interviews based on real examples of how candidates work, learn, collaborate, solve problems, and make decisions. It does not publish an AI Engineer technical question list.
- Databricks describes engineering work across data processing, transformation, querying, training, and deployment of large AI applications. Current public documentation covers agent development, AI Search, MLflow GenAI tracing/evaluation, model serving, and Unity Catalog / Unity Gateway governance.

### What public candidate material suggests

A public interview-notes repository says its Databricks examples are reconstructed from candidate experiences and categorizes the material under coding and system design. Its Databricks sample is a graph/grid-style coding exercise. This is useful as a **weak signal** to practice problem solving and system design, not as evidence of the exact prompt, role, level, or current interview format. I have not copied that repository's problem statement or solution.

### Confidence labels used in this guide

- **Confirmed process:** directly stated in current Databricks careers material.
- **Reported pattern:** a pattern described by a public candidate-reconstruction source; anecdotal and not official.
- **Practice prompt:** an original question synthesized from Databricks' public engineering/product material and the target role. It is not claimed to have been asked verbatim.

## Suggested preparation sequence

1. Read the job description and identify whether the role is product engineering, applied AI, platform engineering, or customer-facing. The same title can cover different work.
2. Prepare one end-to-end project deep dive: user need, data path, model/retrieval choices, evaluation, governance, deployment, measured impact, and lessons.
3. Practice Python coding and core data structures under time pressure. Include graph traversal, arrays/maps, queues, and careful handling of edge cases; this is practice guidance, not a promise about the question set.
4. Rehearse one AI system-design interview and one production-debugging interview aloud. State assumptions, success metrics, data boundaries, failure behavior, and trade-offs before choosing components.
5. Prepare behavioral stories from your own experience. Never disclose confidential information or proprietary material from a current or former employer.
6. Ask the recruiter to confirm the interview format, role-specific preparation materials, coding language, and whether a presentation or take-home exercise is part of your process.

## A. Company, product, and role understanding

### 1. [Practice prompt] What kinds of enterprise problems are a good fit for a unified Data + AI platform, and when would you recommend a different architecture?

**Answer:**

I would first look for a workload where data and AI are tightly coupled: for example, an assistant that must retrieve current company knowledge, respect fine-grained permissions, generate a response with evidence, and be monitored as one application. A unified platform can be a good fit when teams benefit from governed access to shared data, consistent development and deployment workflows, and a clear path from experimentation to production without repeatedly copying data between disconnected systems.

I would not recommend a platform based on breadth alone. I would compare it with the customer's existing architecture against concrete requirements: data location and movement, security and compliance, workload scale, latency, availability, integrations, operational maturity, migration effort, portability, and total cost. A specialized search or serving system may be a better fit for unusual latency or hardware needs; an existing warehouse or cloud-native stack may be preferable when it already meets the requirements and migration would add little value.

My recommendation would be a small, representative proof of value with agreed success measures, such as answer quality, data freshness, access-control correctness, latency, and cost. I would be explicit about trade-offs and avoid implying that a unified platform removes the need for good data engineering, application design, evaluation, or operational ownership.

### 2. [Practice prompt] Explain how governed source data, model development, evaluation, deployment, and monitoring can form one lifecycle. Where are the important interfaces and failure boundaries?

**Answer:**

I think of the lifecycle as a sequence of controlled handoffs. Governed source data is prepared and versioned; model or application code is developed against explicit inputs; evaluation checks whether the candidate meets quality, safety, and cost requirements; deployment promotes a specific artifact and configuration; monitoring compares production behavior with expected service and quality signals. Each stage should preserve enough lineage to explain what data, code, model, prompt, and evaluation informed a release.

The important interfaces are the data contract, identity and authorization boundary, model/application interface, evaluation gate, and deployment contract. For example, retrieval must enforce the caller's permissions before content reaches the model; a model response must be validated before it is treated as structured application data; and promotion should use a known artifact rather than an untracked notebook state.

Failures can occur at every boundary: stale or malformed data, access-control drift, an incompatible schema, evaluation gaps, dependency changes, endpoint failures, or production distribution shift. I would make these visible with validation and lineage, explicit release criteria, versioned artifacts, monitoring, and rollback paths. Governance is not a single final approval: it needs to apply throughout development and runtime.

### 3. [Practice prompt] A customer asks to build a chatbot over internal documents. What questions would you ask before choosing RAG, fine-tuning, an agent, or a simpler search-and-summary workflow?

**Answer:**

Before choosing a design, I would clarify the users and tasks, document types and volume, update frequency, access rules, required answer freshness and citations, expected traffic and latency, failure impact, and how we will measure success. I would also ask whether users need answers only, or whether the system must take actions; what a correct answer looks like; how often the answer is already available through search; and what data can be sent to a model.

For frequently changing facts that must be grounded in private documents, I would start by evaluating retrieval-augmented generation (RAG), with permission-aware retrieval and citations. Fine-tuning is more appropriate when we need to teach a stable behavior, format, or domain-specific response pattern and have suitable training examples; it is usually not the first choice for keeping changing document facts current. An agent is justified when the task genuinely requires multiple steps or approved tools, such as retrieving information and then creating a ticket. If users mainly need to locate a known passage, search with filters and snippets may be more accurate, simpler, and cheaper than generation.

I would establish a baseline using the simplest plausible workflow, build a representative evaluation set, and compare options on task success, grounding, permission isolation, latency, cost, and operational complexity. Then I would prototype the smallest end-to-end slice, inspect failures with domain users, and expand only when evidence shows that added model or agent complexity improves the outcome.

### 4. [Practice prompt] How would you explain the value and limitations of Databricks AI Search, MLflow GenAI, Unity Catalog, and model serving to a technical customer without turning the answer into a product-feature list?

**Answer:**

I would explain the value through one customer workflow rather than reciting product names. Suppose employees need answers from changing internal documentation. Unity Catalog can be part of the governed foundation for managing and controlling data and AI assets. AI Search can provide a retrieval layer for finding relevant material. The application can use a served model to compose a response, while MLflow GenAI capabilities help teams trace and evaluate application behavior as they iterate and operate it.

The benefit is the opportunity to connect data governance, retrieval, model access, and development feedback in a more coherent workflow. The tools do not make the application correct automatically: source quality and permissions still matter; retrieval can miss evidence; generated answers can be wrong; and tracing or evaluation is only useful when the team defines meaningful tests and responds to what they reveal. A customer should validate the required access-control semantics, freshness, latency, model quality, deployment constraints, and cost in its own workload.

I would finish by proposing a small evaluation against the customer's current process. We would measure task completion, citation support, unauthorized retrieval, latency, and cost, then decide which platform components solve demonstrated needs. That keeps the discussion focused on outcomes and limitations rather than treating a product feature list as an architecture.

### 5. [Practice prompt] A team wants to move an experimental notebook into a supported production service. What must change in the code, data controls, deployment process, and operational ownership?

**Answer:**

I would first turn the notebook into a reproducible application with clear inputs, outputs, and ownership. That usually means separating business logic from exploration, parameterizing environment-specific settings, pinning and testing dependencies, defining data and API contracts, and adding unit, integration, and failure-path tests. Long-running or retryable work should be idempotent where possible, with explicit handling for partial failures, rate limits, and duplicate requests.

For data controls, I would identify the service identity and grant only the required access. I would remove embedded credentials, use approved secret management, preserve row- or object-level permissions where required, and define retention and logging rules for sensitive prompts and outputs. Model, prompt, and data versions should be traceable so a production result can be investigated and a known-good version restored.

For deployment, I would use an automated build and release path with development and staging validation, a canary or limited rollout, health and quality checks, and a rollback plan. Before launch, the team should agree on service-level objectives, dashboards and alerts for errors, latency, usage, and cost, a runbook, and named operational owners. I would compare the deployed service with the notebook baseline and move traffic gradually only after correctness, access controls, and operational readiness are demonstrated.

### 6. [Practice prompt] How would you decide whether a requirement belongs in a data pipeline, a retrieval layer, an application service, or the model prompt?

**Answer:**

I would place each requirement at the layer that can enforce it most reliably and close to its source of truth:

- **Data pipeline:** use it for repeatable transformations that apply to the corpus regardless of who asks a question, such as parsing, normalization, deduplication, chunking, metadata enrichment, and embedding generation. Keep lineage and support incremental updates.
- **Retrieval layer:** use it to find the relevant, current, and authorized evidence for a request. Ranking, metadata filters, freshness, and access-aware candidate selection belong here, with permissions tied to trusted identity and policy.
- **Application service:** use it for authentication, authorization, orchestration, business rules, validation, rate limits, retries, tool permissions, auditability, and deciding what to do when dependencies fail. These are deterministic controls; I would not delegate them to the model.
- **Model prompt/context:** use it to express task intent, response structure, tone, and how the model should use supplied evidence or handle uncertainty. Prompts can guide behavior but are not a security boundary or a substitute for validating outputs.

Some requirements cross layers. For example, “answer only from documents the user can access” needs correctly governed source data, retrieval filtering based on authenticated identity, and application-side checks before content is passed to the model. I would test the full path, especially denial cases, and make the requirement observable so a failure can be traced to the right layer.

## B. Governed data and retrieval on Databricks

### 7. [Practice prompt] Design a RAG ingestion pipeline for frequently updated enterprise documents stored in Delta tables. Cover incremental updates, deletions, chunk identity, embedding refresh, and recovery after partial failure.

**Answer:**

I would define a stable source key and track each record's source version or change timestamp, deletion state, and content hash. A streaming or scheduled incremental job can read new and changed records from Delta change data, normalize and parse content, split it into chunks, and write an idempotent chunk table. A chunk ID should be deterministic from the source key, source version or content hash, and chunk position or stable chunk key; this makes retries safe and lets us identify obsolete chunks.

For each chunk, I would persist the source ID, version, content hash, chunk text, ordinal, citation metadata, access-control metadata, and embedding model/version. If the content is unchanged and the embedding model is unchanged, reuse the existing embedding. If the text changes, regenerate embeddings for the affected chunks; if the embedding model changes, plan a controlled full or staged re-embedding and index migration rather than mixing incompatible vectors silently.

Deletions and access changes must propagate as carefully as inserts. I would process tombstones or change records and remove or mark all derived chunks so retrieval cannot return deleted or newly unauthorized content. The index should be updated from the governed chunk table, with a reconciliation job to compare expected source/chunk state with indexed state.

To recover from partial failure, make each stage idempotent, checkpoint progress, record per-batch status, and retry failed batches without duplicating chunks. Publish a batch as ready only after its content and embeddings are complete; monitor lag, failures, duplicate IDs, and source-to-index counts. I would test updates, deletions, model-version changes, and interruption between stages before relying on the pipeline.

### 8. [Practice prompt] How would you choose between vector similarity, keyword search, and hybrid retrieval for a corpus containing both prose and exact product codes?

**Answer:**

I would evaluate all three against representative questions and judged relevant passages rather than choose by intuition. Vector similarity is useful when the query and passage express the same idea using different words. Keyword or lexical search is strong for exact product codes, names, error strings, version numbers, and other terms whose precise match matters. A hybrid approach can combine semantic coverage with exact-term recall, which is often a good starting hypothesis for a mixed corpus.

I would inspect tokenization and normalization for identifiers—for example, whether punctuation, case, or separators in product codes are preserved—and check whether metadata filters could narrow candidates correctly. For hybrid retrieval, I would evaluate the fusion method and weighting, then tune ranking or reranking on actual examples. Metrics should include recall at k for relevant passages, ranking quality, citation support, and downstream answer correctness, with slices for exact-code and natural-language queries.

Finally, I would account for latency, index freshness, operational complexity, and cost. If hybrid search offers no measurable improvement for the important query types, a simpler retrieval method is preferable. I would keep a regression set of exact identifiers and paraphrased questions so later index or ranking changes do not silently break either behavior.

### 9. [Practice prompt] An AI Search index returns semantically related passages but misses exact names, identifiers, and version numbers. How would you investigate and improve retrieval?

**Answer:**

I would first determine whether the failure occurs during query parsing, candidate retrieval, filtering, or ranking. I would collect representative failing queries and expected documents, inspect the raw indexed text and metadata, and verify that names and identifiers were not lost through parsing, chunking, tokenization, or normalization. I would also confirm that the relevant source version was ingested and that no filter or permission rule excluded it.

Then I would compare lexical, vector, and hybrid retrieval on a labeled set. Exact names, product codes, and version strings usually need a lexical signal; semantic similarity alone can favor conceptually related but incorrect passages. I would test case and punctuation handling, metadata fields for exact identifiers, query expansion where appropriate, hybrid weighting or rank fusion, and a reranker if it improves ordering without hiding exact matches.

I would measure recall at k and ranking quality separately for exact-match and semantic queries, then test the resulting answers and citations. Any change should be checked for latency, freshness, and authorization behavior. I would add these failures to a regression suite and instrument retrieval diagnostics—such as candidate counts and filter outcomes—without unnecessarily logging sensitive query content.

### 10. [Practice prompt] How would you apply metadata filters and authorization checks so a RAG query cannot retrieve records the requesting user is not allowed to see?

**Answer:**

I would authenticate the user at the application boundary and derive their identity and entitlements from a trusted identity or authorization service, not from request text or model output. Each indexed chunk needs reliable security metadata—such as tenant, document, group, or policy identifiers—kept synchronized with the governed source.

Before retrieval, the application should construct filters from the authenticated principal's current permissions and apply them as part of candidate selection. The model must receive only the authorized retrieved content; filtering the final answer after retrieval is insufficient because unauthorized text may already have entered the prompt or logs. If permissions are complex or frequently changing, I would favor an authorization-aware retrieval path or a secure pre-retrieval policy check rather than relying on stale copied ACLs.

I would also check authorization again before any downstream tool action or source-document fetch, use least-privilege service identities, and fail closed if identity or policy evaluation is unavailable. Tests should include cross-tenant access, revoked permissions, group changes, guessed document IDs, empty entitlements, and adversarial prompts asking for restricted content. Audit logs should capture the principal, policy decision, and resource identifiers at an appropriate level while minimizing sensitive content retention.

### 11. [Practice prompt] A source Delta table changes while the search index is synchronizing. What freshness and consistency guarantees would you expose to the application, and how would you detect indexing lag?

**Answer:**

I would avoid promising strict read-after-write consistency unless the ingestion and index path actually provides it. Instead, define a measurable freshness objective, such as a target maximum delay from a committed source update to searchable content, and expose an index or synchronization watermark so the application can tell how current its searchable view is.

For changes that have not reached the index yet, the product can communicate that content may be briefly stale, show a last-indexed time, or route especially freshness-sensitive lookups through a source-of-truth path. If a document is deleted or access is revoked, the safety requirement is stricter: I would ensure it becomes unavailable to retrieval as quickly as feasible and consider a denylist or authorization check against the source policy while index updates propagate.

I would measure lag from source commit/change version to index visibility, monitor sync duration and failures, and compare source change counts with indexed updates. Synthetic canary records can test end-to-end visibility and deletion behavior. Alerts should distinguish a slow but progressing sync from a stuck or failed one. The service should have a defined response when freshness exceeds its objective rather than silently presenting stale results as current.

### 12. [Practice prompt] Design a document-chunk schema for retrieval. Which fields are required for citations, filtering, updates, access control, and debugging, and which should not be embedded?

**Answer:**

I would give each chunk a stable chunk ID and retain a source document ID, source version or update timestamp, content hash, chunk ordinal or offsets, and the chunk text. Citation fields should identify the human-readable source and a stable location—such as title, URI, page, section, or character offsets—so the UI can link the answer to its evidence.

For filtering and access, I would store structured metadata such as tenant, document type, language, effective date, and access-policy identifiers or groups, with a clear process for synchronizing permission changes. For updates and debugging, I would track ingestion batch/version, parser or chunker version, embedding model/version, timestamps, and processing status. These fields help distinguish stale data, a changed source, a changed embedding, or a pipeline defect.

I would embed the meaningful searchable content, not identifiers or control metadata that should be used as exact filters. In particular, access-control fields, tenant IDs, source IDs, secrets, and operational fields must not be relied on as semantic text for security. Exact product codes may be indexed lexically or stored as searchable metadata depending on the retrieval system, but should be tested independently. Minimize retained personal or sensitive content, and ensure the index inherits the source's governance and retention requirements.

### 13. [Practice prompt] A customer requires row-level and column-level restrictions in natural-language analytics. How would you preserve those restrictions across question interpretation, query generation, execution, and answer generation?

**Answer:**

I would treat the authenticated user's permissions as a constraint on the entire workflow, not something the model can infer. The application should resolve the caller's identity and entitlements through trusted authorization, then provide the model only the schema and business context the caller is allowed to use. The model can propose a query, but it cannot grant access.

Generated SQL should be parsed and validated against an allowlisted set of catalogs, tables, columns, and permitted operations. Row-level policies should be enforced by the trusted query execution identity or governed data platform at execution time, not reimplemented as model-generated WHERE clauses. Column-level restrictions should prevent unauthorized fields from being selected or exposed, including through derived expressions where policy requires it. Use parameterized query execution and impose limits, timeouts, and read-only constraints as appropriate.

After execution, I would validate the returned columns and rows against policy before passing results to the model, then constrain answer generation to those authorized results. Tests should cover direct and indirect leakage, aliases and aggregates, joins, nested queries, prompt injection, alternate identities, and changed permissions. I would log the principal, validated query or query ID, policy outcome, and access decision while minimizing sensitive values. If identity or policy cannot be established, fail closed rather than answering with broader service-account access.

### 14. [Practice prompt] How would you use Unity Catalog concepts to govern tables, models, functions, and AI services consistently across development and production?

**Answer:**

I would use a consistent ownership and permission model for the assets involved in the application, with governed data and AI assets discoverable through catalogs and schemas, and explicit grants aligned to development, staging, and production responsibilities. The goal is to make the data, model, function, and serving endpoint access path understandable and auditable rather than relying on informal workspace conventions.

For tables, I would define owners, grants, and any row- or column-level controls required by the workload. For models and functions, I would track versions and limit who can create, execute, or promote them. For an AI service, I would scope its service identity to only the resources it needs and keep user-level authorization in the request path where end-user permissions must be honored. I would separate human development permissions from runtime permissions and avoid broad shared credentials.

Promotion should use reviewed, versioned artifacts and configuration, with lineage linking code, model, data, and evaluation results. I would verify permissions and behavior in each environment, monitor access and quality, and have a revocation and rollback process. The exact controls depend on the customer's Unity Catalog configuration and product versions, so I would validate the intended enforcement semantics with a test identity and representative positive and negative access cases before release.

### 15. [Practice prompt] A RAG system is accurate in a developer workspace but leaks or omits data after deployment under a service identity. How would you reason about user identity, service-principal permissions, and least privilege?

**Answer:**

I would first distinguish the two identities: the end user making the request and the service principal used by the deployed application. In development, a human identity may have broad access that masks missing production grants. In deployment, a service principal may have too little access and omit documents, or too much access and retrieve data the end user should not see.

I would trace the request end to end: which identity authenticates the user, how that identity is mapped to permissions, what principal queries the source or index, which filters are applied, and what content reaches the model. I would compare effective permissions in development and production, inspect policy and index synchronization, and reproduce with test users covering allowed and denied cases. I would not solve omissions by granting the service principal broad access unless there is a separate, reliable per-user authorization layer.

Apply least privilege to the service identity and keep it narrowly scoped to the required tables, indexes, models, or functions. If the application must honor each user's access, carry a trusted user or entitlement context into an authorization-aware retrieval/query path; do not accept identity claims from the prompt or client without validation. Filter before content enters model context, fail closed when identity or policy lookup fails, and audit decisions without logging sensitive retrieved text unnecessarily. Finally, add deployment integration tests for permission revocation, cross-tenant access, and service-identity behavior so workspace success cannot substitute for production validation.

## C. GenAI applications, agents, and evaluation

### 16. [Practice prompt] Design an enterprise knowledge assistant that uses Databricks AI Search. Walk through ingestion, retrieval, generation, citations, authorization, evaluation, and production monitoring.

**Answer:**

I would start with the source systems, user tasks, freshness needs, and access policies. An incremental pipeline would parse approved documents, normalize and chunk them with stable IDs, preserve source/version and citation metadata, and synchronize deletions and permission changes. I would build or synchronize the AI Search index from a governed chunk table and monitor ingestion failures and source-to-index lag.

At query time, the application authenticates the user and derives authorization context from a trusted identity system. It retrieves only permitted candidates, using metadata filters and a retrieval strategy evaluated against representative questions. The model receives the question and selected evidence with instructions to answer from that evidence and abstain when it is insufficient. The application validates that citations refer to retrieved sources and returns source links or locations with the answer.

I would keep access checks, tool permissions, and output validation in application code rather than relying on prompt instructions. Evaluation should include retrieval recall and ranking, answer correctness, grounding/citation validity, permission isolation, abstention, safety, and latency/cost. I would use offline regression sets before release and a staged rollout with traces and production metrics afterward. Monitor endpoint errors and latency, retrieval/index freshness, usage and cost, user corrections, and safety incidents; define owners, alerts, and rollback criteria.

### 17. [Practice prompt] When is an agent justified over a deterministic workflow or a single RAG call? Define the evidence you would require before adding tool use and multi-step planning.

**Answer:**

I would use an agent only when the task requires meaningful choice among steps or tools based on intermediate results—for example, searching several sources, resolving ambiguity, and then preparing a draft action. If the workflow is known in advance, a deterministic state machine is usually easier to test, cheaper, faster, and more predictable. If the task is simply to answer from retrieved documents, a single RAG call may be sufficient.

Before adding agent behavior, I would define a representative task set and compare the agent against the simplest baseline. Evidence should show better end-to-end task completion or a meaningful user benefit, not just more tool calls or more fluent explanations. I would track correctness, completion rate, tool selection and argument validity, retries/loops, latency, cost, safety, and recovery from tool failures, with slices for ambiguous and high-risk cases.

I would start with a bounded prototype: a small allowlisted tool set, limited steps and time, read-only permissions where possible, and human confirmation for consequential actions. I would expand autonomy only if evaluations and a controlled pilot show reliable behavior. If the agent's planning does not improve the outcome enough to justify its added failure modes and operating cost, I would keep the deterministic or single-call design.

### 18. [Practice prompt] An agent can call SQL, search, and an external API. How would you design tool schemas, permission checks, confirmation for consequential actions, and bounded execution?

**Answer:**

I would give each tool a narrow, typed schema with required fields, explicit enums and limits, clear descriptions, and structured success/error results. SQL access should be constrained to approved catalogs, tables, columns, and read-only operations unless there is a specific reviewed write use case. Search should accept bounded queries and filters. External API tools should expose only the actions and fields the product needs.

The application—not the model—must authenticate the caller, authorize every operation, validate arguments against business rules, and execute with least-privilege credentials. For consequential or irreversible actions, the agent should present a preview of the exact action and relevant parameters, then require explicit user confirmation bound to that action before execution. Revalidate authorization and critical state at execution time to avoid stale approvals or time-of-check/time-of-use problems.

I would enforce per-tool timeouts, rate limits, idempotency keys for retryable writes, maximum steps/tokens/spend, and a total deadline. Treat tool output as untrusted input, contain errors, and stop on repeated failures or lack of progress. Record a trace of decisions and tool outcomes with sensitive data minimized, and test unauthorized calls, malformed arguments, injection in results, duplicate execution, timeout, cancellation, and partial failure.

### 19. [Practice prompt] How would you persist conversation sessions and longer-term agent memory while supporting privacy, deletion, tenant isolation, and recovery after a worker restart?

**Answer:**

I would separate short-lived conversation state from any longer-term memory. Store session messages or a compact state representation under an opaque session ID with tenant and owner identifiers, timestamps, retention policy, and schema/version metadata. Persist only information needed to resume the workflow; avoid treating every conversation detail as durable memory by default. Long-term memory should have a defined purpose, user-visible controls, and an explicit consent/retention policy.

Enforce tenant isolation in storage and every read/write path, encrypt data in transit and at rest, and use least-privilege service access. A deletion request should remove or tombstone the relevant session and derived memory, then propagate to caches, indexes, backups, and downstream stores according to a documented deletion policy. Do not rely on the model to forget data that remains in storage.

For worker recovery, persist state transitions and tool results with idempotency keys, and use a durable queue or workflow record so a restarted worker can resume safely without repeating side effects. Version the state schema and handle incompatible versions explicitly. Test tenant boundary violations, deletion races, retries, worker crashes between tool execution and state commit, and retention expiry.

### 20. [Practice prompt] What information should a GenAI trace capture for a multi-step agent, and how would you use traces to reproduce a failure without indiscriminately retaining sensitive prompts or retrieved content?

**Answer:**

I would capture a correlation/trace ID, application and prompt versions, model/deployment identifier, timing and token/cost metadata, step boundaries, retrieval parameters and candidate IDs/scores, tool names and validated arguments, outcomes/errors, safety or authorization decisions, and the final response status. This makes it possible to locate whether a failure came from orchestration, retrieval, model behavior, a tool, or a downstream validator.

Raw user content and retrieved passages should not be logged by default. I would prefer structured metadata, redacted or sampled payloads, and short retention periods with access controls. If exact content is required for debugging, use an approved, narrowly scoped capture process with user/customer privacy requirements, encryption, audited access, and deletion rules. Make logs explicitly distinguish absent/redacted content from empty content.

To reproduce a failure, use a trace ID to locate the versions and sequence of operations, then replay against a sanitized fixture or controlled dataset with the same model and configuration where feasible. Record whether the replay is exact or approximate because model endpoints can be nondeterministic or change. Convert the root cause into a regression test and ensure the tracing design does not create a new privacy or security risk.

### 21. [Practice prompt] Build an evaluation plan for a production RAG agent. Separate retrieval, response quality, groundedness, tool behavior, safety, and operational measures; explain which checks should be deterministic.

**Answer:**

I would build a versioned test set from real task patterns, with held-out examples and slices for document type, language, freshness, permissions, ambiguity, and high-impact cases. Evaluate components separately and end to end:

- **Retrieval:** recall at k and ranking quality against labeled relevant passages; deterministic checks can verify filters, source IDs, and whether required documents appear in the candidate set.
- **Response quality:** task correctness, completeness, and usefulness; use reference-based checks where possible and calibrated human or model-assisted review for open-ended responses.
- **Groundedness:** verify claims against supplied evidence and check citation links/locations. Citation existence and schema can be deterministic; semantic entailment generally needs human review or a calibrated judge.
- **Tool behavior:** assert allowed tool selection, argument schema, authorization, and expected results with deterministic mocks; separately test whether the tool was appropriate for the task.
- **Safety:** deterministic tests for access denial, prohibited actions, and required confirmation; human/adversarial tests for nuanced harmful or injection cases.
- **Operations:** measure latency percentiles, timeouts, availability, token use, cost, retries, and index freshness from system telemetry.

I would define release thresholds and critical no-regression conditions before comparing versions. Offline tests should be followed by a limited rollout that monitors user outcomes and failure reports. A single aggregate score should not hide a regression in safety, permission isolation, or an important user segment.

### 22. [Practice prompt] How would you combine human feedback, LLM judges, code-based scorers, and fixed test examples in a repeatable evaluation workflow? How would you validate that a judge is useful?

**Answer:**

I would maintain a versioned evaluation dataset with fixed regression examples, representative production-derived cases that are appropriately de-identified, and adversarial or boundary tests. Code-based scorers should check objective properties such as schema validity, exact values, citation IDs, policy outcomes, and tool-call constraints. Human reviewers should judge nuanced qualities such as usefulness, factual support, and tone using a clear rubric. An LLM judge can help scale these subjective checks but should not be the sole release authority.

I would validate a judge by comparing its ratings with independent human labels on a representative, blinded sample; measure agreement and error patterns; check for position, verbosity, style, or model-family bias; and test whether small controlled changes affect the score as expected. Calibrate thresholds and periodically recheck the judge as models and tasks change. For close comparisons, use pairwise evaluations with randomized answer order and human adjudication for disagreements.

The workflow should pin evaluator, rubric, dataset, model, prompt, and application versions; store results and confidence or disagreement indicators; and make runs repeatable. Production feedback should be triaged and converted into new evaluation cases after review, while keeping training or prompt-tuning examples distinct from held-out regression tests.

### 23. [Practice prompt] A new prompt improves judge scores but worsens customer task completion. What additional evidence would you inspect before deciding whether to release it?

**Answer:**

I would treat customer task completion as a critical outcome and not release based on a judge-score increase alone. First, verify the measurement: compare cohorts and traffic mix, check logging and attribution, account for sample size and uncertainty, and confirm the task-completion metric measures the intended user outcome rather than a proxy.

Then I would inspect representative failures and segment results by task type, user group, language, context length, retrieval quality, and model response style. The prompt may be optimizing for the judge's rubric—such as longer, more confident, or more elaborated answers—while making the actual workflow slower or less actionable. I would also compare grounding, refusal, citation correctness, latency, and follow-up/abandonment rates.

I would run a controlled comparison on the same held-out cases, blind reviewers where practical, and include direct human assessment of task success. If the task metric regression is real, I would reject or revise the prompt, add the failure examples to the regression set, and recalibrate the judge if it rewards behavior users do not value. Any release should meet pre-agreed guardrails and be staged with rollback criteria.

### 24. [Practice prompt] How would you compare two model versions using the same production-like workload while controlling for nondeterminism, traffic mix, latency, and inference cost?

**Answer:**

I would freeze a representative, privacy-safe workload with the same inputs, retrieval snapshots, tool fixtures, and application configuration for both models. Run both versions across the same task and traffic slices, randomize or interleave execution order to reduce time-related bias, and repeat samples where nondeterminism matters. Keep decoding parameters and output limits consistent when supported, and record model, endpoint, prompt, and dependency versions.

Quality comparisons should use predetermined metrics and blinded human or calibrated pairwise evaluation for subjective output. Deterministic scorers should check schemas, citations, and tool constraints. For online behavior, use a randomized A/B or shadow test with careful exposure controls, ensuring the shadow model cannot trigger side effects.

Measure latency distributions (especially time-to-first-token and p95/p99), error/timeout rates, throughput, token usage, and cost per successful task—not just per request. Compare within task and traffic strata, report uncertainty, and investigate quality/cost trade-offs. Use predeclared launch gates and a rollback plan; do not infer a general win from a single benchmark or a noisy average.

### 25. [Practice prompt] A model produces valid structured output that is syntactically correct but refers to nonexistent records. Where would you validate the response, and how would you prevent invalid output from causing a side effect?

**Answer:**

Schema validation is necessary but not sufficient. I would validate the output in the application service immediately after parsing and before any database mutation, external API call, or other side effect. Check that referenced IDs exist, belong to the authorized tenant, are in the expected state, and satisfy domain invariants. Use trusted database lookups or parameterized queries; never let a model-created identifier establish authorization.

For write operations, prefer a two-phase flow: validate and create a proposed action, show the user a clear preview when the action is consequential, then revalidate current state and authorization at commit time. Make the operation idempotent and use a transaction or conditional update so a record that changes between validation and execution cannot be modified incorrectly. If validation fails, return a structured error or ask for clarification rather than guessing or silently substituting another record.

I would test nonexistent IDs, cross-tenant IDs, stale records, duplicates, malformed-but-schema-valid combinations, race conditions, and retries. The invariant is that no model output directly triggers an irreversible side effect without deterministic validation and the required authorization.

### 26. [Practice prompt] How would you use MLflow traces, evaluation results, and production feedback as a learning loop from observed failure to regression test to safely deployed fix?

**Answer:**

I would start by triaging production feedback and traces into a concrete failure category—for example, retrieval missed the relevant document, the model made an unsupported claim, a tool call was invalid, or the request failed operationally. Traces help connect the user-visible result to the prompt/model version, retrieval candidates, tool calls, timings, and validators. I would inspect only the content needed under the applicable privacy controls.

After confirming the root cause, I would create a sanitized, reproducible evaluation case with expected behavior and add it to the appropriate regression set. I would keep holdout cases separate from examples used to tune prompts or retrieval so the fix is not evaluated only on the example that inspired it. Then I would change the responsible layer, rerun component and end-to-end evaluations, and compare quality, safety, latency, and cost against the current baseline.

For rollout, I would version the code, prompt, model, and evaluation results; deploy behind a feature flag or canary; monitor the relevant failure slice and guardrails; and retain a rollback path. If the fix shifts behavior or creates a new failure, feed that evidence into the next iteration. This makes feedback actionable without assuming every individual report is representative or storing sensitive transcripts indiscriminately.

### 27. [Practice prompt] How would you test prompt injection contained in retrieved enterprise documents when the agent also has tools that can access governed data?

**Answer:**

I would model retrieved documents and tool results as untrusted data, even when they come from an internal source. The key invariant is that document text can inform an answer but cannot change the agent's authority, override system policy, or grant access. Authorization must be enforced by trusted application code and data-platform policies, not by asking the model to resist malicious instructions.

I would create adversarial test documents containing instructions to reveal secrets, ignore prior rules, call tools, exfiltrate retrieved content, or access another tenant's records. Test them alongside benign quoted instructions so the system does not simply reject all imperative text. Exercise the full path: ingestion and metadata, retrieval, prompt/context assembly, model response, tool selection, argument validation, authorization, and output handling.

Tools should be allowlisted and least-privileged; SQL should be read-only and constrained where possible; external network access and secrets should be restricted; and consequential actions should require explicit user confirmation. The application should validate every tool call against the authenticated user and resource policy and should never put credentials in model context. I would assert that injected content cannot cause unauthorized retrieval or actions, monitor tool-denial and suspicious-pattern metrics, and review regressions after changes to prompts, models, retrieval, or permissions.

## D. Data and ML engineering fundamentals

### 28. [Practice prompt] A streaming source delivers duplicate and late events used to refresh an AI Search index. How would you design an idempotent Delta pipeline and define the freshness contract?

**Answer:**

I would require a stable event or source-record key, a source version or event time, and an explicit operation type such as upsert or delete. In the streaming pipeline, I would deduplicate by key and version, handle late events with a watermark appropriate to the source's lateness distribution, and use deterministic upserts into a Delta table so replaying a micro-batch does not create duplicate state. When versions conflict, define a deterministic ordering rule and preserve tombstones so a late older upsert cannot resurrect a deleted record.

From the resulting current-state table, derive chunks and embeddings idempotently using stable chunk IDs and content hashes, then synchronize the search index. Checkpoint stream progress and make each downstream step retryable; reconcile the index against the authoritative Delta state to catch partial failures or missed deletes.

I would define the freshness objective precisely—for example, a percentile or maximum target from source commit to searchable update—and specify what the application does when it is exceeded. Measure source-to-table and table-to-index lag separately, monitor checkpoint progress, late-event volume, retry/failure counts, and deletion propagation, and use synthetic canaries for end-to-end verification. For security-sensitive deletions or permission revocations, add a fast deny path rather than relying solely on eventual index synchronization.

### 29. [Practice prompt] A Spark job generating embeddings is slow and occasionally exhausts memory. How would you profile and improve it without hiding data skew behind an arbitrary increase in cluster size?

**Answer:**

I would first profile the stages and task distributions: input and output rows/bytes, partition sizes, per-task duration, executor memory and garbage collection, shuffle read/write, spill, model-call latency, and retry/OOM locations. Compare median and tail task times and inspect the largest partitions and keys to distinguish skew from a uniformly undersized cluster or slow external endpoint.

Then I would verify the data path: avoid collecting records to the driver, control partition sizes, project only needed columns, and batch texts for embedding within a bounded memory budget. If a few keys or documents dominate, split or process them deliberately; tune shuffle partitioning or use skew-aware techniques where appropriate. Cache only when reuse justifies memory, and release large intermediate data. For endpoint-backed embeddings, use bounded concurrency, request-size limits, backpressure, and retry policies that respect rate limits.

I would benchmark a representative sample and compare throughput, tail latency, memory/spill, and cost before and after each change. Increase cluster size only if profiling shows distributed compute or memory capacity is the actual bottleneck and the workload scales with additional resources. Add monitoring for partition skew and OOMs so the fix remains visible as data volume changes.

### 30. [Practice prompt] When would you use Spark-native transformations, vectorized UDFs, or an external model endpoint for embedding generation? Compare throughput, serialization, cost, and operational complexity.

**Answer:**

I would choose based on where the embedding model runs, the volume and freshness requirements, and measured end-to-end throughput:

- **Spark-native transformations** are preferable for built-in or SQL-native operations that avoid Python row-by-row overhead and integrate naturally with distributed execution. Use them for supported preprocessing and transformations; they do not automatically mean the embedding model itself is available as a native expression.
- **Vectorized UDFs** can process batches in Python with Arrow/Pandas-style vectorization, reducing per-row serialization overhead compared with scalar UDFs. They are useful when model libraries can run close to the workers, but require careful control of batch size, worker memory, dependency distribution, and GPU/resource contention.
- **External model endpoints** centralize model lifecycle and can decouple Spark workers from model runtime, making upgrades and serving policies easier. They add network latency, request/response serialization, rate limits, endpoint cost, and failure/backpressure concerns; use bounded parallelism and batch requests where the endpoint supports it.

I would compare effective embeddings per second, total cost per million records, tail latency, retry/error rate, memory use, serialization and network overhead, and operational burden on a representative dataset. I would ensure deterministic IDs and model-version metadata regardless of implementation, and test that retries do not duplicate or mislabel results. The fastest microbenchmark is not enough if it creates fragile deployment or throttles the endpoint at production scale.

### 31. [Practice prompt] How would you design a backfill that recomputes embeddings after changing the embedding model while keeping the currently served index available?

**Answer:**

I would treat the embedding-model change as a new versioned retrieval artifact, not overwrite the live vectors in place. Record the model name/version, dimensions, preprocessing, and relevant configuration alongside each embedding, and ensure the new vectors are never compared with old vectors in the same index unless the retrieval system explicitly supports that compatibility.

I would create a new embedding column or versioned chunk table and a separate index (or isolated namespace) for the new model. Backfill incrementally from the authoritative chunk data, checkpoint progress, make writes idempotent, and monitor failures, coverage, and cost. The existing index continues serving traffic during the backfill.

Before switching, evaluate the new index with the same held-out retrieval and end-to-end datasets, including exact identifiers, freshness, permission filters, and citations. Shadow or canary a portion of eligible queries if safe, comparing quality and latency without duplicating side effects. Once the new index meets release criteria and is sufficiently populated, switch via configuration or alias; keep the old index available for a defined rollback window. Only retire it after verifying traffic, consistency, and retention requirements.

### 32. [Practice prompt] What is the difference between tracking an experiment and governing a production model artifact? Describe how you would make the model, code, data, and evaluation lineage auditable.

**Answer:**

Experiment tracking records what was tried and the observed results: parameters, metrics, artifacts, source revision, environment, and possibly traces or datasets. It helps compare experiments and reproduce development work. Production governance adds controls for which artifact is approved, who owns and can access it, how it is versioned and promoted, what it is allowed to serve, and how it can be monitored, rolled back, or retired.

For auditability, I would link a deployed model or application version to immutable identifiers for its model weights or provider deployment, code commit/build, prompt and configuration, training/evaluation data versions or snapshots, and evaluation run with dataset and scorer versions. For RAG, also record the embedding model and index/chunk snapshot or watermark relevant to the release. Preserve approval and promotion events, runtime configuration, and endpoint identity.

Lineage should be discoverable through the organization's model and data governance systems, with access controls and retention appropriate to the artifacts. I would verify that the recorded lineage corresponds to what actually ran in production, not merely what was intended to deploy. A rollback should identify a previously evaluated artifact/configuration bundle, not just a model name.

### 33. [Practice prompt] How would you choose between online serving, batch inference, and streaming inference for a model-backed feature with both interactive and large-scale workloads?

**Answer:**

I would separate the workloads by latency and freshness needs rather than force one serving mode to serve both:

- **Online serving** fits interactive requests requiring a response within a user-facing latency budget, such as a chat answer or on-demand classification. It needs capacity management, concurrency limits, timeouts, and clear degradation behavior.
- **Batch inference** fits large, schedulable workloads where minutes or hours of latency are acceptable, such as backfills, offline enrichment, or periodic scoring. It can improve throughput and resource utilization but needs job tracking, idempotency, and recovery.
- **Streaming inference** fits continuously arriving events where results should be produced with bounded delay, such as near-real-time enrichment. It requires checkpointing, event-time handling, backpressure, and explicit semantics for duplicates and late data.

I would quantify volume, arrival pattern, freshness, per-request latency, output use, peak-to-average ratio, and cost. Shared model code or artifacts may serve multiple paths, but I would isolate resource pools or quotas so batch work cannot starve interactive traffic. I would compare total cost per successful task and operational complexity, then define separate SLOs and fallback paths for each workload.

### 34. [Practice prompt] A model endpoint has good average latency but poor p99 latency under concurrent requests. Which measurements and workload characteristics would you inspect, and what mitigation would you test first?

**Answer:**

I would first break latency into queueing, preprocessing, model execution, and response/streaming time, and examine p50/p95/p99 by request class rather than only the overall average. Inspect concurrency, queue depth, request and output token lengths, batch composition, cold starts, retries, rate limits, GPU memory/utilization, batching wait time, and any downstream retrieval or tool latency. A small number of very long prompts or outputs can dominate tail latency even when typical requests are fast.

I would also check whether traffic bursts exceed provisioned concurrency, whether dynamic batching waits too long for a batch, and whether retries amplify overload. Correlate trace data with endpoint and infrastructure metrics while avoiding unnecessary retention of sensitive payloads.

The first mitigation depends on the bottleneck, but I would usually test admission control and bounded concurrency with appropriate queue limits to prevent overload amplification, while ensuring requests fail or degrade predictably. If queueing dominates, scale capacity or adjust batching/scheduling; if long contexts dominate, consider context limits, caching, or workload routing; if generation dominates, evaluate output limits or a faster model while checking quality. Validate changes using a production-like load test and compare p99, throughput, errors, and cost—not just the mean.

## E. Coding and practical exercises

The public candidate-reconstruction source provides a weak signal for coding-round practice, including graph/grid traversal. The exercises below are original practice prompts and are not copied from that source.

### 35. [Practice prompt] Given a directed dependency graph for document-processing jobs, return a valid execution order or report a cycle. Explain your complexity and how you would test edge cases.

**Answer:**

I would use Kahn's topological-sort algorithm. Build an adjacency list and indegree count for every job, then process zero-indegree jobs from a queue. When a job is emitted, decrement the indegree of its dependents and enqueue any that reach zero. If fewer jobs are emitted than the number of nodes, the graph contains a cycle. The ordering is deterministic for a fixed queue order; if a canonical order is required, use a min-heap instead of a FIFO queue.

```python
from collections import defaultdict, deque

def execution_order(jobs, dependencies):
    """Return a topological ordering, or None if dependencies contain a cycle."""
    graph = defaultdict(list)
    indegree = {job: 0 for job in jobs}

    for prerequisite, dependent in dependencies:
        if prerequisite not in indegree or dependent not in indegree:
            raise ValueError("dependency references an unknown job")
        graph[prerequisite].append(dependent)
        indegree[dependent] += 1

    ready = deque(job for job in jobs if indegree[job] == 0)
    order = []

    while ready:
        job = ready.popleft()
        order.append(job)
        for dependent in graph[job]:
            indegree[dependent] -= 1
            if indegree[dependent] == 0:
                ready.append(dependent)

    return order if len(order) == len(indegree) else None
```

With `V` jobs and `E` dependencies, building the graph and traversing it takes `O(V + E)` time and `O(V + E)` space. I would test an empty graph, one job, a linear chain, independent jobs, a diamond dependency, multiple valid orderings, a self-cycle, a multi-node cycle, duplicate edges, and an edge referencing an unknown job. If duplicate dependencies are allowed in the input, I would either deduplicate them or document that each edge is counted consistently; otherwise they can be handled as repeated indegree increments/decrements.

### 36. [Practice prompt] Write a Python function that groups incoming document updates by stable document ID and returns only the latest valid version, handling duplicate timestamps and deletions deterministically.

**Answer:**

I would validate the stable ID, timestamp, and operation first, then choose a deterministic winner per document. Timestamps alone may tie, so I would use a source-provided monotonic version or sequence as the next ordering key and define a final stable tie-breaker. If an upsert and delete have the same timestamp/version, I would make deletion win to avoid resurrecting a document. Invalid records should be reported or quarantined rather than silently treated as valid updates.

```python
from datetime import datetime

def latest_valid_updates(updates):
    """Return one latest update per document ID; a deletion wins an exact tie."""
    latest = {}

    for update in updates:
        doc_id = update.get("document_id")
        timestamp = update.get("updated_at")
        version = update.get("version")
        operation = update.get("operation")

        if not doc_id or not isinstance(timestamp, datetime):
            continue
        if not isinstance(version, int) or operation not in {"upsert", "delete"}:
            continue

        # Version resolves timestamp ties; delete wins if both ordering fields tie.
        rank = (timestamp, version, operation == "delete")
        current = latest.get(doc_id)
        if current is None or rank > current[0]:
            latest[doc_id] = (rank, update)

    return {
        doc_id: update
        for doc_id, (_, update) in latest.items()
    }
```

In production I would not silently `continue` invalid records; I would send them to a quarantine/dead-letter path with a reason and metrics. The ordering fields must reflect the source's actual semantics—if versions are not comparable across events, use a source-defined sequence or event ID. Tests should cover out-of-order updates, equal timestamps, duplicate events, deletion ties, missing IDs, invalid operations, and replaying the same input.

### 37. [Practice prompt] Design a chunking function that respects document boundaries where possible, applies a token budget and overlap, and preserves source offsets and metadata for citations.

**Answer:**

I would tokenize each document section independently so chunks do not cross unrelated document boundaries. Use a tokenizer matching the target embedding/model context, enforce a maximum token count, and create overlap by moving the next chunk's starting token backward by a configured amount. Store stable source ID/version, section, chunk ordinal, and source offsets for citations. For exact offsets, tokenize with offset mappings from the source text; the simplified example below assumes the tokenizer returns token offsets.

```python
def chunk_section(text, tokenizer, max_tokens, overlap_tokens, metadata):
    if max_tokens <= 0 or not 0 <= overlap_tokens < max_tokens:
        raise ValueError("require max_tokens > overlap_tokens >= 0")

    encoded = tokenizer.encode_with_offsets(text)
    tokens = encoded.tokens
    offsets = encoded.offsets
    chunks = []
    start = 0

    while start < len(tokens):
        end = min(start + max_tokens, len(tokens))
        char_start = offsets[start][0]
        char_end = offsets[end - 1][1]
        chunks.append({
            **metadata,
            "chunk_ordinal": len(chunks),
            "start_char": char_start,
            "end_char": char_end,
            "text": text[char_start:char_end],
        })
        if end == len(tokens):
            break
        start = end - overlap_tokens

    return chunks
```

In a real implementation, I would adapt the tokenizer API and ensure offsets map correctly for Unicode and normalized text. I would also preserve page/section boundaries and metadata before chunking, handle empty sections, and test that each emitted chunk stays within budget, overlap is as intended, offsets are monotonic, and citations reconstruct the right source span. If one paragraph exceeds the budget, split it at sentence or token boundaries rather than dropping content.

### 38. [Practice prompt] Given retrieval results with scores, source IDs, and access labels, implement a selection step that filters unauthorized results, removes duplicates, and applies a bounded context budget.

**Answer:**

I would apply authorization before deduplication and before any result is added to model context. Then sort by retrieval score, keep the best result per stable source/chunk identity, and add results until the token budget is exhausted. In production, token counting must use the model's tokenizer and the budget must reserve space for instructions and the user's request.

```python
def select_context(results, allowed_labels, token_count, token_budget):
    if token_budget < 0:
        raise ValueError("token_budget must be non-negative")

    authorized = [
        item for item in results
        if item.get("access_label") in allowed_labels
        and item.get("text")
        and item.get("source_id") is not None
    ]
    authorized.sort(key=lambda item: item.get("score", float("-inf")),
                    reverse=True)

    selected = []
    seen = set()
    used_tokens = 0

    for item in authorized:
        key = (item["source_id"], item.get("chunk_id"))
        if key in seen:
            continue
        size = token_count(item["text"])
        if size < 0:
            raise ValueError("token_count returned a negative value")
        if used_tokens + size > token_budget:
            continue
        selected.append(item)
        seen.add(key)
        used_tokens += size

    return selected
```

I would validate access labels against a trusted authorization decision rather than accept them from an untrusted request. I would define whether oversized high-ranked chunks should be skipped or truncated at a safe boundary, preserve citations, and test ties, missing fields, duplicate chunks, unauthorized high scores, and exact budget boundaries. The application should fail closed if authorization cannot be determined.

### 39. [Practice prompt] Implement an idempotent batch-processing pattern for embedding records so that retrying a failed partition cannot create duplicate or stale index entries.

**Answer:**

I would give each source chunk a deterministic key based on document ID, source version/content hash, and chunk identity, and record the embedding model version. Process a bounded batch, write results to a staging table with an idempotent merge keyed by `(chunk_id, embedding_model_version)`, and publish only completed records to the index. A stale event must not overwrite a newer document version; compare source versions during the merge. Deletes should be represented as tombstones and propagated to the serving index.

```python
def process_batch(rows, embed_batch, staging, model_version):
    prepared = []
    for row in rows:
        if row["deleted"]:
            prepared.append({
                "chunk_id": row["chunk_id"],
                "source_version": row["source_version"],
                "model_version": model_version,
                "deleted": True,
                "embedding": None,
            })
            continue

        vector = embed_batch(row["text"])
        prepared.append({
            "chunk_id": row["chunk_id"],
            "source_version": row["source_version"],
            "model_version": model_version,
            "deleted": False,
            "embedding": vector,
        })

    # Upsert by the stable composite key; accept only non-stale source versions.
    staging.merge_if_newer(
        prepared,
        key=("chunk_id", "model_version"),
        version_column="source_version",
    )
```

The storage merge and index publication APIs are intentionally abstract here; they must provide atomic or otherwise recoverable upsert semantics. I would checkpoint source progress only after the staging write succeeds, make retries safe with the same keys, and reconcile staged rows against index state. Tests should replay the same partition, fail between embedding and write, fail between write and checkpoint, deliver an older version late, and process delete/recreate sequences.

### 40. [Practice prompt] Given per-request traces containing model, tenant, token count, latency, and outcome, calculate cost and quality summaries by tenant without allowing missing fields or failed requests to corrupt aggregate metrics.

**Answer:**

I would validate each trace and keep denominators explicit. Failed or malformed requests should count toward reliability/error metrics but should not be included as successful quality observations. Missing token counts should not be silently treated as zero for cost; report them as unknown and count them separately. Cost should use a versioned per-model price table and known input/output token categories if available.

```python
from collections import defaultdict

def summarize_by_tenant(traces, price_per_1k, quality_key="quality"):
    totals = defaultdict(lambda: {
        "requests": 0, "successes": 0, "failures": 0,
        "known_cost": 0.0, "cost_known_requests": 0,
        "latency_values": [], "quality_values": [],
    })

    for trace in traces:
        tenant = trace.get("tenant")
        if not isinstance(tenant, str) or not tenant:
            continue
        row = totals[tenant]
        row["requests"] += 1

        succeeded = trace.get("outcome") == "success"
        row["successes" if succeeded else "failures"] += 1

        model = trace.get("model")
        tokens = trace.get("token_count")
        if model in price_per_1k and isinstance(tokens, int) and tokens >= 0:
            row["known_cost"] += tokens * price_per_1k[model] / 1000
            row["cost_known_requests"] += 1

        latency = trace.get("latency_ms")
        if succeeded and isinstance(latency, (int, float)) and latency >= 0:
            row["latency_values"].append(latency)

        quality = trace.get(quality_key)
        if succeeded and isinstance(quality, (int, float)):
            row["quality_values"].append(quality)

    summaries = {}
    for tenant, row in totals.items():
        summaries[tenant] = {
            "requests": row["requests"],
            "success_rate": row["successes"] / row["requests"],
            "known_cost": row["known_cost"],
            "cost_coverage": row["cost_known_requests"] / row["requests"],
            "mean_success_latency_ms": (
                sum(row["latency_values"]) / len(row["latency_values"])
                if row["latency_values"] else None
            ),
            "mean_success_quality": (
                sum(row["quality_values"]) / len(row["quality_values"])
                if row["quality_values"] else None
            ),
        }
    return summaries
```

I would report quality sample coverage and use a production percentile calculation for latency rather than rely only on a mean. In practice, validate finite numeric values, distinguish input/output token prices, handle model-price changes by effective date, and avoid exposing small-tenant aggregates that could reveal sensitive behavior.

### 41. [Practice prompt] You are given a grid of blocked and traversable cells and need the shortest route from a start to a destination. Explain the algorithm, data structures, complexity, and how you would extend it when edges have different costs.

**Answer:**

For an unweighted grid, I would use breadth-first search (BFS), because it explores cells in increasing number of steps. A queue stores cells to visit, a visited set prevents revisiting, and a parent map reconstructs the route when the destination is reached. With `R` rows and `C` columns, the time and space complexity are both `O(R * C)` in the worst case.

If moves have different nonnegative costs, ordinary BFS is no longer sufficient. I would use Dijkstra's algorithm with a min-priority queue; if all edge costs are equal, BFS remains appropriate. A* can be useful when a valid heuristic such as Manhattan distance is available and the grid is large, but correctness requires an admissible heuristic.

```python
from collections import deque

def shortest_path(grid, start, goal):
    rows = len(grid)
    cols = len(grid[0]) if rows else 0
    if not rows or not cols:
        return None

    def open_cell(cell):
        r, c = cell
        return 0 <= r < rows and 0 <= c < cols and grid[r][c] == 0

    if not open_cell(start) or not open_cell(goal):
        return None

    queue = deque([start])
    parent = {start: None}
    directions = ((1, 0), (-1, 0), (0, 1), (0, -1))

    while queue:
        r, c = queue.popleft()
        current = (r, c)
        if current == goal:
            path = []
            while current is not None:
                path.append(current)
                current = parent[current]
            return path[::-1]

        for dr, dc in directions:
            neighbor = (r + dr, c + dc)
            if neighbor not in parent and open_cell(neighbor):
                parent[neighbor] = (r, c)
                queue.append(neighbor)
    return None
```

I would test blocked or out-of-bounds endpoints, no route, start equal to goal, a one-row grid, and multiple equal-length routes. The code assumes `0` is traversable and `1` is blocked; I would make that contract explicit.

## F. System-design practice

### 42. [Practice prompt] Design a multi-tenant enterprise RAG service on Databricks for thousands of customers, each with different document volumes, access policies, freshness needs, and model budgets.

**Answer:**

I would separate the control plane from the data plane. The control plane holds tenant configuration, identity/policy mappings, index and model assignments, quotas, retention, and deployment settings. The data plane handles ingestion, retrieval, generation, and telemetry under tenant-scoped authorization. At request time, authenticate the caller, resolve tenant and entitlements from trusted identity, enforce quota and policy, retrieve only authorized chunks, and pass only those chunks to the model.

For ingestion, use an incremental, idempotent pipeline from governed sources into versioned chunk tables and indexes. Choose isolation per sensitivity and scale: shared infrastructure with strict tenant keys and policy filters can be cost-efficient, while dedicated indexes or compute may be appropriate for large or highly regulated customers. Do not rely on a tenant ID supplied by the prompt. Propagate deletes and permission changes and track freshness per tenant.

Use configurable model routing and budgets with per-tenant concurrency, token, and spend limits; queue or degrade gracefully under pressure. Evaluate retrieval and answer quality by tenant/task slice, and keep quality, latency, cost, and isolation metrics separate. Prevent noisy-neighbor issues with resource quotas and workload isolation, and use model fallbacks only when policy and quality permit.

Operationally, define SLOs for freshness, availability, and latency; monitor index lag, errors, cost, and authorization denials; and provide audit trails, data retention/deletion, incident response, and rollback. Validate at scale with cross-tenant penetration tests, access revocation tests, load tests, and failure injection. I would confirm the exact Databricks governance and serving controls available in the customer's deployment rather than assume a particular feature configuration.

### 43. [Practice prompt] Design a governed natural-language-to-SQL assistant over Unity Catalog data. Cover schema discovery, query generation, SQL validation, authorization, execution limits, result explanation, and auditability.

**Answer:**

I would begin with an authenticated user and a governed schema-discovery step that returns only catalogs, tables, columns, and descriptions the user is allowed to see. Provide the model a concise, relevant schema plus business definitions; do not expose secrets or unrestricted metadata. The model generates a candidate query, but trusted code parses it and enforces an allowlist of relations, columns, functions, and read-only statements.

Execute under an identity and policy configuration that preserves the user's intended row- and column-level access. If the service uses a service principal, I must not accidentally broaden user access: authorization needs to be enforced for the end user before execution, and the query engine's governed policies should remain authoritative. Use parameterized values, query timeouts, row/result limits, concurrency controls, and cost or scan limits where available.

Return results to the model only after checking that the columns and rows are permitted. Generate an explanation grounded in the executed query and result, include the query or data provenance appropriate to the user's permissions, and state when the result is empty or uncertain rather than inventing an answer. Keep an audit record of principal, schema context/version, generated and validated query or query ID, policy decision, execution outcome, and model/prompt versions, while minimizing sensitive result logging.

Evaluation should include query correctness, permission isolation, prompt injection, SQL injection-like content, expensive-query rejection, and explanation faithfulness. I would use read-only execution by default, safe failure behavior, and human review before enabling writes or high-impact decisions.

### 44. [Practice prompt] Design an agent service that must survive worker restarts and support synchronous, streaming, and background tasks. What state is durable, how are runs resumed, and how do you avoid repeating side effects?

**Answer:**

I would represent each agent run as a durable workflow with a run ID, tenant/owner, request and configuration references, status, deadline, step number, and versioned state. Persist completed tool results and checkpoints before advancing the state machine. Store large payloads in governed object/table storage and keep only references plus hashes in the orchestration record. Encrypt and apply retention/deletion rules to conversation content.

For synchronous requests, execute within a bounded deadline and return a result or a run handle if it will take longer. Streaming sends progress/events to the client but should not be the only durable record; reconnecting clients can resume from a sequence cursor. Background runs use a durable queue and workers that claim work with leases, heartbeat, and checkpoint progress. After restart, a worker reloads the last committed state and continues from the next safe step.

Exactly-once execution across external systems is generally not guaranteed. I would use idempotency keys derived from run and action IDs, persist intent before calling a tool, and persist the result afterward. For external APIs, use their idempotency support or reconcile the remote state before retrying an uncertain action. Human approval should be a durable, signed/associated transition bound to the exact action parameters. Enforce max steps, deadlines, cancellation, and retry budgets; make terminal and failed states explicit and auditable.

### 45. [Practice prompt] Design a model-serving architecture that routes between a hosted foundation model and a fine-tuned model while enforcing latency objectives, cost budgets, privacy boundaries, and a fallback policy.

**Answer:**

I would put a policy-aware model gateway behind the application API. It authenticates the caller, classifies the request using trusted metadata and deterministic rules, applies privacy and provider allowlists, and selects a model based on task capability, data sensitivity, latency SLO, and budget. A hosted foundation model may be appropriate for broad capability, while a fine-tuned endpoint may be preferred for a stable domain task or a data-residency constraint; selection should be supported by evaluations on the actual workload.

Before routing, minimize or redact data where possible and reject a route that violates the tenant's provider or residency policy. Apply per-tenant quotas, timeouts, concurrency limits, and cost estimates. Track end-to-end and per-model latency, errors, token use, and cost. The hosted provider and fine-tuned endpoint should have explicit versions and health checks.

Fallback must be capability- and policy-aware, not simply “try the other model.” If the primary is unavailable, route only to a pre-approved model that is allowed to receive that data and meets minimum quality; otherwise use a deterministic response, queue the request, or fail clearly. Avoid retry storms and duplicate tool side effects; use circuit breakers and bounded retries. Evaluate each route and fallback for quality, safety, and latency, then canary routing changes and retain rollback controls.

### 46. [Practice prompt] Design a production monitoring system for a GenAI application using traces, evaluation scorers, usage data, and user feedback. How do you sample, alert, protect privacy, and investigate regressions?

**Answer:**

I would build monitoring around separate signals for service health, AI behavior, and user outcomes. Service metrics include availability, error/timeout rates, latency percentiles, queue depth, token use, and cost. AI-quality signals include retrieval/index freshness, citation validity, tool success, safety/authorization denials, and sampled scorer results. User feedback and task outcomes should be captured as distinct signals with their own coverage and bias limitations.

I would trace all requests with minimal metadata, while sampling or redacting payload content according to sensitivity and debugging needs. Apply retention limits and strict access controls to any stored prompt, completion, or retrieved text. For quality scorers, use stratified sampling across tenants, task types, languages, and model routes rather than only sampling the easiest or most frequent cases. Maintain a versioned offline regression set and compare online samples against it.

Alerts should map to actionable thresholds: SLO violations, unusual cost/token spikes, retrieval lag, rising tool failures, safety incidents, or a quality regression on a critical slice. Avoid paging on noisy individual scores; aggregate with adequate sample size and route high-risk events to the right owner. For an investigation, correlate traces with model/prompt/index versions, deployment changes, and traffic mix; replay sanitized cases where possible; identify the failing component; then create a regression test and canary the fix with rollback criteria.

### 47. [Practice prompt] Design a safe model and index migration that keeps the current application available while the new embedding model and vector index are built and validated.

**Answer:**

I would treat the model and index as a versioned release pair. Keep the existing embedding model/index serving production while creating a separate target pipeline and index for the new embedding model. Backfill from the governed source/chunk table with stable source versions, idempotent writes, and explicit progress tracking; then keep the target index current with changes arriving during the backfill.

Before traffic moves, validate coverage, embedding dimensions/version consistency, deletion and permission propagation, retrieval recall/ranking, citations, latency, and cost. Use held-out evaluation data and representative query slices. If feasible, run shadow retrieval on production-like queries, but do not expose shadow results or let them trigger side effects.

After the target is complete and meets release gates, canary a small traffic fraction or use an alias/configuration switch. Monitor quality and operational metrics and compare against the old index. Keep the old model/index intact for rapid rollback until the new path is stable. Roll back the pair together if needed; avoid a mixed state where query embeddings are generated by one model and the index contains vectors from another. Retire the old assets only after the rollback window, lineage, and data-retention requirements are satisfied.

### 48. [Practice prompt] A customer requires all inference traffic to use approved model providers, with per-team spend limits and auditable access to tools. Design the control plane and explain enforcement points.

**Answer:**

I would create a control plane for provider/model allowlists, team ownership, budgets, rate limits, tool permissions, and audit/retention policies. Changes should be versioned, reviewed, and attributable to an authorized administrator. The data plane should not accept a client-selected provider or tool as authoritative; it should resolve the permitted configuration from the authenticated user/team and policy service.

Enforcement belongs at multiple trusted points: an API gateway authenticates the caller and applies quotas; a model-routing gateway rejects unapproved providers and records model/version, usage, and cost; tool adapters authorize each call against the user's and service identity's permissions; and the underlying data/API systems enforce their own access controls. Use short-lived, least-privilege credentials held outside prompts and model-visible content. Add per-team budgets with warning thresholds, hard caps, and a defined safe response when exhausted.

For auditability, record principal/team, policy version, model/provider, request/run ID, tool name and authorization outcome, usage/cost, and status, while minimizing sensitive payload content. Reconcile usage with provider billing and alert on anomalies. Test policy bypass attempts, unknown providers, missing identity, budget exhaustion, revoked permissions, and indirect tool access through agents. Policy service failure should fail closed for prohibited routes/actions, with a transparent user-facing error rather than silently using an unapproved provider.

### 49. [Practice prompt] Design a document ingestion and question-answering platform for sensitive data across multiple business units. Identify the trust boundaries and explain how you prevent cross-tenant retrieval and accidental exposure in logs.

**Answer:**

I would identify trust boundaries between source systems, ingestion workers, governed storage, indexes, the application API, model provider, tools, telemetry, and human operators. Each business unit should have an explicit data owner, classification, retention policy, and access model. Ingestion should preserve source identifiers and permissions, validate content, and create versioned chunks; indexes should be partitioned or filtered according to the required isolation strength.

At query time, authenticate the user, resolve business-unit membership from a trusted identity provider, and apply authorization before retrieval. The model should receive only the minimum authorized context. Enforce tenant boundaries in the storage/index layer and again in application policy; never rely solely on a tenant ID from the prompt or on the model to avoid cross-tenant content. Tools should use scoped credentials and recheck permissions for every action.

For logs, default to metadata-only traces; redact or avoid prompts, completions, and retrieved passages. Apply encryption, strict role-based access, retention/deletion controls, and audit access to sensitive diagnostics. Where content capture is necessary for an investigation, use an approved, time-limited process with explicit access and redaction.

I would test cross-tenant retrieval, permission revocation, stale index ACLs, prompt injection, misconfigured service identities, cached responses crossing user boundaries, and log/trace exposure. Monitor authorization denials and unexpected access patterns, conduct periodic access reviews, and define incident response for accidental disclosure.

## G. Troubleshooting and customer scenarios

### 50. [Practice prompt] Users report that answers are relevant but omit key facts. How would you isolate chunking, retrieval coverage, context assembly, generation, and answer validation as possible causes?

**Answer:**

I would take representative queries with a human-identified expected answer and trace each stage, rather than immediately rewrite the prompt. First verify the source contains the missing fact and that the correct version was ingested. Then inspect chunk boundaries and metadata to see whether the fact is split, dropped, or detached from its context.

Next, measure retrieval recall: does the expected passage appear among candidates, and where does it rank? If not, investigate query formulation, filters, lexical/vector/hybrid settings, and reranking. If it is retrieved, inspect the final assembled context for truncation, ordering, deduplication, or token-budget issues. If the evidence reaches the model but the answer omits it, test prompt clarity, competing evidence, model choice, and decoding behavior. Finally, check output post-processing or schema validation to ensure a generated fact is not being removed.

I would use stage-specific metrics and a small set of controlled interventions to localize the cause. Add the failure to regression tests at the right level—retrieval, context assembly, or end-to-end—and compare answer completeness, grounding, latency, and cost after the fix. Keep citations so users and reviewers can verify whether the important evidence was available.

### 51. [Practice prompt] Search quality regresses after a source schema change, although the embedding model did not change. What lineage, index synchronization, metadata, and query-path checks would you make?

**Answer:**

I would compare the last known-good and current source schema, ingestion code, chunker, metadata mappings, index configuration, and query filters. A stable embedding model does not guarantee stable retrieval if the text field, identifier normalization, chunk boundaries, or metadata fields changed.

Check source-to-chunk lineage and row counts; confirm parsing did not omit or rename content; inspect null rates, text lengths, and key distributions; and compare representative chunk text and metadata before and after the change. Verify the index schema and synchronization status, including whether new/renamed fields are populated and whether deletes or updates were applied. Look for lag, failed syncs, stale index versions, or a partial deployment.

On the query path, inspect query construction, selected text/vector columns, metadata filters, tenant/access predicates, ranking configuration, and any reranker. Replay a fixed set of queries against the previous and current index snapshots, measuring retrieval recall and ranking by query category. If possible, shadow the new path before switching traffic.

I would roll back the source or index mapping if the regression impacts users, then fix the transformation or query contract and add schema compatibility tests. Preserve lineage linking source schema version, pipeline code, chunker, embedding model, index version, and query configuration so the next change is diagnosable.

### 52. [Practice prompt] A deployment works for developers but fails for some production users with permission errors. How would you distinguish application identity, user identity, catalog grants, endpoint permissions, and workspace configuration issues?

**Answer:**

I would reproduce with a failing user and a known-good user, then trace the request's identities and each authorization hop. Determine how the user authenticates, what identity the application uses to call data and model services, whether user identity is passed through or represented by a service principal, and which permissions are expected to apply at each layer.

Check catalog/schema/table and function grants, row/column policies, model or endpoint permissions, workspace/service-principal configuration, and environment-specific secrets or network settings. Compare effective permissions rather than just role names, and inspect audit/error logs for the denied principal and resource. Confirm that the deployment is using the intended workspace, catalog, endpoint, and policy version—not a developer default.

I would test the same operation using a least-privilege service identity and representative end-user identities. Avoid fixing the issue with broad grants; identify the missing permission or incorrect identity mapping and apply the narrowest correction. If per-user data access is required, ensure that service-principal access does not bypass the end user's policy. Add deployment integration tests for allowed and denied users and verify the behavior after permission revocation.

### 53. [Practice prompt] A production agent is making repeated tool calls and exceeding its token budget. How would you use traces to find the loop and add controls without masking the underlying reasoning failure?

**Answer:**

I would inspect traces by run ID and reconstruct the sequence of model decisions, tool names, normalized arguments, tool results, retries, and token usage. Look for repeated identical calls, alternating calls with no state change, repeated tool errors, oversized tool outputs, or planning that fails to recognize completion. Compare the loop across prompt/model versions and task types, and determine whether the tool result itself is ambiguous or malformed.

I would add protective bounds immediately—maximum steps, wall-clock deadline, token/spend budget, per-tool retry limits, and detection of repeated tool/argument pairs. On limit exhaustion, stop safely, preserve the run state, and return a clear partial result or escalation rather than silently claiming success. Truncate or summarize large tool outputs with provenance and limits, not by dropping critical evidence without notice.

Then address the cause: improve tool schemas and result contracts, expose progress/state to the planner, handle errors deterministically, or replace a predictable portion of the plan with a fixed workflow. Add regression tests that reproduce the loop and verify both that the agent terminates and that it does not stop prematurely on valid multi-step tasks. Track loop rate and budget-exhaustion outcomes after rollout.

### 54. [Practice prompt] The application is suddenly over budget, but request volume is unchanged. How would you investigate model routing, prompt size, retries, output length, cache behavior, and tenant-level usage?

**Answer:**

I would decompose spend into request count multiplied by cost per request, then compare the affected period with a baseline by tenant, route, model, and task. Verify pricing/configuration changes and billing reconciliation first. With traffic flat, inspect whether more requests are being sent to a higher-cost model, fallback or retry attempts have increased, or one tenant is consuming a disproportionate share.

Break token usage into input and output: prompt templates, conversation history, retrieved context, tool outputs, and system instructions can increase input tokens; longer completions or changed output limits can increase output tokens. Check whether caching hit rates changed, cache keys/prefixes stopped matching, or repeated calls bypass caching. Also inspect agent steps and parallel calls, since request count at the application layer may hide multiple model calls per user request.

Use traces and usage data with privacy controls to identify the change point, then test a targeted fix—routing policy, context trimming, retrieval limits, retry policy, output bounds, caching, or per-tenant budgets. Do not reduce context blindly if it harms grounding or safety. Canary the change and measure cost per successful task, quality, latency, and error rate, with alerts for both aggregate and per-tenant budget thresholds.

### 55. [Practice prompt] A provider outage causes cascading failures in an agent workflow. What should fail over, what should fail closed, and how would you preserve request state and communicate partial completion?

**Answer:**

I would classify dependencies and actions by policy and consequence. Model calls may fail over to a pre-approved provider only if the request's data classification, residency rules, model capability, and quality requirements permit that route. Otherwise, fail closed for the inference path. Authorization, policy checks, and safety controls must never be bypassed during an outage. Read-only retrieval might continue if it is independently healthy, but no consequential tool action should proceed based on an incomplete or unvalidated plan.

Use timeouts, circuit breakers, bounded retries with jitter, and admission control to stop the outage from causing a retry storm. Persist the workflow state, completed steps, pending actions, and idempotency keys so the run can resume safely. Mark each step as completed, failed, or uncertain; reconcile uncertain external side effects before retrying.

The user should receive an honest status: what completed, what did not, whether any external action may have occurred, and whether the system will retry or needs user action. Do not present partial work as complete. Provide a run ID or status endpoint for background recovery, notify operators when SLOs or safety conditions require it, and canary failover policy changes before broad rollout.

### 56. [Practice prompt] An executive asks you to remove authorization checks because they lower answer quality. How would you demonstrate the trade-off and propose a safe alternative?

**Answer:**

I would acknowledge the quality concern, but I would not remove a control that protects confidential data. First, I would make the trade-off measurable: compare answer quality and task completion with the current permission-aware retrieval against the proposed broader retrieval, while separately testing unauthorized retrieval and cross-tenant exposure. That demonstrates whether the quality gap comes from missing access to useful documents, stale entitlements, poor metadata, or retrieval/ranking problems.

Then I would propose safe ways to improve quality: fix permission metadata and synchronization, improve chunking and hybrid retrieval, expose a user-appropriate source catalog, make access requests easier, or let an authorized user explicitly switch to a broader approved scope. We can also return a clear explanation when relevant evidence is inaccessible rather than silently retrieving it. Any change should be approved by the data owners/security stakeholders and preserve the principle that the caller only receives information they are authorized to see.

I would present decision-makers with the quality gain, risk, affected data, and alternatives, and recommend a measured pilot with explicit security and quality gates. If authorization cannot be verified, the system must fail closed. Better answers do not justify bypassing access controls.

## H. Behavioral and project deep-dive practice

Databricks' public behavioral guidance recommends using real examples. Adapt these prompts to your own experience; do not present invented stories as personal work.

### 57. [Practice prompt] Tell me about a time you took an ambiguous AI or data problem from discovery through production. How did you define success, manage risk, and measure impact?

**Answer:**

I would answer this with a real project and make my own contribution explicit. A strong structure is:

“In **[team/project]**, users were struggling with **[specific workflow and evidence of the problem]**. The initial request was broad—**[original ambiguous ask]**—so I worked with **[users/partners]** to map the workflow and agree on a measurable goal: **[baseline and target]**. I tested whether AI was appropriate by comparing it with **[simpler baseline]**, then built **[specific architecture or smallest useful slice]**.

“I owned **[your concrete responsibilities]** and partnered with **[teams]** on **[data, security, product, or operations]**. To manage risk, I added **[evaluation, permission controls, fallback, human review, or staged rollout]**. We launched to **[scope]**, monitored **[quality, adoption, latency, cost, safety, or reliability measures]**, and saw **[verifiable result]**. The hardest issue was **[actual failure or trade-off]**; I addressed it by **[action and evidence]**. Looking back, I would **[specific improvement]**.”

I would avoid vague claims such as “the AI improved productivity” without a baseline, measurement method, and my role. If the project did not reach production, say so and explain what was validated and what remained unresolved.

### 58. [Practice prompt] Describe a time an evaluation result or user report contradicted your team's belief that a model feature was ready. What did you do?

**Answer:**

I would use a real example and show that I treated contradictory evidence as a reason to investigate rather than defend the prototype:

“We believed **[feature]** was ready because **[evidence the team initially relied on]**. Before/after **[test or pilot]**, evaluation or users showed **[specific contrary result]**, especially for **[task/user slice]**. I first checked whether the signal was reliable by reviewing **[sample size, metric definition, traffic mix, or evaluator agreement]**. Then I examined representative failures and found **[root cause, if known]**.

“I recommended **[pause, narrow launch, rollback, or targeted change]** and explained the user impact and trade-off to **[stakeholders]**. We changed **[system/component]**, added **[regression case or monitoring]**, and retested using **[method]**. The result was **[measured outcome]**. The lesson I took away was **[how your approach changed]**.”

The strongest answer includes a concrete example of being willing to change course, a method for validating the signal, and a specific follow-up. I would not invent metrics or claim sole credit for a team result.

### 59. [Practice prompt] Tell me about a production incident involving data quality, model behavior, or a dependency. How did you communicate, mitigate impact, and prevent recurrence?

**Answer:**

I would describe an actual incident using a clear timeline and separate containment from root-cause prevention:

“During **[service/project]**, we detected **[user-visible symptom]** through **[alert, trace, or report]**. I was responsible for **[your role]**. I first assessed scope and impact—**[which users/data/workflows were affected]**—and communicated what we knew, what we did not yet know, and when stakeholders would hear from us again. To limit harm, we **[disabled a feature, rolled back, restricted traffic, served a fallback, or corrected data]**.

“The root cause was **[verified cause]**, not just the first visible symptom. We confirmed it using **[logs/evaluation/data lineage/reproduction]**. After recovery, I led or contributed to **[code/data/process change]**, added **[test/alert/runbook/ownership]**, and verified the fix under **[test or canary]**. The incident resulted in **[impact and learning]**.”

I would be candid about uncertainty and any mistakes, avoid blaming individuals, and distinguish confirmed facts from hypotheses. A strong close explains how recurrence became less likely and how recovery became faster.

### 60. [Practice prompt] Describe a technical disagreement about architecture or reliability. How did you reach a decision and what evidence changed your view?

**Answer:**

I would choose a real disagreement where the other person's concerns were represented fairly:

“On **[project]**, we disagreed about **[specific design choice]**. I initially favored **[your position]** because **[reasons]**, while **[colleague/team]** emphasized **[their valid concern]**. Rather than turning it into a preference debate, we agreed on decision criteria: **[correctness, reliability, latency, cost, maintainability, or delivery risk]**.

“We compared options using **[prototype, load test, threat model, failure analysis, or user evidence]**. The evidence showed **[what was learned]**, which changed or confirmed my view. We chose **[decision]**, documented the trade-offs and revisit conditions, and delivered **[outcome]**. I maintained a constructive working relationship because the goal was the best solution, not winning the argument.”

I would be specific about what evidence changed my mind—or explain respectfully why I still disagreed and how the team reached a decision. Avoid portraying collaboration as simply persuading others to accept your original idea.

### 61. [Practice prompt] Tell me about a time you had to reduce scope or choose a simpler approach to deliver a reliable result. What did you defer, and how did you validate the trade-off?

**Answer:**

I would use a real case where scope reduction protected the outcome rather than just the schedule:

“We planned **[original scope]**, but **[constraint or evidence]** made it risky to deliver reliably by **[deadline]**. I helped identify the essential user outcome, **[must-have capability]**, and separated it from **[deferred capabilities]**. We chose **[simpler architecture or narrower launch]** because it reduced **[specific complexity or risk]** while preserving **[core value]**.

“I made the trade-off explicit to **[stakeholders/users]**, including what the initial version would not do and how users could handle those cases. We validated it with **[tests, pilot, evaluation, or baseline comparison]** and monitored **[success and guardrail metrics]**. The result was **[verifiable outcome]**. We later revisited deferred work based on **[evidence]**, rather than assuming it had to be built.”

For AI features, a good example may be choosing a single RAG call over an agent, limiting the document corpus, or keeping a human approval step. I would use only an example that reflects my actual decisions and results.

### 62. [Practice prompt] Walk through a project you personally built. Which parts did you implement, what alternatives did you reject, what failed, and what would you change now?

**Answer:**

I would choose a project with enough technical depth to explain decisions and outcomes. A concise walkthrough could follow this sequence:

1. **Problem and users:** “The project was **[what you built]** for **[users]**, addressing **[specific need]**. Success meant **[measurable goal]**.”
2. **My contribution:** “I personally implemented **[components/decisions]**. **[Collaborators]** owned **[their distinct work]**.”
3. **Architecture:** “The main path was **[data/input → application → model/retrieval/tools → validation → user/output]**. The important trust or failure boundary was **[boundary]**.”
4. **Alternatives:** “We considered **[alternative A/B]**. We chose **[selected approach]** because **[evidence and constraints]**, accepting **[trade-off]**.”
5. **Failure and iteration:** “Initially **[what failed]**. We diagnosed it through **[evidence]**, changed **[component]**, and added **[test or monitoring]**.”
6. **Outcome and reflection:** “We measured **[baseline → result]** using **[method]**. I would now change **[specific improvement]** because **[lesson].”

I would be ready to drill into implementation, evaluation design, security, production operations, and my own decisions. If the project was a prototype rather than a production launch, I would say so clearly and distinguish measured results from expected impact. Replace every bracketed item with truthful details; do not present this template as a personal story.

## Final readiness checklist

- I can explain a concrete AI project end-to-end, including decisions, failure cases, measurable outcomes, and my own contribution.
- I can design a governed RAG or agent application without treating prompts as an authorization boundary.
- I can separate retrieval quality, answer quality, safety, latency, and cost in an evaluation plan.
- I can reason about data freshness, idempotency, permissions, model/index versioning, and production rollback.
- I can solve coding problems aloud, test edge cases, and state time and space complexity.
- I have at least five truthful behavioral stories that show ownership, collaboration, learning, and customer impact.
- I have checked the exact role scope and confirmed current interview format with the recruiter.

## Research references

### Official Databricks sources

- [Engineering at Databricks](https://www.databricks.com/company/careers/engineering-at-databricks) — product/engineering scope and a role-dependent interview-process outline.
- [Databricks interview preparation](https://www.databricks.com/company/careers/interview-prep) — official behavioral guidance and candidate preparation advice.
- [Develop agents on Databricks](https://docs.databricks.com/aws/en/agents/) — agent development, memory, tools, deployment, tracing, evaluation, and governance.
- [Agent Runtime](https://docs.databricks.com/aws/en/agents/deploy/agent-runtime) — deployment identity, durability, tracing, and scaling concepts.
- [Databricks AI Search](https://docs.databricks.com/aws/en/ai-search/ai-search) — indexes, hybrid retrieval, filters, reranking, and synchronization.
- [Unity Catalog](https://docs.databricks.com/aws/en/data-governance/unity-catalog/) — governance, access control, lineage, and data/AI securable objects.
- [Unity Gateway](https://docs.databricks.com/aws/en/ai-gateway/) — AI service governance, routing, rate limits, budgets, policies, and usage monitoring.
- [MLflow GenAI tracing](https://docs.databricks.com/aws/en/mlflow3/genai/tracing/overview) — trace structure and production observability.
- [MLflow GenAI evaluation](https://docs.databricks.com/aws/en/mlflow3/genai/eval-monitor/) — scorers, evaluation runs, and production monitoring.
- [MLflow scorers and LLM judges](https://docs.databricks.com/aws/en/mlflow3/genai/eval-monitor/concepts/scorers) — evaluation scorer concepts.
- [Machine learning on Databricks](https://docs.databricks.com/aws/en/machine-learning) — training, serving, monitoring, and MLOps lifecycle.

### Public candidate-reconstruction reference

- [Dark Interview Questions — Databricks directory](https://github.com/harry-the-nerd/interview-notes-questions/tree/main/databricks) — the repository states its questions are reconstructed from publicly shared candidate experiences and lists coding/system design examples. This is anecdotal, not an official Databricks source. Its custom license restricts redistribution; this guide does not reproduce its problem statement, solution, or code.
