# 03. Retrieval-Augmented Generation (RAG)

Source entries are in their original order. Use the space after each heading to draft an answer.

## What is Retrieval-Augmented Generation (RAG), and why is it important?

**Answer:**

### Definition

**Retrieval-Augmented Generation (RAG)** is a system pattern that retrieves relevant information from an external data source and supplies it to a language model as context for generating a response. Instead of relying only on knowledge encoded in model parameters, the application grounds the response in selected documents, records, or other evidence.

A typical request is:

\[
\text{question} \rightarrow \text{retrieve evidence} \rightarrow
\text{generate answer conditioned on evidence}
\]

RAG does not retrain or update the base model. The knowledge source can be refreshed independently, subject to indexing and access-control processes.

### Why it matters

- **Freshness:** New or changing information can be indexed without retraining the model.
- **Domain grounding:** Responses can use private, organization-specific, or specialized content.
- **Attribution:** The system can retain document identifiers and return citations or source links.
- **Cost and iteration:** Updating an index may be cheaper and faster than repeated model fine-tuning for factual updates.
- **Access control:** Retrieval can scope evidence to the requesting user when authorization is correctly enforced.

RAG does not guarantee that the model uses retrieved context correctly, that the retriever found all relevant evidence, or that a citation supports a claim. It can still hallucinate, retrieve stale or conflicting data, or expose information if access controls are weak.

### When RAG is a good fit

Use RAG when answers depend on a changing or external knowledge base, need source grounding, or should be restricted to authorized documents. It may be unnecessary for a self-contained task that does not require external facts. Structured databases, APIs, or deterministic code may be a better source of truth for exact transactional questions.

### Concise interview answer

“RAG retrieves relevant external evidence for a request and provides it to a language model as context for generating a grounded answer. It is useful for fresh, domain-specific, or access-controlled knowledge and can support source citations without retraining the model for every content update. But it does not guarantee retrieval completeness or faithful generation. I evaluate retrieval and answer quality separately, preserve source references, and enforce authorization before retrieved content reaches the model.”

### Revision summary

| Stage | Role |
|---|---|
| Retrieval | Select evidence relevant to the question. |
| Augmentation | Supply evidence and source metadata to the model. |
| Generation | Produce a response conditioned on the evidence. |
| Benefit | Fresh, domain-grounded answers with potential attribution. |
| Caveat | Retrieval and generation can both fail; authorization is essential. |

<br><br><br>

## Explain the architecture of a basic RAG system.

**Answer:**

### Two main paths

A basic RAG system has an **offline ingestion/indexing path** and an **online question-answering path**.

**Ingestion path**

1. Connect to approved source systems and identify documents or records.
2. Extract text and relevant metadata; normalize formats and remove or handle duplicates.
3. Split content into chunks that preserve useful semantic boundaries.
4. Compute embeddings for chunks and store vectors alongside text, source IDs, permissions, and metadata in a searchable index.
5. Record versions and update/delete behavior so the index can be reconciled with source-of-truth changes.

**Query path**

1. Authenticate the requester and apply query-time access scope.
2. Normalize or enrich the question if appropriate, then retrieve candidate chunks using vector, keyword, or hybrid search.
3. Optionally filter and rerank candidates for relevance.
4. Assemble a bounded context with source references and clear instructions.
5. Generate an answer or abstention, ideally citing the evidence used.
6. Validate the response and return it with relevant source links; log metrics safely.

### Architectural sketch

```text
Documents/DBs -> extract -> clean -> chunk -> embed -> vector/search index
                                                        ^
User query -> authenticate -> retrieve -> filter/rerank -+
                                     -> prompt with evidence -> LLM
                                     -> validate/cite -> answer
```

### Important design boundaries

The index is derived data; the source system remains authoritative. Permissions must be enforced during retrieval, not merely mentioned in the prompt. Embedding model, chunking policy, and index version should be tracked together because changing them may require re-embedding or re-indexing. For structured or transactional information, query a governed database/API rather than treating prose chunks as authoritative state.

### Concise interview answer

“A basic RAG architecture separates ingestion from serving. Ingestion extracts and cleans authorized sources, chunks them, embeds the chunks, and indexes vectors with text, metadata, source IDs, and permissions. At query time the system authenticates the user, retrieves only authorized candidates, optionally filters or reranks, assembles bounded evidence, and asks the model to answer with citations or abstain. It then validates the output. I version the index pipeline and enforce access control in retrieval, not through prompt instructions.”

### Revision summary

| Path | Main steps |
|---|---|
| Ingestion | Extract → clean → chunk → embed → index with metadata and ACLs. |
| Serving | Authenticate → retrieve/filter/rerank → build context → generate → validate. |
| Governance | Source of truth, freshness, versioning, permissions, deletion. |
| Quality | Measure retrieval, grounding, citations, latency, and cost. |

<br><br><br>

## What are the key components of a RAG pipeline?

**Answer:**

### Components

1. **Source connectors and ingestion:** Read approved files, databases, knowledge bases, or APIs; track provenance and changes.
2. **Content processing:** Parse formats, normalize text, preserve layout or table structure where needed, deduplicate, and handle malformed or oversized inputs.
3. **Chunking and metadata:** Divide content into retrieval units and attach source, section, timestamp, tenant, permissions, and version metadata.
4. **Embedding model and index:** Encode query-compatible representations and store them in a vector index; many systems also maintain a lexical index.
5. **Retriever:** Search for candidates using vector similarity, keyword search, metadata filters, or hybrid retrieval.
6. **Post-retrieval processing:** Deduplicate, filter, rerank, compress, or expand context as appropriate.
7. **Prompt/context assembly:** Fit evidence within the model budget, preserve citations, and distinguish untrusted source content from trusted instructions.
8. **Generator:** Produce an answer grounded in the supplied evidence, or abstain when evidence is insufficient.
9. **Output validation and presentation:** Validate schema and citations; return source links and uncertainty appropriately.
10. **Evaluation and operations:** Measure retrieval and answer quality, freshness, access-control correctness, latency, cost, failures, and index drift.

### Quality depends on the whole pipeline

A strong generator cannot answer from evidence the retriever missed. A good retriever can still lead to an incorrect response if chunks lose context, the prompt is poorly assembled, or the model ignores evidence. Evaluate components independently and end to end. Monitor index freshness and permission changes as carefully as model output quality.

### Concise interview answer

“A RAG pipeline includes source ingestion, parsing and normalization, chunking and metadata, embeddings and an index, retrieval, optional filtering or reranking, context assembly, generation, output validation, and evaluation/monitoring. The components form a chain: parsing and chunk boundaries affect retrieval, retrieval determines available evidence, and generation determines whether that evidence is used faithfully. I track provenance, freshness, and ACLs throughout and evaluate both retrieval metrics and answer-level quality.”

### Revision summary

| Layer | Responsibility |
|---|---|
| Ingest | Connect to sources, parse, normalize, track versions. |
| Index | Chunk, embed, store searchable text and metadata. |
| Retrieve | Search and enforce metadata/permission filters. |
| Generate | Assemble evidence, answer or abstain, preserve citations. |
| Operate | Evaluate quality, freshness, security, cost, and latency. |

<br><br><br>

## What are chunking strategies, and how do you choose the right chunk size?

**Answer:**

### What chunking does

**Chunking** divides a source document into smaller units that can be indexed and retrieved independently. The chunk must be large enough to retain the information and context needed to answer questions, but focused enough that retrieval does not return lots of irrelevant text or exceed the generation context budget.

There is no universally optimal chunk size. It depends on document structure, question types, embedding and reranker behavior, context limits, and quality/latency/cost requirements. Measure size in the model’s tokens rather than assuming a fixed number of characters maps consistently to tokens.

### Common strategies

- **Fixed-size:** Split at a target token or character length, often with overlap. Simple and predictable, but may break sentences, tables, or topics.
- **Structure-aware:** Split on headings, paragraphs, pages, sections, code blocks, or table boundaries. Preserves document organization but may create highly variable chunk sizes.
- **Semantic:** Find boundaries where content changes topic, often using embeddings or similarity signals. Can keep coherent units but costs more preprocessing and depends on boundary quality.
- **Recursive:** Try preferred separators first—such as sections, paragraphs, sentences, then smaller units—until each piece fits a target range. Useful for preserving hierarchy while controlling maximum size.

### How to choose empirically

1. Inspect source formats and representative questions; determine what evidence must remain together.
2. Create candidate chunking policies and sizes, including overlap only where boundary loss is observed.
3. Index each candidate and evaluate retrieval recall/precision at relevant \(k\), reranker quality, answer faithfulness, and citation accuracy.
4. Test long, short, cross-section, table, and boundary-dependent questions.
5. Measure index size, embedding cost, context tokens, answer latency, and total cost.
6. Select a configuration that meets quality and operational constraints; version it with the embedding model and index.

Small chunks can improve focused matching but omit necessary context and increase the number of results. Large chunks preserve context but can dilute similarity and consume the prompt budget. Overlap can reduce boundary misses but duplicates content, increases storage/cost, and can crowd retrieval results.

### Concise interview answer

“Chunking creates the units that are embedded and retrieved. I choose size based on document structure and question patterns, balancing focused matching against enough surrounding context. Candidates include fixed-size, structure-aware, semantic, and recursive splitting, sometimes with overlap. I do not pick a size by convention alone: I evaluate retrieval recall and precision, downstream faithfulness and citations, context use, latency, and index cost on representative questions, including boundary and table cases.”

### Revision summary

| Trade-off | Smaller chunks | Larger chunks |
|---|---|---|
| Matching | More focused. | More context, potentially diluted match. |
| Context | May omit surrounding definitions. | More likely to retain relationships. |
| Prompt budget | More results may be needed. | Fewer chunks but each consumes more tokens. |
| Overlap | Can protect boundaries. | Adds duplication and storage/retrieval overhead. |
| Selection | Use evaluation over real queries and sources. | No universal best token size. |

<br><br><br>

## Compare fixed-size chunking, semantic chunking, and recursive chunking.

**Answer:**

### Comparison

| Strategy | How it splits | Strengths | Limitations |
|---|---|---|---|
| **Fixed-size** | Splits every target number of tokens/characters, optionally overlapping adjacent chunks. | Simple, predictable, fast to implement, easy to batch. | Can cut across sentences, sections, lists, or tables; chunk content may be incoherent. |
| **Semantic** | Places boundaries where topic or semantic similarity indicates a content shift. | Can produce more coherent topic-focused chunks. | More preprocessing and tuning; similarity thresholds can be unstable and may miss document structure. |
| **Recursive** | Tries a hierarchy of separators—e.g., headings, paragraphs, sentences, then smaller boundaries—until units fit target constraints. | Respects structure when possible while enforcing size limits; handles varied documents. | Depends on parser/separator quality; fallback splits can still break meaning, and size distribution varies. |

These approaches are not mutually exclusive. A practical pipeline might recursively split by document structure, then use a fixed token limit as a safety cap, with semantic boundaries considered within large sections.

### Example

For a policy manual, fixed-size splitting might break a rule from its exception. Semantic splitting may keep related paragraphs together but separate a heading from the section it labels. Recursive structure-aware splitting can first split by heading, then paragraph, and finally sentence if a section exceeds the token cap. Each strategy still needs testing against actual questions and evidence boundaries.

### Selection criteria

Choose based on source types, query patterns, parser reliability, indexing throughput, and retrieval/answer results. Compare recall@\(k\), precision or nDCG where labels exist, answer faithfulness, citation correctness, index size, and runtime. Include questions whose answers cross chunk boundaries. Track the chosen chunker and configuration as part of the index version; changing chunk boundaries usually requires rebuilding affected embeddings and index entries.

### Concise interview answer

“Fixed-size chunking splits at a predictable token or character length, making it simple but potentially breaking semantic units. Semantic chunking tries to place boundaries at topic changes, improving coherence but adding computation and threshold sensitivity. Recursive chunking respects a hierarchy of separators—such as section, paragraph, and sentence—until chunks fit a target limit, often with a fixed-size fallback. They can be combined. I compare them on representative retrieval and answer evaluations, including cross-boundary questions, as well as index and latency costs.”

### Revision summary

| Strategy | Key idea | Best reason to choose |
|---|---|---|
| Fixed-size | Uniform target length. | Simplicity and predictable processing. |
| Semantic | Split at topic shifts. | Topic-coherent units when boundary detection works. |
| Recursive | Hierarchical separators plus size limit. | Preserve source structure while bounding chunk size. |
| Hybrid | Combine structure, semantics, and hard limits. | Real corpora with mixed formats and needs. |
| Validation | Retrieval and answer quality, not chunk aesthetics. | Ensure relevance, coverage, cost, and latency. |

