---
title: "Announcing MIVM: A Module Compiler Infrastructure for Interaction Programming Languages"
date: 2025-01-12T12:17:53-05:00
draft: true
---

## MIVM Seeks to Unite Developments in Interaction Programming

Interaction programming (IP) is a turing-complete system of computing based on symbolic graph rewriting rules ("interaction") between agents through ports. IP resembles cellular automata and other graph rewriting systems, but poses unique advantages, as outlined in Yves Lafont's original paper, "[Interaction Nets](https://dl.acm.org/doi/pdf/10.1145/96709.96718)," which describes the system. IP languages are universal, and definitionally local in computation, requiring no global synchronization for parallelism. The model has been extensively explored for applications requiring or suitable to parallel computation, but has seen scant practical use. Many developments and iterations on the model have emerged in academic circles since the paper's publication, each posing unique benefits and drawbacks. Over the last two months, I have been developing MIVM, the Modular Interaction Virtual Machine, which aims to unite these developments, providing a modular language infrastructure for implementation and comparative analysis of IP languages.

## MIVM Infrastructure Overview

MIVM, implemented in Rust, arose from iterative, rapidly prototyped design and implementation of an interaction programming runtime. The toolchain aims to be as modular as possible, providing self-contained interfaces and implementations of components in each layer of the pipeline from parsing to evaluation of IP programs. This modular design will hopefully enable sharing and comparison of new ideas and designs in IP between academics and developers alike.

To enable extensible IP language development, MIVM introduces a multi-layer intermediate representation, which encodes the reduction of an interaction net. This intermediate representation is generic, and compatible with any ahead-of-time (AOT) compiled or bytecode interpreted implementation of an IP language. As a demonstration of its modular capabilities, MIVM implements three reference frontends for interaction programming: one based on LaFont's original syntax, a syntax presented in, "Compilation of Interaction Nets" (Hassan et al.), and a frontend based on LaFont's subset language of interaction nets, [interaction combinators](https://core.ac.uk/download/pdf/81113716.pdf).

## MIVM Article Series

Over the coming months I will continue to publish articles detailing the development of this project. The project is currently published on my GitHub [here](https://github.com/dowlandaiello/mivm).
