# Google DeepMind — AI / ML Engineer Interview Bank

**Research snapshot:** October 31, 2026  
**Target:** AI and machine-learning engineers working on frontier models, Gemini products and APIs, multimodal or agentic systems, AI infrastructure, or research-to-product applications at Google DeepMind and adjacent Google AI teams. These are related but not interchangeable organizations or role scopes; the exact job description and hiring team should guide preparation.

Google DeepMind's public careers page describes a general process of an introductory recruiter conversation, potentially including a hiring-manager interview, two or three skills interviews, and final interviews with team leads and leadership. The competencies, interview content, and sequence vary by role. The official sources reviewed do not publish a definitive AI Engineer question bank. The prompts below are original practice questions informed by official public material; they are **not represented as verbatim or guaranteed interview questions**.

## Research signals and confidence

### Officially documented

- Google DeepMind describes work across frontier-model research and products such as Gemini, Veo, and image generation, supported by a full-stack approach spanning research, custom chips, large-scale training infrastructure, and global deployment.
- Its public research and model pages cover areas including Gemini, multimodal models, robotics, world models, agents, and scientific applications such as AlphaFold.
- Gemini API documentation describes production capabilities including structured outputs, function calling, long-context input, grounding and other tools, streaming, batch processing, caching, and real-time audio/video interactions through the Live API.
- Google's agent documentation describes managed agent environments and calls out sandboxing, network restrictions, least-privilege credentials, and human verification of agent work.
- Google DeepMind's careers page describes an interview process at a high level. It does not specify a universal technical loop for every AI/ML role.

### Publicly reported material

This guide does not assert any unverified candidate-recalled question as a current, Google DeepMind-specific interview question. General Google interview anecdotes can be team-, level-, location-, and date-specific and should not be used to infer the loop for a Google DeepMind research or product role.

### Confidence labels

- **Official context:** supported by Google DeepMind careers, research, product, safety, or Google AI developer documentation.
- **Reported signal:** a third-party account of a candidate experience; anecdotal and not official. No role-specific question report is asserted in this guide.
- **Practice prompt:** an original question synthesized from the target engineering scope and official public material.

## How to use this bank

1. Read the exact job description and determine whether the role is research engineering, model training, applied AI, product/API engineering, infrastructure, robotics, or scientific AI.
2. Ask the recruiter which team owns the role, which competencies are assessed, whether coding uses a particular language or environment, and what preparation material is available. The public process outline is general, not a guarantee of your loop.
3. Prepare one substantial project deep dive: problem, personal contribution, data and model choices, evaluation, engineering trade-offs, launch or research outcome, and what you would change.
4. For research-oriented roles, be ready to reason from first principles, discuss experimental design, and explain how you would distinguish a real improvement from noise or leakage.
5. For product and platform roles, treat the model as one component in a complete system. Discuss product metrics, reliability, latency, cost, privacy, safety, and operations.
6. For every prompt below, state assumptions, identify failure modes, and describe how you would test your claims.

## A. Role understanding, product judgment, and research-to-product work

### 1. [Practice prompt] What does a full-stack AI approach mean in practice, and how should research, model architecture, hardware, serving infrastructure, and product design influence one another?

**Answer:**

<br><br><br>

### 2. [Practice prompt] How would you decide whether a promising model capability is mature enough to become a user-facing product feature?

**Answer:**

<br><br><br>

### 3. [Practice prompt] A research result improves benchmark performance but increases inference cost and latency substantially. How would you determine whether it is valuable for a real product?

**Answer:**

<br><br><br>

### 4. [Practice prompt] How would you turn an ambiguous product request such as “make the assistant better at research” into a scoped engineering or research problem?

**Answer:**

<br><br><br>

### 5. [Practice prompt] When should a product use a frontier model, a smaller specialized model, a conventional software component, or a combination of them?

**Answer:**

<br><br><br>

### 6. [Practice prompt] A feature has strong average quality but performs inconsistently across languages, user groups, or task types. How would you decide whether to launch, limit, or delay it?

**Answer:**

<br><br><br>

### 7. [Practice prompt] How would you define a success metric for an AI capability when user satisfaction, task completion, latency, and model cost move in different directions?

**Answer:**

<br><br><br>

### 8. [Practice prompt] Tell me about a time you translated an uncertain research or prototype result into a dependable engineering outcome. What evidence changed your plan?

**Answer:**

<br><br><br>

## B. Machine-learning and model fundamentals

### 9. [Practice prompt] Explain the main computational and memory costs of transformer inference. How do sequence length, batch size, attention, and KV caching affect them?

**Answer:**

<br><br><br>

### 10. [Practice prompt] Compare pretraining, supervised fine-tuning, preference optimization, and inference-time techniques. What kinds of problems is each suited to address?

