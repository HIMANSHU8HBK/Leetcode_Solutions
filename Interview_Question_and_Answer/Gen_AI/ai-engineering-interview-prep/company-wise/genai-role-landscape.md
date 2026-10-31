# Generative AI Role Landscape

**Research snapshot:** October 31, 2026  
**Purpose:** A practical guide to the recurring role families companies may hire for when building foundation models, AI products, and the infrastructure around them.

## Important note on hiring frequency

This is a broad role map, not a live vacancy census or a ranked list of hiring volume. Job titles and hiring demand change quickly, and the same work may appear under different titles. A role should count as GenAI-related because of its responsibilities—not simply because its title contains “AI” or “GenAI.” Check the employer's current job description and team before preparing.

## Common GenAI role families

| Role family | Common title variations | Typical work | Useful preparation focus |
|---|---|---|---|
| **Applied AI / GenAI Engineer** | Applied AI Engineer, Generative AI Engineer, AI Engineer | Turn model capabilities into reliable user or business features; integrate models, retrieval, tools, APIs, and evaluation. | End-to-end AI application design, RAG, structured outputs, model selection, evaluation, latency, cost, and production debugging. See the [end-to-end Applied AI Engineer guide](../roles/applied-ai-engineer.md) for role scope, comparisons, lifecycle, interview preparation, and employers to investigate. |
| **AI Product / Full-Stack Engineer** | AI Product Engineer, Full-Stack AI Engineer, Software Engineer — AI Products | Build the user-facing product and backend around AI features, including streaming, permissions, data flows, and feedback. | API and UI design, state management, streaming, error handling, privacy, user experience, and deterministic controls around model output. |
| **LLM / Agent Engineer** | Agent Engineer, LLM Application Engineer, AI Workflow Engineer | Build tool-using or multi-step systems, manage context and state, and constrain autonomous behavior. | Agent architecture, tool contracts, orchestration, context engineering, prompt injection defenses, authorization, retries, and human approval. |
| **Machine Learning Engineer — Models** | ML Engineer, Foundation Model Engineer, LLM Engineer | Train, fine-tune, adapt, or improve foundation and task-specific models. | Deep learning fundamentals, data and training pipelines, distributed training, fine-tuning, optimization, and rigorous experiments. |
| **Research Engineer / Research Scientist** | Research Engineer, Research Scientist, ML Researcher | Develop and test new model methods, training approaches, capabilities, or scientific hypotheses; the research/engineering balance varies by role. | ML theory and implementation, experimental design, statistics, reproducibility, paper/project deep dives, and clear evidence-based reasoning. |
| **Inference / Model-Serving Engineer** | Inference Engineer, LLM Serving Engineer, Model Optimization Engineer | Make model inference faster, cheaper, more reliable, and more efficient across hardware and workloads. | GPU/accelerator fundamentals, batching, KV cache, quantization, kernels, throughput and tail latency, profiling, and benchmarking. |
| **AI Infrastructure / Distributed Systems Engineer** | AI Infrastructure Engineer, ML Systems Engineer, Distributed Training Engineer | Build compute, networking, storage, orchestration, and reliability systems for model training and inference at scale. | Distributed systems, accelerators, parallelism, scheduling, observability, fault tolerance, capacity planning, and SLOs. |
| **ML Platform / MLOps Engineer** | ML Platform Engineer, GenAIOps Engineer, AI Platform Engineer | Provide shared systems for data, experiments, model deployment, versioning, monitoring, governance, and developer workflows. | CI/CD for models, model registries, deployment and rollback, monitoring, reproducibility, security, and platform/API design. |
| **AI Evaluation / Quality Engineer** | AI Evaluation Engineer, LLM Quality Engineer, Model Evaluation Scientist | Measure model, RAG, and agent quality; create datasets and evaluation systems that inform model or product decisions. | Benchmark design, human and automated evaluation, judge calibration, statistics, error analysis, online testing, and release criteria. |
| **AI Safety / Responsible AI Engineer** | AI Safety Engineer, Safety Researcher, Responsible AI Engineer, Red Team Engineer | Identify and reduce misuse, harmful outputs, privacy risks, security vulnerabilities, and uneven performance. | Threat modeling, adversarial testing, policy and classifier evaluation, privacy, risk mitigation, incident response, and safety-performance trade-offs. |
| **Data / Curation Engineer for AI** | AI Data Engineer, Training Data Engineer, Data Curation Engineer | Build data ingestion, cleaning, labeling, filtering, deduplication, governance, and multimodal datasets for training or evaluation. | Data quality, distributed pipelines, provenance, leakage, licensing, privacy, dataset shift, and measurable curation impact. |
| **Multimodal AI Engineer** | Multimodal ML Engineer, Vision-Language Engineer, Speech/Audio AI Engineer | Build systems that process or generate combinations of text, images, audio, video, and other modalities. | Modality-specific representations, temporal alignment, cross-modal evaluation, streaming, latency, and data/privacy constraints. |
| **AI Solutions / Forward-Deployed Engineer** | Forward-Deployed Engineer, AI Solutions Engineer, Customer AI Engineer | Work with customers to scope, prototype, integrate, and productionize AI systems for real workflows. | Customer discovery, API integration, rapid prototyping, system design, deployment constraints, evaluation, and clear technical communication. |
| **AI Developer Relations / Technical Enablement** | Developer Advocate, AI Solutions Architect, Technical Trainer | Help developers adopt AI platforms through examples, architecture guidance, workshops, and technical feedback to product teams. | Strong implementation skills, clear teaching, developer workflows, API knowledge, demos, and translating user problems into product feedback. |
| **AI Product Manager** | AI Product Manager, GenAI Product Manager, Technical Product Manager — AI | Define user problems, product requirements, success measures, launch plans, and trade-offs for AI capabilities. | Product judgment, model capability limits, evaluation, safety/privacy, experimentation, prioritization, and cross-functional execution. |

