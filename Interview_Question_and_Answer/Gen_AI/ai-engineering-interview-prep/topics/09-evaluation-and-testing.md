# 09. Evaluation and Testing

Source entries are in their original order. Use the space after each heading to draft an answer.

## AI Agent Evaluation

**Answer:**

### Evaluate the agent as a complete, multi-step system

AI agent evaluation measures whether an agent completes a goal correctly, safely, and efficiently—not merely whether its final response sounds plausible. An agent’s behavior includes planning, tool selection and arguments, observations, state/memory use, retries, stopping decisions, and side effects. Evaluation should therefore inspect both the outcome and the trajectory that produced it.

### A practical evaluation approach

1. **Define task success precisely:** Create representative tasks with explicit success criteria, preconditions, permitted tools, forbidden actions, and expected final state. Include easy, ambiguous, long-horizon, and failure-recovery cases.
2. **Measure end outcomes:** Track task completion, correctness, constraint adherence, user acceptance, and whether the intended external state changed correctly. For tasks with multiple valid solutions, define rubric-based acceptance rather than exact text matching.
3. **Inspect trajectories:** Record step count, tool choice/argument correctness, unnecessary calls, invalid actions, repeated loops, observation use, planning changes, and whether the agent stopped at the right time. A successful outcome reached through unsafe or unauthorized behavior is not a pass.
4. **Evaluate safety and policy:** Test prompt injection, untrusted tool output, permission boundaries, data exfiltration attempts, harmful actions, and confirmation requirements. Check that controls are enforced by trusted application code, not only instructions to the model.
5. **Measure efficiency and reliability:** Track latency, tokens, cost per successful task, retries, timeouts, tool failures, human interventions, and variance across repeated runs. Set budgets for steps, tool calls, time, and spend.
6. **Use complementary evaluators:** Combine deterministic assertions for state and tool effects, simulation/sandbox tests, human review for ambiguous quality, and calibrated model judges for scalable rubric scoring. No single method adequately measures all dimensions.
7. **Run regression and live evaluation:** Maintain versioned test tasks, compare agent/model/prompt/tool changes against a baseline, and deploy changes through canaries with quality, safety, and cost gates. Monitor production feedback with privacy protections and convert incidents into tests.

Agent results are often nondeterministic. Repeat selected cases, report confidence or score distributions, and separate failures caused by the model from environment/tool reliability. Use realistic but controlled environments so expected outcomes can be verified without risking production side effects.

### Trade-offs, bottlenecks, and capacity assumptions

End-to-end simulation is realistic but expensive to build and maintain; short unit tests are cheap but miss planning and recovery failures. Human grading improves contextual judgment but is slower and can vary by evaluator. Model-based judging scales, yet can share biases with the agent and miss unsafe tool effects. Long trajectories increase evaluation cost and variance. Task volume, risk level, and evaluation budget are unspecified, so use broad inexpensive checks on every change and deeper repeated/sandboxed tests for high-impact releases.

### Concise interview answer

“I evaluate an agent on end-task success, safety, and efficiency, while also inspecting its trajectory: plans, tool choices, arguments, retries, and stopping behavior. I use deterministic checks for state changes, sandboxed end-to-end tasks, human review for ambiguous quality, and calibrated model judges for scale. Tests include adversarial inputs and tool failures, with budgets on steps, time, and cost. Because runs vary, I use repeated trials and compare versioned task suites before canary rollout.”

### Revision summary

| Dimension | Example evidence |
|---|---|
| Outcome | Correct task completion and final state. |
| Trajectory | Tool selection, arguments, loops, stopping. |
| Safety | Authorization, injection resistance, side-effect controls. |
| Efficiency | Steps, latency, tokens, cost, interventions. |
| Method | Deterministic tests, sandbox, human/model judging, repeated runs. |

<br><br><br>

## LLM Evaluation

**Answer:**

### Judge behavior against the intended use, not a single generic score

LLM evaluation is the systematic measurement of a model or LLM-powered application against defined quality, safety, reliability, and operational requirements. The right method depends on the task: exact extraction, summarization, open-ended assistance, code generation, and retrieval-grounded answering need different criteria. A fluent response alone is not evidence of correctness.

### Build a layered evaluation plan

1. **Define the target and rubric:** Specify what a successful answer must contain, what counts as an error, and which constraints are mandatory. Include task-specific requirements such as factual correctness, citation support, completeness, format validity, helpfulness, or calibrated refusal.
2. **Create representative data:** Use versioned examples from expected workloads, with important languages, user groups, difficulty levels, edge cases, and high-risk scenarios. Keep a protected holdout set to reduce tuning to the evaluation data.
3. **Use objective checks where possible:** Apply exact-match or schema validation for structured tasks, unit tests for code, citation/grounding checks for RAG, and deterministic policy checks for required behavior. These are interpretable but cover only their defined criteria.
4. **Evaluate subjective dimensions carefully:** Use trained human raters or a calibrated LLM judge with a detailed rubric for qualities such as relevance, coherence, and preference. Audit judge agreement and compare scores with human labels; do not treat a judge score as ground truth.
5. **Measure safety and robustness:** Test harmful requests, prompt injection, sensitive-data handling, refusal behavior, adversarial phrasing, and robustness to malformed inputs. Measure both false refusals and unsafe compliance where appropriate.
6. **Measure production constraints:** Track latency percentiles, time-to-first-token for streaming, token use, availability, error rates, and cost per successful task. A quality improvement may not be acceptable if it violates a hard latency or budget requirement.
7. **Compare and release:** Run paired comparisons against the current baseline, analyze task slices and uncertainty, investigate regressions, and gate canaries on predefined thresholds. Re-evaluate after changes to model, prompt, retrieval, tools, or provider behavior.

Keep evaluation data and labels governed: remove or protect personal data, document provenance, and limit access. A benchmark score is meaningful only relative to its dataset, metric, evaluator, and intended deployment.

### Trade-offs, bottlenecks, and capacity assumptions

Exact metrics are fast and reproducible but often narrow; human and model-judge evaluation can assess nuanced quality but introduce cost, subjectivity, and bias. Larger suites improve coverage but slow iteration and consume inference/reviewer capacity. A static set can become stale or leak into tuning. Since model, task mix, and risk are unspecified, start from user outcomes and allocate evaluation depth by risk, keeping a stable baseline plus fresh and adversarial samples.

### Concise interview answer

“I define task-specific success criteria, then combine representative held-out examples with deterministic checks, human review, and calibrated LLM judging as appropriate. I measure correctness, completeness, safety, robustness, format/grounding, latency, and cost, and inspect results by task slice rather than only an average. Paired comparisons and release gates catch regressions, while protected test data and ongoing refresh reduce overfitting. Evaluation is tied to the application’s definition of done, not just model fluency or a benchmark score.”

### Revision summary

| Layer | What it answers |
|---|---|
| Task rubric/data | What “good” means for intended users. |
| Deterministic tests | Whether explicit constraints and outputs hold. |
| Human/model judging | Nuanced quality and preference. |
| Safety/robustness | Whether behavior remains acceptable under stress. |
| Operational metrics | Whether quality meets latency, availability, and cost needs. |

<br><br><br>

## AI Agent Observability

**Answer:**

### Make agent decisions and side effects traceable

AI agent observability is the ability to understand what an agent did, why the workflow took a particular path, where it failed, and what resources or external effects it produced. For agents, a single request log is not enough: one user task may involve multiple reasoning/generation steps, retrieval, tools, retries, handoffs, and a final response. Instrument the workflow while minimizing sensitive content capture.

### What to instrument

1. **Trace the full execution:** Assign a correlation ID and create spans for planning/generation steps, retrieval, each tool call, validation, retries, and finalization. Preserve parent-child relationships across queues and asynchronous operations.
2. **Record safe decision metadata:** Capture agent/model/prompt/tool versions, selected tool and validated arguments, routing and policy decisions, step/attempt number, and whether a human approval occurred. Avoid recording hidden reasoning or raw sensitive content by default; structured decision events and outcomes are generally more useful and safer.
3. **Track completion and failure states:** Distinguish success, partial completion, refusal, timeout, cancellation, budget exhaustion, invalid tool call, dependency failure, and user abandonment. For side-effecting tools, record an auditable action ID/result and idempotency outcome without exposing secrets.
4. **Measure behavior and cost:** Track goal completion, step and tool-call counts, loop/retry frequency, tool success rate, human intervention, latency by stage, token use, and cost per successful task. Aggregate by task type/model/version while controlling label cardinality.
5. **Add quality and safety signals:** Link approved evaluation outcomes, user corrections, policy violations, and safety incidents to the trace or release version. Treat online proxies as signals—not proof of correctness—and protect any user feedback data.
6. **Build operational views and alerts:** Show end-to-end success and latency alongside stage-level errors, queueing, provider throttling, tool failures, and budget exhaustion. Alert on actionable SLO and safety thresholds with enough context to investigate.
7. **Protect and govern telemetry:** Apply redaction, role-based access, encryption, retention limits, and sampling. Keep prompts, outputs, retrieved records, and tool payloads out of general logs unless a justified, approved debugging workflow requires them.

Observability must not compromise the security model: tool authorization and confirmation are enforced by application services, and traces must not become an alternate channel for secrets or cross-tenant data.

### Trade-offs, bottlenecks, and capacity assumptions

Fine-grained traces make long-horizon failures diagnosable but increase telemetry volume, storage cost, and privacy risk. Sampling can miss rare harmful behavior; targeted error capture helps but needs access controls. High-cardinality dimensions such as request IDs belong in traces, not aggregate metric labels. Agent step count, traffic, and retention are unspecified, so budget telemetry by expected tasks × steps × events and decide which payload fields are necessary before enabling capture broadly.

### Concise interview answer

“I trace an agent task end to end, with spans for generation, retrieval, tools, retries, approvals, and finalization. I capture versioned configuration, safe tool/decision metadata, outcomes, step counts, latency, tokens, and side-effect identifiers, while avoiding hidden reasoning and raw sensitive content by default. Metrics and alerts cover completion, loops, tool failures, safety, and cost. Privacy-aware retention and access controls are essential because observability data can be as sensitive as the original conversation.”

### Revision summary

| Signal | Purpose |
|---|---|
| End-to-end traces | Reconstruct multi-step execution and bottlenecks. |
| Decision/tool metadata | Understand routing, actions, and versions safely. |
| Outcome metrics | Completion, failure, loops, latency, and cost. |
| Safety signals | Find policy incidents and intervention points. |
| Governance | Minimize, restrict, redact, and expire telemetry. |

<br><br><br>

## What is evaluation-driven development for AI applications?

**Answer:**

### Make measurable behavior part of the development loop

**Evaluation-driven development (EDD)** is an approach in which teams define desired AI behavior through explicit evaluation criteria and representative test cases, then use those evaluations throughout design, implementation, and release. It extends test-driven thinking to systems whose outputs are probabilistic and whose quality cannot always be reduced to exact expected strings.

### How the workflow operates

1. **Define outcomes before implementation:** Translate user needs and risk requirements into observable criteria—task success, groundedness, safety, format validity, latency, and cost. State which criteria are hard gates and which are optimization goals.
2. **Create a baseline dataset and rubric:** Curate representative examples, expected properties or labels, edge cases, and adversarial cases. Use deterministic assertions where possible and human-annotated rubrics for subjective outcomes. Protect holdout examples from prompt/model tuning.
3. **Build the smallest viable system:** Implement prompts, retrieval, tools, or model selection, then run the evaluation suite to identify concrete failure modes rather than relying on anecdotal “good” outputs.
4. **Iterate against errors:** Group failures by cause, make a targeted change, and rerun relevant tests plus regression suites. Preserve the previous baseline so a local gain does not hide a regression in safety, another task slice, or operational performance.
5. **Automate continuous checks:** Run fast deterministic tests and selected evaluations in CI; run broader, more expensive human/model-judge evaluations before promotion. Pin data, model, prompt, evaluator, and configuration versions for reproducibility.
6. **Release with guardrails:** Use canaries or controlled experiments, monitor live outcomes, and roll back when predefined quality or safety gates fail. Convert production incidents and user corrections into governed tests.
7. **Refresh responsibly:** Update the dataset as tasks, language, users, and attack patterns change. Audit label quality, contamination, privacy, and evaluator calibration; do not optimize the product to a stale test set.

EDD does not mean every quality dimension has a perfect numeric metric. It means making the current definition of acceptable behavior explicit, testing it consistently, and documenting uncertainty where measurement is imperfect.

### Trade-offs, bottlenecks, and capacity assumptions

An evaluation-first loop catches regressions early but requires investment in datasets, labels, evaluator calibration, and CI compute. Overly narrow metrics create Goodhart effects; overly large suites slow iteration and may be expensive for stochastic model calls. Human review can be a release bottleneck. Team size, risk, and release cadence are unspecified, so maintain a fast low-cost gate for every change and a deeper risk-weighted suite for production promotion.

### Concise interview answer

“Evaluation-driven development starts by defining measurable task, safety, and operational criteria and building representative test cases before optimizing the AI behavior. I run those evaluations through iteration and CI, analyze failures by slice, and require regression and release gates before canary deployment. Deterministic checks, human review, and calibrated model judges complement one another. The suite is versioned, protected from tuning leakage, and refreshed from governed production feedback, with expensive evaluation depth matched to risk.”

### Revision summary

| Practice | Result |
|---|---|
| Define success first | Align implementation with user and risk needs. |
| Versioned evaluation set | Make comparisons repeatable. |
| Failure-driven iteration | Target root causes, not anecdotal outputs. |
| Automated gates | Catch regressions before full release. |
| Refresh and governance | Avoid stale, leaked, or privacy-risky tests. |

<br><br><br>

## Why is AI only as good as our definition of done?

**Answer:**

### The system optimizes only what the team defines and measures

An AI feature can produce fluent responses and still fail the user’s real task. “Definition of done” translates a broad product goal into testable acceptance criteria, risk boundaries, and operational requirements. If the criteria are vague or incomplete, teams may optimize visible proxies—such as engagement, benchmark scores, or answer length—while missing correctness, safety, fairness, accessibility, or reliability.

### What a useful definition of done includes