**Answer:**

<br><br><br>

### 11. [Practice prompt] How would you investigate a model that performs well on a validation benchmark but poorly on real user requests?

**Answer:**

<br><br><br>

### 12. [Practice prompt] What can scaling laws tell you when planning a training run, and what important decisions or risks do they not settle?

**Answer:**

<br><br><br>

### 13. [Practice prompt] How would you distinguish data quality problems, distribution shift, optimization problems, and evaluation defects when model quality regresses?

**Answer:**

<br><br><br>

### 14. [Practice prompt] Explain how quantization can reduce model serving cost and latency. What accuracy, calibration, hardware, or workload effects would you measure?

**Answer:**

<br><br><br>

### 15. [Practice prompt] What trade-offs would you consider when choosing between dense and mixture-of-experts architectures for a production model?

**Answer:**

<br><br><br>

### 16. [Practice prompt] You observe a model quality change after a data or training-pipeline update. How would you establish whether the change is causal and reproducible?

**Answer:**

<br><br><br>

## C. Gemini API and production AI application engineering

### 17. [Practice prompt] Design a reliable application around a hosted generative-model API. Explain request validation, timeouts, retries, rate limits, streaming, error handling, and observability.

**Answer:**

<br><br><br>

### 18. [Practice prompt] When would you use structured output rather than asking a model for free-form JSON? How would you validate and recover from invalid or semantically incorrect output?

**Answer:**

<br><br><br>

### 19. [Practice prompt] Design a function-calling flow that lets a model look up an order and optionally cancel it. Which steps must remain under deterministic application control?

**Answer:**

<br><br><br>

### 20. [Practice prompt] How would you implement server-side streaming to a web client while handling client disconnects, partial output, cancellation, and upstream errors?

**Answer:**

<br><br><br>

### 21. [Practice prompt] A generative AI endpoint is hitting provider quotas during peak traffic. How would you manage backpressure, admission control, graceful degradation, and user-facing behavior?

**Answer:**

<br><br><br>

### 22. [Practice prompt] How would you manage prompt versions, model versions, safety settings, and rollout configuration so that a production change can be evaluated and rolled back?

**Answer:**

<br><br><br>

### 23. [Practice prompt] What data would you log to debug model quality and service failures, and how would you minimize exposure of user content and sensitive information?

**Answer:**

<br><br><br>

### 24. [Practice prompt] When would you use a batch or background API workflow instead of synchronous inference, and how would you handle idempotency and job recovery?

**Answer:**

<br><br><br>

## D. Multimodal, real-time, and generative systems

### 25. [Practice prompt] Design a real-time voice assistant that supports interruption and tool use. How would you reason about turn-taking, latency, partial transcripts, and cancellation?

**Answer:**

<br><br><br>

### 26. [Practice prompt] A user asks a model about a long video. How would you represent temporal structure and select relevant frames or segments without losing important context?

**Answer:**

<br><br><br>

### 27. [Practice prompt] How would you evaluate an image-generation or image-editing feature for instruction following, visual quality, safety, and consistency?

**Answer:**

<br><br><br>

### 28. [Practice prompt] A multimodal model gives a fluent answer but misses a small, important detail in an image. How would you diagnose whether the issue is perception, resolution, prompt framing, or evaluation?

**Answer:**

<br><br><br>

### 29. [Practice prompt] What additional engineering and safety challenges arise when a model generates video or audio rather than text alone?

**Answer:**

<br><br><br>

### 30. [Practice prompt] How would you design a multimodal benchmark that tests cross-modal grounding rather than merely testing text quality and image recognition separately?

**Answer:**

<br><br><br>

### 31. [Practice prompt] How would you handle a real-time interaction when the model is uncertain, an input modality is degraded, or the connection is unstable?

**Answer:**

<br><br><br>

### 32. [Practice prompt] What provenance or watermarking approach could help users identify generated media, and what limitations should the product communicate?

**Answer:**

<br><br><br>

## E. Agents, tools, grounding, and context

### 33. [Practice prompt] What properties of a task justify an agentic workflow rather than a single model call or deterministic pipeline?

**Answer:**

<br><br><br>

### 34. [Practice prompt] Design a research assistant that uses web search, document retrieval, and code execution. How would you constrain tools and verify its final answer?

**Answer:**

<br><br><br>

### 35. [Practice prompt] How would you protect a tool-using agent from prompt injection in retrieved web pages or uploaded documents?

**Answer:**

<br><br><br>

### 36. [Practice prompt] A model proposes a valid tool call with a dangerous or unauthorized parameter. Where should authorization and validation occur?

**Answer:**

<br><br><br>

### 37. [Practice prompt] How would you decide which information to keep in an agent's context, which to retrieve on demand, and which to discard?

