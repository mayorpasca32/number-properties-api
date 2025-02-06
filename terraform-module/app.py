from flask import Flask, request, jsonify
from flask_cors import CORS
import math
import requests

app = Flask(__name__)
CORS(app)

def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(math.sqrt(abs(n))) + 1):
        if abs(n) % i == 0:
            return False
    return True

def is_perfect(n):
    if n < 1:
        return False

    sum_of_divisors = 0
    abs_n = abs(n)

    try:
        int_n = int(abs_n)  # Convert to integer
    except ValueError:
        return False # Or handle non-integer input as needed

    for i in range(1, int_n):  # Use integer for range
        if abs_n % i == 0:      # Use float for modulo
            sum_of_divisors += i
    return sum_of_divisors == abs_n  # Compare with original float/int

def is_armstrong(n):
  try:
      num_str = str(abs(int(n)))
      power = len(num_str)
      return abs(int(n)) == sum(int(digit) ** power for digit in num_str)
  except ValueError:
      return False

def get_properties(n):
    properties = []
    if is_armstrong(n):
        properties.append("armstrong")

    if n % 2 == 0:
        properties.append("even")
    else:
        properties.append("odd")

    return properties

def get_digit_sum(n):
    try:
        return sum(int(digit) for digit in str(abs(int(n))))
    except ValueError:
        return 0

def get_fun_fact(n):
    try:
        response = requests.get(f"http://numbersapi.com/{n}/math")
        response.raise_for_status()
        return response.text
    except requests.exceptions.RequestException:
        if is_armstrong(n):
            digits = str(abs(int(n)))
            power = len(digits)
            return f"{n} is an Armstrong number because " + " + ".join(f"{d}^{power}" for d in digits) + f" = {abs(int(n))}"
        return f"The number {n} has {len(str(abs(n)))} digits"


@app.route('/api/classify-number', methods=['GET'])
def classify_number():
    number_str = request.args.get('number')
    print(f"Received number_str: {number_str}")

    if not number_str or number_str.strip() == "":
        print("Number string is missing or empty")
        return jsonify({"number": None, "error": True}), 400

    try:
        number = float(number_str)
        print(f"Converted number to float: {number}")
    except ValueError:
        print("Invalid number format")
        return jsonify({"number": number_str, "error": True}), 400

    try:
        response = {
            "number": number,
            "is_prime": is_prime(number),
            "is_perfect": is_perfect(number),
            "properties": get_properties(number),
            "digit_sum": get_digit_sum(number),
            "fun_fact": get_fun_fact(number),
        }
        print(f"Response being sent: {response}")
        return jsonify(response), 200

    except Exception as e:
        print(f"An error occurred during processing: {e}")
        return jsonify({"error": True, "message": str(e)}), 500


if __name__ == '__main__':
    print("Flask application starting...")
    app.run(host='0.0.0.0', port=5001, debug=True)