1. **User outcome:** State the task the user must be able to complete and how success will be verified, including acceptable alternatives or escalation paths.
2. **Quality dimensions:** Define task-specific accuracy, completeness, groundedness/citations, format, usability, and calibration expectations. Do not equate plausibility or preference with factual correctness.
3. **Safety and policy:** Specify disallowed outcomes, privacy and authorization boundaries, refusal/escalation behavior, and human oversight requirements for consequential decisions.
4. **Operational requirements:** Set latency/availability targets, error behavior, throughput or capacity limits, cost budgets, monitoring, and rollback conditions.
5. **Coverage and thresholds:** Identify supported languages, user/task cohorts, edge cases, and minimum sample/evidence requirements. Separate non-negotiable gates from metrics that can be traded off.
6. **Ownership and evidence:** Assign who approves rubric changes and what evidence—automated tests, human evaluations, red-team results, or live canary data—is required for release.
7. **Ongoing review:** Revisit criteria when users, data, models, policies, or deployment context changes; production feedback can reveal that the original definition omitted an important failure mode.

The definition should be specific enough to evaluate but not so narrow that it rewards gaming. Pair quantitative thresholds with qualitative review and document known blind spots. For high-impact applications, a “done” decision may require explicit domain, safety, legal, or compliance approval.

### Trade-offs, bottlenecks, and capacity assumptions

More criteria improve coverage but increase evaluation cost and can create conflicting objectives—for example, shorter latency versus more careful verification. A single aggregate score can conceal severe subgroup or safety regressions. Human and domain review improve judgment but require time and expertise. Product risk, user population, and release cadence are unspecified, so prioritize measurable hard constraints and high-severity risks, report slice-level evidence, and avoid declaring readiness based on a benchmark alone.

### Concise interview answer

“The definition of done determines what the team builds and what the system is rewarded for. For AI, it must cover user task success, correctness/grounding, safety and privacy boundaries, cohort coverage, and operational SLOs—not just fluent output or benchmark scores. I make hard gates explicit, define evidence and owners, use both metrics and human review, and revisit criteria as real usage exposes gaps. If ‘done’ is vague, evaluation will optimize the wrong proxy.”

### Revision summary

| Requirement | Why it matters |
|---|---|
| User outcome | Connects model behavior to actual task success. |
| Quality and safety | Prevents fluency or average scores from hiding failures. |
| Operations | Makes the feature deployable and supportable. |
| Slice coverage | Finds uneven performance across tasks/users. |
| Evidence/ownership | Makes release decisions auditable and revisable. |

<br><br><br>

## How do you evaluate LLM outputs? What metrics do you use?

**Answer:**

### Choose metrics that match the task and failure cost

There is no single metric that captures LLM output quality. Evaluation starts with the intended user outcome and a rubric describing what constitutes a correct, useful, safe response. A metric is only meaningful with its dataset, reference or judge, aggregation method, and deployment context.

### A practical metric set

1. **Correctness and task success:** Use exact match, accuracy, precision/recall/F1, or task-specific assertions when outputs have verifiable labels or structures. For open-ended tasks, assess whether required facts or actions are correct rather than demanding one exact phrasing.
2. **Completeness and relevance:** Use a human or calibrated judge rubric to check required information, relevance, and whether the answer addresses the request without unnecessary content. Measure omissions and unsupported additions separately.
3. **Grounding and factual support:** For retrieval-grounded answers, measure claim support against supplied evidence, citation precision/recall, and whether citations actually substantiate claims. Keep answer correctness separate from evidence attribution.
4. **Format and functional validity:** Validate JSON/schema adherence, tool-call arguments, code tests, or other machine-consumable constraints deterministically. Treat syntactic validity and semantic correctness as separate outcomes.
5. **Safety and calibration:** Measure policy violations, unsafe compliance, false refusals, privacy leakage, and appropriate escalation. For confidence-bearing tasks, assess calibration or selective risk where the system can abstain.
6. **Robustness and consistency:** Compare behavior across paraphrases, languages, input perturbations, and repeated runs. Report variance and important subgroup/task slices, not just a global mean.
7. **Operational metrics:** Track latency percentiles, time-to-first-token for streaming, token use, error rates, availability, and cost per successful task. These determine whether acceptable output can be delivered within production constraints.

Use automated metrics for scalable screening and reproducible checks, human evaluation for nuanced or high-stakes judgments, and LLM judges only after validating their agreement and bias. Report sample size, uncertainty, and evaluator details; investigate failures by category rather than optimizing a single score.

### Trade-offs, bottlenecks, and capacity assumptions

Reference-based metrics are fast but penalize valid alternative wording and may reward superficial overlap. Human review captures nuance but is costly and may vary; model judges scale but can be biased toward their own style or verbosity. Composite scores conceal trade-offs, while many separate metrics complicate release decisions. Task type, risk, and evaluation budget are unspecified, so define a small set of primary outcomes and hard safety/operational gates, then add diagnostic metrics that explain regressions.

### Concise interview answer

“I evaluate outputs against task-specific criteria, not one universal score. I use exact or task metrics for verifiable outcomes, schema/code/citation checks for functional validity and grounding, and calibrated human or LLM-judge rubrics for relevance and completeness. I separately measure safety, refusals, robustness, latency, and cost, report slice-level results and uncertainty, and investigate error categories. A fluent response or high aggregate metric does not establish correctness.”

### Revision summary

| Metric family | Examples |
|---|---|
| Task outcome | Accuracy, exact match, task success. |
| Quality | Relevance, completeness, helpfulness via rubric. |
| Grounding/format | Claim support, citation validity, schema checks. |
| Safety/robustness | Violations, false refusals, consistency, slices. |
| Production | Latency, availability, tokens, cost per success. |

<br><br><br>

## Explain BLEU, ROUGE, and BERTScore. When would you use each?

**Answer:**

### Three complementary text-similarity metrics

BLEU, ROUGE, and BERTScore compare generated text with one or more reference texts, but they capture different kinds of similarity. None directly proves factual correctness or usefulness; their scores depend on tokenization, reference quality, language, and task.

### How they differ

1. **BLEU (Bilingual Evaluation Understudy):** Measures modified n-gram precision—how much of the candidate’s n-gram content appears in the reference—typically with a brevity penalty so very short outputs are not rewarded. It was designed for machine translation and is most informative when wording is expected to align reasonably with references. It can penalize a valid paraphrase or a correct answer with different wording.
2. **ROUGE (Recall-Oriented Understudy for Gisting Evaluation):** A family of metrics commonly used for summarization. ROUGE-N measures n-gram overlap, ROUGE-L uses longest-common-subsequence structure, and variants may measure recall or F-measure. It can indicate whether a summary captures reference content, but lexical overlap does not guarantee that the summary preserves meaning, salience, or factuality.
3. **BERTScore:** Uses contextual token embeddings to align semantically similar tokens between candidate and reference, then computes precision, recall, and F1-like measures. It is more tolerant of paraphrase and synonym choices than exact n-gram overlap, but depends on the embedding model and can assign similarity to text that is semantically related yet factually wrong.

### Choosing and interpreting them

- Use BLEU for translation or constrained generation where reference phrasing and n-gram fidelity are useful signals.
- Use ROUGE for reference-based summarization comparisons, especially when content coverage matters.
- Use BERTScore when semantic similarity under varied wording is relevant.
- Pair these metrics with task-specific correctness, factuality/grounding, human review, or downstream functional tests. Use multiple references when valid answers vary, and report metric variant, tokenizer, language, dataset, and aggregation.

A model can improve one metric while becoming less useful: for example, more reference-like wording may reduce diversity or add unsupported details. Inspect examples and error slices alongside scores.

### Trade-offs, bottlenecks, and capacity assumptions

BLEU and ROUGE are inexpensive and reproducible but sensitive to lexical overlap and reference construction. BERTScore better captures some semantic matches but adds model dependency and still cannot establish truth. All three are vulnerable to benchmark/reference limitations and may be weak for dialogue, reasoning, or answers with many valid forms. Dataset size, language, and task are unspecified, so validate the chosen metric against human judgments on a representative sample and avoid treating any one score as a release gate for factual quality.

### Concise interview answer

“BLEU is modified n-gram precision with a brevity penalty and is commonly used for translation; ROUGE is a family of overlap/sequence metrics often used for summarization and emphasizes content coverage; BERTScore aligns contextual embeddings and is more tolerant of paraphrases. They measure similarity to references, not truth. I select based on task, specify the variant/tokenizer, and pair the score with human or task-specific correctness and grounding checks.”

### Revision summary

| Metric | Signal | Main limitation |
|---|---|---|
| BLEU | Candidate n-gram precision. | Penalizes valid wording differences. |
| ROUGE | N-gram/LCS overlap and coverage. | Overlap does not ensure salient, faithful content. |
| BERTScore | Contextual semantic alignment. | Similarity is not factual correctness. |
| Best practice | Match metric to task and validate against humans. | Never use as a universal quality score. |

<br><br><br>

## What is G-Eval, and how does it use LLMs for evaluation?

**Answer:**

### LLM-assisted rubric scoring

**G-Eval** is an LLM-based evaluation approach that uses a language model to judge generated text against specified evaluation criteria. In the commonly described method, the evaluator receives a task definition, evaluation steps or rubric, and the input/output context; it produces a score and often an explanation. The approach can be used for qualities that are difficult to capture with n-gram metrics, such as coherence, relevance, or summarization quality.

### Typical evaluation flow

1. Define the criterion precisely, with a scoring scale and anchors describing what each score means.
2. Provide the evaluator only the context required for the judgment—such as the source, user request, candidate response, and reference/rubric—while treating candidate text as untrusted data.
3. Ask the judge to assess explicit dimensions and return a constrained score format. Some G-Eval formulations use chain-of-thought-style intermediate evaluation steps or probability-weighted token scores; exact implementations and current best practice vary.
4. Run it on a representative set and compare its scores with independent human ratings. Measure agreement, calibration, position/style sensitivity, and consistency across repeated judgments.
5. Use it as a scalable signal for comparisons or diagnosis, not as sole ground truth. Review disagreement and high-risk examples with humans.

LLM judging can be sensitive to prompt wording, model version, answer length, ordering, and the judge’s own preferences. It may reward confident or verbose writing, miss subtle factual errors, or be manipulated by instructions embedded in the candidate response. Use structured prompts, blinded order for pairwise comparisons, explicit rubrics, and safeguards against judge prompt injection.

### Trade-offs, bottlenecks, and capacity assumptions

G-Eval can assess nuanced language quality at scale more flexibly than lexical overlap, but each judgment costs inference time and money and may be less reproducible than deterministic checks. A powerful judge can still share biases with the candidate model; judge-model upgrades may shift scores. Criterion, domain, and judge budget are unspecified, so calibrate against human labels, version the evaluator and prompt, and reserve human review for uncertain, high-impact, or disputed cases.

### Concise interview answer

“G-Eval uses an LLM as a rubric-based evaluator: provide the task context, candidate output, explicit criteria and scoring anchors, then ask for structured scores. It can scale judgments of relevance or coherence that simple overlap metrics miss. However, judge scores are model-dependent and can be biased by verbosity, order, prompt injection, or shared model preferences. I validate agreement with human ratings, version the judge and rubric, and use it alongside deterministic checks—not as ground truth.”

### Revision summary

| Stage | Practice |
|---|---|
| Rubric | Define criterion, scale, and score anchors. |
| Judge input | Provide relevant context and treat output as untrusted. |
| Calibration | Compare with independent human ratings. |
| Controls | Blind order, structured scores, version judge/prompt. |
| Use | Scalable signal with human/deterministic checks. |

<br><br><br>

## What is LLM-as-a-judge evaluation, and what are its limitations?

**Answer:**

### Use a model to score or compare model outputs

**LLM-as-a-judge** evaluation asks a language model to assess candidate outputs against a rubric, a reference, or another candidate. It is often used to estimate relevance, helpfulness, completeness, style, or preference at a scale that would be expensive to achieve entirely with human raters. It is an evaluator component, not an objective oracle.

### Design a more reliable judging setup

1. **Define the decision:** Specify whether the judge is scoring one response, checking criteria, or choosing between two. Write a narrow rubric with observable anchors and distinguish correctness from style.
2. **Provide sufficient context:** Include the user request and authoritative evidence/reference when available. Do not ask a judge to verify facts it cannot access.
3. **Reduce known biases:** For pairwise comparisons, randomize or blind candidate order and test position bias. Normalize irrelevant formatting where appropriate; do not make verbosity or confident tone a proxy for quality.
4. **Constrain outputs:** Request structured scores/reasons tied to rubric criteria. Treat candidate content as untrusted so embedded instructions cannot change the judge’s task.
5. **Calibrate and audit:** Compare judgments with human ratings on representative and high-risk subsets. Measure agreement, inter-rater variability, sensitivity to wording/order, false acceptance, and drift when the judge model changes.
6. **Combine methods:** Use deterministic validators for exact rules, unit tests or evidence checks for factual/functional claims, humans for nuanced or high-impact decisions, and model judges for scalable screening or triage.
7. **Record provenance:** Version judge model, prompt, rubric, context, sampling settings, and dataset. Report uncertainty and investigate disagreements instead of hiding them in an average.

### Important limitations

Judges can favor their own model family or style, show position/length bias, miss subtle hallucinations, and produce inconsistent scores. They can be manipulated by prompt injection in candidate text. A judge that shares the candidate’s failure modes may systematically endorse wrong answers. Scoring explanations can sound persuasive while being unsupported, so they should not be treated as evidence without verification.

### Trade-offs, bottlenecks, and capacity assumptions

LLM judges are faster and more scalable than large human panels but incur inference cost and still need calibration and monitoring. Stronger judges may cost more without resolving domain-specific ambiguity. Human review provides context but limits throughput. Dataset volume, judge budget, and risk are unspecified, so use judges for triage and repeated comparisons where validated, and reserve independent human or deterministic verification for high-stakes, factual, or safety-critical outcomes.

### Concise interview answer

“LLM-as-a-judge uses a model to score or compare outputs against an explicit rubric. It scales subjective evaluation, but it can have position, verbosity, style, and self-preference biases; it may miss factual errors or be prompt-injected. I randomize pair order, provide authoritative context, constrain structured judgments, and calibrate against human ratings. I combine it with deterministic checks and treat disagreements or high-risk decisions as requiring independent review.”

### Revision summary

| Limitation | Mitigation |
|---|---|
| Position/style bias | Blind and randomize order; test sensitivity. |
| Factual errors | Supply evidence; use deterministic/domain checks. |
| Prompt injection | Treat candidate as untrusted data. |
| Judge drift | Version and recalibrate evaluator. |
| High-stakes ambiguity | Human or independent expert review. |

<br><br><br>

## How do you conduct human evaluation for AI systems?

**Answer:**

### Make human judgments consistent, representative, and actionable

Human evaluation uses people to assess AI outputs or behavior against a defined task rubric. It is valuable for nuanced qualities—usefulness, tone, completeness, fairness, or whether an answer actually meets user needs—that are difficult to capture with automated metrics. Its quality depends on clear criteria, representative samples, trained raters, and analysis of disagreement.

