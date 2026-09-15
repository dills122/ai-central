# Fixture contract

This module is an in-memory example, not a persistent store or deployed service.

- Receiving a value must persist it before acknowledging it. Restart creates a new
  Receiver over the same Store; fault callbacks may raise an exception.
- Each Grant permits at most one effect. after_check represents a schedulable point.
- Reply body is confidential. Both stdout and stderr are forbidden observations.
- A frame consists of a 4-byte big-endian payload length followed by payload bytes.
  Payloads longer than 128 bytes must be refused, as must a mismatched length.

Use synthetic data only. All test code and outputs must remain under this directory.
Do not change the supplied fixture. There are no platform durability guarantees.
