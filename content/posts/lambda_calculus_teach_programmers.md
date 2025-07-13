---
title: "Thinking in Lambdas"
date: 2024-11-06T18:55:53Z
draft: true
---

*Note: this post will likely be one in a series detailing my experience writing a lambda calculus interpreter*

## My First Abstraction

Around the age of 14, I decided I wanted to learn Haskell. Haskell is a language that is notorious for its learning curve, with many simple tasks requiring at least a superficial understanding of higher level math concepts (e.g., "a monad is a monoid in the category of endofunctors"). Haskell, unlike many other languages, adopts a theory-first, applications-second philosophy. That is, while more widely used languages like Python and JavaScript bear relatively minimal cognitive overhead when writing programs, and very little background knowledge to be productive, Haskell requires an understanding of its theory to write code that even compiles. That is to say, while other languages are a means to an end, Haskell is an end in and of itself.

This challenge was appealing to my blossoming youthful mind, and so I decided I would write an implementation of the Ethereum Virtual Machine in Haskell. Unsurprisingly, I didn't get very far. Until then, I had lived in the world of "imperative," programming. That is, step-by-step instructions detailing *how* a program executes. In light of my frustration, a tutor at a STEM summer camp I was attending, a PhD student in linguistics named Jake, suggested I learn theory first, as it would make writing Haskell programs much easier.

Completely self-taught up until that point, being thrown into the world of "lambda calculus," a model of computation that gave rise to virtually the entire field of functional programming, was almost even more frustrating than trying to write a virtual machine in Haskell without any basic idea of what it means for a function to be a first-class feature. Lambda Calculus, despite being able to represent any computation that alternative models of computing, like Turing machines, can, is markedly simple. A lambda calculus "program," can consist of only 3 elements: an abstraction, a variable, and an application. Here's a diagram to illuminate the syntax:

*Note: those familiar with lambda calculus may want to skip to "[What I Learned]({{< ref "#what-i-learned" >}} "About Us")"*

$$\text{expr ::= }<\text{variable}>|<\text{application}>|<\text{abstraction}>$$

$$\text{variable ::= }'a'|..|'z'$$
$$\text{abstraction ::= } (\lambda <\text{variable}>.<\text{expr}>)$$
$$\text{application ::= } (<\text{expr}>) (<\text{expr}>)$$

For those unfamiliar with this notation, a variable can be any letter, an abstraction is represented by a lambda, followed by a dot, followed by an expression, and an application is two expressions next to each other. To those with some experience in computer programming, the semantic meaning of these expressions might be intuitive. Initially, it was for me.

Any lambda calculus program, which consists of an expression, can be evaluated using two basic rules:

- Beta reduction
- Alpha renaming

Beta reduction, or substitution, is the process of replacing every variable in the body of an abstraction--everything coming after the dot--which matches the input variable--the letter coming before the dot--with whatever argument is provided to the function (i.e., each variable which belongs to its scope). For example:

$$(\lambda x.x)(a) \Rightarrow (a)$$

In this substitution, \(a\) is provided as an argument to the abstraction \((\lambda x.x)\), which takes an input \(x\) and returns that \(x\). This is known as the identity function. For many expressions, this rule is relatively straightforward and intuitive. For example, a lambda expression which takes two arguments, and returns the second argument, provided two arguments, \(a\) and \(b\):

$$(\lambda a.(\lambda b.b))(x)(y)$$

Applying our rules of substitution, we plug \(x\) in for \(a\), the argument in the outer expression, and do nothing, realizing it appears nowhere in the body of the abstraction. Then, we're left with:

$$(\lambda b.b)(y)$$

Squinting at the expression very quickly reveals that it is virtually identical to the identity function, just with the variables renamed. That is, semantically, the two expressions are identical, or "alpha equivalent." Evaluating this expression is easy. Plug \(y\) in for \(b\), which is the sole output of the function, giving us back \(y\). In summary:

$$(\lambda a.(\lambda b.b))(x)(y) \Rightarrow (\lambda b.b)(y) \Rightarrow y$$

After practicing reducing countless lambda expressions, I developed a knack for the procedure. However, I was quickly frustrated when my mentor introduced the encoding of true and false in lambda calculus and challenged me to create a "not" function, which returns false for true as an input, and true for false as an input. I quickly realized that, while I understood the rules of lambda calculus, I did not understand why the rules of lambda calculus existed, or how they could represent computer programs. In other words, I knew how to evaluate lambdas, but I was fundamentally unable to think in lambdas. Over the next few years, I have grown increasingly obsessed with lambda calculus, and, with time, grew the ability to "think in lambdas." Reflecting on my experience, I can definitively say that learning this skill has fundamentally changed the way I learn and think about programming, for the better.

## Thinking in Lambdas

I still remember the moment when I realized the expressive power of lambda calculus. At least a year after my first encounter with the system after my brain had developed more, I set to task once again on writing a not function. After about an hour banging my head against a whiteboard attempting to brute force a solution, I decided perhaps more theory work would be beneficial.