### A practical study design

1. **Define the evaluation question:** Decide whether raters judge correctness, preference, safety, usability, or task completion. Separate dimensions rather than asking whether an answer is simply “good.”
2. **Build a representative sample:** Stratify by task type, difficulty, language, user cohort, and known risk cases. Randomize examples and avoid selecting only easy or memorable outputs. Determine sample size based on the decision and uncertainty you need.
3. **Write an operational rubric:** Provide score anchors, examples, acceptable alternatives, and instructions for uncertainty or “cannot judge.” Include criteria for factual support and safety where relevant. Avoid leading language that favors one system.
4. **Train and calibrate raters:** Run a pilot, discuss disagreements, refine ambiguous rubric text, and measure inter-rater agreement. Use multiple raters for subjective or high-impact judgments and independent adjudication for unresolved cases.
5. **Blind and randomize comparisons:** Hide model/version identity when possible, randomize output order, and use paired comparisons for preference questions. Control for presentation differences and avoid revealing irrelevant metadata.
6. **Protect participants and data:** Use consent and appropriate compensation, minimize personal data, control access, and provide escalation procedures for distressing or unsafe content. Follow domain-specific review and privacy requirements.
7. **Analyze transparently:** Report sample composition, rubric, rater count, agreement, uncertainty, and results by important slices. Preserve raw ratings securely and investigate disagreements rather than reporting only an average.
8. **Close the loop:** Convert recurring, well-understood failure patterns into automated regression tests or rubric updates, while retaining human review for genuinely judgment-dependent cases.

Human evaluation should not ask annotators to make decisions beyond their expertise. For medical, legal, financial, or other high-impact tasks, involve qualified reviewers and define governance separately from general preference labeling.

### Trade-offs, bottlenecks, and capacity assumptions

More raters and stratified samples improve reliability but increase cost and turnaround time. A detailed rubric reduces ambiguity but can constrain natural judgment; a short rubric is easier but may produce inconsistent labels. Agreement statistics do not prove the rubric measures the right construct. No budget, domain, or risk level is specified, so pilot first, estimate annotation time and adjudication needs, and allocate human review to high-impact slices and evaluator calibration.

### Concise interview answer

“I start with a specific evaluation question and a rubric with observable anchors, then sample representative tasks and train raters on a pilot. I blind model identity and randomize order for comparisons, use multiple raters where subjectivity matters, measure agreement, and adjudicate disagreements. I report slices and uncertainty, protect rater and user data, and involve qualified domain experts for high-impact decisions. Human labels complement automated tests and should feed a governed regression process.”

### Revision summary

| Element | Good practice |
|---|---|
| Rubric | Clear dimensions, anchors, and uncertainty option. |
| Sample | Representative, stratified, randomized examples. |
| Raters | Training, multiple judgments, agreement/adjudication. |
| Analysis | Slices, uncertainty, disagreement, provenance. |
| Governance | Privacy, compensation, safety, domain expertise. |

<br><br><br>

## What is red teaming, and how do you red team an LLM application?

**Answer:**

### Probe the system adversarially before attackers or failures do

**Red teaming** is a structured exercise in which testers deliberately probe an AI system for safety, security, privacy, reliability, and policy failures. For an LLM application, the target is the complete product—not only the base model—so the exercise includes prompts, retrieval, tools, permissions, orchestration, filters, logging, and human workflows. The goal is to find actionable weaknesses and improve controls, not to produce a list of clever prompts without a remediation path.

### A responsible red-team workflow

1. **Set scope and authorization:** Define systems, environments, data, time window, prohibited actions, safety constraints, escalation contacts, and rules of engagement. Use an isolated or controlled environment and do not test against third-party systems without authorization.
2. **Threat-model the application:** Identify assets, trust boundaries, user roles, model/provider dependencies, retrieved data, tool privileges, and likely abuse cases. Prioritize harms by likelihood and impact.
3. **Build test categories:** Include direct and indirect prompt injection, instruction/data boundary confusion, unauthorized retrieval, cross-tenant leakage, unsafe tool invocation, data exfiltration, harmful or disallowed requests, refusal bypass attempts, malformed inputs, and denial-of-service/resource abuse.
4. **Test realistic workflows:** Try single-turn and multi-turn scenarios, tool outputs containing untrusted instructions, retrieved documents, streaming/partial failures, and interactions between safety controls. Check the actual state changes and disclosures, not only the model’s verbal response.
5. **Record reproducible evidence:** Capture test setup, versioned model/prompt/index/policy/tools, input, observable outcome, severity, and impact with sensitive data minimized. Do not retain exploit-like content more widely than necessary.
6. **Triage and remediate:** Assign severity and owner; fix controls in trusted code—authorization, tool allowlists, schema validation, output controls, rate limits—rather than relying only on stronger prompt wording.
7. **Retest and institutionalize:** Verify fixes, add governed regression tests, track residual risk, and repeat after major model, tool, retrieval, or policy changes. Include cross-functional reviewers for safety and domain-specific harms.

For high-impact systems, red-team findings should feed release gates and incident response. Distinguish a model refusal from an actual security boundary: the application must enforce permissions and prevent unauthorized side effects independently.

### Trade-offs, bottlenecks, and capacity assumptions

Broad testing improves discovery but requires skilled reviewers, controlled environments, and time to validate findings. Automated attack suites scale but can miss novel, context-specific failures; human red teams find complex chains but are slower and may vary in coverage. Aggressive testing can create real data or service impacts if scope is weak. System risk, attack surface, and release cadence are unspecified, so prioritize high-impact threat paths, allocate time for remediation/retesting, and do not claim safety from a single exercise.

### Concise interview answer

“I red team the full LLM application under an authorized scope: model, retrieval, tools, permissions, filters, and workflows. I threat-model first, then test prompt injection, data leakage, unsafe tool actions, policy bypass, malformed inputs, and resource abuse in a controlled environment. I verify actual disclosures and side effects, record versioned reproducible evidence, fix root causes in trusted controls, and retest. Findings become regression tests and release gates; a model refusal alone is not a security boundary.”

### Revision summary

| Phase | Key practice |
|---|---|
| Scope | Authorization, rules of engagement, safe environment. |
| Threat model | Assets, trust boundaries, tools, data, likely harms. |
| Testing | Injection, leakage, unsafe actions, policy and resource abuse. |
| Remediation | Trusted-code controls and severity-based ownership. |
| Follow-through | Retest, regression coverage, repeat after changes. |

<br><br><br>

## How do you detect and measure hallucinations in LLM outputs?

**Answer:**

### Define hallucination relative to evidence and task

A **hallucination** is an output claim that is unsupported by, or inconsistent with, the information available or the task’s authoritative sources. The operational definition matters: in a closed-book creative task, inventing details may be expected; in a retrieval-grounded answer, unsupported factual claims or fabricated citations are failures. Measure claims and evidence, not just whether the response sounds confident.

### Detection and measurement workflow

1. **Specify the evidence boundary:** Identify the authoritative context—provided documents, verified database, known answer, or domain reference—and what the model is allowed to infer. Separate factual support, source attribution, and answer correctness.
2. **Decompose outputs into claims:** For factual responses, identify atomic claims and map each to supporting evidence. Evaluate whether support is sufficient, contradictory, absent, or irrelevant; assess citation existence and whether the citation entails the claim.
3. **Use deterministic checks where available:** Verify structured fields against source records, citations against retrieved documents, calculations with code, and tool results against authoritative state. Such checks are strong for constrained domains but do not cover all natural-language claims.
4. **Use calibrated human or model review:** Apply a rubric to claim support and factual consistency. LLM judges can help scale screening but may themselves hallucinate or accept plausible claims; validate them against domain-expert labels and audit difficult cases.
5. **Report meaningful rates:** Track unsupported-claim rate, supported-claim precision, citation precision/recall, answer-level factuality, and severity-weighted error rates. State denominator, sampling method, and uncertainty. A response-level binary label can obscure that one answer has many claims and only one is wrong.
6. **Test across conditions:** Include adversarial, ambiguous, stale-source, out-of-scope, and insufficient-evidence cases. Check whether the system abstains or asks a clarifying question when appropriate and whether answers remain grounded across model/prompt/retrieval versions.
7. **Reduce and monitor failures:** Improve source quality and retrieval, constrain answers to evidence, require citations when appropriate, provide abstention paths, and monitor production samples under privacy governance. Convert confirmed errors into regression cases.

Automated factuality metrics and model confidence are proxies; neither proves truth. In high-stakes settings, authoritative verification and qualified human review may be required.

### Trade-offs, bottlenecks, and capacity assumptions

Claim-level review is informative but expensive, especially for long outputs or specialized domains. Automated entailment/judge systems scale but can miss subtle contradictions and inherit model errors. More citation requirements improve auditability but can add latency and still produce irrelevant citations. Domain, output volume, and risk are unspecified, so sample proportionally by risk and use deterministic verification for high-consequence claims, with transparent confidence intervals and known limitations.

### Concise interview answer

“I define hallucination against an explicit evidence boundary, decompose answers into factual claims, and test whether each is supported, contradicted, or unverifiable. I combine source/database checks and citation validation with calibrated human or model review, then report claim-level and answer-level rates with denominators and severity. Tests include insufficient evidence and stale sources, where abstention may be correct. Confidence or fluency alone does not establish factuality.”

### Revision summary

| Measurement | What it reveals |
|---|---|
| Claim support | Unsupported or contradictory factual assertions. |
| Citation precision/recall | Whether references exist and substantiate claims. |
| Answer-level factuality | Overall user-facing correctness. |
| Severity/slices | Impact and where errors cluster. |
| Mitigation checks | Grounding, abstention, source freshness, regression. |

<br><br><br>

## What is adversarial testing for AI systems?

**Answer:**

### Test behavior under deliberately difficult inputs and conditions

**Adversarial testing** evaluates whether an AI system remains reliable, safe, and policy-compliant when inputs or environments are intentionally crafted to trigger failure. It can include malicious attempts, but also edge cases, distribution shifts, ambiguity, noise, and unexpected tool or dependency behavior. Red teaming is a broader, often human-led security/safety exercise; adversarial testing is a set of techniques that can be included in routine evaluation and CI.

### Build a systematic test set

1. **Define the threat and failure model:** Identify what must remain true—such as authorization, privacy, output validity, or task correctness—and who or what can provide untrusted inputs.
2. **Cover input transformations:** Test paraphrases, typos, multilingual or encoded content, long inputs, conflicting instructions, irrelevant context, malformed structures, and ambiguous requests.
3. **Probe application-specific boundaries:** For LLM systems, include direct/indirect prompt injection, retrieved text with instructions, tool-output attacks, data boundary crossing, unsafe tool arguments, and attempts to bypass refusals or confirmation.
4. **Test robustness and operations:** Exercise context-limit boundaries, streaming interruption, timeouts, rate limits, retries, stale retrieval, malformed model output, and partial dependency failure. Attack inputs should not cause unbounded cost or resource exhaustion.
5. **Use multiple generators:** Combine expert-designed cases, controlled mutations, approved automated adversarial generation, and production-derived failures that are privacy-scrubbed. Keep the source and transformation for each case traceable.
6. **Specify expected invariants:** Judge more than the final text. Assert no unauthorized data/action, bounded resource use, correct refusal/escalation, and valid output; allow acceptable response variation where exact strings are not required.
7. **Triage and regression-test:** Group failures by root cause and severity, remediate system controls, retest, and add durable cases to the evaluation suite. Keep held-out adversarial examples to reduce overfitting.

Authorized scope is essential when testing systems or tools beyond a local controlled environment. Adversarial examples are not a complete guarantee against unknown attacks; combine them with security review, monitoring, and defense in depth.

### Trade-offs, bottlenecks, and capacity assumptions

Large attack corpora improve breadth but can be costly to run and may contain noisy or unrealistic examples. Automatically generated attacks expand coverage but can bias toward known patterns; expert testing finds contextual chains but is slower. Exact-match assertions are brittle for generative outputs, whereas broad rubrics can miss specific invariant violations. System risk and release cadence are unspecified, so run fast, high-signal adversarial smoke tests on each change and deeper scenario-based testing before high-risk releases.

### Concise interview answer

“Adversarial testing deliberately challenges a system with malicious, ambiguous, malformed, or shifted inputs to see whether key invariants still hold. I threat-model first, then test prompt injection and trust boundaries, tool/data permissions, long or malformed inputs, and operational failures. Assertions cover actual data access, side effects, safety, and resource budgets—not only text. Findings are triaged by impact, fixed at the system boundary, retested, and added to regression coverage.”

### Revision summary

| Test family | Examples |
|---|---|
| Input robustness | Paraphrase, noise, ambiguity, language, boundary lengths. |
| Security/safety | Injection, leakage, unsafe actions, refusal bypass. |
| Operational | Timeouts, partial streams, rate limits, stale dependencies. |
| Assertions | Invariants, side effects, resource bounds, escalation. |
| Lifecycle | Triage, remediation, held-out tests, regression. |

<br><br><br>

## How do you build a regression test suite for AI applications?

**Answer:**

### Turn known failures and requirements into repeatable checks

An AI regression suite checks that a change to the model, prompt, retrieval/index, tool, policy, runtime, or data pipeline has not broken previously acceptable behavior. Because generated outputs may vary, a robust suite tests task properties and invariants rather than relying exclusively on exact text snapshots.

### Build the suite in layers

1. **Define versioned cases:** Each case should include the input/context, relevant configuration, expected outcome or rubric, risk/task tags, and provenance. Remove or protect sensitive data and keep a held-out set separate from routine tuning.
2. **Add deterministic tests first:** Test prompt rendering, schema and tool validation, authorization, retrieval filters, citations, policy rules, business invariants, and code/tool effects. These are fast and give precise failure signals.
3. **Add behavioral evaluations:** Use task-specific rubrics, reference properties, human labels, or calibrated judges for open-ended quality. For stochastic tasks, use controlled sampling/repetitions and compare distributions or thresholds rather than brittle exact strings.
4. **Cover slices and failures:** Include representative languages, user/task cohorts, difficulty levels, insufficient-evidence cases, safety/adversarial tests, malformed inputs, provider errors, and recovery behavior. Add confirmed production incidents after privacy review.
5. **Pin the evaluation context:** Record model/provider revision, prompt, tokenizer, retrieval snapshot/index, tools, policy, decoding parameters, evaluator version, and test data. Without this, score changes may not be attributable.
6. **Use tiered CI gates:** Run lint/unit/schema tests on every change; run a fast smoke eval for prompt/model changes; run broader quality, safety, and repeated tests before deployment. Set hard safety gates and quality/latency/cost thresholds before seeing results.
7. **Review failures and maintain the suite:** Inspect regressions by category and slice, triage flaky cases, refresh stale examples, calibrate judges, and retire cases only with documented rationale. Track false positives and test runtime so the suite remains usable.

