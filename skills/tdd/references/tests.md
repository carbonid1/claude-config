# Good and Bad Tests

## Good Tests

**Integration-style**: Test through real interfaces, not mocks of internal parts.

```typescript
import { describe, expect, it } from 'vitest'

// GOOD: Tests observable behavior
describe('checkout', () => {
  it('confirms order with valid cart', async () => {
    const cart = createCart()
    cart.add(product)
    const result = await checkout(cart, paymentMethod)
    expect(result.status).toBe('confirmed')
  })
})
```

Characteristics:

- Tests behavior users/callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test

## Vitest Conventions

**StrictMode wrapper for hooks.** Always wrap hook tests with `<StrictMode>` — catches ref mutation bugs from double-mount:

```typescript
const { result } = renderHook(() => useMyHook(), {
  wrapper: ({ children }) => <StrictMode>{children}</StrictMode>,
})
```

**Assert outcomes, not DOM method calls.** jsdom mocks don't reproduce browser side effects (e.g., `load()` with no `src` fires `onerror`), so verifying DOM method calls gives false confidence. Assert observable outcomes instead:

```typescript
// GOOD: Asserts observable behavior
expect(result.current.isPlaying).toBe(false)

// BAD: Asserts implementation detail that jsdom may not faithfully simulate
expect(audio.removeAttribute).toHaveBeenCalledWith('src')
```

**Skip tests when TypeScript already validates.** Pure type transformations, simple prop-threading, and config objects don't need tests — the compiler catches those mistakes.

## Bad Tests

**Implementation-detail tests**: Coupled to internal structure.

```typescript
import { describe, expect, it, vi } from 'vitest'

// BAD: Tests implementation details
describe('checkout', () => {
  it('calls paymentService.process', async () => {
    const mockPayment = vi.fn()
    await checkout(cart, payment)
    expect(mockPayment).toHaveBeenCalledWith(cart.total)
  })
})
```

Red flags:

- Mocking internal collaborators
- Testing private methods
- Asserting on call counts/order
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT
- Verifying through external means instead of interface

```typescript
import { describe, expect, it } from 'vitest'

describe('createUser', () => {
  // BAD: Bypasses interface to verify
  it('saves to database', async () => {
    await createUser({ name: 'Alice' })
    const row = await db.query('SELECT * FROM users WHERE name = ?', ['Alice'])
    expect(row).toBeDefined()
  })

  // GOOD: Verifies through interface
  it('makes user retrievable', async () => {
    const user = await createUser({ name: 'Alice' })
    const retrieved = await getUser(user.id)
    expect(retrieved.name).toBe('Alice')
  })
})
```
