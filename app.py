import streamlit as st
import pandas as pd
import joblib
import time

# Muat model dan preprocessor yang telah disimpan
# Pastikan file model.pkl dan preprocessor.pkl ada di folder yang sama
try:
    model = joblib.load('C:/Users/Ade Ahmad Faizal/OneDrive - Universitas Islam Indonesia/Documents/Semester 4/MPML/UAS/model.pkl')
    preprocessor = joblib.load('C:/Users/Ade Ahmad Faizal/OneDrive - Universitas Islam Indonesia/Documents/Semester 4/MPML/UAS/preprocessor.pkl')
except FileNotFoundError:
    st.error("File model atau preprocessor tidak ditemukan. Pastikan 'model.pkl' dan 'preprocessor.pkl' ada di direktori yang sama.")
    st.stop()

# --- Konfigurasi Halaman Web ---
st.set_page_config(
    page_title="Prediksi Harga Sepatu",
    page_icon="👟",
    layout="wide"
)

# --- Gaya Kustom (CSS) untuk Tampilan yang Lebih Menarik ---
st.markdown("""
<style>
    /* Latar belakang dengan gradien */
    .stApp {
        background-image: linear-gradient(to right top, #d16ba5, #c777b9, #ba83ca, #aa8fd8, #9a9ae1, #8aa7ec, #79b3f4, #69bff8, #52cffe, #41dfff, #46eefa, #5ffbf1);
    }
    
    /* Gaya untuk judul utama */
    .stTitle {
        font-weight: bold;
        color: #FFFFFF;
        text-shadow: 2px 2px 4px #000000;
    }

    /* Gaya untuk form di sidebar */
    .st-emotion-cache-16txtl3 {
        padding: 2rem 1.5rem;
        background-color: rgba(255, 255, 255, 0.1);
        border-radius: 10px;
    }

    /* Gaya untuk tombol */
    .stButton>button {
        color: #ffffff;
        background-color: #007BFF;
        border-radius: 50px;
        padding: 10px 20px;
        font-weight: bold;
        border: none;
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        transition: all 0.3s;
    }
    .stButton>button:hover {
        background-color: #0056b3;
        transform: translateY(-2px);
        box-shadow: 0 6px 12px rgba(0,0,0,0.15);
    }

    /* Gaya untuk hasil prediksi */
    .stMetric {
        background-color: #FFFFFF;
        border-left: 5px solid #007BFF;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }
</style>
""", unsafe_allow_html=True)


# --- Sidebar untuk Input Pengguna ---
st.sidebar.header("Masukkan Detail Sepatu")

# Opsi untuk Dropdown
brand_options = [
    'ASIAN', 'Adidas', 'BATA', 'BUROJ', 'Bourge', 'Campus', 'Centrino', 
    'Corstyle', 'D Shoes', 'FEETEES', 'FURO', 'Generic', 'Kraasa', 'Nivia', 
    'Puma', 'Reebok', 'Robbie jones', 'Sparx', 'URJO', 'Wakefield', 'Axter', 
    'road runner'
]
category_options = [
    'Casual', 'Other', 'Running', 'Sneakers', 'Sports', 'Training & Gym', 'Walking'
]

with st.sidebar.form("prediction_form"):
    brand = st.selectbox("🏷️ Merek Sepatu", options=brand_options)
    category = st.selectbox("👟 Kategori Fungsional", options=category_options)
    rating = st.slider("⭐ Rating", min_value=1.0, max_value=5.0, step=0.1, value=4.0)
    
    submit_button = st.form_submit_button(label="Prediksi Harga")

# --- Halaman Utama ---
st.title("Aplikasi Prediksi Harga Sepatu")
st.markdown("Selamat datang! Aplikasi ini menggunakan model *Machine Learning* untuk memberikan estimasi harga sepatu berdasarkan fitur yang Anda pilih di sidebar.")

# --- Logika untuk Menampilkan Prediksi ---
if submit_button:
    # Buat DataFrame dari input pengguna
    input_data = pd.DataFrame({
        'Brand_Name': [brand],
        'RATING': [rating],
        'Category': [category]
    })

    # Tampilkan animasi loading
    with st.spinner('Sedang menghitung prediksi...'):
        time.sleep(1) # Simulasi proses
        try:
            # Proses data input
            processed_data = preprocessor.transform(input_data)
            
            # Lakukan prediksi
            prediction = model.predict(processed_data)
            
            # Tampilkan hasil dalam kolom
            col1, col2 = st.columns([1,2])
            with col1:
                st.metric(
                    label="Prediksi Harga",
                    value=f"Rp {prediction[0]:,.0f}"
                )
            with col2:
                st.info(f"Estimasi harga untuk sepatu **{brand}** dengan kategori **{category}** dan rating **{rating}**.")

        except Exception as e:
            st.error(f"Terjadi kesalahan saat melakukan prediksi: {e}")

st.markdown("---")
st.write("Dibuat oleh **Ade Ahmad Faizal** untuk Proyek UAS MPML.")