Regression tests are evidence about the tested distribution, not proof that a model is safe or correct on all future inputs. Pair them with canary monitoring and incident response.

### Trade-offs, bottlenecks, and capacity assumptions

More cases improve coverage but increase inference cost and release time; stochastic repeats multiply both. Exact expected-output tests are cheap but brittle, while human/model judgment is richer but slower and less deterministic. Large suites can become flaky or overfit to known incidents. Application risk, test count, and release frequency are unspecified, so tier tests by cost and severity, run inexpensive invariants continuously, and reserve deep repeated evaluation for promotion.

### Concise interview answer

“I build a versioned suite from requirements, representative tasks, adversarial cases, and confirmed incidents. Deterministic checks cover schemas, permissions, retrieval, and side effects; rubric-based evaluations cover open-ended quality. I pin the full model/prompt/index/tool/evaluator context, use tiered CI gates, and compare stochastic outputs by properties or distributions rather than exact strings. Failures are reviewed by slice, flaky/stale tests are managed deliberately, and production canaries complement the offline suite.”

### Revision summary

| Suite layer | Purpose |
|---|---|
| Deterministic | Fast checks of schemas, permissions, and invariants. |
| Behavioral | Quality, grounding, safety, and task outcomes. |
| Adversarial/recovery | Abuse cases, failures, and degradation behavior. |
| Versioning | Attribute results to complete system configuration. |
| Tiered gates | Balance feedback speed, risk, and evaluation cost. |

<br><br><br>

## What are benchmark suites (MMLU, HumanEval, GSM8K), and how do you interpret them?

**Answer:**

### Standardized task collections provide comparative signals

Benchmark suites are collections of tasks and scoring procedures designed to compare model performance on defined capabilities. **MMLU** (Massive Multitask Language Understanding) covers multiple-choice questions across academic and professional subject areas. **HumanEval** is a set of programming problems evaluated by running generated code against tests (commonly reported with pass@k variants). **GSM8K** is a collection of grade-school math word problems whose answers can be checked against expected solutions, often using exact numeric-answer procedures.

### Interpret scores with methodology and scope

1. **Check the benchmark version and setup:** Dataset split, prompt format, few-shot examples, sampling/decoding, tool access, code execution environment, and scoring implementation can materially affect results.
2. **Understand the measured capability:** MMLU is not a general measure of reliable professional expertise; HumanEval tests a bounded set of coding problems, not complete software engineering; GSM8K measures a particular class of math word problems, not all reasoning.
3. **Read the metric correctly:** Accuracy, exact match, pass@k, and other scores have different meanings. pass@k estimates whether at least one of k samples passes under a specified setup; it is not the probability that a single deployed answer is correct.
4. **Check contamination and uncertainty:** Public benchmark items may appear in training data. Scores also vary by sampling and finite test size; use appropriate uncertainty estimates and independent or newer tests where possible.
5. **Compare like with like:** Ensure models are evaluated under comparable prompts, compute budgets, tools, and data. A leaderboard score without methodology is not a reliable comparison.
6. **Connect to deployment:** Add tests from the application’s actual task distribution, user language, safety requirements, and operational limits. Use benchmarks as diagnostics or broad screens, not as the sole release criterion.

### Trade-offs, bottlenecks, and capacity assumptions

Standard suites are convenient and reproducible but can be narrow, stale, contaminated, or misaligned with user tasks. Re-running code benchmarks may require safe, consistent sandboxes; larger sampling budgets increase cost and can make comparisons unequal. Model and application context are unspecified, so cite the exact suite/version/protocol and pair public benchmark results with representative held-out application evaluations and safety/latency/cost measures.

### Concise interview answer

“MMLU tests multiple-choice knowledge across subjects, HumanEval tests code generation using executable unit tests, and GSM8K tests grade-school math word problems. They provide useful, standardized signals, but each measures a bounded dataset and protocol. I check version, prompting, tools, scoring and contamination, interpret metrics such as pass@k carefully, and validate against the target application’s tasks. A benchmark win alone does not prove a model will work better for users.”

### Revision summary

| Benchmark | Typical signal | Boundary |
|---|---|---|
| MMLU | Multiple-choice subject knowledge. | Not equivalent to broad real-world expertise. |
| HumanEval | Code solution passing tests; pass@k. | Not full software engineering quality. |
| GSM8K | Grade-school math problem answers. | Not general reasoning across domains. |
| Interpretation | Verify protocol, contamination, and uncertainty. | Pair with application-specific evaluation. |

<br><br><br>

## What is benchmark contamination, and how do you guard against it?

**Answer:**

### Training exposure can inflate evaluation scores

**Benchmark contamination** occurs when evaluation items, answers, or close variants are present in a model’s training or adaptation data, or become exposed through repeated tuning and selection. The model may memorize examples or benefit from leaked labels, so a high score may reflect familiarity with the test rather than generalization. Contamination can also occur in application development when teams repeatedly tune prompts against a public test set.

### Detection and prevention

1. **Track data provenance:** Record benchmark sources, versions, publication dates, licenses, and how examples entered training, fine-tuning, prompt development, and evaluation. Ask model providers what training-data disclosures or contamination checks they can support, while recognizing that complete training corpora may not be inspectable.
2. **Protect evaluation splits:** Keep held-out items access-controlled and separate from training, prompt tuning, and model selection. Limit repeated peeking at test results; use development data for iteration and reserve a final test set for confirmation.
3. **Use fresh and private evaluations:** Add newly authored, private, or time-sensitive tasks that are unlikely to be in training. Ensure they are not later added to training or prompt examples without rotating the holdout.
4. **Probe memorization carefully:** Search for exact or near-duplicate overlap where data access permits, test paraphrased or transformed variants, and inspect suspiciously high item-level performance. These checks can find evidence but cannot prove absence of exposure.
5. **Use multiple evaluation sources:** Combine public benchmarks with domain-specific tasks, prospective user tasks, and tests requiring current or private evidence. Compare performance across splits and task slices.
6. **Control iterative tuning:** Log how many evaluations informed each change, avoid optimizing directly on the final test, and use statistical correction or a fresh holdout when many configurations are compared.
7. **Report limitations:** State what is known about dataset overlap, test access, model training data, and evaluation date. Do not claim a benchmark is contamination-free without evidence.

For code or math tasks, correct answers can appear verbatim online; removing exact matches alone does not address paraphrases, templates, or solution patterns. Contamination risk depends on both model training and the human evaluation workflow.

### Trade-offs, bottlenecks, and capacity assumptions

Private/fresh tests improve independence but cost time to author, validate, and maintain; public benchmarks improve comparability but are more exposed. Restricted test access protects integrity but can slow debugging and reproducibility. Exact deduplication is computationally manageable in many cases, while semantic overlap review can be expensive and imperfect. Training-data access and evaluation budget are unspecified, so use layered evidence and describe residual uncertainty rather than promising complete detection.

### Concise interview answer

“Benchmark contamination is exposure of evaluation examples or close variants during training, tuning, or repeated model selection, which can inflate apparent generalization. I track data provenance, separate development from protected test sets, limit test peeking, and add fresh private or prospective tasks. I check for exact and near-duplicate overlap where possible and report what is unknown. No deduplication method proves zero contamination, so benchmark results should be paired with independent application-specific evaluation.”

### Revision summary

| Risk | Mitigation |
|---|---|
| Training overlap | Provenance, deduplication, provider disclosure. |
| Prompt/model tuning leakage | Protected holdout and controlled access. |
| Public benchmark familiarity | Fresh, private, and prospective tasks. |
| Repeated comparisons | Log experiments; use new holdouts when needed. |
| Overclaiming | Disclose evidence and remaining uncertainty. |

<br><br><br>

## Your new model version scores higher on every benchmark, but users say it got worse. Why does this happen, and how do you find the problem?

**Answer:**

### Public benchmarks may not represent the product’s success criteria

A model can improve on standard benchmarks while regressing for users because benchmark coverage and deployment conditions differ. The new model may score better on the benchmark’s task mix yet be worse on a key language, domain, user cohort, response format, latency constraint, or interaction pattern. User reports may also reveal a real regression that aggregate metrics conceal—or reflect a change in product behavior or expectations rather than model capability alone.

### Diagnose systematically

1. **Validate the signal:** Confirm the model version and deployment window, quantify complaint rate and task impact, and check whether reports are representative or concentrated in a cohort. Avoid dismissing qualitative feedback because an average score improved.
2. **Compare like-for-like:** Replay the same privacy-approved production examples against old and new systems with identical prompts, tools, retrieval, decoding, and configuration. Separate model changes from prompt, tokenizer, routing, safety, and infrastructure changes.
3. **Slice results:** Break down quality by user task, language, domain, input length, safety/refusal state, structured-output validity, and important cohorts. A gain on many benchmark categories can hide a severe regression in a smaller but important slice.
4. **Inspect failures directly:** Review paired outputs with domain experts or blinded human raters. Identify whether the issue is factuality, instruction following, tone, verbosity, changed refusals, tool use, grounding, or format compatibility. Check changed tokenization/context truncation and provider behavior.
5. **Check benchmark validity:** Verify evaluation protocol and contamination risk, and assess whether benchmark metrics align with the observed user task. Benchmark gains are not evidence of product success if the benchmark is not representative.
6. **Use online evidence cautiously:** Compare canary cohorts or controlled experiments on task outcomes, corrections, abandonment, and support reports, while accounting for traffic mix and novelty. Avoid relying on noisy engagement proxies alone.
7. **Mitigate and close the loop:** Pause rollout or route affected tasks back if user impact is material. Add confirmed failures to the evaluation suite, update acceptance criteria, and promote only after the new version passes relevant slice-level and operational gates.

Also verify that the application actually serves the model build used in offline benchmarks; caching, routing, fallback, and rollout mistakes can create a model/configuration mismatch.

### Trade-offs, bottlenecks, and capacity assumptions

User feedback can surface rare but high-impact issues yet may be selection-biased; offline replay is controlled but can miss interactive behavior and current distribution. Broad slice analysis increases evaluation effort and can create false positives when sample sizes are small. A controlled canary limits exposure but needs traffic and time. User/task mix and risk are unspecified, so prioritize severity and affected cohorts, report uncertainty, and avoid declaring the issue resolved from a single aggregate score.

### Concise interview answer

“I treat the reports as a signal, then compare old and new systems on identical representative cases and slice by task, language, cohort, format, safety, and context length. I inspect paired failures with domain reviewers and verify the deployed configuration matches the benchmark setup. Public benchmark gains may not align with product tasks or may hide a slice regression. If impact is material, I pause or roll back, add the failure modes to evaluation, and re-promote only after relevant quality and operational gates pass.”

### Revision summary

| Diagnostic | What it checks |
|---|---|
| Deployment/config validation | Correct version, prompt, routing, tools, retrieval. |
| Paired replay | Isolates model behavior under equal conditions. |
| Slice analysis | Finds regressions hidden by overall averages. |
| Human failure review | Explains what users experience. |
| Mitigation | Canary pause/rollback and targeted regression coverage. |

<br><br><br>

## How do you evaluate a RAG system end-to-end?

**Answer:**

### Evaluate retrieval and generation as one user-facing pipeline

An end-to-end RAG evaluation asks whether the system retrieves the right evidence and produces a correct, grounded, useful answer within operational and safety constraints. Evaluating only the final response makes it hard to distinguish retrieval failure from generation failure; evaluating retrieval alone does not establish that the answer used evidence correctly.

### Layered evaluation

1. **Create representative questions and evidence:** Build a versioned set covering answerable, unanswerable, ambiguous, multi-hop, stale-document, and adversarial cases. Record expected answers or facts, relevant source passages, and permission scope. Protect private data and holdouts.
2. **Measure retrieval:** Evaluate relevant-document and passage recall/precision, ranking quality such as MRR or nDCG where labels support them, coverage at k, freshness, and access-control correctness. Include cases where the right behavior is to retrieve nothing or abstain.
3. **Measure context construction:** Check chunk boundaries, duplicate/irrelevant context, token-budget truncation, source metadata, citation preservation, and whether retrieved content respects tenant/document permissions.
4. **Measure answer quality:** Score correctness, completeness, relevance, groundedness, citation precision/recall, and appropriate abstention. Verify each claim against the supplied evidence; format validity and user utility may need separate criteria.
5. **Test robustness and safety:** Include prompt injection in retrieved documents, conflicting or outdated sources, missing evidence, malformed queries, cross-tenant access attempts, and tool/model failures. Confirm that retrieved instructions are treated as untrusted data.
6. **Evaluate operations:** Track end-to-end and stage latency, token usage, retrieval/model errors, cache behavior, throughput, and cost per successful task. Segment by query class, language, corpus, and access scope.
7. **Run ablations and release checks:** Compare retrieval, reranker, chunking, prompt, and model changes independently where possible. Use offline regression suites and canary traffic; turn confirmed production failures into tests.

Use deterministic source matching and domain review when possible; LLM judges can assist with rubric scoring but need calibration. A high answer score should not hide permission leakage or unsafe citations.

### Trade-offs, bottlenecks, and capacity assumptions

Human claim-level annotation is accurate but costly; automatic relevance labels and judges scale but may be noisy. Larger k can improve recall while adding irrelevant context, token cost, and latency. End-to-end scores localize failures poorly unless paired with stage metrics and ablations. Corpus size, query mix, and risk are unspecified, so measure both component and task-level behavior, stratify by workload, and optimize recall/quality against context and latency budgets.

### Concise interview answer

“I evaluate RAG at retrieval, context assembly, and answer levels. I measure relevant-passage recall/ranking and permission correctness, then assess answer correctness, completeness, claim support, citations, and abstention against the retrieved evidence. Tests cover unanswerable questions, stale/conflicting sources, prompt injection, and tenant boundaries. I track latency and cost by stage, run ablations to localize regressions, and use canaries after offline gates. Retrieval metrics alone or a fluent final answer are not enough.”

### Revision summary

| Layer | Example checks |
|---|---|
| Retrieval | Recall/precision, ranking, freshness, access scope. |
| Context | Chunking, relevance, duplication, truncation, metadata. |
| Generation | Correctness, grounding, citations, abstention. |
| Safety | Injection, conflicting sources, tenant isolation. |
| Operations | Latency, throughput, errors, cost, canary behavior. |

<br><br><br>

## How do you evaluate the quality of AI agents?

**Answer:**

### Judge goals, trajectories, constraints, and resource use