<br><br><br>

## What is Contextual Retrieval, and how does it improve RAG?

**Answer:**

### Core idea

**Contextual Retrieval** enriches a chunk with concise information about its source and surrounding document context before it is indexed and retrieved. A chunk that says “It increased by 15%” is ambiguous on its own; its heading or document context might identify the subject, period, and comparison. Adding that context can make both lexical and semantic retrieval more likely to find the right passage.

The enrichment might include a document title, section path, entity names, or a short generated description. It should complement—not replace—the original chunk and its source metadata.

### Typical workflow

1. Split a source into chunks while retaining document and section metadata.
2. For each chunk, derive a brief contextual prefix from trusted surrounding material.
3. Index the contextualized text for search, while retaining the original text and canonical source offsets.
4. Retrieve relevant chunks and pass the original content, useful context, and citations to the generator.
5. Evaluate whether the added context improves retrieval and final answer quality.

Some approaches also combine contextual enrichment with lexical indexing or reranking. Exact implementations vary.

### Benefits and risks

| Potential benefit | Risk or cost |
|---|---|
| Makes locally ambiguous chunks easier to match. | Adds preprocessing, storage, and embedding tokens. |
| Improves retrieval for references that depend on document context. | Generated context can introduce errors or leak information across access boundaries. |
| Can help semantic and lexical search. | Enrichment may add noise or bias retrieval toward the document summary. |
| Preserves chunk-level retrieval granularity. | Requires reprocessing when source context changes. |

Use only authorized context when enriching a chunk, preserve provenance, and never let generated descriptions replace source evidence. Measure retrieval recall/precision and grounded answer quality against a non-enriched baseline.

### Concise interview answer

“Contextual Retrieval adds concise document or section context to otherwise ambiguous chunks before indexing, so a passage can be matched using information that was outside the local chunk. For example, a pronoun or metric becomes clearer when its section title and subject are included. I preserve the original text and source offsets, control the enrichment process, and compare retrieval and answer metrics against the baseline. The trade-offs are preprocessing and token cost, stale or incorrect generated context, and the need to enforce document permissions.”

### Revision summary

| Step | Purpose |
|---|---|
| Preserve original chunk | Maintain authoritative evidence and citation offsets. |
| Add concise context | Disambiguate local references and topic. |
| Index enriched content | Improve lexical/semantic matching. |
| Validate | Measure retrieval and answer gains, not just index changes. |
| Govern | Track provenance, permissions, and source updates. |

<br><br><br>

## What are embedding models, and how do they convert text to vectors?

**Answer:**

### Definition

An **embedding model** maps an input—such as a sentence, document chunk, image, or query—to a fixed-dimensional numeric vector. The model is trained so that useful relationships in the task are reflected in vector geometry: for example, semantically related texts may have vectors that are close under a chosen similarity measure.

For text, the model typically tokenizes the input, processes tokens through a neural network, and applies a pooling or output transformation to produce one vector. The details vary by architecture and model.

### Similarity search

Given query vector \(q\) and document vectors \(d_i\), a system ranks candidates with a similarity or distance function, commonly cosine similarity, dot product, or Euclidean distance:

\[
\operatorname{cosine}(q,d)=\frac{q\cdot d}{\|q\|\|d\|}
\]

The vectors can be searched with a nearest-neighbor index, often using approximate nearest-neighbor techniques for scale. This retrieves by learned similarity, not exact meaning or proof of factual relevance.

### Important practical details

- Use the model’s documented query/document encoding conventions, including any query prefixes.
- Respect model input limits; long inputs may be truncated or need chunking.
- Keep the embedding model and vector dimension consistent between indexed documents and queries.
- If changing embedding models or preprocessing, re-embed/reindex consistently; vectors from unrelated spaces are not directly comparable.
- Consider normalization and similarity metric requirements of the model and index.

Embeddings can miss rare terms, identifiers, negation, or exact numbers; hybrid lexical search can complement them. Embedding similarity is a retrieval signal, not a calibrated probability that a passage answers a question.

### Concise interview answer

“An embedding model converts text or another input into a dense numeric vector intended to place task-relevant similar items near one another. A RAG system embeds document chunks and queries, then ranks candidates using cosine similarity, dot product, or another supported metric, often through an approximate nearest-neighbor index. The vector is a learned representation, not a truth score. I keep model and preprocessing consistent, handle token limits, and combine semantic search with lexical signals when exact terms matter.”

### Revision summary

| Concept | Remember |
|---|---|
| Embedding | Fixed-dimensional learned representation. |
| Retrieval | Rank vectors with a defined similarity/distance function. |
| Index | Approximate nearest-neighbor search can scale retrieval. |
| Compatibility | Query and corpus embeddings must share model/preprocessing space. |
| Caveat | Similarity is not proof of relevance or correctness. |

<br><br><br>

## How do you choose an embedding model for your RAG system?

**Answer:**

### Begin with the retrieval task

Choose an embedding model based on the actual corpus and query distribution, not only a public leaderboard. Identify languages, domain terminology, document lengths, query types, freshness needs, privacy constraints, and expected throughput. Decide whether retrieval needs semantic matching, cross-lingual matching, code search, or multimodal support.

### Evaluation criteria

1. **Retrieval quality:** Measure recall@\(k\), precision@\(k\), MRR, or nDCG on labeled query-document pairs.
2. **Downstream quality:** Measure answer correctness, faithfulness, citation precision, and abstention after RAG generation.
3. **Robustness:** Test paraphrases, rare terminology, exact identifiers, negatives, multilingual queries, and long documents.
4. **Operations:** Compare latency, throughput, embedding/index cost, vector dimensions, memory, and reindexing requirements.
5. **Governance:** Check deployment location, data retention, licensing, privacy, versioning, and provider constraints.

Use the model’s recommended query/document encoding and similarity metric. Evaluate with the same chunking, filters, and retrieval settings planned for production; otherwise the comparison can be misleading. Consider a reranker or hybrid search if the embedding model alone misses exact terms.

### Migration considerations

Embedding spaces are model-specific. Do not mix vectors from different models in one similarity calculation unless the system explicitly supports a compatible mapping. Version the model and preprocessing pipeline; re-embed and rebuild or isolate indexes during migration, then compare quality and operational behavior before switching traffic.

### Concise interview answer

“I choose an embedding model by evaluating it on representative query-document pairs from the target corpus. I measure retrieval metrics and downstream answer faithfulness, including rare domain terms, exact identifiers, multilingual queries, and paraphrases. I also compare latency, throughput, vector size, hosting/privacy, cost, and reindexing impact. I use the model’s recommended query/document encoding and metric, and keep each model’s vectors in a consistent, versioned index.”

### Revision summary

| Criterion | How to test |
|---|---|
| Relevance | Labeled retrieval benchmarks and downstream RAG evaluation. |
| Coverage | Rare terms, exact matches, languages, and query variants. |
| Cost/performance | Latency, throughput, vector memory, embedding cost. |
| Compliance | Privacy, licensing, hosting, retention, versioning. |
| Compatibility | Same model/preprocessing for query and indexed vectors. |

<br><br><br>

## Explain Agentic RAG.

**Answer:**

### Definition

**Agentic RAG** is a retrieval-augmented system in which an agent can plan and take one or more retrieval-related actions dynamically rather than executing only one fixed search-and-answer pass. Depending on the task, it may rewrite a query, select a data source, apply filters, retrieve more evidence, use a tool, or stop and answer.

The key distinction is adaptive control flow. A basic RAG pipeline commonly performs a predefined retrieval step; Agentic RAG gives a model some control over whether and how to retrieve, within application-defined constraints.

### Example flow

1. Classify the request and identify missing evidence.
2. Choose an authorized source or search strategy.
3. Retrieve evidence and inspect whether it addresses the question.
4. If needed, reformulate the query or retrieve another bounded set.
5. Synthesize an answer with source references, or abstain when evidence remains insufficient.

### Benefits and trade-offs

Agentic retrieval can help with ambiguous queries, multi-hop questions, and multiple specialized data sources. It also adds model calls, latency, cost, nondeterminism, and more failure paths. A model may choose a poor source, loop, over-retrieve, or be manipulated by instructions in retrieved content.

Define allowed sources and actions, enforce ACLs server-side, treat retrieved text as untrusted, set strict call/token/time budgets, and log source selection. Compare the agent to a simpler baseline; if a fixed retrieval workflow performs as well, prefer the simpler design.

### Concise interview answer

“Agentic RAG uses a model-driven control loop to decide how and when to retrieve—possibly selecting sources, rewriting queries, or gathering additional evidence before synthesizing an answer. Its adaptivity can help with ambiguous or multi-hop questions, but it increases latency, cost, and operational risk. I bound calls and sources, enforce authorization outside the model, treat retrieved content as untrusted, preserve citations, and evaluate against a simpler fixed RAG baseline.”

### Revision summary

| Property | Basic RAG | Agentic RAG |
|---|---|---|
| Retrieval flow | Usually fixed query/retrieve/generate. | Model can choose additional retrieval actions. |
| Benefit | Simpler, predictable, efficient. | Adaptive for complex or multi-source tasks. |
| Risk | Retriever may miss evidence. | More calls, loops, tool misuse, and cost. |
| Safeguards | Retrieval ACLs and grounded generation. | Also bound actions, sources, and budgets. |

<br><br><br>

## What is hybrid search, and why is it better than pure vector search?

**Answer:**

### Definition

**Hybrid search** combines lexical retrieval—such as BM25 or another term-based method—with semantic vector retrieval. Lexical search is strong when the query contains exact terms, identifiers, names, or rare phrases. Dense vector search can find semantically related content even when wording differs.

The result sets can be combined using reciprocal rank fusion, a weighted score, or another calibrated method. A common rank-fusion method is:

\[
\operatorname{RRF}(d)=\sum_{r\in R}\frac{1}{k+\operatorname{rank}_r(d)}
\]

where \(R\) is the set of ranked lists and \(k\) is a smoothing constant. Rank fusion is useful when raw scores from different retrievers are not directly comparable.

### Why combine them?

| Search mode | Strength | Common miss |
|---|---|---|
| Lexical | Exact phrases, identifiers, product codes, rare words. | Synonyms and semantic paraphrases. |
| Vector | Conceptual similarity and alternative wording. | Exact strings, rare entities, negation, or subtle distinctions. |
| Hybrid | Broad semantic recall plus exact-term matching. | Needs tuning, deduplication, and evaluation. |

Hybrid is often better when a corpus and query set contain both semantic questions and exact terminology, but it is not automatically superior for every workload. Filters, analyzers, index quality, and fusion strategy matter.

### Production evaluation

Tune candidate depths and fusion on labeled queries. Measure recall@\(k\), precision/nDCG, downstream answer faithfulness, latency, and cost. Preserve metadata filters and authorization across both retrieval paths, deduplicate results by canonical document/chunk IDs, and inspect failures where one retriever contributes irrelevant candidates.

### Concise interview answer

“Hybrid search combines term-based retrieval such as BM25 with dense vector similarity. Lexical search catches exact identifiers and terminology, while vector search handles semantic paraphrases. Their rankings can be combined with a weighted method or reciprocal rank fusion, which avoids assuming the scores share a scale. Hybrid search is useful when both signals matter, but I validate it against the target query set, deduplicate candidates, preserve ACL filters, and measure downstream answer quality and latency.”

### Revision summary

| Signal | Best at | Combine with |
|---|---|---|
| Lexical/BM25 | Exact terms and rare identifiers. | Vector retrieval for semantic recall. |
| Dense vectors | Paraphrases and conceptual similarity. | Lexical retrieval for exact matches. |
| Fusion | Merge complementary ranked lists. | RRF or tuned score combination. |
| Evaluation | Query-specific relevance and answer quality. | Recall, ranking metrics, latency, cost. |

<br><br><br>

## What is re-ranking, and how does it improve RAG retrieval quality?

**Answer:**

### Definition

**Re-ranking** is a second-stage retrieval step that re-scores an initial set of candidate passages against the query and sorts them by estimated relevance. A fast retriever—often vector, lexical, or hybrid search—first returns a broader candidate set. A more expensive reranker then examines query-document pairs and selects or orders the most useful candidates for the final context.

### Why it helps

Initial retrieval optimizes for high recall and speed, but its similarity score may not reflect whether a passage directly answers the question. A reranker can consider token-level interactions, query constraints, and passage meaning more precisely. Better ordering can improve context quality when only the top few passages fit in the generation prompt.

