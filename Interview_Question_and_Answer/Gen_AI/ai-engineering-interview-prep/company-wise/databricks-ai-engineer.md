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

<br><br><br>

### 2. [Practice prompt] Explain how governed source data, model development, evaluation, deployment, and monitoring can form one lifecycle. Where are the important interfaces and failure boundaries?

**Answer:**

<br><br><br>

### 3. [Practice prompt] A customer asks to build a chatbot over internal documents. What questions would you ask before choosing RAG, fine-tuning, an agent, or a simpler search-and-summary workflow?

**Answer:**

<br><br><br>

### 4. [Practice prompt] How would you explain the value and limitations of Databricks AI Search, MLflow GenAI, Unity Catalog, and model serving to a technical customer without turning the answer into a product-feature list?

**Answer:**

<br><br><br>

### 5. [Practice prompt] A team wants to move an experimental notebook into a supported production service. What must change in the code, data controls, deployment process, and operational ownership?

**Answer:**

<br><br><br>

### 6. [Practice prompt] How would you decide whether a requirement belongs in a data pipeline, a retrieval layer, an application service, or the model prompt?

**Answer:**

<br><br><br>

## B. Governed data and retrieval on Databricks

### 7. [Practice prompt] Design a RAG ingestion pipeline for frequently updated enterprise documents stored in Delta tables. Cover incremental updates, deletions, chunk identity, embedding refresh, and recovery after partial failure.

**Answer:**

<br><br><br>

### 8. [Practice prompt] How would you choose between vector similarity, keyword search, and hybrid retrieval for a corpus containing both prose and exact product codes?

**Answer:**

<br><br><br>

### 9. [Practice prompt] An AI Search index returns semantically related passages but misses exact names, identifiers, and version numbers. How would you investigate and improve retrieval?

**Answer:**

<br><br><br>

### 10. [Practice prompt] How would you apply metadata filters and authorization checks so a RAG query cannot retrieve records the requesting user is not allowed to see?

**Answer:**

<br><br><br>

### 11. [Practice prompt] A source Delta table changes while the search index is synchronizing. What freshness and consistency guarantees would you expose to the application, and how would you detect indexing lag?

**Answer:**

<br><br><br>

### 12. [Practice prompt] Design a document-chunk schema for retrieval. Which fields are required for citations, filtering, updates, access control, and debugging, and which should not be embedded?

**Answer:**

<br><br><br>

### 13. [Practice prompt] A customer requires row-level and column-level restrictions in natural-language analytics. How would you preserve those restrictions across question interpretation, query generation, execution, and answer generation?

**Answer:**

<br><br><br>

### 14. [Practice prompt] How would you use Unity Catalog concepts to govern tables, models, functions, and AI services consistently across development and production?

**Answer:**

<br><br><br>

### 15. [Practice prompt] A RAG system is accurate in a developer workspace but leaks or omits data after deployment under a service identity. How would you reason about user identity, service-principal permissions, and least privilege?

**Answer:**

<br><br><br>

## C. GenAI applications, agents, and evaluation

### 16. [Practice prompt] Design an enterprise knowledge assistant that uses Databricks AI Search. Walk through ingestion, retrieval, generation, citations, authorization, evaluation, and production monitoring.

**Answer:**

<br><br><br>

### 17. [Practice prompt] When is an agent justified over a deterministic workflow or a single RAG call? Define the evidence you would require before adding tool use and multi-step planning.

**Answer:**

<br><br><br>

### 18. [Practice prompt] An agent can call SQL, search, and an external API. How would you design tool schemas, permission checks, confirmation for consequential actions, and bounded execution?

**Answer:**

<br><br><br>

### 19. [Practice prompt] How would you persist conversation sessions and longer-term agent memory while supporting privacy, deletion, tenant isolation, and recovery after a worker restart?

**Answer:**

<br><br><br>

### 20. [Practice prompt] What information should a GenAI trace capture for a multi-step agent, and how would you use traces to reproduce a failure without indiscriminately retaining sensitive prompts or retrieved content?

**Answer:**

<br><br><br>

### 21. [Practice prompt] Build an evaluation plan for a production RAG agent. Separate retrieval, response quality, groundedness, tool behavior, safety, and operational measures; explain which checks should be deterministic.

**Answer:**

<br><br><br>