AI agent quality is broader than the wording of its final response. An agent must achieve the user’s goal, respect constraints and permissions, use tools appropriately, recover from failures, and stop within acceptable time and cost. Evaluation should examine both outcome and process, because a correct result reached through an unauthorized action is not acceptable.

### A multidimensional evaluation

1. **Define task outcomes:** Specify the desired final state and acceptable solution paths for each task. Include normal, ambiguous, long-horizon, and recovery scenarios with verifiable success criteria.
2. **Score execution traces:** Assess planning quality, tool choice, argument validity, observation use, unnecessary steps, repeated loops, task decomposition, and stopping behavior. Do not require hidden chain-of-thought; use observable actions and state transitions.
3. **Verify external effects:** In a sandbox, assert database or file changes, API calls, and other side effects. Check authorization, confirmation, reversibility, and idempotency independently of the agent’s textual claim.
4. **Assess answer quality:** Evaluate correctness, completeness, clarity, calibrated uncertainty, and whether the agent communicates partial failure or asks for clarification when needed.
5. **Test safety and robustness:** Include prompt injection, untrusted tool output, permission boundaries, malformed observations, unavailable tools, conflicting goals, and attempts to induce harmful or unauthorized actions.
6. **Measure efficiency and reliability:** Track success rate, steps, tool calls, latency, tokens, cost per successful task, retries, timeouts, human takeover, and outcome variance across repeated runs.
7. **Use layered evaluators:** Combine deterministic assertions and simulations with human review for nuanced outcomes and calibrated LLM judges for scalable scoring. Maintain a versioned suite and test changes through offline evaluation and canaries.

Report results by task and risk slice, not only a global success percentage. If a task has multiple valid paths, use rubric-based criteria and invariants rather than matching one recorded trajectory.

### Trade-offs, bottlenecks, and capacity assumptions

Realistic environments and long-horizon tasks reveal planning/recovery failures but are expensive and can be hard to reset reproducibly. Deterministic state checks are strong for side effects but do not measure conversational utility; judges scale but may miss dangerous actions. Repeated trials improve confidence for stochastic agents but multiply cost. Agent use cases and risk are unspecified, so prioritize tasks by impact, isolate side effects in sandboxes, and set success/efficiency thresholds before comparing versions.

### Concise interview answer

“I evaluate agent quality across task success, trajectory quality, safety, and efficiency. I verify the final state and tool side effects in a sandbox, inspect observable tool choices/arguments/retries/stopping, and assess the response for correctness and honest uncertainty. Tests include prompt injection, failures, permissions, and recovery. I combine deterministic assertions, human review, and calibrated judges, repeat stochastic tasks, and report by scenario and risk—not just one overall pass rate.”

### Revision summary

| Dimension | Evidence |
|---|---|
| Outcome | Goal achieved and correct final state. |
| Process | Tool choices, arguments, retries, loops, stopping. |
| Safety | Permissions, side effects, injection and constraints. |
| Efficiency | Steps, latency, tokens, cost, interventions. |
| Confidence | Repeated runs, task slices, versioned test suite. |

<br><br><br>

## How would you evaluate an autonomous coding agent? Why can SWE-bench pass rates be misleading?

**Answer:**

### Evaluate the end-to-end software change, not only benchmark closure

An autonomous coding agent should be assessed on whether it resolves a task in a realistic repository while preserving existing behavior, producing maintainable changes, and operating safely. Evaluation should use isolated, reproducible environments and test the full workflow: repository understanding, edits, commands, debugging, and final report.

### Evaluation dimensions and setup

1. **Use realistic, held-out tasks:** Include bug fixes and feature work across repositories, languages, difficulty levels, and issue types. Ensure task statements and repositories are not leaked into agent tuning where feasible; track environment and dependency versions.
2. **Verify functional correctness:** Run hidden tests and relevant existing suites, plus tests for requested behavior. Check regressions, edge cases, types/lint/build where applicable, and whether the change actually addresses the issue rather than gaming a test.
3. **Assess patch quality:** Review scope, maintainability, readability, compatibility, security, documentation, and unnecessary changes. A test-passing patch can still be brittle, overfit, or unsafe.
4. **Measure autonomy and efficiency:** Track tasks solved without intervention, number of attempts/commands, tool errors, wall-clock time, token and compute cost, context use, and recovery from failed tests. Define what counts as an intervention.
5. **Test realistic constraints:** Use controlled network/dependency access, limited permissions, resource/time budgets, and safe handling of repository data. Observe whether the agent follows project instructions and reports uncertainty accurately.
6. **Use paired human review:** For representative tasks, reviewers blinded to system/version assess patch correctness and maintainability. Keep deterministic test outcomes separate from subjective quality scores.
7. **Report task-level distributions:** Show solve rate, regression rate, partial credit if defined, cost/time, and results by task/repository category with uncertainty. Avoid treating one leaderboard number as production readiness.

### Why SWE-bench pass rates can mislead

SWE-bench evaluates issue resolution on real repository tasks, but a pass rate depends on the benchmark subset/version, harness, test environment, attempt budget, model/tool setup, and what “resolved” means. Passing tests may not prove a robust patch: tests can be incomplete, solutions can overfit visible tests, and hidden-test coverage is imperfect. Results may also be inflated by training contamination or benchmark-specific tuning. Conversely, setup failures can understate capability. A single number says little about security, reviewability, intervention burden, deployment success, or performance on an organization’s own repositories.

### Trade-offs, bottlenecks, and capacity assumptions

Repository-scale evaluations are costly to run and reset; broad task diversity improves external validity but increases annotation and environment maintenance. Hidden tests reduce overfitting but can still be incomplete, and human patch review is expensive. Agent runs are stochastic and cost varies sharply with retries. Task count, agent budget, and target workflow are unspecified, so report protocol and confidence intervals, evaluate patches—not just test status—and run a pilot on representative internal tasks before estimating productivity.

### Concise interview answer

“I evaluate coding agents in reproducible, isolated repositories using held-out issues, hidden and existing tests, and review of patch quality, regressions, security, and maintainability. I also measure intervention rate, attempts, latency, and cost. SWE-bench is useful evidence, but its pass rate depends on subset, harness, budget, environment, test completeness, and contamination; passing tests can still yield brittle patches, while setup failures can distort results. I pair benchmark results with blinded patch review and representative internal tasks.”

### Revision summary

| Dimension | What to verify |
|---|---|
| Functional | Hidden/existing tests, requested behavior, regressions. |
| Patch quality | Maintainability, scope, security, compatibility. |
| Autonomy | Intervention, attempts, tool use, recovery. |
| Cost | Time, tokens, compute, retries. |
| Benchmark interpretation | Version, harness, contamination, test completeness, external validity. |

<br><br><br>

## What is the difference between offline and online evaluation for AI systems?

**Answer:**

### Controlled tests versus evaluation in live use

**Offline evaluation** assesses a model or application on a fixed dataset or controlled environment before or apart from serving real user traffic. **Online evaluation** measures behavior while the system is deployed, using live outcomes, controlled experiments, production telemetry, and/or human feedback. They answer different questions and are most useful together.

### Key differences

| Aspect | Offline | Online |
|---|---|---|
| Data | Curated, replayed, or simulated examples. | Real requests/outcomes, usually sampled or assigned by cohort. |
| Control | Inputs and system configuration can be held constant. | Traffic mix, users, environment, and time vary. |
| Strength | Repeatable, safer, and useful for regression and adversarial tests. | Measures actual product impact and uncaptured distribution behavior. |
| Limitation | May not represent current users or feedback loops. | Noisy, potentially risky, slower for delayed outcomes, and subject to confounding. |
| Typical methods | Unit/behavioral tests, benchmark suites, simulations, human/model grading. | A/B tests, canaries, shadow traffic, task completion, corrections, support signals. |

### Combine the methods responsibly

1. Define the question and metrics first: task success, quality/safety guardrails, latency, availability, and cost.
2. Use offline tests to screen candidates, explore edge cases, and reject clear regressions before exposing users.
3. Use shadow traffic for operational comparison when outputs can be safely evaluated without affecting users; avoid duplicating side-effecting tool actions.
4. Roll out through a canary or randomized experiment with stable assignment, predefined stop conditions, and appropriate privacy controls.
5. Account for user/task mix, seasonality, delayed outcomes, novelty, sample size, and interference between cohorts.
6. Feed confirmed, governed production failure patterns into offline regression suites without leaking test data into training or tuning.

Online signals such as clicks, dwell time, or user ratings are proxies and can be biased or manipulated. Offline scores can also be misleading if the dataset is stale, contaminated, or misaligned. For high-impact applications, online testing should not replace predeployment safety review or human oversight.

### Trade-offs, bottlenecks, and capacity assumptions

Offline evaluation is repeatable and safer but costs time to curate and may miss distribution shift. Online evaluation is realistic but exposes users to variation and often needs much more traffic to distinguish small effects. Shadowing increases inference cost; A/B tests can be confounded by cohort or novelty effects. Traffic, risk, and release cadence are unspecified, so use offline gates for every candidate and limit online exposure to changes that pass them, with a pre-agreed rollback threshold.

### Concise interview answer

“Offline evaluation tests candidates on fixed representative data or simulations, making it controlled, repeatable, and useful for regressions and adversarial cases. Online evaluation measures live impact through canaries, A/B tests, shadow traffic, and production outcomes, but is noisier and exposes users. I use offline tests as a safety and quality gate, then a controlled online rollout with guardrails and rollback. Production signals feed back into offline tests after privacy and contamination review.”

### Revision summary

| Evaluation | Best for | Main caution |
|---|---|---|
| Offline | Reproducible regression, edge, and safety testing. | Dataset may not match deployment. |
| Online | Real user/product impact and distribution shift. | Noise, risk, bias, and delayed outcomes. |
| Combined | Pre-release gate plus live confirmation. | Govern data feedback and stop conditions. |

<br><br><br>

## How do you measure factual consistency in LLM outputs?

**Answer:**

### Compare claims with the relevant evidence source

**Factual consistency** measures whether statements in an output agree with a defined source of truth. In summarization, the source may be the input document; in RAG, it may be retrieved passages; in a data assistant, it may be an authoritative database. This is narrower than general truth: an answer can be consistent with a flawed source while still being false in the world.

### Measurement process

1. **Define the reference boundary:** State which evidence is authoritative, whether inference is allowed, and how to treat missing, conflicting, or time-sensitive information.
2. **Decompose the response:** Identify atomic factual claims, including important qualifiers, numbers, dates, and causal relationships. For very long outputs, use a consistent claim-extraction procedure and audit it.
3. **Check support and contradiction:** For each claim, classify it as supported, contradicted, unsupported, or not verifiable from the evidence. Measure claim-level support and contradiction rates, then compute answer-level outcomes under an explicit rule.
4. **Validate citations:** Check that cited sources exist, are accessible to the user, and actually entail the associated claim. Track citation precision and evidence coverage separately; citation presence alone is not support.
5. **Use suitable evaluators:** Prefer deterministic checks for structured facts and authoritative records. Use trained domain reviewers for high-impact or ambiguous claims; calibrated NLI/LLM judges can assist at scale but must be compared with human labels.
6. **Test difficult cases:** Include contradictory sources, stale evidence, insufficient context, paraphrase, numerical claims, and abstention cases. Check whether the system distinguishes “not found” from “false.”
7. **Report uncertainty and slices:** Provide denominators, sampling method, confidence intervals, claim severity, and results by task/source/language. Convert verified failures into regression cases.

Do not treat model confidence, fluency, or self-reported citations as proof. For high-consequence answers, use independent authoritative verification or qualified human review.

### Trade-offs, bottlenecks, and capacity assumptions

Claim-level annotation is precise but expensive and may require domain expertise. Automated judges scale but can miss subtle entailment, negation, and temporal contradictions. A single answer-level score is cheaper but hides how many claims are unsupported. Output lengths, domain risk, and review budget are unspecified, so use automated screening for broad coverage, sample human audits to calibrate it, and reserve expert review for high-severity claims.

### Concise interview answer

“I define factual consistency against an explicit authoritative evidence set, extract atomic claims, and classify each as supported, contradicted, or unverifiable. I validate citations for both existence and entailment, report claim- and answer-level rates with denominators, and test conflicting, stale, and insufficient evidence. Deterministic source checks and expert review are strongest for high-impact facts; NLI or LLM judges are scalable aids that need calibration. Consistency with a source does not prove the source itself is true.”

### Revision summary

| Check | Measures |
|---|---|
| Claim support | Evidence entails each factual assertion. |
| Contradiction | Output conflicts with source. |
| Citation validity | Source exists and supports cited claim. |
| Abstention | Correct handling of missing/conflicting evidence. |
| Reporting | Claim-level and answer-level rates, slices, uncertainty. |

<br><br><br>

## How do you evaluate multi-turn conversation quality?

**Answer:**

### Evaluate the conversation state and user goal across turns

Multi-turn quality cannot be measured by judging each assistant message in isolation. Later responses depend on whether the system remembers relevant context, resolves references, respects corrections, maintains consistent commitments, and advances the user’s goal without carrying forward stale or unauthorized information.

### Evaluation dimensions and method

1. **Construct realistic dialogues:** Include short and long conversations, topic changes, corrections, ambiguous references, interruptions, user preferences, and attempts to override policy. Define the expected state or acceptable continuation.
2. **Measure goal progress:** Assess whether the conversation resolves the user’s task, asks useful clarifying questions when needed, and avoids unnecessary turns. Track task completion and user effort, not just message-level preference.
3. **Test context handling:** Check coreference, factual recall from prior turns, appropriate use of conversation summaries/memory, and whether irrelevant or outdated details are ignored. Include context-window truncation and summary-loss scenarios.
4. **Measure consistency and correction:** Verify that answers do not contradict earlier supported facts or promises without explanation, and that the assistant updates beliefs when the user corrects information. Distinguish consistency from stubbornly repeating a previous error.
5. **Assess safety and privacy over time:** Test cross-turn prompt injection, gradual elicitation of sensitive data, permission changes, user identity boundaries, and whether memory is retained or forgotten as policy requires.
6. **Evaluate response quality:** Use turn- and conversation-level rubrics for relevance, completeness, tone, calibration, refusal, and appropriate escalation. Human raters can judge coherence; deterministic tests can verify state and memory behavior.
7. **Track efficiency and robustness:** Measure turns to resolution, abandoned conversations, repeated questions, latency/cost, tool calls, and variance across paraphrased dialogue histories. Report by task and user cohort.

Use paired dialogue evaluations and preserve prior turns and system configuration so a regression can be reproduced. User satisfaction is useful but should be combined with objective task and safety evidence.

### Trade-offs, bottlenecks, and capacity assumptions

