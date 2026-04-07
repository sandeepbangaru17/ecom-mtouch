import { useState } from 'react';

import { useAuth } from '../context/AuthContext';

export default function LoginPage() {
  const { signIn, isLoading } = useAuth();
  const [form, setForm] = useState({ email: 'admin@shopflow.com', password: 'admin123' });
  const [error, setError] = useState('');

  async function handleSubmit(event) {
    event.preventDefault();
    setError('');
    try {
      await signIn(form.email, form.password);
    } catch (submissionError) {
      setError(submissionError.message);
    }
  }

  return (
    <main className="login-shell">
      <section className="login-card">
        <p className="eyebrow">ShopFlow Admin</p>
        <h1>Manage products and COD orders</h1>
        <p className="muted">
          Sign in with the seeded admin account or any admin user created in the backend.
        </p>

        <form onSubmit={handleSubmit} className="form-grid">
          <label>
            Email
            <input
              type="email"
              value={form.email}
              onChange={(event) => setForm({ ...form, email: event.target.value })}
              required
            />
          </label>

          <label>
            Password
            <input
              type="password"
              value={form.password}
              onChange={(event) => setForm({ ...form, password: event.target.value })}
              required
            />
          </label>

          <button className="button primary" type="submit" disabled={isLoading}>
            {isLoading ? 'Signing in...' : 'Login'}
          </button>
        </form>

        {error && <p className="error-text">{error}</p>}
      </section>
    </main>
  );
}