### 22. [Practice prompt] How would you combine human feedback, LLM judges, code-based scorers, and fixed test examples in a repeatable evaluation workflow? How would you validate that a judge is useful?

**Answer:**

<br><br><br>

### 23. [Practice prompt] A new prompt improves judge scores but worsens customer task completion. What additional evidence would you inspect before deciding whether to release it?

**Answer:**

<br><br><br>

### 24. [Practice prompt] How would you compare two model versions using the same production-like workload while controlling for nondeterminism, traffic mix, latency, and inference cost?

**Answer:**

<br><br><br>

### 25. [Practice prompt] A model produces valid structured output that is syntactically correct but refers to nonexistent records. Where would you validate the response, and how would you prevent invalid output from causing a side effect?

**Answer:**

<br><br><br>

### 26. [Practice prompt] How would you use MLflow traces, evaluation results, and production feedback as a learning loop from observed failure to regression test to safely deployed fix?

**Answer:**

<br><br><br>

### 27. [Practice prompt] How would you test prompt injection contained in retrieved enterprise documents when the agent also has tools that can access governed data?

**Answer:**

<br><br><br>

## D. Data and ML engineering fundamentals

### 28. [Practice prompt] A streaming source delivers duplicate and late events used to refresh an AI Search index. How would you design an idempotent Delta pipeline and define the freshness contract?

**Answer:**

<br><br><br>

### 29. [Practice prompt] A Spark job generating embeddings is slow and occasionally exhausts memory. How would you profile and improve it without hiding data skew behind an arbitrary increase in cluster size?

**Answer:**

<br><br><br>

### 30. [Practice prompt] When would you use Spark-native transformations, vectorized UDFs, or an external model endpoint for embedding generation? Compare throughput, serialization, cost, and operational complexity.

**Answer:**

<br><br><br>

### 31. [Practice prompt] How would you design a backfill that recomputes embeddings after changing the embedding model while keeping the currently served index available?

**Answer:**

<br><br><br>

### 32. [Practice prompt] What is the difference between tracking an experiment and governing a production model artifact? Describe how you would make the model, code, data, and evaluation lineage auditable.

**Answer:**

<br><br><br>

### 33. [Practice prompt] How would you choose between online serving, batch inference, and streaming inference for a model-backed feature with both interactive and large-scale workloads?

**Answer:**

<br><br><br>

### 34. [Practice prompt] A model endpoint has good average latency but poor p99 latency under concurrent requests. Which measurements and workload characteristics would you inspect, and what mitigation would you test first?

**Answer:**

<br><br><br>

## E. Coding and practical exercises

The public candidate-reconstruction source provides a weak signal for coding-round practice, including graph/grid traversal. The exercises below are original practice prompts and are not copied from that source.

### 35. [Practice prompt] Given a directed dependency graph for document-processing jobs, return a valid execution order or report a cycle. Explain your complexity and how you would test edge cases.

**Answer:**

<br><br><br>

### 36. [Practice prompt] Write a Python function that groups incoming document updates by stable document ID and returns only the latest valid version, handling duplicate timestamps and deletions deterministically.

**Answer:**

<br><br><br>

### 37. [Practice prompt] Design a chunking function that respects document boundaries where possible, applies a token budget and overlap, and preserves source offsets and metadata for citations.

**Answer:**

<br><br><br>

### 38. [Practice prompt] Given retrieval results with scores, source IDs, and access labels, implement a selection step that filters unauthorized results, removes duplicates, and applies a bounded context budget.

**Answer:**

<br><br><br>

### 39. [Practice prompt] Implement an idempotent batch-processing pattern for embedding records so that retrying a failed partition cannot create duplicate or stale index entries.

**Answer:**

<br><br><br>

### 40. [Practice prompt] Given per-request traces containing model, tenant, token count, latency, and outcome, calculate cost and quality summaries by tenant without allowing missing fields or failed requests to corrupt aggregate metrics.

**Answer:**

<br><br><br>

### 41. [Practice prompt] You are given a grid of blocked and traversable cells and need the shortest route from a start to a destination. Explain the algorithm, data structures, complexity, and how you would extend it when edges have different costs.

**Answer:**

<br><br><br>

## F. System-design practice

### 42. [Practice prompt] Design a multi-tenant enterprise RAG service on Databricks for thousands of customers, each with different document volumes, access policies, freshness needs, and model budgets.

