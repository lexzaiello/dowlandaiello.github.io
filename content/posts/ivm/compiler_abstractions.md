---
title: "Private Intermediate Representation: An Intuitive Abstraction for Compiler Implementation"
date: 2025-01-27T15:25:19-05:00
draft: true
---

Over the last 3-4 months, I've set out on the ambitious task of designing and implementing my own programming languages. My languages implement relatively novel features and belong to a field of programming called "interaction programming" (IP). IP is a Turing-complete model of computing based on symbolic graph rewriting rules ("interaction"). Rules are defined through interaction between agents through ports. IP poses numerous advantages to other computing models due to its lack of requirements for global synchronization, enabling intuitive and massive parallelism.

During my research into compiler/interpreter design, I iterated and prototyped many implementations of IP, each making new design choices informed by my prior learnings. So far, I have implemented:

- A basic lambda calculus interpreter, with a hand-written parser
- Multiple parsers for syntaxes representing interaction programs
- A high-level bytecode-interpreted stack-based virtual machine for interaction net programs
- A low-level bytecode-interpreted stack-based virtual machine for interaction net programs
- An AST-walker "naive" implementation of interaction nets
- An AST-walker implementation of interaction combinators

So far, I have relied on my intuition in designing this software. I have utilized no formal references and I have no formal training or background in compilers. As a result, in the process, I've discovered a few techniques and abstractions that have made implementing new versions of my language easier, and less error-prone. In this article series, I aim to give an overview of how these abstractions work, why they are useful, and how they can be implemented in Rust.

## Private Intermediate Representation

Intermediate representation (IR) languages (e.g., LLVM IR, MIR) are often utilized by compiler backends to generate binary targets in a platform-agnostic, portable way. IR languages also permit optimizations that are not immediately obvious in initial human-readable source code. IR languages also make code generation more intuitive, readable, and maintainable. However, IR languages are often a target exposed in and of themselves sitting between a compiler frontend and backend. As a result, they often have custom syntax and toolchains, and are an unnecessary and heavy abstraction for many small languages.

However, the benefits of an IR language can still be realized without hosting the language in a self-contained, free-standing way. In other words, an IR language may serve great utility as a "private" abstraction in the implementation of a compiler, seeing no usage in the public-facing API.

### Why

I discovered this abstraction in the course of implementing my bytecode-interpreted language variant, where it became nearly indispensable. In particular, this abstraction enabled the composition of code generation "blocks" in a reusable and readable way. For example, in compiling an interaction net program for my virtual machine, I would often hand-write loops, which was very tedious and error-prone. Almost always, the structure of the loop was identical, differing only in its body and `GOTO` instruction position. For example:

```rust
// i = 3
Op::PushStack(StackElem::Ptr(GlobalPtr::AgentPtr(AgentPtr {
	mem_pos: 3,
	port: Some(0),
})))
.into(),

// Loop body: print out *memptr
Op::Copy.into(),
Op::Debug.into(),

// Incr ptr
Op::PushStack(StackElem::Offset(1)).into(),
Op::IncrPtr.into(),
Op::Copy.into(),

// *i != null -> continue, else break
Op::Deref.into(),
Op::PushStack(StackElem::None).into(),

// Goto loop beginning @0x08
Op::PushStack(StackElem::Ptr(GlobalPtr::MemPtr(8))).into(),
Op::GoToNeq.into(),
```

Most of this snippet is boilerplate, with only 2 lines constituting the body of the loop. Furthermore, the boilerplate is implemented through a GOTO opcode which jumps to the beginning of the loop. This places an unnecessary cognitive load on the programmer by requiring them to keep track of the absolute starting positions of every loop in the source code, calculating offsets caused by moving blocks around in the source code. Introducing a private intermediate representation does a great deal to lessen this burden and allows easy composition of snippets of generated code. Here's what that code looks like using my IR:

```rust
BcBlock::IterRedex {
	stmts: vec![
		// The redex will be lhs port pointer, rhs port pointer
		// in stack [0], [-1]
		BcBlock::RawOp(Op::Deref)
	],
}
```

