from flask import Flask, request, jsonify
from flask_cors import CORS
import math
import requests

app = Flask(__name__)
CORS(app)

def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0:
            return False
    return True

def is_perfect(n):
    if n < 1:
        return False
    sum = 0
    for i in range(1, n):
        if n % i == 0:
            sum += i
    return sum == n

def is_armstrong(n):
    num_str = str(n)
    power = len(num_str)
    return n == sum(int(digit) ** power for digit in num_str)

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
    return sum(int(digit) for digit in str(n))

def get_fun_fact(n):
    try:
        response = requests.get(f"http://numbersapi.com/{n}/math")
        return response.text
    except:
        if is_armstrong(n):
            digits = str(n)
            power = len(digits)
            return f"{n} is an Armstrong number because " + " + ".join(f"{d}^{power}" for d in digits) + f" = {n}"
        return f"The number {n} has {len(str(n))} digits"

@app.route('/api/classify-number', methods=['GET'])
def classify_number():
    try:
        number = request.args.get('number')
        if not number:
            return jsonify({"number": None, "error": True}), 400
        
        number = int(number)
        
        response = {
            "number": number,
            "is_prime": is_prime(number),
            "is_perfect": is_perfect(number),
            "properties": get_properties(number),
            "digit_sum": get_digit_sum(number),
            "fun_fact": get_fun_fact(number)
        }
        
        return jsonify(response), 200
    
    except ValueError:
        return jsonify({"number": request.args.get('number'), "error": True}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
