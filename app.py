import streamlit as st
import pandas as pd
import joblib
import time

# --- 1. Muat Model dan Preprocessor ---
# Menggunakan path relatif agar bisa berjalan saat di-deploy
try:
    model = joblib.load('C:/Users/Ade Ahmad Faizal/OneDrive - Universitas Islam Indonesia/Documents/Semester 4/MPML/UAS/model.pkl')
    preprocessor = joblib.load('C:/Users/Ade Ahmad Faizal/OneDrive - Universitas Islam Indonesia/Documents/Semester 4/MPML/UAS/preprocessor.pkl')
except FileNotFoundError:
    st.error("File 'model.pkl' atau 'preprocessor.pkl' tidak ditemukan.")
    st.stop()

# --- 2. Konfigurasi Halaman dan Gaya Kustom (CSS) ---
st.set_page_config(
    page_title="Prediksi Harga Sepatu",
    page_icon="👟",
    layout="wide"
)

st.markdown("""
<style>
    /* Latar belakang dengan gradien */
    .stApp {
        background-image: linear-gradient(to right top, #6d327c, #485DA6, #008793, #00BF72, #A8EB12);
    }
    
    /* Gaya untuk judul utama */
    h1 {
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

# --- 3. Sidebar untuk Input Pengguna ---
st.sidebar.header("Masukkan Detail Sepatu")

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

# --- 4. Halaman Utama ---
st.title("Aplikasi Prediksi Harga Sepatu")
st.markdown("Selamat datang! Aplikasi ini menggunakan model *Machine Learning* untuk memberikan estimasi harga sepatu berdasarkan fitur yang Anda pilih di sidebar.")

# --- 5. Logika untuk Menampilkan Prediksi ---
if submit_button:
    input_data = pd.DataFrame({
        'Brand_Name': [brand],
        'RATING': [rating],
        'Category': [category]
    })

    with st.spinner('Sedang menghitung prediksi...'):
        time.sleep(1) # Simulasi proses
        processed_data = preprocessor.transform(input_data)
        prediction = model.predict(processed_data)
        
        col1, col2 = st.columns([1,2])
        with col1:
            st.metric(
                label="Prediksi Harga",
                value=f"Rp {prediction[0]:,.0f}"
            )
        with col2:
            st.info(f"Estimasi harga untuk sepatu **{brand}** dengan kategori **{category}** dan rating **{rating}**.")

st.markdown("---")
st.write("Dibuat oleh **Ade Ahmad Faizal** untuk Proyek UAS MPML.")