This is, in a true sense, a zero-cost abstraction. The output of this code is identical. However, the two are worlds apart in their readability, and reusability. That is, the body, `stmts`, of `IterRedex` may contain any other variant of `BcBlock` or a sequence of raw opcodes. `Referable`, another IR variant, is equally powerful. This variant permits a subset of IR variants to product outputs, which can be referred to later in code generation. For example:

```rust
// Where lhs and rhs are AST elements in code generation
let net_ref = Rc::new(NetRef::Intro { lhs, rhs });

out.push(net_ref.clone());

// Need to translate the net in some way to its reduced form
// by substituting symbols
if requires_substitution {
    out.push(BcBlock::QueueRedex(net_ref.clone()));

	// ... more code gen for modifying the net to its reduced form
}

out.push(BcBlock::PushRes(Some(net_ref.clone()), Some(net_ref)));
```

Here, `NetRef::Intro` serves both to abstract the generation of bytecode to translate a net from the AST to the VM's memory layout and as a variable that can be referred to later in code generation. As was the case for `IterRedex`, this does a great deal to offload the cognitive burden of remembering memory offsets from the programmer to the compiler itself. Furthermore, this new layer of abstraction also permits the layout of memory to change in the future without breaking previous code generation plans.

### How

To folks of the object-oriented programming persuasion, this strategy smells like polymorphism. In languages like Java, this would call for at least two interfaces and a class for each IR variant. However, in Rust, implementation of this feature is concise and easy:

```rust
#[derive(Ord, PartialOrd, Eq, PartialEq, Debug)]
pub enum BcBlock<'a> {
    Referable(Rc<NetRef<'a>>),
    Substitute,
    PushRes(Option<Rc<NetRef<'a>>>, Option<Rc<NetRef<'a>>>),
    IterRedex { stmts: Vec<BcBlock<'a>> },
    RawStackElem(StackElem),
    QueueRedex(Rc<NetRef<'a>>),
}

#[derive(Ord, PartialOrd, Eq, PartialEq, Debug)]
pub enum NetRef<'a> {
    Intro {
        lhs: &'a Agent,
        rhs: &'a Agent,
    },
    MatchingRule,
    SubstitutionPositions {
        of_parent: Option<Rc<NetRef<'a>>>,
        of_child: Option<Rc<NetRef<'a>>>,
    },
    CloneNet(Option<Rc<NetRef<'a>>>),
}
```

Here, each variant of `BcBlock` and `NetRef` represents a segment of generated bytecode. Some variants are composable (e.g., `IterRedex`). Variants of `NetRef` each produce a pointer to a net and can be referred to later as values in a later code generation step to invoke the compiler's bookkeeping function. These features are accomplished easily with a map from `BcBlock` variants to source code pointers and pattern matching over each `BcBlock` to produce the corresponding bytecode. For example:

```rust
for instr in instrs {
    match instr {
        BcBlock::Referable(r) => match r.clone().as_ref() {
            NetRef::Intro { lhs, rhs } => {
                let (section, _, intro_agent_ptrs) =
                    Self::try_compile_net(start_ptr + src.len(), lhs, rhs)?;
                src.extend(section);

                agent_ptrs
                    .extend(intro_agent_ptrs.into_iter().map(|(_, v)| (r.clone(), v)));
            }
			// ...
        },
        BcBlock::IterRedex { stmts } => {
            let loop_start_ptr = start_ptr + src.len();

            let compiled_instrs =
                Self::compile_section(loop_start_ptr + 4, agent_ptrs, stmts)?;

            src.extend([
                Op::PopRedex.into(),
                Op::PushStack(StackElem::None).into(),
                Op::PushStack(StackElem::Ptr(GlobalPtr::MemPtr(
                    loop_start_ptr + 4 + compiled_instrs.len() + 2,
                )))
                .into(),
                Op::GoToEq.into(),
            ]);
            src.extend(compiled_instrs);
            src.extend([
                Op::PushStack(StackElem::Ptr(GlobalPtr::MemPtr(loop_start_ptr))).into(),
                Op::GoTo.into(),
            ]);
        }
        // ...
    }
}
```

Private intermediate representations are one of many very useful abstractions I've stumbled into in implementing my language. This abstraction in particular is relatively simple but exceedingly powerful.
