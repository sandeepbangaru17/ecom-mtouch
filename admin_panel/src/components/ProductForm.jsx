import { useEffect, useState } from 'react';

const initialState = {
  name: '',
  description: '',
  price: '',
  image_url: '',
};

export default function ProductForm({
  token,
  mode = 'create',
  product,
  onSubmit,
  onUploadImage,
  isSaving,
}) {
  const [form, setForm] = useState(initialState);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    if (product) {
      setForm({
        name: product.name,
        description: product.description,
        price: String(product.price),
        image_url: product.image_url,
      });
      return;
    }
    setForm(initialState);
  }, [product]);

  async function handleImageUpload(event) {
    const [file] = event.target.files ?? [];
    if (!file) {
      return;
    }
    setUploading(true);
    try {
      const data = await onUploadImage(token, file);
      setForm((current) => ({ ...current, image_url: data.image_url }));
    } finally {
      setUploading(false);
      event.target.value = '';
    }
  }

  function handleSubmit(event) {
    event.preventDefault();
    onSubmit({
      ...form,
      price: Number(form.price),
    });
    if (mode === 'create') {
      setForm(initialState);
    }
  }

  return (
    <form className="panel form-grid" onSubmit={handleSubmit}>
      <div className="panel-header">
        <div>
          <p className="eyebrow">{mode === 'create' ? 'New product' : 'Edit product'}</p>
          <h3>{mode === 'create' ? 'Add product' : `Update ${product?.name ?? ''}`}</h3>
        </div>
      </div>

      <label>
        Product name
        <input
          required
          value={form.name}
          onChange={(event) => setForm((current) => ({ ...current, name: event.target.value }))}
        />
      </label>

      <label>
        Description
        <textarea
          required
          rows="4"
          value={form.description}
          onChange={(event) =>
            setForm((current) => ({ ...current, description: event.target.value }))
          }
        />
      </label>

      <label>
        Price
        <input
          required
          type="number"
          min="1"
          step="0.01"
          value={form.price}
          onChange={(event) => setForm((current) => ({ ...current, price: event.target.value }))}
        />
      </label>

      <label>
        Image URL
        <input
          required
          value={form.image_url}
          onChange={(event) =>
            setForm((current) => ({ ...current, image_url: event.target.value }))
          }
        />
      </label>

      <label className="upload-field">
        Upload product image
        <input type="file" accept="image/*" onChange={handleImageUpload} />
      </label>

      <button className="button primary" type="submit" disabled={isSaving || uploading}>
        {isSaving ? 'Saving...' : mode === 'create' ? 'Create product' : 'Save changes'}
      </button>

      {(uploading || form.image_url) && (
        <div className="preview-card">
          <span>{uploading ? 'Uploading image...' : 'Preview'}</span>
          {form.image_url && <img src={form.image_url} alt={form.name || 'Preview'} />}
        </div>
      )}
    </form>
  );
}