Typical flow:

```text
query -> first-stage retrieval (top N) -> reranker -> selected top K -> generator
```

### Trade-offs and design

- **Candidate recall is a ceiling:** A reranker cannot promote a relevant passage that the first-stage retriever did not retrieve.
- **Latency and cost:** Reranking adds inference work; batch candidates and keep \(N\) bounded.
- **Context constraints:** Select passages by relevance and diversity, not score alone, to avoid near-duplicates.
- **Score interpretation:** Reranker scores are ranking signals, not necessarily calibrated probabilities.
- **Access control:** Apply authorization filters before ranking candidates and preserve permissions through context assembly.

Evaluate end-to-end improvements as well as reranker ranking metrics. Compare recall@\(N\) before reranking, nDCG/MRR after reranking, and downstream answer faithfulness, citations, latency, and cost.

### Concise interview answer

“Reranking takes a candidate set from a fast retriever and scores query-document pairs with a more precise model, then selects the best passages for the context. It can improve relevance at a fixed context budget, but it cannot recover evidence missing from the first-stage candidates and adds latency and cost. I keep candidate generation high-recall, bound and batch reranking, deduplicate results, preserve ACL filters, and evaluate both ranking metrics and final answer quality.”

### Revision summary

| Stage | Goal |
|---|---|
| First-stage retrieval | Quickly find a high-recall candidate set. |
| Reranker | More precisely order query-passage relevance. |
| Context selection | Fit relevant, diverse evidence within token budget. |
| Limitation | Cannot rank a passage that was never retrieved. |
| Evaluation | Ranking metrics plus answer quality, cost, and latency. |

<br><br><br>

## What is ColBERT, and how does late interaction retrieval work?

**Answer:**

### Core idea

**ColBERT** (Contextualized Late Interaction over BERT) is a neural retrieval approach that encodes the query and document separately into contextualized token-level vectors, then computes their interaction at scoring time. Because the document representation can be precomputed and indexed, it avoids running a full joint query-document Transformer for every candidate while retaining finer-grained matching than a single pooled vector.

### MaxSim late interaction

Let query token vectors be \(q_i\) and document token vectors be \(d_j\). A common ColBERT-style score is:

\[
S(q,d)=\sum_i \max_j q_i^\top d_j
\]

Each query token finds its best-matching document token, and those best-match scores are aggregated. This is called **late interaction** because query and document encodings are computed independently first, then interact during scoring.

### Comparison with single-vector and cross-encoder retrieval

- **Single-vector bi-encoder:** Stores one vector per document; efficient ANN search, but compresses all token-level details into one representation.
- **ColBERT:** Stores multiple token vectors per document; more expressive token matching, but larger index and more complex retrieval.
- **Cross-encoder:** Processes query and document jointly; often strong reranking quality, but requires model inference for each pair and is expensive at large candidate counts.

### When useful and operational costs

ColBERT can be useful when exact token-level matching and semantic context both matter, and where the additional storage and serving complexity are acceptable. Its multi-vector index can be significantly larger than a single-vector index. Measure index size, candidate latency, ranking quality, and downstream answer quality on the actual corpus. As with other neural retrieval, it does not guarantee factual support or replace authorization filtering.

### Concise interview answer

“ColBERT is a late-interaction retriever: it independently encodes a query and each document into contextualized token vectors, then scores them by matching each query token to its best document-token match, commonly with a MaxSim aggregation. This retains finer-grained matching than one pooled embedding while allowing document encodings to be precomputed, unlike a cross-encoder that jointly processes each pair. The trade-off is a larger multi-vector index and more complex retrieval. I choose it only when measured quality justifies its storage and latency.”

### Revision summary

| Retrieval type | Representation | Interaction |
|---|---|---|
| Bi-encoder | One vector per query/document. | Similarity after independent encoding. |
| ColBERT | Multiple contextualized token vectors. | Late token-level MaxSim interaction. |
| Cross-encoder | Joint query-document sequence. | Full interaction during each pair’s inference. |
| ColBERT trade-off | Finer matching. | More index storage and retrieval complexity. |

<br><br><br>

## Compare reranker architectures: cross-encoder, ColBERT, and LLM-based rerankers.

**Answer:**

### Architectural comparison

| Architecture | How it scores | Strengths | Trade-offs |
|---|---|---|---|
| **Cross-encoder** | Encodes query and passage together and predicts a relevance score. | Strong fine-grained interaction; effective reranking of a limited candidate set. | Must run for each query-passage pair; latency and compute grow with candidates and passage length. |
| **ColBERT** | Independently encodes query and passage into token vectors, then uses late interaction (e.g., MaxSim). | Token-level matching with document representations precomputed; can scale better than joint encoding for some workloads. | Multi-vector index increases storage and serving complexity; retrieval is more involved than a single-vector ANN index. |
| **LLM-based reranker** | Uses an instruction-following LLM to judge or order query-passage relevance, often with a structured prompt or pairwise comparisons. | Flexible criteria, can incorporate task-specific instructions, and may provide interpretable labels/rationales. | High token cost and latency, output variability, prompt sensitivity, context limits, and possible position bias. |

These are broad patterns, not guarantees: actual results depend on model size, index, candidate count, truncation, hardware, and implementation. An LLM-generated rationale is not itself evidence that a ranking is correct.

### Choosing one

1. Establish candidate-set recall with the first-stage retriever.
2. Compare ranking quality on labeled query-passage pairs.
3. Measure downstream answer faithfulness and citation quality.
4. Benchmark p50/p95 latency, throughput, compute, and index footprint at production candidate sizes.
5. Test long passages, multiple languages, hard negatives, position effects, and adversarial content.
6. Select the least expensive architecture that meets quality and operational targets.

In many systems, a cross-encoder is a practical reranker for a modest top-\(N\) set, ColBERT is attractive when token-level retrieval and precomputation justify a multi-vector index, and an LLM reranker is useful when criteria are complex or change often—provided its cost and variance are acceptable.

### Concise interview answer

“A cross-encoder jointly processes each query-passage pair and often provides strong reranking but costs an inference per pair. ColBERT independently encodes token vectors and scores them with late interaction, trading a larger multi-vector index for more scalable token-level matching. An LLM reranker can follow flexible instructions but is typically more expensive, slower, and more variable. I compare them on labeled ranking data and end-to-end RAG quality, while measuring p95 latency, throughput, and storage at production scale.”

### Revision summary

| Choice | Prefer when |
|---|---|
| Cross-encoder | Candidate set is bounded and high pairwise relevance quality matters. |
| ColBERT | Token-level interactions and precomputable document vectors justify storage. |
| LLM reranker | Criteria are complex/flexible and cost/latency remain acceptable. |
| All | Candidate recall, ranking quality, downstream quality, and operations must be measured. |

<br><br><br>

## How do you handle multi-document and multi-hop questions in RAG?

**Answer:**

### Why one-shot retrieval may fail

A multi-document question requires evidence from several sources; a multi-hop question requires retrieving one fact, using it to identify or formulate the next retrieval, and combining the results. A single nearest-neighbor query can miss one of the needed pieces, especially when the full question does not contain the terms used in an intermediate document.

### A robust strategy

1. **Decompose the question** into answerable subquestions or required facts.
2. **Retrieve candidates for each subquestion**, using hybrid search, metadata filters, or source-specific queries as appropriate.
3. **Follow entities and relationships** discovered in evidence to formulate bounded follow-up searches.
4. **Deduplicate and rerank** the combined evidence; retain provenance for every fact.
5. **Build an evidence map** that links each subclaim to one or more source passages.
6. **Synthesize only supported conclusions** and cite the relevant sources; abstain or ask for clarification if a necessary hop is missing.

For complex workflows, a graph, SQL query, or domain-specific tool may express relationships more reliably than repeatedly asking an LLM to search. The model can help plan, but application code should enforce source permissions and call limits.

### Avoid common failures

Bound hop count, retrieval calls, token budget, and wall-clock time. Prevent one unsupported intermediate result from becoming a premise for later steps. Check for contradictory evidence, duplicate sources, and entity-resolution errors. Evaluate each hop’s retrieval recall as well as final answer correctness and citation support.

### Concise interview answer

“For multi-document or multi-hop questions, I decompose the request into subquestions, retrieve evidence for each, and use entities or relations in the first results to guide bounded follow-up retrieval. I deduplicate and rerank the evidence, preserve source provenance, and map each final claim back to supporting passages. A graph or structured query may be better for explicit relationships. I cap hops and calls, enforce ACLs on every retrieval, and evaluate hop-level recall and final faithfulness.”

### Revision summary

| Stage | Purpose |
|---|---|
| Decompose | Identify facts and relationships needed. |
| Retrieve iteratively | Follow evidence to the next query/hop. |
| Consolidate | Deduplicate, rerank, preserve provenance. |
| Verify | Ensure each subclaim has support and no unsupported leap. |
| Bound | Limit hops, calls, context, latency, and permissions. |

<br><br><br>

## What is the "lost in the middle" problem in RAG systems?

**Answer:**

### The issue in a RAG context

The **“lost in the middle”** problem is the tendency observed in some language models to use relevant evidence less reliably when it appears in the middle of a long context than when it is near the beginning or end. In RAG, the retriever may return the right passage, but context assembly can still bury it among many chunks, making the final answer omit or misuse it.

This is distinct from a retrieval miss: the evidence may be present in the prompt yet not effectively used. It is also model- and task-dependent, so it should be measured rather than assumed.

### Mitigations

- Retrieve fewer, more relevant passages; increase reranking quality rather than context length alone.
- Deduplicate overlapping chunks and avoid including several near-identical passages.
- Order evidence using a tested policy, such as relevance or grouping by subquestion; do not assume one universal best ordering.
- Keep evidence concise while retaining critical qualifiers, tables, and provenance.
- Separate subquestions and their evidence for multi-hop tasks.
- Ask for citations or claim-evidence mappings and validate them against source text.
- Test by moving the same evidence to beginning, middle, and end positions while holding other content constant.

Context compression or summaries can reduce noise but may drop qualifiers. Preserve the original passage for verification, and measure answer quality and citation faithfulness before adopting a compression strategy.

### Concise interview answer

“In RAG, lost in the middle means the model may fail to use a relevant chunk even though retrieval placed it inside a long prompt. It is an evidence-utilization problem, not necessarily a retrieval miss. I improve candidate precision with reranking, remove duplicates, use a measured evidence-ordering and grouping strategy, keep context concise, and request verifiable citations. I test with position-controlled experiments because the effect varies by model and task.”

### Revision summary

| Failure point | Mitigation |
|---|---|
| Too many candidates | Improve retrieval/reranking; reduce context. |
| Duplicate chunks | Deduplicate and control overlap. |
| Evidence position | Test ordering and position sensitivity. |
| Long multi-hop context | Group evidence by subquestion and preserve citations. |
| Summarization loss | Verify compressed claims against original passages. |

<br><br><br>

## How do you evaluate a RAG system? Explain faithfulness, relevance, and context precision/recall.

**Answer:**

### Evaluate retrieval and generation separately

RAG quality is a pipeline property. A useful evaluation separates:

1. **Retrieval:** Did the system find the evidence needed to answer?
2. **Generation:** Did the model answer correctly and use the evidence faithfully?
3. **End-to-end behavior:** Did the user receive a useful, supported answer or an appropriate abstention?

Create a representative set of queries with expected answers and, where possible, annotated relevant passages. Include common, ambiguous, unanswerable, multi-hop, long-document, adversarial, and permission-scoped cases.

### Core metrics

- **Faithfulness / groundedness:** Are the answer’s factual claims supported by the retrieved context? This measures support from context, not necessarily truth in the world; the source itself may be wrong.
- **Answer relevance:** Does the response address the user’s actual question, at the requested scope and format?
- **Context precision:** How much of the retrieved context is relevant? High precision means less distracting or redundant material.
- **Context recall:** How much of the required relevant evidence was retrieved? High recall means fewer necessary facts were missed.

For labeled retrieval results, standard ranking metrics can help:

\[
\operatorname{Precision@k}=\frac{\text{relevant retrieved items in top }k}{k}
\]
\[
\operatorname{Recall@k}=\frac{\text{relevant retrieved items in top }k}{\text{all relevant items}}
\]

MRR or nDCG can capture ranking quality, especially when the position of relevant passages matters. These metrics require consistent relevance judgments and careful handling of multiple valid sources.

### Evaluation methods and caveats

