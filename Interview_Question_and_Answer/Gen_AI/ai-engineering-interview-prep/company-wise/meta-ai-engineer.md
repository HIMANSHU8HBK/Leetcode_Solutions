# Meta AI — AI / GenAI Engineer Interview Bank

**Research snapshot:** October 31, 2026  
**Target:** AI / GenAI engineers working on consumer AI experiences, multimodal assistants, agentic systems, model APIs, or the infrastructure behind AI products at Meta. Meta AI roles are not one uniform job family: product engineering, applied AI, recommendation/ranking, model training, and infrastructure roles can have substantially different interview expectations.

The official sources reviewed describe Meta's current AI product and engineering areas but do not publish a definitive AI Engineer interview loop or role-specific question bank. I also did not find a sufficiently reliable public source establishing exact, current interview questions for Meta AI roles. The questions below are original practice prompts informed by Meta's public product, research, careers, and safety material. They are **not represented as verbatim or guaranteed interview questions**.

## Research signals and confidence

### Officially documented

- Meta Careers currently presents AI as a major area of work and describes products including Meta AI, Muse models, Meta Model API, image generation, and AI glasses.
- Meta's public product material describes Muse Spark as a natively multimodal reasoning model used in Meta AI, including visual understanding, tool use, and multi-agent orchestration. Meta's materials also discuss real-time voice and camera experiences across its apps and wearables.
- Meta's Muse Glimmer research release describes open weights for local agent workflows and discusses distillation, quantization, inference latency, tool use, multimodal input, long-horizon tasks, and evaluation.
- Meta's Advanced AI Scaling Framework describes risk assessment, safeguards, testing before and after safeguards, and deployment decisions for advanced models.
- Meta FAIR describes research spanning algorithms, applications, software infrastructure, and hardware infrastructure.

### Publicly reported material

No reliable, current public source specific to Meta AI Engineer interviews or a verified Meta AI question list was identified during this research pass. General Meta interview-preparation content may describe broad software-engineering patterns, but should not be mistaken for an AI-role-specific or guaranteed interview process.

### Confidence labels

- **Official context:** supported by Meta public careers, product, research, or safety material.
- **Reported signal:** a third-party account of a candidate experience; anecdotal and not official. No role-specific question reports are asserted in this guide.
- **Practice prompt:** an original question synthesized from the target engineering scope and current public material.

## How to use this bank

1. Read the exact job description. Identify whether the role is product engineering, applied AI, model training, recommendation/ranking, multimodal systems, or infrastructure.
2. Prepare one project deep dive with your personal contribution, measured user impact, data and model choices, evaluation, launch approach, and failures.
3. Practice coding fundamentals and production-oriented implementation. Explain assumptions, edge cases, complexity, and how you would test the solution.
4. For system design, reason about the whole product path: client experience, models, data, tools, serving, privacy, safety, and operations.
5. Treat personalization and multimodal context as sensitive data flows. Explain consent, permissions, retention, user controls, and safe defaults.
6. Ask the recruiter about the current role-specific interview format, coding language, and preparation resources. Do not rely on generic internet claims about Meta interview rounds.

## A. Product judgment and Meta AI context

### 1. [Practice prompt] What does it mean for an AI assistant to understand a user's world rather than only respond to typed prompts? What product capabilities and risks follow from that goal?

**Answer:**

<br><br><br>

### 2. [Practice prompt] Design a useful Meta AI feature that works across a messaging app, a social feed, and AI glasses. Which capabilities should be shared, and which should be specific to each surface?

**Answer:**

<br><br><br>

### 3. [Practice prompt] A user asks a multimodal assistant for help with a real-world object shown on camera. How would you make the response useful while communicating uncertainty and avoiding unsupported high-stakes advice?

**Answer:**

<br><br><br>

### 4. [Practice prompt] How would you decide which personal, social, or environmental context is relevant to a request and which context must remain out of the model input?

**Answer:**

<br><br><br>

### 5. [Practice prompt] A feature increases engagement but also increases unwanted AI interruptions in conversations. How would you evaluate whether to change the experience?

**Answer:**

<br><br><br>

