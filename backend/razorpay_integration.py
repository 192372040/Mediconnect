# pyrefly: ignore [missing-import]
import razorpay
import os

# Initialize the Razorpay client
# Keys provided by the user
RAZORPAY_KEY_ID = "rzp_test_T3R0IL2TZZC1Gl"
RAZORPAY_KEY_SECRET = "SqT3fZo37Y7JfY7vOCfV1UAq"

client = razorpay.Client(auth=(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET))

def create_razorpay_order(amount, receipt_id="receipt_1"):
    """
    Creates an order in Razorpay.
    Note: amount should be in rupees if you are passing the total amount,
    but Razorpay expects the amount in paise (1 INR = 100 paise).
    So we multiply the amount by 100.
    """
    try:
        data = {
            "amount": int(float(amount) * 100), # Convert to paise
            "currency": "INR",
            "receipt": receipt_id,
            "payment_capture": 1 # Auto capture
        }
        order = client.order.create(data=data)
        return {"success": True, "order_id": order["id"]}
    except Exception as e:
        return {"success": False, "error": str(e)}

def verify_razorpay_payment(payment_id, order_id, signature):
    """
    Verify the payment signature.
    """
    try:
        params_dict = {
            'razorpay_order_id': order_id,
            'razorpay_payment_id': payment_id,
            'razorpay_signature': signature
        }
        # returns None if successful, raises SignatureVerificationError otherwise
        client.utility.verify_payment_signature(params_dict)
        return True
    except Exception as e:
        return False
