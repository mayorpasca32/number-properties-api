from flask import Flask, request, jsonify
from flask_cors import CORS
import math
import requests

app = Flask(__name__)
CORS(app)

def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(math.sqrt(abs(n))) + 1):  # Handle negative numbers in prime check
        if n % i == 0:
            return False
    return True

def is_perfect(n):
    if n < 1:
        return False
    sum_of_divisors = 0  # More descriptive variable name
    for i in range(1, abs(n)):  # Iterate from 1 up to (but not including) the number itself
        if abs(n) % i == 0:  # Use abs(n) to handle negative input
            sum_of_divisors += i
    return sum_of_divisors == abs(n)  # Correct comparison