### 6. [Practice prompt] How would you select between a fast response mode and a deeper reasoning mode for a user request, and how would you make that choice understandable to the user?

**Answer:**

<br><br><br>

### 7. [Practice prompt] What would you measure to determine whether an AI feature helps people complete a task better, rather than merely increasing time spent in the product?

**Answer:**

<br><br><br>

### 8. [Practice prompt] A product asks for a highly personalized assistant, but users have different expectations about memory and personalization. How would you design controls and defaults?

**Answer:**

<br><br><br>

## B. Multimodal perception and real-time interaction

### 9. [Practice prompt] Design a real-time camera assistant that answers questions about what a user is seeing. Cover capture, perception, temporal context, response latency, and privacy.

**Answer:**

<br><br><br>

### 10. [Practice prompt] A user shares a photo containing a chart, small text, and several objects. How would you process the image and decide which regions or details need further analysis?

**Answer:**

<br><br><br>

### 11. [Practice prompt] How would you evaluate visual grounding and localization separately from general language quality in a multimodal assistant?

**Answer:**

<br><br><br>

### 12. [Practice prompt] Design a voice assistant that supports natural turn-taking, barge-in, topic changes, language switching, and tool use. What state belongs on the client and server?

**Answer:**

<br><br><br>

### 13. [Practice prompt] How should an assistant handle an interruption while a response is being generated or spoken, especially if a tool call is already in flight?

**Answer:**

<br><br><br>

### 14. [Practice prompt] Compare a speech-to-speech architecture with a pipeline of speech recognition, language-model reasoning, and speech synthesis for wearable use.

**Answer:**

<br><br><br>

### 15. [Practice prompt] How would you manage a rolling window of audio/video context so the assistant can answer follow-ups without retaining more raw media than necessary?

**Answer:**

<br><br><br>

### 16. [Practice prompt] A multimodal model performs well on still images but fails on a live camera stream due to motion, occlusion, or changing viewpoints. How would you diagnose the gap?

**Answer:**

<br><br><br>

### 17. [Practice prompt] How would you design graceful behavior when audio is noisy, an image is unavailable, the network drops, or the model cannot confidently perceive the relevant detail?

**Answer:**

<br><br><br>

### 18. [Practice prompt] How would you evaluate whether a multimodal assistant is appropriately using what the user sees, hears, or shares rather than hallucinating details from the scene?

**Answer:**

<br><br><br>

## C. Agents, tools, and multi-agent orchestration

### 19. [Practice prompt] When is a multi-agent approach justified over one model call with tools? What coordination overhead and failure modes would you measure?

**Answer:**

<br><br><br>

### 20. [Practice prompt] Design a system that delegates parts of a complex user request to parallel subagents and then synthesizes one coherent response.

**Answer:**

<br><br><br>

### 21. [Practice prompt] How would you prevent parallel agents from duplicating work, contradicting each other, or returning ungrounded claims to the final synthesizer?

**Answer:**

<br><br><br>

### 22. [Practice prompt] An agent can search, generate images, and run code. How would you decide which tools are available for a particular request and constrain their permissions?

**Answer:**

<br><br><br>

### 23. [Practice prompt] How would you design tool schemas and result formats so agents can use tools reliably across long tasks?

**Answer:**

<br><br><br>

### 24. [Practice prompt] A tool returns an error or unexpected result. How should the agent recover, and when should it stop or ask the user instead of retrying?

**Answer:**

<br><br><br>

### 25. [Practice prompt] How would you place limits on agent steps, tool calls, execution time, reasoning tokens, and spend without preventing legitimate completion?

**Answer:**

<br><br><br>

### 26. [Practice prompt] An agent takes an external action on behalf of a user. How would you enforce authorization, obtain informed confirmation, make the operation idempotent, and support audit or reversal?

**Answer:**

<br><br><br>

### 27. [Practice prompt] How would you build a durable agent task that can pause for user input, resume after a crash, and avoid repeating already completed actions?

**Answer:**

<br><br><br>

### 28. [Practice prompt] What evidence would you require before turning a successful agent prototype into a product feature used by a large consumer audience?

**Answer:**

<br><br><br>

