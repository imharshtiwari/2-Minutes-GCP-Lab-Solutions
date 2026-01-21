import os
import sys

# Import Google Cloud Library modules
from google.cloud import storage, bigquery, language, vision, translate_v2

# Credential Check
if ('GOOGLE_APPLICATION_CREDENTIALS' in os.environ):
    if (not os.path.exists(os.environ['GOOGLE_APPLICATION_CREDENTIALS'])):
        print ("The GOOGLE_APPLICATION_CREDENTIALS file does not exist.\n")
        exit()
else:
    print ("The GOOGLE_APPLICATION_CREDENTIALS environment variable is not defined.\n")
    exit()

if len(sys.argv)<3:
    print('You must provide parameters for the Google Cloud project ID and Storage bucket')
    print ('python3 '+sys.argv[0]+ ' [PROJECT_NAME] [BUCKET_NAME]')
    exit()

project_name = sys.argv[1]
bucket_name = sys.argv[2]

# Set up clients
storage_client = storage.Client()
bq_client = bigquery.Client(project=project_name)
nl_client = language.LanguageServiceClient()
vision_client = vision.ImageAnnotatorClient()
translate_client = translate_v2.Client()

# Setup the BigQuery dataset and table objects
dataset_ref = bq_client.dataset('image_classification_dataset')
table_ref = dataset_ref.table('image_text_detail')
table = bq_client.get_table(table_ref)

rows_for_bq = []

# Get list of files
files = storage_client.bucket(bucket_name).list_blobs()
bucket = storage_client.bucket(bucket_name)

print('Processing image files from GCS. This will take a few minutes..')

for file in files:
    if file.name.endswith('jpg') or file.name.endswith('png'):
        file_content = file.download_as_string()

        # Create a Vision API image object
        image_object = vision.Image(content=file_content)

        # Detect text in the image
        response = vision_client.text_detection(image=image_object)
        
        # Check if text was actually found to avoid IndexErrors
        if response.text_annotations:
            text_data = response.text_annotations[0].description
            desc = response.text_annotations[0].description
            locale = response.text_annotations[0].locale

            # Save text detection to GCS as a .txt file
            file_name = file.name.split('.')[0] + '.txt'
            blob = bucket.blob(file_name)
            blob.upload_from_string(text_data, content_type='text/plain')

            # FIXED: Translation Logic (Translating to English 'en')
            if locale == 'en':
                translated_text = desc
            else:
                # Target language set to 'en' (English) as per standard lab requirements
                translation = translate_client.translate(desc, target_language='en')
                translated_text = translation['translatedText']
            
            print(f"File: {file.name} | Translated: {translated_text[:50]}...")

            # Prepare row for BigQuery
            rows_for_bq.append((desc, locale, translated_text, file.name))

print('Writing Vision API image data to BigQuery...')

# FIXED: Insert rows and check for errors
if rows_for_bq:
    errors = bq_client.insert_rows(table, rows_for_bq)
    if errors == []:
        print("Success: Data inserted into BigQuery.")
    else:
        print(f"Errors occurred: {errors}")
else:
    print("No data found to insert.")