**Answer:**

<br><br><br>

### 43. [Practice prompt] Design a governed natural-language-to-SQL assistant over Unity Catalog data. Cover schema discovery, query generation, SQL validation, authorization, execution limits, result explanation, and auditability.

**Answer:**

<br><br><br>

### 44. [Practice prompt] Design an agent service that must survive worker restarts and support synchronous, streaming, and background tasks. What state is durable, how are runs resumed, and how do you avoid repeating side effects?

**Answer:**

<br><br><br>

### 45. [Practice prompt] Design a model-serving architecture that routes between a hosted foundation model and a fine-tuned model while enforcing latency objectives, cost budgets, privacy boundaries, and a fallback policy.

**Answer:**

<br><br><br>

### 46. [Practice prompt] Design a production monitoring system for a GenAI application using traces, evaluation scorers, usage data, and user feedback. How do you sample, alert, protect privacy, and investigate regressions?

**Answer:**

<br><br><br>

### 47. [Practice prompt] Design a safe model and index migration that keeps the current application available while the new embedding model and vector index are built and validated.

**Answer:**

<br><br><br>

### 48. [Practice prompt] A customer requires all inference traffic to use approved model providers, with per-team spend limits and auditable access to tools. Design the control plane and explain enforcement points.

**Answer:**

<br><br><br>

### 49. [Practice prompt] Design a document ingestion and question-answering platform for sensitive data across multiple business units. Identify the trust boundaries and explain how you prevent cross-tenant retrieval and accidental exposure in logs.

**Answer:**

<br><br><br>

## G. Troubleshooting and customer scenarios

### 50. [Practice prompt] Users report that answers are relevant but omit key facts. How would you isolate chunking, retrieval coverage, context assembly, generation, and answer validation as possible causes?

**Answer:**

<br><br><br>

### 51. [Practice prompt] Search quality regresses after a source schema change, although the embedding model did not change. What lineage, index synchronization, metadata, and query-path checks would you make?

**Answer:**

<br><br><br>

### 52. [Practice prompt] A deployment works for developers but fails for some production users with permission errors. How would you distinguish application identity, user identity, catalog grants, endpoint permissions, and workspace configuration issues?

**Answer:**

<br><br><br>

### 53. [Practice prompt] A production agent is making repeated tool calls and exceeding its token budget. How would you use traces to find the loop and add controls without masking the underlying reasoning failure?

**Answer:**

<br><br><br>

### 54. [Practice prompt] The application is suddenly over budget, but request volume is unchanged. How would you investigate model routing, prompt size, retries, output length, cache behavior, and tenant-level usage?

**Answer:**

<br><br><br>

### 55. [Practice prompt] A provider outage causes cascading failures in an agent workflow. What should fail over, what should fail closed, and how would you preserve request state and communicate partial completion?

**Answer:**

<br><br><br>

### 56. [Practice prompt] An executive asks you to remove authorization checks because they lower answer quality. How would you demonstrate the trade-off and propose a safe alternative?

**Answer:**

<br><br><br>

## H. Behavioral and project deep-dive practice

Databricks' public behavioral guidance recommends using real examples. Adapt these prompts to your own experience; do not present invented stories as personal work.

### 57. [Practice prompt] Tell me about a time you took an ambiguous AI or data problem from discovery through production. How did you define success, manage risk, and measure impact?

**Answer:**

<br><br><br>

### 58. [Practice prompt] Describe a time an evaluation result or user report contradicted your team's belief that a model feature was ready. What did you do?

**Answer:**

<br><br><br>

### 59. [Practice prompt] Tell me about a production incident involving data quality, model behavior, or a dependency. How did you communicate, mitigate impact, and prevent recurrence?

**Answer:**

<br><br><br>

### 60. [Practice prompt] Describe a technical disagreement about architecture or reliability. How did you reach a decision and what evidence changed your view?

**Answer:**

<br><br><br>

### 61. [Practice prompt] Tell me about a time you had to reduce scope or choose a simpler approach to deliver a reliable result. What did you defer, and how did you validate the trade-off?

**Answer:**

<br><br><br>

### 62. [Practice prompt] Walk through a project you personally built. Which parts did you implement, what alternatives did you reject, what failed, and what would you change now?

**Answer:**

<br><br><br>

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