Use deterministic checks for citations, schemas, exact facts, and access-control behavior where possible. Human review is valuable for nuanced answers. LLM-as-judge can scale assessment, but must be calibrated against human ratings and objective tests; it can share biases with the generator. Track abstention quality, citation precision, hallucination rate, latency, cost, freshness, and ACL correctness, and inspect results by query/document/language slices.

### Concise interview answer

“I evaluate RAG at three levels: retrieval coverage and ranking, answer grounding and relevance, and end-to-end usefulness including abstention. Faithfulness asks whether claims are supported by retrieved context; relevance asks whether the answer addresses the query; context precision measures how much retrieved material is useful, while context recall measures whether required evidence was found. I use labeled retrieval metrics such as recall@k and nDCG, human review and calibrated judges for nuanced quality, and deterministic checks for citations and permissions. Faithfulness does not prove that the source itself is true.”

### Revision summary

| Metric | Question answered |
|---|---|
| Faithfulness | Are answer claims supported by retrieved evidence? |
| Answer relevance | Does the response address the question? |
| Context precision | Is retrieved context mostly useful? |
| Context recall | Was the necessary evidence retrieved? |
| End-to-end | Is the result correct, safe, useful, fresh, and affordable? |

<br><br><br>

## Explain Self-RAG. How does the model decide when to retrieve?

**Answer:**

### Core idea

**Self-RAG** is a retrieval-augmented generation approach that makes retrieval and response generation more adaptive. Rather than retrieving the same way for every prompt, the model can decide whether external evidence is needed, retrieve passages, and assess whether those passages and the resulting answer are relevant and supported.

In the Self-RAG research approach, special reflection tokens are used to represent decisions or critiques such as whether to retrieve, whether a passage is relevant, whether a response is supported by evidence, and how useful the response is. The exact token set and inference procedure are method-specific; “Self-RAG” should not be reduced to any generic agent that retries search.

### High-level process

1. **Assess need:** Determine whether the question can be answered from available model knowledge or requires external evidence.
2. **Retrieve when needed:** Search the configured corpus and obtain candidate passages.
3. **Assess passages:** Estimate relevance and discard evidence that does not support the query.
4. **Generate with evidence:** Produce a response conditioned on selected passages.
5. **Critique:** Check support/faithfulness and usefulness; revise, retrieve again, or abstain when appropriate.

Retrieval decisions may be learned or driven by special tokens, thresholds, or a controller depending on the implementation. A decision to skip retrieval is not proof the model already knows the answer.

### Benefits and limitations

Adaptive retrieval can reduce unnecessary searches on simple questions and improve grounding on knowledge-intensive ones. It introduces more complex training or inference, additional latency when retrieval/critique is triggered, and potential errors in the model’s self-assessment. A model can incorrectly decide not to retrieve, judge irrelevant evidence as relevant, or accept an unsupported answer.

For production, enforce ACLs independently, bound retrieval/revision cycles, preserve citations, and evaluate retrieval precision/recall and answer faithfulness. Compare against a simple retrieve-always and retrieve-never baseline for the target workload.

### Concise interview answer

“Self-RAG makes retrieval and generation adaptive: the model can decide whether to retrieve, judge candidate passages for relevance, generate from selected evidence, and critique whether its answer is supported and useful. The research formulation uses reflection signals/tokens to guide these steps. It can avoid unnecessary retrieval and improve groundedness, but its self-assessments can be wrong and the loop adds complexity and latency. I bound iterations, preserve ACL enforcement and citations, and compare it with fixed retrieval baselines using retrieval and answer metrics.”

### Revision summary

| Stage | Function |
|---|---|
| Decide | Estimate whether external retrieval is needed. |
| Retrieve | Search for supporting passages when triggered. |
| Reflect | Assess relevance, support, and usefulness. |
| Respond | Answer, revise within bounds, or abstain. |
| Caveat | Self-critique is fallible; validate against external evidence. |

<br><br><br>

## What is GraphRAG, and when would you use it over traditional RAG?

**Answer:**

### Definition

**GraphRAG** combines retrieval-augmented generation with a graph representation of entities and relationships. Documents are processed to identify entities, links, and sometimes communities or summaries; queries can retrieve relevant graph elements, connected evidence, and source passages for generation.

The term covers multiple system designs. Some graph-based RAG systems use a knowledge graph as the primary retriever; others combine graph traversal with vector or lexical retrieval. A graph is not automatically more accurate simply because relationships are explicit.

### Why use a graph?

Traditional chunk retrieval is effective for questions answered by a small number of semantically similar passages. A graph can help when queries require:

- traversing explicit multi-hop relationships;
- aggregating information across many entities or documents;
- answering questions about connections, hierarchies, or communities;
- combining structured entity data with unstructured source text.

For example, “Which teams are affected by the service owned by the group that maintains the authentication platform?” may require following several ownership/dependency edges and verifying each edge against source evidence.

### Trade-offs and architecture

Graph construction may require entity resolution, relation extraction, schema design, and updates when source documents change. Errors in extracted edges can propagate into confident but false answers. Graph storage, query planning, and governance add operational complexity. Retain provenance from each node/edge to its source passage and timestamp; retrieve supporting text for final verification.

Use graph retrieval when relationship structure is central and evaluate it against vector/hybrid RAG on multi-hop and aggregation questions. For simpler semantic lookups, standard chunk retrieval may be cheaper and easier to maintain.

### Concise interview answer

“GraphRAG augments generation with a graph of entities and relationships extracted from or linked to source data. It is useful for multi-hop, relationship, and corpus-level questions that ordinary nearest-neighbor chunk retrieval may miss. Graph construction and entity resolution introduce cost and error risk, so I preserve provenance for every edge, verify final claims against source passages, and compare graph-based retrieval with simpler hybrid RAG on the target queries. I use it when the relationship structure justifies the added complexity.”

### Revision summary

| Approach | Strong fit |
|---|---|
| Vector/chunk RAG | Local semantic questions answered by a few passages. |
| GraphRAG | Multi-hop relationships, entity connections, or corpus-level aggregation. |
| Hybrid graph + vector | Questions needing both relationship traversal and supporting text. |
| Main risk | Incorrect entity/relation extraction can create false paths. |
| Safeguard | Provenance, source verification, and comparative evaluation. |

<br><br><br>

## Vectorless RAG

**Answer:**

### Clarify the term

**Vectorless RAG** is not a single universally standardized architecture. The phrase generally describes retrieval-augmented systems that do not depend on dense vector embeddings as their primary retrieval mechanism. Depending on the source, this may mean lexical search, database queries, graph traversal, metadata filtering, or model-assisted selection over structured documents.

“RAG” still means that external information is retrieved and supplied or otherwise made available to a generator. Removing vector embeddings does not mean removing retrieval.

### Common retrieval options

- **Lexical/full-text search:** BM25 or inverted indexes match terms and phrases; effective for exact identifiers, names, and rare terminology.
- **Structured queries:** SQL or APIs answer precise questions over governed records.
- **Graph traversal:** Follow explicit entity relationships.
- **Metadata and rules:** Filter by date, document type, tenant, or known attributes.
- **Hierarchical navigation:** Search titles/headings first, then inspect selected sections or pages.

These approaches can be combined. For example, lexical search may find candidate documents, metadata filters narrow the scope, and an LLM synthesizes the selected passages.

### When it helps and what it trades off

Vectorless retrieval can be simpler, more interpretable, cheaper to maintain, or more accurate for exact terms and structured questions. It may underperform for paraphrases and semantic similarity unless lexical expansion, synonyms, or another semantic layer is added. Search quality depends on tokenization, analyzers, schema, query formulation, and content normalization.

Choose by evaluating relevant queries rather than by assuming vector search is mandatory or undesirable. Compare recall, ranking quality, end-to-end answers, latency, operational cost, and explainability on the target data.

### Concise interview answer

“Vectorless RAG usually means retrieving evidence without dense embedding similarity—using methods such as BM25/full-text search, SQL, metadata filters, or graph traversal—then providing the retrieved results to a generator. The term is not standardized, so I clarify which retrieval mechanism is meant. It can work well for exact terms, structured records, or auditable search, but lexical methods may miss paraphrases. I select and combine retrieval methods based on measured query coverage and end-to-end quality.”

### Revision summary

| Method | Good at |
|---|---|
| Lexical search | Exact phrases, identifiers, rare terms. |
| SQL/API | Structured, current, transactional facts. |
| Graph traversal | Explicit relationships and multi-hop paths. |
| Metadata filtering | Known attributes and access scopes. |
| Key caveat | “Vectorless RAG” describes a family, not one fixed method. |

<br><br><br>

## How do you handle structured data (tables, SQL databases) in a RAG pipeline?

**Answer:**

### Use the structure instead of flattening everything

Tables and databases encode schemas, types, keys, and relationships that can be lost when rows are flattened into text chunks. Select the retrieval method based on the question:

- **Exact/current values and aggregations:** Query the authoritative database or API.
- **Narrative descriptions or schema documentation:** Use text retrieval.
- **Mixed questions:** Combine structured queries with retrieved explanatory documents and synthesize the results with provenance.

### Safe SQL-backed workflow

1. Provide the model with a bounded schema description and allowed tables/columns—not unrestricted database access.
2. Have it propose a typed query or use a structured query planner.
3. Parse and validate the query against an allowlist and query policy.
4. Execute with a read-only, least-privilege database role; enforce tenant/user authorization in the database or trusted service.
5. Apply row limits, timeouts, cost/resource controls, and parameterized execution.
6. Return only authorized results with column names, units, filters, and provenance.
7. Ask the model to explain the result without inventing fields or extrapolating beyond returned rows.

Never execute arbitrary generated SQL directly. Protect against prompt injection in schema comments or retrieved records, and avoid placing credentials in the prompt.

### Handling tables in document collections

Preserve headers, row/column associations, units, footnotes, merged cells, and page/source references during extraction. Index table captions and structured representations where appropriate; retrieve the relevant rows or table region rather than a large flattened dump. Validate numeric computations with deterministic code and retain source coordinates for citations.

### Concise interview answer

“For structured data, I preserve the schema and use SQL or an API for exact, current values and aggregations rather than flattening everything into vector chunks. The model may help formulate a query, but a trusted layer validates it, enforces authorization, executes with least privilege and resource limits, and returns bounded results with units and provenance. For document tables, I preserve headers, row relationships, and source locations and verify calculations deterministically. Mixed questions can combine structured results with text RAG.”

### Revision summary

| Data/query type | Retrieval approach |
|---|---|
| Exact structured fact or aggregation | Governed SQL/API query. |
| Explanatory narrative | Text RAG. |
| Table in PDF/document | Structure-aware extraction with headers and provenance. |
| Mixed question | Combine structured query and cited text evidence. |
| Security | Validate query, enforce ACLs, use read-only least privilege and limits. |

<br><br><br>

## What are the common failure modes of RAG systems, and how do you debug them?

**Answer:**

### Common failure modes by stage

| Stage | Typical failure |
|---|---|
| Ingestion/parsing | Missing pages, broken text order, lost tables/headers, stale or duplicate documents. |
| Chunking | Chunks split key context, mix unrelated topics, or exceed model limits. |
| Embedding/index | Wrong model or preprocessing, inconsistent vector space, index drift, poor ANN settings. |
| Retrieval | Relevant evidence is missed; irrelevant or unauthorized passages are returned. |
| Reranking/context assembly | Relevant passages are reordered poorly, duplicated, truncated, or buried. |
| Generation | Model ignores evidence, hallucinates, overstates certainty, or cites unsupported claims. |
| Operations/governance | Stale index, broken ACLs, high latency/cost, or untraceable prompt/model changes. |

### Debug in a traceable sequence

1. Reproduce the request and record the prompt/model version, query, retrieved IDs/scores, filters, assembled context, generated answer, and timing for each stage—while protecting sensitive data.
2. Verify the source document is current, parsed correctly, and present in the expected index version.
3. Check retrieval independently with labeled relevant passages and inspect candidate recall before blaming generation.
4. Inspect chunk boundaries, metadata filters, query/document embedding consistency, lexical candidates, and reranker ordering.
5. Confirm the right evidence actually reached the model without truncation or contradictory prompt instructions.
6. Compare the answer’s individual claims with cited passages; distinguish retrieval failure from evidence-use failure.
7. Add a regression test for the failure, fix the responsible layer, and validate both quality and operational metrics.

Do not “fix RAG” by changing the generation prompt when the source was never retrieved, or by changing the retriever when the model received good evidence but ignored it.

### Concise interview answer

