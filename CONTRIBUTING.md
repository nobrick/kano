# Contributing to Kano

## Reporting Bugs
Bugs are tracked as [GitHub issues](https://guides.github.com/features/issues/), explain the problem and include addition details clearly to help reproduce the problem.

## Code Contribution

### Submitting a Pull Request
- Make your changes in a new git branch.
- The branch name is in the format of `<type>/<subject>` (for example `feat/handyman-bonus`), type must be one of the following:
  - **feat**: A new feature
  - **fix**: A bug fix
  - **enhance**: A feature enhancement
  - **docs**: Documentation only changes
  - **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc.)
  - **refactor**: A code change that neither fixes a bug nor adds a feature
  - **perf**: A code change that improves performance
  - **specs**: Adding missing test specs
- Follow the [Coding Guidelines](#coding-guidelines).
- Ensure all tests passed.
- Make git commits following [Git Commit Messages](#git-commit-messages).
- Write appropriate test cases following [Specs Guidelines](#specs-guidelines).
- Rebase to avoid getting your code base too outdated.
- Push the git branch to GitHub.
- Make the PR.

### Git Commit Messages
- Follow the 50/72 rules for Git messages:
  - First line is 50 characters or less
  - Then a blank line
  - Remaining text should be wrapped at 72 characters

- Check the grammar and spelling, articles(`the`, `a`, `an`) in a message can be omitted for elegance.
- Prefix `[ci skip]` to the message to ignore CI builds for `docs` and `style` commits.

### Coding Guidelines
Follow the rules contained in [The Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide).

### Specs Guidelines
Follow best practices in [Better Specs](http://betterspecs.org/) for writing tests with RSpec.