**Answer:**

<br><br><br>

### 38. [Practice prompt] When should an agent ask a user for confirmation before acting? Give a principled way to set confirmation thresholds.

**Answer:**

<br><br><br>

### 39. [Practice prompt] How would you isolate an autonomous coding or browsing agent, restrict its network access, and manage its credentials?

**Answer:**

<br><br><br>

### 40. [Practice prompt] An agent loops through repeated tool calls without making progress. How would you detect, bound, and recover from the loop?

**Answer:**

<br><br><br>

## F. Evaluation, experimentation, and scientific rigor

### 41. [Practice prompt] How would you build an evaluation set for a new assistant feature when user requests are open-ended and change over time?

**Answer:**

<br><br><br>

### 42. [Practice prompt] Compare human evaluation, deterministic tests, model-based judges, and online experiments. What can each establish, and where can each mislead?

**Answer:**

<br><br><br>

### 43. [Practice prompt] How would you test whether an improvement on a benchmark reflects genuine capability rather than contamination, prompt overfitting, or metric gaming?

**Answer:**

<br><br><br>

### 44. [Practice prompt] A model update improves the mean score but causes a small number of severe failures. How would you characterize the distribution and decide what to ship?

**Answer:**

<br><br><br>

### 45. [Practice prompt] How would you design an online experiment for a generative feature when outputs vary between requests and users can be affected by repeated exposure?

**Answer:**

<br><br><br>

### 46. [Practice prompt] How would you combine quality, latency, safety, and cost measurements into a release decision without hiding a serious regression in an aggregate score?

**Answer:**

<br><br><br>

### 47. [Practice prompt] A safety classifier's measured false-negative rate is low overall but substantially higher for one language. What would you investigate and how would you respond?

**Answer:**

<br><br><br>

### 48. [Practice prompt] Describe a rigorous experiment you designed or would design to test an AI hypothesis. How would you control confounders and report uncertainty?

**Answer:**

<br><br><br>

## G. AI infrastructure, training, and serving at scale

### 49. [Practice prompt] Design a high-throughput inference service for a large model. Discuss request scheduling, batching, memory, autoscaling, and tail latency.

**Answer:**

<br><br><br>

### 50. [Practice prompt] A distributed training run has poor accelerator utilization. How would you identify whether the bottleneck is input data, communication, synchronization, kernels, or workload imbalance?

**Answer:**

<br><br><br>

### 51. [Practice prompt] How would you plan fault tolerance and checkpointing for a long-running distributed training job?

**Answer:**

<br><br><br>

### 52. [Practice prompt] How do accelerator memory capacity, interconnect bandwidth, and compute throughput affect model-parallel training and inference choices?

**Answer:**

<br><br><br>

### 53. [Practice prompt] A service meets average latency targets but misses its p99 objective during traffic spikes. How would you diagnose and mitigate the issue?

**Answer:**

<br><br><br>

### 54. [Practice prompt] How would you estimate the cost of serving a model feature before launch and identify the highest-leverage cost optimizations?

**Answer:**

<br><br><br>

### 55. [Practice prompt] How would you deploy a new model safely across a global service with different capacity, latency, and availability constraints?

**Answer:**

<br><br><br>

### 56. [Practice prompt] What signals would you use to detect a silent model-serving regression that does not cause conventional infrastructure alerts?

**Answer:**

<br><br><br>

## H. Safety, privacy, and responsible deployment

### 57. [Practice prompt] How would you build a safety evaluation plan for a new generative capability before launch and after deployment?

**Answer:**

<br><br><br>

### 58. [Practice prompt] How would you balance safety filters that block harmful content against the risk of overblocking benign or educational requests?

**Answer:**

<br><br><br>

### 59. [Practice prompt] A model can answer a high-impact question with persuasive but uncertain content. What product and system controls would you put around the capability?

**Answer:**

<br><br><br>

### 60. [Practice prompt] How would you minimize privacy risks when building personalization or long-term memory into an AI assistant?

**Answer:**

<br><br><br>

### 61. [Practice prompt] How would you evaluate whether a model or safety system treats different demographic or language groups fairly?

**Answer:**

<br><br><br>

### 62. [Practice prompt] What safeguards are appropriate when an AI agent can send messages, modify files, spend money, or control a physical device?

**Answer:**

<br><br><br>

### 63. [Practice prompt] What should a product do when a user reports a harmful model response that the automated monitoring system did not catch?

**Answer:**

<br><br><br>

### 64. [Practice prompt] How would you make AI-generated media provenance understandable and useful without suggesting that any single detector or watermark is infallible?

**Answer:**

<br><br><br>

## I. Scientific AI, robotics, and research engineering

