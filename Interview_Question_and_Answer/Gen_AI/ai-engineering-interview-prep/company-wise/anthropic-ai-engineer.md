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

<br><br><br>

### 2. [Practice prompt] A team proposes an agent for a task users currently complete with a short form and a deterministic workflow. How would you decide whether an LLM adds enough value to justify its failure modes and operating cost?

**Answer:**

<br><br><br>

### 3. [Practice prompt] How would you decide whether to use a direct Messages API integration, an application-owned agent loop, or a managed agent runtime for a new product?

**Answer:**

<br><br><br>

### 4. [Practice prompt] A prototype impresses internal reviewers but has not been tested with representative users. What evidence would you gather before expanding access?

**Answer:**

<br><br><br>

### 5. [Practice prompt] How do you prioritize model quality, latency, cost, user control, privacy, and safety when product requirements conflict?

**Answer:**

<br><br><br>

### 6. [Practice prompt] Anthropic's careers principles include empirical simplicity and personal ownership. Describe a time you chose a simpler solution or took responsibility for an unclear problem.

**Answer:**

<br><br><br>

### 7. [Practice prompt] How would you respond if a product leader asked you to ship a capability whose benefits are clear but whose misuse risks are not yet understood?

**Answer:**

<br><br><br>

## B. Claude API and application engineering

### 8. [Practice prompt] How would you structure a Messages API integration for a multi-turn application, including system instructions, message history, stop reasons, and error states?

**Answer:**

<br><br><br>

### 9. [Practice prompt] What responsibilities belong in your application rather than being delegated to the model API when building an AI product?

**Answer:**

<br><br><br>

### 10. [Practice prompt] How would you choose among Claude model tiers for a workload with quality, latency, and cost targets? Describe an evaluation-based selection process rather than choosing by model name alone.

**Answer:**

<br><br><br>

### 11. [Practice prompt] A model response may end because it completed normally, reached a token limit, or requested a tool. How should the application interpret and handle each state?

**Answer:**

<br><br><br>

### 12. [Practice prompt] How would you stream model output to a client while handling partial events, network interruptions, cancellation, backpressure, and a final completion or error state?

**Answer:**

<br><br><br>

### 13. [Practice prompt] A client times out while the upstream generation may still be running. How would you design request identity, retry behavior, cancellation, and cost attribution?

**Answer:**

<br><br><br>

### 14. [Practice prompt] How would you handle rate limits and transient provider failures without retrying permanent errors or creating a retry storm?

**Answer:**

<br><br><br>

### 15. [Practice prompt] Your service uses prompt caching for a large stable system prompt and shared reference material. What should remain dynamic, how do you monitor cache effectiveness, and what privacy or freshness issues must you check?

**Answer:**

<br><br><br>

### 16. [Practice prompt] How would you design an API abstraction that permits model upgrades while preserving a stable application contract and exposing provider-specific features only when required?

**Answer:**

<br><br><br>

### 17. [Practice prompt] How do you keep API keys and user credentials out of browser code, logs, traces, and prompts while still enabling interactive client applications?

**Answer:**

<br><br><br>

### 18. [Practice prompt] A customer has strict data-retention requirements. How would you determine which request data is retained by your application, the provider, and any enabled API features?

**Answer:**

<br><br><br>

## C. Tool use, agents, and computer interaction

### 19. [Practice prompt] Walk through the tool-use lifecycle from model decision to application-side tool execution and the model's follow-up response. Where should validation and authorization occur?

**Answer:**

<br><br><br>

### 20. [Practice prompt] How would you design tool schemas and descriptions so the model selects the intended tool and produces arguments that can be validated deterministically?

**Answer:**

<br><br><br>

### 21. [Practice prompt] A model requests a payment, account change, or data deletion. How would you prevent a tool call from becoming an authorization decision, and when should the user approve the action?

**Answer:**

<br><br><br>

### 22. [Practice prompt] How would you design an agent loop with bounded steps, tool allowlists, deadlines, retries, and explicit termination conditions?

**Answer:**

<br><br><br>

### 23. [Practice prompt] When would you use a managed agent service instead of an application-owned agent loop? What state, execution, security, and observability responsibilities change?

**Answer:**

<br><br><br>

### 24. [Practice prompt] A long-running agent must survive restarts and resume work. What state would you persist, how would you version it, and how would you avoid replaying completed side effects?

**Answer:**

<br><br><br>

### 25. [Practice prompt] How would you connect an agent to MCP tools while controlling server trust, tool discovery, authentication, user approval, and the data sent to remote servers?

**Answer:**

<br><br><br>

