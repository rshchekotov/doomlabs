# Contribution Guidelines
## Git
### Commit Standard
I use the [Gitmoji](https://gitmoji.dev/) standard for commit messages, 
so if you expect your submissions to be reviewed, please use it as well.
I would also prefer Unicode Emoji's over the `:emoji:` syntax due to
the fact that some tools may not render the text-version out-of-the-box,
which would make the commits look horrendous.

Additionally, unless it's a **very** small change (i.e. typo), I'd love to 
have a commit body explaining the changes made, and more importantly why they
were made.

I also, support scopes if you want to use them, but that's a minor concern
to me. In that case the message would preferably look like this 
`🎨 [infra] refactor terraform code`.

An example of a bigger commit message as I would write it, would be:
```
🎨 refactor terraform code

- Refactored the terraform code to use modules
- ...
```

### Branches
I use the [Gitflow](https://nvie.com/posts/a-successful-git-branching-model/)
and I would like all of you to use it as well, so that we can keep things
consistent, organized and easy to understand.

The branch prefixes would be as usual, meaning:
- `feature/` for new features
- `hotfix/` for critical bug fixes

Then `master` for the main history, `develop` for the unstable (yet compilable)
history and `release` for the stable and tested history.

`develop` and `release` in this sense are often referenced as 
'bleeding-edge'/'unstable' and 'stable' respectively.

After major releases we will also tag the appropriate commit on master in
order to allow reproducible builds.

## Code
### Style Guide
Here's a quick summary of the style I use and expect in contributions:
- 2 spaces for indentation (unless there's a very good reason to use 4)
- 80 characters per line (unless there's a very good reason to use more)
- Use either Java or C naming conventions depending on the language (just check what I'm using)
- `{` in the same line for blocks and a space between keyword and brace, i.e.: `if (condition) {`
- Always use braces for blocks, even if they're one-liners unless the language favors the other way

Most of these should (hopefully) be enforced by linter configurations, so
please use those. If you're not sure, check the existing code and otherwise
don't hesitate to ask me. I put a **lot** of effort into making the code
consistent and easy to read, so I'd like to keep it that way.