### 65. [Practice prompt] A scientist asks for an AI system to accelerate discovery, but the available data are sparse and experimental outcomes are expensive. How would you frame the problem?

**Answer:**

<br><br><br>

### 66. [Practice prompt] How would you evaluate a scientific model when ground truth is incomplete, measurements are noisy, and downstream experiments take months?

**Answer:**

<br><br><br>

### 67. [Practice prompt] What is the difference between predicting a plausible scientific structure or outcome and establishing that it is experimentally valid?

**Answer:**

<br><br><br>

### 68. [Practice prompt] How would you combine a learned model with scientific constraints, simulations, or expert review?

**Answer:**

<br><br><br>

### 69. [Practice prompt] A robot receives a natural-language instruction in an unfamiliar environment. How would you connect perception, planning, action, and safety monitoring?

**Answer:**

<br><br><br>

### 70. [Practice prompt] How would you evaluate whether an embodied agent can generalize to unseen objects, layouts, and tasks rather than memorize a test environment?

**Answer:**

<br><br><br>

### 71. [Practice prompt] In a research engineering collaboration, a research result is difficult to reproduce in the production training stack. How would you investigate the gap and work with researchers?

**Answer:**

<br><br><br>

### 72. [Practice prompt] Describe how you would make an AI research artifact reproducible and usable by collaborators without overselling what the evidence supports.

**Answer:**

<br><br><br>

## J. Coding, system design, and behavioral preparation

### 73. [Practice prompt] Implement or outline a bounded-concurrency worker that processes model requests while respecting a rate limit and preserving per-request results. What edge cases would you test?

**Answer:**

<br><br><br>

### 74. [Practice prompt] Given a stream of model-serving events, design a method to compute rolling error rates and latency percentiles without retaining every event indefinitely.

**Answer:**

<br><br><br>

### 75. [Practice prompt] Design an API for a long-running AI job with progress updates, cancellation, retries, and result retrieval. How would you make it safe to retry?

**Answer:**

<br><br><br>

### 76. [Practice prompt] Walk through a technical project you are proud of. What was your specific contribution, how did you measure impact, and what would you improve?

**Answer:**

<br><br><br>

### 77. [Practice prompt] Tell me about a time an experiment or technical hypothesis failed. How did you interpret the evidence and decide what to do next?

**Answer:**

<br><br><br>

### 78. [Practice prompt] Describe a disagreement with a research or product collaborator about priorities or evidence. How did you reach a decision?

**Answer:**

<br><br><br>

### 79. [Practice prompt] Tell me about a time you raised a safety, privacy, reliability, or fairness concern that affected a launch or project plan.

**Answer:**

<br><br><br>

### 80. [Practice prompt] A project is behind schedule, model quality is below target, and leadership wants a launch date. How would you communicate options and recommend a path?

**Answer:**

<br><br><br>

## Final readiness checklist

- I can explain how the exact role differs across research, product, applied AI, infrastructure, robotics, and scientific applications.
- I have asked the recruiter about the role-specific skills interviews, coding expectations, and available preparation guidance.
- I can reason about model quality and systems constraints together: data, compute, serving, latency, cost, and reliability.
- I can design and evaluate multimodal or tool-using systems with clear trust boundaries and failure handling.
- I can discuss experimental rigor, benchmark limitations, user impact, and release criteria with concrete examples.
- I can address safety, privacy, and fairness as engineering requirements and operational processes.
- I have concise, truthful examples of technical ownership, collaboration, learning from failure, and responsible judgment.

## Research references

### Official Google DeepMind and Google AI sources

- [Google DeepMind Careers](https://deepmind.google/careers/) — mission, role context, and high-level interview process.
- [About Google DeepMind](https://deepmind.google/about/) — organizational history and full-stack research and engineering context.
- [Google DeepMind Research](https://deepmind.google/research/) — public research areas, including robotics, agents, and world models.
- [Google DeepMind models and technologies](https://deepmind.google/models/) — public model and product areas, including Gemini, Gemma, Veo, image generation, and embeddings.
- [AlphaFold](https://deepmind.google/science/alphafold/) — scientific AI impact and research context.
- [Gemini API documentation](https://ai.google.dev/gemini-api/docs) — production API capabilities and current developer documentation.
- [Function calling](https://ai.google.dev/gemini-api/docs/function-calling) — model-mediated tool and API integration.
- [Live API](https://ai.google.dev/gemini-api/docs/live-api) — real-time audio, image, text, and voice-agent interactions.
- [Agents](https://ai.google.dev/gemini-api/docs/agents) — managed agent environments, network controls, credentials, and human oversight.
- [Safety settings](https://ai.google.dev/gemini-api/docs/safety-settings) — configurable output safety filters and blocked-content behavior.