### 26. [Practice prompt] Design a computer-use agent for a browser task. What environment isolation, credentials, domain limits, approval gates, and audit records would you require?

**Answer:**

<br><br><br>

### 27. [Practice prompt] A webpage contains instructions that conflict with the user's request and could cause the agent to expose data or take an action. How would you design defenses against this prompt-injection path?

**Answer:**

<br><br><br>

### 28. [Practice prompt] How do you decide whether to expose multiple specialized agents or one agent with a set of tools? What evidence justifies the extra handoff and state-management complexity?

**Answer:**

<br><br><br>

## D. Context, prompting, and retrieval

### 29. [Practice prompt] How would you structure a prompt containing instructions, examples, untrusted user input, retrieved passages, and tool results so that their roles and trust levels are explicit?

**Answer:**

<br><br><br>

### 30. [Practice prompt] When would XML-style structure or other explicit delimiters help Claude interpret a complex prompt, and how would you test whether the structure actually improves behavior?

**Answer:**

<br><br><br>

### 31. [Practice prompt] How would you decide whether a poor result should be addressed by changing the prompt, retrieval, model, tools, or product workflow?

**Answer:**

<br><br><br>

### 32. [Practice prompt] A conversation grows beyond the context budget. How would you preserve key instructions and evidence while summarizing or dropping history?

**Answer:**

<br><br><br>

### 33. [Practice prompt] How would you build a document question-answering system with citations and abstention when the retrieved context does not support an answer?

**Answer:**

<br><br><br>

### 34. [Practice prompt] Retrieval finds relevant passages, but answer quality is inconsistent. How would you separate problems in parsing, chunking, ranking, context assembly, and generation?

**Answer:**

<br><br><br>

### 35. [Practice prompt] How would you use prompt caching for long shared context while preventing one tenant's confidential information from appearing in another tenant's request?

**Answer:**

<br><br><br>

## E. Evaluation, reliability, and safety

### 36. [Practice prompt] How do you define success criteria for a new LLM feature before tuning prompts or selecting a model?

**Answer:**

<br><br><br>

### 37. [Practice prompt] Build an evaluation plan combining exact checks, domain-specific tests, human review, and model-based grading. What limitations would you communicate about each?

**Answer:**

<br><br><br>

### 38. [Practice prompt] How would you create a representative evaluation set when user traffic is skewed, labels are expensive, and behavior changes over time?

**Answer:**

<br><br><br>

### 39. [Practice prompt] A prompt change improves average evaluation scores but causes a serious regression for one user segment. How would you detect, investigate, and decide whether to ship?

**Answer:**

<br><br><br>

### 40. [Practice prompt] What red-team cases would you create for a tool-using assistant, and which failure classes should block a release?

**Answer:**

<br><br><br>

### 41. [Practice prompt] How would you test a model's refusal behavior without over-optimizing for refusals and degrading legitimate user requests?

**Answer:**

<br><br><br>

### 42. [Practice prompt] What safety controls belong in application code, model instructions, moderation or classification systems, and human review?

**Answer:**

<br><br><br>

### 43. [Practice prompt] How would you decide when a human must verify a model output before it is acted on, especially in high-impact or irreversible workflows?

**Answer:**

<br><br><br>

### 44. [Practice prompt] What would you log for production debugging of an agent, and how would you balance reproducibility with data minimization and retention requirements?

**Answer:**

<br><br><br>

### 45. [Practice prompt] How would you safely roll out a model or prompt change using offline tests, limited traffic, monitoring, and rollback criteria?

**Answer:**

<br><br><br>

### 46. [Practice prompt] Users report that the model is less helpful after a provider-side model update, although your application code is unchanged. How would you detect and respond to the regression?

**Answer:**

<br><br><br>

## F. Multimodal and real-time applications

### 47. [Practice prompt] Design a real-time voice assistant that supports turn-taking, interruption, tool use, and low latency. Explain client/server responsibilities and failure handling.

**Answer:**

<br><br><br>

### 48. [Practice prompt] Compare speech-to-speech with a chained speech-recognition, text-reasoning, and speech-generation architecture. Which product and operational requirements drive the choice?

**Answer:**

<br><br><br>

### 49. [Practice prompt] How would a voice agent handle barge-in while it is speaking, including cancellation of generation and any in-flight tool action?

**Answer:**

<br><br><br>

### 50. [Practice prompt] A vision model receives screenshots from a user-controlled website. How would you handle hidden prompt injection, sensitive visual data, and potentially consequential clicks?

**Answer:**

<br><br><br>

