from flask import Blueprint, request, render_template

mainpage_dp = Blueprint('index', __name__,url_prefix = '/')

@mainpage_dp.route('/')
def index():
    return render_template('index.html')