“I debug RAG stage by stage: source freshness and parsing, chunking, embedding/index consistency, retrieval and ACL filters, reranking/context assembly, then generation and citations. I capture a privacy-safe trace of retrieved IDs, scores, context, model version, and per-stage timing. I evaluate retrieval with labeled evidence before assessing answer faithfulness, identify the root-cause stage, add a regression case, and verify both quality and latency after the fix.”

### Revision summary

| Symptom | First place to inspect |
|---|---|
| Answer missing a fact | Source/index presence and retrieval recall. |
| Wrong passage returned | Chunking, query formulation, embeddings, filters, reranking. |
| Correct evidence, wrong answer | Context assembly, truncation, generation faithfulness. |
| Stale answer | Ingestion events, index version, cache invalidation. |
| Inconsistent incident | Trace/versioning, regression tests, stage-level metrics. |

<br><br><br>

## How do you handle document updates and maintain freshness in a RAG system?

**Answer:**

### Treat the index as a versioned materialized view

The source system remains authoritative; the RAG index is derived data that must be reconciled with source changes. Track stable document IDs, source versions or content hashes, timestamps, parser/chunker versions, embedding model versions, and index build identifiers.

### Update workflow

1. **Detect changes:** Use source events, CDC, scheduled scans, or webhooks; record create, update, and delete events.
2. **Process idempotently:** Re-parse and re-chunk only affected documents when possible, using deterministic IDs to avoid duplicates.
3. **Replace consistently:** Upsert new chunks and remove obsolete chunks for that document; do not leave deleted content searchable.
4. **Handle embedding changes:** Re-embed when model or preprocessing changes; keep old and new index versions isolated during migration.
5. **Publish safely:** Build or update a versioned index, validate counts and sample retrievals, then switch traffic via an atomic alias or controlled rollout.
6. **Invalidate dependent caches:** Include document/index version in cache keys or invalidate affected entries.
7. **Monitor lag and correctness:** Track source-to-index delay, failed jobs, deletion lag, duplicate/stale chunks, and freshness by source.

For frequently changing data, stream or incrementally process updates; for low-change corpora, scheduled batch rebuilds may be simpler. Define freshness SLAs per data source and retain rollback capability. Apply ACL changes and deletions promptly, since stale permissions can expose data even when answer quality appears fine.

### Concise interview answer

“I treat the retrieval index as a versioned materialized view of an authoritative source. I detect create/update/delete events, process documents idempotently using stable IDs and hashes, replace affected chunks, and re-embed when the embedding or preprocessing version changes. I validate a new index before switching traffic, invalidate version-sensitive caches, monitor source-to-index lag and deletion correctness, and preserve rollback. Freshness SLAs and ACL updates are part of correctness, not just content quality.”

### Revision summary

| Concern | Practice |
|---|---|
| Change detection | Events, CDC, webhooks, or scheduled reconciliation. |
| Idempotency | Stable document/chunk IDs and content hashes. |
| Deletes/ACLs | Remove stale chunks and revoke access promptly. |
| Versioning | Track parser, chunker, embedding, corpus, and index versions. |
| Safe release | Validate, switch traffic gradually/atomically, rollback if needed. |

<br><br><br>

## How do you optimize RAG for latency in production?

**Answer:**

### Establish a latency budget

Instrument end-to-end latency and break it down into authentication/authorization, query transformation, embedding, search, reranking, context assembly, model time-to-first-token, generation, and network overhead. Track p50/p95/p99, throughput, queueing, timeouts, and quality by workload; otherwise an optimization may only move the bottleneck.

### High-impact techniques

- **Reduce unnecessary work:** Use bounded candidate counts, fewer generation tokens, and simpler fixed retrieval for straightforward questions.
- **Optimize retrieval:** Tune ANN indexes, metadata filters, query-time `top-k`, and shard/partition strategy based on recall-latency trade-offs.
- **Parallelize independent work:** Run lexical and vector retrieval concurrently, and parallelize independent subqueries where safe.
- **Use reranking selectively:** Rerank a bounded high-recall candidate set; skip or simplify it for low-risk queries if evaluation supports that.
- **Avoid repeated preprocessing:** Cache query embeddings or retrieval results when freshness, user isolation, and access scope are included in cache keys.
- **Use streaming:** Stream answer tokens to improve perceived latency while still enforcing output validation and safe completion behavior.
- **Batch and scale:** Batch embedding/reranking work when beneficial; autoscale services and indexes based on queue/latency metrics.
- **Reduce context cost:** Deduplicate, compress carefully, and include only relevant evidence; verify that this does not harm faithfulness.

### Trade-offs and safeguards

Lower `top-k`, smaller rerankers, and aggressive caching can reduce latency but may lower recall or return stale/unauthorized results. Cache keys must include tenant/user permissions and index version where relevant. Set timeouts, circuit breakers, backpressure, and clear fallback behavior. Test changes with both latency benchmarks and retrieval/answer quality evaluations.

### Concise interview answer

“I first profile end-to-end and per-stage p50/p95/p99 latency, including embedding, retrieval, reranking, model prefill, generation, and queueing. Then I reduce unnecessary candidates and output, tune ANN and filters, parallelize independent searches, rerank selectively, cache only with freshness and ACL-aware keys, and stream responses. Every change is evaluated against retrieval recall and answer quality because lower `top-k` or aggressive caching can make the system faster but wrong or unsafe.”

### Revision summary

| Bottleneck | Optimization |
|---|---|
| Query/search | ANN tuning, filters, bounded candidates, parallel hybrid search. |
| Reranking | Bound candidate set, batch, or selectively skip. |
| Generation | Reduce irrelevant context/output; stream. |
| Repeated work | Cache with index-version and permission-aware keys. |
| Verification | Track latency percentiles alongside recall, faithfulness, and safety. |

<br><br><br>

## What is the role of metadata filtering in RAG systems?

**Answer:**

### What metadata filtering does

**Metadata filtering** restricts retrieval candidates using structured attributes associated with documents or chunks—such as tenant, user/group permissions, source type, date, product, language, jurisdiction, or document status. It can improve relevance by narrowing the search space and is essential for access control when implemented correctly.

Filters may be applied before vector/lexical search, during index search, or after candidate retrieval. For security-sensitive scopes, prefer enforcement within the trusted retrieval layer before content is returned; post-filtering alone can be inefficient and may leak through logs, counts, or intermediate outputs.

### Design considerations

- Define normalized, typed metadata fields and controlled vocabularies.
- Attach ACL and tenant metadata from trusted source systems, not from model-generated text.
- Apply authorization on every query using the authenticated identity and current policy.
- Combine filters with lexical/vector retrieval and ensure the search backend actually honors them.
- Decide how missing, stale, or contradictory metadata is handled; fail closed for protected content.
- Preserve filter provenance and test group membership changes, revocations, and cross-tenant isolation.

Metadata filters can improve retrieval precision and reduce search cost, but an overly narrow or incorrect filter can hide relevant evidence. A filter is not a substitute for source-of-truth authorization; permissions may change between indexing and retrieval.

### Concise interview answer

“Metadata filtering constrains RAG candidates by structured attributes such as tenant, ACL, date, source, or language. It improves relevance and, when applied by the trusted retrieval service, enforces document scope before content reaches the model. I derive ACL metadata from authoritative identity systems, re-check current permissions at query time, fail closed for protected data, and test revocations and tenant isolation. I also monitor over-filtering because incorrect metadata can silently reduce recall.”

### Revision summary

| Metadata use | Example |
|---|---|
| Authorization | Tenant, user/group ACL, classification level. |
| Relevance | Language, product, source type, topic. |
| Freshness | Effective date, version, status. |
| Security rule | Apply trusted current permissions before returning content. |
| Quality risk | Bad filters can exclude correct evidence. |

<br><br><br>

## Compare RAG vs fine-tuning. When would you use each?

**Answer:**

### Different mechanisms

**RAG** supplies external evidence at inference time. It is well suited to changing facts, private or document-specific knowledge, and answers that need source attribution. It requires a retrieval/indexing pipeline and can fail if relevant evidence is missed or misused.

**Fine-tuning** updates model parameters using task- or domain-specific examples. It is suited to changing behavior—such as response style, task format, classification patterns, or specialized skills—when the data and evaluation justify training. Fine-tuning does not provide a reliable, easily updated factual database and can encode stale or incorrect information.

### Comparison

| Dimension | RAG | Fine-tuning |
|---|---|---|
| Knowledge/behavior | Retrieves current external content. | Changes model behavior/parameters. |
| Updates | Update the data/index. | Retrain or continue training and validate a model release. |
| Attribution | Can cite retrieved sources. | Usually cannot identify a supporting training example at inference. |
| Best fit | Fresh facts, private documents, source-grounded answers. | Stable task behavior, style, format, or domain patterns. |
| Main failure | Retrieval miss, stale index, poor grounding. | Overfitting, forgetting, data leakage, stale learned facts. |
| Operations | Connectors, parsing, index, ACLs. | Data curation, training, model/version deployment. |

The methods can be combined: fine-tune a model to follow a domain-specific answer format, then use RAG to supply current authorized evidence. Before fine-tuning, compare prompt engineering, structured output, retrieval, and smaller task-specific models.

### Concise interview answer

“RAG changes the evidence available at inference by retrieving external documents; fine-tuning changes model parameters to adapt behavior. I choose RAG for fresh, private, auditable knowledge that needs citations, and fine-tuning for stable patterns such as task behavior, style, or format when labeled examples show a measurable gain. RAG adds retrieval and index operations; fine-tuning adds training and model-release governance. They are complementary, but fine-tuning should not be treated as a dependable database for frequently changing facts.”

### Revision summary

| Need | Prefer |
|---|---|
| Frequently updated factual knowledge | RAG or direct structured data access. |
| Citations and source traceability | RAG. |
| Stable behavior/style/task adaptation | Fine-tuning, if evaluation supports it. |
| Both current evidence and specialized behavior | Combine fine-tuning with RAG. |
| Decision rule | Benchmark quality, safety, freshness, cost, and operations. |

<br><br><br>

## Long context windows keep getting cheaper. When should you use retrieval (RAG) vs putting everything in the context window?

**Answer:**

### Compare the actual workload

The choice is not simply “short context versus long context.” Use a long context when the complete, relevant corpus for a request is bounded, fits comfortably within the model’s effective context, and benefits from seeing all material together—for example, comparing a small set of documents or summarizing one report.

Use **RAG** when the corpus is large or frequently changing, only a small fraction is relevant to each query, permissions vary by user, or the system needs targeted source attribution. Retrieval can reduce prompt size and focus evidence, but introduces ingestion, indexing, freshness, and retrieval-miss risks.

### Trade-offs

| Factor | Long-context input | RAG |
|---|---|---|
| Setup | Simple for bounded inputs. | Requires ingestion, index, retrieval, and operations. |
| Per-request context | Can be large and costly even when much is irrelevant. | Sends selected evidence, generally reducing prompt volume. |
| Coverage | All supplied content is available, but not guaranteed to be used. | Can miss relevant evidence during retrieval. |
| Freshness | Current if the application supplies current source content. | Depends on index update and cache invalidation. |
| Access control | Application must select authorized content before inclusion. | Retrieval layer must enforce ACLs for every query. |
| Evidence handling | Many documents may be harder to cite precisely. | Chunk/source metadata supports targeted citations. |

Long context is not unlimited effective attention: models may miss evidence, and prefill latency/cost can remain substantial. RAG is not automatically cheaper if retrieval, reranking, and repeated indexing are expensive. Hybrid designs are common: retrieve candidate documents, then provide their full sections or neighboring context to the model.

### Decision process

Benchmark both approaches on representative queries. Measure answer quality, evidence coverage, citation accuracy, latency percentiles, input/output tokens, freshness, and operational cost. Include long, multi-document, and access-controlled cases. Select the simplest design that meets requirements and has safe failure behavior when evidence is missing.

### Concise interview answer

“I use long context when the complete relevant input is bounded and jointly reading it helps, such as comparing a few documents. I use RAG when the corpus is large, dynamic, selectively relevant, or permission-scoped, because retrieval limits per-request context and can provide targeted sources. Long context still has cost and effective-attention limits; RAG adds index and retrieval failure modes. I benchmark both on answer quality, evidence coverage, citations, latency, freshness, and total cost, and often combine retrieval with full-section context.”

### Revision summary

| Prefer | When |
|---|---|
| Long context | Small, bounded corpus; joint comparison; simple ingestion path. |
| RAG | Large/dynamic corpus; selective retrieval; ACLs and citations. |
| Hybrid | Retrieve relevant documents, then include richer local context. |
| Evaluate | Quality, coverage, cost, latency, freshness, permissions. |

<br><br><br>

