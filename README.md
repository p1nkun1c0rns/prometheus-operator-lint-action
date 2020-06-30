# prometheus-operator-lint-action

[![Test](https://github.com/p1nkun1c0rns/prometheus-operator-lint-action/workflows/Test/badge.svg)](https://github.com/p1nkun1c0rns/prometheus-operator-lint-action/actions?query=workflow%3ATest)

This action ...

## Contributions

- Contributions are welcome!
- Give :star: - if you want to encourage me to work on a project
- Don't hesitate create issue for new feature you dream of or if you suspect some bug

## Project versioning

Project use [Semantic Versioning](https://semver.org/).
We recommended to use the latest and specific release version.

In order to keep your project dependencies up to date you can watch this repository *(Releases only)*
or use automatic tools like [Dependabot](https://dependabot.com/).

## Usage

See [action.yml](action.yml)

### One Path

```yml
steps:
- uses: docker://p1nkun1c0rns/prometheus-operator-lint-action:v2.0.3
  env:
    INPUT_PATH: "./"
    INPUT_FILES: ".yaml"
    INPUT_EXCLUDE: "skip"
```

### Multiple Paths

```yml
steps:
- uses: docker://p1nkun1c0rns/prometheus-operator-lint-action:v2.0.3
  env:
    INPUT_PATH: "./DEV/monitoring,./TEST/monitoring,./PROD/monitoring"
    INPUT_FILES: "*.yaml"
    INPUT_EXCLUDE: "foobar"
```

## Testing

For testing the [bats](https://github.com/bats-core/bats-core#installation) testing framework is used.

```bash
git clone https://github.com/p1nkun1c0rns/prometheus-operator-lint-action.git
./tests/run.bats
```

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE)

## Release

- create new branch
- make your changes, if needed
- commit your changes like
  - Patch Release: `fix(script): validate input file to prevent empty files`
  - Minor Release: `feat(dockerimage): add open for multiple input files`
  - Major Release [look her](https://github.com/mathieudutour/github-tag-action/blob/master/README.md)