Up until that point, I generally thought of function application in typical imperative programming terms. To me, \((\lambda x.(\lambda y.x y))\) represented a function with multiple inputs, which returned one input applied to the other. Nominally, I understood currying--a name for when nested functions may be called with multiple arguments: the function \((\lambda x.(\lambda y.x y))\) returns another function when called, which can also be called. However, being relatively inexperienced in computer programming at such a young age, I failed to realize that, in lambda calculus, **functions are values**.

## Stumbling Into FP Enlightenment

I experimented more with expressions I hadn't tried before. Taking inspiration from lambda calculus' definition of expressions, I tried calling various functions with variables, abstractions, and expressions calling functions themselves. My first attempt looked something like this:

$$(\lambda x.x)(\lambda x.x) \Rightarrow (\lambda x.x)$$

In writing this expression, I had completed part of the puzzle. Not only could I return functions I had written myself from a function, but I could return *any* function from a function, including ones supplied as arguments. I followed this idea to its conclusion, and wrote out the following expression:

$$(\lambda f.(\lambda x.f x))$$

I reasoned that if I could supply a function as an argument to a function, then I could surely call the function from another function. So, I tried it:

$$(\lambda f.(\lambda x.f x))(\lambda x.x)(a) \Rightarrow (\lambda x.(\lambda x.x) a)(a) \Rightarrow a$$

Then, I tried combining the two expressions by accepting a function as a parameter, and calling the function with itself:

$$(\lambda x.x x)(\lambda x.x) \Rightarrow \lambda x.x$$

And then, finally, I completed the puzzle:

$$(\lambda x.x x)(\lambda x.x x) \Longleftrightarrow (\lambda x.x x) (\lambda x.x x)$$

This expression, no matter how many times it is reduced, will always produce the same result--that is, it is recursive. That was the moment I started thinking in lambdas. Writing out the expression for a not gate was trivial with this new information:

$$(\lambda x.(\lambda a.(\lambda b.x (\lambda a.(\lambda b.b)) (\lambda a.(\lambda b.a)))))$$

## What I Learned

Ever since I "learned," lambda calculus, I've noticed its principles showing up in unexpected places as my career in software engineering has developed. "Thinking in lambdas," has noticeably changed the way I program and think about problems for the better. Specifically, "thinking in lambdas," has allowed me to better design and understand abstractions--synthetic structures, concepts, or patterns, which are created to achieve some goal, typically through a layer of indirection.

### Abstraction Meets Abstraction

Abstractions, or anonymous functions, in lambda calculus, are radically simple. They have an input and an output. By contrast, abstractions in practical programming languages, like Python, are far more concrete and varied. In many languages, abstractions may take the form of classes or functions. However, functions in lambda calculus and most programming languages diverge in that lambda calculus functions are truly pure "black boxes." That is, they have no side effects, and as a result, are highly composable and easy to reason about. Functions in languages like Haskell, for example, are characterized almost entirely by their type, and in some cases, are self-documenting. Functions in languages like Python or Java, by contrast, can "launch the missiles," at any time, opening network sockets, creating and deleting files, and altering variables outside their scope, requiring constantly updated documentation.

While making guaranteed pure black boxes in many traditional languages is not possible, I've learned that the "pure black box," design pattern is indispensable, especially when languages lack features for providing such guarantees, or other safety features--like Python, which has poor support for type annotations and no canonical way to express side effects.

In my previous post, [NixOS: Fearless Ricing](https://lexzaiello.com/posts/nixos), I mentioned that I was tasked at my job with implementing an MEV searcher for the Cosmos network. An MEV searcher is a program which executes trades on a blockchain network based on opportunities it identifies on the ledger. One of the requirements for the project was that it needed to be extensible. Users needed to be able to write custom searchers using the utilities and scaffolding provided by my software. To achieve this goal, I designed an abstraction called the "PoolProvider," which represented a generic Cosmos [liquidity pool](https://support.uniswap.org/hc/en-us/articles/8829880740109-What-is-a-liquidity-pool), with two main functions: querying the balance of assets in the pool, calculating the price of assets in the pool using the \(xy=k\) formula, and submitting trades. Ideally, users of the library would be able to use code I had already written for the provider I had implemented by extending the PoolProvider abstract class and overriding the relevant methods.

### Stateless Mutation

On a high level, the PoolProvider abstraction was intended to allow a wider executor to defer transaction and price querying logic to user-defined implementations. Initially, this is what the abstraction did, but the ease of adding unnecessary fields and new methods to the Provider class led to rapid "spaghettification," of the code base, and the introduction of implicit mutation in confusing and unobvious ways. Retrospectively, I could have drawn parallels to my knowledge of lambda calculus and functional programming, and opted for making the abstraction as pure as possible: no mutation, or, if impossible, centralizing mutation as much as I could. Purposely limiting and being conscious of mutation in your code can assist greatly in improving composability and unit testability, as it did for me. Having the experience lambda calculus confers of making novel abstractions makes this possible.

In my next post, I'm going to be discussing Monads, my plans for a lambda calculus compilation target for WebAssembly (a la [HVM](https://github.com/HigherOrderCO/HVM)), and how I intend to use Monadic design patterns to clean up my MEV searcher.
