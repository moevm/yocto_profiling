# forget_unavailable_mirrors.patch
Attempt to implement "forgetting" unavailable servers with cache upon receiving an unavailability error (5** code)

> [!IMPORTANT]
> Description for commit e4a79c9a60893e2ec36ea4634ee52a0704185a60

### Main Problem
The main issue is that bitbake lacks such functionality. The entire processing logic is based on either finding a file and returning true or not finding it and returning false.
Integrating this logic is a complex and significant task because the polling method depends on the interaction protocol supported in bitbake. This means that for each protocol, we need to implement the logic for tracking server unavailability errors, return a specific value up the call stack to somehow modify the logic of future polls. The task is complicated by the system's architecture: during the download, starting from a certain point, there is no access to the data class (only to its copy), which prevents removing all mentions of the unavailable server from the method where the unavailability error is encountered.

### Solution
Use raise to ascend to the level where the mirror polling logic is abstractly described and, upon receiving an error, intercept it and modify the future processing logic.
At this stage, this "ascent" to the point where the server polling is initiated—the `try_mirrors` method—has been implemented.

### Current Problem
The current problem is the reorganization of the mirror polling loop.
In the current version of `try_mirrors`, a list of the addresses we are interested in is first obtained:
```
uris, uds = build_mirroruris(origud, mirrors, ld)
```

Then a large polling loop is launched:

```
for index, uri in enumerate(uris):
```

#### Reorganization Problem
1. If we simply update the list of mirrors without changing the loop and uris, there will be no effect; the loop will continue to go through all previously compiled links.
2. If we abruptly terminate the loop, the current progress is lost (polled 3 thousand tasks, encountered an error, interrupted the loop, recalculated uris, started the loop again, and repolled the 3 thousand already polled packages—this is bad).
3. Reorganization while preserving the current progress with dynamic recalculation of uris. It might make sense to rewrite it using a while loop.


### Experiments on the Number of Requests
If the server is unavailable (approximately the same number of requests to a working server), on average:

- 1 request to each package (for .siginfo file)
- 2 requests to each package (for non-.siginfo file) 

In total, each non-working server creates a load of 3 * number of tasks. For core-image-minimal, this results in about 6.8 thousand requests.
