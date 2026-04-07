import { useEffect, useMemo, useState } from 'react';

import { useAuth } from '../context/AuthContext';
import {
  createProduct,
  deleteProduct,
  fetchOrders,
  fetchProducts,
  updateOrderStatus,
  updateProduct,
  uploadImage,
} from '../services/api';
import ProductForm from '../components/ProductForm';

const orderStatuses = ['Pending', 'Confirmed', 'Delivered'];

export default function DashboardPage() {
  const { token, user, signOut } = useAuth();
  const [activeTab, setActiveTab] = useState('products');
  const [products, setProducts] = useState([]);
  const [orders, setOrders] = useState([]);
  const [search, setSearch] = useState('');
  const [editingProduct, setEditingProduct] = useState(null);
  const [isLoadingProducts, setIsLoadingProducts] = useState(true);
  const [isLoadingOrders, setIsLoadingOrders] = useState(true);
  const [savingProduct, setSavingProduct] = useState(false);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    void loadProducts();
    void loadOrders();
  }, []);

  async function loadProducts(searchTerm = '') {
    setIsLoadingProducts(true);
    try {
      const data = await fetchProducts({ search: searchTerm, page: 1, pageSize: 50 });
      setProducts(data.items);
    } catch (loadError) {
      setError(loadError.message);
    } finally {
      setIsLoadingProducts(false);
    }
  }

  async function loadOrders() {
    setIsLoadingOrders(true);
    try {
      const data = await fetchOrders(token);
      setOrders(data.items);
    } catch (loadError) {
      setError(loadError.message);
    } finally {
      setIsLoadingOrders(false);
    }
  }

  async function handleCreateProduct(payload) {
    setSavingProduct(true);
    setError('');
    try {
      await createProduct(token, payload);
      setMessage('Product created successfully.');
      await loadProducts(search);
    } catch (saveError) {
      setError(saveError.message);
    } finally {
      setSavingProduct(false);
    }
  }

  async function handleUpdateProduct(payload) {
    if (!editingProduct) {
      return;
    }
    setSavingProduct(true);
    setError('');
    try {
      await updateProduct(token, editingProduct.id, payload);
      setEditingProduct(null);
      setMessage('Product updated successfully.');
      await loadProducts(search);
    } catch (saveError) {
      setError(saveError.message);
    } finally {
      setSavingProduct(false);
    }
  }

  async function handleDeleteProduct(productId) {
    if (!window.confirm('Delete this product?')) {
      return;
    }
    setError('');
    try {
      await deleteProduct(token, productId);
      setMessage('Product deleted successfully.');
      await loadProducts(search);
    } catch (deleteError) {
      setError(deleteError.message);
    }
  }

  async function handleStatusChange(orderId, status) {
    setError('');
    try {
      await updateOrderStatus(token, orderId, status);
      setMessage(`Order #${orderId} updated to ${status}.`);
      await loadOrders();
    } catch (statusError) {
      setError(statusError.message);
    }
  }

  const stats = useMemo(() => {
    const totalRevenue = orders.reduce(
      (sum, order) => sum + Number(order.total_amount),
      0,
    );
    const pendingOrders = orders.filter((order) => order.status === 'Pending').length;
    return {
      totalProducts: products.length,
      totalOrders: orders.length,
      totalRevenue,
      pendingOrders,
    };
  }, [orders, products]);

  return (
    <main className="dashboard-shell">
      <header className="hero">
        <div>
          <p className="eyebrow">Operations console</p>
          <h1>ShopFlow admin dashboard</h1>
          <p className="muted">
            Signed in as {user?.name}. Manage products, inspect COD demand, and move orders
            through the delivery lifecycle.
          </p>
        </div>
        <button className="button ghost" type="button" onClick={signOut}>
          Logout
        </button>
      </header>

      <section className="stats-grid">
        <article className="stat-card">
          <span>Products</span>
          <strong>{stats.totalProducts}</strong>
        </article>
        <article className="stat-card">
          <span>Orders</span>
          <strong>{stats.totalOrders}</strong>
        </article>
        <article className="stat-card">
          <span>Pending COD</span>
          <strong>{stats.pendingOrders}</strong>
        </article>
        <article className="stat-card">
          <span>Revenue</span>
          <strong>Rs {stats.totalRevenue.toFixed(2)}</strong>
        </article>
      </section>

      <section className="toolbar">
        <div className="tab-row">
          <button
            className={`button ${activeTab === 'products' ? 'primary' : 'ghost'}`}
            type="button"
            onClick={() => setActiveTab('products')}
          >
            Products
          </button>
          <button
            className={`button ${activeTab === 'orders' ? 'primary' : 'ghost'}`}
            type="button"
            onClick={() => setActiveTab('orders')}
          >
            Orders
          </button>
        </div>

        {activeTab === 'products' && (
          <div className="search-bar">
            <input
              placeholder="Search products"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
            />
            <button className="button primary" type="button" onClick={() => loadProducts(search)}>
              Search
            </button>
          </div>
        )}
      </section>

      {message && <p className="success-text">{message}</p>}
      {error && <p className="error-text">{error}</p>}

      {activeTab === 'products' ? (
        <section className="content-grid">
          <ProductForm
            token={token}
            mode="create"
            onSubmit={handleCreateProduct}
            onUploadImage={uploadImage}
            isSaving={savingProduct}
          />

          <ProductForm
            token={token}
            mode="edit"
            product={editingProduct}
            onSubmit={handleUpdateProduct}
            onUploadImage={uploadImage}
            isSaving={savingProduct}
          />

          <div className="panel list-panel">
            <div className="panel-header">
              <div>
                <p className="eyebrow">Catalog</p>
                <h3>All products</h3>
              </div>
            </div>

            {isLoadingProducts ? (
              <div className="empty-state">Loading products...</div>
            ) : (
              <div className="product-list">
                {products.map((product) => (
                  <article key={product.id} className="product-row">
                    <img src={product.image_url} alt={product.name} />
                    <div>
                      <h4>{product.name}</h4>
                      <p>{product.description}</p>
                      <span>Rs {Number(product.price).toFixed(2)}</span>
                    </div>
                    <div className="actions">
                      <button
                        className="button ghost"
                        type="button"
                        onClick={() => setEditingProduct(product)}
                      >
                        Edit
                      </button>
                      <button
                        className="button danger"
                        type="button"
                        onClick={() => handleDeleteProduct(product.id)}
                      >
                        Delete
                      </button>
                    </div>
                  </article>
                ))}
              </div>
            )}
          </div>
        </section>
      ) : (
        <section className="panel list-panel">
          <div className="panel-header">
            <div>
              <p className="eyebrow">COD orders</p>
              <h3>Fulfillment queue</h3>
            </div>
          </div>

          {isLoadingOrders ? (
            <div className="empty-state">Loading orders...</div>
          ) : (
            <div className="order-list">
              {orders.map((order) => (
                <article key={order.id} className="order-card">
                  <div className="order-topline">
                    <div>
                      <h4>Order #{order.id}</h4>
                      <p>{order.customer_name}</p>
                    </div>
                    <span className={`status-pill status-${order.status.toLowerCase()}`}>
                      {order.status}
                    </span>
                  </div>

                  <p className="muted">{order.shipping_address}</p>
                  <p className="muted">Phone: {order.customer_phone}</p>

                  <div className="item-stack">
                    {order.items.map((item) => (
                      <div key={item.id} className="item-row">
                        <span>{item.product.name}</span>
                        <span>
                          {item.quantity} x Rs {Number(item.unit_price).toFixed(2)}
                        </span>
                      </div>
                    ))}
                  </div>

                  <div className="order-footer">
                    <strong>Rs {Number(order.total_amount).toFixed(2)}</strong>
                    <select
                      value={order.status}
                      onChange={(event) => handleStatusChange(order.id, event.target.value)}
                    >
                      {orderStatuses.map((status) => (
                        <option key={status} value={status}>
                          {status}
                        </option>
                      ))}
                    </select>
                  </div>
                </article>
              ))}
            </div>
          )}
        </section>
      )}
    </main>
  );
}
