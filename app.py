import streamlit as st
import pandas as pd
import joblib
import numpy as np

# Konfigurasi halaman
st.set_page_config(page_title="Prediksi Harga Sepatu", layout="wide")

# Fungsi untuk memuat semua aset yang diperlukan
@st.cache_resource
def load_assets():
    """Memuat model, preprocessor, dan daftar untuk dropdown."""
    try:
        model = joblib.load('model.pkl')
        preprocessor = joblib.load('preprocessor.pkl')
        brands = joblib.load('brands.pkl')
        categories = joblib.load('categories.pkl')
        return model, preprocessor, brands, categories
    except FileNotFoundError as e:
        st.error(f"Error: File aset tidak ditemukan. Pastikan file .pkl ada di direktori yang sama. Detail: {e}")
        return None, None, None, None

model, preprocessor, brands, categories = load_assets()

# Judul dan deskripsi aplikasi
st.title('👟 Aplikasi Prediksi Harga Sepatu')
st.markdown("""
Aplikasi ini memprediksi harga sepatu dalam Rupiah (IDR) berdasarkan merek, kategori, dan rating.
Model ini dilatih menggunakan algoritma **Decision Tree Regressor**.
""")

# Hanya tampilkan UI jika semua aset berhasil dimuat
if all([model, preprocessor, brands, categories]):
    # Membuat kolom untuk input pengguna
    col1, col2 = st.columns([2, 3])

    with col1:
        st.subheader("Masukkan Detail Sepatu")
        # Input dari pengguna dengan daftar yang sudah dimuat
        brand = st.selectbox('Pilih Merek:', options=brands)
        category = st.selectbox('Pilih Kategori Fungsional:', options=categories)
        rating = st.slider('Pilih Rating:', min_value=0.0, max_value=5.0, value=4.0, step=0.1)

    # Tombol untuk melakukan prediksi
    if st.button('Prediksi Harga', use_container_width=True):
        # Membuat DataFrame dari input pengguna
        input_data = pd.DataFrame({
            'Brand_Name': [brand],
            'RATING': [rating],
            'Category': [category]
        })
        
        # Lakukan pra-pemrosesan pada data input
        input_processed = preprocessor.transform(input_data)
        
        # Lakukan prediksi
        prediction = model.predict(input_processed)
        predicted_price = prediction[0]
        
        # Tampilkan hasil prediksi di kolom kedua
        with col2:
            st.subheader("Hasil Prediksi")
            st.metric(label="Prediksi Harga Sepatu", value=f"Rp {predicted_price:,.2f}")
            st.info("Catatan: Prediksi ini didasarkan pada data historis dan mungkin tidak sepenuhnya akurat untuk semua produk.")
            
else:
    st.warning("Aplikasi tidak dapat dijalankan karena aset model gagal dimuat.")


st.markdown("---")
st.write("Proyek UAS - Modern Prediction and Machine Learning")
st.write("Nama: Ade Ahmad Faizal")