## D. Model development, inference, and efficiency

### 29. [Practice prompt] How would you compare a hosted frontier model with an open-weight model for a high-volume product? Discuss quality, privacy, latency, operating cost, hardware, and iteration speed.

**Answer:**

<br><br><br>

### 30. [Practice prompt] Explain how distillation can transfer capabilities from a larger teacher model to a smaller model, and describe evaluation risks such as teacher errors or loss of rare behaviors.

**Answer:**

<br><br><br>

### 31. [Practice prompt] A model needs to run locally on a wearable or consumer device. How would you trade off parameter count, quantization, memory, KV cache, multimodal encoders, and response quality?

**Answer:**

<br><br><br>

### 32. [Practice prompt] How would you evaluate whether 4-bit quantization preserves the task capabilities that matter for an agent, rather than only preserving perplexity or generic benchmark scores?

**Answer:**

<br><br><br>

### 33. [Practice prompt] Explain speculative decoding at a high level. Under what conditions does a drafter/verifier approach improve end-to-end latency, and what can limit the gains?

**Answer:**

<br><br><br>

### 34. [Practice prompt] What are the memory costs of model weights, activations, multimodal encoders, and KV cache during inference? How would you profile peak memory for a target device?

**Answer:**

<br><br><br>

### 35. [Practice prompt] How would you route requests across small, medium, and large models while protecting quality on difficult or high-risk requests?

**Answer:**

<br><br><br>

### 36. [Practice prompt] A new model improves quality but doubles p99 latency and compute cost. How would you determine whether and where it should be deployed?

**Answer:**

<br><br><br>

### 37. [Practice prompt] How would you use test-time reasoning or additional inference compute selectively? Which tasks merit the extra latency and how would you measure the return?

**Answer:**

<br><br><br>

### 38. [Practice prompt] How would you design a model-upgrade path for on-device models when devices have different memory, accelerator, and software capabilities?

**Answer:**

<br><br><br>

## E. Evaluation, safety, and privacy

### 39. [Practice prompt] Build an evaluation plan for a multimodal assistant that can reason, use tools, and coordinate agents. How do you separately measure perception, task success, tool correctness, and safety?

**Answer:**

<br><br><br>

### 40. [Practice prompt] How would you evaluate an agent end-to-end when intermediate tool calls and trajectories matter as much as the final answer?

**Answer:**

<br><br><br>

### 41. [Practice prompt] A model's benchmark performance improves, but user outcomes worsen after launch. How would you investigate the mismatch?

**Answer:**

<br><br><br>

### 42. [Practice prompt] How would you design safety evaluations before and after safeguards are applied, and how would evaluation findings influence a deployment decision?

**Answer:**

<br><br><br>

### 43. [Practice prompt] How would you red-team a multimodal assistant that sees images and live camera input and can invoke tools?

**Answer:**

<br><br><br>

### 44. [Practice prompt] How would you test prompt injection in user-shared content, social posts, images, or tool outputs when the assistant also has personal context?

**Answer:**

<br><br><br>

### 45. [Practice prompt] How do you distinguish a model refusal that is needed for safety from an unnecessary refusal that blocks a benign request?

**Answer:**

<br><br><br>

### 46. [Practice prompt] A model gives wellness or health-related information based partly on an image. What product boundaries, uncertainty communication, escalation, and expert review should apply?

**Answer:**

<br><br><br>

### 47. [Practice prompt] How would you provide meaningful user control over memory and personalization, including inspection, correction, deletion, and disabling context use?

**Answer:**

<br><br><br>

### 48. [Practice prompt] What should be logged to investigate rare AI failures across billions of interactions, and how would you minimize sensitive data exposure and retention?

**Answer:**

<br><br><br>

### 49. [Practice prompt] How would you monitor quality and safety across languages, regions, devices, and user segments without relying solely on global averages?

**Answer:**

<br><br><br>

### 50. [Practice prompt] A safety evaluation finds a low-frequency but severe failure mode. How would you reason about mitigation, rollout scope, monitoring, and launch readiness?

**Answer:**

<br><br><br>

## F. Recommendation, personalization, and product systems