## What is query transformation in RAG (HyDE, query decomposition, step-back prompting)?

**Answer:**

### Definition

**Query transformation** rewrites or expands a user’s query before retrieval to better match the corpus or expose the information needs behind the request. The original question should be retained so the final answer is still directed at the user’s actual intent.

### Common methods

- **Query rewriting/expansion:** Generate clearer or alternative phrasings, synonyms, entities, or keywords; search with one or more variants and merge results.
- **HyDE (Hypothetical Document Embeddings):** Generate a hypothetical answer/document that might address the question, embed that text, and use it as a retrieval query. The hypothetical text is a retrieval aid—not evidence—and must never be cited as fact.
- **Query decomposition:** Break a complex or multi-hop question into subquestions, retrieve for each, and combine evidence with provenance.
- **Step-back prompting:** Formulate a broader, more general question that retrieves background principles or context, then use that evidence alongside retrieval for the specific question.

### Design and risks

Transformation can improve recall when the original query is short, ambiguous, or uses different language from the corpus. It can also drift from user intent, introduce invented terms, increase calls and latency, or retrieve irrelevant passages. Preserve the original query, bound the number of variants/subqueries, deduplicate results, and apply ACL filters to every search. Evaluate retrieval recall and downstream answer quality against the untransformed baseline.

### Concise interview answer

“Query transformation creates retrieval-friendly queries while preserving the original user intent. Rewriting adds likely terms; HyDE retrieves using an embedding of a hypothetical answer; decomposition splits a multi-part question; and step-back prompting retrieves broader background context. HyDE output is only a search probe, never source evidence. I bound transformations, deduplicate merged results, enforce permissions on every query, and measure recall and answer quality against a baseline to catch query drift and added latency.”

### Revision summary

| Technique | Purpose | Important caveat |
|---|---|---|
| Rewrite/expand | Match corpus vocabulary. | Can drift or add noisy terms. |
| HyDE | Bridge query/document embedding mismatch. | Hypothetical text is not evidence. |
| Decompose | Retrieve separate facts for multi-hop queries. | Must preserve links and provenance. |
| Step-back | Find general principles/background. | Combine with specific evidence for the actual question. |

<br><br><br>

## How do you implement citation and source attribution in RAG?

**Answer:**

### Preserve provenance from ingestion onward

Reliable citations cannot be added only at the final generation step. Each indexed chunk should carry stable source metadata such as document ID, version, title, section/page, URL or record key, chunk offsets, and access scope. Parsing and chunking should preserve enough location information to reconstruct and display the source passage.

### Ground answer claims in retrieved sources

1. Return retrieved passages to the generator with stable source IDs, not just untracked text.
2. Require citations to reference only IDs provided in the current request.
3. Prefer a structured claim-and-citation output or inline source markers.
4. Validate that cited IDs exist and that the cited passage supports the associated claim.
5. Render citations as links/snippets with page or section details where available.
6. If evidence is insufficient or conflicting, state uncertainty, show the disagreement, ask for clarification, or abstain.

Citation presence alone does not establish support. A model may attach a real but irrelevant source. For high-assurance use, perform claim-level verification with deterministic checks, a separate entailment model, or human review. Keep user-specific access checks in the retrieval and citation-serving layers so a citation cannot disclose an unauthorized source.

### Evaluation and operations

Measure citation precision (whether cited sources support claims), citation completeness/recall (whether material claims have citations), source-link validity, and end-to-end factuality. Version source documents and store enough provenance to reproduce which passage supported a response. Protect logs and avoid retaining more sensitive source text than necessary.

### Concise interview answer

“I implement citations by preserving document IDs, versions, page/section and chunk offsets during ingestion, then passing stable source IDs with retrieved passages to the model. The output must cite only supplied IDs, and the application validates IDs and permissions before rendering source links. For important claims I verify that the cited passage actually supports them; citation syntax alone is not evidence. I measure citation precision and completeness and preserve enough versioned provenance to reproduce the answer.”

### Revision summary

| Requirement | Implementation |
|---|---|
| Stable source | Document ID, version, location, offsets. |
| Grounded generation | Pass source IDs alongside evidence. |
| Validation | Check citation ID and claim support. |
| Access control | Reauthorize source before displaying citation. |
| Evaluation | Precision, completeness, validity, and reproducibility. |

<br><br><br>

## How do you scale a RAG system to millions of documents?

**Answer:**

### Scale each pipeline stage

At millions of documents, treat RAG as a distributed data and serving system, not just a vector database. Separate ingestion, indexing, retrieval, reranking, generation, and observability so each can scale and fail independently.

**Ingestion and indexing**

- Use streaming or distributed batch processing with backpressure and bounded retries.
- Partition by tenant, domain, language, source, or time where it helps routing and governance.
- Use stable IDs, content hashes, idempotent upserts, and deletion tombstones.
- Batch parsing and embedding; track pipeline versions and failed records.
- Choose an index strategy based on recall, latency, memory, update rate, and hardware; benchmark ANN parameters and sharding.
- Keep source metadata and ACLs queryable, and ensure index partitions do not bypass authorization.

**Query serving**

- Apply authorization and high-selectivity metadata filters early.
- Route to relevant shards or indexes rather than searching everything when safe.
- Use hybrid retrieval, bounded candidate sets, and reranking only where it improves quality.
- Cache embeddings or results with tenant, permission, and index-version-aware keys.
- Set timeouts, quotas, circuit breakers, and backpressure; degrade safely if one retriever is unavailable.

### Reliability, freshness, and measurement

Use replicas, health checks, reindex/rollback procedures, and source-to-index reconciliation. Monitor p50/p95/p99 latency, recall/answer quality, index size, ingestion lag, update/delete propagation, shard skew, cost, and access-control errors. Load-test realistic query mixes and update rates; millions of documents alone do not determine the right index design.

### Concise interview answer

“I scale RAG by independently scaling and observing ingestion, indexing, retrieval, reranking, and generation. Ingestion uses distributed batching, stable IDs, idempotent updates, and deletion tracking. Serving uses partitioning/sharding, ANN tuning, early ACL-aware metadata filters, bounded candidates, selective reranking, and safe caching. I load-test realistic traffic and monitor p95 latency, retrieval and answer quality, ingestion lag, index health, cost, and permission correctness. The index design follows workload and freshness requirements rather than document count alone.”

### Revision summary

| Scale concern | Approach |
|---|---|
| Ingestion throughput | Distributed jobs, batching, backpressure, retries. |
| Index size/latency | Partitioning, sharding, ANN tuning, replicas. |
| Updates/deletes | Idempotent IDs, hashes, tombstones, reconciliation. |
| Query cost | Early filters, bounded retrieval, selective reranking, safe caches. |
| Reliability | Load tests, monitoring, rollback, ACL and freshness checks. |

<br><br><br>

## What is parent-child chunking, and how does it improve retrieval?

**Answer:**

### Core idea

**Parent-child chunking** indexes small **child chunks** for precise retrieval while retaining a larger **parent section or document** that supplies broader context. The retriever matches the query against child chunks; after a child is selected, the system can return the parent, a parent window, or adjacent chunks to the generator.

For example, a child may contain one paragraph from a policy section, while its parent contains the full section with the heading, definitions, and exceptions.

### Why use it?

Small chunks can match specific queries well but may omit definitions or qualifications. Large chunks preserve context but can dilute embedding similarity and consume too much prompt space. Parent-child retrieval separates these goals: retrieve precisely, then expand context selectively.

### Implementation considerations

- Assign stable parent and child IDs and retain source offsets, section titles, and versions.
- Retrieve top child chunks, then deduplicate by parent and expand only the relevant parent window.
- Bound expansion by token budget; returning every parent can undo retrieval precision.
- Preserve citations to the exact child passage, even if the answer context includes a larger parent.
- Apply ACLs to both child and parent; never expand into unauthorized neighboring content.
- Evaluate child-level recall and final answer faithfulness, plus context tokens, latency, and duplicate rate.

Parent-child chunking does not itself solve poor parsing, retrieval misses, or contradictory documents. It is a context-selection strategy whose value depends on document structure and query patterns.

### Concise interview answer

“Parent-child chunking indexes smaller child passages for precise matching and links each one to a larger parent section. Retrieval happens at the child level, then the system selectively expands to the parent or neighboring context for generation. This balances precise retrieval with enough context to interpret definitions and exceptions. I bound expansion, deduplicate parents, preserve exact child provenance for citations, enforce ACLs on both levels, and compare answer quality and token cost against single-level chunking.”

### Revision summary

| Level | Role |
|---|---|
| Child | Fine-grained embedding/retrieval unit. |
| Parent | Broader context returned after a child match. |
| Benefit | Precision during search, context during generation. |
| Risk | Expansion can reintroduce noise, duplicates, or unauthorized text. |
| Evaluation | Retrieval recall, faithfulness, citations, token and latency cost. |

<br><br><br>

## Your RAG system is hallucinating despite having the right context. How do you fix it?

**Answer:**

### Diagnose evidence use, not just evidence presence

First verify that the “right context” actually reaches the model intact: inspect the exact rendered request, source versions, chunk boundaries, ordering, token-budget truncation, and whether the passage entails the answer. A relevant document can still be insufficient, contradictory, stale, or ambiguous.

### Fix the responsible layer

1. **Check claim-level support:** Break the response into factual claims and map each to specific retrieved passages. Identify unsupported inference versus source conflict.
2. **Improve context assembly:** Remove irrelevant or duplicate chunks, preserve definitions and qualifiers, and use citations or claim-evidence structure.
3. **Clarify generation behavior:** Instruct the model to answer only from supplied evidence, distinguish direct support from inference, and abstain when evidence is insufficient. Treat this as guidance, not a guarantee.
4. **Add validation:** Check citations against supplied source IDs and, for important answers, verify entailment with rules, a calibrated verifier, or human review.
5. **Use deterministic tools:** For arithmetic, comparisons, dates, and structured facts, compute or query authoritative sources rather than asking the model to infer.
6. **Test and measure:** Add the failure to a groundedness evaluation set; compare prompt, model, and decoding changes on held-out cases.

If the source documents themselves conflict or contain errors, improve source governance and surface uncertainty instead of forcing the model to choose silently. Lower temperature can reduce some variability but cannot guarantee factuality.

### Concise interview answer

“I verify the exact context sent to the model, including truncation, source version, chunk qualifiers, and whether it truly entails the answer. Then I map each answer claim to evidence and distinguish unsupported inference from contradictory or stale sources. I improve context assembly, require citations or abstention, validate claim-source support, and use deterministic tools for calculations. A prompt cannot guarantee faithfulness, so I test groundedness on held-out cases and route high-impact answers to stronger verification.”

### Revision summary

| Possible cause | Fix |
|---|---|
| Evidence truncated or incomplete | Inspect rendered prompt, token budget, and chunk boundaries. |
| Evidence does not entail claim | Require support, clarify uncertainty, abstain. |
| Contradictory/stale sources | Resolve through provenance and source governance. |
| Model makes unsupported inference | Claim-level citation validation and external checks. |
| Numeric/structured task | Use deterministic computation or authoritative query. |

<br><br><br>

## Your RAG chunk overlap causes redundant results. How do you reduce redundancy?

**Answer:**

### Find where duplication enters

Overlap is often used to avoid losing meaning at chunk boundaries, but too much overlap can cause adjacent chunks to repeat the same text and crowd out distinct evidence. Inspect retrieved results for adjacent chunk IDs, shared parent IDs, near-identical content, and repeated source passages. Also check whether ingestion has indexed the same document multiple times.

### Reduce redundancy without losing boundary context

- **Tune overlap empirically:** Reduce overlap or remove it where structure-aware boundaries already preserve context.
- **Deduplicate before context assembly:** Collapse identical chunks by canonical ID/content hash and suppress adjacent chunks with high overlap.
- **Use parent-child retrieval:** Search smaller children, then expand to one bounded parent or local window instead of returning many overlapping children.
- **Apply diversity-aware selection:** Use maximal marginal relevance (MMR) or per-document quotas so selected passages cover distinct evidence.
- **Retain the best representative:** For adjacent chunks, select the most relevant one and include a small neighboring window only when needed.
- **Fix ingestion duplication:** Use stable source/chunk IDs, content hashes, and idempotent upserts.

Tune these controls on boundary-dependent queries. Excessive deduplication can remove complementary details or exceptions, so measure context recall and answer quality as well as duplicate rate and token use.

### Concise interview answer