## How to identify the right role from a job description

Look past the title and classify the role by its primary deliverables:

- **Models and experiments:** model training, architecture, fine-tuning, or research results point toward ML Engineer, Research Engineer, or Research Scientist.
- **User-facing features:** application behavior, product surfaces, and workflow integration point toward Applied AI or AI Product Engineering.
- **Throughput and reliability:** accelerator efficiency, serving, distributed compute, and SLOs point toward Inference or AI Infrastructure Engineering.
- **Shared tooling:** internal platforms, deployment workflows, governance, and monitoring point toward ML Platform or MLOps.
- **Quality and risk:** benchmarks, evaluation datasets, red teaming, and release decisions point toward Evaluation or Safety.
- **Customer delivery:** implementation with external users and deployment in varied environments point toward Solutions or Forward-Deployed Engineering.

Many jobs are hybrids. For example, an Applied AI Engineer may own evaluation and production operations, while a Research Engineer may write substantial distributed-training code. Prioritize the responsibilities and required qualifications over the label.

## Skills that recur across many GenAI roles

1. **Software engineering:** readable code, testing, API design, debugging, version control, and sound systems fundamentals.
2. **Model literacy:** strengths and limitations of LLMs, multimodal models, embeddings, fine-tuning, and inference.
3. **Evaluation:** define success measures, create representative tests, analyze failure modes, and avoid relying on a single benchmark.
4. **Production judgment:** account for reliability, latency, cost, observability, privacy, security, and graceful failure.
5. **Communication and ownership:** explain trade-offs, collaborate across disciplines, and connect technical decisions to user or research outcomes.

Depth varies substantially: CUDA kernel expertise is central for some inference roles but not a baseline requirement for every GenAI application engineer. Match preparation to the role rather than trying to master every specialty.

## Official references

These references illustrate the range of GenAI work and technical systems; they do not prove that a particular employer has an open position at the time you read this guide.

- [Google DeepMind Careers](https://deepmind.google/careers/) — public role areas and high-level interview process.
- [Google Gemini API documentation](https://ai.google.dev/gemini-api/docs) — application, multimodal, tool, and agent capabilities.
- [OpenAI Careers](https://openai.com/careers/) — research, engineering, product, and deployment organization context.
- [Anthropic Careers](https://www.anthropic.com/careers) — current organization and career information.
- [NVIDIA Careers](https://www.nvidia.com/en-us/about-nvidia/careers/) — AI, hardware, and accelerated-computing career areas.
- [NVIDIA Triton Inference Server](https://docs.nvidia.com/deeplearning/triton-inference-server/user-guide/docs/) — model serving, batching, health, and performance monitoring.
- [NVIDIA NeMo Framework](https://docs.nvidia.com/nemo-framework/user-guide/latest/overview.html) — generative and speech model development and customization.
- [Databricks Careers](https://www.databricks.com/company/careers) — roles across data, AI, engineering, and research.

Check each company's live career listings for current vacancies, team, seniority, location, and qualifications before treating any role family as actively hiring.