### 51. [Practice prompt] Meta AI can use a user's interests and public content to personalize answers. How would you define a permission-aware context retrieval layer that avoids using irrelevant or unauthorized data?

**Answer:**

<br><br><br>

### 52. [Practice prompt] Design a shopping assistant that combines user preferences, creator content, product catalogs, location, and external search. How would you rank results and explain why they were shown?

**Answer:**

<br><br><br>

### 53. [Practice prompt] How would you combine retrieval, recommendation ranking, and generative explanation without allowing generated text to misrepresent why an item was recommended?

**Answer:**

<br><br><br>

### 54. [Practice prompt] A personalized answer is relevant but surprises the user by using context from a different app or conversation. How would you investigate and redesign the context boundary?

**Answer:**

<br><br><br>

### 55. [Practice prompt] How would you evaluate personalization quality while detecting filter bubbles, popularity bias, sensitive inference, and unequal outcomes?

**Answer:**

<br><br><br>

### 56. [Practice prompt] A feature draws from public posts and creator content. How would you ensure accurate attribution, respect content permissions, and handle deleted or edited sources?

**Answer:**

<br><br><br>

## G. Coding and implementation practice

These are original practice exercises based on common AI product, agent, and systems engineering needs. They are not sourced from a reported interview prompt.

### 57. [Practice prompt] Implement a bounded parallel task runner that invokes subagents, enforces a concurrency limit and deadline, and returns partial results with explicit failures.

**Answer:**

<br><br><br>

### 58. [Practice prompt] Given tool-call events from several agents, group them by task, detect duplicate actions, and produce an ordered, auditable execution summary.

**Answer:**

<br><br><br>

### 59. [Practice prompt] Implement a rolling context buffer for a voice assistant that retains recent transcript segments under a token budget and removes audio payloads after their derived features are no longer needed.

**Answer:**

<br><br><br>

### 60. [Practice prompt] Given candidates from multiple retrieval or recommendation sources, deduplicate them and combine relevance, freshness, quality, and policy eligibility into a deterministic ranking step.

**Answer:**

<br><br><br>

### 61. [Practice prompt] Implement an idempotency layer for an agent tool that performs an external action. Show how concurrent duplicate requests and retries are handled.

**Answer:**

<br><br><br>

### 62. [Practice prompt] Write a stream processor that consumes partial multimodal events, assembles complete user turns, handles out-of-order or missing events, and emits a clear terminal state.

**Answer:**

<br><br><br>

### 63. [Practice prompt] Given model-route candidates with quality estimates, latency, cost, and safety eligibility, implement a routing policy subject to hard quality and budget constraints.

**Answer:**

<br><br><br>

### 64. [Practice prompt] Design a memory-bounded LRU cache for local model artifacts that accounts for item size, concurrent downloads, eviction, and partial/corrupt files.

**Answer:**

<br><br><br>

## H. System-design practice

### 65. [Practice prompt] Design a personal multimodal assistant that works across mobile, messaging, and smart glasses. Cover context, voice/camera streaming, model routing, tools, privacy, and graceful degradation.

**Answer:**

<br><br><br>

### 66. [Practice prompt] Design a multi-agent research experience that plans subqueries, searches in parallel, synthesizes evidence, cites sources, and returns a response under a strict latency budget.

**Answer:**

<br><br><br>

### 67. [Practice prompt] Design a serving platform for a family of models from cloud-scale to on-device. Include capability routing, model versions, quantization variants, telemetry, and rollout safety.

**Answer:**

<br><br><br>

### 68. [Practice prompt] Design an inference service for billions of consumer requests with highly variable prompt lengths, multimodal payloads, and reasoning effort. Discuss batching, scheduling, cache behavior, and tail latency.

**Answer:**

<br><br><br>

### 69. [Practice prompt] Design a safe personalization system that selects user context for a request across multiple Meta surfaces while enforcing consent, access boundaries, deletion, and auditability.

**Answer:**

<br><br><br>

### 70. [Practice prompt] Design an evaluation and rollout platform for a new multimodal model. Cover offline tests, safety evaluations, shadowing, canaries, segment-level monitoring, and rollback.

