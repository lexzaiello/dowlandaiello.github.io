---
title: "Chumsky Parser Combinator Review: Democratizing Language"
date: 2024-11-18T16:17:38Z
draft: true
---

## Lambda Calculus: Part II

As I recounted in my [previous post](https://dowlandaiello.com/posts/lambda_calculus_teach_programmers/), I've been enthralled in studying higher level CS in my free time. [Lambda Calculus](https://en.wikipedia.org/wiki/Lambda_calculus) has long been a particular interest of mine, so I recently took to writing a Lambda Calculus interpreter. The interpreter takes in a lambda expression and attempts to reduce it, step by step, or to infinity--or termination. As usual, I grew bored of the project over time, and eventually decided I was content with its degree of completion and correctness. As of writing, [the interpreter](https://github.com/dowlandaiello/lci) can reduce [church encoded](https://en.wikipedia.org/wiki/Church_encoding) arithmetic and list expressions, and attempt to reduce the paradoxical combinator, step by step, or by causing a stack overflow. Surprisingly to those who will peruse the source code, almost all of the components are hand written. It uses no parsing libraries, and has **no dependencies**, aside from, implicitly, Rust's standard library. This was a mistake.

### Parsing is Hard

Parsing is, in short, the art of edge case handling, and by nature, results in very verbose, unreadable code. In the experience I gleaned from writing `lci`, I've determined that hand-writing parsing solutions, in almost all cases, will likely make the task of parsing even harder and unsustainable.

Edge cases, tautologically, require special consideration. This is especially true for hand-written solutions like, which do not defer to any dependencies. When none of the work to handle special cases is done for you, you must write them yourself. So that is what I did. The end result was a disgusting, abhorrent amalgamation of string manipulation and pattern matching, which bears resemblance to code written by a monkey engaged in proving the [Infinite Monkey Theorem](https://en.wikipedia.org/wiki/Infinite_monkey_theorem) in its intelligibility.

#### Exhibit A: Cyclomatic Complexity Ad Infinitum

At the top level, a lambda expression can only be one of three things: a variable, an abstraction, or an application. These terms are explain in my previous post for those who are interested, but for the purposes of this article, their significance is irrelevant. This would seemingly imply that parsing a lambda expression would involve invoking one of three possible parsers: a variable parser, an abstraction parser, or an application parser. Each is distinct in that abstractions begin and end with parenthesis, applications involve one or more expression next to each other, and variables are just letters. It escapes my understanding, then, why my parser contains 8 if clauses, two pattern matches, and interior calls to further parsing functions.

To illucidate this dilemma, here's an example of *deeply nested* control flow in the parser:

```rust
let mut applicands = to_curried(tok_stream)?;

// Single term
if applicands.len() == 1 {
    let mut term = applicands
        .pop()
        .ok_or(Span::new(0, Error::EmptyExpression))?;

    // Free term
    if term.len() == 1 {
        let tok = term.remove(0);

        match tok {
            Span {
                pos: _,
                content: Token::Id(c),
                backtrace: _,
            } => {
                return Ok(Expr::Id(c));
            }
            Span {
                pos,
                content,
                backtrace: _,
            } => {
                return Err(Span::new(pos, Error::UnrecognizedToken(content)));
            }
        }
    }

/// cont...
```

This code parses a free variable. That is to say, special case handling is exceedingly verbose without readily available, composable units which do the work for you. These readily available, composable units are frequently referred to as combinators, and I like them, a lot.

## Enter Chumsky


