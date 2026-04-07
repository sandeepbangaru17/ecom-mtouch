import { createContext, useContext, useMemo, useState } from 'react';

import { loginAdmin } from '../services/api';

const AuthContext = createContext(null);
const STORAGE_KEY = 'shopflow_admin_session';

function readInitialSession() {
  const raw = window.localStorage.getItem(STORAGE_KEY);
  if (!raw) {
    return { token: null, user: null };
  }

  try {
    return JSON.parse(raw);
  } catch {
    window.localStorage.removeItem(STORAGE_KEY);
    return { token: null, user: null };
  }
}

export function AuthProvider({ children }) {
  const initial = readInitialSession();
  const [token, setToken] = useState(initial.token);
  const [user, setUser] = useState(initial.user);
  const [isLoading, setIsLoading] = useState(false);

  async function signIn(email, password) {
    setIsLoading(true);
    try {
      const data = await loginAdmin(email, password);
      setToken(data.access_token);
      setUser(data.user);
      window.localStorage.setItem(
        STORAGE_KEY,
        JSON.stringify({ token: data.access_token, user: data.user }),
      );
    } finally {
      setIsLoading(false);
    }
  }

  function signOut() {
    setToken(null);
    setUser(null);
    window.localStorage.removeItem(STORAGE_KEY);
  }

  const value = useMemo(
    () => ({
      token,
      user,
      isLoading,
      isAuthenticated: Boolean(token && user),
      signIn,
      signOut,
    }),
    [isLoading, token, user],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const value = useContext(AuthContext);
  if (!value) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return value;
}