**Answer:**

<br><br><br>

### 71. [Practice prompt] Design a local agent that can operate user-approved apps on a consumer device. Cover sandboxing, permissions, sensitive data, tool confirmation, offline behavior, and recovery.

**Answer:**

<br><br><br>

### 72. [Practice prompt] Design an AI shopping assistant that combines marketplace listings, creator content, maps, and conversational refinement. How would you ensure relevance, attribution, freshness, and user trust?

**Answer:**

<br><br><br>

## I. Behavioral and project deep-dive practice

Meta Careers emphasizes impact, teamwork, and building AI experiences at scale. Use truthful examples from your own experience; these are practice prompts, not claims about exact Meta interview questions.

### 73. [Practice prompt] Tell me about a time you shipped a feature used by many people. How did you measure impact, handle operational risks, and respond to feedback?

**Answer:**

<br><br><br>

### 74. [Practice prompt] Describe a time you worked across research, product, infrastructure, or design to turn an ambiguous AI capability into a user-facing experience.

**Answer:**

<br><br><br>

### 75. [Practice prompt] Tell me about a time you found a reliability, safety, or privacy issue late in development. How did you communicate it and what decision followed?

**Answer:**

<br><br><br>

### 76. [Practice prompt] Describe a technical decision where you traded off model capability against latency, compute, or device constraints. What did you learn?

**Answer:**

<br><br><br>

### 77. [Practice prompt] Tell me about a time a metric improved but the user experience did not. How did you detect that and change course?

**Answer:**

<br><br><br>

### 78. [Practice prompt] Walk through an AI or distributed-systems project you personally built. What did you own, what failed, and what would you redesign?

**Answer:**

<br><br><br>

## Final readiness checklist

- I can explain which Meta AI role family I am targeting and why my experience matches its specific requirements.
- I can design a multimodal, real-time consumer assistant with explicit privacy, permission, and context boundaries.
- I can reason about agent delegation, tool authority, durability, and how to measure end-to-end task completion.
- I understand inference trade-offs across hosted and local models, quantization, KV cache, memory, and latency.
- I can design evaluation and safety controls for multimodal systems and explain how results affect deployment.
- I can connect personalization and recommendation decisions to user value, transparency, and safeguards.
- I can solve coding problems incrementally and communicate assumptions, tests, and complexity.
- I have real examples demonstrating impact, collaboration, ownership, and sound judgment under constraints.
- I have confirmed the exact interview format and role scope with the recruiter.

## Research references

### Official Meta sources

- [Meta Careers](https://www.metacareers.com/) — current company careers overview, featured AI work, and product context.
- [Engineering at Meta — AI research](https://engineering.fb.com/category/ai-research/) — FAIR scope across research, software infrastructure, and hardware infrastructure.
- [AI at Meta Research](https://ai.meta.com/research/) — current research and model-family overview.
- [Introducing Muse Spark](https://ai.meta.com/blog/introducing-muse-spark-msl/) — multimodal reasoning, tool use, multi-agent orchestration, scaling axes, and public model details.
- [Meta AI and Muse Spark product update](https://about.fb.com/news/2026/04/introducing-muse-spark-meta-superintelligence-labs/) — voice, camera, shopping, social-context, and multi-surface product examples.
- [Muse Glimmer: Open agentic model](https://research.meta.ai/blog/introducing-muse-glimmer-open-agentic-model) — local agent workflows, distillation, quantization, inference constraints, tool use, multimodal input, and evaluation.
- [Advanced AI Scaling Framework](https://ai.meta.com/blog/scaling-how-we-build-test-advanced-ai/) — safety assessment, safeguards, evaluation, and deployment decisions.
- [Llama 4: Natively multimodal intelligence](https://ai.meta.com/blog/llama-4-multimodal-intelligence/) — historical technical background on MoE and open-weight multimodal models. Product/model lineups change; check current Meta materials for up-to-date availability.

### Candidate-reported interview references

No sufficiently reliable, current public source specific to Meta AI Engineer interview questions was found during this research pass. This guide therefore does not present reported question prompts or claim a verified Meta AI interview pattern.
