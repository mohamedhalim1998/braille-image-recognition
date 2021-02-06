from flask import Flask, render_template, request, jsonify
from braille import *

app = Flask(__name__)


@app.route('/', methods=['GET', 'POST'])
def index():
    if (request.method == 'POST'):
        print(str(request.files))
        url = request.files['url']
        url.save(url.filename)
        word = analyze(url.filename)
        json_file = {'word': word}
        return jsonify(json_file)
    else:
        return render_template("index.html")


if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0")
