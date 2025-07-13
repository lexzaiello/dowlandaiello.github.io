---
title: "Open Sourcing my Interaction Combinator Research"
date: 2025-03-05T13:16:02-05:00
draft: false
---

# Announcing IC-Sandbox

Today, I open-sourced 4 months' worth of my self-conducted research, study, and iteration in the field of graphical parallel computing. Available on GitHub ([dowlandaiello/ic-sandbox](https://github.com/dowlandaiello/ic-sandbox)), ic-sandbox represents the culmination of months of fully self-directed learning in this burgeoning field of computing, all from first principles.

## Interaction Computing

Interaction computing (IC) is a rapidly growing field of research in computing building on proof nets, linear logic, and graphical computing. IC programs are characterized by their encoding of computation through local graph rewriting rules. The computing model poses numerous benefits for "massively parallel computing," due to its determinism and lack of requirements for global synchronization. IC programs are composed of agents that "interact" through primary ports. Interaction causes auxiliary ports of the agents interacting to be rewired according to rules. Many variations on the model exist, the most prominent being [Interaction Nets (LaFont)](https://dl.acm.org/doi/pdf/10.1145/96709.96718), and [Interaction Combinators (LaFont)](https://core.ac.uk/download/pdf/81113716.pdf).

## My Research

This repository unifies a wide variety of research previously conducted in this field. In my self-study and iteration, I implemented numerous syntaxes, reduction strategies, encodings, and systems based on interaction nets and interaction combinators. For example, LaFont's original syntax for interaction nets is implemented, alongside others and a custom intermediate representation for the symmetric interaction combinators. In total, I have written over **13 thousand lines of code** over the past 4 months across all iterations of the project.

Most notably, the repository **features a fully functioning parallel virtual machine implementing the [symmetric interaction combinators (Mazza)](https://lipn.univ-paris13.fr/~mazza/papers/CombSem-MSCS.pdf).** To demonstrate the practical and theoretical application of the interaction combinators, this project also implements a semi-functioning compiler from the SK combinators to my interaction combinator virtual machine.

I aim to eventually self-publish in further detail some of my discoveries gained through this process.

## Try it Out

Available on GitHub ([lexzaiello/ic-sandbox](https://github.com/dowlandaiello/ic-sandbox)), this project includes two important binaries:

- `icc`, a tool for evaluating, syntax checking, and debugging interaction combinator programs (also the underlying virtual machine for most of the repo)
- `toyfp`, an implementation of the SK combinator calculus targeting `icc`, my interaction combinator virtual machine

Type `cargo run --bin icc dev` to enter the interaction combinator REPL. The syntax is relatively obscure and not easily readable but is documented in the repository.

Type `cargo run --bin toyfp dev --sk` to enter the SK combinator -> interaction combinator REPL. Use `S` or `K` for the combinators, respectively, and parenthesis for application: `((KS)K) => S`. I recommend trying out this command with the `RUST_LOG=trace` environment variable set to demonstrate everything under the hood. Doing so will display a log of the conversion to interaction combinators, all the steps in reduction, all the steps in compilation, and all the steps in decoding. Note that this compiler is still in progress,  and some expressions cannot be decoded properly. Some expressions do not respect parenthesization correctly, either.

## Next Steps

I have a long roadmap for this project, but I'm most excited about a new compiler I am working on targeting my virtual machine. This compiler implements the BCKW combinator calculus. I am implementing the compiler in Lean. I have been loving Lean recently and would love to see it shine in this project.

## The Future Looks Bright

Interaction computing has been an absolute joy to work with and learn. I am aware of exciting research happening in the field, particularly focused on making the system practical, scalable, and efficient. I have no doubt that, with time, interaction combinators will find their way into specialized use cases where massive parallelism is required (or, perhaps, distributed computing?).

This has been, by far, my favorite project I have ever worked on, bar none.

It is a core belief of mine that to think is the pinnacle of what it means to be human. More than anything, this project was an experience in learning--in thinking.

I have never been as grateful in my entire life as I am today to have the astonishing privilege of being alive to study, experience, and savor computing, math, and thinking. I will cherish this wonderful privilege for the rest of my life. And, with hope, I will someday light the flame of passion in another human's heart for the subject that has loved me despite all odds, for nearly as long as I have been alive.

"Hello, world."
