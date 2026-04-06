# Datadog APM Integration for Odoo

## Prerequisites

1. **Datadog Agent installed** — The Datadog Agent must be installed and running on the host before enabling APM tracing. Refer to the [Datadog Agent Installation Documentation](https://docs.datadoghq.com/agent/) for setup instructions.

---

## Steps

### 1. Install `ddtrace` Library

```bash
pip install ddtrace
```

---

### 2. Add Tracing Middleware to `odoo-bin`

Edit the main Odoo entry point file (`odoo-bin`, located at the root of the Odoo installation) and add the following code after the Odoo application is initialized:

```python
from ddtrace.contrib.wsgi import DDWSGIMiddleware
from ddtrace import patch_all, tracer

# Patch all libraries supported by ddtrace
patch_all()

class TracingMiddleware(DDWSGIMiddleware):
    """
    Thin subclass of DDWSGIMiddleware that delegates attribute access
    to the wrapped Odoo application, preserving session_store and
    any other attributes Odoo expects on http.root.
    """
    def __init__(self, app, *args, **kwargs):
        super().__init__(app, *args, **kwargs)
        self._odoo_app = app  # keep a direct reference

    def __getattr__(self, name):
        # Fall back to the wrapped Odoo app for any unknown attribute
        # This covers session_store, db_filter, etc.
        return getattr(self._odoo_app, name)

odoo.http.root = TracingMiddleware(odoo.http.root)
```

> **Note:** This wraps the Odoo WSGI application with Datadog's `DDWSGIMiddleware`, enabling distributed tracing for all incoming HTTP requests. The `__getattr__` override ensures Odoo's internal attributes (such as `session_store`) remain accessible through the middleware.

---

### 3. Setup Docker for Odoo

Refer to [docker/README.md](./docker/README.md) for the full Docker setup instructions for Odoo.
Add this following environment variables on docker-compose.yml to enable tagging
- DD_SERVICE
- DD_ENV
- DD_VERSION
- DD_PROFILING_ENABLED (optional to enable profiling)
- DD_AGENT_HOST (to communicate with Docker agent using host IP)