Long dialogue simulations reveal memory and consistency failures but are costly to author and evaluate; short-turn tests are cheaper but miss accumulation effects. Human judgment is valuable for conversational coherence, while automated state checks scale for recall/privacy invariants. Session length, memory policy, and target user mix are unspecified, so build a stratified suite of dialogue lengths and focus expensive review on long-horizon and high-risk scenarios.

### Concise interview answer

“I evaluate whole dialogues, not isolated turns. Tests cover goal completion, useful clarification, context/reference resolution, memory and truncation, correction handling, consistency, safety/privacy across turns, and effort to resolution. I combine rubric-based human review for coherence with deterministic checks on state, permissions, and memory, then measure turns, latency, cost, and abandonment by scenario. The suite includes long and adversarial conversations because many failures emerge only through accumulated context.”

### Revision summary

| Dimension | Example check |
|---|---|
| Goal progress | Task completion, clarification, turns to resolution. |
| Context | Reference resolution, relevant recall, truncation behavior. |
| Consistency | Correct updates after corrections; justified changes. |
| Safety/privacy | Cross-turn leakage, memory and identity boundaries. |
| Efficiency | Repetition, abandonment, latency, cost. |

<br><br><br>

## What is the role of golden datasets in AI evaluation?

**Answer:**

### A trusted reference set for comparison and regression

A **golden dataset** is a curated set of evaluation examples with trusted labels, expected properties, references, or expert judgments that teams use as a stable baseline. It helps compare models, prompts, retrieval configurations, and application releases over time. “Golden” does not mean infallible: labels can be incomplete, subjective, stale, or biased.

### How to use one well

1. **Represent the intended workload:** Include common tasks, important edge cases, user/task slices, safety cases, and examples where the right behavior is to abstain or ask for clarification.
2. **Store evaluation semantics:** For each example, record the input/context, expected answer or rubric, source of truth, tags, label provenance, and known ambiguity. Use acceptable ranges/properties when many outputs are valid rather than a single canonical string.
3. **Validate labels:** Use domain experts or adjudication for high-impact cases, measure agreement where judgments are subjective, and document uncertainty. Do not silently force ambiguous cases into an artificial binary label.
4. **Version and govern the data:** Track dataset versions and changes, access, licensing, privacy, retention, and provenance. Remove or protect personal data and avoid using protected test examples in model/prompt tuning.
5. **Use for regression and diagnosis:** Compare candidates against a baseline with consistent prompts, model/configuration, evaluators, and metrics. Report task slices and uncertainty; investigate examples where performance moves in either direction.
6. **Refresh without losing comparability:** Add new production failure modes and evolving tasks through review; preserve a stable core for longitudinal trends and rotate/hold out examples that have been repeatedly used for tuning.

Golden data should be paired with fresh/adversarial tests and online evidence. A system can overfit to a small curated set or score well on examples that do not represent real users.

### Trade-offs, bottlenecks, and capacity assumptions

High-quality labels and expert adjudication are costly; a small stable set supports fast iteration but can become stale and overfit. A frequently refreshed set reflects change but complicates trend comparisons. Sensitive production-derived examples require governance and may not be reusable. Dataset size, domain, and release cadence are unspecified, so maintain a representative stable core plus a governed rotating set and allocate expert labeling by risk.

### Concise interview answer

“A golden dataset provides trusted, versioned examples and labels or rubrics for comparing AI changes and catching regressions. I make it representative, document provenance and ambiguity, validate high-impact labels, and protect it from leakage into tuning. I report slices and uncertainty rather than only an aggregate score, and pair the stable set with fresh adversarial and production-derived cases. Golden labels are a useful reference, not unquestionable truth.”

### Revision summary

| Role | Good practice |
|---|---|
| Baseline | Stable comparison across versions. |
| Coverage | Representative tasks, slices, edges, and abstention. |
| Label quality | Provenance, expert review, ambiguity documentation. |
| Governance | Versioning, privacy, access, holdout protection. |
| Maintenance | Stable core plus reviewed fresh cases. |

<br><br><br>

## How do you build an eval set when there is no labelled ground truth and domain experts are expensive?

**Answer:**

### Combine weak signals, structured rubrics, and targeted expert review

When ground-truth labels are unavailable and experts are scarce, build evaluation evidence in layers rather than pretending a weak proxy is definitive. The objective is to create a useful, auditable set of cases with known uncertainty and enough validation to compare changes.

### A practical data-building strategy

1. **Define observable success properties:** Break the task into criteria that can be checked without a full reference answer—for example schema validity, citations to supplied sources, correct tool state, required constraints, or appropriate abstention.
2. **Generate candidate examples from multiple sources:** Sample representative and difficult inputs from privacy-approved usage, synthetic scenarios, domain documentation, issue reports, and adversarial transformations. Track provenance and avoid reusing benchmark items as if they were fresh.
3. **Use weak supervision carefully:** Apply heuristics, existing rules, source matching, user outcomes, or multiple model judges to create provisional labels. Preserve label source/confidence and do not collapse disagreement into certainty.
4. **Collect pairwise preferences where easier:** For some subjective tasks, raters can more reliably choose between two anonymized outputs than assign an absolute score. Randomize order and separately test factual and safety constraints.
5. **Use active sampling:** Prioritize examples with model disagreement, high uncertainty, high user impact, new behavior, or likely failure. This directs scarce expert time to cases where labels change decisions.
6. **Reserve expert review for calibration:** Ask domain experts to label a representative, stratified subset and adjudicate high-impact disagreements. Use this subset to estimate weak-label/judge error and refine the rubric.
7. **Build a layered set:** Keep separately tagged gold/expert-labeled, silver/weak-labeled, synthetic, adversarial, and production-derived examples. Report performance by source and confidence rather than pooling them uncritically.
8. **Iterate and govern:** Pilot the rubric, assess inter-rater agreement, add confirmed failures, protect privacy, and hold out examples from tuning. Revalidate labels as policies, domain knowledge, and product use change.

Synthetic data can improve coverage but may share the generator’s blind spots or unrealistic assumptions. User engagement and thumbs-up are noisy proxies and should not be treated as ground truth without validation.

### Trade-offs, bottlenecks, and capacity assumptions

Weak labels increase scale but introduce systematic noise; expert labels improve validity but cost time and may still disagree. Active sampling can improve information per review but may underrepresent common experiences if not balanced with representative sampling. Multiple judge models add cost and may share biases. Expert capacity and task risk are unspecified, so reserve a stratified calibration sample, target expert effort at high-impact uncertainty, and report label confidence/source explicitly.

### Concise interview answer

“I define verifiable properties first, then combine representative examples, source-based checks, weak labels, pairwise preferences, and synthetic/adversarial cases. I track each label’s provenance and confidence instead of treating proxies as truth. Active sampling sends high-uncertainty or high-impact disagreements to experts, whose reviewed subset calibrates the broader labels. I keep gold, silver, and synthetic data separate, protect holdouts, and report results by label quality and source.”

### Revision summary

| Data source/method | Use |
|---|---|
| Deterministic properties | Check schemas, citations, actions, constraints. |
| Weak labels/judges | Scale provisional signals with confidence metadata. |
| Pairwise preferences | Easier judgments for subjective comparisons. |
| Active expert review | Spend scarce expertise where it matters most. |
| Tiered datasets | Keep gold, silver, synthetic, and production cases distinct. |

<br><br><br>

## How do you implement continuous evaluation for production AI systems?

**Answer:**

### Keep measuring behavior as models, data, and usage change

Continuous evaluation is the ongoing assessment of an AI system after deployment, combined with pre-release evaluation in the development lifecycle. It helps detect regressions, distribution shifts, provider/model drift, safety issues, and changing user needs that a one-time benchmark cannot reveal. It is not simply logging every prompt and asking another model to score it.

### A privacy-aware evaluation loop

1. **Define signals and decision thresholds:** Track task success proxies, quality/safety outcomes, refusals, errors, latency, cost, user corrections, and human escalation. Label each signal as a direct measurement or proxy and define actions for threshold breaches.
2. **Capture a governed sample:** Use privacy-approved sampling or opt-in feedback, redact/minimize sensitive fields, and apply retention/access policies. Avoid storing raw prompts and outputs unless necessary and authorized.
3. **Evaluate through complementary paths:** Run deterministic checks automatically on suitable outputs; use calibrated model judges for scalable rubric-based screening; send high-risk, low-confidence, or disagreement cases to human reviewers. Do not equate thumbs-up or engagement with correctness.
4. **Compare against versioned baselines:** Record model/provider, prompt, retrieval/index, tool, policy, evaluator, and routing versions. Compare quality and operational metrics by task, language, cohort, and risk slice; detect changes in input distribution as well as output behavior.
5. **Use online rollout controls:** For changes, conduct offline gates followed by shadow/canary or randomized experiments where appropriate. Set stop/rollback criteria before exposure and keep safety monitoring active throughout.
6. **Create a learning loop:** Triage incidents and recurring errors, update evaluation data/rubrics after governance review, and add confirmed failures to regression tests. Keep protected holdouts separate from tuning and account for contamination.
7. **Monitor the evaluators:** Audit judge-human agreement, label drift, sampling bias, missing telemetry, and alert quality. A change in the evaluator can look like a model regression.

Continuous evaluation complements production observability: telemetry shows what happened operationally, while evaluation asks whether outcomes meet quality and policy requirements. Neither alone is sufficient.

### Trade-offs, bottlenecks, and capacity assumptions

Broader samples improve coverage but increase inference, review, storage, and privacy costs. Automated judges scale but may miss subtle errors; human review is higher quality for ambiguous cases but has limited throughput. Delayed user outcomes and low-volume subgroups make detection slower. Traffic, retention, risk, and evaluator budget are unspecified, so use risk-weighted sampling, fast deterministic checks, targeted human escalation, and explicit confidence/alert thresholds.

### Concise interview answer

“I establish versioned quality, safety, and operational signals, then continuously evaluate a privacy-governed sample using deterministic checks, calibrated judges, and targeted human review. I segment by task and cohort, compare against baselines, and monitor input-distribution and evaluator drift. Changes go through offline gates and controlled online rollout with predefined stop criteria. Confirmed production failures update regression tests, while protected holdouts prevent tuning leakage.”

### Revision summary

| Loop component | Purpose |
|---|---|
| Signals/thresholds | Define what changes matter and when to act. |
| Governed sampling | Evaluate real behavior without unnecessary data exposure. |
| Multiple evaluators | Balance scale, determinism, and human judgment. |
| Versioned comparisons | Attribute changes to model and application components. |
| Feedback to tests | Turn confirmed incidents into regression coverage. |

<br><br><br>

## How do you evaluate bias in AI model outputs?

**Answer:**

### Define the harm and context before selecting a fairness metric

Bias evaluation examines whether an AI system produces systematically different or harmful outcomes across relevant people, groups, languages, or contexts. There is no single universal fairness metric: the right analysis depends on the task, affected populations, decision consequences, available lawful data, and the organization’s policy and legal obligations.

### A careful evaluation process

1. **Map the use and potential harms:** Identify who is affected, what decisions or recommendations are made, whether outputs influence access to opportunities, and where errors have unequal consequences.
2. **Choose justified comparison groups:** Involve domain, privacy, and affected-community stakeholders. Use legally and ethically appropriate demographic or proxy data; do not infer sensitive attributes casually or collect them without governance.
3. **Select task-relevant metrics:** Depending on the use, examine error rates, false positive/negative rates, calibration, ranking or selection outcomes, refusal/abstention patterns, and quality differences across groups. State denominators and practical impact.
4. **Use counterfactual and qualitative tests:** Compare minimally changed inputs that alter demographic cues while holding task-relevant content constant. Review language, stereotypes, representation, and contextual harms with qualified human evaluators. Such tests are diagnostic, not definitive proof of fairness.
5. **Check intersectional and data limitations:** Examine meaningful intersections where sample sizes and privacy allow. Assess representation, label quality, missingness, and uncertainty; avoid over-interpreting small samples.
6. **Analyze the full system:** Include retrieval coverage, routing, prompts, post-processing, human workflows, and user access patterns, not just base-model output. A model-level metric may miss system-level disparities.
7. **Remediate and monitor:** Document trade-offs, consult stakeholders, mitigate root causes, and repeat evaluations across versions and real deployment. Establish escalation and appeal paths where decisions affect people.

Different fairness criteria can conflict—for example, parity in one error measure may not imply parity in another. Choose metrics transparently based on the relevant harm and governance requirements rather than selecting whichever score looks best.

### Trade-offs, bottlenecks, and capacity assumptions

Disaggregated evaluation can expose disparities but requires reliable, appropriately governed labels and enough samples; privacy constraints may limit group-level analysis. Counterfactual tests are controlled but cannot represent all lived experience. Fairness metrics can conflict, and aggregate parity may hide subgroup harms. Application domain, jurisdiction, and available data are unspecified, so involve affected stakeholders and qualified legal/domain reviewers, report uncertainty, and do not claim “bias-free” from one metric.

### Concise interview answer

“I start with the use case and harm model, then evaluate task-relevant quality and error outcomes across ethically and legally appropriate groups and important intersections. I combine disaggregated metrics, counterfactual tests, and qualitative review, while checking the whole pipeline—not just the base model. I document sample limitations and conflicts between fairness criteria, involve affected and domain stakeholders, and monitor after deployment. No single metric proves a system unbiased.”

### Revision summary

| Step | Consideration |
|---|---|
| Harm/use analysis | Who is affected and how errors differ in impact. |
| Metrics | Error, calibration, selection, refusal, or ranking by task. |
| Data governance | Lawful, appropriate sensitive-attribute use and privacy. |
| Qualitative review | Stereotypes, context, counterfactual behavior. |
| Lifecycle | Remediation, appeals, monitoring, transparent limitations. |

<br><br><br>

## How do you compare two models or prompts in a statistically rigorous way?

**Answer:**

### Design a fair, paired experiment before looking at results

Comparing two models or prompts requires controlling evaluation inputs, defining a primary outcome, and estimating uncertainty. LLM outputs can be stochastic, examples vary in difficulty, and many metrics or slices may be examined; an unplanned comparison can produce a misleading “winner.”

### Experimental procedure

