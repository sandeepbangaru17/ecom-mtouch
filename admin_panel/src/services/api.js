const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8000/api/v1';

async function parseResponse(response) {
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.detail ?? 'Request failed');
  }
  return data;
}

function headers(token, isJson = true) {
  return {
    ...(isJson ? { 'Content-Type': 'application/json' } : {}),
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };
}

export async function loginAdmin(email, password) {
  const response = await fetch(`${API_BASE_URL}/auth/login`, {
    method: 'POST',
    headers: headers(),
    body: JSON.stringify({ email, password }),
  });
  const data = await parseResponse(response);
  if (!data.user?.is_admin) {
    throw new Error('This account does not have admin access.');
  }
  return data;
}

export async function fetchProducts({ search = '', page = 1, pageSize = 20 } = {}) {
  const params = new URLSearchParams({
    search,
    page: String(page),
    page_size: String(pageSize),
  });
  const response = await fetch(`${API_BASE_URL}/products?${params}`);
  return parseResponse(response);
}

export async function createProduct(token, payload) {
  const response = await fetch(`${API_BASE_URL}/products`, {
    method: 'POST',
    headers: headers(token),
    body: JSON.stringify(payload),
  });
  return parseResponse(response);
}

export async function updateProduct(token, id, payload) {
  const response = await fetch(`${API_BASE_URL}/products/${id}`, {
    method: 'PUT',
    headers: headers(token),
    body: JSON.stringify(payload),
  });
  return parseResponse(response);
}

export async function deleteProduct(token, id) {
  const response = await fetch(`${API_BASE_URL}/products/${id}`, {
    method: 'DELETE',
    headers: headers(token),
  });
  if (!response.ok) {
    const data = await response.json();
    throw new Error(data.detail ?? 'Failed to delete product');
  }
}

export async function uploadImage(token, file) {
  const formData = new FormData();
  formData.append('file', file);
  const response = await fetch(`${API_BASE_URL}/uploads/image`, {
    method: 'POST',
    headers: headers(token, false),
    body: formData,
  });
  return parseResponse(response);
}

export async function fetchOrders(token) {
  const response = await fetch(`${API_BASE_URL}/admin/orders`, {
    headers: headers(token, false),
  });
  return parseResponse(response);
}

export async function updateOrderStatus(token, orderId, status) {
  const response = await fetch(`${API_BASE_URL}/orders/${orderId}/status`, {
    method: 'PUT',
    headers: headers(token),
    body: JSON.stringify({ status }),
  });
  return parseResponse(response);
}
