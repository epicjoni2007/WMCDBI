import cv2
from pyzbar import pyzbar
import requests
import base64
import json

def get_product_info(barcode):
    """
    Ruft Produktinformationen von der OpenFoodFacts API ab.
    """
    url = f"https://world.openfoodfacts.net/api/v2/product/{barcode}.json"

    # Authentifizierung wie in deinem Beispiel (off:off)
    auth = base64.b64encode(b"off:off").decode("utf-8")
    headers = {"Authorization": f"Basic {auth}"}

    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        data = response.json()
        if data.get("status") == 1:
            product = data["product"]
            name = product.get("product_name", "Unbekanntes Produkt")
            brand = product.get("brands", "Unbekannte Marke")
            print(f"✅ Gefunden: {name} ({brand})")
            return product
        else:
            print("❌ Produkt nicht gefunden.")
    else:
        print(f"⚠️ Fehler: {response.status_code}")

    return None


def scan_barcodes():
    """
    Öffnet die Kamera und scannt Barcodes in Echtzeit.
    """
    cap = cv2.VideoCapture(0)
    print("📷 Kamera gestartet. Drücke 'q' zum Beenden.")

    scanned = set()

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        # Barcodes im Bild finden
        barcodes = pyzbar.decode(frame)

        for barcode in barcodes:
            barcode_data = barcode.data.decode("utf-8")

            if barcode_data not in scanned:
                print(f"🔍 Barcode erkannt: {barcode_data}")
                get_product_info(barcode_data)
                scanned.add(barcode_data)

            # Zeichnet das Rechteck um den Barcode
            (x, y, w, h) = barcode.rect
            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)

        cv2.imshow("Barcode Scanner", frame)

        # Beenden mit 'q'
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    scan_barcodes()