1. **State the hypothesis and primary metric:** Define the change, target population, primary outcome, and non-negotiable quality/safety/latency/cost guardrails. Select one primary metric or a principled hierarchy to reduce cherry-picking.
2. **Use the same representative cases:** Evaluate both variants on the same held-out items and matched configuration. For subjective quality, use blinded randomized pairwise judgments; for stochastic outputs, decide whether to use fixed seeds where supported or multiple independent samples.
3. **Choose the analysis unit:** Account for clustering—multiple prompts from one user, tasks from one repository, or repeated generations from one input are not necessarily independent. Randomize and analyze at the appropriate user/task level.
4. **Plan sample size and power:** Estimate baseline variance/rate and the smallest practically meaningful effect, then choose sample size and duration for desired power and type-I error. Include multiplicity correction when testing many metrics or slices.
5. **Compute paired effects and uncertainty:** Use paired differences where cases are matched, report effect sizes and confidence intervals, and use an appropriate test for the metric/data distribution. Statistical significance alone does not establish practical or safety significance.
6. **Handle multiple generations and judges:** Predefine aggregation across samples, calibrate LLM judges against human labels, and account for judge noise. Do not repeatedly peek and stop when results look favorable unless using a valid sequential design.
7. **Confirm online where needed:** After offline evaluation, run a controlled canary/A-B test for product impact, with stable assignment, guardrails, and stop rules. Analyze task/cohort slices without over-interpreting underpowered subgroups.

Keep the dataset, model/prompt versions, evaluator, sampling parameters, exclusions, and analysis code fixed and recorded. If the result is inconclusive, report it as such rather than choosing a winner by intuition.

### Trade-offs, bottlenecks, and capacity assumptions

Paired testing reduces variance from example difficulty but may require repeated model calls; larger samples increase cost and release time. More metrics and subgroup analyses find regressions but raise false-positive risk. Online experiments have realistic outcomes but are slower and can expose users. Baseline variance, effect size, and traffic are unspecified, so calculate sample size from measured pilot data and prioritize practical effect and guardrail confidence over a nominal p-value alone.

### Concise interview answer

“I define a primary outcome and guardrails before testing, then compare variants on the same representative held-out cases with blinded, randomized evaluation. I plan sample size for a practically meaningful effect, account for clustering and stochastic repeats, and report paired effect sizes with confidence intervals and multiplicity handling. I avoid repeated peeking and use a controlled online experiment after offline gates. If evidence is insufficient, I call the result inconclusive rather than declaring a winner.”

### Revision summary

| Design choice | Why |
|---|---|
| Primary outcome/guardrails | Prevent post-hoc metric selection. |
| Paired examples | Control for case difficulty. |
| Power/sample planning | Detect meaningful effects with known uncertainty. |
| Clustering/multiplicity | Avoid invalid independence and false discoveries. |
| Recorded protocol | Reproduce and audit the comparison. |

<br><br><br>

## How do you evaluate the robustness of an LLM application across input variations?

**Answer:**

### Test whether meaning-preserving changes preserve acceptable behavior

Robustness evaluation measures whether an LLM application behaves reliably when inputs vary in wording, format, language, context, noise, or adversarial pressure. The expected behavior should remain invariant for meaning-preserving changes, while meaningful changes should produce appropriately different outputs. Robustness is not a requirement that every prompt yield identical text.

### Build a variation-based evaluation

1. **Define invariants and expected sensitivity:** Specify which output properties must remain stable—facts, decisions, safety constraints, schema—and which should change when the request meaning or evidence changes.
2. **Create controlled input families:** Generate paraphrases, spelling/grammar noise, formatting changes, reordered context, multilingual variants, distractors, long inputs, ambiguous references, and boundary-length cases. Preserve a clear mapping to the original intent.
3. **Test adversarial and distribution shifts:** Include prompt injection, conflicting instructions, unusual encodings, irrelevant or stale retrieved text, malformed payloads, and new task/user distributions.
4. **Use metamorphic assertions:** Where there is no exact gold answer, test relations such as paraphrases preserving the decision, irrelevant context not changing the answer, or changed evidence appropriately changing a grounded response.
5. **Measure consistency and task correctness:** Track task success, answer/citation factuality, schema validity, refusal and safety behavior, output variance, and robustness failures by transformation type and user/task slice.
6. **Repeat stochastic cases:** Use repeated generations or controlled sampling and report distributions; do not treat one differing response as a failure if the contract allows variation.
7. **Test the whole system:** Include prompt rendering, retrieval, model routing, tools, safety controls, and post-processing. Run fixed offline suites and carefully sampled online monitoring; add confirmed regressions to tests.

Adversarial input testing should be authorized and safely scoped. Robustness findings should lead to root-cause fixes—such as better parsing, retrieval boundaries, or validation—not only a longer prompt.

### Trade-offs, bottlenecks, and capacity assumptions

Many transformations broaden coverage but can generate invalid or semantically changed examples; each needs quality control. Metamorphic tests scale without labels but encode assumptions that may not hold for every task. Repeated stochastic tests multiply cost, while small test sets can miss rare failures. Language, task scope, and budget are unspecified, so prioritize likely/high-impact transformations and validate synthetic variations with human spot checks.

### Concise interview answer

“I define behavior invariants, then evaluate families of meaning-preserving and adversarial input variations: paraphrases, noise, formatting, language, context order, irrelevant documents, and boundary cases. Where exact labels are absent, metamorphic tests check that equivalent inputs preserve required outcomes and irrelevant changes do not alter them. I measure task correctness, grounding, safety, and output variance by transformation, repeat stochastic cases, and test the full retrieval/tool pipeline.”

### Revision summary

| Variation | Robustness question |
|---|---|
| Paraphrase/noise/language | Does equivalent meaning preserve outcome? |
| Irrelevant/conflicting context | Does evidence handling remain stable? |
| Adversarial input | Do safety and trust boundaries hold? |
| Metamorphic test | Are expected relations preserved without exact labels? |
| Reporting | Failures by transformation, task, and risk slice. |

<br><br><br>

## What are the key differences between evaluating traditional ML vs LLM applications?

**Answer:**

### LLMs add open-ended behavior and system-level evaluation needs

Traditional machine-learning evaluation often predicts a defined label or numeric value, so metrics such as accuracy, precision/recall, calibration, and task-specific loss can be computed against labeled ground truth. LLM applications may generate open-ended text, use tools, retrieve context, and interact over multiple turns. They still need conventional ML metrics where applicable, but also require evaluation of content, evidence, safety, interaction, and operational behavior.

### Main differences

| Dimension | Traditional ML (typical case) | LLM application |
|---|---|---|
| Output space | Often fixed labels, scores, or structured values. | Open-ended text, tool calls, or multi-step actions. |
| Ground truth | Frequently labels/targets exist for held-out cases. | Valid outputs can vary; rubrics, evidence, or human judgment may be needed. |
| Metrics | Accuracy, precision/recall, ROC-AUC, calibration, loss. | Task success, factuality/grounding, completeness, safety, format, preference, plus operational metrics. |
| Determinism | Inference is often stable for a fixed model/input. | Sampling, providers, prompts, and tools can make behavior variable. |
| Failure modes | Misclassification, drift, calibration, subgroup error. | Hallucination, prompt injection, unsafe output/tool action, context/retrieval errors, inconsistent conversations. |
| Evaluation scope | Model and data pipeline are central. | Model plus prompt, retrieval, tools, orchestration, policy, and UX. |
| Test methods | Labeled holdouts and statistical metrics. | Deterministic assertions, rubrics, judges/humans, simulations, adversarial and trajectory tests. |

Both require representative splits, leakage controls, subgroup analysis, monitoring for distribution shift, and decision thresholds based on risk. LLM evaluation does not replace statistical rigor; stochasticity and subjective criteria make careful sampling, evaluator calibration, paired comparisons, and uncertainty reporting especially important.

### Trade-offs, bottlenecks, and capacity assumptions

Traditional ML metrics can be cheaper and more reproducible when labels exist, but may be insufficient for open-ended usefulness or harm. LLM rubrics and human evaluation capture nuance but cost more and can vary; model judges add scale but require calibration. LLM application behavior also changes when any dependency changes, increasing regression-test scope. Task type and risk are unspecified, so reuse deterministic metrics for verifiable parts and add rubric, safety, and system-level evaluation only where needed.

### Concise interview answer

“Traditional ML often predicts a fixed target, so labeled holdouts and metrics like precision/recall or calibration are central. LLM applications produce variable open-ended outputs and may retrieve, call tools, and span turns, so evaluation includes task success, grounding, safety, format, trajectories, and operational cost—not just model accuracy. Both need representative data, leakage control, subgroup analysis, and production monitoring. The evaluation boundary for an LLM is usually the whole application, not only the model.”

### Revision summary

| Difference | Evaluation implication |
|---|---|
| Fixed versus open-ended output | Labels versus rubrics/evidence/task properties. |
| Deterministic versus variable | Repeats, paired tests, uncertainty reporting. |
| Model versus application behavior | Include prompts, retrieval, tools, policy, UX. |
| Failure modes | Add grounding, safety, injection, and action tests. |
| Shared foundation | Representative data, leakage control, monitoring, slices. |

<br><br><br>

## How do you set up an evaluation framework from scratch for a new LLM application?

**Answer:**

### Start from the user outcome and risk model

An evaluation framework is the repeatable process, data, metrics, tooling, and release gates used to determine whether an AI application is useful, safe, and operationally fit. Begin by defining what the product must do and what it must never do; selecting metrics before understanding the task often produces a convenient but irrelevant score.

### Build the framework in stages

1. **Map the application and its boundaries:** Document users, tasks, model/provider, prompts, retrieval, tools, data flows, external effects, and high-impact decisions. Identify safety, privacy, security, and policy requirements.
2. **Define success criteria:** Choose a small set of primary task outcomes and hard guardrails such as factual support, authorization, refusal behavior, output validity, latency, availability, and cost. Define what evidence is sufficient to ship.
3. **Create an initial evaluation set:** Collect representative, privacy-governed examples across common tasks, edge cases, languages, and risk slices. Include answerable/unanswerable and adversarial cases. Store source, label/rubric, version, and uncertainty; reserve a protected holdout.
4. **Select complementary measurement methods:** Use deterministic tests for schemas, permissions, citations, code/tool effects, and invariants; human review for nuanced or high-risk judgments; calibrated LLM judges for scalable subjective scoring; and operational metrics for latency and cost.
5. **Establish a baseline:** Record the full behavior bundle—model/provider revision, prompt, retrieval/index, tools, policy, decoding parameters, and evaluator versions. Run the suite and inspect failures by category and slice, not just aggregate score.
6. **Automate a tiered workflow:** Run fast unit/contract checks on every change, a targeted behavioral suite for relevant modifications, and broader safety/quality evaluations before release. Pin data and configurations so results can be reproduced.
7. **Add controlled production learning:** Use shadow/canary or A/B rollout with predefined stop criteria. Monitor privacy-safe outcomes, drift, user corrections, errors, and cost; review production examples before converting them into governed regression tests.
8. **Maintain the system:** Recalibrate judges, refresh data, audit contamination and label quality, monitor sampling bias, and revisit criteria as product use or policy changes.

The framework should make uncertainty explicit. For a new product, an honest small suite with clear blind spots is more useful than a large collection of poorly defined scores.

### Trade-offs, bottlenecks, and capacity assumptions

Broad coverage increases confidence but requires data curation, expert labels, model calls, and CI time. Human review can constrain release velocity; automatic judges can add scale but need calibration. A very small suite is fast yet may hide rare or subgroup regressions. Product risk, task mix, and evaluation budget are unspecified, so start with critical paths and hard safety invariants, then expand coverage in proportion to impact and observed failure modes.

### Concise interview answer

“I start with the user outcome, system boundaries, and harm model, then define task-specific success criteria and non-negotiable safety and operational gates. I build a versioned representative dataset with a protected holdout, combine deterministic checks, human review, calibrated judges, and service metrics, and establish a baseline for the complete model/prompt/retrieval/tool configuration. I automate tiered CI and use canary rollout with stop criteria. Production feedback expands the suite under privacy and contamination controls.”

### Revision summary

| Foundation | Deliverable |
|---|---|
| Product/risk analysis | Tasks, users, harms, boundaries. |
| Criteria | Primary outcome and hard guardrails. |
| Evaluation data | Representative, versioned, governed holdout. |
| Methods | Deterministic, human, judge, operational measures. |
| Lifecycle | CI gates, canary, monitoring, refresh, calibration. |

<br><br><br>

## Your model passes one fairness metric but fails another. How do you handle conflicting audit results?

**Answer:**

### Treat conflicting metrics as evidence about different fairness properties

Fairness criteria can disagree because they measure different error types, population outcomes, or calibration properties. Some statistical fairness conditions cannot all be satisfied simultaneously when group base rates differ and predictions are imperfect. Therefore, a metric conflict is not automatically a calculation bug—or a reason to select whichever result is most favorable.

### Resolve the conflict transparently

1. **Validate the audit first:** Confirm metric definitions, denominators, thresholds, labels, group membership, missingness, sampling, confidence intervals, and implementation. Check that the comparison uses the same population and time period.
2. **Tie each metric to a harm:** Explain which outcome each metric captures—for example, false negatives, false positives, calibration, selection rate, or access. Ask who bears the consequence of each error in this specific use.
3. **Review context and legitimacy:** Consult affected stakeholders, domain owners, and qualified legal/privacy reviewers. Confirm the use of sensitive attributes and group definitions is appropriate and lawful; document limitations and intersectional concerns.
4. **Assess uncertainty and practical impact:** Examine sample sizes, confidence intervals, error severity, operational thresholds, and downstream effects. A statistically significant difference may be small in practice, while a noisy high-impact gap may warrant further investigation.
5. **Avoid metric shopping:** Predefine primary metrics and guardrails based on the risk analysis. Report all material results and the trade-offs; do not hide a failed metric because another passed.
6. **Consider mitigations and consequences:** Evaluate data, threshold, model, workflow, human-review, or product-design changes. Re-test effects on accuracy, calibration, access, safety, and other groups; do not assume one intervention solves all disparities.
7. **Document the decision:** Record chosen criteria, unresolved conflicts, rationale, approvals, residual risk, monitoring plan, and appeal/escalation path. If no acceptable trade-off exists, restrict or pause the use rather than declaring it fair.

Fairness is a sociotechnical judgment informed by metrics, not a property proven by a single scalar. The correct decision may depend on jurisdiction, domain, and who bears the harm.

### Trade-offs, bottlenecks, and capacity assumptions

Additional metrics and subgroup analysis improve transparency but require reliable labels, adequate sample sizes, and privacy governance. Mitigating one error disparity can worsen another metric or overall utility. Stakeholder consultation and domain review take time but are essential for consequential applications. Since use context and jurisdiction are unspecified, do not prescribe a universal winning metric; escalate to appropriate governance and document any decision to proceed.

### Concise interview answer

