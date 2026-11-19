# Grading and instructor setup

## Local checks and GitHub Actions

`make test` builds the submitted assembly and runs each test in a separate
QEMU process with a 3-second timeout. No C compiler, Python, or testing
framework is required. Use `TEST_TIMEOUT=5 make test` on a slower machine.
Use `make test GROUP=NAME` for practice with filenames beginning `NAME-`.
The full workflow always runs every group.

Results appear in `build/grade.json`, `build/grade.md`, and `build/logs/`.
Each public test has equal weight toward **80 automated points**, rounded
down once at the end. Review the remaining **20 manual points**:

| Criterion | Points |
| --- | --- |
| Required procedure decomposition and meaningful helper calls | 10 |
| Stack/calling-convention discipline, including alignment during calls | 5 |
| Clear comments, names, and readable implementation | 5 |

Tests check returned results, selected memory guards, and preservation of
`x19`–`x29` and SP at call boundaries. They cannot prove all memory accesses
are valid, that all nested calls are aligned, or that helpers actually drive
the result. Review those aspects. There is no instruction whitelist.

The `Autograding` Actions workflow runs on push, pull request, and manual
dispatch. Its job summary shows the results; a `grading-results` artifact
contains JSON and logs. Failing tests intentionally make the workflow red.
Build failures produce no numeric score. A new lab starts with TODO exits
and is expected to fail until students implement it.

## Assignment distribution

Mark each starter repository as a GitHub template. Create a private copy for
each student or connect it to your chosen assignment-management platform.
The course does not require an external classroom package in the Codespace.
GitHub Classroom retired on August 28, 2026; existing repositories remain.
[GitHub announcement](https://github.blog/changelog/2026-08-27-github-classroom-deprecated/).
Classroom 50 or another platform can run `make test` and consume the JSON
score. Platform-specific gradebook integration is not configured here.

## Grading integrity

Public tests are formative feedback. A student's editable workflow or test
files are not a trusted final grade source. For final grading, an instructor
should check out the submitted commit in a controlled grader, retain only
the submission's `src/*.s`, overlay the trusted starter's build/support/tests,
and run `make test` on a fresh build. Record the commit SHA with the result.
The separate instructor kit supplies a script for this process and solutions
for validating the tests. Keep that kit private and outside student repos.

Run untrusted submissions on disposable GitHub-hosted runners with read-only
permissions and no secrets. Do not use `pull_request_target` to execute
submitted code. Additional hidden tests require instructor-controlled files;
putting them in a student repository does not keep them hidden.

## Pilot before distribution

1. Create a fresh Codespace and run the base template's `make test`.
2. Try `make debug` and `make gdb` in two terminals.
3. Confirm each lab builds and its TODO tests fail.
4. Validate solutions separately with the instructor kit.
5. Confirm Actions is enabled in the organization/account and a push creates
   a run. Live Codespaces availability, quotas, and organization policy are
   account settings; local container validation cannot verify them.
