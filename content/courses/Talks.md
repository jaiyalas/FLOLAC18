---
title: 特別演講 (Talks)
---

## [07/13] Racket：語言導向程式設計

#### 多程式語言環境、領域專門語言以及程式語言系統

+ **講者**: 游書泓 *美國西北大學, Northwestern University, USA*
+ **講者簡介**: I am a second year PhD student working with Robby Findler at Northwestern University.
My research mainly focus on automated program testing for functional languages and programming language design.

**大綱**: 在開發軟體時，我們往往會至少使用一種一般程式語言並配合數種不同的領域專門語言，包含專案設定語言、說明文件語言等等。同樣的，Racket 也不是單一一種程式語言，而是許多程式語言並存的環境。在這次分享中，我們將看到 Racket 在從完全相異的程式語言到不同的嵌入式領域專門語言上支援「多程式語言環境」，不同的程式語言之間互動有什麼狀況，以及如何提供與整個程式環境相關的 API。

## [07/19] A Session Type Provider

#### Compile-time Generation of Session Types with Interaction Refinements

+ **Speakers**: [Nobuko Yoshida](http://mrg.doc.ic.ac.uk/) and [Rumyana Neykova](http://mrg.doc.ic.ac.uk/)

**Abstract**: We first give an overview of recent research developments of our mobility group at Imperial College London.

Session types is a typing discipline for concurrent and distributed processes that allows errors such as communication mismatches and deadlocks to be detected statically.    Refinement types are types elaborated by logical constraints that allow richer and finer-grained specification of application properties, combining types with logical formulae that may refer to program values and can constrain types using arbitrary predicates. Type providers, developed in F#,  are compile-time components for on-demand code generation. Their architecture relies on an open-compiler, where provider-authors implement a small interface that allows them to inject new names/types into the programming context as the program is written.

In this talk, we will present a library that integrates aspects from the above fields to realise practical applications of multiparty refinement session types (MPST) for any .Net language. Our library supports the specification and validation of distributed message passing protocols based on a formulation of asynchronous MPST enriched with interaction refinements: a collection of features related to the refinement of protocols, such as message-type refinements (value constraints) and value dependent control flow. The combination of these aspects—session types for structured interactions, constraint solving from refinement types, and protocol-specific code generation—enables the specification and implementation of enriched protocols in native F# (and any .Net-compiled language) without requiring language extensions or external pre-processing of user programs. A well-typed endpoint program using our library is guaranteed to perform only compliant session I/O actions w.r.t. to the refined protocol, up to premature termination. The safety guarantees are achieved by a combination of static type checking of the generated types for messages and I/O operations, correctness by construction from code generation, and automated inlining of assertions.
