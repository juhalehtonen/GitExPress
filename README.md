# GitExPress

[![Build Status](https://travis-ci.org/juhalehtonen/GitExPress.svg?branch=master)](https://travis-ci.org/juhalehtonen/GitExPress)

A simple blog engine with a Git-based workflow. With GitExPress, you can write your blog posts in any public Git repository (e.g. in GitHub, GitLab..) as markdown files and have GitExPress automatically update the contents on your website when your posts are updated (see webhook section).

Only files ending with .md are parsed (and README/CHANGELOG files are ignored), so drafts of posts can be created by simply using a different file extension (or omitting one altogether).

## Usage

Before using GitExPress, you need to configure a couple of things:

- HTTPS URL of your remote Git repository
- Local path where to clone/pull said directory
- ~~Webhook secret~~ (TODO)

GitExPress can be used without a webhook, but not setting one up means you need to provide an alternative method for updating your blog posts. This can be a periodic GenServer, manual labour, or whatever you wish.

## Blog post format

To ensure GitExPress can parse the blog posts, they need to be in a following format:

```
Title: Title of the blog post
Date: 2018-12-31

From this point on, content of the blog post in [markdown](https://daringfireball.net/projects/markdown/) format.
```

## Testing

Run the following whenever making changes to ensure code quality stays consistent (also ran on TravisCI):

```
mix test
mix coveralls
mix format --check-formatted
mix dialyzer --format dialyxir
mix credo --strict
```

## License

Licensed under the MIT License.
