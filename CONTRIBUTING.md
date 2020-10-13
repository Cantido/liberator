# Contributing

Thank you for considering contributing!
I write libraries in my free time and contributions from others help me make great tools.

Following these guidelines helps to communicate that you respect my time,
as the developer managing and developing this open source project.
In return, I should reciprocate that respect in addressing your issue,
assessing changes, and helping you finalize your pull requests.

Questions and pull requests are more than welcome.
I follow Elixir's tenet of bad documentation being a bug,
so if anything is unclear, please [file an issue](https://github.com/Cantido/liberator/issues/new)!
Ideally, my answer to your question will be in an update to the docs.

Please note that this project is released with a Contributor [Code of Conduct]. By participating in this project you agree to abide by its terms.

**Working on your first Pull Request?** You can learn how from this *free* series [How to Contribute to an Open Source Project on GitHub](https://egghead.io/series/how-to-contribute-to-an-open-source-project-on-github).

## Ground Rules

- Follow the [Code of Conduct].
- Keep your commits clear and your pull requests small.
  This isn't a big library.
- Run `mix format` on your files before committing them.
  I like clean diffs.
- Run `mix credo` and resolve anything of yours that comes up.
- Delegate as much as possible to the user, or let them override everything.
- Provide sensible defaults.
  If you can `use Liberator.Resource` in an empty module in an empty Phoenix project,
  and make a request that returns `200 OK`,
  you're doing great.
- Don't pollute the user's context.

## Your First Contribution

- Ask questions!
I like writing good documentation, and questions make that work more meaningful.
Use the issue tracker for questions.
There's a [questions] tag on the issue tracker for that reason.
- Tests are always welcome!
Liberator is a project with a lot of conditional logic,
with a lot of resulting complexity.
- Searching issues or pull requests tagged "[help wanted]" or "[good first issue]" are great places to get started.

## Getting Started

GitHub makes it really easy to submit pull requests. Just:

1. Create your own fork of the code
2. Do the changes in your fork
3. [Submit a pull request](https://github.com/Cantido/liberator/compare)

I don't require a CLA or anything like that.

## How report a bug

If you find a security vulnerability, do NOT open an issue.
Contact [Rosa on keybase.io](https://keybase.io/cantido) instead!

In order to determine whether you are dealing with a security issue, ask yourself these two questions:

- Can I access something that's not mine, or something I shouldn't have access to?
- Can I disable something for other people?

If the answer to either of those two questions are "yes",
then you're probably dealing with a security issue.
Note that even if you answer "no" to both questions,
you may still be dealing with a security issue, so if you're unsure,
[message me directly](https://keybase.io/cantido).
This project helps developers expose data, but we only want it exposing the correct data!

Please [open an issue](https://github.com/Cantido/liberator/issues/new) and
follow the directions in the issue template.

## How to suggest a feature or enhancement

The philosopy of this project is to create a small, sharp tool that takes the burden
of the HTTP spec off of the shoulders of developers.
Feature requests and enhancements should stick to this philosophy.
Help me implement the HTTP spec more closely,
or help me do anything that lets developers do more with their valuable time.

Feature requests give meaning to my work.
[Open an issue](https://github.com/Cantido/liberator/issues/new) that decribes the feature you'd like to see,
why you need it, and how you'd like it to work.

## Code review process

As the primary developer, I will be the one reviewing all pull requests.
I check GitHub almost every day, so you should be able to hear back from me quickly.
However, I only do this in my free time, so please allow me flexibility.

## Community

Chat with me on https://gitter.im/liberator-elixir/community.
This is a small project, but I care about the people that care about my work.
I'm also on [keybase](https://keybase.io/cantido) if you need to message me directly.

---
If you like this contribution guide, please give a star to [Nadia Eghbal]'s [`contributing-template`] project on GitHub.
It was a great help.

[Nadia Eghbal]: https://github.com/nayafia
[`contributing-template`]: https://github.com/nayafia/contributing-template
[help wanted]: https://github.com/Cantido/liberator/labels/help%20wanted
[good first issue]: https://github.com/Cantido/liberator/labels/good%20first%20issue
[questions]: https://github.com/Cantido/liberator/labels/question
[Code of Conduct]: code_of_conduct.md
