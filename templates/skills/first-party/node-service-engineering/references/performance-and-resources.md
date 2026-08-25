# Performance And Resource Ownership

Use this reference for event-loop or worker-pool latency, CPU work, streams, queues, memory, worker
threads, child processes, and overload behavior.

## Protect Shared Schedulers

Node.js serves many clients with a small number of threads. Event-loop callbacks and worker-pool
tasks must therefore be bounded and fair. Asynchronous syntax alone does not make work cheap: file,
DNS, crypto, compression, and native operations may consume the worker pool, while parsing,
serialization, regular expressions, and JavaScript computation consume the event loop.

Before optimizing, measure latency distributions, event-loop delay, queue depth, worker-pool
saturation proxies, CPU, memory, garbage collection, and external dependency time. Reproduce with
representative payload sizes and concurrency.

For expensive work, choose deliberately among:

- reject or cap work at admission;
- partition it into bounded resumable steps;
- stream or page it;
- use a bounded worker-thread pool for CPU-heavy JavaScript;
- use a child process or external job system for stronger failure or privilege isolation.

Do not create one worker per request. Account for serialization/copy cost and transfer ownership.
Worker threads share a process and are not a security boundary.

## Backpressure And Memory

Respect the return value of writable stream operations and wait for drain. Prefer pipeline helpers
that propagate failure and tear down the whole chain. Bound high-water marks based on the number of
concurrent streams, not in isolation.

Set explicit limits for request bodies, uploads, decompressed data, queue batches, pagination,
outbound responses, caches, logs, and child-process output. Reject before allocation where possible.
An unbounded map, queue, promise collection, or buffered stream is a memory leak with traffic as its
trigger.

Give resources lexical or lifecycle ownership. Cleanup must run on success, failure, timeout,
cancellation, disconnect, and process shutdown. Track timers and listeners; `unref()` changes process
liveness but does not replace cleanup.

## Child Processes

Pass a fixed executable and validated argument array. Avoid a shell. Restrict inherited environment,
working directory, privileges, input, runtime, and output. Consume stdout and stderr without
deadlocking, propagate cancellation, and terminate the process tree according to platform behavior.

Use child processes for native tools only when their operational and security cost is justified.
Never concatenate untrusted data into a command string.

## Verification Scenarios

- maximum accepted and first rejected payload or batch
- saturated concurrency and queue behavior
- slow consumer backpressure and peer disconnect
- cancellation and timeout while each resource is held
- worker failure, child exit, oversized output, and shutdown
- sustained-load memory plateau rather than only a short benchmark peak
- event-loop delay and tail latency before and after the change

Sources: https://nodejs.org/en/learn/asynchronous-work/dont-block-the-event-loop,
https://nodejs.org/en/learn/modules/backpressuring-in-streams, and
https://nodejs.org/api/worker_threads.html
