from flask import Blueprint, request, render_template

mainpage_bp = Blueprint('index', __name__,url_prefix = '/')

@mainpage_bp.route('/')
def index():
    return render_template('index.html')