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
    sum = 0
    for i in range(1, abs(n)):  # Handle negative numbers in perfect check
        if n % i == 0:
            sum += i
    return sum == abs