### 51. [Practice prompt] How would you evaluate a multimodal assistant for task success, modality-specific quality, latency, user experience, and safety?

**Answer:**

<br><br><br>

## G. Coding and implementation practice

These are original practice exercises based on common model-backed product engineering work. They are not sourced from a reported interview prompt.

### 52. [Practice prompt] Implement an event-stream parser that reconstructs complete events when network chunks split at arbitrary byte boundaries and handles a terminal event cleanly.

**Answer:**

<br><br><br>

### 53. [Practice prompt] Implement a retry wrapper for a model request with jittered exponential backoff, retryable-status classification, a deadline, and a maximum attempt count.

**Answer:**

<br><br><br>

### 54. [Practice prompt] Implement a tool dispatcher that validates tool names and arguments, checks authorization, enforces a timeout, and returns a structured success or error result.

**Answer:**

<br><br><br>

### 55. [Practice prompt] Implement a bounded agent runner that tracks elapsed time and tool calls and produces distinct outcomes for success, refusal, provider error, and budget exhaustion.

**Answer:**

<br><br><br>

### 56. [Practice prompt] Given a conversation and token budget, trim or summarize old turns without dropping system instructions or separating a tool call from its corresponding result.

**Answer:**

<br><br><br>

### 57. [Practice prompt] Given usage events grouped by model, tenant, status, and timestamp, compute cost and latency summaries while handling failed requests and missing usage fields explicitly.

**Answer:**

<br><br><br>

### 58. [Practice prompt] Implement a job scheduler for agent tasks with dependencies and limited concurrency. Explain cycle detection, retries, idempotency, and what happens when a worker crashes.

**Answer:**

<br><br><br>

## H. System-design practice

### 59. [Practice prompt] Design a multi-tenant Claude-powered assistant API with streaming responses, authentication, quotas, state management, data-retention controls, observability, and graceful degradation.

**Answer:**

<br><br><br>

### 60. [Practice prompt] Design a research assistant that retrieves sources, summarizes evidence, cites claims, and can call external tools. How do you handle source trust, freshness, privacy, and unsupported answers?

**Answer:**

<br><br><br>

### 61. [Practice prompt] Design an agent that can operate a browser to complete user-approved tasks. Cover sandboxing, credential handling, prompt-injection defenses, approval boundaries, durable state, and auditability.

**Answer:**

<br><br><br>

### 62. [Practice prompt] Design an evaluation and rollout platform for model, prompt, and tool changes. How would you support reproducible offline testing, human feedback, canaries, and rollback?

**Answer:**

<br><br><br>

### 63. [Practice prompt] Design a long-running asynchronous agent service that can pause for user approval, resume after a restart, and avoid duplicate side effects.

**Answer:**

<br><br><br>

### 64. [Practice prompt] A high-volume product must route between model tiers to meet quality and latency objectives under a strict budget. Design routing, fallback, evaluation, and spend controls.

**Answer:**

<br><br><br>

### 65. [Practice prompt] Design privacy-aware observability for an AI application so engineers can investigate rare failures without indiscriminately storing raw user content.

**Answer:**

<br><br><br>

### 66. [Practice prompt] Design a safe migration from a short-context workflow to a long-context agent. How would you compare quality, manage state, limit risk, and decide whether the increased complexity is worthwhile?

**Answer:**

<br><br><br>

## I. Behavioral and project deep-dive practice

Anthropic's careers material describes mission, user care, humility implicit in empirical iteration, safety, and ownership. Prepare genuine examples from your own experience; these are practice prompts, not claims about exact interview questions.

### 67. [Practice prompt] Tell me about a time you shipped a user-facing feature and then changed it based on real-world feedback. What did you learn and what improved?

**Answer:**

<br><br><br>

### 68. [Practice prompt] Describe a time you surfaced a safety, privacy, or reliability concern that could have delayed a launch. How did you handle the trade-off?

**Answer:**

<br><br><br>

### 69. [Practice prompt] Tell me about a time you chose a simpler technical approach over a more sophisticated one. How did you validate that the simpler approach was sufficient?

**Answer:**

<br><br><br>

### 70. [Practice prompt] Describe a disagreement with a teammate about a technical decision. How did you communicate directly and kindly, and what evidence helped resolve it?

**Answer:**

<br><br><br>

### 71. [Practice prompt] Tell me about a difficult failure or incident. What did you own, how did you communicate uncertainty, and what did you do to repair the system or relationship?

**Answer:**

<br><br><br>

### 72. [Practice prompt] Walk through an AI or infrastructure project you personally built. What decisions were yours, what did you measure, and what would you change now?

**Answer:**

<br><br><br>

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
