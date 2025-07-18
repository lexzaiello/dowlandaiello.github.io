+++
title = "Towards a Dependently-Typed Binderless Combinator Calculus"
date = "2025-07-18T13:27:42-07:00"
#dateFormat = "2006-01-02" # This value can be configured for per-post date formatting
author = "Alexandra Zaldivar Aiello"
authorTwitter = "lexzaiello" #do not include @
cover = ""
tags = ["lambda calculus", "type theory"]
keywords = ["", ""]
description = "In this post, I outline a proposed dependent type theory for the binderless SK calculus. I link the project's textbook, where you can learn more about my efforts."
showFullContent = false
readingTime = false
hideComments = false
+++

# Dependently-Typed SK is Possible

*To see more on this project, click [here](https://lexzaiello.com/sk-lean).*

The \(SK\) combinator calculus is a computational system equivalent to the $\lambda$ calculus. Dependent type theories are systems which add type information to a program such that types can "depend" on terms. That is, the execution of the program can create new types. As of yet, adding dependent typing to the SK calculus was thought impossible. I, however, have done it. By adding one combinator, the $M$ combinator which does dynamic reflection, I have successfully created the first dependently-typed $SK$ calculus.

## Progress

So far, I have formalized a working encoding of the dependent and non-dependent arrow ($\rightarrow$) derived only from $S$, $K$, $M$, and $\text{Type}$. No variables are used in the system. It is fully binderless, without relying on $\lambda$ abstraction at the expression or meta-level. I have foramlized my work in Lean thus far. I have also written an informal translation algorithm from the simply-typed $\lambda$-calculus to my $SK$ calculus.

## Future Work