“I first verify the calculations and uncertainty, then map each metric to the harm it measures in the specific decision context. Because fairness criteria can conflict, I involve affected stakeholders and domain/legal reviewers, predefine which outcomes are hard constraints, and report all material results rather than metric-shop. I test mitigations across accuracy and group slices, document residual risk and appeals, and pause or limit deployment if no acceptable trade-off is justified.”

### Revision summary

| Step | Goal |
|---|---|
| Verify | Check definitions, denominators, data, and uncertainty. |
| Contextualize | Connect metrics to actual harms and decisions. |
| Govern | Include affected stakeholders and qualified reviewers. |
| Mitigate | Re-evaluate trade-offs across groups and outcomes. |
| Decide | Document residual risk; restrict use if needed. |

<br><br><br>

## Your model was fair at deployment, but became biased 6 months later. How do you monitor continuously?

**Answer:**

### Treat fairness as a changing production property

A model can pass an initial audit and later produce disparate outcomes because user populations, input distributions, labels, policies, upstream data, thresholds, prompts, retrieval content, or human workflows changed. Continuous monitoring should look for changes in both data and outcomes while respecting privacy and recognizing that production labels may arrive late or be incomplete.

### Monitoring and response plan

1. **Preserve a deployment baseline:** Store the original fairness evaluation, model/configuration version, population definitions, data assumptions, thresholds, and known limitations so later measurements are comparable.
2. **Monitor input and process drift:** Track privacy-safe distributions of task types, language, missingness, routing, retrieval coverage, and relevant features. Monitor changes to upstream sources, user access, policy, and human review rates.
3. **Measure outcomes by appropriate groups:** When lawful and governed, monitor task quality, error rates, calibration, selection/approval outcomes, refusals, and human overrides across relevant groups and intersections. Include sample counts and uncertainty; suppress or aggregate small cells to protect privacy.
4. **Handle delayed or weak labels:** Use delayed outcome labels, audits, sampled human review, and validated proxy indicators. Distinguish leading indicators from confirmed outcome disparities; do not treat proxy metrics as ground truth.
5. **Alert on meaningful change:** Set thresholds for practical and statistical changes, minimum sample sizes, and sustained windows to reduce noisy alerts. Monitor both group gaps and absolute performance so parity does not mask broad quality failure.
6. **Investigate the full pipeline:** Check model/prompt/provider revisions, data and retrieval changes, thresholds, routing, human processes, and external conditions. Compare cohorts and time windows while accounting for changing population mix.
7. **Mitigate and govern:** Escalate to domain, fairness, privacy, and legal owners as appropriate. Consider rollback, threshold/workflow changes, additional human oversight, or suspension; document rationale and residual risk.
8. **Re-audit after change:** Re-run the baseline and targeted evaluations after model, data, policy, or product updates, and preserve a reviewable audit trail.

Monitoring must not collect sensitive attributes or personal data by default; use an approved governance basis and access controls. A lack of observed disparity in low-volume or unlabeled data is not evidence that no harm exists.

### Trade-offs, bottlenecks, and capacity assumptions

Frequent subgroup monitoring can detect harm sooner but needs sufficient label volume and raises privacy and multiple-testing concerns. Delayed labels slow response; proxies can alert quickly but may mislead. Fine-grained intersections improve insight but can create small, unstable cells. Population volume, outcome delay, and data permissions are unspecified, so define minimum sample/confidence rules, use risk-based human audits, and maintain a safe pause/escalation path.

### Concise interview answer

“I treat fairness as a lifecycle property. I preserve the deployment baseline, monitor privacy-governed input and outcome distributions by relevant groups, and track sample sizes, uncertainty, and delayed labels. I alert on sustained meaningful changes, investigate model/data/policy/workflow shifts across the whole system, and escalate to appropriate governance owners. Where evidence is insufficient, I use sampled review and cautious controls rather than assuming fairness. Mitigations and rollbacks are followed by a documented re-audit.”

### Revision summary

| Signal | Monitor |
|---|---|
| Data/process drift | Task mix, language, access, routing, source changes. |
| Outcomes | Quality, errors, calibration, refusals, overrides by group. |
| Evidence quality | Label delay, sample size, uncertainty, proxy validity. |
| Response | Alerts, investigation, governance escalation, rollback. |
| Privacy | Approved attribute use, access, small-cell protection. |

<br><br><br>

## An external auditor cannot reproduce your model's results. How do you ensure audit reproducibility?

**Answer:**

### Preserve the complete experiment and execution context

Audit reproducibility means an independent reviewer can reconstruct the evaluation procedure and understand how reported results were produced, subject to lawful privacy, security, and intellectual-property constraints. For LLM systems, recording only a model name and prompt is inadequate: data, provider behavior, runtime, evaluator, and sampling can all affect outcomes.

### Reproducibility controls

1. **Version all artifacts:** Record application code/commit, model and provider revision where available, tokenizer/chat template, prompts, retrieval/index snapshot, tools, policies, datasets and labels, evaluator/judge, dependencies, and configuration.
2. **Capture run parameters:** Preserve timestamps, environment, hardware/runtime, seeds where supported, decoding settings, API parameters, test order, concurrency, retries, exclusions, and any human annotation protocol. Mark parameters that providers do not disclose or that cannot be fixed.
3. **Maintain dataset lineage:** Store data provenance, transformations, sampling, label instructions, adjudication, licensing, privacy processing, and train/dev/test separation. Use checksums or immutable identifiers where permitted.
4. **Preserve executable methodology:** Maintain scripts, container/build references, metric implementations, scoring rules, analysis notebooks or code, and CI artifacts. Document manual steps and the exact command/configuration needed to rerun.
5. **Distinguish reproducibility from repeatability:** A hosted model alias may change behind the interface, and stochastic generation may not return identical output even with fixed settings. Preserve available response metadata and report that exact replay is not guaranteed rather than overstating determinism.
6. **Support independent review safely:** Provide access-controlled artifacts, redacted datasets or secure review environments, logs of approvals, and documentation of limitations. Do not expose personal data, credentials, or restricted model artifacts to an auditor without authorization.
7. **Re-run and reconcile:** Have a separate reviewer execute the documented pipeline, compare intermediate and final metrics, investigate discrepancies, and update the record. Use independent checksums and signed release manifests where appropriate.

If a result cannot be exactly reproduced due to provider nondeterminism, disclose the boundary and provide enough provenance and repeated-run statistics for the auditor to assess the claim.

### Trade-offs, bottlenecks, and capacity assumptions

Immutable snapshots and detailed provenance improve auditability but require storage, access governance, and preservation of potentially sensitive data. Hosted APIs and proprietary models limit control over weights, infrastructure, and deterministic replay. Exact reproduction can be expensive, especially for large stochastic evaluations; secure auditor access may require additional tooling. Audit scope and regulatory requirements are unspecified, so agree on evidence and access model up front and document non-reproducible components explicitly.

### Concise interview answer

“I make results reproducible by versioning the full system bundle, datasets and labels, evaluator, runtime, parameters, and analysis code, with immutable run metadata and data lineage. I preserve commands and artifacts so an independent reviewer can rerun and reconcile the metrics in a controlled environment. For hosted or stochastic models, I record available provider revisions and repeated-run distributions, and clearly state what cannot be exactly reproduced. Audit access is governed to protect sensitive data and credentials.”

### Revision summary

| Evidence | Examples |
|---|---|
| System bundle | Code, model, prompt, index, tools, policy, runtime. |
| Data lineage | Sources, versions, transformations, labels, splits. |
| Execution | Parameters, environment, seeds, timestamps, retries. |
| Analysis | Scripts, metrics, exclusions, human protocol. |
| Limitations | Provider drift, stochasticity, access constraints. |

<br><br><br>

## How do you structure red teaming for an LLM chatbot before launch?

**Answer:**

### Organize testing around chatbot threats, user journeys, and release decisions

Pre-launch red teaming is a scoped, adversarial assessment of the chatbot and its surrounding application before real users depend on it. It should test both model responses and system behavior—especially identity, retrieval, tools, data handling, moderation, and escalation. Findings need owners, severity, remediation, and retesting; a one-off prompt attack list is not a launch strategy.

### Structure the exercise

1. **Set objectives and rules:** Define supported use cases, users, environments, allowed techniques, prohibited actions, data boundaries, timebox, reporting channel, and incident stop conditions. Use authorized test accounts and synthetic or approved data.
2. **Map the chatbot architecture:** Identify model/provider, prompt layers, conversation memory, RAG corpus, tools/actions, authentication/authorization, safety filters, logging, rate limits, human handoff, and third-party dependencies.
3. **Prioritize threat scenarios:** Test direct and indirect prompt injection, retrieval poisoning/untrusted instructions, cross-user or cross-tenant leakage, sensitive-data extraction, unsafe tool use, refusal bypass, harmful content, identity confusion, misinformation/citations, and denial-of-service or cost abuse.
4. **Exercise realistic conversation paths:** Include multi-turn escalation, role changes, corrections, long context, language variation, ambiguous requests, tool failures, streaming interruptions, and attempts to induce the bot to reveal hidden configuration or act without confirmation.
5. **Verify outcomes outside the transcript:** Inspect whether data was accessed or disclosed, whether tools caused side effects, whether rate limits held, and whether the human handoff/incident path worked. A reassuring final message is not proof of safe behavior.
6. **Record and rank findings:** Capture scenario, system version, reproducible steps, impact, likelihood, affected boundary, evidence, and severity. Minimize sensitive artifacts and restrict access to exploit details.
7. **Remediate and retest:** Prioritize root-cause fixes in authorization, retrieval filters, tool allowlists, validation, rate limiting, and monitoring. Re-run the scenario, add regression coverage, and document residual risk and launch criteria.
8. **Include cross-functional review:** Bring in security, privacy, safety, product, and domain experts as appropriate; ensure user reporting and incident response are ready before launch.

### Trade-offs, bottlenecks, and capacity assumptions

Broad scenario coverage requires time, diverse expertise, and stable test environments. Automated attack suites scale but miss conversational context; human testers find chained failures but require careful scope and review. Fixes can affect usability or create false refusals, so regression testing must include benign cases. Chatbot features, users, and risk are unspecified, so use a threat-based launch gate with high-impact scenarios first, reserve remediation time, and avoid declaring a system safe solely because no attack succeeded in a limited exercise.

### Concise interview answer

“I scope an authorized exercise, map the chatbot’s model, memory, retrieval, tools, permissions, filters, and data flows, then prioritize realistic multi-turn threats such as injection, leakage, unsafe actions, refusal bypass, and cost abuse. I verify actual access and side effects—not just transcript wording—record versioned findings, remediate at the trust boundary, and retest. Security, privacy, safety, product, and domain owners agree on severity and launch gates, with residual risks documented.”

### Revision summary

| Phase | Deliverable |
|---|---|
| Scope | Authorized rules, environment, data, escalation path. |
| Threat map | Trust boundaries, assets, tools, dependencies. |
| Scenarios | Injection, leakage, actions, safety, abuse, multi-turn. |
| Findings | Reproducible evidence, impact, severity, owner. |
| Launch gate | Remediation, regression, retest, residual-risk approval. |

<br><br><br>

## How do you red team a multimodal model where text-only safety tests miss cross-modal attacks?

**Answer:**

### Test combinations of modalities and the full processing pipeline

Multimodal red teaming evaluates how a system interprets and combines text, images, audio, video, and other inputs. A model may behave safely on text-only prompts but fail when harmful or misleading instructions are embedded in an image, spoken in audio, shown across video frames, or split between modalities. Testing must cover the model and the surrounding OCR, transcription, captioning, preprocessing, retrieval, tool, and policy layers.

### A structured cross-modal assessment

1. **Set authorized scope and threat model:** Identify supported modalities, input transformations, trust boundaries, user roles, tools, data flows, and prohibited impacts. Use an isolated environment, approved synthetic content, and clear stop/report procedures.
2. **Test each modality independently:** Establish baseline behavior for text, image, audio, video, and relevant metadata. Check modality-specific risks such as OCR text, spoken instructions, transcription errors, frame sampling, and captions.
3. **Test cross-modal combinations:** Construct safe, controlled cases where text conflicts with image/audio content, where instructions are hidden or indirect in media, where meaning is distributed across modalities, or where one modality attempts to override trusted policy. Include mixed-language, low-quality, cropped, noisy, and temporal variants.
4. **Probe preprocessing and alignment:** Check OCR/transcription/caption outputs, frame selection, timestamps, resizing/cropping, normalization, and modality alignment. Failures may originate before the model or from context assembly, not only from model reasoning.
5. **Test application boundaries:** Include multimodal prompt injection in retrieved or uploaded content, unauthorized data requests, unsafe tool invocation based on media, and attempts to bypass moderation or confirmation. Verify actual permissions and side effects outside the final text.
6. **Evaluate safety and utility together:** Use task-specific rubrics and human reviewers to assess harmful compliance, false refusals, evidence fidelity, and correct uncertainty. Avoid test sets containing real harmful content unless approved controls and handling procedures are in place.
7. **Instrument and remediate:** Record modality types, preprocessing/model versions, and safe outcome metadata; minimize retention of sensitive media. Triage root causes, fix trust boundaries or validation, and add cross-modal cases to regression tests.
8. **Repeat across updates:** Re-run after model, encoder, OCR/ASR, prompt, frame-sampling, or moderation changes. Include combinations and realistic user workflows rather than evaluating each modality only in isolation.

### Trade-offs, bottlenecks, and capacity assumptions

Cross-modal test creation requires diverse media, expertise, and often manual annotation; exhaustive combinations grow rapidly with modalities, languages, quality levels, and temporal patterns. Synthetic transformations improve breadth but may be unrealistic or alter meaning. Human review is important for context but can be costly and must be privacy- and safety-aware. Modalities, risk level, and evaluation budget are unspecified, so prioritize likely high-impact interactions, use automated variations for screening, and reserve expert review for ambiguous or severe cases.

### Concise interview answer

“I red team the complete multimodal pipeline, not just text prompts. I test modalities individually and in combination—conflicting text and media, hidden or indirect instructions, noise, cropping, language changes, and temporal alignment—then verify preprocessing, policy enforcement, data access, and tool side effects. I use authorized synthetic cases and human review for ambiguous outcomes, minimize media retention, remediate at the trust boundary, and add cross-modal regression tests after every relevant component change.”

### Revision summary

| Test surface | Examples |
|---|---|
| Modalities | Text, image/OCR, audio/ASR, video/frame sampling. |
| Cross-modal interaction | Conflicts, distributed meaning, indirect instructions. |
| Pipeline | Preprocessing, alignment, context assembly, moderation. |
| Application | Permissions, retrieval, tools, side effects. |
| Lifecycle | Safe evidence, remediation, regression, repeat after updates. |

<br><br><br>
