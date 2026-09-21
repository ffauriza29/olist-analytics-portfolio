import os
import glob
import logging
import pandas as pd
from google.cloud import bigquery
from google.api_core.exceptions import GoogleAPIError

# ==================== KONFIGURASI ====================
GCP_KEY_PATH = "gcp-key.json"
PROJECT_ID = "latihan-data-505310"        # ← GANTI dengan Project ID GCP Anda
DATASET_NAME = "olist_raw"
SOURCE_FOLDER = "raw_data"

# ==================== SETUP LOGGING ====================
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("pipeline.log"),
        logging.StreamHandler()
    ]
)

# ==================== FUNGSI BACA CSV DENGAN ENCODING TEPAT ====================
def read_csv_smart(file_path):
    """
    Coba baca CSV dengan berbagai encoding dan handling.
    """
    # List encoding yang akan dicoba (urutan prioritas)
    encodings = ['utf-8', 'latin-1', 'iso-8859-1', 'cp1252']
    
    for encoding in encodings:
        try:
            # Coba baca dengan pandas
            # error_bad_lines=False akan skip baris yang error (deprecated, pakai on_bad_lines)
            df = pd.read_csv(
                file_path,
                encoding=encoding,
                on_bad_lines='skip',  # Skip baris yang bermasalah
                low_memory=False      # Untuk file besar
            )
            logging.info(f"✅ Berhasil baca dengan encoding: {encoding}")
            return df
        except Exception as e:
            logging.info(f"❌ Gagal dengan encoding {encoding}: {e}")
            continue
    
    raise Exception(f"Tidak bisa baca file {file_path} dengan encoding apapun")

# ==================== FUNGSI UTAMA ====================
def upload_files_to_bigquery():
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = GCP_KEY_PATH
    client = bigquery.Client()
    
    dataset_id = f"{PROJECT_ID}.{DATASET_NAME}"
    
    dataset = bigquery.Dataset(dataset_id)
    dataset.location = "US"
    client.create_dataset(dataset, exists_ok=True)
    logging.info(f"Dataset {dataset_id} siap digunakan.")
    
    pattern = os.path.join(SOURCE_FOLDER, "*.csv")
    csv_files = glob.glob(pattern)
    
    if not csv_files:
        logging.warning(f"Tidak ada file CSV ditemukan di folder {SOURCE_FOLDER}")
        return
    
    logging.info(f"Ditemukan {len(csv_files)} file CSV untuk diproses.")
    
    success_count = 0
    failed_files = []
    
    for file_path in csv_files:
        filename = os.path.basename(file_path)
        table_name = filename.replace('.csv', '').replace('-', '_').lower()
        table_id = f"{dataset_id}.{table_name}"
        
        logging.info(f"Memproses: {filename} -> {table_id}")
        
        try:
            # Baca CSV dengan pandas (handle encoding otomatis)
            df = read_csv_smart(file_path)
            logging.info(f" DataFrame: {df.shape[0]} baris x {df.shape[1]} kolom")
            
            # Upload ke BigQuery menggunakan pandas
            job = client.load_table_from_dataframe(
                df,
                table_id,
                job_config=bigquery.LoadJobConfig(
                    write_disposition="WRITE_TRUNCATE"
                )
            )
            job.result()
            
            table = client.get_table(table_id)
            logging.info(f"✅ Berhasil! Tabel {table_id} kini memiliki {table.num_rows} baris.")
            success_count += 1
            
        except GoogleAPIError as e:
            logging.error(f"❌ Gagal upload {filename}: {e}")
            failed_files.append(filename)
        except Exception as e:
            logging.error(f"❌ Error tak terduga pada {filename}: {e}")
            failed_files.append(filename)
    
    logging.info("=" * 50)
    logging.info(f"PROSES SELESAI: {success_count} sukses, {len(failed_files)} gagal.")
    if failed_files:
        logging.warning(f"File yang gagal: {failed_files}")

if __name__ == "__main__":
    upload_files_to_bigquery()