“I inspect whether redundancy comes from chunk overlap, duplicate ingestion, or retrieval ranking. I reduce overlap based on boundary tests, deduplicate by stable IDs or content similarity, and use parent-child expansion or diversity-aware selection to return distinct evidence. I preserve a neighboring chunk when it contains a needed definition or exception. The objective is not zero overlap at any cost: I measure duplicate rate, context recall, answer faithfulness, and prompt tokens together.”

### Revision summary

| Source of redundancy | Remedy |
|---|---|
| Excessive overlap | Tune overlap; use structure-aware chunking. |
| Adjacent retrieved chunks | Collapse neighbors or expand a single parent window. |
| Duplicate documents | Stable IDs, hashes, idempotent ingestion. |
| Similar but distinct evidence | Diversity-aware ranking; avoid over-aggressive deduplication. |
| Validation | Boundary questions, recall, quality, duplicate rate, token budget. |

<br><br><br>

## Your RAG retrieval is too slow with a large knowledge base. How do you speed it up?

**Answer:**

### Profile the retrieval path

Measure query transformation, authorization/filtering, query embedding, lexical search, vector ANN search, candidate merging, reranking, and network/queue time separately. Track p50/p95/p99 latency, throughput, recall, and resource utilization. A large corpus alone does not reveal whether the bottleneck is embedding, index search, filters, reranking, or an overloaded service.

### Optimize the bottleneck

- **Vector search:** Tune ANN algorithm and search parameters against recall-latency targets; validate the distance metric and vector normalization.
- **Partitioning/sharding:** Route to relevant partitions using trusted metadata such as tenant, language, or source, while avoiding excessive fragmentation and skew.
- **Filters:** Index frequently used filter fields and apply authorization-aware filtering efficiently.
- **Hybrid retrieval:** Run lexical and vector searches in parallel when independent, then merge bounded candidate sets.
- **Reranking:** Keep a high-recall but bounded candidate pool, batch pair scoring, and rerank selectively.
- **Embedding:** Use efficient serving, batching, and cache query embeddings when queries repeat and cache keys respect privacy.
- **Index lifecycle:** Remove stale/deleted vectors, compact segments, balance shards, and prevent indexing load from starving query serving.
- **Service design:** Add replicas, backpressure, timeouts, connection pooling, and autoscaling based on queue and latency metrics.

Do not optimize latency by reducing candidates or filters without checking recall and permission correctness. Benchmark with realistic filters, update rates, and concurrent traffic.

### Concise interview answer

“I profile each retrieval stage and p95/p99 before tuning. Then I optimize the actual bottleneck: ANN parameters and index health, metadata-aware partitioning, indexed ACL filters, parallel lexical/vector search, bounded and batched reranking, embedding batching/caching, and service capacity. I load-test production-like filters and concurrency, and measure recall alongside latency. A faster search that misses evidence or bypasses authorization is not an optimization.”

### Revision summary

| Bottleneck | Options |
|---|---|
| Query embedding | Batch, efficient serving, privacy-aware cache. |
| ANN/lexical search | Tune index/search parameters, parallelize, bound candidates. |
| Filters/shards | Index common fields, route carefully, monitor skew. |
| Reranking | Batch and restrict to selected candidates. |
| Verification | Recall, p95/p99 latency, throughput, ACL correctness. |

<br><br><br>

## Your RAG system returns duplicate results. How do you deduplicate?

**Answer:**

### Deduplicate at multiple levels

“Duplicate results” can mean exact duplicate chunks, overlapping chunks from one document, repeated copies of a source, or semantically similar passages from different sources. Use the level that matches the problem:

1. **Canonicalize sources:** Assign stable document IDs and versions; normalize URLs or source keys where appropriate.
2. **Exact deduplication:** Hash normalized content and remove duplicate records during ingestion or candidate merging.
3. **Chunk-level deduplication:** Use stable chunk IDs and parent IDs; collapse identical or near-identical adjacent chunks.
4. **Result-level diversity:** Apply per-document limits, maximal marginal relevance, or another diversity-aware selection method after relevance ranking.
5. **Preserve provenance:** Keep alternate source references when duplicates have distinct authority or dates; do not erase lineage just because text matches.

For versioned documents, do not collapse genuinely different revisions without an explicit freshness policy. A newer passage may supersede an older one, while a historical question may require both.

### Evaluation

Measure duplicate rate and distinct-evidence coverage, but also check recall, answer quality, citation correctness, and context-token reduction. Test repeated ingestion, overlapping chunks, mirrors, and multiple versions.

### Concise interview answer

“I identify whether duplicates are caused by repeated ingestion, identical chunks, overlapping neighbors, or similar but independently authoritative sources. I use canonical document IDs and versions, content hashes for exact duplicates, parent IDs for chunk grouping, and diversity-aware selection for near-duplicates. I preserve provenance and apply a clear version policy rather than dropping every similar passage. I validate with duplicate rate and distinct-evidence coverage while checking recall and answer quality.”

### Revision summary

| Duplicate type | Technique |
|---|---|
| Re-ingested file | Idempotent IDs, hashes, upserts. |
| Identical chunk | Canonical chunk ID/content hash. |
| Overlapping neighbors | Collapse by parent or select a bounded window. |
| Similar passages | Diversity-aware ranking; preserve distinct sources. |
| Multiple versions | Apply explicit freshness/history policy. |

<br><br><br>

## Your RAG system needs per-user access control on internal documents. How do you implement it?

**Answer:**

### Enforce authorization before content is exposed

Treat retrieval as a data-access operation. Authenticate the user, resolve current groups/roles and tenant scope from a trusted identity system, and apply those permissions within the trusted retrieval service before candidate text is returned to the model. A prompt instruction such as “only use documents this user can access” is not an access-control mechanism.

### Implementation pattern

1. **Ingest trusted ACL metadata:** Associate each document/chunk with authoritative tenant, owner, group, classification, or policy identifiers.
2. **Authorize each request:** Resolve the caller’s current identity and permissions; do not trust user-supplied filter values.
3. **Filter before retrieval output:** Apply ACL constraints in the search layer or a trusted pre-retrieval partitioning service, including both vector and lexical paths.
4. **Revalidate before actions/citations:** Check permissions again when fetching full parent documents, rendering citations, or invoking downstream tools.
5. **Handle changes and revocations:** Propagate ACL updates and deletions promptly; define fail-closed behavior if identity or policy services are unavailable.
6. **Prevent side-channel leakage:** Avoid returning unauthorized titles, snippets, counts, scores, or timing differences; protect logs and caches.
7. **Test isolation:** Verify users, groups, tenants, revocations, inherited permissions, and direct-object access with adversarial tests.

Cache keys must include the effective authorization scope and index/policy version, or caches must be partitioned by a safe boundary. Use least privilege for service identities and audit access decisions without logging unnecessary document content.

### Concise interview answer

“I enforce document ACLs in the trusted retrieval/data layer, not in the prompt. ACL metadata comes from authoritative sources; each request authenticates the user, resolves current groups and tenant, and filters both lexical and vector retrieval before any content reaches the model. I recheck permissions for parent expansion and citations, propagate revocations quickly, fail closed when policy is unavailable, and make caches permission-aware. I test cross-tenant isolation and side channels such as titles, snippets, logs, and result counts.”

### Revision summary

| Layer | Control |
|---|---|
| Identity | Authenticate and resolve current roles/groups from trusted service. |
| Index | Store authoritative ACL/tenant metadata. |
| Retrieval | Apply permissions before returning any content. |
| Follow-on access | Reauthorize parent expansion, citations, and tools. |
| Operations | Revocation handling, safe cache keys, audit, isolation tests. |

<br><br><br>

## Your RAG system fails on domain-specific jargon. How do you fix it?

**Answer:**

### Diagnose the retrieval mismatch

First determine whether the jargon is missing from the source/index, parsed incorrectly, split away from its definition, or present but not retrieved. Inspect failed queries, source passages, tokenization, query embeddings, lexical results, metadata filters, and reranker output. Domain terminology may include acronyms, product codes, abbreviations, spelling variants, formulas, and overloaded terms; an embedding model trained on general text may represent these poorly.

### Improve coverage and matching

1. **Build a domain evaluation set:** Collect real queries and relevant passages with experts. Include acronyms, aliases, misspellings, identifiers, and ambiguous terms.
2. **Normalize carefully:** Expand known abbreviations, standardize units and spelling variants, and preserve the original query. Do not normalize away meaningful distinctions.
3. **Add lexical retrieval:** BM25 or exact identifier search often complements embeddings for rare terms, codes, and acronyms.
4. **Use a controlled terminology layer:** Maintain a versioned synonym/alias dictionary or entity catalog, ideally sourced from domain experts and authoritative records.
5. **Improve context and chunking:** Keep jargon near its definition, heading, product name, or surrounding explanation; index metadata and glossary entries.
6. **Evaluate specialized embeddings:** Compare domain-adapted or multilingual embeddings on the labeled set. Fine-tune embeddings only with representative query-positive/negative pairs and appropriate validation.
7. **Rerank candidates:** A domain-aware reranker may improve precision after high-recall lexical/vector retrieval.

Query expansion can add domain synonyms, but generated expansions can drift or introduce false equivalences. Keep the original query, bound expansions, and check recall and answer quality. If jargon is absent from the source corpus, no embedding model can retrieve its authoritative definition; add trusted source material or route to a domain expert.

### Concise interview answer

“I first locate the failure stage: source coverage, parsing/chunking, candidate recall, or ranking. I build an expert-labeled jargon benchmark covering acronyms, aliases, identifiers, and ambiguous terms. Then I combine semantic retrieval with lexical/exact matching, add a governed synonym or terminology layer, preserve definitions with their context, and evaluate domain-specific embeddings or reranking if needed. I validate each change on held-out queries because expansion can introduce false synonyms. If the knowledge is absent, I fix the corpus rather than expecting embeddings to invent it.”

### Revision summary

| Failure source | Candidate fix |
|---|---|
| Terms absent from corpus | Add authoritative glossary/source coverage. |
| Acronym/alias mismatch | Governed synonym expansion and entity normalization. |
| Rare exact terms | Hybrid vector + lexical/identifier retrieval. |
| Context split away | Structure-aware chunking and contextual metadata. |
| Weak domain semantics | Evaluate domain embeddings/rerankers on expert labels. |

<br><br><br>

## Your text-only RAG system now needs to handle images and tables. How do you extend it?

**Answer:**

### Extend ingestion to preserve modality and structure

Do not treat every image or table as an unstructured text blob. Add modality-aware parsing while preserving the original asset, source document, page/region, caption, layout, and access metadata.

**Images**

- Extract image regions and nearby captions/paragraphs from source documents.
- Depending on the task, index image embeddings, use a vision-language model to create searchable descriptions, or store both image and text representations.
- Keep a reference to the original image and its page/coordinates so the system can show evidence or re-open it for visual inspection.
- Avoid treating generated captions as ground truth; retain the image as the authoritative evidence and validate important visual claims.

**Tables**

- Detect table boundaries and preserve headers, row/column associations, units, footnotes, merged cells, and page location.
- Store a structured representation (for example, typed rows/columns or a table object) alongside a readable text rendering for retrieval.
- Retrieve relevant rows or regions rather than flattening a large table into an ambiguous paragraph.
- Use SQL or deterministic code for exact filtering, arithmetic, and aggregation when the table can be represented structurally.

### Multimodal retrieval and answer flow

At query time, classify whether the question needs text, visual evidence, structured table access, or a combination. Search the relevant indexes with shared document/ACL filters, merge and rerank candidates, then provide the model with the appropriate text, image, or table representation and source references. For a question comparing a chart with a table, retrieve both and preserve their provenance separately.

### Evaluation and operations

Create modality-specific benchmarks: visual entity/region retrieval and caption faithfulness for images; cell/row retrieval, header association, and numerical accuracy for tables. Test scanned pages, low-resolution images, charts, unusual layouts, and cross-modal questions. Track OCR/vision errors, index size, model compatibility, latency, and cost. Use fallbacks or abstention when the asset cannot be parsed reliably.

### Concise interview answer

“I extend ingestion with modality-aware parsing and keep original assets plus page/region provenance. For images, I use image embeddings or vision-language descriptions alongside the source image, treating generated captions as fallible. For tables, I preserve headers, units, footnotes, and row/column structure, and query structured data with code or SQL for exact computations. At query time I retrieve the needed modality, enforce the same ACLs, and cite the source region. I evaluate image and table retrieval separately, including OCR/vision errors and numeric accuracy.”

### Revision summary

