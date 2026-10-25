# 08. LLMOps and Production AI

Source entries are in their original order. Use the space after each heading to draft an answer.

## How does Prompt Caching work?

**Answer:**

<br><br><br>

## Prefill vs Decode

**Answer:**

<br><br><br>

## Why is prefill compute-bound and decode memory-bandwidth-bound?

**Answer:**

<br><br><br>

## What is chunked prefill, and why does it improve tail latency under mixed traffic?

**Answer:**

<br><br><br>

## What is Prefill-Decode Disaggregation, and when does it pay off?

**Answer:**

<br><br><br>

## Explain the AI product lifecycle from ideation to production.

**Answer:**

<br><br><br>

## What is LLMOps, and how does it differ from traditional MLOps?

**Answer:**

<br><br><br>

## How do you serve LLMs in production?

**Answer:**

<br><br><br>

## What is model quantization?

**Answer:**

<br><br><br>

## Explain post-training quantization (PTQ) vs quantization-aware training (QAT). What breaks when you push weights to 2-4 bits?

**Answer:**

<br><br><br>

## How do you monitor LLM applications in production?

**Answer:**

<br><br><br>

## What is LLM observability?

**Answer:**

<br><br><br>

## What are guardrails for LLMs, and how do you implement them?

**Answer:**

<br><br><br>

## How do you implement content filtering for AI outputs?

**Answer:**

<br><br><br>

## How do you estimate the cost of running an AI-powered feature in production?

**Answer:**

<br><br><br>

## How do you optimize LLM inference costs in production?

**Answer:**

<br><br><br>

## How do you implement A/B testing for LLM systems?

**Answer:**

<br><br><br>

## What is CI/CD for AI applications, and how does it differ from traditional CI/CD?

**Answer:**

<br><br><br>

## How do you version and manage prompts in production?

**Answer:**

<br><br><br>

## What is model versioning, and how do you handle model rollbacks?

**Answer:**

<br><br><br>

## How do you implement rate limiting and throttling for LLM APIs?

**Answer:**

<br><br><br>

## How do you handle model updates and migrations without downtime?

**Answer:**

<br><br><br>

## What is the role of feature flags in AI deployments?

**Answer:**

<br><br><br>

## How do you implement logging and tracing for LLM applications?

**Answer:**

<br><br><br>

## How do you handle PII and sensitive data in LLM inputs and outputs?

**Answer:**

<br><br><br>

## What is a gateway pattern for LLM API management?

**Answer:**

<br><br><br>

## How does Token Streaming work?

**Answer:**

<br><br><br>

## How do you implement streaming responses for real-time AI applications?

**Answer:**

<br><br><br>

## How does vLLM work?

**Answer:**

<br><br><br>

## How does SGLang work?

**Answer:**

<br><br><br>

## How does TensorRT-LLM work?

**Answer:**

<br><br><br>

## How does llama.cpp run LLMs on everyday hardware?

**Answer:**

<br><br><br>

## How does Ollama work?

**Answer:**

<br><br><br>

## When would you choose vLLM vs SGLang vs TensorRT-LLM?

**Answer:**

<br><br><br>

## What are the key SLAs and metrics for production AI systems (latency, throughput, availability)?

**Answer:**

<br><br><br>

## Cloud vs on-device Model Deployment for AI applications.

**Answer:**

<br><br><br>

## How do you implement fallback strategies when the primary model is unavailable or rate-limited?

**Answer:**

<br><br><br>

## How do you implement structured output from LLMs reliably in production?

**Answer:**

<br><br><br>

## How do you handle long contexts efficiently in production (context compression, prefix caching)?

**Answer:**

<br><br><br>

## What is semantic routing, and how do you implement it in a multi-model system?

**Answer:**

<br><br><br>

## How do you manage secrets and API keys securely in LLM applications?

**Answer:**

<br><br><br>

## Your LLM API has latency spikes during peak hours. How do you stabilize it?

**Answer:**

<br><br><br>

## Your LLM endpoint's p99 latency doubled after a deploy with no model change. How do you diagnose it?

**Answer:**

<br><br><br>

## Your LLM costs are too high in production. How do you reduce costs without degrading quality?

**Answer:**

<br><br><br>

## Your application is hitting LLM provider rate limits during peak hours. How do you handle it?

**Answer:**

<br><br><br>

## Your application depends on one LLM provider. How do you switch providers without downtime?

**Answer:**

<br><br><br>

## Your AI system handles 100 requests/sec but crashes at 5000. How do you scale for concurrent requests?

**Answer:**

<br><br><br>

## A traffic spike brings down your AI system. How do you handle peak traffic?

**Answer:**

<br><br><br>

## One LLM provider outage took down your entire system. How do you eliminate single points of failure?

**Answer:**

<br><br><br>

## Your multi-LLM pipeline fails when one model in the chain breaks. How do you handle orchestration failure?

**Answer:**

<br><br><br>

## Your AI pipeline has zero visibility into which step is failing. How do you add observability?

**Answer:**

<br><br><br>

## You quantized your LLM, but accuracy dropped significantly. How do you minimize quantization loss?

**Answer:**

<br><br><br>

## One failing AI component can take down your entire platform. How do you design graceful degradation?

**Answer:**

<br><br><br>