| Content | Representation | Validation |
|---|---|---|
| Images | Original asset + region metadata + optional visual/text embeddings. | Region retrieval and caption/claim faithfulness. |
| Tables | Structured rows/columns plus readable rendering and source location. | Header association, cell accuracy, deterministic calculations. |
| Mixed queries | Retrieve and merge modality-specific evidence. | Cross-modal provenance and answer support. |
| Governance | Same source IDs, ACLs, versions, deletion, and freshness. | Test authorization across every modality. |

<br><br><br>

## Your RAG knowledge base gets updated frequently and needs versioning. How do you manage it?

**Answer:**

### Version the full transformation pipeline

An index is the output of more than source documents: parsing, normalization, chunking, metadata extraction, embedding model, vector settings, and index schema all affect retrieval. Record versions for each input and transformation so a result can be reproduced and a migration can be rolled back.

For each document, maintain a stable source ID, source revision or content hash, timestamps, ACL version, and deletion state. For each indexed chunk, retain its parent/document ID, chunking version, embedding model/version, and source offsets.

### Safe update and release workflow

1. Detect creates, updates, permission changes, and deletes through events or reconciliation.
2. Process changes idempotently; reprocess only affected documents when possible.
3. Keep the currently serving index immutable or logically versioned while building a candidate version.
4. Validate ingestion counts, parsing samples, retrieval benchmarks, ACL behavior, and freshness before publication.
5. Use an alias/traffic switch or blue-green deployment to move serving to the new index; retain the previous version for rollback.
6. Invalidate caches using corpus/index versions and relevant permission scope.
7. Re-embed consistently when model or preprocessing changes; do not compare or mix incompatible embedding spaces.

For high update rates, use a small mutable delta index plus periodic compaction/rebuild into a stable base index, if the retrieval platform supports it. Track source-to-index lag, failed events, orphaned chunks, duplicates, and deletion propagation. Define retention and audit policies for old versions, especially where deletion or privacy requirements apply.

### Concise interview answer

“I version both source content and the full indexing pipeline: parser, chunker, metadata schema, embedding model, and index configuration. Updates and deletes are processed idempotently using stable IDs and hashes. I build or update a candidate index, run retrieval, count, freshness, and ACL checks, then switch traffic through a controlled alias or blue-green release while retaining rollback. Cache keys include index and permission versions, and model changes trigger a consistent re-embedding rather than mixing vector spaces.”

### Revision summary

| Versioned item | Why |
|---|---|
| Source revision/hash and ACL | Reproduce content and permissions at query time. |
| Parser/chunker/metadata schema | Changes affect what is searchable and where evidence maps. |
| Embedding model/config | Vectors must remain in a consistent space. |
| Index/corpus snapshot | Supports evaluation, rollback, and incident analysis. |
| Release process | Validate, switch safely, monitor lag, preserve rollback. |

<br><br><br>

## Your RAG system fails on multi-hop questions that require combining multiple facts. How do you fix it?

**Answer:**

### Identify the missing hop

Multi-hop questions require several linked facts, often from different documents. The query may not directly contain the vocabulary needed for the intermediate retrieval. Inspect whether the failure is decomposition, entity resolution, retrieval recall at a particular hop, evidence integration, or unsupported inference.

### Use an evidence-tracked retrieval loop

1. **Decompose into subquestions:** Represent each required fact or relation explicitly, while preserving the original user question.
2. **Retrieve the first evidence set:** Use hybrid search, metadata filters, or structured sources; preserve IDs and exact passages.
3. **Derive the next query from evidence:** Use verified entities/relations from the first hop to formulate follow-up searches; do not let an unsupported model guess become a trusted premise.
4. **Repeat within limits:** Bound the number of hops, calls, documents, tokens, and wall-clock time; detect loops.
5. **Build an evidence graph/table:** Record each subclaim, supporting source, and dependency between facts.
6. **Synthesize and verify:** Answer only when all required links are supported; otherwise state what is missing, ask a clarifying question, or abstain.

For explicit stable relationships, a knowledge graph or SQL/API query may be more reliable than repeated semantic search. For broad corpora, graph and vector/lexical retrieval can complement each other.

### Evaluate and control error propagation

Measure recall for each subquestion/hop, entity-linking accuracy, final answer correctness, citation support, and unnecessary retrieval calls. Include counterfactual and conflicting-source cases. Enforce ACLs on every hop; one authorized first result must not grant access to linked but unauthorized records.

### Concise interview answer

“I treat multi-hop failure as a chain of retrieval and reasoning steps. I decompose the question, retrieve evidence for each subquestion, use verified entities from one hop to guide the next, and track dependencies in an evidence map. A graph or structured query may be better for explicit relationships. I cap hops and calls, enforce permissions at every retrieval, and require support for each link before synthesis. Evaluation covers hop-level recall, entity resolution, final correctness, and citations.”

### Revision summary

| Stage | Safeguard |
|---|---|
| Decomposition | Enumerate required facts and relationships. |
| Follow-up query | Base next hop on retrieved, verified evidence. |
| Evidence tracking | Link each claim to source passages and dependencies. |
| Failure behavior | Clarify or abstain if a necessary hop is missing. |
| Safety/evaluation | Bound calls; enforce ACL per hop; test hop-level recall. |

<br><br><br>

## Your enterprise RAG system returns contradictory answers from different source documents. How do you resolve conflicts?

**Answer:**

### Do not let the model silently choose

Contradictions may reflect different effective dates, jurisdictions, product versions, definitions, source authority, or a genuinely unresolved disagreement. First establish whether the passages refer to the same entity, scope, and time period. Two statements that appear contradictory may both be valid under different conditions.

### Conflict-resolution workflow

1. **Preserve provenance:** Retrieve source owner, document type, version, effective/expiry date, jurisdiction, status, and update timestamp.
2. **Apply deterministic policy where defined:** Use an approved authority hierarchy or precedence rule (for example, current signed policy over an archived draft), not a model-inferred ranking.
3. **Filter by scope and time:** Use user context and query date to select applicable documents, while preserving historical sources when asked about the past.
4. **Verify the conflict:** Compare exact claims and qualifiers; ensure the passages address the same entity and condition.
5. **Answer transparently:** If one source is authoritative, cite it and optionally note superseded material. If no precedence exists, present the disagreement with citations and abstain from asserting a single answer.
6. **Fix upstream governance:** Mark superseded documents, improve metadata, resolve source-of-truth ownership, and prevent stale drafts from being indexed as current policy.

Do not use recency alone as a universal rule: an older statute, contract, or policy may remain authoritative, while a newer draft may not be approved. Authorization applies to every source considered and shown.

### Concise interview answer

“I first determine whether the documents differ by date, scope, jurisdiction, version, or authority. I preserve provenance and apply an explicit, business-approved precedence policy rather than letting the LLM guess. I filter to the relevant effective version, verify that the claims truly conflict, and either cite the authoritative source or disclose the disagreement and abstain when no rule resolves it. Then I fix metadata and source governance so superseded drafts do not look current.”

### Revision summary

| Conflict cause | Resolution |
|---|---|
| Different time/version | Filter by effective date; mark superseded records. |
| Different scope/jurisdiction | Apply scope metadata and query context. |
| Different authority | Use an approved source hierarchy. |
| True unresolved disagreement | Present both with citations; qualify or abstain. |
| Systemic stale content | Fix ownership, metadata, update/deletion workflow. |

<br><br><br>

## Your RAG system returns outdated answers from an evolving knowledge base. How do you keep it current?

**Answer:**

### Trace the stale result to its source

“Outdated” may mean the source itself is obsolete, ingestion has not processed an update, old chunks were not deleted, retrieval selected an archived version, or a cache returned a previous answer. Capture the document IDs, versions, effective dates, index build, retrieval scores, cache key, and source-to-index timestamps for a failing query before changing the model prompt.

### Build a freshness and versioning path

1. **Define freshness by source:** Set an update SLA appropriate to each source; policies, prices, and operational status may need shorter lag than archived reference material.
2. **Detect every mutation:** Consume create/update/delete and ACL-change events where available, supplemented by periodic reconciliation against the source of truth.
3. **Process updates idempotently:** Use stable document IDs and hashes, re-parse and re-index changed documents, remove obsolete chunks, and propagate deletions.
4. **Represent time explicitly:** Store source version, publication/effective/expiry dates, ingestion time, and status such as draft/current/superseded. Filter by relevant effective time, not merely ingestion timestamp.
5. **Prevent stale reads:** Invalidate or version caches; include corpus/index version and authorization scope in keys. Do not mix incompatible embedding versions.
6. **Release safely:** Validate update counts, retrieval samples, ACLs, and freshness before publishing a candidate index; keep rollback and reconciliation procedures.
7. **Monitor the SLA:** Alert on ingestion lag, failed events, orphaned chunks, stale versions returned, delete propagation, and source/index count divergence.

Recency alone is not an authority rule. A newly uploaded draft may be less authoritative than an older approved policy, so preserve status and precedence metadata. For rapidly changing transactional facts, query the authoritative API/database at request time instead of relying on a periodically refreshed vector index.

### Concise interview answer

“I first trace the returned passage through source version, ingestion event, index version, retrieval, and cache to find where it became stale. I define per-source freshness SLAs, process updates and deletions idempotently, retain effective dates and approval status, and reconcile the index against the source of truth. I invalidate version-aware caches, validate a candidate index before release, and alert on source-to-index lag and stale retrievals. For highly volatile values, I query the authoritative service directly rather than pretending batch RAG is real time.”

### Revision summary

| Staleness point | Control |
|---|---|
| Source content/status | Authority, approval, effective and expiry dates. |
| Ingestion/index | Event processing, idempotent upsert, deletion propagation. |
| Retrieval | Filter by applicable version/status and verify provenance. |
| Cache | Include index/corpus and permission versions; invalidate changes. |
| Operations | Freshness SLA, lag alerts, reconciliation, rollback. |

<br><br><br>

## Your RAG system struggles with PDF documents containing tables and layouts. How do you fix PDF parsing?

**Answer:**

### Why naïve text extraction fails

PDFs often store text as positioned glyphs rather than a clean reading-order stream. A basic extractor can interleave columns, detach headers from values, flatten tables, omit footnotes, mishandle page breaks, or return no text for scanned pages. Therefore, “text extracted” is not equivalent to “document understood.”

### Use a layout-aware, testable extraction pipeline

1. **Classify the PDF:** Detect digitally born versus scanned pages, page rotation, columns, tables, figures, and mixed layouts.
2. **Extract with layout information:** Use a parser that returns blocks, lines, coordinates, page numbers, and table regions, not only a flat string.
3. **OCR scanned pages:** Apply OCR or document-vision extraction when text is absent or image-based; retain confidence and coordinates to identify low-quality regions.
4. **Reconstruct reading order:** Handle columns, headers/footers, lists, and page breaks using layout coordinates and document structure.
5. **Preserve tables structurally:** Keep headers, row/column associations, units, merged cells, captions, and footnotes. Store both structured cells and a readable rendering when useful.
6. **Chunk by document structure:** Keep headings with their sections and table captions/headers with relevant rows; maintain page and bounding-box provenance.
7. **Validate and route failures:** Compare extracted output with rendered pages on a gold set. Send low-confidence or malformed pages to a stronger parser or human review rather than silently indexing bad text.

Keep the original PDF and extraction/version metadata. When answering, retrieve the specific page/region and cite it. Numeric or table-derived calculations should be checked programmatically where possible.

### Evaluation and operations

Build a representative corpus of scanned/digital PDFs, multi-column pages, nested or merged tables, rotated pages, footnotes, and charts. Measure text coverage, reading-order accuracy, table-cell/header association, OCR accuracy, retrieval recall, citation location accuracy, and downstream answer correctness. Also track processing cost and latency; a sophisticated vision parser may be reserved for difficult pages.

### Concise interview answer

“I diagnose whether the PDF is scanned or digital and inspect layout-aware extraction, because flat text extraction often destroys columns, reading order, and table relationships. I use OCR or document vision for scanned pages, preserve page coordinates and source versions, reconstruct headings and columns, and store tables with headers, units, footnotes, and cell relationships. I validate against rendered pages and route low-confidence extraction for review. Retrieval citations point to exact pages/regions, and calculations over table data are checked deterministically.”

### Revision summary

| PDF challenge | Treatment |
|---|---|
| Scanned/image pages | OCR or document-vision extraction with confidence. |
| Columns/reading order | Layout blocks, coordinates, and structure-aware reconstruction. |
| Tables | Preserve headers, cells, units, footnotes, and coordinates. |
| Citations | Retain page, region, bounding box, and source version. |
| Quality control | Gold pages, extraction metrics, low-confidence fallback. |

<br><br><br>
